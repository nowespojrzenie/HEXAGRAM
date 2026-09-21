#!/usr/bin/env node
/* KRONOS · INWENTARZ PRZEDPRODUKCYJNY (03.09.2026, MOSTY #35 → #36)
 *
 * PYTANIE: czy ta praca ISTNIEJE, zanim ją DODASZ. Lustro `przed_cieciem.js` (#21), który pyta:
 * czy ten plik ŻYJE, zanim go USUNIESZ. Ta sama materia (git, księgi, rejestry), pytanie
 * odwrócone — i ODWROTNE OBCIĄŻENIE BŁĘDU (słowo twórcy 03.09):
 *   przed_cieciem myli się w stronę ŻYCIA   (fałszywe ŻYWY kosztuje rozmowę, fałszywe KANDYDAT — treść);
 *   inwentarz    myli się w stronę NIE ISTNIEJE (fałszywe ISTNIEJE blokuje pracę potrzebną PO CICHU,
 *                fałszywe NIE kosztuje GŁOŚNY duplikat, który każda straż zobaczy).
 * Dwa przeciwne obciążenia nie mieszczą się w jednym przyrządzie pod flagą (#56) — stąd osobny plik.
 *
 * RODOWÓD (02.09): instancja z WAŻNYM żetonem trzykrotnie zameldowała jako otwarte to, co zamknięto
 * — raz własną ręką w turze przerwanej. Żeton mierzy CZAS stanu (--porownaj), ten przyrząd
 * mierzy ISTNIENIE pracy. Zmierzone ręcznie 03.09, zanim przyrząd powstał: T1 „preflight" →
 * CZĘŚCIOWO (commit + rejestr, brak kodu) · T2 „porownaj" → NIE ISTNIEJE mimo 4 commitów
 * z tym słowem (inna funkcja o tej samej nazwie) — dlatego ISTNIEJE wymaga commita I pliku.
 *
 * WEJŚCIE: 1–3 frazy (nazwa przyrządu · słowo kluczowe · numer blizny). Fraza, nie ścieżka —
 * praca, której się szuka, nie ma jeszcze pliku.
 *
 * SZEŚĆ ŹRÓDEŁ, każde z WŁASNYM rc i WŁASNYM licznikiem (zero bez rc nie jest wynikiem, #18):
 *   1 COMMITY   git log --all --oneline, filtr po TRZONIE ASCII w JS (#80: żółwik = zolwik)
 *   2 PLIKI     git ls-files (ścieżka zawiera frazę)
 *   3 NARZĘDZIA nazwy w narzedzia/** (podzbiór 2 — tu rodzą się przyrządy)
 *   4 MOSTY     kanon/ksiegi/MOSTY.md
 *   5 KOLEJKA   kanon/ksiegi/KOLEJKA_M.md
 *   6 TASKI     prywatne/TASKI.md z rozróżnieniem zamknięte [x]/☑ · otwarte [ ]/□ · wzmianki
 *
 * WERDYKT (na frazę, drukowany — przyrząd ŚWIECI, NIE KROI; rc procesu zawsze 0 poza błędem użycia):
 *   NIE ZMIERZONO — którekolwiek źródło rc≠0. Nigdy nie jest „NIE ISTNIEJE": brak pomiaru ≠ brak rzeczy.
 *   ISTNIEJE      — commit I plik śledzony (oba naraz; sam commit to za mało — precedens „porownaj").
 *   CZĘŚCIOWO     — cokolwiek >0, ale nie oba: tylko rejestr/most/kolejka · tylko commit · tylko plik.
 *   NIE ISTNIEJE  — 0 we wszystkich sześciu i wszystkie rc=0.
 * Instancja cytuje werdykt w meldunku PRZED pierwszą linią cięcia (rytuał §6 pkt 1).
 *
 * UŻYCIE:  node narzedzia/przyrzady/inwentarz.js "<fraza>" ["<fraza2>" ["<fraza3>"]]
 *          node narzedzia/przyrzady/inwentarz.js --test
 * Środowisko: INW_ROOT — korzeń do zmierzenia (domyślnie repo, w którym leży ten plik; tor używa mktemp).
 */
'use strict';
const cp = require('child_process'), fs = require('fs'), path = require('path');
const ROOT = process.env.INW_ROOT || path.resolve(__dirname, '..', '..');

function git(args) {                       // → { rc, out }
  const r = cp.spawnSync('git', args, { cwd: ROOT, encoding: 'utf8' });
  return { rc: r.error ? 127 : r.status, out: r.stdout || '' };
}
function plik(rel) {                       // → { rc, linie }
  try { return { rc: 0, linie: fs.readFileSync(path.join(ROOT, rel), 'utf8').split('\n') }; }
  catch { return { rc: 2, linie: [] }; }
}
// TRZON ASCII PO OBU STRONACH (03.09.2026, blizna #80): „Gladysiak" i „Gładysiak" to to samo słowo
// dla pytania o istnienie pracy; porównanie wrażliwe na diakrytyk dawało 0 trafień = fałszywe
// NIE ISTNIEJE. Normalizacja NFD + zdjęcie znaków łączących + ł→l (ł nie rozkłada się w NFD).
const trzon = x => x.normalize('NFD').replace(/[\u0300-\u036f]/g, '').replace(/ł/g, 'l').replace(/Ł/g, 'L').toLowerCase();
const ma = (s, f) => trzon(s).includes(trzon(f));

function zrodla(fraza) {
  const z = [];
  // commity: cały log raz, filtr po trzonie w JS — `git --grep` nie umie normalizować korpusu (#80)
  const c = git(['log', '--all', '--oneline']);
  const commity = c.out.split('\n').filter(Boolean).filter(l => ma(l, fraza));
  z.push({ nazwa: 'COMMITY', rc: c.rc, n: commity.length, wiersze: commity.map(l => l.slice(0, 90)) });
  const l = git(['ls-files']);
  const pliki = l.out.split('\n').filter(Boolean).filter(p => ma(p, fraza));
  z.push({ nazwa: 'PLIKI', rc: l.rc, n: pliki.length, wiersze: pliki });
  const narz = pliki.filter(p => p.startsWith('narzedzia/') && ma(path.basename(p), fraza));
  z.push({ nazwa: 'NARZĘDZIA', rc: l.rc, n: narz.length, wiersze: narz });
  for (const [nazwa, rel] of [['MOSTY', 'kanon/ksiegi/MOSTY.md'], ['KOLEJKA', 'kanon/ksiegi/KOLEJKA_M.md']]) {
    const p = plik(rel), w = p.linie.filter(x => ma(x, fraza));
    z.push({ nazwa, rc: p.rc, n: w.length, wiersze: w.map(x => x.trim().slice(0, 90)) });
  }
  const t = plik('prywatne/TASKI.md'), tw = t.linie.filter(x => ma(x, fraza));
  const zamk = tw.filter(x => /\[x\]|☑/i.test(x)), otw = tw.filter(x => /\[ \]|□/.test(x));
  z.push({ nazwa: 'TASKI', rc: t.rc, n: tw.length, wiersze: tw.map(x => x.trim().slice(0, 90)),
           zamkniete: zamk.length, otwarte: otw.length, wzmianki: tw.length - zamk.length - otw.length });
  return z;
}

// OBCIĄŻENIE KU „NIE ISTNIEJE": ISTNIEJE wymaga commita I pliku. Mutacja `inwentarz-istnieje-bez-pliku`
// zdejmuje drugi warunek i tor (⊙⊙) oblewa — precedens „porownaj": 4 commity, 0 plików, NIE ISTNIEJE.
function werdykt(z) {
  const padle = z.filter(s => s.rc !== 0).map(s => `${s.nazwa}(rc=${s.rc})`);
  if (padle.length) return ['NIE ZMIERZONO', `źródło padło: ${padle.join(' ')} — to nie jest „nie ma", to „nie wiem"`];
  const n = Object.fromEntries(z.map(s => [s.nazwa, s.n]));
  if (n.COMMITY > 0 && n.PLIKI > 0) return ['ISTNIEJE', `commit i plik śledzony (${n.COMMITY} commit(ów) · ${n.PLIKI} plik(ów))`];
  const suma = z.reduce((a, s) => a + s.n, 0);
  if (suma === 0) return ['NIE ISTNIEJE', 'zero we wszystkich sześciu źródłach, wszystkie rc=0'];
  const gdzie = z.filter(s => s.n > 0).map(s => `${s.nazwa}:${s.n}`).join(' ');
  return ['CZĘŚCIOWO', `ślad bez kompletu (${gdzie}) — commit bez pliku, plik bez commita albo sam rejestr`];
}

function karta(fraza) {
  const z = zrodla(fraza), [w, dlaczego] = werdykt(z);
  console.log(`▤ INWENTARZ · „${fraza}"  (⏱ ${new Date().toISOString().slice(0, 16).replace('T', ' ')} UTC · korzeń: ${ROOT})`);
  for (const s of z) {
    const t = s.nazwa === 'TASKI' && s.n ? ` (zamknięte ${s.zamkniete} · otwarte ${s.otwarte} · wzmianki ${s.wzmianki})` : '';
    console.log(`   ${s.rc === 0 ? '·' : '✗'} ${s.nazwa.padEnd(9)} rc=${s.rc}  n=${s.n}${t}`);
    for (const x of s.wiersze.slice(0, 3)) console.log(`        ${x}`);
    if (s.wiersze.length > 3) console.log(`        … +${s.wiersze.length - 3}`);
  }
  console.log(`   ⇒ ${w} — ${dlaczego}`);
  console.log(`   sprawdzono ${z.length} źródeł · przyrząd świeci, nie kroi — werdykt cytuj PRZED pierwszą linią cięcia`);
  return w;
}

// ── TOR (#38) — cztery strony + obciążenie. Fikstura: repo w mktemp, nigdy żywe ciało (#54). ──
function tor() {
  const os = require('os');
  const T = fs.mkdtempSync(path.join(os.tmpdir(), 'inw-'));
  const R = path.join(T, 'r'); fs.mkdirSync(R);
  const sh = (a) => cp.spawnSync('git', a, { cwd: R, encoding: 'utf8', env: { ...process.env,
    GIT_AUTHOR_NAME: 'T', GIT_AUTHOR_EMAIL: 't@t', GIT_COMMITTER_NAME: 'T', GIT_COMMITTER_EMAIL: 't@t' } });
  sh(['init', '-q']);
  for (const d of ['narzedzia/przyrzady', 'kanon/ksiegi', 'prywatne']) fs.mkdirSync(path.join(R, d), { recursive: true });
  fs.writeFileSync(path.join(R, 'narzedzia/przyrzady/widmo.js'), '// widmo\n');
  fs.writeFileSync(path.join(R, 'kanon/ksiegi/MOSTY.md'), '## most\n\nzjawa — kandydat, nazwana, nie zbudowana\n');
  fs.writeFileSync(path.join(R, 'kanon/ksiegi/KOLEJKA_M.md'), '# kolejka\n');
  fs.writeFileSync(path.join(R, 'prywatne/TASKI.md'), '- [ ] zjawa do zbudowania\n');
  sh(['add', '-A']); sh(['commit', '-q', '-m', 'dodano widmo.js']);
  sh(['commit', '-q', '--allow-empty', '-m', 'wzmianka o upior — sama nazwa w commicie, bez pliku']);
  const N = path.join(T, 'niegit'); fs.mkdirSync(N);         // (⊗) księgi są, gita nie ma
  for (const d of ['kanon/ksiegi', 'prywatne']) fs.mkdirSync(path.join(N, d), { recursive: true });
  for (const f of ['kanon/ksiegi/MOSTY.md', 'kanon/ksiegi/KOLEJKA_M.md', 'prywatne/TASKI.md']) fs.writeFileSync(path.join(N, f), '\n');

  const uruchom = (root, fraza) => {
    const r = cp.spawnSync(process.execPath, [__filename, fraza], { encoding: 'utf8', env: { ...process.env, INW_ROOT: root } });
    const m = (r.stdout || '').match(/⇒ (NIE ZMIERZONO|ISTNIEJE|CZĘŚCIOWO|NIE ISTNIEJE)/);
    return { w: m ? m[1] : `BRAK(rc=${r.status})`, rc: r.status, out: r.stdout || '' };
  };
  const A = uruchom(R, 'widmo');      // (+)  commit + plik → ISTNIEJE
  const B = uruchom(R, 'nicniema');   // (−)  nic nigdzie → NIE ISTNIEJE
  const C = uruchom(R, 'zjawa');      // (⊙)  tylko MOSTY + TASKI otwarte → CZĘŚCIOWO
  const D = uruchom(R, 'upior');      // (⊙⊙) commit bez pliku → CZĘŚCIOWO, NIGDY ISTNIEJE (obciążenie)
  const E = uruchom(N, 'widmo');      // (⊗)  git padł → NIE ZMIERZONO, nigdy NIE ISTNIEJE
  // (ł) BLIZNA #80 — inny diakrytyk we frazie niż w korpusie nie może dać NIE ISTNIEJE:
  //     plik `zolwik.js` + commit „żółwik" · fraza „żółwik" I fraza „zolwik" → obie ISTNIEJE
  fs.writeFileSync(path.join(R, 'narzedzia/przyrzady/zolwik.js'), '// zolw\n');
  sh(['add', '-A']); sh(['commit', '-q', '-m', 'żółwik dodany']);
  const L1 = uruchom(R, 'żółwik'), L2 = uruchom(R, 'zolwik');
  const B_rc0 = /rc=[1-9]/.test(B.out) ? 0 : 1;
  const C_otw = /otwarte 1/.test(C.out) ? 1 : 0;
  fs.rmSync(T, { recursive: true, force: true });
  console.log('╔═══ INWENTARZ — AUTOTEST (#38) ═══╗');
  console.log(`── TEST +  (commit + plik → ISTNIEJE):            ${A.w}  (oczekiwane ISTNIEJE)`);
  console.log(`── TEST −  (nic nigdzie → NIE ISTNIEJE):           ${B.w} · wszystkie rc=0: ${B_rc0}  (oczekiwane NIE ISTNIEJE · 1)`);
  console.log(`── TEST ⊙  (tylko most + TASKI [ ] → CZĘŚCIOWO):   ${C.w} · widzi otwartą kratkę: ${C_otw}  (oczekiwane CZĘŚCIOWO · 1)`);
  console.log(`── TEST ⊙⊙ (commit bez pliku → CZĘŚCIOWO):         ${D.w}  (oczekiwane CZĘŚCIOWO — obciążenie ku NIE)`);
  console.log(`── TEST ⊗  (git padł → NIE ZMIERZONO):             ${E.w}  (oczekiwane NIE ZMIERZONO)`);
  console.log(`── TEST ł  (żółwik ↔ zolwik, #80):                ${L1.w} / ${L2.w}  (oczekiwane ISTNIEJE / ISTNIEJE)`);
  const ok = A.w === 'ISTNIEJE' && B.w === 'NIE ISTNIEJE' && B_rc0 === 1 && C.w === 'CZĘŚCIOWO' && C_otw === 1
          && D.w === 'CZĘŚCIOWO' && E.w === 'NIE ZMIERZONO' && L1.w === 'ISTNIEJE' && L2.w === 'ISTNIEJE' && [A, B, C, D, E, L1, L2].every(x => x.rc === 0);
  if (ok) { console.log('✓ PRZYRZĄD ŻYWY (6/6): rozpoznaje pracę istniejącą, nie wymyśla nieistniejącej, odróżnia ślad od kompletu,\n  commit bez pliku od pracy, a brak pomiaru od braku rzeczy — i nigdy nie kroi (rc=0).'); process.exit(0); }
  console.log(`✗ PRZYRZĄD MARTWY: A=${A.w} B=${B.w}/${B_rc0} C=${C.w}/${C_otw} D=${D.w} E=${E.w} ł=${L1.w}/${L2.w} rc=${[A, B, C, D, E, L1, L2].map(x => x.rc).join(',')}`);
  process.exit(1);
}

const a = process.argv.slice(2);
if (a[0] === '--test') tor();
else if (!a.length || a.length > 3) { console.error('użycie: node inwentarz.js "<fraza>" [fraza2] [fraza3]  |  --test'); process.exit(2); }
else { for (const f of a) karta(f); process.exit(0); }
