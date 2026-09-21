// ═══ domy.js — JEDNO ŹRÓDŁO przypisania długości do domu ═══
//
// RODOWÓD (13.08.2026, faza A planu odlewu v1.5.0): `domDla` żyła w dwóch kopiach
// (`kronos_natal.js` z jawnym argumentem, `kronos_pelnia.js` z closure na `cusps`).
// Logika identyczna co do znaku — a to najgorszy rodzaj duplikatu: taki, który
// NIE MA jak się rozjechać i przez to nigdy nie zgłosi, że jest.
// Prawo z tej samej doby: *duplikat zdradza się tylko wtedy, gdy kopie różnią się
// inaczej niż w błędzie.* Te dwie zgadzały się idealnie — także w braku pokrycia.
//
// KLASA RYZYKA: ta sama co `getC` — przedział przez 0°/360°. Dom 12 zamyka się
// na cuspidzie domu 1, więc ostatni przedział prawie zawsze przechodzi przez zero.
// Do 13.08.2026 nie istniał ANI JEDEN test tej gałęzi.

'use strict';

const norm = a => ((a % 360) + 360) % 360;

/**
 * Dom (1..12) dla długości ekliptycznej `lon` przy podanych cuspidach.
 * @param {number}   lon    długość w stopniach (dowolna, normalizowana)
 * @param {number[]} cusps  tablica [0, c1, c2, ... c12] — indeks 0 ignorowany
 * @returns {number} numer domu 1..12, albo 0 gdy cuspidy nie pokrywają koła
 *
 * SEMANTYKA PÓŁOTWARTA [a, b): cuspida należy do domu, który OTWIERA.
 * Zwrot 0 nie jest „domem zerowym" — to sygnał, że dane wejściowe są zepsute
 * (dziura w cuspidach). Cichy fallback maskujący błąd był przyczyną blizny
 * w `getC` — tutaj brak trafienia zostaje brakiem trafienia.
 */
function domDla(lon, cusps) {
  const L = norm(lon);
  for (let i = 1; i <= 12; i++) {
    const a = norm(cusps[i]), b = norm(cusps[i === 12 ? 1 : i + 1]);
    if (a <= b ? (L >= a && L < b) : (L >= a || L < b)) return i;
  }
  return 0;
}

/** Wariant związany z jedną tablicą cuspid — dla kodu, który miał closure. */
function domDlaZ(cusps) { return L => domDla(L, cusps); }

module.exports = { domDla, domDlaZ, norm };
