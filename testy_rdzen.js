#!/usr/bin/env node
// ═══ TESTY RDZENIA — falsyfikacja krzyżowa silników ═══
// Uruchomienie: node --test testy_rdzen.js
// Zero zależności poza node:test (wbudowany, node >= 18).
//
// EPISTEMOLOGIA: premisa "dwa niezależne silniki (VSOP87 vs Meeus) → zaufanie"
// była do 9.07.2026 sprawdzona w JEDNYM punkcie (29.06.2026, weryfikacja.js).
// Ten plik rozszerza ją na: 365-dniowy sweep, kotwice syzygiów, regresję.
// weryfikacja.js strzeże FORMY (hashe, obecność); ten plik strzeże TREŚCI (liczby).
//
// Tolerancje NIE są arbitralne — wyprowadzone z pomiaru 9.07.2026:
//   zmierzone maksima 2026: Δlon 3.0′ · Δdecl 1.2′ · Δfazy 0.1 h · rozjazd znaku 0/365
//   progi = ~3× margines na dryf zależności.

const test = require('node:test');
const assert = require('node:assert');
const A = require('astronomy-engine');
const v4 = require('./narzedzia/silniki/kronos_v4.js');
const en = require('./narzedzia/silniki/kronos_engine.js');

const JD = d => 2440587.5 + d.getTime() / 86400000;
const dLon = (a, b) => { let x = ((a - b) % 360 + 360) % 360; return x > 180 ? 360 - x : x; };

// ── 1. SWEEP KRZYŻOWY: 365 dni 2026, dwa niezależne silniki ──
test('sweep 2026: silniki zgodne co do longitudy syderycznej (< 10 arcmin)', () => {
  for (let i = 0; i < 365; i++) {
    const d = new Date(Date.UTC(2026, 0, 1, 12)); d.setUTCDate(d.getUTCDate() + i);
    const diff = dLon(v4.sidLon('Moon', d), en.moonSid(JD(d)));
    assert.ok(diff < 10 / 60, `${d.toISOString().slice(0, 10)}: Δlon = ${(diff * 60).toFixed(1)}′`);
  }
});

test('sweep 2026: zgodny znak konstelacji (365/365)', () => {
  for (let i = 0; i < 365; i++) {
    const d = new Date(Date.UTC(2026, 0, 1, 12)); d.setUTCDate(d.getUTCDate() + i);
    const c1 = v4.getC(v4.sidLon('Moon', d)).pl, c2 = en.getC(en.moonSid(JD(d))).pl;
    assert.strictEqual(c1, c2, `${d.toISOString().slice(0, 10)}: v4=${c1} vs engine=${c2}`);
  }
});

test('sweep 2026: deklinacja zgodna (< 5 arcmin) — kierunek wstępujący/zstępujący pewny', () => {
  for (let i = 0; i < 365; i++) {
    const d = new Date(Date.UTC(2026, 0, 1, 12)); d.setUTCDate(d.getUTCDate() + i);
    const diff = Math.abs(v4.moonDecl(d) - en.moonDecl(JD(d)));
    assert.ok(diff < 5 / 60, `${d.toISOString().slice(0, 10)}: Δdecl = ${(diff * 60).toFixed(1)}′`);
  }
});

test('sweep 2026: faza zgodna (< 0.001 cyklu ≈ 42 min)', () => {
  for (let i = 0; i < 365; i++) {
    const d = new Date(Date.UTC(2026, 0, 1, 12)); d.setUTCDate(d.getUTCDate() + i);
    let dp = Math.abs(v4.phaseInfo(d).p - en.phase(JD(d)));
    dp = Math.min(dp, 1 - dp);
    assert.ok(dp < 0.001, `${d.toISOString().slice(0, 10)}: Δfazy = ${dp.toFixed(5)}`);
  }
});

// ── 2. KOTWICE SYZYGIÓW: fazy kardynalne (nów/kwadry/pełnia) — rdzeń [ODDECH] ──
// SearchMoonQuarter (astronomy-engine, algorytm poszukiwania) vs phase() (Meeus, obliczenie)
// — dwie niezależne drogi muszą wskazać ten sam instant fazy kardynalnej.
test('kotwice 2026: instanty faz kardynalnych zgodne między silnikami (< 20 min)', () => {
  let q = A.SearchMoonQuarter(new Date(Date.UTC(2026, 0, 1)));
  let n = 0;
  while (q.time.date.getUTCFullYear() === 2026 && n < 60) {
    const pMeeus = en.phase(JD(q.time.date));
    const pOczek = q.quarter / 4; // 0=nów, 0.25=I kw, 0.5=pełnia, 0.75=III kw
    let dp = Math.abs(pMeeus - pOczek); dp = Math.min(dp, 1 - dp);
    // 20 min = 0.00047 cyklu
    assert.ok(dp < 0.0005, `${q.time.date.toISOString()}: kwadra ${q.quarter}, Δ = ${(dp * 29.53 * 24 * 60).toFixed(0)} min`);
    q = A.NextMoonQuarter(q); n++;
  }
  assert.ok(n >= 48, `oczekiwano ≥48 faz kardynalnych w 2026, znaleziono ${n}`);
});

// Inwariant niezależny od decyzji szeroko/wąsko: w DOKŁADNYM instancie pełni
// OBA klasyfikatory muszą mówić "Pełnia". (Szerokość okna = decyzja kanoniczna, otwarta.)
test('inwariant pełni: dokładny instant syzygium = "Pełnia" w obu klasyfikatorach', () => {
  let q = A.SearchMoonQuarter(new Date(Date.UTC(2026, 0, 1)));
  while (q.quarter !== 2) q = A.NextMoonQuarter(q); // pierwsza pełnia 2026
  const d = q.time.date;
  assert.strictEqual(v4.phaseInfo(d).nm, 'Pełnia', 'v4/phaseInfo w instancie pełni');
  assert.strictEqual(en.phaseName(en.phase(JD(d)))[0], 'Pełnia', 'engine/phaseName w instancie pełni');
});

// ── 3. KOTWICE REGRESYJNE: złote wartości zamrożone 9.07.2026 ──
// UWAGA: to NIE jest prawda zewnętrzna (tę daje walidacja historyczna vs dnisiewu.pl,
// mediana ~15′). To migawka stanu OBU silników przy astronomy-engine ^2.1.19 —
// strażnik przed cichym dryfem po bumpie zależności lub edycji Meeusa.
test('regresja: złote wartości z 9.07.2026 (tolerancja 1 arcmin od migawki)', () => {
  const zlote = [
    // [ISO UTC, sidLon v4, moonSid engine] — zmierzone, nie z pamięci
    ['2026-03-20T12:00:00Z', null, null],
    ['2026-06-29T06:00:00Z', null, null],
    ['2026-09-23T12:00:00Z', null, null],
    ['2026-12-21T12:00:00Z', null, null],
  ];
  // Wartości wpisuje skrypt kalibracyjny (patrz niżej) — jeśli null, test je DRUKUJE
  const ZLOTE = require('./testy_rdzen_zlote.json');
  for (const [iso, ...__] of zlote) {
    const d = new Date(iso);
    const z = ZLOTE[iso];
    assert.ok(z, `brak złotej wartości dla ${iso} — uruchom kalibrację`);
    assert.ok(dLon(v4.sidLon('Moon', d), z.v4) < 1 / 60, `${iso}: v4 odjechał od migawki`);
    assert.ok(dLon(en.moonSid(JD(d)), z.en) < 1 / 60, `${iso}: engine odjechał od migawki`);
  }
});

// ── 4. getC: granice, wrap Ryb, wejścia patologiczne (funkcja najbardziej krytyczna) ──
test('getC: półotwarta semantyka [s, e) na każdej granicy', () => {
  for (const c of v4.CONST) {
    assert.strictEqual(v4.getC(c.s).pl, c.pl, `start ${c.s}° należy do ${c.pl}`);
    // e należy już do następnej konstelacji:
    assert.notStrictEqual(v4.getC(c.e).pl, c.pl, `koniec ${c.e}° NIE należy do ${c.pl}`);
  }
});

test('getC: segment wrap (Ryby przez 0°/360°)', () => {
  const ryby = v4.CONST.find(c => c.s > c.e);
  assert.ok(ryby, 'istnieje dokładnie jeden segment wrap');
  assert.strictEqual(v4.getC(ryby.s).pl, ryby.pl);
  assert.strictEqual(v4.getC(0).pl, ryby.pl, '0° wewnątrz wrapu');
  assert.strictEqual(v4.getC(ryby.e - 0.001).pl, ryby.pl, 'tuż przed końcem wrapu');
});

test('getC: kopie v4/engine logicznie równoważne (sweep co 0.1°)', () => {
  for (let s = 0; s < 360; s += 0.1) {
    assert.strictEqual(v4.getC(s).pl, en.getC(s).pl, `rozjazd kopii przy ${s.toFixed(1)}°`);
  }
});

test('getC: pokrycie pełne — suma segmentów = 360°, bez dziur i nakładek', () => {
  let suma = 0;
  for (const c of v4.CONST) suma += ((c.e - c.s) % 360 + 360) % 360;
  assert.ok(Math.abs(suma - 360) < 1e-9, `suma segmentów = ${suma}°`);
});

// ── 5. STREFA CZASOWA PL — warstwa WEJŚCIA (godzina twórcy → instant) ──
// RODOWÓD (13.08.2026): sześć kopii logiki DST, trzy różne ziarna czasowe.
// v4 i engine dzieliły ziarno DOBOWE — ten sam błąd w obu, więc falsyfikacja
// krzyżowa była tu ślepa Z ZAŁOŻENIA (błąd skorelowany ≠ dwóch świadków).
// Sweep 365-dniowy podaje gotowy Date.UTC i OMIJA tę warstwę — stąd 13 miesięcy ciszy.
// PRAWDA NAZIEMNA: Intl/tzdata — trzeci przyrząd, spoza naszej ręki.
//
// BLIZNA TEGO TORU (ta sama tura): pierwsza wersja mierzyła godzinę LOKALNĄ
// przeciw prawdzie liczonej dla godziny UTC i oskarżyła poprawny kod. Tor też
// jest narzędziem — i też nie jest świadkiem własnej poprawności.
const TZ = require('./narzedzia/silniki/tz_pl.js');

const PRZELACZENIA = [
  [2026, 3, 29], [2026, 10, 25],
  [2027, 3, 28], [2027, 10, 31],
  [2028, 3, 26], [2028, 10, 29],
];
// odczyt tzdata dla INSTANTU (jednoznaczny, bez dwuznaczności godziny lokalnej)
const FMT_PL = new Intl.DateTimeFormat('en-GB', {
  timeZone: 'Europe/Warsaw', hour12: false,
  year: 'numeric', month: '2-digit', day: '2-digit', hour: '2-digit', minute: '2-digit',
  timeZoneName: 'shortOffset',
});
const offTzdata = ms => parseInt(FMT_PL.format(ms).match(/GMT([+-]\d+)/)[1], 10);
const godzTzdata = ms => +FMT_PL.formatToParts(ms).find(p => p.type === 'hour').value;

test('tz: offAt zgodny z tzdata na siatce instantów wokół przełączeń (±36 h co 15 min)', () => {
  let prob = 0;
  for (const [y, m, d] of PRZELACZENIA) {
    const srodek = Date.UTC(y, m - 1, d, 1);           // instant przełączenia
    for (let ms = srodek - 36 * 3600000; ms <= srodek + 36 * 3600000; ms += 15 * 60000) {
      prob++;
      assert.strictEqual(TZ.offAt(ms), offTzdata(ms),
        `${new Date(ms).toISOString()}: tz_pl +${TZ.offAt(ms)} vs tzdata +${offTzdata(ms)}`);
    }
  }
  assert.ok(prob > 1700, `siatka za rzadka: ${prob} prób`);
});

test('tz: round-trip godziny lokalnej — localToUTC → tzdata zwraca tę samą godzinę', () => {
  for (const [y, m, d] of PRZELACZENIA) {
    for (const dd of [d - 1, d, d + 1]) {
      for (let h = 0; h < 24; h++) {
        // 02:00 marca nie istnieje — jedyny udokumentowany wyjątek konwencji
        if (m === 3 && dd === d && h === 2) continue;
        const ms = TZ.localToUTC(y, m, dd, h);
        assert.strictEqual(godzTzdata(ms), h,
          `${y}-${m}-${dd} ${h}:00 PL → instant ${new Date(ms).toISOString()} = ${godzTzdata(ms)}:00 wg tzdata`);
      }
    }
  }
});

test('tz: v4 i engine wskazują TEN SAM instant dla tej samej godziny lokalnej', () => {
  for (const [y, m, d] of PRZELACZENIA) {
    for (const dd of [d - 1, d, d + 1]) {
      for (const h of [0, 1, 3, 12, 23]) {
        const msV4 = v4.analyze(y, m, dd, h).date.getTime();
        const msEn = (en.analyze(y, m, dd, h).j - 2440587.5) * 86400000;
        assert.ok(Math.abs(msV4 - msEn) < 1000,
          `${y}-${m}-${dd} ${h}:00 → rozjazd ${((msV4 - msEn) / 60000).toFixed(0)} min`);
      }
    }
  }
});

test('tz: godzina 0 to północ, nie brak wartości (klasa `h||12`)', () => {
  assert.strictEqual(TZ.godzWejscia(0), 0, '0 musi przejść jako 0');
  assert.strictEqual(TZ.godzWejscia(undefined), 12, 'brak → domyślne 12');
  assert.strictEqual(TZ.godzWejscia(NaN), 12, 'NaN z parsowania argv → domyślne 12');
  const polnoc = v4.analyze(2026, 8, 13, 0).date.getTime();
  const poludnie = v4.analyze(2026, 8, 13, 12).date.getTime();
  assert.strictEqual((poludnie - polnoc) / 3600000, 12, 'północ ≠ południe');
  const enPolnoc = en.analyze(2026, 8, 13, 0).j, enPoludnie = en.analyze(2026, 8, 13, 12).j;
  assert.ok(Math.abs((enPoludnie - enPolnoc) * 24 - 12) < 1e-6, 'engine: północ ≠ południe');
});

test('tz: zakres reguły UE nazwany, nie przemilczany', () => {
  assert.strictEqual(TZ.pozaZakresem(1995), true, '<1996 poza prawem tego modułu');
  assert.strictEqual(TZ.pozaZakresem(1996), false);
});

// ── 6. getC: CICHY FALLBACK (znalezione testem mutacyjnym 13.08.2026) ──
// Ślepota zmierzona, nie domniemana: mutacje `getC-wrap-zerwany` i `getC-cichy-fallback`
// PRZESZŁY przez wszystkie cztery testy getC. Przyczyna zbiegu okoliczności:
// `CONST[0]` to Ryby — a Ryby są też segmentem wrap. Więc gdy wrap się zerwie,
// `return CONST[0]` po cichu zwraca DOKŁADNIE TĘ SAMĄ odpowiedź i błąd jest niewidoczny.
// Fallback zaprojektowany jako siatka bezpieczeństwa działał jak zasłona.
test('getC: wrap działa WEWNĄTRZ segmentu, nie tylko na jego krawędziach', () => {
  const ryby = v4.CONST.find(c => c.s > c.e);
  // punkty głęboko w środku obu ramion wrapu — krawędzie mogłyby trafić przypadkiem
  for (const s of [ryby.s + 5, ryby.s + 15, 355, 358, 1, 3, ryby.e - 1]) {
    assert.strictEqual(v4.getC(((s % 360) + 360) % 360).pl, ryby.pl,
      `${s}° powinno leżeć w ${ryby.pl}`);
  }
});

test('getC: fallback CONST[0] jest NIEOSIĄGALNY dla poprawnego wejścia', () => {
  // Gdyby segmenty pokrywały koło szczelnie, pętla zawsze trafia i `return CONST[0]`
  // nigdy nie wykonuje się jako fallback. Mierzymy to wprost: podmieniamy tożsamość
  // odpowiedzi na taką, której nie da się pomylić z żadnym legalnym trafieniem.
  const trafienia = new Set();
  for (let s = 0; s < 360; s += 0.05) trafienia.add(v4.getC(s).pl);
  assert.strictEqual(trafienia.size, v4.CONST.length,
    `pokryto ${trafienia.size} z ${v4.CONST.length} konstelacji — są dziury albo fallback łata`);
  // każdy stopień musi należeć do segmentu, który go FAKTYCZNIE zawiera
  for (let s = 0; s < 360; s += 0.05) {
    const c = v4.getC(s);
    const wewnatrz = c.s <= c.e ? (s >= c.s && s < c.e) : (s >= c.s || s < c.e);
    assert.ok(wewnatrz, `${s.toFixed(2)}° przypisane do ${c.pl} [${c.s},${c.e}) — poza segmentem (fallback?)`);
  }
});

// ── 7. DOMY: przedział przez 0°/360° (faza A, 13.08.2026) ──
// `domDla` żyła w dwóch identycznych kopiach i miała ZERO pokrycia. Klasa ryzyka
// ta sama co `getC`: dom 12 zamyka się na cuspidzie domu 1, więc ostatni przedział
// prawie zawsze przechodzi przez zero.
const domy = require('./narzedzia/silniki/domy.js');

test('domy: każdy stopień koła trafia w dokładnie jeden dom', () => {
  // cuspidy nierówne (Placidus bywa mocno asymetryczny) i przechodzące przez 0°
  const cusps = [0, 350, 20, 55, 80, 110, 145, 170, 200, 235, 260, 290, 325];
  const trafione = new Set();
  for (let L = 0; L < 360; L += 0.25) {
    const d = domy.domDla(L, cusps);
    assert.ok(d >= 1 && d <= 12, `${L}° → dom ${d} (0 = dziura w cuspidach)`);
    trafione.add(d);
  }
  assert.strictEqual(trafione.size, 12, `pokryto ${trafione.size}/12 domów`);
});

test('domy: cuspida należy do domu, który OTWIERA (semantyka [a, b))', () => {
  const cusps = [0, 350, 20, 55, 80, 110, 145, 170, 200, 235, 260, 290, 325];
  for (let i = 1; i <= 12; i++) {
    assert.strictEqual(domy.domDla(cusps[i], cusps), i, `cuspida ${cusps[i]}° otwiera dom ${i}`);
  }
});

test('domy: dom 12 obejmuje przejście przez 0° (gałąź wrap)', () => {
  const cusps = [0, 350, 20, 55, 80, 110, 145, 170, 200, 235, 260, 290, 325];
  // dom 12 = [325, 350) — nie przechodzi przez zero; dom 1 = [350, 20) — przechodzi
  for (const L of [350, 355, 359.9, 0, 5, 19.9]) {
    assert.strictEqual(domy.domDla(L, cusps), 1, `${L}° leży w domu 1 (przez 0°)`);
  }
  assert.strictEqual(domy.domDla(20, cusps), 2, '20° już poza wrapem');
});

test('domy: długość spoza [0,360) jest normalizowana (znalezione mutacją)', () => {
  // CUSPIDY DOBRANE ŚWIADOMIE: dom 1 NIE przechodzi przez 0° (wrap siedzi w domu 12).
  // Pierwsza wersja tego toru brała cuspidy z wrapem w domu 1 — wtedy gałąź `L < b`
  // łapała każde ujemne wejście PRZYPADKIEM i mutacja „brak normalizacji" przechodziła
  // niezauważona. Tor nie był za słaby przez przeoczenie, tylko przez dobór danych:
  // fikstura może uczynić prawdziwy błąd niewidzialnym. (Zmierzone: 4 różnice na 7 wejść.)
  const cusps = [0, 10, 40, 70, 100, 130, 160, 190, 220, 250, 280, 310, 340];
  for (const [wejscie, rownowazne] of [[-350, 10], [370, 10], [-180, 180], [400, 40], [720, 0]]) {
    assert.strictEqual(domy.domDla(wejscie, cusps), domy.domDla(rownowazne, cusps),
      `${wejscie}° musi dać ten sam dom co ${rownowazne}°`);
  }
});

test('domy: dziura w cuspidach zwraca 0, nie cichy fallback', () => {
  // celowo zepsute: wszystkie cuspidy identyczne → żaden przedział nie ma szerokości
  const zepsute = [0, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10];
  assert.strictEqual(domy.domDla(200, zepsute), 0,
    'brak trafienia MUSI zostać brakiem trafienia — nie domem 1');
});

// ── PEŁNIA: jedno źródło czasu (29.08.2026, BADANIE_UKLADU_NERWOWEGO §II.1) ──────────
// Do 29.08 narzedzia/silniki/kronos_pelnia.js niósł własną kopię reguły DST o ziarnie DOBOWYM; ten tor
// pyta o linię „wejście:" na dniu przełączenia — godzina 02:30 PL 25.10.2026 jest jeszcze
// CEST (przełączenie 03:00 PL), 03:30 już CET. Kopia dobowa dawała CET dla obu.
test('pelnia: offset z tz_pl na dniu przełączenia (02:30 CEST · 03:30 CET) — nie kopia dobowa', () => {
  const cp = require('node:child_process');
  const wejscie = (h) => cp.execSync(`node narzedzia/silniki/kronos_pelnia.js 2026 10 25 ${h} 30 52.41 16.93`,
    { encoding: 'utf8', stdio: ['ignore', 'pipe', 'ignore'] }).split('\n').find(l => /wejście:/.test(l)) || '';
  assert.match(wejscie(2), /02:30 CEST/, 'o 02:30 PL 25.10.2026 jeszcze CEST');
  assert.match(wejscie(3), /03:30 CET\b/, 'o 03:30 PL 25.10.2026 już CET');
  assert.doesNotMatch(require('node:fs').readFileSync('narzedzia/silniki/kronos_pelnia.js', 'utf8'), /function dstEU/,
    'własna kopia reguły DST nie może wrócić do narzedzia/silniki/kronos_pelnia.js');
});
