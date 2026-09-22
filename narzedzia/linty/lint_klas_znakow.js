#!/usr/bin/env node
/* ── LINT KLAS ZNAKÓW (03.09.2026) — mechanizm M dla blizny #80 ──
 *
 * POWÓD (zmierzone 03.09): `grep -rniE "g[lł]adysiak"` → 1 trafienie, `grep -rni "adysiak"` → 8,
 * ten sam korpus. Instancja podała „tego nie ma w żadnym rejestrze" jako pomiar. Zmierzone przy
 * budowie tego lintu: pod `C.UTF-8` klasa działa (2), pod `LC_ALL=C` łapie 1 — wada jest ZALEŻNA
 * OD LOCALE: w C/POSIX klasa `[...]` rozpada się na BAJTY, a `ł` to dwa bajty, więc `[lł]` nigdy
 * nie dopasuje `ł` jako jednego znaku. Windows Git Bash i skrypty bez ustawionego LANG idą tą drogą,
 * a grep NIE ALARMUJE — zero wygląda jak wynik.
 *
 * CO ROBI: skanuje pliki .sh po liniach z grep/sed/awk i szuka klasy
 * `[...]` zawierającej znak spoza ASCII. Każde trafienie: plik:linia + fragment. rc=1 gdy są.
 * JS WYŁĄCZONY JAWNIE: regex JS jest Unicode-aware na stringach — `/[ąę]/` działa niezależnie od locale.
 * Alarm na JS byłby szerszy niż sygnał (#56): zmierzone 8 klas w JS, wszystkie poprawne.
 *
 * DŁUG ZASTANY przy narodzinach: 9 trafień w bashu (gotowosc.sh, straz_kryteriow.sh, straz_prerejestrow.sh,
 * publikuj.sh). Straż lintów mierzy WZROST względem HEAD, nie stan — dług nazwany, nie ukryty.
 * Naprawa każdego: trzon ASCII (`adysiak`), alternatywa `(l|ł)`, albo `LC_ALL=C.UTF-8` jawnie przy komendzie.
 *
 * UŻYCIE:  node narzedzia/linty/lint_klas_znakow.js           (skan; rc=1 gdy są trafienia)
 *          node narzedzia/linty/lint_klas_znakow.js --liczba  (sam licznik — dla straz_lintow)
 *          node narzedzia/linty/lint_klas_znakow.js --test    (tor +/− — lint musi umieć NIE przejść)
 */
'use strict';
const fs = require('fs'), path = require('path');
const ROOT = process.env.LKZ_ROOT || path.resolve(__dirname, '..', '..');
const POMIN = new Set(['.git', 'node_modules', 'ephe', 'keep_import', 'archiwum']);
const KONTEKST = /\b(grep|sed|awk|egrep)\b/;
const KLASA_NIEASCII = /\[[^\]\n]*[^\x00-\x7F][^\]\n]*\]/g;
// ZWOLNIENIE (03.09.2026, spłata długu #80): locale ustalone JAWNIE w tej samej linii —
// `LC_ALL=C.UTF-8 grep …` albo `LC_ALL="$UTF" grep …`. Wtedy klasa nie jest zależna od locale,
// a to jedna z trzech dróg, które lint sam wskazuje w komunikacie. Zwolnienie jest PER LINIA,
// nigdy na cały plik: `LC_ALL` przy jednej komendzie nie usprawiedliwia klasy w drugiej (tor tego pilnuje).
const LOCALE_JAWNE = /LC_ALL=/;

function pliki(d, acc = []) {
  for (const e of fs.readdirSync(d, { withFileTypes: true })) {
    if (POMIN.has(e.name)) continue;
    const p = path.join(d, e.name);
    if (e.isDirectory()) pliki(p, acc); else if (/\.sh$/.test(e.name) || e.name === 'pre-commit') acc.push(p);
  }
  return acc;
}
function skan() {
  const traf = [];
  for (const f of pliki(ROOT)) {
    const linie = fs.readFileSync(f, 'utf8').split('\n');
    linie.forEach((l, i) => {
      if (l.trim().startsWith('#') || !KONTEKST.test(l) || LOCALE_JAWNE.test(l)) return;
      const m = l.match(KLASA_NIEASCII);
      if (m) traf.push({ f: path.relative(ROOT, f), n: i + 1, k: m[0].slice(0, 40) });
    });
  }
  return traf;
}
function raport(t) {
  console.log('╔═══ LINT KLAS ZNAKÓW (#80) — klasa [...] z literą spoza ASCII w grep/sed/awk ═══╗');
  for (const x of t) console.log(`  ✗ ${x.f}:${x.n} → ${x.k}   (pod locale C klasa rozpada się na bajty)`);
  console.log(t.length ? `  ✗ TRAFIEŃ: ${t.length} — trzon ASCII, alternatywa (l|ł) albo jawne LC_ALL=C.UTF-8` : '  ✓ ZERO klas z literą spoza ASCII w bashu bez jawnego locale.');
  return t.length ? 1 : 0;
}
function tor() {
  const os = require('os'); const T = fs.mkdtempSync(path.join(os.tmpdir(), 'lkz-'));
  const w = (n, s) => fs.writeFileSync(path.join(T, n), s);
  const bieg = () => { const r = require('child_process').spawnSync(process.execPath, [__filename], { encoding: 'utf8', env: { ...process.env, LKZ_ROOT: T } }); return { rc: r.status, out: r.stdout }; };
  const zle = [];
  // (−) klasa z ł w grep → 1 trafienie, rc=1, plik:linia
  w('a.sh', '#!/bin/bash\ngrep -rniE "g[lł]adysiak" .\n'); let r = bieg();
  if (r.rc !== 1 || !/a\.sh:2/.test(r.out)) zle.push(`klasa-z-l-nie-zlapana(rc=${r.rc})`);
  // (+) trzon ASCII → 0, rc=0
  w('a.sh', '#!/bin/bash\ngrep -rni "adysiak" .\n'); r = bieg();
  if (r.rc !== 0 || !/ZERO/.test(r.out)) zle.push('trzon-ascii-alarmuje');
  // (+) alternatywa (l|ł) bez klasy → 0
  w('a.sh', '#!/bin/bash\ngrep -rniE "g(l|ł)adysiak" .\n'); r = bieg();
  if (r.rc !== 0) zle.push('alternatywa-alarmuje');
  // (+) ta sama klasa w KOMENTARZU → 0 (komentarz nie wykonuje grepa)
  w('a.sh', '#!/bin/bash\n# grep -E "g[lł]adysiak" to zła praktyka\n'); r = bieg();
  if (r.rc !== 0) zle.push('komentarz-alarmuje');
  // (+) klasa spoza ASCII w JS → poza zakresem (JS Unicode-aware), 0
  w('b.js', 'const x = /[ąę]/.test(s);\n'); w('a.sh', '#!/bin/bash\ntrue\n'); r = bieg();
  if (r.rc !== 0) zle.push('js-alarmuje-mimo-wylaczenia');
  // (−) sed z klasą `[ —]` (em dash) → 1
  w('a.sh', '#!/bin/bash\necho x | sed -E "s/[ —]//"\n'); r = bieg();
  if (r.rc !== 1) zle.push('em-dash-w-klasie-nie-zlapany');
  // (+) LOCALE USTALONE JAWNIE → zwolnienie (03.09, spłata długu #80): klasa nie jest już
  //     zależna od locale, bo skrypt je ustala. To jedna z trzech dróg, które lint sam wskazuje.
  w('a.sh', '#!/bin/bash\nLC_ALL=C.UTF-8 grep -rniE "g[lł]adysiak" .\n'); r = bieg();
  if (r.rc !== 0) zle.push('LC_ALL-w-linii-nie-zwalnia');
  w('a.sh', '#!/bin/bash\nUTF=C.UTF-8\nLC_ALL="$UTF" grep -E "[ąę]" x\n'); r = bieg();
  if (r.rc !== 0) zle.push('LC_ALL-przez-zmienna-nie-zwalnia');
  // (−) ZWOLNIENIE NIE MOŻE BYĆ NA CAŁY PLIK: LC_ALL w JEDNEJ linii nie usprawiedliwia INNEJ
  w('a.sh', '#!/bin/bash\nLC_ALL=C.UTF-8 grep -E "[ąę]" x\ngrep -E "g[lł]adysiak" y\n'); r = bieg();
  if (r.rc !== 1 || !/a\.sh:3/.test(r.out)) zle.push(`zwolnienie-wycieka-na-caly-plik(rc=${r.rc})`);
  fs.rmSync(T, { recursive: true, force: true });
  console.log('╔═══ LINT KLAS ZNAKÓW — AUTOTEST ═══╗');
  if (zle.length) { console.log('✗ TOR OBLANY: ' + zle.join(' · ')); process.exit(1); }
  console.log('✓ TOR PRZESZEDŁ — łapie klasę z literą spoza ASCII w bashu, milczy na trzonie, alternatywie, komentarzu i JS.'); process.exit(0);
}
const a = process.argv.slice(2);
if (a[0] === '--test') tor();
else if (a[0] === '--liczba') { console.log(skan().length); process.exit(0); }
else process.exit(raport(skan()));
