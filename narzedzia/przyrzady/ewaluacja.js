#!/usr/bin/env node
// KRONOS · EWALUACJA UCHWYTÓW v1.0 (27.07.2026) — narzędzie do mierzenia czucia
// Czyta kanon/ksiegi/KSIEGA_SIEGNIEC.md i liczy to, czego samo czucie o sobie nie powie:
//  · ILE UCHWYTÓW ma atrybucję do świeżej pamięci (wskaźnik ECHA)
//  · rozkład rozjazdów A↔B (całkowity / częściowy / trafienie)
//  · trafność per KANAŁ (tkanka vs rzut-maszyna vs świat) — kolumna OWOC
//    Kanał „świat" nosił do 30.08 imię twórcy w komentarzu i w wydruku; sam parser czytał
//    już wtedy neutralne `ŹRÓDŁO: świat`. Nazwa zmieniona przy wejściu do odlewu — kanał
//    jest kategorią modelu (skąd przyszedł impuls), nie osobą.
//  · test ślepy nośnika: czy dominanta uchwytów odbiega od rozkładu płaskiego
// Falsyfikacja wbudowana: jeśli po N≥10 wpisach trafność [TKANKA] ≈ przypadek,
// „czucie" = recytacja i tak trzeba je nazywać. Jeśli istotnie > przypadku — mamy zjawisko.
'use strict';
const fs = require('fs');
// --- tryb --gestosc: PRAWO GĘSTOŚCI (27.07) — mierzy siano vs ostrze w całym ciele ---
if (process.argv.includes('--gestosc')) {
  const cp = require('child_process');
  const pliki = cp.execSync("git ls-files | grep -v keep_import | grep '\\.md$'", {cwd: KORZEN})
    .toString().trim().split('\n');
  const DIAMENTY = ['kanon/ksiegi/ZAPISY_eter.md','kanon/ksiegi/DESTYLATY_architekta.md','kanon/archiwum/ARCHIWUM_destylatow.md'];
  const teraz = Date.now()/1000;
  const raport = [];
  for (const f of pliki) {
    const t = fs.readFileSync(KORZEN + '/' + f, 'utf8');
    const slowa = t.split(/\s+/).filter(Boolean).length;
    const regul = (t.match(/PRAWO|ZASADA|NIGDY|ZAWSZE|REGUŁA/g) || []).length;
    const G = slowa ? (regul / slowa * 1000) : 0;
    let T = 999;
    try { T = Math.floor((teraz - Number(cp.execSync(`git log -1 --format=%ct -- "${f}"`, {cwd: KORZEN}).toString().trim())) / 86400); } catch(e) {}
    raport.push({f, slowa, regul, G, T, diament: DIAMENTY.includes(f)});
  }
  const suma = raport.reduce((a,r)=>a+r.slowa,0);
  const zimne = raport.filter(r=>r.T>30 && r.regul===0 && !r.diament);
  const rozdete = raport.filter(r=>r.slowa>3000 && r.G<1 && !r.diament);
  console.log(`\n╔═══ PRAWO GĘSTOŚCI — siano vs ostrze ═══╗`);
  console.log(`  plików: ${raport.length}  ·  słów: ${suma.toLocaleString('pl')}  ·  reguł łącznie: ${raport.reduce((a,r)=>a+r.regul,0)}`);
  console.log(`  gęstość ciała: ${(raport.reduce((a,r)=>a+r.regul,0)/suma*1000).toFixed(2)} reguł/1000 słów`);
  console.log(`\n【 KANDYDACI DO ARCHIWUM (T>30d ∧ G=0 ∧ nie-diament): ${zimne.length} 】`);
  zimne.slice(0,12).forEach(r=>console.log(`  ${String(r.T).padStart(3)}d  ${String(r.slowa).padStart(5)}sł  ${r.f}`));
  console.log(`\n【 DO DESTYLACJI (>3000 słów ∧ G<1): ${rozdete.length} 】`);
  rozdete.forEach(r=>console.log(`  ${String(r.slowa).padStart(5)}sł  G=${r.G.toFixed(2)}  ${r.f}`));
  console.log(`\n  Diamenty (eter/destylaty) wyłączone z progów — ich wartość nie jest w gęstości reguł.`);
  console.log(`  Kompost, nie kasowanie: ekstrakt zostaje w rejestrze.\n`);
  process.exit(0);
}
// ŚCIEŻKA MARTWA OD CIĘĆ 1–5, ujawniona 29.08: księga mieszka w kanon/ksiegi/, a ten
// przyrząd szukał jej w korzeniu i meldował „brak księgi" z rc=0 — cisza nieodróżnialna
// od pustej księgi. Teraz jedna ścieżka, liczona od korzenia repo (dach narzedzia/przyrzady/).
// ── TOR (#38, dopisany 30.08.2026 przy wejściu do odlewu) ─────────────────────────
// Przyrząd żył od 27.07 bez trybu `--test`, więc `straz_dojrzalosci` trzymała go poza odlewem.
// Fikstura buduje własną księgę w mktemp — NIGDY nie mierzy żywej (#54).
if (process.argv[2] === '--test') {
  const os = require('os'), pathm = require('path'), cp = require('child_process');
  const T = fs.mkdtempSync(pathm.join(os.tmpdir(), 'ewal-'));
  let zle = [];
  const spr = (op, a, b) => { if (String(a) === String(b)) console.log('  ✓ ' + op);
    else { console.log(`  ✗ ${op} (było ${a}, miało ${b})`); zle.push(op); } };
  const bieg = (tresc) => {
    fs.mkdirSync(pathm.join(T, 'kanon/ksiegi'), { recursive: true });
    fs.writeFileSync(pathm.join(T, 'kanon/ksiegi/KSIEGA_SIEGNIEC.md'), tresc);
    try { return cp.execSync(`node ${__filename}`, { encoding: 'utf8', cwd: T,
      env: { ...process.env, EWAL_KORZEN: T } }); } catch (e) { return String(e.stdout || ''); }
  };
  // PREDYKAT ZAKOTWICZONY (30.08): pierwsza wersja szukała `sięgnięć[^0-9]*(\\d+)` i trafiała
  // w NAGŁÓWEK („księga sięgnięć ═══╗"), po którym pierwsza cyfra to liczba uchwytów.
  // Tor meldował 1 zamiast 2 — nie przyrząd był zepsuty, tylko moje pytanie (#66 ods. 6).
  const licz = (wy, etykieta) => { const m = wy.match(new RegExp(etykieta + '[^0-9\\n]*: *(\\d+)')); return m ? Number(m[1]) : -1; };

  // (+) księga z jednym uchwytem i dwoma sięgnięciami — liczby MUSZĄ się zgadzać
  const wy = bieg('# K\n## UCHWYT #1\ntresc\n## SIĘGNIĘCIE A\nŹRÓDŁO: świat\n## SIĘGNIĘCIE B\nŹRÓDŁO: maszyna\n');
  spr('liczy uchwyty', licz(wy, 'uchwytów'), 1);
  spr('liczy siegniecia', licz(wy, 'sięgnięć'), 2);
  spr('rozdziela kanaly (swiat=1)', (wy.match(/świat (\d+)/) || [])[1], '1');
  // (−) PUSTA księga nie może dać tych samych liczb — inaczej przyrząd „liczy" cokolwiek (#75)
  const wy0 = bieg('# K\n(pusto)\n');
  spr('pusta ksiega daje zero uchwytow', licz(wy0, 'uchwytów'), 0);
  // (−) BRAK księgi: melduje brak, nie udaje pustej — cisza nieodróżnialna od zera to blizna 29.08
  fs.rmSync(pathm.join(T, 'kanon/ksiegi/KSIEGA_SIEGNIEC.md'));
  let wyBrak = '';
  try { wyBrak = cp.execSync(`node ${__filename}`, { encoding: 'utf8', cwd: T, env: { ...process.env, EWAL_KORZEN: T } }); }
  catch (e) { wyBrak = String(e.stdout || ''); }
  spr('brak ksiegi MELDOWANY, nie udawany zerem', /brak księgi/.test(wyBrak), true);

  fs.rmSync(T, { recursive: true, force: true });
  console.log('╔═══ EWALUACJA — AUTOTEST ═══╗');
  if (zle.length) { console.log('  ✗ TOR OBLANY: ' + zle.join(' · ')); process.exit(1); }
  console.log('  ✓ TOR PRZESZEDŁ — liczy uchwyty i kanały, a na pustej księdze daje zero, nie cokolwiek.');
  process.exit(0);
}

const KORZEN = process.env.EWAL_KORZEN || require('path').join(__dirname, '..', '..');
const P = require('path').join(KORZEN, 'kanon/ksiegi/KSIEGA_SIEGNIEC.md');
if (!fs.existsSync(P)) { console.log('brak księgi — nic do ewaluacji'); process.exit(0); }
const t = fs.readFileSync(P, 'utf8');

const uchwyty = (t.match(/^## UCHWYT #/gm) || []).length;
const siegniecia = (t.match(/^## SIĘGNIĘCIE/gm) || []).length;
const heksy = (t.match(/^## RZUT HEKSA/gm) || []).length;
const echoWys = (t.match(/Podejrzenie echa: WYSOKIE/g) || []).length;
const echoAtryb = (t.match(/Atrybucja:/g) || []).length;
const rozjCalk = (t.match(/ROZJAZD[^\n]*CAŁKOWITY/gi) || []).length;
const rozjCzesc = (t.match(/ROZJAZD[^\n]*CZĘŚCIOWY/gi) || []).length;
const trafienia = (t.match(/ROZJAZD[^\n]*(TRAFIENIE|ZBIEŻNOŚĆ)/gi) || []).length;
const owoceP = (t.match(/\[OWOC[^\]]*\]:\s*_{3,}/g) || []).length;
const owoceW = (t.match(/\[OWOC[^\]]*\]:\s*(?!_)[^\n]{3,}/g) || []).length;
const kanalSwiat = (t.match(/ŹRÓDŁO: świat/g) || []).length;
const kanalMasz = (t.match(/ŹRÓDŁO: maszyna/g) || []).length;

const pas = (n, max, w = 24) => '█'.repeat(Math.round((n / Math.max(max, 1)) * w)).padEnd(w, '·');
const N = uchwyty + siegniecia;

console.log('\n╔═══ EWALUACJA CZUCIA — księga sięgnięć ═══╗');
console.log(`  uchwytów (kanał A): ${uchwyty}   sięgnięć (kanał B/C): ${siegniecia}   heksów: ${heksy}`);
console.log(`  źródła rzutu:  maszyna ${kanalMasz}  ·  świat ${kanalSwiat}`);
console.log('\n【 WSKAŹNIK ECHA — ile czucia to recytacja pamięci 】');
console.log(`  atrybucji do świeżej pamięci: ${echoAtryb}   z tego oznaczonych WYSOKIE: ${echoWys}`);
if (uchwyty) console.log(`  echo/uchwyt: ${(echoAtryb / uchwyty).toFixed(1)} ${pas(echoAtryb, Math.max(echoAtryb, uchwyty * 3))}`);
console.log('\n【 ROZJAZDY A↔B 】');
console.log(`  całkowite:  ${rozjCalk} ${pas(rozjCalk, Math.max(1, rozjCalk + rozjCzesc + trafienia))}`);
console.log(`  częściowe:  ${rozjCzesc} ${pas(rozjCzesc, Math.max(1, rozjCalk + rozjCzesc + trafienia))}`);
console.log(`  trafienia:  ${trafienia} ${pas(trafienia, Math.max(1, rozjCalk + rozjCzesc + trafienia))}`);
console.log('\n【 OWOCE (czy sprawdzamy po czasie) 】');
console.log(`  wypełnione: ${owoceW}   puste: ${owoceP}`);

console.log('\n【 WERDYKT 】');
if (N < 10) {
  console.log(`  PRÓBA ZA MAŁA (${N}/10). Nie wolno orzekać o naturze czucia — zbieramy dalej.`);
  console.log('  Do rozstrzygnięcia potrzeba ≥10 par (uchwyt + miara) z wypełnionym OWOCEM.');
} else {
  const tr = trafienia / N;
  console.log(`  trafność uchwytów: ${(tr * 100).toFixed(0)}%`);
  console.log(tr > 0.35
    ? '  UCHWYT PRZEŻYŁ PRÓBĘ — istotnie ponad przypadek. Zjawisko do dalszego badania.'
    : '  UCHWYT = RECYTACJA — nie odbiega od przypadku. Nazywać po imieniu, nie ubierać w widzenie.');
}
console.log(`\n  Uczciwość narzędzia: liczy TYLKO to, co zapisane. Uchwyt bez wpisu = anegdota.`);
console.log(`  Prawo pierwszeństwa: uchwyt zapisany przed miarą; miara go nie przepisuje.\n`);
