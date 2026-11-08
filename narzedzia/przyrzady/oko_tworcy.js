#!/usr/bin/env node
'use strict';
/**
 * OKO TWÓRCY — przyrząd CELU 1 (piękno/czytelność dla biologicznego obsługanta).
 *
 * DLACZEGO POWSTAŁ (blizna #69, 24.08.2026): cele 2–5 badania miały liczby, cel 1
 * nie miał ŻADNEGO przyrządu — więc instancja raportowała to, co umie policzyć,
 * i wzięła sumę za całość. Twórca zrobił `kpull` i zobaczył dokładnie tę ścianę,
 * na którą narzekał na starcie. Metryka dostępna wyparła metrykę ważną.
 *
 * CO MIERZY: ciało tak, jak je widzi Obsidian — czyli TYLKO to, co Obsidian
 * renderuje (md + załączniki). Skrypty `.js/.sh` są dla tego oka NIEWIDZIALNE
 * (lekcja ephe), więc ich tu nie ma — i to jest cecha, nie brak.
 *
 * WERDYKT BINARNY: korzeń mieści się na jednym ekranie (PRÓG) albo nie.
 * Bez werdyktu przyrząd byłby kolejnym raportem do interpretacji.
 */
const fs = require('fs');
const path = require('path');
const { execFileSync } = require('child_process');

const args = process.argv.slice(2);
const TEST = args.includes('--test');

// Co renderuje Obsidian (reszta = organy niewidzialne dla oka twórcy).
const WIDZIALNE = /\.(md|png|jpg|jpeg|svg|pdf|canvas)$/i;
// Ekran: telefon ~17 pozycji (zmierzone przez twórcę), pulpit ~40. Próg bierzemy telefonowy — kciuk jest wąskim gardłem.
const EKRAN = 17;   // KALIBRACJA TWÓRCY 24.08: tyle mieści jego ekran; cel: ciut poniżej

function widok(kat) {
  const pliki = execFileSync('git', ['-c', 'core.quotepath=false', 'ls-files', '-z'],
    { cwd: kat, encoding: 'utf8', maxBuffer: 64e6 }).split('\0').filter(Boolean);
  const katalogi = new Set();
  const korzen = [];
  for (const f of pliki) {
    const i = f.indexOf('/');
    if (i > 0) { const d = f.slice(0, i); if (!d.startsWith('.')) katalogi.add(d); continue; }  // Obsidian ukrywa kropkowe
    if (WIDZIALNE.test(f)) korzen.push(f);
  }
  korzen.sort();
  const pozycje = katalogi.size + korzen.length;      // Obsidian: katalogi + luźne pliki
  const ekrany = Math.ceil(pozycje / EKRAN);
  // Rodziny płaskie: prefiks przed pierwszym "_" występujący >1 raz W KORZENIU.
  const rodz = new Map();
  for (const f of korzen) {
    const p = f.replace(/\.[^.]+$/, '').split('_')[0];
    rodz.set(p, (rodz.get(p) || 0) + 1);
  }
  const rodziny = [...rodz.entries()].filter(([, n]) => n > 1).sort((a, b) => b[1] - a[1]);
  const bezdomne = rodziny.reduce((s, [, n]) => s + n, 0);
  return { katalogi: [...katalogi].sort(), korzen, pozycje, ekrany, rodziny, bezdomne };
}

function raport(w) {
  const L = [];
  L.push('');
  L.push('▤ OKO TWÓRCY — ciało widziane przez Obsidian (nie przez git)');
  L.push('');
  L.push(`  pozycji w korzeniu: ${w.pozycje}  (${w.katalogi.length} katalogów + ${w.korzen.length} luźnych plików)`);
  L.push(`  ekranów przewijania (telefon, ~${EKRAN}/ekran): ${w.ekrany}`);
  L.push(`  plików w rodzinach bez domu: ${w.bezdomne}`);
  if (w.rodziny.length) {
    L.push(`  rodziny płaskie: ${w.rodziny.map(([p, n]) => `${p}×${n}`).join(' · ')}`);
  }
  L.push('');
  const ok = w.ekrany <= 1;
  L.push(ok
    ? `  ✓ CEL 1 SPEŁNIONY: korzeń mieści się na jednym ekranie (${w.pozycje} ≤ ${EKRAN}).`
    : `  ✗ CEL 1 NIESPEŁNIONY: korzeń to ${w.ekrany} ekrany przewijania (${w.pozycje} pozycji, próg ${EKRAN}).`);
  if (!ok) L.push(`    Do progu brakuje: ${w.pozycje - EKRAN} pozycji do zagospodarowania.`);
  L.push('');
  L.push('  (Werdykt dotyczy WYŁĄCZNIE celu 1. Nie mówi nic o szybkości instancji,');
  L.push('   granicy publikacji ani jakości treści — te mają własne przyrządy.)');
  return { txt: L.join('\n'), ok };
}

if (TEST) {
  const os = require('os');
  const baza = fs.mkdtempSync(path.join(os.tmpdir(), 'oko-'));
  const g = (...a) => execFileSync('git', a, { cwd: baza, encoding: 'utf8' });
  g('init', '-q', '-b', 'main'); g('config', 'user.email', 't@k'); g('config', 'user.name', 't');
  const w = (n, t) => { fs.mkdirSync(path.join(baza, path.dirname(n)), { recursive: true }); fs.writeFileSync(path.join(baza, n), t); };
  for (let i = 0; i < 30; i++) w(`PLIK_${i}.md`, '#\n');
  w('PLAN_a.md', '#\n'); w('PLAN_b.md', '#\n');
  w('skrypt.js', '//\n'); w('narzedzie.sh', '#\n');       // niewidzialne dla oka
  w('dom/plik.md', '#\n'); w('inny/plik.md', '#\n');
  g('add', '-A'); g('commit', '-qm', 'raz');

  const spr = [];
  const t = (n, a, b) => { const ok = String(a) === String(b); spr.push(ok);
    console.log(`  ${ok ? '✓' : '✗'} ${n}${ok ? '' : ` (było '${a}', miało '${b}')`}`); };

  let v = widok(baza);
  t('skrypty niewidzialne dla oka twórcy', v.korzen.filter(f => /\.(js|sh)$/.test(f)).length, 0);
  t('pozycje = katalogi + luźne md', v.pozycje, 2 + 32);
  t('ekrany liczone progiem telefonu', v.ekrany, Math.ceil(34 / EKRAN));
  t('rodzina płaska wykryta', v.rodziny.some(([p, n]) => p === 'PLAN' && n === 2), 'true');
  t('werdykt: ściana = NIESPEŁNIONY', raport(v).ok, 'false');

  // stan zdrowy: wszystko w domach
  const baza2 = fs.mkdtempSync(path.join(os.tmpdir(), 'oko2-'));
  const g2 = (...a) => execFileSync('git', a, { cwd: baza2, encoding: 'utf8' });
  g2('init', '-q', '-b', 'main'); g2('config', 'user.email', 't@k'); g2('config', 'user.name', 't');
  for (const n of ['a/x.md', 'b/y.md', 'START.md']) {
    fs.mkdirSync(path.join(baza2, path.dirname(n)), { recursive: true });
    fs.writeFileSync(path.join(baza2, n), '#\n');
  }
  g2('add', '-A'); g2('commit', '-qm', 'raz');
  const v2 = widok(baza2);
  t('ciało czyste: jeden ekran', v2.ekrany, 1);
  t('werdykt: czyste = SPEŁNIONY', raport(v2).ok, 'true');

  fs.rmSync(baza, { recursive: true, force: true });
  fs.rmSync(baza2, { recursive: true, force: true });
  const o = spr.filter(x => !x).length;
  console.log(`  zmierzone: zdanych ${spr.length - o} · oblanych ${o}`);
  if (o === 0) { console.log('✓ OKO TWÓRCY ŻYWE: widzi ścianę, nie widzi skryptów, wydaje werdykt.'); process.exit(0); }
  console.log('✗ TOR OBLANY'); process.exit(1);
}

const w = widok(process.cwd());
const r = raport(w);
console.log(r.txt);
process.exit(r.ok ? 0 : 1);
