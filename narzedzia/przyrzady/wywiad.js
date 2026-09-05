#!/usr/bin/env node
/* KRONOS · WYWIAD PODŁUŻNY — czytnik rejestru `prywatne/PYTANIA_dnia.md` (03.09.2026, zlecenie twórcy)
 *
 * PO CO: twórca dostaje JEDNO pytanie o codzienność na turę; odpowiedzi kumulują się w rejestrze,
 * z którego robi się przegląd tygodniowy/miesięczny i z którego rosną blizny z życia (03.09: 6 na 78).
 * Diagnoza: dzwonki żyły w telefonie, czytników w repo 0, kryterium awarii z DZWONKI §3 przekroczone
 * 3× i nigdy nie policzone. Mechanizm ma stać po stronie instancji — ten plik jest tym mechanizmem.
 * Skill: `skills/ai-interview-longitudinal/SKILL.md` (reguła 3: kolumna `rodzaj` steruje hipotezą).
 *
 * UŻYCIE:
 *   node narzedzia/przyrzady/wywiad.js                      → 1–2 pytania najdłużej bez odpowiedzi
 *   node narzedzia/przyrzady/wywiad.js --wstan              → to samo, ≤ 6 linii (budżet R0), rc nigdy nie wywraca wstania
 *   node narzedzia/przyrzady/wywiad.js --zadane <id>        → stempluje „ostatnio zadane" (instancja, gdy NAPRAWDĘ zadała)
 *   node narzedzia/przyrzady/wywiad.js --odpowiedz <id> "<jedno zdanie>" [--kandydat-bledy]
 *                                                            → stempluje datę odpowiedzi (ZEGAR, nie argument) + wiersz w logu
 *   node narzedzia/przyrzady/wywiad.js --przeglad tydzien|miesiac
 *                                                            → surowe zestawienie po obszarze, BEZ interpretacji; miesiąc + obszary bez odpowiedzi
 *   node narzedzia/przyrzady/wywiad.js --test
 *
 * KODY: 0 = jest co pytać/zestawić · 2 = PROTEZA (rejestr pusty ALBO 14 dni bez żadnej odpowiedzi — przyrząd
 *       melduje SAM SIEBIE do reformy; to DZWONKI §3 jako licznik, nie zdanie) · 3 = błąd użycia/id.
 * CISZA NIE JEST SUKCESEM (#39): pusty rejestr = komunikat + rc=2, nigdy rc=0 bez słowa.
 * Środowisko: WYW_PLIK (ścieżka rejestru; tor używa mktemp) · WYW_DZIS (data ISO do toru; produkcja: zegar).
 */
'use strict';
const fs = require('fs'), path = require('path');
const PLIK = process.env.WYW_PLIK || path.resolve(__dirname, '..', '..', 'prywatne', 'PYTANIA_dnia.md');
const DZIS = process.env.WYW_DZIS || new Date().toISOString().slice(0, 10);
const PROG_PROTEZY = 14;                     // dni bez ŻADNEJ odpowiedzi → przyrząd melduje sam siebie
const OBSZARY = ['pasieka', 'dom', 'studio', 'ciało', 'system'];

const dni = (a, b) => Math.round((Date.parse(b) - Date.parse(a)) / 86400000);
const czytaj = () => { try { return fs.readFileSync(PLIK, 'utf8'); } catch { return null; } };

function parsuj(t) {
  const linie = t.split('\n');
  const pyt = [], log = [];
  let wLogu = false;
  linie.forEach((l, i) => {
    if (/^## ODPOWIEDZI/.test(l)) { wLogu = true; return; }
    const k = l.split('|').map(x => x.trim());
    if (k.length < 7 || k[1] === 'id' || k[1] === 'data' || /^-+$/.test(k[1])) return;
    if (!wLogu && k.length >= 7) pyt.push({ i, id: k[1], obszar: k[2], rodzaj: k[3], pytanie: k[4], zadane: k[5], odp: k[6] });
    else if (wLogu) log.push({ i, data: k[1], id: k[2], obszar: k[3], zdanie: k[4], kandydat: /kandydat BLEDY/.test(k[5] || '') });
  });
  const narodz = (t.match(/_narodziny:\s*(\d{4}-\d{2}-\d{2})_/) || [])[1] || null;
  return { linie, pyt, log, narodz };
}

function dataOdp(p) { const m = p.odp.match(/\d{4}-\d{2}-\d{2}/); return m ? m[0] : null; }

// najdłużej bez odpowiedzi: nigdy > najstarsza data; remis → dawniej zadane; potem kolejność w pliku
function kolejka(r) {
  return [...r.pyt].sort((a, b) => {
    const da = dataOdp(a), db = dataOdp(b);
    if (!da && db) return -1; if (da && !db) return 1;
    if (da && db && da !== db) return da < db ? -1 : 1;
    const za = a.zadane.match(/\d{4}-\d{2}-\d{2}/), zb = b.zadane.match(/\d{4}-\d{2}-\d{2}/);
    if (!za && zb) return -1; if (za && !zb) return 1;
    if (za && zb && za[0] !== zb[0]) return za[0] < zb[0] ? -1 : 1;
    return a.i - b.i;
  });
}

function proteza(r) {                        // → { martwy, dniCiszy, od }
  const daty = r.log.map(x => x.data).concat(r.pyt.map(dataOdp).filter(Boolean)).sort();
  const ost = daty.length ? daty[daty.length - 1] : null;
  const od = ost || r.narodz;
  if (!od) return { martwy: true, dniCiszy: null, od: null, zrodlo: null };
  const d = dni(od, DZIS);
  return { martwy: d >= PROG_PROTEZY, dniCiszy: d, od, zrodlo: ost ? 'ostatnia odpowiedź' : 'narodziny rejestru, żadnej odpowiedzi' };
}

function pytaj(wstan) {
  const t = czytaj();
  if (t === null) { console.log(`▤ WYWIAD: brak rejestru ${path.relative(process.cwd(), PLIK)} — nie ma czego pytać (rc=2, nie sukces)`); return 2; }
  const r = parsuj(t);
  if (!r.pyt.length) { console.log('▤ WYWIAD: rejestr bez ani jednego pytania — PROTEZA: zasiej pytania albo skompostuj rejestr (rc=2)'); return 2; }
  const pr = proteza(r);
  const k = kolejka(r).slice(0, wstan ? 1 : 2);
  const bez = r.pyt.filter(p => !dataOdp(p)).length;
  console.log(`▤ WYWIAD (⏱ ${DZIS}) · pytań ${r.pyt.length} · bez odpowiedzi ${bez} · odpowiedzi w logu ${r.log.length}${pr.od ? ` · ${pr.zrodlo} ${pr.od} (${pr.dniCiszy} dni temu)` : ''}`);
  for (const p of k) {
    const reg = p.rodzaj === 'wewnętrzne' ? 'WEWNĘTRZNE — hipoteza ZAKAZANA' : 'operacyjne — hipoteza wolna, z liczbą pewności';
    console.log(`   ${p.id} · ${p.obszar} · ${reg}`);
    console.log(`   → ${p.pytanie}`);
  }
  if (pr.martwy) {
    console.log(`   ✗ PROTEZA: ${pr.dniCiszy === null ? 'żadnej daty w rejestrze' : `${pr.dniCiszy} dni bez ani jednej odpowiedzi (próg ${PROG_PROTEZY})`} — przyrząd melduje SAM SIEBIE do reformy (DZWONKI §3 jako licznik). Nie pytaj więcej tych samych pytań; zapytaj, czemu nikt nie odpowiada.`);
    return 2;
  }
  if (!wstan) console.log('   (jedno pytanie na turę, we własnym bloku PRZED ⟐ META; odpowiedź stempluje instancja: --odpowiedz <id> "<zdanie>")');
  return 0;
}

function zapisz(r, zmieniacz) {
  const linie = zmieniacz(r.linie.slice());
  fs.writeFileSync(PLIK, linie.join('\n').replace(/\n*$/, '\n'), 'utf8');   // zawsze JEDEN końcowy \n — rejestr jest dopisywany, sklejony wiersz = zgubiona odpowiedź
}

function zadane(id) {
  const t = czytaj(); if (t === null) { console.log('✗ brak rejestru'); return 3; }
  const r = parsuj(t); const p = r.pyt.find(x => x.id === id);
  if (!p) { console.log(`✗ nie ma pytania o id ${id}`); return 3; }
  zapisz(r, L => { const k = L[p.i].split('|'); k[5] = ` ${DZIS} `; L[p.i] = k.join('|'); return L; });
  console.log(`   ✓ ${id} zadane ${DZIS}`); return 0;
}

function odpowiedz(id, zdanie, kandydat) {
  const t = czytaj(); if (t === null) { console.log('✗ brak rejestru'); return 3; }
  if (!zdanie || zdanie.length > 240) { console.log('✗ odpowiedź: jedno zdanie, 1–240 znaków — pełna treść idzie do ZAPISY_eter'); return 3; }
  const r = parsuj(t); const p = r.pyt.find(x => x.id === id);
  if (!p) { console.log(`✗ nie ma pytania o id ${id}`); return 3; }
  const czyste = zdanie.replace(/\|/g, '/').replace(/\s+/g, ' ').trim();
  zapisz(r, L => {
    const k = L[p.i].split('|'); k[6] = ` ${DZIS} · ${czyste} `; L[p.i] = k.join('|');
    let j = L.findIndex(l => /^## ODPOWIEDZI/.test(l));
    if (j < 0) { L.push('', '## ODPOWIEDZI (log, append-only — data + jedno zdanie; pełna treść w ZAPISY_eter)', '', '| data | id | obszar | zdanie | znacznik |', '|---|---|---|---|---|'); j = L.length; }
    else { j = L.length; while (j > 0 && L[j - 1].trim() === '') j--; }
    L.splice(j, 0, `| ${DZIS} | ${id} | ${p.obszar} | ${czyste} | ${kandydat ? '→ kandydat BLEDY' : ''} |`);
    return L;
  });
  console.log(`   ✓ ${id} · ${p.obszar} · ${DZIS} · zapisane${kandydat ? ' · → kandydat BLEDY (rozstrzyga twórca)' : ''}`); return 0;
}

function przeglad(okno) {
  const t = czytaj(); if (t === null) { console.log('✗ brak rejestru (rc=2)'); return 2; }
  const r = parsuj(t); const n = okno === 'miesiac' ? 30 : 7;
  const od = new Date(Date.parse(DZIS) - (n - 1) * 86400000).toISOString().slice(0, 10);
  const w = r.log.filter(x => x.data >= od && x.data <= DZIS);
  console.log(`▤ PRZEGLĄD ${okno.toUpperCase()} (${od} → ${DZIS}) · odpowiedzi ${w.length} · surowe zestawienie, bez interpretacji`);
  if (!w.length) { console.log(`   ✗ ZERO odpowiedzi w oknie ${n} dni — cisza jest daną: rejestr nie pracuje (rc=2)`); return 2; }
  const gr = {};
  for (const x of w) (gr[x.obszar] = gr[x.obszar] || []).push(x);
  for (const o of OBSZARY.concat(Object.keys(gr).filter(o => !OBSZARY.includes(o)))) {
    if (!gr[o]) { if (okno === 'miesiac') console.log(`   ${o}: — (bez ani jednej odpowiedzi w 30 dni)`); continue; }
    console.log(`   ${o} (${gr[o].length}):`);
    for (const x of gr[o]) console.log(`      ${x.data} · ${x.id} · ${x.zdanie}${x.kandydat ? '   → kandydat BLEDY' : ''}`);
  }
  const kand = w.filter(x => x.kandydat).length;
  if (kand) console.log(`   → kandydatów do BLEDY: ${kand} — awansuje twórca, nie instancja`);
  return 0;
}

// ── TOR (#38): para na każdą stronę, fikstura w mktemp — nigdy żywy rejestr (#50) ──
function tor() {
  const os = require('os'), cp = require('child_process');
  const T = fs.mkdtempSync(path.join(os.tmpdir(), 'wyw-'));
  const F = path.join(T, 'r.md');
  const bieg = (args, dzis) => { const r = cp.spawnSync(process.execPath, [__filename, ...args], { encoding: 'utf8', env: { ...process.env, WYW_PLIK: F, WYW_DZIS: dzis } }); return { rc: r.status, out: (r.stdout || '') + (r.stderr || '') }; };
  const glowa = (narodz) => `# t\n_narodziny: ${narodz}_\n\n| id | obszar | rodzaj | pytanie | ostatnio zadane | ostatnia odpowiedź (data) |\n|---|---|---|---|---|---|\n`;
  const zle = [];
  // (+) pytanie przeterminowane: dwa pytania, jedno z odpowiedzią 2026-08-01, drugie nigdy → pierwsze w kolejce to NIGDY, rc=0 (przed progiem protezy)
  fs.writeFileSync(F, glowa('2026-08-20') + '| A1 | dom | operacyjne | pytanie A | — | 2026-08-25 · coś |\n| B1 | ciało | wewnętrzne | pytanie B | — | — |\n');
  let r = bieg([], '2026-08-30');
  if (r.rc !== 0) zle.push(`przeterminowane-rc(${r.rc})`);
  if (!/B1 · ciało · WEWNĘTRZNE — hipoteza ZAKAZANA/.test(r.out)) zle.push('nigdy-nieodpowiedziane-nie-pierwsze-albo-bez-rodzaju');
  if (!/pytanie B[\s\S]*pytanie A/.test(r.out)) zle.push('kolejnosc-zla');
  // (−) rejestr świeży: obie odpowiedzi dziś → rc=0 i ŻADNEGO słowa PROTEZA
  fs.writeFileSync(F, glowa('2026-08-20') + '| A1 | dom | operacyjne | pytanie A | 2026-08-30 | 2026-08-30 · x |\n| B1 | ciało | wewnętrzne | pytanie B | 2026-08-30 | 2026-08-30 · y |\n');
  r = bieg([], '2026-08-30');
  if (r.rc !== 0 || /PROTEZA/.test(r.out)) zle.push(`swiezy-rejestr-alarmuje(rc=${r.rc})`);
  // (⊗) PROTEZA: ostatnia odpowiedź 15 dni temu → rc=2 + słowo PROTEZA + liczba dni
  r = bieg([], '2026-09-14');
  if (r.rc !== 2 || !/PROTEZA/.test(r.out) || !/15 dni/.test(r.out)) zle.push(`proteza-nie-melduje-siebie(rc=${r.rc})`);
  // (⊗⊗) narodziny bez żadnej odpowiedzi: 14 dni od narodzin → PROTEZA; 13 dni → jeszcze nie
  fs.writeFileSync(F, glowa('2026-09-01') + '| A1 | dom | operacyjne | pytanie A | — | — |\n');
  if (bieg([], '2026-09-15').rc !== 2) zle.push('proteza-od-narodzin-nie-liczy');
  if (bieg([], '2026-09-14').rc !== 0) zle.push('proteza-przedwczesna');
  // (∅) rejestr pusty → rc=2 z komunikatem, nigdy cisza; brak pliku → rc=2
  fs.writeFileSync(F, glowa('2026-09-01'));
  r = bieg([], '2026-09-02'); if (r.rc !== 2 || !/PROTEZA|nie ma czego/.test(r.out)) zle.push(`pusty-rejestr-milczy(rc=${r.rc})`);
  fs.unlinkSync(F); r = bieg([], '2026-09-02'); if (r.rc !== 2) zle.push(`brak-pliku-rc(${r.rc})`);
  // (✎) --odpowiedz stempluje ZEGAR (WYW_DZIS), nie argument; log dostaje wiersz; --kandydat-bledy przeżywa
  fs.writeFileSync(F, glowa('2026-09-01') + '| A1 | dom | operacyjne | pytanie A | — | — |\n');
  r = bieg(['--odpowiedz', 'A1', 'poszło źle z piecem', '--kandydat-bledy'], '2026-09-03');
  const po = fs.readFileSync(F, 'utf8');
  if (r.rc !== 0 || !/\| 2026-09-03 · poszło źle z piecem \|/.test(po)) zle.push('odpowiedz-nie-stempluje-zegarem');
  if (!/\| 2026-09-03 \| A1 \| dom \| poszło źle z piecem \| → kandydat BLEDY \|/.test(po)) zle.push('log-bez-wiersza-lub-bez-kandydata');
  if (bieg(['--odpowiedz', 'ZZ', 'x'], '2026-09-03').rc !== 3) zle.push('zle-id-przechodzi');
  // (⌘) --przeglad: tydzień widzi odpowiedź sprzed 3 dni, nie widzi sprzed 10; miesiąc nazywa obszary bez odpowiedzi
  fs.appendFileSync(F, '| 2026-08-24 | A1 | dom | stara | |\n');
  r = bieg(['--przeglad', 'tydzien'], '2026-09-06');
  if (r.rc !== 0 || !/dom \(1\)/.test(r.out) || /stara/.test(r.out) || !/kandydatów do BLEDY: 1/.test(r.out)) zle.push('przeglad-tydzien-zly');
  r = bieg(['--przeglad', 'miesiac'], '2026-09-06');
  if (!/dom \(2\)/.test(r.out) || !/pasieka: — \(bez/.test(r.out)) zle.push('przeglad-miesiac-bez-ciszy-obszarow');
  fs.writeFileSync(F, glowa('2026-09-01') + '| A1 | dom | operacyjne | p | — | — |\n');
  r = bieg(['--przeglad', 'tydzien'], '2026-09-06'); if (r.rc !== 2 || !/ZERO odpowiedzi/.test(r.out)) zle.push('przeglad-pusty-jako-sukces');
  // (⊂) --wstan: ≤ 6 linii
  fs.writeFileSync(F, glowa('2026-09-01') + '| A1 | dom | operacyjne | p | — | — |\n| B1 | ciało | wewnętrzne | q | — | — |\n');
  r = bieg(['--wstan'], '2026-09-03'); if (r.out.trim().split('\n').length > 6) zle.push('wstan-ponad-budzet-6-linii');
  fs.rmSync(T, { recursive: true, force: true });
  console.log('╔═══ WYWIAD — AUTOTEST (#38) ═══╗');
  if (!zle.length) { console.log('✓ PRZYRZĄD ŻYWY: pyta najdłużej niepytane z nazwanym rodzajem, milczy na świeżym rejestrze, melduje SAM SIEBIE jako protezę po 14 dniach,\n  pusty rejestr nie jest sukcesem, stempel z zegara nie z argumentu, przegląd bez interpretacji z ciszą obszarów, wstanie ≤ 6 linii.'); process.exit(0); }
  console.log('✗ PRZYRZĄD MARTWY: ' + zle.join(' · ')); process.exit(1);
}

const a = process.argv.slice(2);
if (a[0] === '--test') tor();
else if (a[0] === '--wstan') process.exit(pytaj(true));
else if (a[0] === '--zadane') process.exit(zadane(a[1]));
else if (a[0] === '--odpowiedz') process.exit(odpowiedz(a[1], a[2], a.includes('--kandydat-bledy')));
else if (a[0] === '--przeglad') { if (!['tydzien', 'miesiac'].includes(a[1])) { console.log('użycie: --przeglad tydzien|miesiac'); process.exit(3); } process.exit(przeglad(a[1])); }
else if (!a.length) process.exit(pytaj(false));
else { console.log('użycie: wywiad.js [--wstan | --zadane <id> | --odpowiedz <id> "<zdanie>" [--kandydat-bledy] | --przeglad tydzien|miesiac | --test]'); process.exit(3); }
