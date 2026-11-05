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

// U1-03 (08.10.2026): testy rdzenia mierzą gałąź DOSŁOWNĄ tz_pl.js (Warszawa) i znają ją jako stałą w liczbach — nie mogą zależeć od
// strefy instancji (instancja.json gościa w Nowym Jorku obalała 9 z 49). Ustawione PRZED pierwszym `require` czegokolwiek, co ładuje
// tz_pl.js; testy strefy podają strefę jawnie w `env` procesu potomnego (nadpisuje tę wartość), a wartość '' zostaje tylko tam, gdzie
// test sam buduje drzewo bez instancja.json.
process.env.KRONOS_TZ = 'Europe/Warsaw';
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

// ── 1a (05.10.2026, PAKIET v1.8.1): strefa sprzed 1996 z tzdata, nie z reguły UE ──
// Zmierzone PRZED: natal 1970-07-01 12:00 drukował CEST (+2), tzdata daje +1 — godzina urodzenia
// przesunięta o godzinę bez ostrzeżenia. Świadek: Intl (offTzdata), nie nasza reguła.
test('tz: offLokalny dla lat < 1996 bierze tzdata (1970-07-01 → +1 · 1985-10-10 → +1 · 1995-10-01 → +1 · 1985-07-01 → +2)', () => {
  for (const [y, m, d, h, oczek] of [[1970, 7, 1, 12, 1], [1985, 10, 10, 12, 1], [1995, 10, 1, 12, 1], [1985, 7, 1, 12, 2]]) {
    const r = TZ.offLokalny(y, m, d, h);
    assert.strictEqual(r.off, oczek, `${y}-${m}-${d}: +${r.off}, tzdata +${oczek}`);
    assert.strictEqual(r.zrodlo, 'tzdata');
    assert.strictEqual(offTzdata(Date.UTC(y, m - 1, d, h) - r.off * 3600000), r.off, 'instant z tego offsetu musi go potwierdzić w tzdata');
  }
  const ue = TZ.offLokalny(2000, 7, 1, 12);
  assert.deepStrictEqual(ue, { off: 2, zrodlo: 'UE' }, '2000-07-01 jak dotąd z reguły UE');
});

test('tz: brak danych tzdata RZUCA — nigdy cichy offset (offTzdataAt na instancie nie do odczytu)', () => {
  assert.throws(() => TZ.offTzdataAt(NaN), /tzdata/);
});

test('natal: 1970-07-01 12:00 drukuje UTC+1 i linię o tzdata; 2000-07-01 nadal CEST bez noty', () => {
  const cp = require('node:child_process');
  const wyj = a => cp.execSync(`node narzedzia/silniki/kronos_natal.js ${a} 12 0 50 20`,
    { encoding: 'utf8', stdio: ['ignore', 'pipe', 'ignore'] });
  const stary = wyj('1970 7 1');
  assert.match(stary, /wejście: 1\.7\.1970 12:00 UTC\+1/);
  assert.match(stary, /strefa sprzed 1996: z tzdata/);
  const nowy = wyj('2000 7 1');
  assert.match(nowy, /12:00 CEST/);
  assert.doesNotMatch(nowy, /strefa sprzed 1996/);
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
  const wejscie = (h) => cp.execSync(`node narzedzia/silniki/kronos_pelnia.js 2026 10 25 ${h} 30 50 20`,
    { encoding: 'utf8', stdio: ['ignore', 'pipe', 'ignore'] }).split('\n').find(l => /wejście:/.test(l)) || '';
  assert.match(wejscie(2), /02:30 CEST/, 'o 02:30 PL 25.10.2026 jeszcze CEST');
  assert.match(wejscie(3), /03:30 CET\b/, 'o 03:30 PL 25.10.2026 już CET');
  assert.doesNotMatch(require('node:fs').readFileSync('narzedzia/silniki/kronos_pelnia.js', 'utf8'), /function dstEU/,
    'własna kopia reguły DST nie może wrócić do narzedzia/silniki/kronos_pelnia.js');
});

// ── 1c (05.10.2026, PAKIET v1.8.1): pełnia — zero to wartość, minuty z arytmetyki całkowitej ──
// PRZED (zmierzone): `0 0` → współrzędne domyślne zamiast zera (`Number(x) || stała`); fmtTrop(29,9999°) → „29°60'”.
test('pelnia: współrzędne 0 0 zostają 0 0 (zero to wartość, nie brak)', () => {
  const cp = require('node:child_process');
  const naglowek = a => cp.execSync(`node narzedzia/silniki/kronos_pelnia.js ${a}`,
    { encoding: 'utf8', stdio: ['ignore', 'pipe', 'ignore'] }).split('\n').find(l => /φ/.test(l)) || '';
  assert.match(naglowek('2026 10 5 12 0 0 0'), /φ0 λ0/, '0 0 ma zostać 0 0');
  assert.match(naglowek('2026 10 5 12 0 40.5 -74'), /φ40\.5 λ-74/);
});

test('pelnia: fmtTrop liczy na minutach całkowitych — 29,9999° → następny znak 0°00\', 359,9999° → Baran 0°00\'', () => {
  const fs = require('node:fs');
  const src = fs.readFileSync('narzedzia/silniki/kronos_pelnia.js', 'utf8');
  const blok = src.match(/function fmtTrop[\s\S]*?`; \}/)[0];
  const SY = ['♈','♉','♊','♋','♌','♍','♎','♏','♐','♑','♒','♓'];
  const ZN = ['Baran','Byk','Bliźnięta','Rak','Lew','Panna','Waga','Skorpion','Strzelec','Koziorożec','Wodnik','Ryby'];
  const norm = x => ((x % 360) + 360) % 360;
  const fmtTrop = new Function('norm', 'SY', 'ZN', blok + '; return fmtTrop;')(norm, SY, ZN);
  assert.strictEqual(fmtTrop(29.9999), "♉ Byk 0°00'", 'brak „29°60\'”');
  assert.strictEqual(fmtTrop(359.9999), "♈ Baran 0°00'", 'przeniesienie przez 360°');
  assert.strictEqual(fmtTrop(45.5), "♉ Byk 15°30'");
  assert.strictEqual(fmtTrop(0), "♈ Baran 0°00'");
});

// ── 2d (05.10.2026, PAKIET v1.8.1): lens — „ZMIERZONE TERAZ” z prawdziwą minutą ──
// PRZED (zmierzone): o 19:16 linia pokazywała „19:00 PL”. Zegar wstrzyknięty preloadem (Date zamrożony
// na 5.10.2026 17:24:30 CEST), żeby test nie zależał od chwili, w której biegnie.
test('lens: „ZMIERZONE TERAZ” niesie prawdziwą minutę i nazywa rozdzielczość silnika (17:24 PL · pełna godzina 17:00)', () => {
  const cp = require('node:child_process'), fs = require('node:fs'), os = require('node:os'), path = require('node:path');
  const pre = path.join(fs.mkdtempSync(path.join(os.tmpdir(), 'zegar-')), 'zegar.js');
  fs.writeFileSync(pre, "const R=Date, FIX=R.UTC(2026,9,5,15,24,30); " +
    "global.Date=class extends R{constructor(...a){a.length?super(...a):super(FIX);} static now(){return FIX;}};");
  const wyj = cp.execSync(`node -r ${pre} narzedzia/silniki/kronos_lens.js now`, { encoding: 'utf8', stdio: ['ignore', 'pipe', 'ignore'] });
  const linia = wyj.split('\n').find(l => /ZMIERZONE TERAZ/.test(l)) || '';
  assert.match(linia, /5\.10\.2026 17:24 PL/, 'minuta z zegara, nie zaokrąglona do :00');
  assert.match(linia, /silnik liczy dla pełnej godziny 17:00/, 'rozdzielczość silnika nazwana');
  assert.match(wyj, /╔═══ KRONOS · 5\.10\.2026 17:00 CEST ═══╗/, 'ramka niżej bez zmian');
});

// ── 3a (05.10.2026, PAKIET v1.8.1): drzwi wariant B — dwa pliki drzwi to KOPIE (nie zakładamy, które narzędzie co ładuje) ──
test('drzwi: szablony/drzwi/AGENTS.md i CLAUDE.md mają identyczną treść poza pierwszą linią; bez wartości prywatnych', () => {
  const fs = require('node:fs');
  const [a, c] = ['AGENTS.md', 'CLAUDE.md'].map(f => fs.readFileSync(`szablony/drzwi/${f}`, 'utf8').split('\n'));
  assert.deepStrictEqual(a.slice(1), c.slice(1), 'drzwi rozjechane: dwa pliki mają mówić to samo');
  assert.ok(a.join('\n').includes('bash wstan.sh') && a.join('\n').includes('BEZ DOSTĘPU'), 'drzwi niosą wstanie i zdanie awaryjne');
  // Imion NIE wypisujemy tu (06.10.2026, B2): ten plik jedzie do odlewu, a zamek wycieku (publikuj.sh) słusznie
  // zatrzymał go na liście osobowej z 3a — wzorzec PII nie może stać w pliku z białej listy. Imiona w drzwiach
  // pilnuje ten sam zamek, bo szablony/drzwi/* są na liście odlewu i przechodzą przez niego w etapie 2.
  assert.doesNotMatch(a.join('\n'), /DOBÓR MODELU/, 'drzwi nie niosą tabeli modeli');
});


// ═══ 8. STREFA INSTANCJI (07.10.2026, projekt strefy, krok 1; słowo twórcy 12:19 „Czas twórcy zrobiłbym w tym cyklu.”) ═══
// Dla obcej strefy `tz_pl.js` jest OPAKOWANIEM tzdata, więc „moduł kontra Intl” nie jest świadkiem. Świadkiem są instanty policzone NIEZALEŻNIE
// (Python `zoneinfo`, 07.10.2026) i wpisane tu jako liczby. Każdy test biegnie w procesie potomnym z `KRONOS_TZ` (strefa jest stała na proces).
const cpS = require('node:child_process');
const fsS = require('node:fs');
const osS = require('node:os');
const pathS = require('node:path');
const strefaProc = (tz, kod, cwd) => cpS.spawnSync('node', ['-e', kod], {
  cwd: cwd || __dirname, encoding: 'utf8', env: { ...process.env, KRONOS_TZ: tz },
});
const TZMOD = "const TZ=require('./narzedzia/silniki/tz_pl.js');";
const json = (tz, wyr) => { const r = strefaProc(tz, TZMOD + `process.stdout.write(JSON.stringify(${wyr}))`); assert.strictEqual(r.status, 0, r.stderr); return JSON.parse(r.stdout); };

test('strefa: America/New_York — lato (UTC−4) i zima (UTC−5), instanty z zoneinfo', () => {
  assert.deepStrictEqual(json('America/New_York', '[TZ.localToUTC(2026,7,15,12), TZ.offAt(1784131200000), TZ.nazwa(-4), TZ.STREFA]'),
    [1784131200000, -4, 'UTC−4', 'America/New_York']);
  assert.deepStrictEqual(json('America/New_York', '[TZ.localToUTC(2026,1,15,12), TZ.offAt(1768496400000), TZ.nazwa(-5)]'),
    [1768496400000, -5, 'UTC−5']);
});

test('strefa: America/New_York — oba przełączenia 2026 (luka → skok do przodu, dwuznaczność → pierwsze wystąpienie)', () => {
  // 08.03.2026 02:30 nie istnieje → 03:30 EDT = 07:30Z; 01.11.2026 01:30 jest DWA razy → pierwsze (EDT) = 05:30Z, drugie (EST) = 06:30Z
  assert.deepStrictEqual(json('America/New_York', '[TZ.localToUTC(2026,3,8,2,30), TZ.offAt(1772955000000)]'), [1772955000000, -4]);
  assert.deepStrictEqual(json('America/New_York', '[TZ.localToUTC(2026,11,1,1,30), TZ.offAt(1793511000000), TZ.offAt(1793514600000)]'), [1793511000000, -4, -5]);
});

test('strefa: Asia/Tokyo (UTC+9) i Europe/London zimą (offset 0, nazwa „UTC”)', () => {
  assert.deepStrictEqual(json('Asia/Tokyo', '[TZ.localToUTC(2026,7,15,12), TZ.offAt(1784084400000), TZ.nazwa(9)]'), [1784084400000, 9, 'UTC+9']);
  assert.deepStrictEqual(json('Europe/London', '[TZ.localToUTC(2026,1,15,12), TZ.offAt(1768478400000), TZ.nazwa(0)]'), [1768478400000, 0, 'UTC']);
});

test('strefa: Australia/Sydney — DST odwrócone (styczeń UTC+11, lipiec UTC+10)', () => {
  assert.deepStrictEqual(json('Australia/Sydney', '[TZ.localToUTC(2026,1,15,12), TZ.offAt(1768438800000)]'), [1768438800000, 11]);
  assert.deepStrictEqual(json('Australia/Sydney', '[TZ.localToUTC(2026,7,15,12), TZ.offAt(1784080800000)]'), [1784080800000, 10]);
});

test('strefa: wejście minutowe — localToUTC z minutami i offLokalny z godziną ułamkową (pełnia) nie obcinają minut', () => {
  assert.deepStrictEqual(json('America/New_York', '[TZ.localToUTC(2026,7,15,12,30), TZ.offLokalny(2026,7,15,12.5)]'),
    [1784133000000, { off: -4, zrodlo: 'strefa' }]);
});

test('strefa: Asia/Kolkata (offset niepełnogodzinny) → rc=2 z powodem, nie cichy wynik', () => {
  const r = strefaProc('Asia/Kolkata', TZMOD + 'console.log(TZ.STREFA)');
  assert.strictEqual(r.status, 2);
  assert.match(r.stderr, /niepełnogodzinny nieobsługiwany — podaj czas w UTC \(--utc\)/);
});

test('strefa: nazwa nieznana → rc=2 „nieznana strefa czasu”', () => {
  const r = strefaProc('Mars/Olympus', TZMOD + 'console.log(TZ.STREFA)');
  assert.strictEqual(r.status, 2);
  assert.match(r.stderr, /nieznana strefa czasu/);
});

// Pliki instancji czytane są względem POŁOŻENIA tz_pl.js, więc fikstura to kopia modułu w drzewie tymczasowym.
const drzewoStrefy = (pliki) => {
  const T = fsS.mkdtempSync(pathS.join(osS.tmpdir(), 'kronos_strefa_'));
  fsS.mkdirSync(pathS.join(T, 'narzedzia', 'silniki'), { recursive: true });
  fsS.copyFileSync(pathS.join(__dirname, 'narzedzia', 'silniki', 'tz_pl.js'), pathS.join(T, 'narzedzia', 'silniki', 'tz_pl.js'));
  for (const [n, t] of Object.entries(pliki)) fsS.writeFileSync(pathS.join(T, n), t);
  return T;
};
const strefaZDrzewa = (T, tz) => cpS.spawnSync('node', [pathS.join(T, 'narzedzia', 'silniki', 'tz_pl.js'), '--strefa'],
  { encoding: 'utf8', cwd: osS.tmpdir(), env: { ...process.env, KRONOS_TZ: tz || '' } });

test('strefa: instancja.json uszkodzony → rc=2, NIGDY cichy powrót do Warszawy', () => {
  const T = drzewoStrefy({ 'instancja.json': '{ to nie jest json' });
  const r = strefaZDrzewa(T);
  fsS.rmSync(T, { recursive: true, force: true });
  assert.strictEqual(r.status, 2);
  assert.match(r.stderr, /instancja\.json nieparsowalny/);
});

test('strefa: brak instancja.json → Warszawa (stała; package.json bez pola też)', () => {
  const T = drzewoStrefy({});
  const r = strefaZDrzewa(T);
  fsS.rmSync(T, { recursive: true, force: true });
  assert.strictEqual(r.status, 0);
  assert.strictEqual(r.stdout.trim(), 'Europe/Warsaw');
});

test('strefa: pierwszeństwo KRONOS_TZ > instancja.json > package.json > stała', () => {
  const T = drzewoStrefy({ 'package.json': '{"kronos":{"strefa":"Europe/London"}}' });
  assert.strictEqual(strefaZDrzewa(T).stdout.trim(), 'Europe/London');                       // package.json bije stałą
  fsS.writeFileSync(pathS.join(T, 'instancja.json'), '{"strefa":"Asia/Tokyo"}');
  assert.strictEqual(strefaZDrzewa(T).stdout.trim(), 'Asia/Tokyo');                          // instancja.json bije package.json
  assert.strictEqual(strefaZDrzewa(T, 'America/New_York').stdout.trim(), 'America/New_York'); // KRONOS_TZ bije instancja.json
  fsS.rmSync(T, { recursive: true, force: true });
});

// U1-03: mierzy package.json repo, nie instancja.json gościa — fikstura = kopia package.json repo, BEZ instancja.json.
test('strefa: w repo domyślna rdzenia to Europe/Warsaw (package.json kronos.strefa)', () => {
  const T = drzewoStrefy({ 'package.json': fsS.readFileSync(pathS.join(__dirname, 'package.json'), 'utf8') });
  const r = strefaZDrzewa(T);
  fsS.rmSync(T, { recursive: true, force: true });
  assert.strictEqual(r.status, 0);
  assert.strictEqual(r.stdout.trim(), 'Europe/Warsaw');
});

// ── krok 2 strefy (07.10.2026): kronos_lens — PION liczony z offsetu silnika, nie z `||2` ──
// Londyn w styczniu = offset 0; stare `r.off||2` brało 0 za brak i liczyło o 2 h wcześniej.
// Świadek: ta sama chwila podana warszawską godziną (zima, +1) — PION musi być identyczny.
test('lens: PION dla strefy z offsetem 0 (Londyn, styczeń) = ta sama chwila podana w Warszawie', () => {
  const pion = (tz, h) => {
    const r = cpS.spawnSync('node', ['narzedzia/silniki/kronos_lens.js', '2027', '1', '15', String(h)], { cwd: __dirname, encoding: 'utf8', env: { ...process.env, KRONOS_TZ: tz } });
    assert.strictEqual(r.status, 0, r.stderr);
    const l = r.stdout.split('\n').find(x => x.startsWith('⇅ PION'));
    assert.ok(l, 'linia PION istnieje');
    return l;
  };
  assert.strictEqual(pion('Europe/London', 12), pion('Europe/Warsaw', 13));
});

// ── krok 3 strefy (07.10.2026): wezownik.fmtPL z tz_pl.js, nie z własnej reguły DST ──
// Własna reguła porównywała północ UTC doby z 01:00 UTC przełączenia — cała doba przełączenia
// (od 01:00 UTC) wypadała z reżimem sprzed zmiany. Świadek: chwile wyliczone ręcznie (UTC → lokalny).
test('wezownik now: doba przełączenia czasu (Warszawa) i strefa obca w linii ZMIERZONE TERAZ', () => {
  const zegar = (ms, tz) => {
    const pre = pathS.join(fsS.mkdtempSync(pathS.join(require('node:os').tmpdir(), 'zegar-')), 'z.js');
    fsS.writeFileSync(pre, `const R=Date, FIX=${ms}; global.Date=class extends R{constructor(...a){a.length?super(...a):super(FIX);} static now(){return FIX;}};`);
    const r = cpS.spawnSync('node', ['-r', pre, 'narzedzia/silniki/wezownik.js', 'now'], { cwd: __dirname, encoding: 'utf8', env: { ...process.env, KRONOS_TZ: tz } });
    assert.strictEqual(r.status, 0, r.stderr);
    return (r.stdout.split('\n').find(l => /ZMIERZONE TERAZ/.test(l)) || '');
  };
  assert.match(zegar(Date.UTC(2026, 2, 29, 12, 0), 'Europe/Warsaw'), /29\.03\.2026 14:00 CEST$/);  // po przełączeniu 01:00 UTC
  assert.match(zegar(Date.UTC(2026, 9, 25, 12, 0), 'Europe/Warsaw'), /25\.10\.2026 13:00 CET$/);
  assert.match(zegar(Date.UTC(2027, 0, 15, 12, 0), 'Europe/London'), /15\.01\.2027 12:00 UTC$/);
});

// ── krok 6 strefy (07.10.2026): etykiety z wartości (TZ.nazwa), „PL” tylko dla Warszawy ──
test('etykiety strefy: obca strefa niesie swoją nazwę (UTC−4 / nazwa IANA), Warszawa bez zmian', () => {
  const uruchom = (tz, plik, ...a) => {
    const r = cpS.spawnSync('node', ['narzedzia/silniki/' + plik, ...a], { cwd: __dirname, encoding: 'utf8', env: { ...process.env, KRONOS_TZ: tz } });
    assert.strictEqual(r.status, 0, plik + ': ' + r.stderr);
    return r.stdout;
  };
  assert.match(uruchom('America/New_York', 'kronos_lens.js', '2026', '7', '10', '12'), /10\.07\.2026 12:00 UTC−4 ═══╗/);
  assert.match(uruchom('America/New_York', 'kronos_matryca.js', '2026', '7', '10', '12'), /MATRYCA · 10\.07\.2026 12:00 UTC−4/);
  assert.match(uruchom('America/New_York', 'scan_outer.js', '2026', '7', '10'), /godzina lokalna America\/New_York/);
  assert.match(uruchom('Europe/Warsaw', 'scan_outer.js', '2026', '7', '10'), /godzina lokalna PL\n?/);
  assert.match(uruchom('Europe/Warsaw', 'kronos_lens.js', '2026', '7', '10', '12'), /12:00 CEST ═══╗/);
  assert.match(uruchom('Europe/Warsaw', 'kronos_lens.js', '2026', '1', '10', '12'), /12:00 CET ═══╗/);
});

// ── krok 7 strefy (07.10.2026): kronos_impuls formatuje datę w strefie silnika (TZ.STREFA), nie w literale Warszawy ──
// Start impulsu = północ UTC doby: 7.10 00:00 UTC to w Warszawie 7.10 (02:00), a w Nowym Jorku jeszcze 6.10 (20:00).
test('kronos_impuls: data startu w strefie silnika (Warszawa 7.10, Nowy Jork 6.10)', () => {
  const pre = pathS.join(fsS.mkdtempSync(pathS.join(require('node:os').tmpdir(), 'zegar-')), 'z.js');
  fsS.writeFileSync(pre, "const R=Date, FIX=R.UTC(2026,9,7,20,0); global.Date=class extends R{constructor(...a){a.length?super(...a):super(FIX);} static now(){return FIX;}};");
  const linia = tz => {
    const r = cpS.spawnSync('node', ['-r', pre, 'narzedzia/silniki/kronos_impuls.js'], { cwd: __dirname, encoding: 'utf8', env: { ...process.env, KRONOS_TZ: tz } });
    assert.strictEqual(r.status, 0, r.stderr);
    return r.stdout.split('\n').find(l => /IMPULS ASPEKTOWY/.test(l)) || '';
  };
  assert.match(linia('Europe/Warsaw'), /dni od 7\.10\.2026/);
  assert.match(linia('America/New_York'), /dni od 6\.10\.2026/);
});

// ── krok 8 strefy (07.10.2026): kronos_natal --strefa <IANA> dla GODZINY URODZENIA ──
// Świadek: 10.07.2026 12:00 w Nowym Jorku = 16:00 UTC (UTC−4, wyliczone ręcznie). Współrzędne okrągłe, przykładowe.
test('natal --strefa: ta sama chwila co --utc daje identyczne pozycje; --utc wygrywa; brak wartości = rc=2', () => {
  const nat = (...a) => cpS.spawnSync('node', ['narzedzia/silniki/kronos_natal.js', ...a], { cwd: __dirname, encoding: 'utf8', env: { ...process.env, KRONOS_TZ: '' } });
  const bezWejscia = r => { assert.strictEqual(r.status, 0, r.stderr); return r.stdout.split('\n').filter(l => !l.startsWith('wejście')).join('\n'); };
  const lokalnie = nat('2026', '7', '10', '12', '0', '50', '20', '--strefa', 'America/New_York');
  const utc      = nat('2026', '7', '10', '16', '0', '50', '20', '--utc');
  assert.strictEqual(bezWejscia(lokalnie), bezWejscia(utc));
  assert.match(lokalnie.stdout, /wejście: 10\.7\.2026 12:00 UTC−4/);
  assert.strictEqual(bezWejscia(nat('2026', '7', '10', '12', '0', '50', '20', '--strefa=America/New_York')), bezWejscia(utc));   // forma z `=`
  const utcWygrywa = nat('2026', '7', '10', '16', '0', '50', '20', '--utc', '--strefa', 'America/New_York');
  assert.strictEqual(bezWejscia(utcWygrywa), bezWejscia(utc));
  assert.strictEqual(nat('2026', '7', '10', '12', '0', '50', '20', '--strefa').status, 2);
});

// ── krok 8 strefy / T4 + krok 11 (07.10.2026): kronos_pelnia — miejsce z instancja.json, brak miejsca = rc=2 ──
// Drzewo tymczasowe (instancja.json warsztatu nie jest świadkiem): kopia silników + dowiązany node_modules. Współrzędne okrągłe, przykładowe.
test('pelnia: miejsce z instancja.json; brak miejsca i brak argumentów = rc=2; argumenty wygrywają; 5 argumentów nie bierze godziny za szerokość', () => {
  const T = fsS.mkdtempSync(pathS.join(osS.tmpdir(), 'kronos_miejsce_'));
  fsS.mkdirSync(pathS.join(T, 'narzedzia'), { recursive: true });
  fsS.cpSync(pathS.join(__dirname, 'narzedzia', 'silniki'), pathS.join(T, 'narzedzia', 'silniki'), { recursive: true });
  fsS.copyFileSync(pathS.join(__dirname, 'package.json'), pathS.join(T, 'package.json'));
  fsS.symlinkSync(pathS.join(__dirname, 'node_modules'), pathS.join(T, 'node_modules'));
  const uruchom = (...a) => cpS.spawnSync('node', [pathS.join(T, 'narzedzia', 'silniki', 'kronos_pelnia.js'), ...a], { encoding: 'utf8', cwd: T, env: { ...process.env, KRONOS_TZ: '' } });
  const naglowek = (...a) => { const r = uruchom(...a); assert.strictEqual(r.status, 0, r.stderr); return (r.stdout.split('\n').find(l => /KRONOS · PEŁNIA —/.test(l)) || ''); };
  const brak = uruchom('now');
  assert.strictEqual(brak.status, 2, 'bez instancja.json i bez argumentów: rc=2');
  assert.match(brak.stderr, /podaj LAT LON albo ustaw `miejsce` w instancja\.json/);
  fsS.writeFileSync(pathS.join(T, 'instancja.json'), '{ "strefa": "Europe/Warsaw", "miejsce": null }');
  assert.strictEqual(uruchom('now').status, 2, 'szablon gościa (miejsce: null): rc=2');
  assert.strictEqual(uruchom('2026', '10', '5', '12', '0').status, 2, '5 argumentów bez współrzędnych i bez miejsca: rc=2 (godzina i minuta nie są współrzędnymi)');
  fsS.writeFileSync(pathS.join(T, 'instancja.json'), '{"miejsce":{"lat":50,"lon":20,"nazwa":"przykład"}}');
  assert.match(naglowek('now'), /φ50 λ20/, 'miejsce z instancja.json');
  assert.match(naglowek('2026', '10', '5', '12', '0'), /φ50 λ20/, '5 argumentów: miejsce z instancja.json, nie (godzina, minuta)');
  assert.match(naglowek('now', '10', '30'), /φ10 λ30/, 'argumenty wiersza poleceń wygrywają');
  fsS.rmSync(T, { recursive: true, force: true });
});

// ── krok 10 strefy (07.10.2026): stemple czasu w powłoce idą przez strefę instancji (tz_pl.js --strefa) ──
// Świadek: zegar UTC procesu testowego (+9 h dla Tokio, ±3 min na uruchomienie); rodowod.sh drukuje „zmierzone HH:MM”.
test('powłoka: rodowod.sh stempluje czas w strefie instancji (KRONOS_TZ=Asia/Tokyo = UTC+9), Warszawa bez zmian', () => {
  const godz = tz => {
    const r = cpS.spawnSync('bash', ['narzedzia/przyrzady/rodowod.sh', 'narzedzia/silniki/tz_pl.js'], { cwd: __dirname, encoding: 'utf8', env: { ...process.env, KRONOS_TZ: tz } });
    const m = /zmierzone (\d\d):(\d\d)/.exec(r.stdout);
    assert.ok(m, tz + ': brak stempla w wyjściu rodowod.sh');
    return +m[1] * 60 + +m[2];
  };
  const odl = (a, b) => { const d = Math.abs(a - b) % 1440; return Math.min(d, 1440 - d); };
  const u = new Date(), utcMin = u.getUTCHours() * 60 + u.getUTCMinutes();
  assert.ok(odl(godz('Asia/Tokyo'), (utcMin + 540) % 1440) <= 3, 'Tokio = UTC+9');
  const wa = new Date(Date.now() + 0), offW = require('./narzedzia/silniki/tz_pl.js').offAt(wa);   // domyślna strefa procesu = Warszawa (KRONOS_TZ='' w env potomnego niżej)
  assert.ok(odl(godz('Europe/Warsaw'), (utcMin + offW * 60) % 1440) <= 3, 'Warszawa = UTC+1/+2');
});

// ── U1-14a/U1-06/U1-14b (08.10.2026): nazwa kanoniczna strefy · prawdziwy powód w natal/pełni · rc=2 w lens ──
test('strefa: nazwa kanoniczna — europe/warsaw i Poland idą gałęzią Warszawy (CEST, STREFA = Europe/Warsaw)', () => {
  for (const tz of ['europe/warsaw', 'Poland', 'EUROPE/WARSAW']) {
    assert.deepStrictEqual(json(tz, '[TZ.STREFA, TZ.nazwa(2), TZ.nazwa(1), TZ.ETYKIETA]'), ['Europe/Warsaw', 'CEST', 'CET', 'PL'], tz);
  }
  assert.strictEqual(json('america/new_york', 'TZ.STREFA'), 'America/New_York');   // wielkość liter innej strefy też sprowadzona do kanonicznej
});

test('strefa: offset niepełnogodzinny w danym roku → natal, pełnia i lens kończą rc=2 z PRAWDZIWYM powodem (nie „rok < 1996”, nie stos)', () => {
  const env = { ...process.env, KRONOS_TZ: 'Asia/Singapore' };   // 1975: UTC+7:30
  const nat = cpS.spawnSync('node', ['narzedzia/silniki/kronos_natal.js', '1975', '6', '1', '12', '0', '1.3', '103.8', '--strefa', 'Asia/Singapore'], { cwd: __dirname, encoding: 'utf8', env: { ...process.env, KRONOS_TZ: '' } });
  assert.strictEqual(nat.status, 2); assert.match(nat.stdout, /niepełnogodzinny/); assert.doesNotMatch(nat.stdout, /rok < 1996/);
  const pel = cpS.spawnSync('node', ['narzedzia/silniki/kronos_pelnia.js', '1975', '6', '1', '12', '0', '1.3', '103.8'], { cwd: __dirname, encoding: 'utf8', env });
  assert.strictEqual(pel.status, 2); assert.match(pel.stdout, /niepełnogodzinny/); assert.doesNotMatch(pel.stdout, /rok < 1996/);
  const len = cpS.spawnSync('node', ['narzedzia/silniki/kronos_lens.js', '1975', '6', '1', '12'], { cwd: __dirname, encoding: 'utf8', env });
  assert.strictEqual(len.status, 2); assert.match(len.stderr, /niepełnogodzinny/); assert.doesNotMatch(len.stderr, /\n\s+at /);
});

// ── K6/N9 (23.10.2026, zlecenie 01N9CoiA): natal — zły argument to rc=2 z powodem, nie cicha domyślna ──
// Tor (−) mierzy WEJŚCIE, na którym dawne ciało zwracało liczbę bez sygnału: nieznany kod układu domów dawał Placidus (nagłówek
// drukował „Placidus"), a minuta „abc" przechodziła przez `mi||0` jako 0. Fikstura odróżnialna: ten sam adres z poprawnym `--hsys=W`.
test('natal: nieznany/pusty --hsys i nienumeryczna data kończą rc=2 z powodem (nie cichy Placidus, nie minuta 0)', () => {
  const nat = (...a) => cpS.spawnSync('node', ['narzedzia/silniki/kronos_natal.js', '1985', '6', '15', '14', '30', '50', '20', ...a], { cwd: __dirname, encoding: 'utf8', env: { ...process.env, KRONOS_TZ: '' } });
  const dobry = nat('--hsys=W');
  assert.strictEqual(dobry.status, 0, dobry.stderr);
  assert.match(dobry.stdout, /domy: WholeSign/);
  for (const zly of ['--hsys=Z', '--hsys', '--hsys=', '--hsys=p', '--hsys=constructor']) {
    const r = nat(zly);
    assert.strictEqual(r.status, 2, zly + ' → rc ' + r.status);
    assert.match(r.stderr, /nieznany układ domów/, zly);
    assert.match(r.stderr, /P \(Placidus\).*W \(WholeSign\)/, zly + ': lista dozwolonych');
    assert.doesNotMatch(r.stdout, /KRONOS·NATAL/, zly + ': nie drukuje odczytu na zgadniętym układzie');
  }
  const zlaData = cpS.spawnSync('node', ['narzedzia/silniki/kronos_natal.js', '1985', '6', 'xx', '14', 'abc', '50', '20'], { cwd: __dirname, encoding: 'utf8', env: { ...process.env, KRONOS_TZ: '' } });
  assert.strictEqual(zlaData.status, 2);
  assert.match(zlaData.stderr, /dzień, minuta/);
  assert.doesNotMatch(zlaData.stdout, /KRONOS·NATAL/);
});

// ── K6/N9 (23.10.2026): kronos_retro — argument nie-liczba to rc=2, nie raport „od NaN.NaN … przez NaN dni” ──
// Dawne ciało drukowało raport na NaN i kończyło rc=0 z „Brak okresów wstecznych" — pusty wynik z zepsutego wejścia udawał odpowiedź.
// Fikstura odróżnialna: ten sam adres z poprawnymi liczbami (30 dni) → rc 0 i prawdziwy nagłówek.
test('retro: data/dni nie-liczba kończą rc=2 z powodem (nie raport na NaN)', () => {
  const retro = (...a) => cpS.spawnSync('node', ['narzedzia/silniki/kronos_retro.js', ...a], { cwd: __dirname, encoding: 'utf8', env: { ...process.env, KRONOS_TZ: 'Europe/Warsaw' } });
  const dobry = retro('2026', '10', '23', '30');
  assert.strictEqual(dobry.status, 0, dobry.stderr);
  assert.match(dobry.stdout, /przez 30 dni/);
  assert.doesNotMatch(dobry.stdout, /NaN/);
  for (const zle of [['abc', '10', '23'], ['2026', '10', '23', 'xyz'], ['2026', '10', '23', '0'], ['--teraz', 'abc']]) {
    const r = retro(...zle);
    assert.strictEqual(r.status, 2, zle.join(' ') + ' → rc ' + r.status);
    assert.match(r.stderr, /kronos_retro\.js: /, zle.join(' '));
    assert.doesNotMatch(r.stdout, /NaN|RUCHY WSTECZNE/, zle.join(' ') + ': nie drukuje raportu');
  }
});

// ── K6/N9 (23.10.2026): scan_outer — okno otwarte na końcu skanu nie znika; argument nie-liczba to rc=2 ──
// Dawne ciało: pętla kończyła się z inWin=true bez wpisu (aspekt, który trwa w chwili końca skanu, znikał z wyniku), a „abc 10 23"
// drukowało „od 23.10.NaN" i „Brak ścisłych aspektów w tym oknie" (pusty wynik z zepsutego wejścia). Świadek deterministyczny:
// pierwsze okno Plutona 2026 z pełnego skanu, potem skan kończony w jego ŚRODKU — musi wrócić dokładnie to okno, otwarte.
test('scan_outer: okno otwarte na końcu zakresu wraca (end=null, otwarte), okno zamknięte ma koniec', () => {
  const so = require('./narzedzia/silniki/scan_outer.js');
  const t0 = TZ.localToUTC(2026, 1, 1, 0);
  const pelne = so.scan(2026, 1, 1, 60, ['Pluto']);
  assert.ok(pelne.length >= 2, 'świadek: 60 dni daje co najmniej 2 okna Plutona (było ' + pelne.length + ')');
  const w0 = pelne.reduce((a, b) => (b.start < a.start ? b : a));
  assert.ok(w0.end > w0.start);
  const dniDoSrodka = ((w0.start + w0.end) / 2 - t0) / 86400000;
  const ucięte = so.scan(2026, 1, 1, dniDoSrodka, ['Pluto']);
  assert.strictEqual(ucięte.length, 1, 'skan ucięty w środku okna: wraca to okno, nie pustka');
  assert.strictEqual(ucięte[0].end, null);
  assert.strictEqual(ucięte[0].otwarte, true);
  assert.strictEqual(ucięte[0].start, w0.start);
  const zZapasem = so.scan(2026, 1, 1, (w0.end + 6 * 3600000 - t0) / 86400000, ['Pluto']);
  const z0 = zZapasem.find(w => w.start === w0.start);
  assert.ok(z0 && typeof z0.end === 'number' && !z0.otwarte, 'okno zamknięte w zakresie: koniec liczbą, bez znacznika otwarcia');
});

// ── zlecenie 3 · 01N9CoiA, cz. 5: lewa krawędź. Okno, które trwa już w pierwszej próbce zakresu, ma start = początek zakresu, a nie prawdziwy
// początek — musi to mówić (otwarteLewo). Świadek z efemerydy: dzień, którego lokalna północ leży WEWNĄTRZ okna z pełnego skanu 120 dni.
test('scan_outer: okno trwające w pierwszej próbce zakresu ma otwarteLewo; okno zaczynające się później — nie', () => {
  const so = require('./narzedzia/silniki/scan_outer.js');
  const pl = ['Uranus', 'Neptune', 'Pluto'];
  const pelne = so.scan(2026, 1, 1, 120, pl);
  assert.ok(pelne.length >= 10, 'świadek: 120 dni × 3 planety daje wiele okien (było ' + pelne.length + ')');
  assert.ok(pelne.every(w => w.otwarteLewo === false), '(+) pełny skan od 1.01 nie trafia w trwające okno: żadne okno nie jest lewo-otwarte');
  let d = 2, T = null, w0 = null;
  for (; d <= 100 && !w0; d++) { T = TZ.localToUTC(2026, 1, d, 0); w0 = pelne.find(w => w.start <= T && T < w.end); }
  assert.ok(w0, 'świadek: istnieje północ lokalna wewnątrz okna');
  d--;
  const lewe = so.scan(2026, 1, d, 5, [w0.planet]);
  assert.ok(lewe.length >= 1 && lewe[0].start === T, 'okno trwające w t0 zaczyna się w t0 (pierwsza próbka), nie w prawdziwym początku');
  assert.strictEqual(lewe[0].otwarteLewo, true);
  assert.ok(w0.start < T, 'świadek: prawdziwy początek leży PRZED zakresem');
  assert.ok(lewe.slice(1).every(w => w.otwarteLewo === false), 'okna zaczynające się później nie są lewo-otwarte');
});

test('scan_outer CLI: data/dni nie-liczba kończą rc=2 z powodem (nie „Brak ścisłych aspektów")', () => {
  const sc = (...a) => cpS.spawnSync('node', ['narzedzia/silniki/scan_outer.js', ...a], { cwd: __dirname, encoding: 'utf8', env: { ...process.env, KRONOS_TZ: 'Europe/Warsaw' } });
  const dobry = sc('2026', '10', '23', '5');
  assert.strictEqual(dobry.status, 0, dobry.stderr);
  assert.match(dobry.stdout, /przez 5 dni/);
  for (const zle of [['abc', '10', '23'], ['2026', '10'], ['2026', '10', '23', 'xyz'], ['2026', '10', '23', '0']]) {
    const r = sc(...zle);
    assert.strictEqual(r.status, 2, zle.join(' ') + ' → rc ' + r.status);
    assert.match(r.stderr, /scan_outer\.js: /, zle.join(' '));
    assert.doesNotMatch(r.stdout, /Brak ścisłych|NaN/, zle.join(' '));
  }
});

// BUNDEL = ŹRÓDŁO (26.10.2026, odlew 1.8.3, straż dojrzałości: bundel bez świadka): `kronos_lens.bundle.js` jedzie do gości
// bez npm, budowany ręcznie `npm run bundle`. Zmiana źródła bez przebudowy = goście liczą inne niebo niż my. Trzy ustalone chwile,
// wyjście bajt w bajt. Zmierzone przed dopisaniem: 0 różnych linii na 3 chwilach (43/45/42 linie).
test('bundel nieba = źródło: kronos_lens.bundle.js drukuje to samo co kronos_lens.js (3 ustalone chwile)', () => {
  const uruchom = (plik, a) => cpS.spawnSync('node', [plik, ...a], { cwd: __dirname, encoding: 'utf8', env: { ...process.env, KRONOS_TZ: 'Europe/Warsaw' } });
  for (const a of [['2026', '3', '20', '12'], ['2026', '10', '26', '5'], ['2025', '12', '21', '18']]) {
    const zr = uruchom('narzedzia/silniki/kronos_lens.js', a), bu = uruchom('narzedzia/silniki/kronos_lens.bundle.js', a);
    assert.strictEqual(zr.status, 0, zr.stderr); assert.strictEqual(bu.status, 0, bu.stderr);
    assert.ok(zr.stdout.length > 500, 'świadek: źródło drukuje briefing (' + zr.stdout.length + ' B)');
    assert.strictEqual(bu.stdout, zr.stdout, a.join(' ') + ': bundel rozjechał się ze źródłem — `npm run bundle`');
  }
});
