#!/usr/bin/env node
/* ── PRZED CIĘCIEM (15.08.2026) ───────────────────────────────────────────────
 * Prośba twórcy po poważnej pomyłce: „jaka struktura uświadomienia ciała pomogłaby nam
 * ustrzec się takich błędów? Jaka kolejność ładowania informacji przed werdyktem —
 * jakimkolwiek, a już tym bardziej w tematach usunięć?"
 *
 * CO SIĘ STAŁO (#57): poleciłam kompost pięciu plików z `szablony/`, bo jedna miara mówiła
 * „zero czytelników". Katalog stoi na BIAŁEJ LIŚCIE `publikuj.sh` i wychodzi w KAŻDYM odlewie.
 * Potem poprawka zlała dwie miary w jedną i dała zero kandydatów. Trzy podejścia do jednej
 * rzeczy — bo werdykt zapadał, ZANIM ciało się załadowało.
 *
 * ZASADA: WERDYKT JEST OSTATNI. Najpierw osiem warstw, zawsze w tej samej kolejności,
 * zawsze wszystkie — i dopiero na końcu zdanie. Im bardziej nieodwracalne cięcie,
 * tym mniej wolno pominąć. „Dwie miary albo żadna."
 *
 * WARSTWY (kolejność nieprzypadkowa — od treści ku kontekstowi, od trwałego ku bieżącemu):
 *   1 CZYM JEST      — treść, nie nazwa (duplikat miewa inną nazwę: tak przegapiłam skan_martwicy)
 *   2 CZYTELNICY     — kto odwołuje się po nazwie
 *   3 ZBIOROWO       — kto wynosi katalogiem (biała lista, glob) ← tu poległa rekomendacja
 *   4 MAPA           — czy zna go DUSZA / wstan / weryfikacja / _HASHE
 *   5 UZYSK          — czy niesie coś, czego nie ma bliźniak (♻ przed ✂)
 *   6 MOST           — czy jest brzegiem pary w kanon/ksiegi/MOSTY.md
 *   7 NIETYKALNOŚĆ   — pamięć · prerejestr · marker ślepy (#24)
 *   8 DRUGA RĘKA     — ostatni commit i kto go dotknął
 *
 * WERDYKT: ŻYWY (≥1 warstwa mówi „używane") · NIETYKALNY · KANDYDAT (wszystkie ciche).
 * Nawet KANDYDAT nie jest zgodą na cięcie — jest zgodą na ROZMOWĘ o cięciu.
 *
 * ZNANE OGRANICZENIE WARSTWY 5 (nazwane 15.08, po trzech podejściach): uzysk mierzy CAŁE
 * LINIE. Linia SCALONA Z DWÓCH ŹRÓDEŁ (np. wiersz „prawo + nośnik", gdzie prawo żyje w BLEDY,
 * a nośnik w KOLEJKA_M) zawsze wygląda na unikalną, choć obie połowy są ocalone. Miara myli się
 * wtedy W STRONĘ ŻYCIA — i tak ma zostać: fałszywe „ŻYWY" kosztuje rozmowę, fałszywe „KANDYDAT"
 * kosztuje treść. Przy takim trafieniu rozstrzyga człowiek, nie kolejna poprawka miary.
 *
 * UŻYCIE:  node przed_cieciem.js <ścieżka> [...]   ·   node przed_cieciem.js --test
 */
const cp = require('child_process'), fs = require('fs'), path = require('path');
const ROOT = process.env.PC_ROOT || '.';

const czytaj = f => { try { return fs.readFileSync(path.join(ROOT, f), 'utf8'); } catch { return ''; } };
const korpusPlikow = () => {
  try {
    return cp.execSync('git ls-files', { cwd: ROOT, encoding: 'utf8' }).trim().split('\n')
      .filter(f => /\.(md|sh|js|txt|json|html)$/.test(f) && !/^(keep_import|archiwum|ephe|node_modules)\//.test(f));
  } catch { return []; }
};

function karta(cel) {
  const base = path.basename(cel);
  const katalog = cel.includes('/') ? cel.split('/')[0] : null;
  const pliki = korpusPlikow().filter(f => f !== cel);
  const tresci = pliki.map(f => [f, czytaj(f)]);
  const w = {};

  // 1 CZYM JEST
  const t = czytaj(cel);
  w.istnieje = t.length > 0;
  w.pierwszaLinia = (t.split('\n')[0] || '').slice(0, 80);
  w.bajtow = t.length;

  // 2 CZYTELNICY (po nazwie)
  w.czytelnicy = tresci.filter(([, c]) => c.includes(base)).map(([f]) => f);

  // 3 ZBIOROWO (katalog jako całość)
  w.zbiorowo = [];
  if (katalog) {
    const wzory = [`"${katalog}`, ` ${katalog} `, `${katalog}"`, '`' + katalog + '`', `${katalog}/*`];
    w.zbiorowo = tresci.filter(([, c]) => wzory.some(x => c.includes(x))).map(([f]) => f);
  }

  // 4 MAPA
  w.mapa = ['DUSZA.md', 'wstan.sh', 'weryfikacja.js', '_HASHE.txt']
    .filter(m => czytaj(m).includes(base));

  // 5 UZYSK — najbliższy bliźniak treścią i czy cel ma linie, których bliźniak nie ma
  w.blizniak = null; w.unikalnychLinii = null;
  if (t.length > 200) {
    const gram = s => { const ws = s.toLowerCase().replace(/[^a-ząćęłńóśźż0-9\s]/g, ' ').split(/\s+/).filter(x => x.length > 3);
      const set = new Set(); for (let i = 0; i + 4 < ws.length; i++) set.add(ws.slice(i, i + 5).join(' ')); return set; };
    const A = gram(t); let best = [0, null];
    for (const [f, c] of tresci) {
      if (c.length < 200) continue;
      const B = gram(c); let inter = 0; for (const x of A) if (B.has(x)) inter++;
      const jac = inter / (A.size + B.size - inter);
      if (jac > best[0]) best = [jac, f];
    }
    if (best[0] > 0.12) {
      w.blizniak = { plik: best[1], podobienstwo: Math.round(best[0] * 100) };
      // BLIZNA 15.08 (złapana PRZED zapisem): porównanie po surowej linii uznało 48 wierszy
      // tabeli za „unikalne", bo kopia miała JEDNĄ KOLUMNĘ WIĘCEJ. Uzysk był pozorny — treść
      // stała w obu plikach. Formatowanie to nie treść: normalizujemy przed porównaniem.
      const norm = l => l.trim().toLowerCase().replace(/[|`*_#>-]/g, ' ').replace(/\s+/g, ' ').trim();
      // DRUGA BLIZNA tego samego dnia: uzysk liczony wobec JEDNEGO bliźniaka pokazał 48 linii
      // „tylko tutaj" — a wszystkie żyły w `kanon/ksiegi/KOLEJKA_M.md`. Treść nie musi mieszkać u bliźniaka,
      // żeby być ocalona. Uzysk mierzymy wobec CAŁEGO domu.
      const wszystkie = new Set();
      for (const [, c] of tresci) for (const l of c.split('\n').map(norm)) if (l.length > 40) wszystkie.add(l);
      w.unikalnychLinii = t.split('\n').map(norm).filter(l => l.length > 40 && !wszystkie.has(l)).length;
    }
  }

  // 6 MOST
  w.most = czytaj('kanon/ksiegi/MOSTY.md').includes(base);

  // 7 NIETYKALNOŚĆ
  w.nietykalny = /^(ZAPISY_eter|DESTYLATY_architekta|LOG_SESJI|PRZESWIT_eter)\.md$/.test(cel)
              || /^prerejestr\//.test(cel) || /^KSIEGA_SIEGNIEC\.md$/.test(cel);

  // 8 DRUGA RĘKA
  try {
    w.ostatni = cp.execSync(`git log -1 --format="%cI · %an · %s" -- "${cel}"`, { cwd: ROOT, encoding: 'utf8' }).trim().slice(0, 100);
  } catch { w.ostatni = '?'; }

  return w;
}

function werdykt(w) {
  if (!w.istnieje) return ['BRAK', 'pliku nie ma — nie ma czego rozstrzygać'];
  if (w.nietykalny) return ['NIETYKALNY', 'pamięć / prerejestr / księga sięgnięć — cięcie wykluczone z mocy #24'];
  const powody = [];
  if (w.czytelnicy.length) powody.push(`czyta go ${w.czytelnicy.length} plik(ów)`);
  if (w.zbiorowo.length) powody.push(`wynoszony zbiorowo przez ${w.zbiorowo.length}`);
  if (w.mapa.length) powody.push(`zna go mapa: ${w.mapa.join(', ')}`);
  if (w.most) powody.push('jest brzegiem mostu');
  if (w.unikalnychLinii > 0) powody.push(`ma ${w.unikalnychLinii} linii, których nie ma bliźniak`);
  if (powody.length) return ['ŻYWY', powody.join(' · ')];
  return ['KANDYDAT', 'wszystkie osiem warstw milczy — to zgoda na ROZMOWĘ o cięciu, nie na cięcie'];
}

function pokaz(cel) {
  const w = karta(cel), [v, d] = werdykt(w);
  console.log(`\n╔═ KARTA PRZED CIĘCIEM · ${cel}`);
  console.log(`  1 CZYM JEST    ${w.bajtow} B · ${w.pierwszaLinia}`);
  console.log(`  2 CZYTELNICY   ${w.czytelnicy.length}${w.czytelnicy.length ? ': ' + w.czytelnicy.slice(0, 4).join(', ') : ''}`);
  console.log(`  3 ZBIOROWO     ${w.zbiorowo.length}${w.zbiorowo.length ? ': ' + w.zbiorowo.slice(0, 4).join(', ') : ''}`);
  console.log(`  4 MAPA         ${w.mapa.length ? w.mapa.join(', ') : '—'}`);
  console.log(`  5 UZYSK        ${w.blizniak ? `bliźniak ${w.blizniak.plik} (${w.blizniak.podobienstwo}%) · linii tylko tutaj: ${w.unikalnychLinii}` : '— (brak bliźniaka)'}`);
  console.log(`  6 MOST         ${w.most ? 'TAK — brzeg pary w kanon/ksiegi/MOSTY.md' : '—'}`);
  console.log(`  7 NIETYKALNY   ${w.nietykalny ? 'TAK' : '—'}`);
  console.log(`  8 DRUGA RĘKA   ${w.ostatni}`);
  console.log(`  ⇒ WERDYKT: ${v} — ${d}\n`);
  return v;
}

function tor() {
  let rc = 0;
  console.log('╔═══ PRZED CIĘCIEM — TOR ═══╗');
  // T1 (−): plik nietykalny NIGDY nie jest kandydatem, choćby wszystko milczało
  const t1 = werdykt({ istnieje: true, nietykalny: true, czytelnicy: [], zbiorowo: [], mapa: [], most: false })[0] === 'NIETYKALNY';
  console.log(t1 ? '  ✓ T1 nietykalny nie do cięcia' : '  ✗ T1 OBLANY — pamięć poszłaby pod nóż'); if (!t1) rc = 1;
  // T2 (−): sama warstwa ZBIOROWO wystarczy, by uznać za żywy (to była pomyłka #57)
  const t2 = werdykt({ istnieje: true, nietykalny: false, czytelnicy: [], zbiorowo: ['publikuj.sh'], mapa: [], most: false })[0] === 'ŻYWY';
  console.log(t2 ? '  ✓ T2 wynoszony zbiorowo = ŻYWY (zamek na #57)' : '  ✗ T2 OBLANY — #57 wraca'); if (!t2) rc = 1;
  // T3 (−): sam most wystarczy
  const t3 = werdykt({ istnieje: true, nietykalny: false, czytelnicy: [], zbiorowo: [], mapa: [], most: true })[0] === 'ŻYWY';
  console.log(t3 ? '  ✓ T3 brzeg mostu = ŻYWY' : '  ✗ T3 OBLANY — most przecięty'); if (!t3) rc = 1;
  // T4 (−): uzysk (linie tylko tutaj) blokuje kandydaturę
  const t4 = werdykt({ istnieje: true, nietykalny: false, czytelnicy: [], zbiorowo: [], mapa: [], most: false, unikalnychLinii: 7 })[0] === 'ŻYWY';
  console.log(t4 ? '  ✓ T4 nieodzyskany uzysk = ŻYWY' : '  ✗ T4 OBLANY — uzysk przepadłby'); if (!t4) rc = 1;
  // T5 (+): dopiero pełna cisza daje KANDYDATA
  const t5 = werdykt({ istnieje: true, nietykalny: false, czytelnicy: [], zbiorowo: [], mapa: [], most: false, unikalnychLinii: 0 })[0] === 'KANDYDAT';
  console.log(t5 ? '  ✓ T5 pełna cisza = KANDYDAT (nie werdykt cięcia)' : '  ✗ T5 OBLANY'); if (!t5) rc = 1;
  console.log(rc === 0 ? '  TOR PRZESZEDŁ' : '  TOR OBLANY');
  process.exit(rc);
}

const a = process.argv.slice(2);
if (a[0] === '--test') tor();
else if (!a.length) console.log('użycie: node przed_cieciem.js <ścieżka> [...]');
else a.forEach(pokaz);
