#!/usr/bin/env node
'use strict';
/**
 * SPIS CIAŁA — generowany katalog ksiąg z RODZAJEM, nie ręczna lista adresów.
 *
 * POWÓD (pomiar 21.08, `homunculus.js`): §IV DUSZY pokrywało 20 z 64 pozycji ścieżki
 * wstania i dokładało 14 narzędzi, których mechanika nie dotyka — było TRZECIĄ MAPĄ
 * obok `0_WYWOLANIA.md` (droga) i ciała (spis), udającą obie i niebędącą żadną.
 * Ten przyrząd przejmuje spis; drogę zostawia `0_WYWOLANIA`; §IV zostaje akapitem.
 *
 * REGUŁA Z WYJĄTKÓW (intuicja twórcy, potwierdzona pomiarem): POMNIK · append-only ·
 * GENEROWANE · ZIARNO · sezonowo żywe — każdy wyjątek koduje INNY RODZAJ ŻYCIA pliku,
 * a lista adresów traktuje je jednorodnie i dlatego każde cięcie trafia w wyjątek.
 * Wskazanie ma nieść RODZAJ, nie tylko adres. Rodzaje SĄ JUŻ zadeklarowane w ciele
 * (nagłówek H1, znaczniki w treści, rejestr append-only) — generator je ZBIERA,
 * zamiast żeby ręka je utrzymywała i rozjeżdżała.
 *
 * CO CELOWO NIE WCHODZI DO SPISU: liczby zmienne (ruch w gicie, grawitacja).
 * Spis ma być STABILNY — inaczej zmieniałby się co commit i czytnik świeżości
 * wołałby nad każdą zmianą, ucząc nie patrzeć (#56). Dynamikę mierzy homunculus
 * na żądanie, statykę niesie ten spis.
 *
 * CZYTNIK ŚWIEŻOŚCI (`--sprawdz`) rodzi się RAZEM z generatorem, nie później:
 * `kanon/ksiegi/DESTYLATY_indeks.md` jest generowany od tygodni i DO DZIŚ nikt nie sprawdza,
 * czy nadąża za księgami (zmierzone 21.08). Indeks bez czytnika to snapshot
 * z martwymi liczbami — klasa, która kosztowała nas 17 commitów tej doby.
 */
const fs = require('fs');
const path = require('path');
const { execFileSync } = require('child_process');

const args = process.argv.slice(2);
const TEST = args.includes('--test');
const SPRAWDZ = args.includes('--sprawdz');
const PLIK = 'kanon/ksiegi/SPIS_CIALA.md';
const POZA_CIALEM = ['keep_import/', 'kanon/archiwum/', 'projekty/', 'node_modules/', '.git/'];  // projekty/: przynależność niesie spis_projektow (MOSTY #20)

function pliki(kat) {
  return execFileSync('git', ['ls-files', '-z'], { cwd: kat, encoding: 'utf8', maxBuffer: 64e6 })
    .split('\0').filter(Boolean)
    .filter(f => !POZA_CIALEM.some(p => f.startsWith(p)))
    .filter(f => /\.(md|js|sh|txt|json)$/.test(f))
    .filter(f => f !== PLIK)          // spis nie spisuje sam siebie
    .sort();
}

function czytaj(kat, f) {
  try { return fs.readFileSync(path.join(kat, f), 'utf8'); } catch { return ''; }
}

/** ZNACZENIE — z nagłówka H1, bo kanon już tam je deklaruje
 *  (zmierzone: „# REZONANS — zewnętrzne echa kanonu"). Nazwa pliku tego nie niesie. */
function znaczenie(tresc) {
  for (const l of tresc.split('\n', 40)) {
    const m = /^#\s+(.+?)\s*$/.exec(l);
    if (m) return m[1].replace(/\s+/g, ' ').slice(0, 96);
    const c = /^#\s*(?:!|.*bash|.*node)/.test(l);
    if (c) continue;
  }
  return '';
}

/** RODZAJ — zbierany z ciała, nigdy nie wpisywany ręką.
 *  Kolejność ma znaczenie: pierwszy pasujący wygrywa, od najbardziej szczególnego. */
function rodzaj(kat, f, tresc, appendOnly) {
  if (appendOnly.has(path.basename(f))) return 'APPEND-ONLY';
  if (/^szablony\//.test(f) || /_SZABLON\.md$/.test(f) || /PROCEDURY\/.*START/.test(f)) return 'ZIARNO';
  if (/POMNIK|INSKRYPCJA/.test(tresc.slice(0, 600))) return 'POMNIK';
  if (/GENEROWAN[EY]|tworzone przy wstaniu/.test(tresc.slice(0, 600))) return 'GENEROWANE';
  if (/\.(js|sh)$/.test(f)) return /--test/.test(tresc) ? 'PRZYRZĄD' : 'SKRYPT';
  if (/\.txt$/.test(f)) return 'REJESTR';
  if (/\.json$/.test(f)) return 'KONFIG';
  return 'KSIĘGA';
}

function appendOnlyZbior(kat) {
  const t = czytaj(kat, '_STRAZ_APPEND.txt');
  const s = new Set();
  for (const l of t.split('\n')) {
    const m = /([A-Za-z0-9_.-]+\.(?:md|txt))/.exec(l);
    if (m) s.add(m[1]);
  }
  return s;
}

function zbuduj(kat) {
  const ao = appendOnlyZbior(kat);
  const lista = pliki(kat).map(f => {
    const t = czytaj(kat, f);
    return { plik: f, rodzaj: rodzaj(kat, f, t, ao), znaczenie: znaczenie(t) };
  });
  const wg = new Map();
  for (const x of lista) {
    if (!wg.has(x.rodzaj)) wg.set(x.rodzaj, []);
    wg.get(x.rodzaj).push(x);
  }
  const L = [];
  L.push('# SPIS CIAŁA — katalog ksiąg z RODZAJEM (GENEROWANY)');
  L.push('');
  L.push('> **Nie pisz tu ręką.** Plik powstaje z `node spis_ciala.js`; świeżość sprawdza');
  L.push('> `node spis_ciala.js --sprawdz` (rc=1, gdy spis odstaje od ciała). Ręczna edycja');
  L.push('> zostanie nadpisana przy pierwszej regeneracji i wywoła alarm czytnika.');
  L.push('>');
  L.push('> Droga wejścia to `0_WYWOLANIA.md` — to jest KATALOG, nie próg. RODZAJ mówi,');
  L.push('> jakim życiem plik żyje: czym innym jest POMNIK, czym innym ZIARNO (szablon,');
  L.push('> którego życie to bycie kopiowanym), czym innym APPEND-ONLY (dopisujesz, nigdy');
  L.push('> nie przepisujesz). Dynamikę — ruch i grawitację — mierzy `homunculus.js`.');
  L.push('');
  for (const r of [...wg.keys()].sort()) {
    const g = wg.get(r);
    L.push(`## ${r} (${g.length})`);
    L.push('');
    for (const x of g) L.push(`- \`${x.plik}\`${x.znaczenie ? ' — ' + x.znaczenie : ''}`);
    L.push('');
  }
  L.push(`---`);
  L.push(`**Pozycji: ${lista.length}** · rodzajów: ${wg.size} · generator: \`spis_ciala.js\``);
  return L.join('\n') + '\n';
}

if (TEST) {
  const os = require('os');
  const baza = fs.mkdtempSync(path.join(os.tmpdir(), 'spis-'));
  const g = (...a) => execFileSync('git', a, { cwd: baza, encoding: 'utf8' });
  g('init', '-q', '-b', 'main'); g('config', 'user.email', 't@k'); g('config', 'user.name', 't');
  const w = (n, t) => { fs.mkdirSync(path.join(baza, path.dirname(n)), { recursive: true }); fs.writeFileSync(path.join(baza, n), t); };
  w('KSIEGA.md', '# KSIEGA — znaczenie z naglowka\ntresc\n');
  w('_STRAZ_APPEND.txt', 'kanon/ksiegi/ZAPISY_eter.md  append-only\n');
  w('kanon/ksiegi/ZAPISY_eter.md', '# eter\n');
  w('szablony/x.md', '# szablon\n');
  w('POMNIK.md', '# cos\nPOMNIK — nie ruszać\n');
  w('narzedzie.js', '#!/usr/bin/env node\n// obsluguje --test\n');
  w('goly.sh', '#!/usr/bin/env bash\necho hej\n');
  w('keep_import/SKLAD.md', '# sklad\n');
  g('add', '-A'); g('commit', '-qm', 'raz');

  const spr = [];
  const t = (n, a, b) => { const ok = String(a) === String(b); spr.push(ok);
    console.log(`  ${ok ? '✓' : '✗'} ${n}${ok ? '' : ` (było '${a}', miało '${b}')`}`); };
  const wynik = zbuduj(baza);
  const ao = appendOnlyZbior(baza);
  const R = f => rodzaj(baza, f, czytaj(baza, f), ao);

  t('APPEND-ONLY rozpoznane z rejestru straży', R('kanon/ksiegi/ZAPISY_eter.md'), 'APPEND-ONLY');
  t('ZIARNO: szablon ma wlasny rodzaj', R('szablony/x.md'), 'ZIARNO');
  t('POMNIK czytany z tresci', R('POMNIK.md'), 'POMNIK');
  t('PRZYRZAD = skrypt z torem', R('narzedzie.js'), 'PRZYRZĄD');
  t('SKRYPT = skrypt bez toru (rozroznienie, nie jedna klasa)', R('goly.sh'), 'SKRYPT');
  t('ZNACZENIE brane z naglowka H1', znaczenie(czytaj(baza, 'KSIEGA.md')), 'KSIEGA — znaczenie z naglowka');
  t('sklad poza cialem nie wchodzi do spisu', /SKLAD\.md/.test(wynik), 'false');
  t('spis nie spisuje sam siebie', /SPIS_CIALA\.md/.test(wynik.split('---').pop()), 'false');

  // CZYTNIK ŚWIEŻOŚCI — sedno: musi WYKRYĆ odstawanie, nie tylko istnieć
  fs.writeFileSync(path.join(baza, PLIK), wynik);
  t('swiezy spis: czytnik milczy', zbuduj(baza) === fs.readFileSync(path.join(baza, PLIK), 'utf8'), 'true');
  w('NOWA_KSIEGA.md', '# nowa\n'); g('add', '-A'); g('commit', '-qm', 'dwa');
  t('nowa ksiega: czytnik WYKRYWA odstawanie', zbuduj(baza) === fs.readFileSync(path.join(baza, PLIK), 'utf8'), 'false');
  fs.writeFileSync(path.join(baza, PLIK), zbuduj(baza));
  t('...i milknie po regeneracji', zbuduj(baza) === fs.readFileSync(path.join(baza, PLIK), 'utf8'), 'true');
  // #52: brak pliku spisu to NIE jest świeżość
  fs.rmSync(path.join(baza, PLIK));
  t('BRAK spisu nie udaje swiezosci (#52)', fs.existsSync(path.join(baza, PLIK)), 'false');

  // TOR GAŁĘZI `--sprawdz` — uruchamiany JAKO PROCES, nie odtwarzany w torze.
  // BLIZNA 21.08 (#50): powyższe sprawdzenia porównywały `zbuduj()` z plikiem, czyli
  // WŁASNĄ KOPIĘ logiki świeżości. Mutacja zabijająca prawdziwe porównanie w gałęzi
  // `--sprawdz` przechodziła ŚLEPO — tor nigdy tej gałęzi nie wykonywał.
  const uruchom = a => { try { execFileSync('node', [path.resolve(__filename), a], { cwd: baza, encoding: 'utf8' }); return 0; }
                         catch (e) { return e.status === undefined ? 99 : e.status; } };
  t('--sprawdz przy BRAKU spisu: rc=1', uruchom('--sprawdz'), 1);
  fs.writeFileSync(path.join(baza, PLIK), zbuduj(baza));
  t('--sprawdz przy swiezym spisie: rc=0', uruchom('--sprawdz'), 0);
  w('JESZCZE_JEDNA.md', '# jeszcze\n'); g('add', '-A'); g('commit', '-qm', 'trzy');
  t('--sprawdz przy ODSTAJACYM spisie: rc=1', uruchom('--sprawdz'), 1);

  fs.rmSync(baza, { recursive: true, force: true });
  const o = spr.filter(x => !x).length;
  console.log(`  zmierzone: zdanych ${spr.length - o} · oblanych ${o}`);
  if (o === 0) { console.log('✓ SPIS CIAŁA ŻYWY: rodzaje zbierane z ciała, czytnik świeżości wykrywa odstawanie.'); process.exit(0); }
  console.log('✗ TOR OBLANY'); process.exit(1);
}

const kat = process.cwd();
const nowy = zbuduj(kat);

if (SPRAWDZ) {
  if (!fs.existsSync(path.join(kat, PLIK))) {
    console.log(`  ✗ SPIS NIE ISTNIEJE: ${PLIK} — brak pliku to nie jest świeżość (#52).`);
    console.log('    -> node spis_ciala.js');
    process.exit(1);
  }
  const stary = fs.readFileSync(path.join(kat, PLIK), 'utf8');
  if (stary === nowy) { console.log(`  OK spis ciała: ${PLIK} zgodny z ciałem.`); process.exit(0); }
  const a = stary.split('\n'), b = nowy.split('\n');
  let n = 0; for (let i = 0; i < Math.max(a.length, b.length); i++) if (a[i] !== b[i]) n++;
  console.log(`  ✗ SPIS ODSTAJE od ciała: linii różnych ${n} (ciało się zmieniło, spis nie).`);
  console.log('    -> node spis_ciala.js   (regeneruj; nie poprawiaj ręką)');
  process.exit(1);
}

fs.writeFileSync(path.join(kat, PLIK), nowy);
const poz = (nowy.match(/^- `/gm) || []).length;
console.log(`  ✓ ${PLIK} zapisany — pozycji ${poz}.`);
