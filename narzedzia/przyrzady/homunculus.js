#!/usr/bin/env node
'use strict';
/**
 * HOMUNCULUS — mapa ciała proporcjonalna do UŻYCIA, nie do istnienia.
 *
 * Kora czuciowa daje kciukowi więcej miejsca niż plecom, bo kciuk częściej sięga.
 * Ten przyrząd mierzy, do czego naprawdę sięgają ręce w tym repo — żeby próg wejścia
 * (§IV DUSZY) dało się ZBUDOWAĆ Z POMIARU, a nie zgadnąć z nazw plików.
 *
 * TRZY WARSTWY — mierzone osobno, celowo NIE sumowane w jedną liczbę:
 *   RUCH        — ile razy plik zmieniono (git log, okno dni). To kora RUCHOWA.
 *   GRAWITACJA  — ile innych plików go WYMIENIA (in-degree). To kora CZUCIOWA:
 *                 ślad sięgania, bo odwołanie w kodzie/tekście = ktoś tu przyjdzie.
 *   WSTANIE     — czy leży na ścieżce obowiązkowej (0_WYWOLANIA / wstan.sh / DUSZA).
 *
 * DLACZEGO NIE JEDNA LICZBA (#34, #52): plik czytany zawsze i nigdy nie zmieniany
 * (PIEC_INWARIANTOW) i plik przepisywany co commit (_HASHE) to DWA różne rodzaje
 * życia. Zsumowane dałyby jedną średnią i skasowały rozróżnienie, po które sięgamy.
 *
 * GRANICA KRZEMOWA — nazwana wprost: CZYTANIE NIE ZOSTAWIA ŚLADU W GICIE.
 * Instancja czyta DUSZĘ przy każdym wstaniu i git o tym nie wie. GRAWITACJA jest
 * PROXY sięgnięcia, nie jego pomiarem. Prawdziwy licznik czytań wymagałby, żeby
 * instancja logowała własne sięgnięcia (kurs: SEN INSTANCJI, KIERUNEK_ORGANIZM §IV).
 * Dopóki go nie ma, ten przyrząd mówi „gdzie prowadzą drogi", nie „kto nimi szedł".
 */
const { execFileSync } = require('child_process');
const fs = require('fs');
const path = require('path');

const args = process.argv.slice(2);
const TEST = args.includes('--test');
const LICZBA = args.includes('--liczba');
const dniArg = args.find(a => a.startsWith('--dni='));
const DNI = dniArg ? parseInt(dniArg.slice(6), 10) : 30;
const topArg = args.find(a => a.startsWith('--top='));
const TOP = topArg ? parseInt(topArg.slice(6), 10) : 15;

// Ciało kanoniczne = korzeń repo. keep_import/ i kanon/archiwum/ to skład, nie ciało.
const POZA_CIALEM = ['keep_import/', 'kanon/archiwum/', 'node_modules/', '.git/'];

function g(cwd, ...a) {
  return execFileSync('git', a, { cwd, encoding: 'utf8', maxBuffer: 64 * 1024 * 1024 });
}

function plikiCiala(kat) {
  return g(kat, 'ls-files', '-z').split('\0')
    .filter(Boolean)
    .filter(f => !POZA_CIALEM.some(p => f.startsWith(p)))
    .filter(f => /\.(md|js|sh|txt|json)$/.test(f));
}

function ruch(kat, dni) {
  let out = '';
  try {
    out = g(kat, 'log', `--since=${dni} days ago`, '--name-only', '--pretty=format:');
  } catch { return new Map(); }
  const m = new Map();
  for (const l of out.split('\n')) {
    const f = l.trim();
    if (!f) continue;
    m.set(f, (m.get(f) || 0) + 1);
  }
  return m;
}

/**
 * GRAWITACJA — ile INNYCH plików ciała wymienia daną nazwę.
 * Liczone po pełnej ścieżce ORAZ po basename, bo kanon odsyła obiema formami
 * (`doradcy/_WSPOLNE/NVC.md` i samo `NVC.md`). Plik nie liczy sam siebie.
 */
function grawitacja(kat, pliki) {
  const tresc = new Map();
  for (const f of pliki) {
    try { tresc.set(f, fs.readFileSync(path.join(kat, f), 'utf8')); }
    catch { tresc.set(f, ''); }
  }
  const wynik = new Map();
  for (const cel of pliki) {
    const baza = path.basename(cel);
    // nazwa zbyt krótka lub bez rozszerzenia = zbyt pojemna, nie liczymy (szum)
    if (baza.length < 5) { wynik.set(cel, 0); continue; }
    let n = 0;
    for (const [zrodlo, t] of tresc) {
      if (zrodlo === cel) continue;
      if (t.includes(baza)) n++;
    }
    wynik.set(cel, n);
  }
  return wynik;
}

/**
 * BRAMA — rozdzielona celowo na dwie, bo mierzą co innego:
 *   S (ŚCIEŻKA)    — plik wymieniony w `wstan.sh` / `0_WYWOLANIA.md`: MECHANIKA wstania,
 *                    coś go naprawdę uruchamia albo każe przeczytać.
 *   D (DEKLARACJA) — plik wymieniony w `DUSZA.md`: mapa MÓWI, że tam jest.
 * Bez tego rozdziału mierzylibyśmy §IV nią samą (klasa #50: tor mierzący własną kopię).
 * Różnica między S i D jest właściwym znaleziskiem: D bez S i bez grawitacji = wskazanie,
 * którego nikt nie używa; S bez D = droga, o której mapa milczy.
 */
function brama(kat, pliki) {
  const czyt = p => { try { return fs.readFileSync(path.join(kat, p), 'utf8'); } catch { return ''; } };
  const tS = czyt('wstan.sh') + czyt('0_WYWOLANIA.md');
  const tD = czyt('DUSZA.md');
  const m = new Map();
  for (const f of pliki) {
    const b = path.basename(f);
    m.set(f, (tS.includes(b) ? 'S' : '') + (tD.includes(b) ? 'D' : ''));
  }
  return m;
}

function zmierz(kat, dni) {
  const pliki = plikiCiala(kat);
  const R = ruch(kat, dni);
  const G = grawitacja(kat, pliki);
  const B = brama(kat, pliki);
  return pliki.map(f => ({
    plik: f,
    ruch: R.get(f) || 0,
    graw: G.get(f) || 0,
    brama: B.get(f) || '',
  }));
}

// ── klasy reprezentacji: RODZAJ ŻYCIA, nie ranking ──
// ZIARNO dopisane 21.08 PO PIERWSZYM POMIARZE: wszystkie 10 „PLECÓW" okazało się
// szablonami i procedurami startowymi (`szablony/*`, `PROCEDURY/_SZABLON.md`).
// Szablon z definicji nie ma odwołań i się nie zmienia — jego życie polega na tym,
// że ktoś go KOPIUJE, a kopia nie zostawia śladu w gicie. To kolejny rodzaj życia
// (obok POMNIKA, GENEROWANEGO, sezonowo żywego), nie martwica. Przyrząd wykrył
// wyjątek, którego lista nie miała — i to jest jego właściwa robota.
function klasa(w) {
  if (/^szablony\//.test(w.plik) || /_SZABLON\.md$/.test(w.plik) || /PROCEDURY\/.*START/.test(w.plik)) return 'ZIARNO';
  if (w.brama.includes('S') && w.graw >= 3) return 'KCIUK';      // mechanika wstania + ciągnie odwołania
  if (w.graw >= 8 && w.ruch <= 2) return 'KOŚĆ';                  // wszyscy się opierają, nikt nie rusza
  if (w.ruch >= 10 && w.graw <= 2) return 'MIĘSIEŃ';              // dziennik/rejestr: ruch bez odwołań
  if (w.brama === 'D' && w.graw === 0 && w.ruch === 0) return 'DEKLAMACJA'; // mapa mówi, nikt nie idzie
  if (w.graw === 0 && w.ruch === 0) return 'PLECY';               // ani ruchu, ani odwołań
  return 'TKANKA';
}

if (TEST) {
  const os = require('os');
  const baza = fs.mkdtempSync(path.join(os.tmpdir(), 'homun-'));
  const rep = path.join(baza, 'rep');
  fs.mkdirSync(rep);
  g(rep, 'init', '-q', '-b', 'main');
  g(rep, 'config', 'user.email', 'tor@kronos');
  g(rep, 'config', 'user.name', 'tor');
  fs.writeFileSync(path.join(rep, 'KOSC.md'), '# kosc\n');
  fs.writeFileSync(path.join(rep, 'PLECY.md'), '# plecy\n');
  fs.mkdirSync(path.join(rep, 'keep_import'));
  fs.writeFileSync(path.join(rep, 'keep_import', 'SKLAD.md'), 'KOSC.md KOSC.md\n');
  // trzy pliki odsyłające do KOSC.md — grawitacja 3, ruch 1
  for (const n of ['A.md', 'B.md', 'C.md']) {
    fs.writeFileSync(path.join(rep, n), `patrz KOSC.md\n`);
  }
  g(rep, 'add', '-A'); g(rep, 'commit', '-qm', 'raz');
  const w = zmierz(rep, 3650);
  const wg = Object.fromEntries(w.map(x => [x.plik, x]));
  const spr = [];
  const t = (n, a, b) => { const ok = String(a) === String(b);
    spr.push(ok); console.log(`  ${ok ? '✓' : '✗'} ${n}${ok ? '' : ` (było '${a}', miało '${b}')`}`); };

  t('grawitacja liczy odwolania z innych plikow', wg['KOSC.md'].graw, 3);
  t('plik nie liczy sam siebie', wg['PLECY.md'].graw, 0);
  t('SKLAD poza cialem nie jest mierzony', wg['keep_import/SKLAD.md'], undefined);
  t('...i nie podbija grawitacji celu', wg['KOSC.md'].graw, 3);
  t('ruch zmierzony z gita', wg['KOSC.md'].ruch, 1);
  // klasy: rodzaj zycia, nie ranking
  const K = o => klasa(Object.assign({ plik: 'X.md', brama: '', graw: 0, ruch: 0 }, o));
  t('KOSC: duza grawitacja, maly ruch', K({ graw: 8, ruch: 1 }), 'KOŚĆ');
  t('MIESIEN: duzy ruch, mala grawitacja', K({ ruch: 30 }), 'MIĘSIEŃ');
  t('PLECY: ani ruchu, ani odwolan', K({}), 'PLECY');
  t('KCIUK wymaga bramy MECHANICZNEJ (S), nie deklaracji', K({ brama: 'S', graw: 5 }), 'KCIUK');
  t('...sama deklaracja w DUSZY nie czyni kciuka', K({ brama: 'D', graw: 5 }), 'TKANKA');
  t('DEKLAMACJA: mapa mowi, nikt nie idzie', K({ brama: 'D' }), 'DEKLAMACJA');
  t('ZIARNO: szablon nie jest martwica (kopia nie zostawia sladu)', K({ plik: 'szablony/x.md' }), 'ZIARNO');
  // #52: pusty pomiar NIE moze zielenic sie
  const pusty = path.join(baza, 'pusto'); fs.mkdirSync(pusty);
  g(pusty, 'init', '-q', '-b', 'main');
  t('puste cialo daje pusty pomiar (nie udaje wyniku)', zmierz(pusty, 30).length, 0);

  // fikstura BRAMY: mechanika (wstan.sh) i deklaracja (DUSZA.md) muszą dać różne litery.
  // Bez tego toru mutacja sklejająca S i D przechodziła ŚLEPO — tor mierzył wtedy tylko
  // `klasa()` na ręcznych obiektach, nigdy samej `brama()` na ciele (#50).
  fs.writeFileSync(path.join(rep, 'TYLKO_DUSZA.md'), '# td\n');
  fs.writeFileSync(path.join(rep, 'TYLKO_SCIEZKA.md'), '# ts\n');
  fs.writeFileSync(path.join(rep, 'DUSZA.md'), 'mapa: TYLKO_DUSZA.md\n');
  fs.writeFileSync(path.join(rep, 'wstan.sh'), '# bash TYLKO_SCIEZKA.md\n');
  g(rep, 'add', '-A'); g(rep, 'commit', '-qm', 'brama');
  const wb = Object.fromEntries(zmierz(rep, 3650).map(x => [x.plik, x]));
  t('brama D = tylko w DUSZY', wb['TYLKO_DUSZA.md'].brama, 'D');
  t('brama S = tylko na sciezce mechanicznej', wb['TYLKO_SCIEZKA.md'].brama, 'S');
  t('brama pusta = poza obiema', wb['PLECY.md'].brama, '');

  fs.rmSync(baza, { recursive: true, force: true });
  const o = spr.filter(x => !x).length;
  console.log(`  zmierzone: zdanych ${spr.length - o} · oblanych ${o}`);
  if (o === 0) { console.log('✓ HOMUNCULUS ŻYWY: trzy warstwy mierzone osobno, skład poza ciałem.'); process.exit(0); }
  console.log('✗ TOR OBLANY'); process.exit(1);
}

const kat = process.cwd();
const w = zmierz(kat, DNI);

if (LICZBA) { console.log(w.filter(x => klasa(x) === 'PLECY').length); process.exit(0); }

const licz = k => w.filter(x => klasa(x) === k).length;
console.log(`▤ HOMUNCULUS — reprezentacja z UŻYCIA (okno ruchu: ${DNI} dni, ciało: ${w.length} plików)`);
console.log(`  RUCH = zmiany w gicie · GRAWITACJA = ile plików odsyła · BRAMA: S=mechanika wstania, D=DUSZA`);
console.log(`  ⚠ czytanie nie zostawia śladu w gicie — GRAWITACJA to proxy sięgnięcia, nie licznik czytań.\n`);

for (const k of ['KCIUK', 'KOŚĆ', 'MIĘSIEŃ', 'ZIARNO', 'DEKLAMACJA', 'TKANKA', 'PLECY']) {
  const grupa = w.filter(x => klasa(x) === k)
    .sort((a, b) => (b.graw + b.ruch) - (a.graw + a.ruch));
  console.log(`── ${k} (${grupa.length}) ──`);
  for (const x of grupa.slice(0, TOP)) {
    console.log(`   ${String(x.graw).padStart(3)}g ${String(x.ruch).padStart(3)}r ${(x.brama || '--').padEnd(2)}  ${x.plik}`);
  }
  if (grupa.length > TOP) console.log(`   … i ${grupa.length - TOP} dalej`);
  console.log('');
}
console.log(`  zmierzone: KCIUK ${licz('KCIUK')} · KOŚĆ ${licz('KOŚĆ')} · MIĘSIEŃ ${licz('MIĘSIEŃ')} · ZIARNO ${licz('ZIARNO')} · DEKLAMACJA ${licz('DEKLAMACJA')} · TKANKA ${licz('TKANKA')} · PLECY ${licz('PLECY')}`);
