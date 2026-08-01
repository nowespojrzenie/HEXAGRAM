#!/usr/bin/env node
// ============================================================
// LINT KSIĘGI BŁĘDÓW — mechanizacja prawa #22 (28.07.2026, polecenie twórcy)
// PRAWO #22: „numeracja księgi = jeden kanon [#N]; indeks-słownik jako wejście".
// Prawo bez mechanizmu = życzenie (inwariant 5). To jest jego mechanizm.
//
// Sprawdza cztery niezależności:
//   1. każdy wiersz INDEKSU ma wpis w korpusie (poza jawnie pustymi)
//   2. każdy wpis w korpusie ma wiersz w INDEKSIE
//   3. jeden format nagłówka: `## #N` — żadnych gołych glifów na poziomie 2
//   4. ciągłość numeracji 1..max, bez dziur poza jawnie zadeklarowanymi
//   5. GLIFY: glif z INDEKSU zgadza się z glifem w nagłówku korpusu (pozycja kanoniczna:
//      pierwszy nawias zaraz po numerze, bez spacji — `## #14 (⓲) TYTUŁ`)
//
// Użycie:  node lint_bledy.js         (rc=0 czysto, rc=1 usterka)
// ============================================================
const fs = require('fs');
const PLIK = 'BLEDY.md';
const PUSTE = [7];   // #7 — jawnie pusty wpis, żyje tylko w odwołaniu straz_czystosci

const t = fs.readFileSync(PLIK, 'utf8');
let bledy = [], ostrz = [];

// --- indeks: wiersze tabeli postaci "| N | glif | prawo | ... |"
const indeks = [...t.matchAll(/^\|\s*(\d+)\s*\|/gm)].map(m => Number(m[1]));
// --- glif z indeksu (kolumna 2) i z nagłówka korpusu (pierwszy nawias po numerze)
const glifIdx = {};
for (const m of t.matchAll(/^\|\s*(\d+)\s*\|\s*([^|]*?)\s*\|/gm)) {
  const g = m[2].trim();
  glifIdx[Number(m[1])] = (g === '—' || g === '-') ? '' : g;
}
const glifKor = {};
for (const m of t.matchAll(/^## #(\d+)(?:\s*\(([^)\s]+)\))?/gm))
  glifKor[Number(m[1])] = (m[2] || '').trim();
// --- korpus: nagłówki poziomu 2 w kanonie
const korpus = [...t.matchAll(/^## #(\d+)\b/gm)].map(m => Number(m[1]));
// --- nagłówki poziomu 2 zaczynające się od glifu (stary format = rozjazd)
const gole = [...t.matchAll(/^## ([❶-❿⓫-⓭⑮-⑳㉑-㉕])/gm)].map(m => m[1]);

const setI = new Set(indeks), setK = new Set(korpus);

for (const n of indeks)
  if (!setK.has(n) && !PUSTE.includes(n))
    bledy.push('#' + n + ': jest w INDEKSIE, brak wpisu w korpusie');
for (const n of korpus)
  if (!setI.has(n))
    bledy.push('#' + n + ': jest wpis w korpusie, brak wiersza w INDEKSIE');
for (const g of gole)
  bledy.push('nagłówek w starym formacie glifowym (poziom 2): ## ' + g + ' — kanon to ## #N (' + g + ')');

const max = Math.max(...indeks);
for (let n = 1; n <= max; n++)
  if (!setI.has(n)) bledy.push('#' + n + ': dziura w numeracji INDEKSU');

// duplikaty
const dupI = indeks.filter((v, i) => indeks.indexOf(v) !== i);
const dupK = korpus.filter((v, i) => korpus.indexOf(v) !== i);
for (const n of new Set(dupI)) bledy.push('#' + n + ': zdublowany wiersz w INDEKSIE');
for (const n of new Set(dupK)) bledy.push('#' + n + ': zdublowany nagłówek w korpusie');

// 5) glify: indeks musi zgadzać się z nagłówkiem korpusu
for (const n of korpus) {
  if (!(n in glifIdx)) continue;
  if (glifIdx[n] !== glifKor[n])
    bledy.push('#' + n + ': rozjazd glifu — INDEKS „' + (glifIdx[n] || '—') +
               '" vs nagłówek „' + (glifKor[n] || '—') + '"');
}

for (const n of PUSTE)
  if (setI.has(n) && !setK.has(n))
    ostrz.push('#' + n + ': jawnie pusty (zadeklarowany wyjątek) — OK');

console.log('╔═══ LINT KSIĘGI BŁĘDÓW (prawo #22) ═══╗');
console.log('  indeks: ' + indeks.length + ' wierszy · korpus: ' + korpus.length + ' wpisów · zakres 1–' + max);
for (const o of ostrz) console.log('  ⓘ ' + o);
if (bledy.length === 0) {
  console.log('  ✓ KSIĘGA SPÓJNA — jeden kanon [#N], indeks pokrywa korpus.');
  process.exit(0);
} else {
  for (const b of bledy) console.log('  ✗ ' + b);
  console.log('  ROZJAZD: ' + bledy.length + ' — prawo #22 naruszone.');
  process.exit(1);
}
