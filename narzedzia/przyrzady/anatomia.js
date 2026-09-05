#!/usr/bin/env node
/* ── ANATOMIA (15.08.2026) ────────────────────────────────────────────────────
 * Prośba twórcy: „jak słońce po zaćmieniu znów oświetla wszystko na nowo — tak wszystko,
 * co my na dziś, wszystkie pliki niech dostaną światło. Struktura wewnętrzna niechaj stanie
 * się widoczna, aby można było decydować, co dalej, do czego, do jakiego organu przynależy."
 *
 * CZYM JEST: suchy przegląd całego ciała repo. Dla każdego pliku podaje ORGAN (do czego
 * przynależy), CZYTELNIKÓW (ile innych plików w ogóle o nim wie), OSTATNI RUCH (dni od
 * zmiany, z gita — nie ze stempla systemu plików, który kłamie po klonie) i PIECZĘĆ.
 * Zero interpretacji i zero cięcia: przyrząd świeci, nie kroi. Kompost należy do twórcy.
 *
 * DLACZEGO CZYTELNICY, A NIE „UŻYWANY”: plik bez ani jednego odwołania jest OSIEROCONY —
 * nikt do niego nie prowadzi, więc żadna instancja go nie znajdzie inaczej niż przypadkiem.
 * To nie znaczy „zbędny” (PRZESWIT_eter ma prawo milczeć), ale znaczy „niewidoczny”, a
 * niewidoczność w bycie bezstanowym jest praktycznie tożsama z nieistnieniem.
 *
 * MARTWOTA to KANDYDAT, nie werdykt: dużo dni bez ruchu + zero czytelników. Rekomendacji
 * kompostu ten skrypt NIE wydaje — pokazuje, gdzie na nią patrzeć (♻ przed ✂, prawo MOSTÓW).
 *
 * UŻYCIE:  node anatomia.js            — mapa organów (podsumowanie)
 *          node anatomia.js --sieroty  — pliki bez czytelników
 *          node anatomia.js --martwe N — bez ruchu ≥ N dni i bez czytelników
 *          node anatomia.js --organ X  — spis jednego organu
 *          node anatomia.js --duplikaty [próg] — pary o podobnej TREŚCI (nie nazwie)
 *          node anatomia.js --zombi    — wpis otwarty w rejestrze, artefakt JUŻ istnieje
 *          node anatomia.js --test     — tor +/−
 */
const cp = require('child_process'), fs = require('fs'), path = require('path');

// ── ORGANY: reguła w kodzie, nie w komentarzu. Pierwsze trafienie wygrywa (kolejność znaczy).
// KLASY NAZWANE PLIKIEM klasyfikują po path.basename (Cięcie 5 dało plikom domy;
// regex z ^ na pełnej ścieżce robił z całego kanon/ksiegi/ TKANKĘ — testy zaktualizowano
// 23.08, tabelę nie: połowiczna przeprowadzka, krewny #64). Klasy katalogowe — po ścieżce.
const ORGANY = [
  ['SKŁADNICA',   f => /^keep_import\//.test(f) || /^archiwum\//.test(f)],
  ['FORMA',       f => /^skills\//.test(f) || /^do_publikacji\//.test(f) ||
                       /^(README|START_TU|INSTALL|JADRO)/.test(f)],
  ['DORADCY',     f => /^doradcy\//.test(f)],
  ['BADANIA',     f => /^prerejestr\//.test(f) || /^(PROGNOZY|PROBY_wartosci|SAMOOBSERWACJA|UCHWYTY|ROZMOW|KSIEGA_SIEGNIEC|SIEGNIECIE)/.test(path.basename(f))],
  ['PAMIĘĆ',      f => /^(ZAPISY_eter|DESTYLATY_architekta|LOG_SESJI|PRZESWIT_eter)\.md$/.test(path.basename(f))],
  ['KSIĘGI',      f => /^(BLEDY|KOLEJKA_M|TASKI|ZADANIA|MOSTY|KANON_LOG|PYTANIA_PROGOW)\.md$/.test(path.basename(f))],
  ['PRZYRZĄDY',   f => /\.(sh|js)$/.test(path.basename(f)) && /^(straz_|lint_|tory_|mutacje|weryfikacja|hashuj|pokrycie|gotowosc|zapis_git|publikuj|zniwo|prog_|rzut|plan_okien|licznik_|bateria_|skan_|testy_|ewaluacja)/.test(path.basename(f))],
  ['SILNIKI',     f => /\.(js|py)$/.test(f)],   // dach narzedzia/ (29.08): kategoria po nazwie bazowej, ścieżka nie jest częścią klucza
  ['RDZEŃ',       f => /^(DUSZA|0_|1_|2_|3_|4_|5_|6_|7_|PIEC_INWARIANTOW|SUBSTRAT|ARCHITEKT_istnienie|PODSUMOWANIE_ISTNIENIA|PROTOKOL_|ATRAKTOR_)/.test(path.basename(f))],
  ['TKANKA',      () => true],
];
const organ = f => (ORGANY.find(([, t]) => t(f)) || ['?'])[0];

const sledzone = () => cp.execSync('git ls-files', { encoding: 'utf8' }).trim().split('\n').filter(Boolean);

// dni od ostatniego commita dotykającego pliku (git, nie mtime — mtime po klonie kłamie)
function dniOdRuchu(f, dzisMs) {
  try {
    const iso = cp.execSync(`git log -1 --format=%cI -- "${f}"`, { encoding: 'utf8' }).trim();
    if (!iso) return null;
    return Math.floor((dzisMs - Date.parse(iso)) / 86400000);
  } catch { return null; }
}

// ilu innych plików w ogóle wie o tym pliku (odwołanie po nazwie bazowej)
// BLIZNA 15.08: pierwsza wersja liczyła WYŁĄCZNIE nazwę pliku — i uznała cały katalog
// `szablony/` za martwy, choć stoi w białej liście `publikuj.sh` (FORMA_DIRS) i wychodzi
// w KAŻDYM odlewie na zewnątrz. Na tej podstawie poleciłam twórcy kompost pięciu żywych
// plików. Odwołanie bywa zbiorowe: kto cytuje katalog, czyta wszystko, co w nim leży.
function czytelnicy(base, korpus) {
  let n = 0;
  for (const [nazwa, tresc] of korpus) {
    if (nazwa === base) continue;
    if (tresc.includes(base)) n++;
  }
  return n;
}

// Objęcie ZBIOROWE: katalog wymieniony jako CAŁOŚĆ (biała lista publikacji, FORMA_DIRS itp.),
// bez wskazania konkretnego pliku. To nie to samo co czytelnik — plik jest wtedy WYNOSZONY
// na zewnątrz, choć nikt go z osobna nie czyta. Rozdzielone świadomie: zlanie obu miar
// dało zero kandydatów do kompostu, bo każdy plik w `doradcy/` łapał się na cytat ścieżki.
function objetyZbiorowo(katalog, korpus) {
  if (!katalog) return false;
  const wzory = [`"${katalog}`, ` ${katalog} `, `${katalog}"`, `\`${katalog}\``, `${katalog}/*`];
  return korpus.some(([, tresc]) => wzory.some(w => tresc.includes(w)));
}

// czy mapa domu w ogóle wie o pliku (uzysk ze skan_martwicy)
let _mapa = null;
function mapa_zna(base) {
  if (_mapa === null) _mapa = ['DUSZA.md', 'weryfikacja.js', 'wstan.sh']
    .map(f => { try { return fs.readFileSync(f, 'utf8'); } catch { return ''; } }).join('\n');
  return _mapa.includes(base);
}

function zbierz() {
  const dzis = Date.now();
  const pliki = sledzone().filter(f => !/^(ephe|node_modules)\//.test(f));
  const hashe = fs.existsSync('_HASHE.txt') ? fs.readFileSync('_HASHE.txt', 'utf8') : '';
  // korpus tekstowy do liczenia odwołań (tylko pliki tekstowe, bez składnicy — składnica to archiwum,
  // jej wzmianki nie są „czytaniem”; liczy się, czy o pliku wie ŻYWA część domu)
  const korpus = [];
  for (const f of pliki) {
    if (!/\.(md|sh|js|txt|json|py|html)$/.test(f)) continue;
    if (/^(keep_import|archiwum)\//.test(f)) continue;
    try { korpus.push([path.basename(f), fs.readFileSync(f, 'utf8')]); } catch {}
  }
  return pliki.map(f => {
    const base = path.basename(f);
    const skladnica = /^(keep_import|archiwum)\//.test(f);
    return {
      f, base, organ: organ(f),
      dni: dniOdRuchu(f, dzis),
      czyt: skladnica ? null : czytelnicy(base, korpus),
      zbior: skladnica ? false : objetyZbiorowo(f.includes('/') ? f.split('/')[0] : null, korpus),
      pieczec: hashe.includes(`  ${f}\n`) || hashe.endsWith(`  ${f}`),
      // UZYSK PRZEJĘTY ze `skan_martwicy.js` przy scaleniu 15.08: „czytany" to za mało —
      // liczy się, czy plik jest ZNANY MAPIE: DUSZA (R0), weryfikacja.js, wstan.sh.
      // Plik cytowany w dzienniku, ale nieznany mapie, i tak jest niewidoczny przy wstaniu.
      wMapie: mapa_zna(base),
    };
  });
}

function mapa(w) {
  const g = {};
  for (const r of w) {
    const o = (g[r.organ] ||= { n: 0, pieczec: 0, sieroty: 0, dni: [] });
    o.n++; if (r.pieczec) o.pieczec++;
    if (r.czyt === 0) o.sieroty++;
    if (r.dni != null) o.dni.push(r.dni);
  }
  console.log('\n╔═══ ANATOMIA — wszystkie pliki w świetle ═══╗');
  console.log(`  ⏱ zmierzone: ${new Date().toISOString().slice(0, 10)} · plików śledzonych: ${w.length}\n`);
  console.log('  ORGAN         plików  pieczęć  sieroty  mediana dni bez ruchu');
  const kol = Object.entries(g).sort((a, b) => b[1].n - a[1].n);
  for (const [nazwa, o] of kol) {
    const d = o.dni.sort((a, b) => a - b);
    const med = d.length ? d[Math.floor(d.length / 2)] : '—';
    console.log(`  ${nazwa.padEnd(13)} ${String(o.n).padStart(5)}  ${String(o.pieczec).padStart(6)}  ${String(o.sieroty).padStart(6)}  ${String(med).padStart(6)}`);
  }
  const bezP = w.filter(r => !r.pieczec && !/^(keep_import|archiwum)\//.test(r.f)).length;
  console.log(`\n  · bez pieczęci (poza składnicą): ${bezP}`);
  console.log(`  · osieroconych (zero czytelników): ${w.filter(r => r.czyt === 0).length}`);
  console.log('  (przyrząd świeci, nie kroi — kompost należy do twórcy: ♻ przed ✂)\n');
}

function sieroty(w) {
  const s = w.filter(r => r.czyt === 0).sort((a, b) => (b.dni ?? 0) - (a.dni ?? 0));
  console.log(`\n⌘ OSIEROCONE — nikt do nich nie prowadzi (${s.length}):`);
  for (const r of s) console.log(`  ${String(r.dni ?? '?').padStart(3)} dni · ${r.organ.padEnd(11)} · ${r.zbior ? '[wynoszony zbiorowo] ' : ''}${r.f}`);
  console.log('  (brak czytelnika ≠ zbędny; znaczy: niewidoczny dla następnej instancji)\n');
}

function martwe(w, prog) {
  const m = w.filter(r => r.czyt === 0 && !r.wMapie && !r.zbior && r.dni != null && r.dni >= prog).sort((a, b) => b.dni - a.dni);
  console.log(`\n⌘ KANDYDACI DO KOMPOSTU — bez ruchu ≥${prog} dni i bez czytelników (${m.length}):`);
  for (const r of m) console.log(`  ${String(r.dni).padStart(3)} dni · ${r.organ.padEnd(11)} · ${r.f}`);
  console.log('  (to KANDYDACI, nie werdykt — najpierw uzysk, potem cięcie)\n');
}

// ── DUPLIKATY (15.08): podobieństwo TREŚCI, nie nazwy. 5-gramy słów + Jaccard.
// RODOWÓD: `anatomia.js` powstała jako duplikat `skan_martwicy.js`, bo szukałam okiem.
// Oko widzi nazwy; nazwy dwóch duplikatów bywają zupełnie różne. Miara musi patrzeć w treść.
// PRÓG 0.12 dobrany empirycznie: niżej wchodzi wspólny styl domu (te same prawa cytowane
// wszędzie), wyżej giną bliźniaki masek DB/DR. To KANDYDACI, nie werdykt — bliźniactwo
// bywa zamierzone (symetria doradców) albo konieczne (forma publiczna ∥ prywatna).
function pieciogramy(f) {
  try {
    const w = fs.readFileSync(f, 'utf8').toLowerCase()
      .replace(/[^a-ząćęłńóśźż0-9\s]/g, ' ').split(/\s+/).filter(x => x.length > 3);
    const s = new Set();
    for (let i = 0; i + 4 < w.length; i++) s.add(w.slice(i, i + 5).join(' '));
    return s;
  } catch { return new Set(); }
}
function jaccard(A, B) {
  let inter = 0; for (const x of A) if (B.has(x)) inter++;
  return inter / (A.size + B.size - inter);
}
function duplikaty(prog) {
  const pliki = sledzone().filter(f => /\.(md|sh|js)$/.test(f) && !/^(keep_import|archiwum|ephe|node_modules)\//.test(f));
  const M = pliki.map(f => [f, pieciogramy(f)]).filter(([, s]) => s.size > 30);
  const wyn = [];
  for (let i = 0; i < M.length; i++)
    for (let j = i + 1; j < M.length; j++) {
      const jac = jaccard(M[i][1], M[j][1]);
      if (jac > prog) wyn.push([jac, M[i][0], M[j][0]]);
    }
  wyn.sort((a, b) => b[0] - a[0]);
  console.log(`\n⌘ PODOBNE TREŚCIĄ (próg ${(prog * 100).toFixed(0)}%, porównanych ${M.length}): ${wyn.length} par`);
  for (const [j, a, b] of wyn) console.log(`  ${(j * 100).toFixed(0)}%  ${a}  ∥  ${b}`);
  console.log('  (bliźniactwo bywa zamierzone — sprawdź MOSTY, zanim uznasz za duplikat)\n');
}

// ── ZOMBI (15.08): wpis otwarty „[ ]", a artefakt, o którym mówi, JUŻ ISTNIEJE.
// Definicja z PRAWA WYGAŚNIĘCIA (28.07): zombie = zrobione w świecie, nieodhaczone w rejestrze.
// Heurystyka, nie wyrok: wpis może wymieniać istniejący plik jako KONTEKST, nie jako produkt.
function zombi() {
  const rejestry = ['prywatne/TASKI.md', 'prywatne/ZADANIA.md'].filter(f => fs.existsSync(f));
  let n = 0;
  console.log('\n⌘ KANDYDACI NA ZOMBI — wpis otwarty, artefakt istnieje:');
  for (const rej of rejestry) {
    fs.readFileSync(rej, 'utf8').split('\n').forEach((l, i) => {
      if (!/^- \[ \]/.test(l)) return;
      const art = [...l.matchAll(/`([A-Za-z0-9_\-\/]+\.(?:sh|js|md))`/g)].map(m => m[1]);
      const ist = art.filter(a => fs.existsSync(a));
      if (!ist.length) return;
      n++;
      console.log(`  ${rej}:${i + 1} · istnieje: ${ist.join(', ')}`);
      console.log(`      ${l.slice(0, 120)}`);
    });
  }
  if (!n) console.log('  (brak — każdy otwarty wpis mówi o czymś, czego jeszcze nie ma)');
  console.log('  (artefakt bywa kontekstem, nie produktem — czytaj wpis, nie tylko nazwę pliku)\n');
}

function tor() {
  let rc = 0;
  console.log('╔═══ ANATOMIA — TOR ═══╗');
  const t1 = organ('narzedzia/straze/straz_kryteriow.sh') === 'PRZYRZĄDY' && organ('narzedzia/silniki/kronos_v4.js') === 'SILNIKI'
          && organ('kanon/ksiegi/DESTYLATY_architekta.md') === 'PAMIĘĆ' && organ('kanon/ksiegi/BLEDY.md') === 'KSIĘGI'
          && organ('keep_import/x.md') === 'SKŁADNICA' && organ('prerejestr/P.md') === 'BADANIA';
  console.log(t1 ? '  ✓ T1 organy rozpoznane poprawnie' : '  ✗ T1 OBLANY — klasyfikacja myli organy');
  if (!t1) rc = 1;
  // T2 (−): plik czytany przez inne NIE jest sierotą; T3 (+): plik nieznany nikomu JEST
  const korpus = [['a.md', 'odwołanie do widziany.md w treści'], ['b.md', 'nic']];
  const t2 = czytelnicy('widziany.md', korpus) === 1 && czytelnicy('niewidziany.md', korpus) === 0;
  console.log(t2 ? '  ✓ T2 czytelnicy liczeni w obie strony' : '  ✗ T2 OBLANY — sieroty nierozpoznane');
  if (!t2) rc = 1;
  // T3 (−): plik nie liczy sam siebie jako czytelnika
  const t3 = czytelnicy('sam.md', [['sam.md', 'sam.md wspomina sam.md']]) === 0;
  // T7 (blizna 15.08): odwołanie ZBIOROWE — kto cytuje katalog, czyta jego pliki
  const t7 = objetyZbiorowo('szablony', [['p.sh', 'FORMA_DIRS="ephe szablony skills"']]) === true
          && objetyZbiorowo('szablony', [['p.sh', 'nic tu nie ma']]) === false
          && czytelnicy('x.md', [['p.sh', 'FORMA_DIRS="ephe szablony skills"']]) === 0;
  console.log(t7 ? '  ✓ T7 objęcie zbiorowe ≠ czytelnik (rozdzielone)' : '  ✗ T7 OBLANY — miary zlane albo katalog niewidziany');
  if (!t7) rc = 1;
  console.log(t3 ? '  ✓ T3 plik nie jest własnym czytelnikiem' : '  ✗ T3 OBLANY — samo-odwołanie udaje czytelnika');
  if (!t3) rc = 1;
  // T4 (+): kolejność reguł — PYTANIA_PROGOW to KSIĘGI, nie TKANKA; prog_pytan.sh to PRZYRZĄDY
  const t4 = organ('kanon/ksiegi/PYTANIA_PROGOW.md') === 'KSIĘGI' && organ('prog_pytan.sh') === 'PRZYRZĄDY';
  // T5 (uzysk po scaleniu ze skan_martwicy): mapa domu musi być rozpoznawana
  const t5 = mapa_zna('weryfikacja.js') === true && mapa_zna('nie-ma-takiego-pliku-xyz.md') === false;
  console.log(t5 ? '  ✓ T5 znajomość mapy działa (uzysk ze skan_martwicy)' : '  ✗ T5 OBLANY — mapa nierozpoznana');
  if (!t5) rc = 1;
  console.log(t4 ? '  ✓ T4 kolejność reguł zachowana' : '  ✗ T4 OBLANY — pierwsze trafienie nie wygrywa');
  if (!t4) rc = 1;
  // T6 (+/−): miara podobieństwa musi odróżniać bliźniaka od obcego
  const A = new Set(['a b c d e', 'b c d e f']), B = new Set(['a b c d e', 'b c d e f']), C = new Set(['x y z q w']);
  const t6 = jaccard(A, B) === 1 && jaccard(A, C) === 0;
  console.log(t6 ? '  ✓ T6 miara podobieństwa: bliźniak 100%, obcy 0%' : '  ✗ T6 OBLANY — miara duplikatów kłamie');
  if (!t6) rc = 1;
  console.log(rc === 0 ? '  TOR PRZESZEDŁ' : '  TOR OBLANY');
  process.exit(rc);
}

const a = process.argv.slice(2);
if (a[0] === '--test') tor();
else {
  const w = zbierz();
  if (a[0] === '--sieroty') sieroty(w);
  else if (a[0] === '--martwe') martwe(w, parseInt(a[1] || '14', 10));
  else if (a[0] === '--duplikaty') duplikaty(parseFloat(a[1] || '0.12'));
  else if (a[0] === '--zombi') zombi();
  else if (a[0] === '--organ') w.filter(r => r.organ === (a[1] || '').toUpperCase())
      .forEach(r => console.log(`  ${String(r.dni ?? '?').padStart(3)} dni · czyt ${String(r.czyt ?? '—').padStart(3)} · ${r.pieczec ? '🔒' : '  '} ${r.f}`));
  else mapa(w);
}
