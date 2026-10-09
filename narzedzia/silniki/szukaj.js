#!/usr/bin/env node
/* ── KRONOS · SZUKAJ — dwa algorytmy szukania chwili, jedno miejsce (03.10.2026) ──────────
 * RODOWÓD: pomiar dubletów 03.10 (MOSTY #49). Słowo twórcy 13:12: „Zgoda. Opus a."
 * Zmierzone PRZED: w silnikach rodziny astronomy-engine żyło SZEŚĆ kopii DWÓCH algorytmów,
 * pod czterema nazwami, z których jedna myliła (`bisekcja` w scan_aspekty była trójpodziałem):
 *   ZERO (połowienie na zmianie znaku):  kronos_eter.refineZero (44 it.) · kronos_impuls.bisekcja (48 it.)
 *                                        · kronos_retro.bisekcja (do 1 min)
 *   EKSTREMUM (trójpodział):             kronos_eter.refineExt (60 it.) · scan_aspekty.bisekcja (40 it.)
 *                                        · scan_outer — pętla wpisana w skan (30 it.)
 * Żadna kopia nie miała własnego toru. Ten plik ma.
 *
 * CZYM JEST: suchy przyrząd. Nie wie nic o niebie — dostaje funkcję czasu f(ms) i przedział.
 * CZEGO NIE ROBI: nie wybiera liczby iteracji ani tolerancji za wołającego. Każdy silnik
 * podaje TĘ SAMĄ wartość, którą miał przed scaleniem — dlatego wyniki są identyczne co do bitu
 * (pomiar 03.10: 20 biegów CLI + surowe ms, przed = po). Zmiana dokładności któregoś silnika
 * to osobna decyzja z osobnym pomiarem, nie skutek uboczny sprzątania.
 *
 * ŚWIADOMIE POZA: kronos_engine.js (bezpiecznik niezależności — liczy sam, Meeus; MOSTY #51)
 * i scan_dwarfs.js (połowienie po KATEGORII znaku na obiektach Date, zwraca brzeg `hi`, nie środek).
 *
 * PRAWA (każde ma tor w --test):
 *  S1 · zero(): znajduje miejsce zmiany znaku; tryb `iter` i tryb `tol` dają to samo miejsce
 *  S2 · ekstremum(): znajduje minimum i maksimum funkcji jednomodalnej
 *  S3 · arytmetyka kroku jest DOKŁADNIE ta sprzed scalenia (wzorzec wpisany w tor, bit w bit)
 *  S4 · brak `iter` i `tol` naraz = błąd, nie cicha wartość domyślna — i test UMIE nie przejść
 *
 * UŻYCIE:
 *   const {zero, ekstremum} = require('./szukaj.js');
 *   zero(f, a, b, {iter: 44})        → ms   (f(ms) zmienia znak w [a,b])
 *   zero(f, a, b, {tol: 60000})      → ms   (aż przedział ≤ tol)
 *   ekstremum(f, a, b, {iter: 60, min: true|false}) → ms
 *   node narzedzia/silniki/szukaj.js --test
 * ─────────────────────────────────────────────────────────────────────────────────────── */
'use strict';

// ZERO: połowienie. Zakłada, że f(a) i f(b) mają różne znaki; trzyma znak lewego brzegu.
function zero(f, a, b, opcje) {
  const iter = opcje && opcje.iter, tol = opcje && opcje.tol;
  if (iter == null && tol == null) throw new Error('szukaj.zero: podaj iter albo tol (S4)');
  let fa = f(a);
  const krok = () => { const m = (a + b) / 2, fm = f(m); if ((fa < 0) === (fm < 0)) { a = m; fa = fm; } else b = m; };
  if (tol != null) { while (b - a > tol) krok(); }
  else { for (let i = 0; i < iter; i++) krok(); }
  return (a + b) / 2;
}

// EKSTREMUM: trójpodział. Zakłada jedno ekstremum w [a,b]. min=true szuka minimum.
function ekstremum(f, a, b, opcje) {
  const iter = opcje && opcje.iter;
  if (iter == null) throw new Error('szukaj.ekstremum: podaj iter (S4)');
  const min = !(opcje && opcje.min === false);
  for (let i = 0; i < iter; i++) {
    const m1 = a + (b - a) / 3, m2 = b - (b - a) / 3;
    const f1 = f(m1), f2 = f(m2);
    if (min ? f1 < f2 : f1 > f2) b = m2; else a = m1;
  }
  return (a + b) / 2;
}

module.exports = { zero, ekstremum };

/* ── TORY ── */
if (require.main === module && process.argv.includes('--test')) {
  let ok = 0, zle = 0;
  const t = (nazwa, warunek, opis) => { if (warunek) { ok++; console.log(`  ✓ ${nazwa}${opis ? ' — ' + opis : ''}`); } else { zle++; console.log(`  ✗ ${nazwa}${opis ? ' — ' + opis : ''}`); } };

  console.log('── TOR S1: zero() znajduje zmianę znaku; iter i tol zgodne ──');
  const lin = x => x - 1234.5;
  const zi = zero(lin, 0, 10000, { iter: 48 }), zt = zero(lin, 0, 10000, { tol: 1e-6 });
  t('S1a', Math.abs(zi - 1234.5) < 1e-6, `iter=48 → ${zi}`);
  t('S1b', Math.abs(zt - 1234.5) < 1e-5, `tol=1e-6 → ${zt}`);
  t('S1c', Math.abs(zero(x => 1234.5 - x, 0, 10000, { iter: 48 }) - 1234.5) < 1e-6, 'funkcja malejąca też');

  console.log('── TOR S2: ekstremum() — minimum i maksimum ──');
  const par = x => (x - 777) * (x - 777);
  const emin = ekstremum(par, 0, 5000, { iter: 60 }), emax = ekstremum(x => -par(x), 0, 5000, { iter: 60, min: false });
  t('S2a', Math.abs(emin - 777) < 1e-3, `minimum → ${emin.toFixed(6)}`);
  t('S2b', Math.abs(emax - 777) < 1e-3, `maksimum → ${emax.toFixed(6)}`);

  console.log('── TOR S3: arytmetyka kroku = wzorce sprzed scalenia (bit w bit) ──');
  const f3 = x => Math.sin(x / 1e7) - 0.3;                      // funkcja nieliniowa, przedział jak w silnikach (ms)
  const A0 = 1.7e12, B0 = A0 + 3600e3 * 24 * 40;
  const wzorZeroIter = (f, t0, t1, iter) => { let a = t0, b = t1, fa = f(a); for (let i = 0; i < iter; i++) { const m = (a + b) / 2, fm = f(m); if ((fa < 0) === (fm < 0)) { a = m; fa = fm; } else b = m; } return (a + b) / 2; };   // kronos_eter.refineZero
  const wzorZeroImp = (f, t0, t1) => { let a = t0, b = t1, fa = f(a); for (let i = 0; i < 48; i++) { const m = (a + b) / 2, fm = f(m); if ((fa < 0) !== (fm < 0)) b = m; else { a = m; fa = fm; } } return (a + b) / 2; };            // kronos_impuls.bisekcja
  const wzorZeroTol = (f, lo, hi, MIN) => { let flo = f(lo); while (hi - lo > MIN) { const m = (lo + hi) / 2, fm = f(m); if ((fm < 0) === (flo < 0)) { lo = m; flo = fm; } else hi = m; } return (lo + hi) / 2; };                    // kronos_retro.bisekcja
  const wzorExt = (f, t0, t1, isMin, iter) => { let a = t0, b = t1; for (let i = 0; i < iter; i++) { const m1 = a + (b - a) / 3, m2 = b - (b - a) / 3; const f1 = f(m1), f2 = f(m2); if (isMin ? f1 < f2 : f1 > f2) b = m2; else a = m1; } return (a + b) / 2; };   // kronos_eter.refineExt
  const wzorAbs = (f, t0, t1, iter) => { let a = t0, b = t1; for (let i = 0; i < iter; i++) { const m1 = a + (b - a) / 3, m2 = b - (b - a) / 3; if (Math.abs(f(m1)) < Math.abs(f(m2))) b = m2; else a = m1; } return (a + b) / 2; };                             // scan_aspekty.bisekcja · scan_outer
  const g3 = x => Math.cos(x / 9e8) + 2;
  t('S3a', zero(f3, A0, B0, { iter: 44 }) === wzorZeroIter(f3, A0, B0, 44), 'eter (44 it.)');
  t('S3b', zero(f3, A0, B0, { iter: 48 }) === wzorZeroImp(f3, A0, B0), 'impuls (48 it.)');
  t('S3c', zero(f3, A0, B0, { tol: 60000 }) === wzorZeroTol(f3, A0, B0, 60000), 'retro (do 1 min)');
  t('S3d', ekstremum(g3, A0, B0, { iter: 60 }) === wzorExt(g3, A0, B0, true, 60) && ekstremum(g3, A0, B0, { iter: 60, min: false }) === wzorExt(g3, A0, B0, false, 60), 'eter ekstremum (60 it., min i max)');
  t('S3e', ekstremum(x => Math.abs(f3(x)), A0, B0, { iter: 40 }) === wzorAbs(f3, A0, B0, 40) && ekstremum(x => Math.abs(f3(x)), A0, B0, { iter: 30 }) === wzorAbs(f3, A0, B0, 30), 'aspekty (40 it.) i outer (30 it.) przez |f|');

  console.log('── TOR S4: brak parametru = błąd; i tor UMIE nie przejść ──');
  let rzucil = 0; try { zero(lin, 0, 1); } catch (e) { rzucil++; } try { ekstremum(par, 0, 1); } catch (e) { rzucil++; }
  t('S4a', rzucil === 2, 'zero() i ekstremum() bez iter/tol rzucają');
  const zepsuty = (f, a, b, it) => { let fa = f(a); for (let i = 0; i < it; i++) { const m = (a + b) / 2, fm = f(m); if ((fa < 0) === (fm < 0)) b = m; else { a = m; fa = fm; } } return (a + b) / 2; };   // odwrócona gałąź
  t('S4b', Math.abs(zepsuty(lin, 0, 10000, 48) - 1234.5) > 1, 'połowienie z odwróconą gałęzią NIE trafia — test odróżnia');

  console.log(zle === 0 ? `\n  ✓ STRAŻ ŻYWA: każde deklarowane prawo (S1–S4) ma własny tor i przechodzi. (${ok}/${ok})` : `\n  ✗ OBLANE: ${zle} z ${ok + zle}`);
  process.exit(zle === 0 ? 0 : 1);
}
