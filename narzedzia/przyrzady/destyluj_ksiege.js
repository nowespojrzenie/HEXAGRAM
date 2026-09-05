#!/usr/bin/env node
// ── DESTYLACJA KSIĄG DLA ODLEWU (30.08.2026) ─────────────────────────────────────
// Decyzja twórcy: „zalążkujemy błędy" + „mosty: niektóre wchodzą, inne dopiero powstaną —
// zbadaj i wyszukaj najlepszej drogi". Najlepsza droga okazała się REGUŁĄ, nie cięciem ręką:
// obie księgi mają kryterium, po którym da się rozstrzygnąć KAŻDY wiersz bez gustu.
//
// BLEDY  → jedzie INDEKS w całości (79 wierszy, każdy to jedno zdanie prawa — gotowy destylat)
//          + korpus WYŁĄCZNIE wpisów ze statusem `M✓`. Uzasadnienie: nowy twórca dostaje
//          działający mechanizm w kodzie, więc opis jego blizny jest instrukcją, nie kroniką.
//          Wpisy R/P/M-bez-ptaszka to droga pierwotna — zostają u autora.
// MOSTY  → jedzie nagłówek i prawo (#39: dwaj świadkowie ≠ duplikat) + te wiersze tabeli,
//          których WSZYSTKIE wymienione przyrządy są na białej liście odlewu. Most o parze
//          `anatomia ∥ homunculus` jest dla nowego twórcy zdaniem o narzędziach, których
//          nie dostanie — zmierzone 30.08: pięć takich wierszy z czterdziestu.
//
// CZYM TO NIE JEST (granica wobec `zalazkuj.sh`, most #28): zalążkowanie zdejmuje treść
// MIĘDZY znacznikami ⟠ — autor rozstrzyga ręcznie, co jest drogą. Tutaj rozstrzyga POMIAR
// (status wpisu · biała lista), więc wynik sam się aktualizuje: przyrząd wchodzi do odlewu,
// jego most pojawia się w odlewowej wersji bez niczyjej pamięci. Dwa różne pytania, dwa
// przyrządy — nie duplikat (#39).
//
// UŻYCIE: node narzedzia/przyrzady/destyluj_ksiege.js --bledy <źródło> <cel> [--lista <plik>]
//         node narzedzia/przyrzady/destyluj_ksiege.js --mosty <źródło> <cel> --lista <plik>
//         node narzedzia/przyrzady/destyluj_ksiege.js --test

const fs = require('fs');
const path = require('path');
const { execFileSync } = require('child_process');   // C3 tura 4: odczyt białej listy przez publikuj.sh --lista
const KORZEN = path.join(__dirname, '..', '..');

const NOTA = [
  '',
  '```',
  '⟠ DESTYLAT KSIĘGI — dla nowego twórcy',
  'To NIE jest pełna księga twórcy pierwotnego. Jedzie prawo i mechanizm;',
  'droga, na której powstały — opisy dni, nazwy sesji, przebiegi — zostaje u autora.',
  'GENEROWANY (destyluj_ksiege.js) — nie edytuj ręcznie, bo druga kopia rozjeżdża się po cichu.',
  'Twoje własne wpisy dopisuj normalnie: przyrządy, które to wymuszają, masz w środku.',
  '```',
  ''
].join('\n');

// nazwy plików (bez ścieżek) obecne na białej liście odlewu
// C3 · tura 4 (02.09.2026): JEDNO ŹRÓDŁO ODCZYTU — pytamy `publikuj.sh --lista`.
//
// STARY CZYTNIK PRZECIEKAŁ, ZMIERZONE. Regex `FORMA_(MD|JS|SH|INNE)="[^"]*"` leciał po
// CAŁYM pliku, więc łapał też fikstury z bloku `--test` samego `publikuj.sh` (linie 399,
// 438-440, 616-620). Zbiór nazw wychodził na 128 zamiast 122; sześć obcych pozycji to
// "", "$1", "$2", "$3", "$4" i "KANON_LOG.md" — ten ostatni stoi na liście
// NIGDY_NIE_WYCHODZI. Skutku wyjściowego dziś NIE BYŁO (filtr wierszy MOSTY dopuszcza
// tylko `[a-z_0-9]+\.(js|sh)`, więc żadna z szóstki nie mogła trafić w wiersz) — ale to
// ta sama klasa, którą 28.08 złapała `straz_aktora.sh`: czytnik widzi więcej, niż mu dano.
// DIRS świadomie NIE jest czytane: nazwy katalogów nie są przyrządami w wierszach MOSTY.
function nazwyOdlewu(plikPublikuj) {
  const out = new Set();
  for (const sekcja of ['MD', 'JS', 'SH', 'INNE']) {
    const wynik = execFileSync('bash', [plikPublikuj, '--lista', sekcja], { encoding: 'utf8' });
    for (const s of wynik.split('\n')) if (s.trim()) out.add(path.basename(s.trim()));
  }
  return out;
}

function destylujBledy(zrodlo) {
  const linie = fs.readFileSync(zrodlo, 'utf8').split('\n');
  // status M✓ czytamy z INDEKSU — jedno źródło prawdy o statusie (kolumna 5)
  const zMech = new Set();
  for (const l of linie) {
    const m = l.match(/^\|\s*(\d+)\s*\|/);
    if (!m) continue;
    const kol = l.split('|');
    if ((kol[5] || '').includes('✓')) zMech.add(m[1]);
  }
  const out = [];
  let wKorpusie = false, biezacy = null, trzymaj = true;
  for (const l of linie) {
    const h = l.match(/^## #(\d+)/);
    if (h) { wKorpusie = true; biezacy = h[1]; trzymaj = zMech.has(biezacy); }
    else if (/^## /.test(l) && wKorpusie) { trzymaj = true; biezacy = null; }
    if (!wKorpusie || trzymaj) out.push(l);
  }
  // nota tuż po tytule
  const i = out.findIndex(l => /^# /.test(l));
  if (i >= 0) out.splice(i + 1, 0, NOTA);
  return { tekst: out.join('\n'), zostalo: zMech.size };
}

function destylujMosty(zrodlo, nazwy) {
  const linie = fs.readFileSync(zrodlo, 'utf8').split('\n');
  const out = [];
  let zdjete = 0, zostalo = 0;
  for (const l of linie) {
    if (/^\|\s*\d+\s*\|/.test(l)) {
      const przyrzady = [...new Set(l.match(/[a-z_0-9]+\.(js|sh)/g) || [])];
      // wiersz bez przyrządów (para dokumentów) zostaje — mówi o prawie, nie o narzędziu
      const wszystkieJada = przyrzady.length === 0 || przyrzady.every(p => nazwy.has(p));
      if (!wszystkieJada) { zdjete++; continue; }
      zostalo++;
    }
    out.push(l);
  }
  const i = out.findIndex(l => /^# /.test(l));
  if (i >= 0) out.splice(i + 1, 0, NOTA);
  return { tekst: out.join('\n'), zostalo, zdjete };
}

// ── TOR (#38: przyrząd musi umieć NIE przejść) ────────────────────────────────────
if (process.argv[2] === '--test') {
  const T = fs.mkdtempSync('/tmp/destyl-');
  let zle = [];
  const spr = (op, a, b) => { if (String(a) === String(b)) console.log('  ✓ ' + op); else { console.log(`  ✗ ${op} (było ${a}, miało ${b})`); zle.push(op); } };

  // BLEDY: indeks zostaje w całości, korpus tylko dla M✓
  const b = ['# B', '| 1 | — | prawo jeden | POMIAR | **M✓** |', '| 2 | — | prawo dwa | POMIAR | **R** |',
             '## #1 (x) PIERWSZY', 'opis pierwszy', '## #2 (x) DRUGI', 'opis drugi', ''].join('\n');
  fs.writeFileSync(T + '/b.md', b);
  const rb = destylujBledy(T + '/b.md');
  spr('BLEDY: wpis M✓ ZOSTAJE', /## #1 /.test(rb.tekst), true);
  spr('BLEDY: wpis R ZNIKA', /## #2 /.test(rb.tekst), false);
  spr('BLEDY: opis wpisu R znika razem z nim', /opis drugi/.test(rb.tekst), false);
  spr('BLEDY: INDEKS zostaje w calosci (oba wiersze)', (rb.tekst.match(/^\| \d /gm) || []).length, 2);
  spr('BLEDY: nota destylatu dopisana', /⟠ DESTYLAT KSIĘGI/.test(rb.tekst), true);

  // MOSTY: wiersz zostaje tylko, gdy WSZYSTKIE jego przyrządy jadą
  const m = ['# M', 'prawo #39 o świadkach',
             '| 1 | `jedzie_a.sh` ∥ `jedzie_b.sh` | ⟡ | POŁĄCZ | opis |',
             '| 2 | `jedzie_a.sh` ∥ `nie_jedzie.js` | ⟡ | POŁĄCZ | opis |',
             '| 3 | `PLIK_A.md` ∥ `PLIK_B.md` | ⟡ | POŁĄCZ | para dokumentów |', ''].join('\n');
  fs.writeFileSync(T + '/m.md', m);
  const nazwy = new Set(['jedzie_a.sh', 'jedzie_b.sh']);
  const rm = destylujMosty(T + '/m.md', nazwy);
  spr('MOSTY: para w calosci w odlewie ZOSTAJE', /jedzie_b\.sh/.test(rm.tekst), true);
  spr('MOSTY: para z przyrzadem spoza odlewu ZNIKA', /nie_jedzie\.js/.test(rm.tekst), false);
  spr('MOSTY: wiersz bez przyrzadow (dokumenty) ZOSTAJE', /para dokumentów/.test(rm.tekst), true);
  spr('MOSTY: prawo poza tabela ZOSTAJE', /prawo #39/.test(rm.tekst), true);
  spr('MOSTY: licznik zdjetych', rm.zdjete, 1);

  // (−) ODRÓŻNIALNOŚĆ: gdy NIC nie jedzie, tabela ma zniknąć w całości — inaczej filtr
  //     przepuszczający wszystko wyglądałby tak samo jak działający (#75)
  const rm0 = destylujMosty(T + '/m.md', new Set());
  spr('MOSTY: pusty odlew zdejmuje oba wiersze z przyrzadami', rm0.zdjete, 2);

  fs.rmSync(T, { recursive: true, force: true });
  console.log('╔═══ DESTYLACJA KSIĄG — AUTOTEST ═══╗');
  if (zle.length) { console.log('  ✗ TOR OBLANY: ' + zle.join(' · ')); process.exit(1); }
  console.log('  ✓ TOR PRZESZEDŁ — filtr zdejmuje drogę, zostawia prawo, i umie zdjąć wszystko.');
  process.exit(0);
}

const tryb = process.argv[2], zrodlo = process.argv[3], cel = process.argv[4];
if (!tryb || !zrodlo || !cel) {
  console.log('użycie: --bledy|--mosty <źródło> <cel> [--lista <publikuj.sh>]');
  process.exit(2);
}
const iL = process.argv.indexOf('--lista');
const plikListy = iL > 0 ? process.argv[iL + 1] : path.join(KORZEN, 'publikuj.sh');

if (tryb === '--bledy') {
  const r = destylujBledy(zrodlo);
  fs.writeFileSync(cel, r.tekst);
  console.log(`⟠ destylat BLEDY: ${cel} · wpisów z mechanizmem: ${r.zostalo} · ${fs.statSync(cel).size} B`);
} else if (tryb === '--mosty') {
  const r = destylujMosty(zrodlo, nazwyOdlewu(plikListy));
  fs.writeFileSync(cel, r.tekst);
  console.log(`⟠ destylat MOSTY: ${cel} · wierszy zostało: ${r.zostalo} · zdjętych: ${r.zdjete} · ${fs.statSync(cel).size} B`);
} else { console.log('nieznany tryb: ' + tryb); process.exit(2); }
