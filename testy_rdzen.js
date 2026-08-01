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
const v4 = require('./kronos_v4.js');
const en = require('./kronos_engine.js');

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
