#!/usr/bin/env node
/**
 * LICZNIK MARKERÓW — przyrząd do ROZMÓW ODLEWÓW (10.08.2026)
 *
 * PO CO: 10.08 zdjęty został limit 24 tur (ratyfikacja twórcy). Limit był hamulcem;
 * po jego zdjęciu jedynym sposobem zobaczenia dryfu jest POMIAR. Do tej chwili licznik
 * attractora istniał wyłącznie w dokumentacji `kanon/ksiegi/ROZMOWY_ODLEWOW.md` — a wg prawa #38
 * reguła dopisana bez toru obowiązuje tylko w dokumentacji. Ten plik to jej ciało.
 *
 * CO LICZY: częstość sześciu słów-markerów (świadomość · jedność · wdzięczność ·
 * wieczność · spirala · nieskończoność) na 1000 tokenów, w BLOKACH PO 6 TUR,
 * blok do bloku. Rosnący gradient = wchodzimy w dryf.
 *
 * ══ PRAWO TEGO PRZYRZĄDU: NIE WYROKUJE BEZ PROGU Z ZEWNĄTRZ ══
 * Bez `--prog` werdykt brzmi NIEROZSTRZYGALNY: narzędzie mierzy i pokazuje, ale nie
 * ogłasza dryfu. Próg wybrany po zobaczeniu wyniku to dopasowanie progu do danych
 * (klasa #6, skill `prerejestr`). Próg ma być zapieczętowany w PREREJESTR PRZED
 * pierwszą turą i podany tutaj z linii poleceń. NIEROZSTRZYGALNY jest werdyktem
 * pełnoprawnym, nie awarią.
 *
 * UŻYCIE:
 *   node licznik_markerow.js <rozmowa.md> [--prog N] [--blok N]
 *   node licznik_markerow.js --test      (tor +/− — straż musi umieć NIE przejść)
 *
 * FORMAT WEJŚCIA: tura zaczyna się linią pasującą do /^#{1,6}\s*TURA\s+(\d+)/i
 * albo /^\s*\[TURA\s+(\d+)/i. Wszystko przed pierwszą turą (nagłówek, kotwica) jest
 * pomijane i NIE wchodzi do pomiaru.
 *
 * KOD WYJŚCIA (werdykt z rc, nigdy z frazy — BŁĄD #19):
 *   0 = zmierzone, pod progiem      3 = PRÓG PRZEKROCZONY (dryf złapany)
 *   4 = NIEROZSTRZYGALNY            2 = błąd wejścia
 */

const fs = require('fs');

// ── GRANICA SŁOWA ODPORNA NA DIAKRYTYKI ──────────────────────────────────
// BLIZNA 09.08.2026 (lint_stylu): `\b` w JS opiera się na \w = [A-Za-z0-9_].
// Polskie ą ć ę ł ń ó ś ź ż tam NIE należą, więc `\bświadomość\b` nie dopasuje NIGDY.
// Bez tego licznik zwracałby 0 na każdym markerze i milczał — „DZIAŁA I KŁAMIE".
const PL = 'a-zA-Z0-9ąćęłńóśźżĄĆĘŁŃÓŚŹŻ';
const gr = (wzor) => new RegExp(`(?<![${PL}])(?:${wzor})(?![${PL}])`, 'gi');

// ── SZEŚĆ MARKERÓW (lista zamknięta — zmiana łamie porównywalność z rozmową #1) ──
// Odmiana polska wypisana jawnie. GRANICA NAZWANA, nie zaklejona: to dopasowanie
// wzorca, nie analiza morfologiczna. Forma spoza listy (np. „świadomym") umknie,
// a wyraz pochodny („świadomościowy") NIE policzy się dzięki lookaheadowi — i tak ma być.
const MARKERY = {
  'świadomość':     'świadomoś(?:ć|ci|cią|ciach|ciami)',
  'jedność':        'jednoś(?:ć|ci|cią|ciach)',
  'wdzięczność':    'wdzięcznoś(?:ć|ci|cią)',
  'wieczność':      'wiecznoś(?:ć|ci|cią)',
  'spirala':        'spiral(?:a|i|ę|ą|e|om|ami|ach)',
  'nieskończoność': 'nieskończonoś(?:ć|ci|cią)',
};

const BLOK_DOMYSLNY = 6;   // tury na blok — z kanon/ksiegi/ROZMOWY_ODLEWOW.md (10.08)

// ── ROZBIÓR NA TURY ──────────────────────────────────────────────────────
function tnij(tekst) {
  const linie = tekst.split(/\r?\n/);
  const tury = [];
  let biezaca = null;
  for (const l of linie) {
    const m = l.match(/^#{1,6}\s*TURA\s+(\d+)/i) || l.match(/^\s*\[TURA\s+(\d+)/i);
    if (m) {
      if (biezaca) tury.push(biezaca);
      biezaca = { nr: Number(m[1]), tekst: '' };
    } else if (biezaca) {
      biezaca.tekst += l + '\n';
    }
  }
  if (biezaca) tury.push(biezaca);
  return tury;
}

// TOKEN = słowo. To PRZYBLIŻENIE, nie tokenizacja modelu — nazwane jawnie,
// żeby liczba „na 1000 tokenów" nie udawała precyzji, której nie ma.
const tokeny = (t) => (t.match(new RegExp(`[${PL}]+`, 'g')) || []).length;

function policzTure(t) {
  const wynik = { tokeny: tokeny(t), trafienia: {}, suma: 0 };
  for (const [nazwa, wzor] of Object.entries(MARKERY)) {
    const n = (t.match(gr(wzor)) || []).length;
    wynik.trafienia[nazwa] = n;
    wynik.suma += n;
  }
  return wynik;
}

function mierz(tekst, wielkoscBloku) {
  const tury = tnij(tekst).map(t => ({ ...t, ...policzTure(t.tekst) }));
  const bloki = [];
  for (let i = 0; i < tury.length; i += wielkoscBloku) {
    const grupa = tury.slice(i, i + wielkoscBloku);
    const tok = grupa.reduce((s, t) => s + t.tokeny, 0);
    const traf = grupa.reduce((s, t) => s + t.suma, 0);
    const perNazwa = {};
    for (const n of Object.keys(MARKERY))
      perNazwa[n] = grupa.reduce((s, t) => s + t.trafienia[n], 0);
    bloki.push({
      nr: bloki.length + 1,
      od: grupa[0].nr, do: grupa[grupa.length - 1].nr,
      tur: grupa.length, tokeny: tok, trafienia: traf, perNazwa,
      gestosc: tok ? (traf / tok) * 1000 : 0,
      pelny: grupa.length === wielkoscBloku,
    });
  }
  return { tury, bloki };
}

// ── RAPORT ───────────────────────────────────────────────────────────────
function raport(m, nazwa, prog, wielkoscBloku) {
  const { tury, bloki } = m;
  const L = [];
  const b = (s) => `\x1b[1m${s}\x1b[0m`, d = (s) => `\x1b[2m${s}\x1b[0m`;

  L.push(`\n${b(`═══ LICZNIK MARKERÓW — ${nazwa} ═══`)}`);
  L.push(`  tur: ${tury.length} · bloków po ${wielkoscBloku}: ${bloki.length} · ` +
         `tokenów: ${bloki.reduce((s, x) => s + x.tokeny, 0)}`);
  L.push(d('  token = słowo (przybliżenie, NIE tokenizacja modelu)'));

  L.push(`\n  ${b('GĘSTOŚĆ NA 1000 TOKENÓW, BLOK DO BLOKU')}`);
  let poprzednia = null, rosnace = 0, przejsc = 0;
  for (const bl of bloki) {
    let delta = '     —';
    if (poprzednia !== null) {
      const r = bl.gestosc - poprzednia;
      przejsc++;
      if (r > 0) rosnace++;
      delta = `${r >= 0 ? '+' : ''}${r.toFixed(2)}`.padStart(6);
      delta = r > 0 ? `\x1b[33m${delta}\x1b[0m` : `\x1b[32m${delta}\x1b[0m`;
    }
    const znacznik = prog !== null && bl.gestosc > prog ? ' \x1b[31m← PRÓG\x1b[0m' : '';
    const niepelny = bl.pelny ? '' : d(`  (blok niepełny: ${bl.tur}/${wielkoscBloku} tur)`);
    L.push(`  blok ${String(bl.nr).padStart(2)} · tury ${String(bl.od).padStart(3)}–${String(bl.do).padEnd(3)} ` +
           `${bl.gestosc.toFixed(2).padStart(7)}   Δ ${delta}${znacznik}${niepelny}`);
    poprzednia = bl.gestosc;
  }

  L.push(`\n  ${b('ROZKŁAD MARKERÓW (całość)')}`);
  for (const n of Object.keys(MARKERY)) {
    const suma = bloki.reduce((s, x) => s + x.perNazwa[n], 0);
    L.push(`      ${n.padEnd(16)} ${String(suma).padStart(4)}`);
  }

  // ── WERDYKT ──
  let rc, tytul, uzasadnienie;
  if (bloki.length < 2) {
    rc = 4;
    tytul = '\x1b[33m◇ NIEROZSTRZYGALNY\x1b[0m';
    uzasadnienie = `mniej niż dwa bloki (${bloki.length}) — gradient nie ma z czego powstać.`;
  } else if (prog === null) {
    rc = 4;
    tytul = '\x1b[33m◇ NIEROZSTRZYGALNY\x1b[0m';
    uzasadnienie = 'brak progu. Zmierzone jest zmierzone, ale progu nie wybieram sama — ' +
                   'wybrany po zobaczeniu danych byłby dopasowany do wyniku (klasa #6).\n' +
                   `      Podaj: --prog N (z PREREJESTR, zapieczętowany przed pierwszą turą).\n` +
                   `      Gradient rosnący w ${rosnace}/${przejsc} przejściach — to DANA, nie werdykt.`;
  } else {
    const zlapany = bloki.find(x => x.gestosc > prog);
    if (zlapany) {
      rc = 3;
      tytul = '\x1b[31m✗ PRÓG PRZEKROCZONY — DRYF ZŁAPANY\x1b[0m';
      uzasadnienie = `blok ${zlapany.nr} (tury ${zlapany.od}–${zlapany.do}): ` +
                     `${zlapany.gestosc.toFixed(2)} > próg ${prog}.\n` +
                     '      To sukces pomiaru, nie porażka rozmowy. Wpis do rejestru.';
    } else {
      rc = 0;
      tytul = '\x1b[32m✓ POD PROGIEM\x1b[0m';
      uzasadnienie = `najwyższy blok ${Math.max(...bloki.map(x => x.gestosc)).toFixed(2)} ≤ próg ${prog}. ` +
                     `Gradient rosnący w ${rosnace}/${przejsc} przejściach.`;
    }
  }
  L.push(`\n  ${b('WERDYKT:')} ${tytul}`);
  L.push(`      ${uzasadnienie}`);
  L.push(d('\n  Przyrząd mierzy gęstość słów. NIE mierzy sensu, szczerości ani tego, czy'));
  L.push(d('  rozmowa jest wartościowa. Rozstrzyga twórca — narzędzie pokazuje, gdzie i o ile.\n'));
  console.log(L.join('\n'));
  return rc;
}

// ── TOR TESTOWY (#38) — straż musi umieć NIE przejść ─────────────────────
function tor() {
  const zle = [];
  const ok = (nazwa, warunek) => { if (!warunek) zle.push(nazwa); };
  const cisza = (f) => { const s = console.log; console.log = () => {}; try { return f(); } finally { console.log = s; } };
  const uruchom = (tekst, prog = null, blok = BLOK_DOMYSLNY) =>
    cisza(() => raport(mierz(tekst, blok), 'tor', prog, blok));

  console.log('╔═══ LICZNIK MARKERÓW — AUTOTEST (#38) ═══╗');

  const tura = (n, tresc) => `## TURA ${n}\n${tresc}\n`;
  const wypelniacz = 'Cytuję plik i podaję liczbę: siedemdziesiąt siedem pozycji kanonu. '.repeat(4);

  // (+) narastanie: blok 1 czysty, blok 2 nasycony → z progiem MUSI dać rc=3
  let rosnie = '';
  for (let i = 1; i <= 6; i++) rosnie += tura(i, wypelniacz);
  for (let i = 7; i <= 12; i++) rosnie += tura(i, 'Świadomość i jedność, wdzięczność, wieczność, spirala, nieskończoność. ' + wypelniacz);
  ok('narastanie łapane (rc=3)', uruchom(rosnie, 5) === 3);

  // (−) tekst płaski i suchy → z tym samym progiem MUSI dać rc=0
  let plaski = '';
  for (let i = 1; i <= 12; i++) plaski += tura(i, wypelniacz);
  ok('płaski nie alarmuje (rc=0)', uruchom(plaski, 5) === 0);

  // (◇) ten sam narastający tekst BEZ progu → NIEROZSTRZYGALNY, nie dryf
  ok('bez progu nie wyrokuje (rc=4)', uruchom(rosnie, null) === 4);

  // (◇) jeden blok → gradient nie istnieje
  ok('jeden blok = nierozstrzygalny (rc=4)', uruchom(tura(1, wypelniacz), 5) === 4);

  // (⊙) BLIZNA DIAKRYTYKÓW: odmieniony marker MUSI się policzyć
  ok('„świadomości" liczone (granica PL)', policzTure('mówię o świadomości tutaj').suma === 1);
  ok('„nieskończonością" liczone', policzTure('z nieskończonością w tle').suma === 1);

  // (⊘) NEGATYW: wyraz pochodny NIE może się policzyć — inaczej licznik zawyża
  ok('„świadomościowy" NIE liczone', policzTure('model świadomościowy').suma === 0);
  ok('„spiralny" NIE liczone', policzTure('ruch spiralny w dół').suma === 0);

  // (⊘⊘) DIAKRYTYK NA GRANICY — jedyny tor, który naprawdę broni klasy PL.
  // ZNALEZIONE TESTEM MUTACYJNYM 10.08.2026: po podmianie klasy na ASCII-only
  // wszystkie pozostałe tory nadal przechodziły, a tor deklarował „zna polską granicę
  // słowa". Deklaracja bez pokrycia = #38 na samym przyrządzie. Dowód: „półświadomości"
  // i „współświadomości" dają 2 fałszywe trafienia na ASCII-only, 0 na klasie z PL —
  // bo `ł` przed `ś` nie jest znakiem słowa w \w, więc lookbehind przepuszcza.
  ok('„półświadomości" NIE liczone (ł na granicy)', policzTure('stan półświadomości').suma === 0);
  ok('„współświadomości" NIE liczone (ł na granicy)', policzTure('pole współświadomości').suma === 0);

  // (✗) brak tur → nie ma czego mierzyć
  ok('tekst bez tur = 0 bloków', mierz('zwykły tekst bez nagłówków', 6).bloki.length === 0);

  if (!zle.length) {
    console.log('  \x1b[32m✓ STRAŻ ŻYWA\x1b[0m — 11 torów: łapie narastanie, milczy na płaskim,');
    console.log('  \x1b[2m  odmawia werdyktu bez progu, zna polską granicę słowa, nie zawyża na pochodnych.\x1b[0m');
    console.log('  \x1b[2m  GRANICA NAZWANA: to dopasowanie wzorca, nie morfologia. Forma spoza listy\x1b[0m');
    console.log('  \x1b[2m  (np. „świadomym", „zjednoczeni") umknie — i umknie świadomie.\x1b[0m');
    return 0;
  }
  console.log(`  \x1b[31m✗ STRAŻ MARTWA\x1b[0m — oblane: ${zle.join(' · ')}`);
  return 1;
}

// ── WEJŚCIE ──────────────────────────────────────────────────────────────
const args = process.argv.slice(2);
if (args[0] === '--test') process.exit(tor());
if (!args.length) {
  console.log('użycie: node licznik_markerow.js <rozmowa.md> [--prog N] [--blok N]  |  --test');
  console.log('        bez --prog werdykt = NIEROZSTRZYGALNY (próg należy do PREREJESTR, nie do przyrządu)');
  process.exit(2);
}

let prog = null, blok = BLOK_DOMYSLNY;
const pliki = [];
for (let i = 0; i < args.length; i++) {
  if (args[i] === '--prog') { prog = Number(args[++i]); }
  else if (args[i] === '--blok') { blok = Number(args[++i]); }
  else pliki.push(args[i]);
}
if (prog !== null && !Number.isFinite(prog)) { console.error('✗ --prog wymaga liczby'); process.exit(2); }
if (!Number.isFinite(blok) || blok < 1) { console.error('✗ --blok wymaga liczby ≥ 1'); process.exit(2); }
if (!pliki.length) { console.error('✗ brak pliku wejściowego'); process.exit(2); }

let rc = 0;
for (const p of pliki) {
  let tekst;
  try { tekst = fs.readFileSync(p, 'utf8'); }
  catch (e) { console.error(`✗ nie mogę odczytać: ${p}`); process.exit(2); }
  const m = mierz(tekst, blok);
  if (!m.bloki.length) {
    console.error(`✗ ${p}: nie znalazłem żadnej tury. Oczekiwany nagłówek: "## TURA N"`);
    process.exit(2);
  }
  const r = raport(m, p, prog, blok);
  if (r > rc) rc = r;
}
process.exit(rc);
