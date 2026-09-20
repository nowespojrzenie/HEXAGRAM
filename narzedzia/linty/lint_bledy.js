#!/usr/bin/env node
// ============================================================
// LINT KSIĘGI BŁĘDÓW — mechanizacja prawa #22 (28.07.2026, polecenie twórcy)
// PRAWO #22: „numeracja księgi = jeden kanon [#N]; indeks-słownik jako wejście".
// Prawo bez mechanizmu = życzenie (inwariant 5). To jest jego mechanizm.
//
// Sprawdza pięć niezależności:
//   1. każdy wiersz INDEKSU ma wpis w korpusie (poza jawnie pustymi)
//   2. każdy wpis w korpusie ma wiersz w INDEKSIE
//   3. jeden format nagłówka: `## #N` — żadnych gołych glifów na poziomie 2
//   4. ciągłość numeracji 1..max, bez dziur poza jawnie zadeklarowanymi
//   5. GLIFY: glif z INDEKSU zgadza się z glifem w nagłówku korpusu (pozycja kanoniczna:
//      pierwszy nawias zaraz po numerze, bez spacji — `## #14 (⓲) TYTUŁ`)
//   6. PARYTET Z KOLEJKĄ M (14.08.2026): każdy numer INDEKSU ma wiersz w `kanon/ksiegi/KOLEJKA_M.md`
//      i odwrotnie. Kolumna „Nośnik/kandydat M" wyprowadziła się z indeksu 14.08; prawo
//      „nowy wpis dopisuje wiersz w tej samej turze" stało WYŁĄCZNIE w głowicy kolejki,
//      czyli obowiązywało w dokumentacji (#38). To jest jego mechanizm. Rozdzielenie
//      dwóch plików bez straży parytetu = pewna rozjazd w pierwszej turze roztargnienia.
//
// Użycie:  node lint_bledy.js         (rc=0 czysto, rc=1 usterka)
//          node lint_bledy.js --test  (tor +/− : straż musi umieć NIE przejść)
//
// TOR TESTOWY dopisany 31.07.2026 (prawo #38: reguła bez własnego toru obowiązuje
// tylko w dokumentacji). Analiza wyjęta do funkcji `analiza(tekst)`, żeby dało się
// ją karmić tekstem syntetycznym, nie tylko plikiem z dysku.
// ============================================================
const fs = require('fs');
const PLIK = 'kanon/ksiegi/BLEDY.md';
const PUSTE = [7];   // #7 — jawnie pusty wpis, żyje tylko w odwołaniu straz_czystosci

// ── ANALIZA (czysta funkcja tekstu — to samo, co przedtem, tylko sparametryzowane) ──
function analiza(t, puste = PUSTE, kolejka = null) {
  const bledy = [], ostrz = [];

  // indeks: wiersze tabeli postaci "| N | glif | prawo | ... |"
  const indeks = [...t.matchAll(/^\|\s*(\d+)\s*\|/gm)].map(m => Number(m[1]));
  // glif z indeksu (kolumna 2) i z nagłówka korpusu (pierwszy nawias po numerze)
  const glifIdx = {};
  for (const m of t.matchAll(/^\|\s*(\d+)\s*\|\s*([^|]*?)\s*\|/gm)) {
    const g = m[2].trim();
    glifIdx[Number(m[1])] = (g === '—' || g === '-') ? '' : g;
  }
  const glifKor = {};
  for (const m of t.matchAll(/^## #(\d+)(?:\s*\(([^)\s]+)\))?/gm))
    glifKor[Number(m[1])] = (m[2] || '').trim();
  // korpus: nagłówki poziomu 2 w kanonie
  const korpus = [...t.matchAll(/^## #(\d+)\b/gm)].map(m => Number(m[1]));
  // nagłówki poziomu 2 zaczynające się od glifu (stary format = rozjazd)
  const gole = [...t.matchAll(/^## ([❶-❿⓫-⓭⑮-⑳㉑-㉕])/gm)].map(m => m[1]);

  if (indeks.length === 0) {
    bledy.push('brak INDEKSU — ani jeden wiersz tabeli `| N |` nie znaleziony');
    return { bledy, ostrz, indeks, korpus, max: 0 };
  }

  const setI = new Set(indeks), setK = new Set(korpus);

  for (const n of indeks)
    if (!setK.has(n) && !puste.includes(n))
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

  for (const n of puste)
    if (setI.has(n) && !setK.has(n))
      ostrz.push('#' + n + ': jawnie pusty (zadeklarowany wyjątek) — OK');

  // 6) parytet z KOLEJKĄ M — numer bez nośnika jest prawem bez adresu egzekucji
  if (kolejka !== null) {
    // ── ZALĄŻEK TO BRAK DANYCH, NIE NARUSZENIE (13.09.2026) ──────────────────────────
    // ZMIERZONE na odlewie: `KOLEJKA_M.md` stoi na liście ZALAZKOWANE (prywatna tkanka nie
    // podróżuje), a `BLEDY.md` jedzie PEŁNY — 85 numerów w indeksie, 0 wierszy w kolejce.
    // Prawo #22 wiąże tę parę parytetem, więc zalążkowanie JEDNEJ strony czyniło lint
    // czerwonym u odbiorcy OD PIERWSZEJ SEKUNDY — nie jako stan do wypełnienia, tylko jako
    // rozjazd wpisany w konstrukcję odlewu. Skutek uboczny: czterech świadków rejestru
    // mutacji było MARTWYCH na `main`, bo ich miernik oblewał, zanim cokolwiek wstrzyknięto.
    // Zalążek jest JAWNĄ deklaracją „tu nie ma jeszcze danych" — mierzenie go jak wady myli
    // BRAK POMIARU z WYNIKIEM (#18, #82). Lint stosuje ten wzorzec już dwa razy niżej
    // (brak pliku → rc=2, „nie melduję sukcesu"); tu brakowało trzeciego przypadku.
    // Reguły 1–5 mierzą samą księgę i działają dalej — brak jednej składowej nie unieważnia
    // pozostałych, ale MUSI być nazwany, nigdy przemilczany.
    // Znacznik szukany po wycięciu fragmentów w backtickach — dokładnie jak w naprawie
    // `straz_zalazkow.sh` z 28.08: kod inline w markdown jest mową O znaczniku, nie użyciem.
    // LINIOWO, nie na całym tekście: kanoniczna metoda to `sed 's/`[^`]*`//g'`, a sed pracuje
    // wiersz po wierszu. Regex wieloliniowy dopasowuje `[^`]*` PRZEZ znaki nowej linii, więc
    // zjadał cały blok ``` razem ze znacznikiem w środku — a zalążki generowane przez
    // `zalazkuj.sh` niosą deklarację właśnie w takim bloku. Zmierzone: zalążkowa KOLEJKA_M
    // z `main` nie była rozpoznawana, dopóki wycinanie nie zeszło do poziomu wiersza.
    const kolBezCytatow = kolejka.split('\n').map(l => l.replace(/`[^`]*`/g, '')).join('\n');
    if (/⟠\s*ZALĄŻEK/.test(kolBezCytatow)) {
      ostrz.push('parytet z KOLEJKĄ M: NIEMIERZALNY — kolejka jest zalążkiem (⟠), ' +
                 'a nie pustą tabelą. Reguły 1–5 zmierzone normalnie; parytet ożyje, ' +
                 'gdy kolejka dostanie pierwsze wiersze.');
    } else {
    const kolNum = [...kolejka.matchAll(/^\|\s*(\d+)\s*\|/gm)].map(m => Number(m[1]));
    if (kolNum.length === 0) {
      bledy.push('KOLEJKA M: ani jeden wiersz `| N |` — kolejka pusta albo o zmienionym formacie');
    } else {
      const setKol = new Set(kolNum);
      for (const n of indeks)
        if (!setKol.has(n))
          bledy.push('#' + n + ': jest w INDEKSIE, brak wiersza w KOLEJCE M');
      for (const n of setKol)
        if (!setI.has(n))
          bledy.push('#' + n + ': jest w KOLEJCE M, brak w INDEKSIE księgi');
      const dupK = kolNum.filter((v, i) => kolNum.indexOf(v) !== i);
      for (const n of new Set(dupK))
        bledy.push('#' + n + ': zdublowany wiersz w KOLEJCE M');
    }
    }
  }

  return { bledy, ostrz, indeks, korpus, max };
}

// ── RAPORT (werdykt wyprowadzony z wyniku, nie postawiony obok — #34) ──
function raport(w, naglowek = '╔═══ LINT KSIĘGI BŁĘDÓW (prawo #22) ═══╗') {
  console.log(naglowek);
  console.log('  indeks: ' + w.indeks.length + ' wierszy · korpus: ' + w.korpus.length +
              ' wpisów · zakres 1–' + w.max);
  for (const o of w.ostrz) console.log('  ⓘ ' + o);
  if (w.bledy.length === 0) {
    console.log('  ✓ KSIĘGA SPÓJNA — jeden kanon [#N], indeks pokrywa korpus.');
    return 0;
  }
  for (const b of w.bledy) console.log('  ✗ ' + b);
  console.log('  ROZJAZD: ' + w.bledy.length + ' — prawo #22 naruszone.');
  return 1;
}

// ── TOR TESTOWY (#38) ──
if (process.argv.includes('--test')) {
  const ZDROWY = [
    '| # | glif | prawo |',
    '|---|---|---|',
    '| 1 | ❶ | pierwsze |',
    '| 2 | ❷ | drugie |',
    '',
    '## #1 (❶) PIERWSZE',
    'treść',
    '## #2 (❷) DRUGIE',
    'treść',
  ].join('\n');

  const ZDROWA_KOLEJKA = [
    '| # | Nośnik / kandydat M |',
    '|---|---|',
    '| 1 | nosnik pierwszy |',
    '| 2 | nosnik drugi |',
  ].join('\n');

  // każdy zepsuty przypadek celuje w INNĄ z pięciu reguł
  const CHORE = {
    'brak wpisu w korpusie (reguła 1)':
      ZDROWY.replace('## #2 (❷) DRUGIE\ntreść', ''),
    'wpis bez wiersza indeksu (reguła 2)':
      ZDROWY + '\n## #9 (❾) SIEROTA\ntreść',
    'goły glif na poziomie 2 (reguła 3)':
      ZDROWY + '\n## ❿ STARY FORMAT\ntreść',
    'dziura w numeracji (reguła 4)':
      ZDROWY.replace('| 2 | ❷ | drugie |', '| 3 | ❸ | trzecie |')
            .replace('## #2 (❷) DRUGIE', '## #3 (❸) TRZECIE'),
    'rozjazd glifu indeks↔korpus (reguła 5)':
      ZDROWY.replace('## #2 (❷) DRUGIE', '## #2 (❺) DRUGIE'),
    'zdublowany wiersz indeksu':
      ZDROWY.replace('| 2 | ❷ | drugie |', '| 2 | ❷ | drugie |\n| 2 | ❷ | drugie |'),
  };

  console.log('╔═══ LINT KSIĘGI BŁĘDÓW — AUTOTEST (#38) ═══╗');
  const rcPlus = raport(analiza(ZDROWY, PUSTE, ZDROWA_KOLEJKA),
                        '── TEST + (księga zdrowa, MUSI przejść) ──');
  let wszystkieOblaly = true;
  for (const [nazwa, tekst] of Object.entries(CHORE)) {
    const rc = raport(analiza(tekst, PUSTE, ZDROWA_KOLEJKA), '── TEST − ' + nazwa + ' (MUSI oblać) ──');
    if (rc !== 1) wszystkieOblaly = false;
  }

  // ── TORY REGUŁY 6 (parytet z KOLEJKĄ M) — psuta jest KOLEJKA, nie księga ──
  const CHORE_KOLEJKI = {
    'numer w indeksie bez wiersza w KOLEJCE M (reguła 6)':
      ZDROWA_KOLEJKA.replace('| 2 | nosnik drugi |', ''),
    'sierota w KOLEJCE M bez wpisu w indeksie (reguła 6)':
      ZDROWA_KOLEJKA + '\n| 9 | nosnik widmo |',
    'zdublowany wiersz w KOLEJCE M (reguła 6)':
      ZDROWA_KOLEJKA + '\n| 2 | nosnik drugi |',
  };
  for (const [nazwa, kol] of Object.entries(CHORE_KOLEJKI)) {
    const rc = raport(analiza(ZDROWY, PUSTE, kol), '── TEST − ' + nazwa + ' (MUSI oblać) ──');
    if (rc !== 1) wszystkieOblaly = false;
  }

  // ── PARA TORÓW: ZALĄŻEK ≠ PUSTA TABELA (13.09.2026) ──────────────────────────────
  // Dwustronnie, bo sama cisza dowodziłaby tylko, że lint milczy (#75): kolejka-zalążek
  // MUSI przejść z ⓘ (brak pomiaru nazwany), a kolejka pusta BEZ znacznika ⟠ MUSI oblać.
  // Trzeci tor pilnuje naprawy z 28.08: znacznik W BACKTICKACH to mowa O zalążku, nie
  // deklaracja — taka kolejka jest zwykłą pustą tabelą i ma oblać.
  const KOL_ZALAZEK = '# KOLEJKA M\n<!-- ⟠ ZALĄŻEK -->\n⟠ ZALĄŻEK — tkanka nowego twórcy\n\n| N | nosnik |\n|---|---|\n';
  const KOL_PUSTA   = '# KOLEJKA M\n\n| N | nosnik |\n|---|---|\n';
  const KOL_CYTAT   = '# KOLEJKA M\n\nplik z `⟠ ZALĄŻEK` w cudzysłowie to nie zalążek\n\n| N | nosnik |\n|---|---|\n';

  const wZal = analiza(ZDROWY, PUSTE, KOL_ZALAZEK);
  const rcZal = raport(wZal, '── TEST + kolejka ZALĄŻEK (MUSI przejść, parytet niemierzalny) ──');
  const nazwalBrak = wZal.ostrz.some(o => o.includes('NIEMIERZALNY'));
  if (rcZal !== 0 || !nazwalBrak) wszystkieOblaly = false;

  const rcPus = raport(analiza(ZDROWY, PUSTE, KOL_PUSTA),
                       '── TEST − kolejka PUSTA bez znacznika (MUSI oblać) ──');
  if (rcPus !== 1) wszystkieOblaly = false;

  const rcCyt = raport(analiza(ZDROWY, PUSTE, KOL_CYTAT),
                       '── TEST − znacznik ⟠ w BACKTICKACH to nie zalążek (MUSI oblać) ──');
  if (rcCyt !== 1) wszystkieOblaly = false;

  const ILE_CHORYCH = Object.keys(CHORE).length + Object.keys(CHORE_KOLEJKI).length + 2;

  console.log();
  if (rcPlus === 0 && wszystkieOblaly) {
    console.log('✓ STRAŻ ŻYWA: przepuściła zdrową, oblała wszystkie ' +
                ILE_CHORYCH + ' chore — każda z sześciu reguł ma tor.');
    process.exit(0);
  }
  console.log('✗ STRAŻ MARTWA: rcPlus=' + rcPlus + ' · wszystkie chore oblały: ' + wszystkieOblaly);
  process.exit(1);
}

// ── BIEG WŁAŚCIWY ──
if (!fs.existsSync(PLIK)) {
  console.log('  ⓘ brak ' + PLIK + ' — lint nie ma czego mierzyć (rc=2, nie melduję sukcesu)');
  process.exit(2);
}
const KOLEJKA = 'kanon/ksiegi/KOLEJKA_M.md';
if (!fs.existsSync(KOLEJKA)) {
  console.log('  ⓘ brak ' + KOLEJKA + ' — parytetu nie da się zmierzyć (rc=2, nie melduję sukcesu)');
  process.exit(2);
}
process.exit(raport(analiza(fs.readFileSync(PLIK, 'utf8'), PUSTE,
                            fs.readFileSync(KOLEJKA, 'utf8'))));
