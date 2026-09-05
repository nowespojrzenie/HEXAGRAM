#!/usr/bin/env node
/* odduplikuj.js — wykrywa ten sam fakt w dwóch rejestrach.
 *
 * POWÓD (25.08.2026): POZOSTALOSCI trzyma pozycje przeniesione już do ZADANIA.
 * Każdy przegląd to spotkanie z rzeczami załatwionymi — czytelnik traci pewność,
 * czy to, co czyta, jest jeszcze aktualne. Ten sam gatunek błędu co rozjazd PAT
 * (jeden obowiązek, dwa pliki, dwie daty).
 *
 * NIE KASUJE SAM. Dopasowanie po słowach bywa mylne: „renowacja drzwi" może być
 * osobną pozycją albo fragmentem większej. Werdykt należy do twórcy.
 *
 * UŻYCIE
 *   node odduplikuj.js                    raport par, nic nie rusza
 *   node odduplikuj.js zdejmij 1,3,7-9    suchy bieg — pokazuje, co by zdjął
 *   node odduplikuj.js zdejmij 1,3,7-9 --wykonaj
 */
const fs = require('fs');

// ŚCIEŻKI Z OTOCZENIA, NIE ZASZYTE (30.08.2026, PRAWO ODLEWU): mechanizm porównywania dwóch
// rejestrów jest uniwersalny, ale lista MOICH rejestrów nią nie jest — dopóki nazwy stały
// w kodzie, przyrząd był mechanizmem zrośniętym z zawartością i nie mógł jechać (ta sama
// klasa, przez którą `spis_projektow.js` zatrzymał odlew godzinę wcześniej).
// Domyślne wartości zostają, żeby wywołanie bez argumentów działało jak dotąd.
const ZRODLO = process.env.ODD_ZRODLO || 'kanon/ksiegi/POZOSTALOSCI.md';
const CELE = (process.env.ODD_CELE || 'prywatne/ZADANIA.md prywatne/TASKI.md projekty/dom-rodzina/LOWY.md').split(/\s+/).filter(Boolean);
const KOSZ = process.env.ODD_KOSZ || 'kanon/ksiegi/POZOSTALOSCI_zdjete.md';

/* ── normalizacja: zostaje sam sens, znika formatowanie ────────────── */
const STOP = new Set(['tego','tych','tym','jest','sie','czy','dla','przy','nie','oraz',
  'jako','albo','pod','nad','bez','tez','ale','wiec','tak','juz','moze','byc','ma','na']);

// ── TOR (#38, dopisany 30.08.2026) ────────────────────────────────────────────────
if (process.argv[2] === '--test') {
  const os = require('os'), pathm = require('path');
  const T = fs.mkdtempSync(pathm.join(os.tmpdir(), 'odd-'));
  let zle = [];
  const spr = (op, a, b) => { if (String(a) === String(b)) console.log('  ✓ ' + op);
    else { console.log(`  ✗ ${op} (było ${a}, miało ${b})`); zle.push(op); } };
  const cp = require('child_process');
  const bieg = (zr, cele) => {
    try {
      return cp.execSync(`node ${__filename}`, { encoding: 'utf8',
        env: { ...process.env, ODD_ZRODLO: zr, ODD_CELE: cele, ODD_KOSZ: T + '/kosz.md' } });
    } catch (e) { return String(e.stdout || '') + String(e.stderr || ''); }
  };
  // PREDYKAT NA LICZBACH, NIE NA SŁOWACH (30.08): pierwsza wersja szukała w wydruku frazy
  // „zdejmij 1" — a to fragment STAŁEJ instrukcji („zdejmij 1,3,7-9"), obecnej zawsze.
  // Tor świecił zielono na obu stronach naraz. Liczymy sumę PEWNE+MOCNE+SŁABE (#66 ods. 6).
  const pary = (wy) => {
    const m = wy.match(/PEWNE[^:]*:\s*(\d+).*?MOCNE[^:]*:\s*(\d+).*?SŁABE[^:]*:\s*(\d+)/s);
    return m ? Number(m[1]) + Number(m[2]) + Number(m[3]) : -1;
  };
  // (+) TA SAMA rzecz w obu rejestrach — MUSI zostać zgłoszona jako para
  // FORMAT JAK W PRODUKCJI (30.08): przyrząd czyta WYŁĄCZNIE wiersze `- [ ]`; pierwsza
  // fikstura pisała `- ` i tor mierzył materię, której przyrząd w ogóle nie widzi (#51/#70).
  fs.writeFileSync(T + '/z.md', '- [ ] kupic uszczelki do ula wielkopolskiego\n');
  fs.writeFileSync(T + '/c.md', '- [ ] uszczelki wielkopolskiego ula kupic pilnie\n');
  spr('ta sama rzecz w dwoch rejestrach ZGLOSZONA', pary(bieg(T + '/z.md', T + '/c.md')) > 0, true);
  // (−) rzeczy ROZŁĄCZNE — zero par, inaczej „wszystko jest duplikatem" (#75)
  fs.writeFileSync(T + '/c2.md', '- [ ] podlac pomidory w szklarni rano\n');
  spr('rozlaczne rejestry NIE daja pary', pary(bieg(T + '/z.md', T + '/c2.md')), 0);
  // (+) puste źródło nie wywraca przyrządu (zero znaczące)
  fs.writeFileSync(T + '/pusty.md', '');
  spr('puste zrodlo nie wywraca', /Error|undefined/.test(bieg(T + '/pusty.md', T + '/c.md')), false);
  fs.rmSync(T, { recursive: true, force: true });
  console.log('╔═══ ODDUPLIKUJ — AUTOTEST ═══╗');
  if (zle.length) { console.log('  ✗ TOR OBLANY: ' + zle.join(' · ')); process.exit(1); }
  console.log('  ✓ TOR PRZESZEDŁ — widzi ten sam fakt w dwóch rejestrach i NIE widzi go tam, gdzie go nie ma.');
  process.exit(0);
}

function norm(t) {
  return t.replace(/\*\*|`|~~|<[^>]*>/g, '')
          .replace(/\[\[.*?\]\]/g, '')
          .replace(/#[\wąćęłńóśźż-]+/gi, '')
          .replace(/⌛\S+|⚠|🔴|🔔|◆|✓/g, '')
          .replace(/\(.*?\)/g, ' ')
          .replace(/[^\wąćęłńóśźżĄĆĘŁŃÓŚŹŻ ]/g, ' ')
          .replace(/\s+/g, ' ').trim().toLowerCase();
}
const klucz = t => new Set(t.split(' ').filter(w => w.length > 3 && !STOP.has(w)));

function czytaj(path) {
  if (!fs.existsSync(path)) return [];
  const out = [];
  fs.readFileSync(path, 'utf8').split('\n').forEach((l, i) => {
    const m = l.match(/^\s*- \[ \]\s*(.+)/);
    if (!m) return;
    const n = norm(m[1]);
    if (n.length > 8) out.push({ nr: i + 1, surowy: m[1].trim(), n, k: klucz(n) });
  });
  return out;
}

/* ── podobieństwo: Jaccard po rdzeniach słów ───────────────────────── */
function sim(a, b) {
  if (a.k.size < 2 || b.k.size < 2) return 0;
  let wsp = 0;
  a.k.forEach(w => { if (b.k.has(w)) wsp++; });
  return wsp / Math.min(a.k.size, b.k.size);
}

const zrodlo = czytaj(ZRODLO);
const cele = [];
CELE.forEach(p => czytaj(p).forEach(z => cele.push({ ...z, plik: p.split('/').pop() })));

const pary = [];
zrodlo.forEach(p => {
  let best = null;
  cele.forEach(z => {
    const s = sim(p, z);
    if (s >= 0.6 && (!best || s > best.s)) best = { s, z };
  });
  if (best) pary.push({ p, ...best });
});
pary.sort((a, b) => b.s - a.s);

const cmd = process.argv[2] || 'raport';

if (cmd === 'raport') {
  console.log(`\n╔═ ODDUPLIKUJ — raport ═╗\n`);
  console.log(`  źródło: ${ZRODLO}  →  ${zrodlo.length} otwartych pozycji`);
  console.log(`  cele:   ${CELE.map(c => c.split('/').pop()).join(' · ')}  →  ${cele.length} pozycji`);
  console.log(`\n  ZNALEZIONE PARY: ${pary.length}   (próg podobieństwa 0.6)\n`);
  pary.forEach((x, i) => {
    const pewnosc = x.s >= 0.85 ? 'PEWNE  ' : x.s >= 0.7 ? 'MOCNE  ' : 'SŁABE  ';
    console.log(`  ${String(i + 1).padStart(2)}. [${pewnosc}${x.s.toFixed(2)}]`);
    console.log(`      POZOSTALOSCI : ${x.p.surowy.slice(0, 88)}`);
    console.log(`      ${x.z.plik.padEnd(13)}: ${x.z.surowy.slice(0, 88)}\n`);
  });
  console.log(`  ─────────────────────────────────────────────────────────`);
  console.log(`  PEWNE ≥0.85: ${pary.filter(x => x.s >= .85).length}  ·  MOCNE ≥0.7: ${pary.filter(x => x.s >= .7 && x.s < .85).length}  ·  SŁABE: ${pary.filter(x => x.s < .7).length}`);
  console.log(`\n  Werdykt należy do twórcy. Zdjęcie:  node odduplikuj.js zdejmij 1,3,7-9 --wykonaj\n`);
  process.exit(0);
}

if (cmd === 'zdejmij') {
  const spec = process.argv[3] || '';
  const wykonaj = process.argv.includes('--wykonaj');
  const idx = new Set();
  spec.split(',').forEach(s => {
    const m = s.trim().match(/^(\d+)-(\d+)$/);
    if (m) { for (let i = +m[1]; i <= +m[2]; i++) idx.add(i); }
    else if (/^\d+$/.test(s.trim())) idx.add(+s.trim());
  });
  if (!idx.size) { console.log('  Podaj numery, np. 1,3,7-9'); process.exit(1); }

  const wybrane = [...idx].map(i => pary[i - 1]).filter(Boolean);
  console.log(`\n  ${wykonaj ? '⚙ WYKONUJĘ' : '◌ SUCHY BIEG'} — do zdjęcia: ${wybrane.length}\n`);
  wybrane.forEach(x => console.log(`    − ${x.p.surowy.slice(0, 80)}`));

  if (!wykonaj) { console.log(`\n  Nic nie ruszone. Dodaj --wykonaj.\n`); process.exit(0); }

  const doUsun = new Set(wybrane.map(x => x.p.nr));
  const linie = fs.readFileSync(ZRODLO, 'utf8').split('\n');
  const zdjete = [];
  const zostaje = linie.filter((l, i) => {
    if (doUsun.has(i + 1)) { zdjete.push(l); return false; }
    return true;
  });
  fs.writeFileSync(ZRODLO, zostaje.join('\n'));

  const naglowek = fs.existsSync(KOSZ) ? '' :
    `# POZOSTAŁOŚCI — zdjęte jako duplikaty\n\n> Pozycje usunięte z \`POZOSTALOSCI.md\`, bo ten sam fakt stał już w innym rejestrze.\n> Zachowane, nie skasowane — gdyby dopasowanie okazało się mylne.\n\n`;
  const wpis = `\n## ${new Date().toISOString().slice(0, 10)} — zdjęto ${wybrane.length}\n\n` +
    wybrane.map(x => `${x.p.surowy}\n   ↳ dublet z **${x.z.plik}**: ${x.z.surowy.slice(0, 100)}`).join('\n\n') + '\n';
  fs.appendFileSync(KOSZ, naglowek + wpis);

  console.log(`\n  ✓ zdjęto ${zdjete.length} · zapisane w ${KOSZ}`);
  console.log(`  ✓ ${ZRODLO}: ${zrodlo.length} → ${zrodlo.length - wybrane.length} pozycji\n`);
}
