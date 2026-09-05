#!/usr/bin/env node
/**
 * WEKTORY — dynamika ruchu przez organy (15.08.2026, ratyfikacja twórcy:
 * „Mierzmy wszystkie. Przyrząd aktywny — skan ciała, z możliwościami rozbudowy").
 *
 * Most #23: wektory ∥ anatomia ∥ pokrycie_m — anatomia = STATYKA (kto gdzie leży),
 * ten przyrząd = DYNAMIKA (co przez co płynie, jak szybko, co czeka na błonie).
 * Czytać razem, nigdy osobno. Anatomia jest ŹRÓDŁEM czytelników (sekcja POWRÓT
 * deleguje, nie duplikuje — blizna #49-rodzina: kopie milczą, gdy zgadzają się w błędzie).
 *
 * SEKCJE (każda = funkcja; CLI wybiera, domyślnie wszystkie):
 *   lancuch  — przepustowość ogniw: eter → destylaty → blizny → mechanizmy
 *   wiek     — AGING WIP: wiek pozycji „w drodze" od narodzin blizny (najstarszy pierwszy)
 *   tempo    — TEMPO ✓: kiedy każdy ✓ pojawił się w indeksie (świadek: git, nie pamięć)
 *   przeplyw — LEAD TIME blizna→✓; JAWNIE: podział aktywne/czekanie NIEMIERZALNY
 *              z obecnych danych (brak dziennika aktywności per pozycja) — meldujemy
 *              czas przejścia, nie „flow efficiency"; liczba, której nie ma, nie pada
 *   parytet  — BŁONA pamięć∥kanon: zdania kryteriów w pamięci (lustro logiki
 *              narzedzia/straze/straz_kryteriow.sh) parowane z nośnikami ⌛/kryteriami kanonu po dacie
 *   powrot   — MIARA POWROTU: sieroty z anatomia.js (delegacja; Collector's Fallacy:
 *              wartość = powrót do użycia, nie rozmiar; przegląd = ręka twórcy, ♻ przed ✂)
 *
 * PRZYRZĄD ŚWIECI, NIE KROI. rc: 0 = pomiar wykonany · 1 = --test oblał · 2 = błąd wejścia.
 * Każda liczba w wydruku pochodzi z tego procesu, w tej chwili (⏱ ZMIERZONE TERAZ).
 */
'use strict';
const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');

const ROOT = require('path').join(__dirname, '..', '..');   // dach narzedzia/przyrzady/ (29.08): korzeń repo
const BLEDY = path.join(ROOT, 'kanon/ksiegi/BLEDY.md');
// NAZWY PAMIĘCI PARAMETRYZOWANE (21.08.2026 — warunek wejścia do formy publicznej).
// Ten przyrząd mierzy dynamikę pamięci, a nie CZYTA JEJ TREŚCI: liczy nagłówki wpisów
// i wiek najstarszego niedestylowanego. Sama FUNKCJA jest bezosobowa — osobiste są
// wyłącznie nazwy plików. Wyniesione do zmiennych środowiskowych, żeby odbiorca odlewu
// mógł wskazać własne dzienniki, zamiast dziedziczyć nasze nazwy jako cudze prawo.
// Domyślne wartości zostają NASZE: w tym repo mają działać bez konfiguracji.
const F_ETER  = process.env.WEKTORY_ETER  || 'kanon/ksiegi/ZAPISY_eter.md';
const F_DEST  = process.env.WEKTORY_DEST  || 'kanon/ksiegi/DESTYLATY_architekta.md';
const F_LOG   = process.env.WEKTORY_LOG   || 'kanon/ksiegi/LOG_SESJI.md';
const PAMIEC = [F_ETER, F_DEST, F_LOG];
const DZIS = new Date(); // zegar maszyny; meldunek niesie datę pomiaru

// ── narzędzia wspólne ────────────────────────────────────────────────────────
// ZERO ZNACZĄCE (21.08.2026 — warunek wejścia do formy publicznej).
// Ten przyrząd mierzy dynamikę PAMIĘCI: eteru, destylatów, księgi błędów. U odbiorcy
// odlewu tych plików może NIE BYĆ — i to jest stan legalny, nie awaria. Wcześniej
// `readFileSync` wyrzucał ENOENT i cały przyrząd padał z rc=1, czyli w formie publicznej
// byłby narzędziem, które przy pierwszym uruchomieniu wygląda na zepsute.
// Pusty ciąg zamiast wyjątku: brak pamięci to zero wpisów, nie błąd odczytu.
// Rodzina ZERA ZNACZĄCEGO ze straży tropu — pusty zbiór bywa zdrowiem, ale MUSI być nazwany.
const czytaj = (f) => { try { return fs.readFileSync(f, 'utf8'); } catch (e) { return ''; } };
const iso = (dd, mm, rr) => `${rr || DZIS.getFullYear()}-${String(mm).padStart(2, '0')}-${String(dd).padStart(2, '0')}`;
const dniOd = (isoData) => Math.floor((DZIS - new Date(isoData + 'T00:00:00')) / 86400000); // floor: pełne dni, południe nie podbija

// ── klasyfikator indeksu BLEDY (lustro pokrycie_m; świadek krzyżowy niżej) ──
function klasyfikuj(tekstBledy) {
  const w = { zmech: [], wDrodze: [], bez: [], postawa: [], wierszy: 0 };
  for (const l of tekstBledy.split('\n')) {
    const m = l.match(/^\| (\d+) \|/); if (!m) continue;
    const kol = l.split('|'); if (kol.length < 7) continue;
    const status = (kol[5] || '').replace(/\*/g, '').trim();
    w.wierszy++;
    if (status.includes('✓')) w.zmech.push(m[1]);
    else if (/POSTAWA/.test(status)) w.postawa.push(m[1]);
    else if (/\bM\b|M-|M$/.test(status)) w.wDrodze.push(m[1]);
    else w.bez.push(m[1]);
  }
  return w;
}

// daty narodzin blizn z nagłówków `## #N … DD.MM`
function datyBlizn(tekstBledy) {
  const d = {};
  for (const l of tekstBledy.split('\n')) {
    const m = l.match(/^## #(\d+)\D*?(\d{1,2})\.(\d{2})(?:\.(\d{4}))?/);
    if (m) d[m[1]] = iso(+m[2], +m[3], m[4]);
  }
  return d;
}

// ── LANCUCH ──────────────────────────────────────────────────────────────────
function lancuch() {
  const eter = (czytaj(path.join(ROOT, F_ETER)).match(/^#{2,3} .*2026/gm) || []).length;
  const dest = (czytaj(path.join(ROOT, F_DEST)).match(/^## Destylat/gm) || []).length;
  const b = czytaj(BLEDY);
  const blizny = (b.match(/^## #\d+/gm) || []).length;
  const k = klasyfikuj(b);
  // ŚWIADEK KRZYŻOWY (dwa interpretery, PRARODZINY): niezależny wzorzec na ✓
  const swiadek = (b.match(/^\| \d+ \|.*✓/gm) || []).length;
  const zgoda = swiadek === k.zmech.length ? '· świadek zgodny' : `· ⚠ ŚWIADEK ROZJECHANY (${swiadek}≠${k.zmech.length})`;
  console.log('▸ ŁAŃCUCH (przepustowość ogniw):');
  console.log(`   eter ${eter} → destylaty ${dest} → blizny ${blizny} → prawa ${k.wierszy}: ` +
    `✓ ${k.zmech.length} · w drodze ${k.wDrodze.length} · bez ${k.bez.length} · POSTAWA ${k.postawa.length} ${zgoda}`);
  console.log('   (dwa strumienie — oddech twórcy ∥ praca instancji — łączą się w BLEDY; to nie rurociąg)');
  return k;
}

// ── WIEK (aging WIP) ─────────────────────────────────────────────────────────
function wiek(k, tekst) {
  k = k || klasyfikuj(tekst || czytaj(BLEDY));
  const daty = datyBlizn(tekst || czytaj(BLEDY));
  const lista = k.wDrodze.map(n => ({ n, d: daty[n] || null, w: daty[n] ? dniOd(daty[n]) : null }))
    .sort((a, b2) => (b2.w ?? -1) - (a.w ?? -1));
  const zn = lista.filter(x => x.w !== null).map(x => x.w).sort((a, b2) => a - b2);
  console.log(`▸ WIEK „W DRODZE" (aging WIP · ${lista.length} pozycji · najstarszy pierwszy):`);
  for (const x of lista) console.log(`   #${x.n} · ${x.d || 'data poza wzorcem nagłówka'}${x.w !== null ? ` · ${x.w} dni` : ''}`);
  if (zn.length) console.log(`   mediana ${zn[Math.floor(zn.length / 2)]} dni · najstarszy ${zn[zn.length - 1]} dni · z datą ${zn.length}/${lista.length}`);
  return lista;
}

// ── TEMPO ✓ (świadek: git; funkcja czysta niżej — testowalna bez repo) ──────
// pierwszeZobaczenie: [{data, zbior:Set}] chronologicznie → {n: dataISO}
function pierwszeZobaczenie(migawki) {
  const first = {};
  for (const m of migawki) for (const n of m.zbior) if (!(n in first)) first[n] = m.data;
  return first;
}
function gitPierwszeCheck() { // świadek git: pierwsze pojawienie ✓ per #N (wspólne: tempo + snapshot)
  const log = execSync('git log --reverse --format="%H %ad" --date=short -- kanon/ksiegi/BLEDY.md', { cwd: ROOT, encoding: 'utf8' })
    .trim().split('\n').filter(Boolean);
  const migawki = [];
  for (const linia of log) {
    const [hash, data] = linia.split(' ');
    let tresc = '';
    try { tresc = execSync(`git show ${hash}:kanon/ksiegi/BLEDY.md`, { cwd: ROOT, encoding: 'utf8', maxBuffer: 8e6 }); }
    catch (e) { continue; } // plik mógł nie istnieć w tym commicie
    const zbior = new Set((tresc.match(/^\| (\d+) \|.*✓.*$/gm) || []).map(l => l.match(/^\| (\d+)/)[1]));
    migawki.push({ data, zbior });
  }
  return { first: pierwszeZobaczenie(migawki), migawki };
}
function tempo() {
  let first, migawki;
  try { ({ first, migawki } = gitPierwszeCheck()); }
  catch (e) { console.log('▸ TEMPO ✓: git niedostępny (rc pomiaru bez tej sekcji)'); return null; }
  const wpisy = Object.entries(first).sort((a, b) => a[1].localeCompare(b[1]));
  // tempo tygodniowe: ostatnie 28 dni
  const prog28 = new Date(DZIS - 28 * 86400000).toISOString().slice(0, 10);
  const ost28 = wpisy.filter(([, d]) => d >= prog28).length;
  console.log(`▸ TEMPO ✓ (pierwsze pojawienie w indeksie — świadek: ${migawki.length} migawek git):`);
  for (const [n, d] of wpisy) console.log(`   #${n} → ✓ ${d}`);
  console.log(`   ✓ w ostatnich 28 dniach: ${ost28} → tempo ${(ost28 / 4).toFixed(2)} ✓/tydzień (BRUTTO: pojawienia)`);
  // ✓ wycofane: pierwsze zobaczenie jest, ale dzisiejszy indeks ✓ nie niesie
  const teraz = new Set(klasyfikuj(czytaj(BLEDY)).zmech);
  const wycofane = Object.keys(first).filter(n => !teraz.has(n));
  if (wycofane.length) console.log(`   ⚠ ✓ WYCOFANE (były, dziś ich nie ma): ${wycofane.map(n => '#' + n).join(', ')} — stan ≠ historia`);
  console.log('   (Little: czas domknięcia kolejki ≈ WIP / tempo — licz z sekcją WIEK, nie z pamięci)');
  return first;
}

// ── PRZEPŁYW (lead time blizna→✓) ────────────────────────────────────────────
function przeplyw(first) {
  const t = czytaj(BLEDY);
  const daty = datyBlizn(t);
  first = first || {};
  const pary = Object.entries(first)
    .filter(([n]) => daty[n])
    .map(([n, dCheck]) => ({ n, lead: Math.round((new Date(dCheck) - new Date(daty[n])) / 86400000) }))
    .filter(x => x.lead >= 0)
    .sort((a, b) => a.lead - b.lead);
  console.log('▸ PRZEPŁYW blizna→✓ (lead time; par z obiema datami: ' + pary.length + '):');
  if (pary.length) {
    const l = pary.map(x => x.lead);
    console.log(`   min ${l[0]} · mediana ${l[Math.floor(l.length / 2)]} · max ${l[l.length - 1]} dni`);
    console.log('   ' + pary.map(x => `#${x.n}:${x.lead}d`).join(' · '));
  }
  console.log('   ⓘ podział aktywne/czekanie NIEMIERZALNY (brak dziennika aktywności per pozycja)');
  console.log('     — „flow efficiency" NIE pada jako liczba; świat mówi 5–15% [NOŚNA RAMA]');
}

// ── PARYTET (błona pamięć∥kanon) — lustro narzedzia/straze/straz_kryteriow.sh ─────────────────
function zdaniaKryteriow(tekst) { // lustro awk: akapity → zdania → fraza twarda
  const zdania = [];
  for (const ak of tekst.split(/\n\s*\n/)) {
    for (const z of ak.replace(/\n/g, ' ').split(/\. /)) {
      if (/[Kk]ryterium (życia|śmierci)/.test(z) && !/ZATRZYMAŁA:/.test(z)) zdania.push(z);
    }
  }
  return zdania;
}
const datyZeZdania = (z) => [...z.matchAll(/([0-3]?\d)\.([01]\d)(?:\.(20\d\d))?/g)].map(m => iso(+m[1], +m[2], m[3]));
function plikiKanonu() { // lustro pliki() ze straży: *.md poza składnicami, archiwum i pamięcią
  const wyn = [];
  const idz = (d) => {
    for (const e of fs.readdirSync(d, { withFileTypes: true })) {
      if (e.name === 'node_modules' || e.name === '.git' || e.name === 'archiwum' || e.name === 'keep_import') continue;
      const p = path.join(d, e.name);
      if (e.isDirectory()) idz(p);
      else if (e.name.endsWith('.md') && !PAMIEC.includes(e.name)) wyn.push(p);
    }
  };
  idz(ROOT); return wyn;
}
// podział bez-pary: ŻYWE (data >= dziś) krzyczą; ECHA (przeszłe) tylko się liczą
function podzielBezPary(bezPary, dzisIso) {
  const zywe = bezPary.filter(x => x.data >= dzisIso);
  const echa = bezPary.filter(x => x.data < dzisIso);
  return { zywe, echa };
}
function parytet() {
  // kryteria w PAMIĘCI (świadczą)
  const pam = [];
  for (const f of PAMIEC) {
    const p = path.join(ROOT, f); if (!fs.existsSync(p)) continue;
    for (const z of zdaniaKryteriow(czytaj(p)))
      for (const d of datyZeZdania(z)) pam.push({ plik: f, data: d });
  }
  // nośniki w KANONIE: ⌛+data w linii (nierozliczone) ALBO twarde zdanie kryterium
  const kanon = new Set();
  for (const p of plikiKanonu()) {
    const t = czytaj(p);
    for (const l of t.split('\n')) {
      if (!l.includes('⌛') || /\[x\]|ROZLICZONE|WYKONANE|BEZPRZEDMIOTOWE/.test(l)) continue;
      for (const d of datyZeZdania(l)) kanon.add(d);
    }
    for (const z of zdaniaKryteriow(t)) for (const d of datyZeZdania(z)) kanon.add(d);
  }
  const zPara = pam.filter(x => kanon.has(x.data));
  const bezPary = pam.filter(x => !kanon.has(x.data));
  const dzisIso = DZIS.toISOString().slice(0, 10);
  const { zywe, echa } = podzielBezPary(bezPary, dzisIso);
  console.log(`▸ PARYTET pamięć∥kanon (kryteria pamięci: ${pam.length} · z nośnikiem: ${zPara.length} · bez pary ŻYWE: ${zywe.length} · echa przeszłe: ${echa.length}):`);
  for (const x of zywe) console.log(`   ✗ ŻYWE ${x.plik} · ${x.data} — przyszłe kryterium bez nośnika w kanonie`);
  if (echa.length) console.log(`   ⓘ echa (pamięć świadczy o przeszłości, bez akcji): ${[...new Set(echa.map(x => x.data))].join(', ')}`);
  console.log('   (jednostka: para zdanie×data — straz_kryteriow liczy ZDANIA; różnica liczb = różnica jednostek, nie sprzeczność)');
  console.log('   (PRAWO PAMIĘCI: pamięć świadczy, zobowiązuje kanon — bez pary = kryterium bez czytnika)');
  return { pam: pam.length, zPara: zPara.length, bezPary };
}

// ── POWRÓT (delegacja do anatomii — jedno źródło czytelników) ────────────────
function powrot() {
  try {
    const out = execSync('node narzedzia/przyrzady/anatomia.js', { cwd: ROOT, encoding: 'utf8' });
    const m = out.match(/osieroconych[^:]*:\s*(\d+)/);
    const org = [...out.matchAll(/^\s+(\S+)\s+(\d+)\s+\d+\s+(\d+)/gm)]
      .filter(x => +x[3] > 0).map(x => `${x[1]}:${x[3]}`);
    console.log(`▸ POWRÓT (Collector's Fallacy · źródło: anatomia.js): sierot ${m ? m[1] : '?'}` +
      (org.length ? ` (${org.join(' · ')})` : ''));
    console.log('   wartość archiwum = powrót do użycia, nie rozmiar; przegląd sierot = ręka twórcy (♻ przed ✂)');
  } catch (e) { console.log('▸ POWRÓT: anatomia.js niedostępna — sekcja pominięta jawnie'); }
}

// ── SNAPSHOT v1 (standard porównywalności map — ratyfikacja twórcy 15.08:
//    „ujednolicajmy i standaryzujmy") ─────────────────────────────────────────
// KOLUMNY STAŁE v1 (zmiana zestawu = v2 + nowy rejestr, nigdy ciche przedefiniowanie):
// data | eter | dest | blizny | ✓ | wDr | bez | dopływ28/t | odpływ28/t | maxWiek | B2żywe | sieroty
function wierszSnapshotu(d) {
  return `| ${d.data} | ${d.eter} | ${d.dest} | ${d.blizny} | ${d.zmech} | ${d.wDr} | ${d.bez} | ` +
         `${d.doplyw} | ${d.odplyw} | ${d.maxWiek} | ${d.b2zywe} | ${d.sieroty} | v1 |`;
}
function snapshot() {
  const b = czytaj(BLEDY);
  const k = klasyfikuj(b);
  const eter = (czytaj(path.join(ROOT, F_ETER)).match(/^#{2,3} .*2026/gm) || []).length;
  const dest = (czytaj(path.join(ROOT, F_DEST)).match(/^## Destylat/gm) || []).length;
  const blizny = (b.match(/^## #\d+/gm) || []).length;
  const daty = datyBlizn(b);
  const prog28 = new Date(DZIS - 28 * 86400000).toISOString().slice(0, 10);
  const doplyw = (Object.values(daty).filter(d => d >= prog28).length / 4).toFixed(2);
  let odplyw = '∅', first = {};
  try { first = gitPierwszeCheck().first;
    odplyw = (Object.values(first).filter(d => d >= prog28).length / 4).toFixed(2); } catch (e) {}
  const wieki = k.wDrodze.map(n => daty[n] ? dniOd(daty[n]) : null).filter(x => x !== null);
  const maxWiek = wieki.length ? Math.max(...wieki) : '∅';
  // B2 żywe: przelicz bez druku
  let b2zywe = '∅';
  try {
    const pam = [];
    for (const f of PAMIEC) { const p = path.join(ROOT, f); if (!fs.existsSync(p)) continue;
      for (const z of zdaniaKryteriow(czytaj(p))) for (const d of datyZeZdania(z)) pam.push(d); }
    const kanon = new Set();
    for (const p of plikiKanonu()) { const t = czytaj(p);
      for (const l of t.split('\n')) { if (!l.includes('⌛') || /\[x\]|ROZLICZONE|WYKONANE|BEZPRZEDMIOTOWE/.test(l)) continue;
        for (const d of datyZeZdania(l)) kanon.add(d); }
      for (const z of zdaniaKryteriow(t)) for (const d of datyZeZdania(z)) kanon.add(d); }
    const dzisIso = DZIS.toISOString().slice(0, 10);
    b2zywe = pam.filter(d => !kanon.has(d) && d >= dzisIso).length;
  } catch (e) {}
  let sieroty = '∅';
  try { const out = execSync('node narzedzia/przyrzady/anatomia.js', { cwd: ROOT, encoding: 'utf8' });
    const m = out.match(/osieroconych[^:]*:\s*(\d+)/); if (m) sieroty = m[1]; } catch (e) {}
  console.log(wierszSnapshotu({ data: DZIS.toISOString().slice(0, 10), eter, dest, blizny,
    zmech: k.zmech.length, wDr: k.wDrodze.length, bez: k.bez.length, doplyw, odplyw, maxWiek, b2zywe, sieroty }));
}

// ── TOR --test (fikstury syntetyczne; mutacje celują tutaj) ──────────────────
function test() {
  let ok = 0, zle = 0;
  const t = (nazwa, war) => { if (war) { ok++; } else { zle++; console.log(`  ✗ ${nazwa}`); } };
  const FIX = [
    '| 1 | x | p | POMIAR | **M✓** | s |',
    '| 2 | x | p | INNA | M | s |',
    '| 3 | x | p | INNA | POSTAWA | s |',
    '| 4 | x | p | INNA | R | s |',
    '## #1 — coś (01.07.2026)', '## #2 — coś (16.07)', '## #4 — bez daty tu',
  ].join('\n');
  const k = klasyfikuj(FIX);
  t('T1 klasyfikator: ✓/M/POSTAWA/bez = 1/1/1/1',
    k.zmech.join() === '1' && k.wDrodze.join() === '2' && k.postawa.join() === '3' && k.bez.join() === '4');
  const d = datyBlizn(FIX);
  t('T2a daty nagłówków: #1=2026-07-01, #2=2026-07-16', d['1'] === '2026-07-01' && d['2'] === '2026-07-16');
  t('T2b brak daty NIE zmyśla się (#4 nieobecny)', !('4' in d));
  const fp = pierwszeZobaczenie([
    { data: '2026-07-01', zbior: new Set(['1']) },
    { data: '2026-07-10', zbior: new Set(['1', '2']) },
    { data: '2026-07-20', zbior: new Set(['2']) }, // #1 znika — pierwsze zobaczenie ZOSTAJE
  ]);
  t('T3 tempo: pierwsze zobaczenie trwałe (#1=01.07, #2=10.07)',
    fp['1'] === '2026-07-01' && fp['2'] === '2026-07-10');
  const zd = zdaniaKryteriow('Akapit. Kryterium życia: do 20.08.2026 musi wstać. To ZATRZYMAŁA: kryterium śmierci 01.01. Zwykłe zdanie.');
  t('T4a parytet: łapie twarde zdanie, pomija ZATRZYMAŁA:', zd.length === 1 && /20\.08/.test(zd[0]));
  t('T4b parytet: data ze zdania → ISO', datyZeZdania(zd[0])[0] === '2026-08-20');
  const w6 = wierszSnapshotu({ data: '2026-08-15', eter: 1, dest: 2, blizny: 3, zmech: 4, wDr: 5, bez: 6, doplyw: '7.00', odplyw: '8.00', maxWiek: 9, b2zywe: 10, sieroty: 11 });
  t('T6 snapshot v1: 13 kolumn, stała kolejność, stempel wersji',
    w6.split('|').length === 15 && w6.endsWith('| v1 |') && w6.startsWith('| 2026-08-15 | 1 | 2 | 3 | 4 | 5 | 6 |'));
  const pb = podzielBezPary([{ data: '2026-07-27' }, { data: '2026-12-31' }], '2026-08-15');
  t('T5 parytet: przeszłe=echo, przyszłe=żywe', pb.echa.length === 1 && pb.zywe.length === 1 && pb.zywe[0].data === '2026-12-31');
  // T9 (ZERO ZNACZĄCE — warunek formy publicznej, 21.08): u odbiorcy odlewu plików
  // pamięci może NIE BYĆ. Wcześniej `readFileSync` rzucał ENOENT i cały przyrząd padał,
  // czyli w formie publicznej wyglądałby na zepsuty przy pierwszym uruchomieniu.
  // Fikstura ODRÓŻNIALNA (#64): ten sam odczyt na pliku ISTNIEJĄCYM musi zwrócić treść —
  // inaczej „nie wywala się" byłoby nieodróżnialne od „nigdy niczego nie czyta".
  let bezpiecznie = true;
  try { czytaj(path.join(ROOT, 'NIE_MA_TAKIEGO_PLIKU_9x.md')); } catch (e) { bezpiecznie = false; }
  t('T9 brak pliku pamięci nie wywraca przyrządu (zero znaczące)', bezpiecznie);
  t('T9b istniejący plik nadal jest CZYTANY (odróżnialność)',
    czytaj(path.join(ROOT, 'wektory.js')).length > 0);

  console.log(`TOR wektory: ${ok} ✓ · ${zle} ✗`);
  process.exit(zle ? 1 : 0);
}

// ── CLI ──────────────────────────────────────────────────────────────────────
const arg = process.argv.slice(2);
if (arg.includes('--test')) test();
const wybor = arg.length ? arg : ['lancuch', 'wiek', 'tempo', 'przeplyw', 'parytet', 'powrot'];
if (wybor.length === 1 && wybor[0] === 'snapshot') { snapshot(); process.exit(0); } // cichy: sam wiersz do rejestru
console.log(`╔═══ WEKTORY — dynamika ciała ═══╗  ⏱ zmierzone: ${DZIS.toISOString().slice(0, 10)}`);
let k = null, first = null;
if (wybor.includes('lancuch')) k = lancuch();
if (wybor.includes('wiek')) wiek(k);
if (wybor.includes('tempo')) first = tempo();
if (wybor.includes('przeplyw')) przeplyw(first);
if (wybor.includes('parytet')) parytet();
if (wybor.includes('powrot')) powrot();
console.log('(przyrząd świeci, nie kroi — dźwignie i cięcia należą do twórcy)');
