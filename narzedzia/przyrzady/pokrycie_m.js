#!/usr/bin/env node
'use strict';
/**
 * POKRYCIE M (13.08.2026) — licznik pokrycia mechanicznego ksiegi bledow.
 *
 * PO CO: R0 rosnie glownie w warstwie R (rytual). Rytual u bytu bezstanowego
 * dziala tylko wtedy, gdy zostanie PRZECZYTANY — wiec kazde nowe prawo R
 * konkuruje o uwage z poprzednimi. Mechanizm (straz/lint) odpala sie sam i nie
 * zajmuje ani bajta R0. Piaty inwariant: prawo bez mechanizmu = zyczenie.
 * Objetosc R0 byla ZLA WIELKOSCIA STERUJACA — rosla takze wtedy, gdy system
 * stawal sie lepszy (blizna #49 podniosla R0 o 4783 B). Ten przyrzad mierzy
 * to, co ma rosnac: udzial praw, ktore dzialaja bez czytania.
 *
 * KOTWICA (blizna #49 — tor na ALARM to nie tor na MIARE): wiersze indeksu
 * lapane po WZORCU `^| N |`, nie po tytule sekcji. Klasyfikacja po ZNAKU ✓,
 * nie po dlugosci napisu. Suma klas MUSI rownac sie liczbie wierszy — inaczej
 * rc=1 (przyrzad, ktory gubi wiersz po cichu, jest ta sama choroba, ktora leczy).
 *
 * BRAMKA MIANOWNIKA (25.08.2026, ksztalt ratyfikowany 22.08 — DECYZJA 1 w TASKI).
 * Wpis bez mechanizmu wchodzi jako **NOSNA RAMA** — jawne „jeszcze nie", nie ciche „R".
 * Przyrzad raportuje odtad DWIE liczby: pokrycie M ORAZ dlugosc kolejki ram.
 * PO CO DWIE: jedna liczba da sie zoptymalizowac, dwie nie. Podniesienie procentu
 * przez przepisanie wpisu z „R" na „NOSNA RAMA" natychmiast wydluza druga liczbe.
 * ZAMEK ANTY-GOODHART (pulapka nazwana w decyzji): raportowane jest takze NIEPOKRYTE
 * = bez + rama + w drodze. Ta suma NIE ZMIENIA SIE przy przenoszeniu wpisu miedzy
 * kategoriami — zmienia ja wylacznie zbudowanie mechanizmu albo dopisanie prawa.
 * Straz ma widziec reklasyfikacje, nie premiowac jej.
 *
 * UZYCIE:  node pokrycie_m.js            (raport; rc 0 czysto / 1 usterka / 2 brak materii)
 *          node pokrycie_m.js --liczba   (jedna linia dla wstan.sh)
 *          node pokrycie_m.js --test     (tor +/− : przyrzad musi umiec NIE przejsc)
 */
const fs = require('fs');
const path = require('path');
const PLIK = path.join(__dirname, '..', '..', 'kanon/ksiegi/BLEDY.md');   // dach (29.08): korzeń repo
const PRAWA = path.join(__dirname, '..', '..', 'kanon/prawa/_GRANICA.md'); // drugi zbiór, ROZŁĄCZNY z BLEDY (03.09)
const PUSTE = [7]; // #7 jawnie pusty — wiersz w indeksie, brak naglowka w korpusie

const WIERSZ = /^\|\s*(\d+)\s*\|/;

function analiza(t) {
  const w = { wierszy: 0, zmech: 0, wDrodze: 0, bez: 0, postawa: 0, rama: 0, ramy: [], nieskl: [],
              pomiar: { wierszy: 0, zmech: 0 }, naglowki: 0, luki: [] };
  const numery = [];

  for (const linia of t.split('\n')) {
    if (/^##\s+#\d+/.test(linia)) { w.naglowki++; continue; }
    const m = linia.match(WIERSZ);
    if (!m) continue;
    const kol = linia.split('|');
    if (kol.length < 7) { w.nieskl.push(m[1]); continue; }
    const rodzina = (kol[4] || '').trim();
    const status = (kol[5] || '').replace(/\*/g, '').trim();

    w.wierszy++; numery.push(Number(m[1]));
    const maPomiar = /POMIAR/.test(rodzina);
    if (maPomiar) w.pomiar.wierszy++;

    if (status.includes('✓')) {                       // mechanizm dziala i ma dowod
      w.zmech++; if (maPomiar) w.pomiar.zmech++;
    } else if (/POSTAWA/.test(status)) {              // swiadomie niemechanizowalne (#25)
      w.postawa++;
    } else if (/NO[ŚS]NA\s+RAMA/i.test(status)) {     // jawne „jeszcze nie" (bramka mianownika)
      w.rama++; w.ramy.push(Number(m[1]));
    } else if (/\bM\b|M-|M$/.test(status)) {          // M zapowiedziane, bez ptaszka
      w.wDrodze++;
    } else if (/^(R|P|—|-)/.test(status) || /R\+rytua/.test(status)) {
      w.bez++;
    } else {
      w.nieskl.push(m[1]);
    }
  }

  // krzyzowy swiadek: kazdy wiersz indeksu ma naglowek w korpusie (poza PUSTE)
  const oczekiwane = w.wierszy - numery.filter(n => PUSTE.includes(n)).length;
  if (w.wierszy > 0 && w.naglowki !== oczekiwane) w.luki.push(oczekiwane + '≠' + w.naglowki);
  return w;
}

// ── PRAWA (03.09.2026, korekta twórcy do diagnozy (b) z ALARMY_odpowiedzi) ─────
// `pokrycie_m` liczy WIERSZE INDEKSU `BLEDY.md` — blizny. Prawa żyją w `_GRANICA.md`
// i nigdy w tym liczniku nie były: 02.09 weszło PRAWO KARTY ZDOLNOŚCI z mechanizmem,
// a „35 bez mechanizmu" nie drgnęło. Dwa ROZŁĄCZNE zbiory pod jedną nazwą — cięcie
// jest w nazwie i w osobnym wierszu, nie w formule (reklasyfikacja = obejście przez dane).
// MIARA, NIE WERDYKT: „z egzekutorem" znaczy „sekcja NAZYWA plik .sh/.js", nie „egzekutor
// działa" (to pyta straz_dojrzalosci). Prawo bez nazwanego pliku jest regułą bez adresu —
// Inwariat 5 w wersji słabej: nie wiadomo, kto ma je wyegzekwować.
function prawa(t) {
  const sek = t.split(/^## /m).slice(1);
  const zPrawem = sek.filter(x => /status PRAWO/.test(x.split('\n')[0]));
  const zEgz = zPrawem.filter(x => /`[A-Za-z0-9_./-]+\.(sh|js)`/.test(x));
  return { praw: zPrawem.length, zEgz: zEgz.length, bez: zPrawem.length - zEgz.length,
           bezNazwy: zPrawem.filter(x => !/`[A-Za-z0-9_./-]+\.(sh|js)`/.test(x))
                            .map(x => (x.split('\n')[0].match(/^[^(—]+/) || [''])[0].trim().slice(0, 40)) };
}

function liniaPraw() {
  let g;
  try { g = prawa(fs.readFileSync(PRAWA, 'utf8')); }
  catch { return '   PRAWA (_GRANICA): NIE ZMIERZONO — brak ' + PRAWA + ' (brak pomiaru ≠ zero, #18)'; }
  return `   PRAWA (_GRANICA): ${g.praw} · ${g.zEgz} z egzekutorem (nazwany plik) · ${g.bez} bez`
       + (g.bez ? `\n      bez nazwanego egzekutora: ${g.bezNazwy.join(' · ')}` : '');
}

function linia(w) {
  const proc = w.wierszy ? Math.round(w.zmech * 100 / w.wierszy) : 0;
  const niepokryte = w.bez + w.rama + w.wDrodze;
  return `   POKRYCIE M — BLIZNY (kanon/ksiegi/BLEDY.md): ${w.wierszy} blizn · ${w.zmech} z ✓ (${proc}%) · ${w.wDrodze} w drodze · `
       + `${w.bez} bez mechanizmu · ${w.rama} NOŚNA RAMA · ${w.postawa} POSTAWA   [POMIAR: ${w.pomiar.wierszy} · ${w.pomiar.zmech} z ✓]`
       + `\n   KOLEJKA RAM: ${w.rama} · NIEPOKRYTE: ${niepokryte} (bez+rama+w drodze — reklasyfikacja jej NIE rusza)`
       + `\n` + liniaPraw();
}

function raport(w, naglowek = '╔═══ POKRYCIE MECHANICZNE — BLIZNY (BLEDY.md) ∥ PRAWA (_GRANICA.md) ═══╗') {
  console.log(naglowek);
  if (w.wierszy === 0) {
    console.log('  ⓘ zero wierszy indeksu — nie ma czego mierzyć (rc=2, NIE melduję sukcesu)');
    return 2;
  }
  console.log(linia(w));
  const suma = w.zmech + w.wDrodze + w.bez + w.postawa + w.rama;
  let rc = 0;
  if (w.nieskl.length) { console.log('  ✗ status nierozpoznany we wpisach: ' + w.nieskl.join(', ')); rc = 1; }
  if (suma !== w.wierszy) { console.log(`  ✗ suma klas ${suma} ≠ wierszy ${w.wierszy} — przyrząd gubi wiersz`); rc = 1; }
  if (w.luki.length) { console.log('  ⚠ indeks↔korpus: ' + w.luki.join(' ') + ' (poza zadeklarowanym #' + PUSTE.join(',#') + ')'); rc = 1; }
  if (rc === 0) console.log('  ✓ każdy wiersz sklasyfikowany; indeks pokrywa korpus.');
  console.log('  → co ma rosnąć: kolumna „z ✓". Nowa blizna bez kandydata M powiększa „bez mechanizmu".');
  console.log('  ⓘ DWA ROZŁĄCZNE ZBIORY: pierwszy wiersz mierzy BLIZNY, trzeci PRAWA. Nazwa „pokrycie M"');
  console.log('    obiecywała prawa i mierzyła blizny — od 03.09 mówi, co mierzy (korekta twórcy).');
  return rc;
}

// ── TOR TESTOWY (#38/#47: przyrząd własnej roboty nie jest świadkiem własnej poprawności) ──
if (process.argv.includes('--test')) {
  console.log('╔═══ POKRYCIE M — AUTOTEST ═══╗');
  let zle = [];
  const naglowki = n => Array.from({length: n}, (_, i) => '## #' + (i + 1) + ' X').join('\n');

  // (+) trzy klasy rozpoznane poprawnie
  let t = naglowki(3) + '\n| 1 | — | prawo | POMIAR | **M✓** | straż |\n'
        + '| 2 | — | prawo | GIT | R | kand |\n'
        + '| 3 | — | prawo | — | **POSTAWA** (niemechanizowalne) | dom |\n';
  let w = analiza(t);
  if (!(w.wierszy === 3 && w.zmech === 1 && w.bez === 1 && w.postawa === 1)) zle.push('trzy-klasy');
  if (!(w.pomiar.wierszy === 1 && w.pomiar.zmech === 1)) zle.push('wycinek-POMIAR');

  // (+) BRAMKA MIANOWNIKA: NOŚNA RAMA jest własną klasą, nie „bez mechanizmu"
  t = naglowki(2) + '\n| 1 | — | prawo | POMIAR | **NOŚNA RAMA** | kand |\n'
    + '| 2 | — | prawo | GIT | R | kand |\n';
  w = analiza(t);
  if (!(w.rama === 1 && w.bez === 1 && w.ramy[0] === 1)) zle.push('rama-nierozpoznana');

  // (−) ZAMEK ANTY-GOODHART: przepisanie „R" → „NOŚNA RAMA" NIE MOŻE obniżyć NIEPOKRYTE.
  // To jest cała treść pułapki nazwanej w decyzji z 22.08: mianownik da się zbić
  // przenosinami między kategoriami, bez zbudowania czegokolwiek.
  const przed = analiza(naglowki(2) + '\n| 1 | — | p | POMIAR | R | k |\n| 2 | — | p | GIT | R | k |\n');
  const po    = analiza(naglowki(2) + '\n| 1 | — | p | POMIAR | **NOŚNA RAMA** | k |\n| 2 | — | p | GIT | R | k |\n');
  const npkr = x => x.bez + x.rama + x.wDrodze;
  if (npkr(przed) !== npkr(po)) zle.push('reklasyfikacja-obniza-niepokryte');
  if (po.rama === przed.rama) zle.push('reklasyfikacja-niewidoczna-w-kolejce');

  // (−) MIARA: wiersz spoza indeksu (tabela prarodzin) NIE może zostać policzony
  t = naglowki(1) + '\n| **POMIAR > PAMIĘĆ** | pytanie | #1 #2 | warstwy |\n| 1 | — | prawo | POMIAR | R | k |\n';
  if (analiza(t).wierszy !== 1) zle.push('połyka-wiersz-prarodzin');

  // (−) status nieznany MUSI oblać
  t = naglowki(1) + '\n| 1 | — | prawo | POMIAR | ZZZ | k |\n';
  if (raport(analiza(t), '── TEST − status nieznany (MUSI oblać) ──') !== 1) zle.push('nieznany-przechodzi');

  // (−) ZAMEK SUMY KLAS testowany WPROST — mutacja `if (false)` ujawniła, że przez
  // analiza() nie da się go dosięgnąć (nieskl i rozjazd sumy zapalają się razem).
  // Prawo drugiej ręki 13.08: mechanizm bez mutacji = życzenie o mechanizmie.
  const podrzucony = { wierszy: 2, zmech: 1, wDrodze: 0, bez: 0, postawa: 0, rama: 0, ramy: [],
                       nieskl: [], pomiar: { wierszy: 0, zmech: 0 }, naglowki: 2, luki: [] };
  if (raport(podrzucony, '── TEST − suma klas ≠ wierszy (MUSI oblać) ──') !== 1) zle.push('suma-klas-nie-pilnowana');

  // (−) zero materii MUSI dać rc=2, nie sukces
  if (raport(analiza('bez tabeli'), '── TEST − brak materii (MUSI dać rc=2) ──') !== 2) zle.push('zero-melduje-sukces');

  // (−) rozjazd indeks↔korpus MUSI oblać
  t = naglowki(1) + '\n| 1 | — | p | POMIAR | R | k |\n| 2 | — | p | GIT | R | k |\n';
  if (raport(analiza(t), '── TEST − brakujący nagłówek (MUSI oblać) ──') !== 1) zle.push('rozjazd-przechodzi');

  // (−) TOR NA REALNEJ MATERII (blizna DZIAŁA-I-KŁAMIE): atrapy nie wystarczą
  if (fs.existsSync(PLIK)) {
    const r = analiza(fs.readFileSync(PLIK, 'utf8'));
    if (r.wierszy < 10) zle.push('realna-materia-pusta');
    if (r.zmech + r.wDrodze + r.bez + r.postawa + r.rama !== r.wierszy) zle.push('realna-materia-gubi-wiersz');
  }

  // ── (03.09.2026) NAZWA MIERZY TO, CO MIERZY · PRAWA OSOBNO OD BLIZN ──
  // Rodowód (ALARMY_odpowiedzi §pokrycie_m, diagnoza (b), korekta twórcy 03.09): nazwa
  // wydruku obiecywała „pokrycie praw", a liczone było pokrycie WIERSZY INDEKSU BLEDY.md.
  // `_GRANICA.md` (prawa) i `BLEDY.md` (blizny) to zbiory ROZŁĄCZNE — 02.09 weszło PRAWO
  // KARTY ZDOLNOŚCI z mechanizmem i licznik nie drgnął, bo prawa w nim nigdy nie były.
  // Cięcie jest w NAZWIE i w DRUGIM WIERSZU, nie w formule (reklasyfikacja = obejście przez dane).
  // (−) wydruk NIE MOŻE nazywać wierszy BLEDY „prawami"
  const _lin = linia(analiza(naglowki(1) + '\n| 1 | — | p | POMIAR | R | k |\n'));
  if (/[0-9]+ praw\b/.test(_lin)) zle.push('wydruk-nazywa-blizny-prawami');
  if (!/bliz/i.test(_lin)) zle.push('wydruk-nie-nazywa-blizn');
  if (!/· [0-9]+ bez mechanizmu/.test(_lin)) zle.push('zerwany-czytnik-straz_powtorzen');
  // (+) prawo NAZYWAJĄCE egzekutora (plik .sh/.js w treści sekcji) liczy się jako pokryte
  // Brak funkcji `prawa` na starym kodzie ma oblać IMIENNIE, nie wyjątkiem — wyjątek
  // zabiłby wydruk pozostałych podtestów i tor przestałby nazywać, CO jest zepsute.
  let _g = null;
  try {
    _g = prawa('## PRAWO X (status PRAWO)\ntreść, egzekutor `narzedzia/straze/x.sh`\n'
             + '## PRAWO Y (status PRAWO)\nsama reguła, żadnego pliku\n'
             + '## NIE-PRAWO Z\negzekutor `a.sh` — nagłówek bez statusu\n');
  } catch (e) { zle.push('brak-licznika-praw(' + e.constructor.name + ')'); }
  if (_g && !(_g.praw === 2 && _g.zEgz === 1 && _g.bez === 1)) zle.push(`prawa-zle-policzone(${_g.praw}/${_g.zEgz}/${_g.bez})`);
  // (⊙) drugi wiersz wydruku istnieje i niesie licznik praw ODDZIELNIE od blizn
  if (!/PRAWA \(_GRANICA\): [0-9]+/.test(_lin)) zle.push('brak-wiersza-praw-w-wydruku');

  if (zle.length) { console.log('✗ TOR OBLANY: ' + zle.join(' · ')); process.exit(1); }
  console.log('✓ TOR PRZESZEDŁ — przyrząd umie NIE przejść.');
  process.exit(0);
}

if (!fs.existsSync(PLIK)) { console.log('  ⓘ brak kanon/ksiegi/BLEDY.md (rc=2)'); process.exit(2); }
const wynik = analiza(fs.readFileSync(PLIK, 'utf8'));
if (process.argv.includes('--liczba')) { console.log(linia(wynik)); process.exit(0); }
process.exit(raport(wynik));
