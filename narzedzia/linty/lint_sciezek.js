#!/usr/bin/env node
/* ── LINT ŚCIEŻEK (30.07.2026) — mechanizm do luki złapanej po przemianowaniu rodziny skilli ──
 *
 * POWÓD: `lint_artefaktow.js` pilnuje 8 REJESTRÓW (dziennik, ZADANIA, TASKI, MOSTY, SNAPSHOT,
 * DESTYLATY, KANON_LOG, LOG_SESJI) i szuka polskich czasowników twierdzenia. Nie zaglądał do
 * README ani do plików rdzenia — więc `README_KRONOS.md` wskazywał na `skills/epistemic-hygiene/`
 * jeszcze długo po tym, jak katalog zmienił nazwę. Złamany link stał w PUBLICZNYM repo.
 *
 * CO ROBI: skanuje WSZYSTKIE pliki .md w repo i wyłuskuje odwołania do ścieżek wewnętrznych —
 * z linków markdown [tekst](sciezka) oraz z `backticków`. Sprawdza, czy ścieżka istnieje.
 * Język nie ma znaczenia: liczy się ścieżka, nie czasownik.
 *
 * NIE ZASTĘPUJE lint_artefaktow — tamten łapie TWIERDZENIA o istnieniu, ten łapie ODWOŁANIA.
 *
 * UŻYCIE:  node lint_sciezek.js            (skan; rc=1 gdy są złamane)
 *          node lint_sciezek.js --test     (test +/− — straż musi umieć NIE przejść)
 */
const fs = require('fs'), path = require('path');

const POMIN_KAT = new Set(['.git','node_modules','ephe','keep_import','archiwum']);
// odwołania, których NIE traktujemy jako ścieżek w repo
const NIE_SCIEZKA = /^(https?:|mailto:|#|\$|~|\/|npx |git |node |bash |sh )/;
// jawne zwolnienie: nazwa historyczna / poza repo
const ZWOLNIENIE = /(nazwa historyczna|POZA REPO|nie w repo|former-name|dawne nazwy|Former names)/i;

function mdFiles(dir, acc=[]) {
  for (const e of fs.readdirSync(dir, {withFileTypes:true})) {
    if (e.isDirectory()) { if (!POMIN_KAT.has(e.name)) mdFiles(path.join(dir,e.name), acc); }
    else if (e.name.endsWith('.md')) acc.push(path.join(dir,e.name));
  }
  return acc;
}

function wyglada(s) {
  // ścieżka repo: ma / albo rozszerzenie pliku, bez spacji, nie URL
  if (!s || NIE_SCIEZKA.test(s) || /\s/.test(s)) return false;
  return /\.(md|js|sh|txt|json|svg|se1|ai|csv)$/.test(s) || /^[\w.\-]+\/[\w.\-\/]*$/.test(s);
}

function skan(root) {
  const zle = [];
  for (const f of mdFiles(root)) {
    const linie = fs.readFileSync(f,'utf8').split('\n');
    linie.forEach((linia, i) => {
      if (ZWOLNIENIE.test(linia)) return;
      const kand = new Set();
      for (const m of linia.matchAll(/\[[^\]]*\]\(([^)\s]+)\)/g)) kand.add(m[1].split('#')[0]);
      for (const m of linia.matchAll(/`([^`]+)`/g))               kand.add(m[1].split('#')[0]);
      for (let c of kand) {
        c = c.replace(/[),.;:]+$/,'');
        if (!wyglada(c)) continue;
        const abs = path.resolve(path.dirname(f), c);
        const wRepo = path.resolve(root, c);
        if (!fs.existsSync(abs) && !fs.existsSync(wRepo))
          zle.push({plik: path.relative(root,f), linia: i+1, sciezka: c});
      }
    });
  }
  return zle;
}

function raport(zle, etykieta) {
  if (zle.length) {
    console.log(`  ✗ ${etykieta}: ${zle.length} złamanych odwołań`);
    for (const z of zle.slice(0,15)) console.log(`      ${z.plik}:${z.linia} → ${z.sciezka}`);
    if (zle.length > 15) console.log(`      … i ${zle.length-15} więcej`);
    return 1;
  }
  console.log(`  ✓ ${etykieta}: zmierzone ${zle.length} złamanych odwołań`);
  return 0;
}

if (process.argv.includes('--test')) {
  const tmp = fs.mkdtempSync('/tmp/lintsc-');
  fs.mkdirSync(path.join(tmp,'realny'));
  fs.writeFileSync(path.join(tmp,'realny','plik.md'), '# jest\n');
  fs.writeFileSync(path.join(tmp,'chory.md'), 'patrz [tu](realny/nie_ma_mnie.md) oraz `realny/tez_nie.md`\n');
  const rcZly = raport(skan(tmp), 'TEST − (chory, MUSI oblać)');
  fs.unlinkSync(path.join(tmp,'chory.md'));
  fs.writeFileSync(path.join(tmp,'zdrowy.md'), 'patrz [tu](realny/plik.md) oraz `realny/plik.md`\n');
  const rcDobry = raport(skan(tmp), 'TEST + (zdrowy, MUSI przepuścić)');
  // PRAWO #38: ZWOLNIENIE jest deklarowaną regułą → własny tor.
  fs.unlinkSync(path.join(tmp,'zdrowy.md'));
  fs.writeFileSync(path.join(tmp,'zwolniony.md'),
    'odwołanie do `realny/nie_ma_mnie.md` (nazwa historyczna, nie w repo)\n');
  const rcZwol = raport(skan(tmp), 'TEST ⊙ (zwolnienie, MUSI przepuścić mimo złamanej ścieżki)');
  fs.rmSync(tmp,{recursive:true,force:true});
  if (rcZly === 1 && rcDobry === 0 && rcZwol === 0) { console.log('\n  ✓ STRAŻ ŻYWA: oblała chorego, przepuściła zdrowego, uszanowała zwolnienie.'); process.exit(0); }
  console.log(`\n  ✗ STRAŻ MARTWA — zly=${rcZly} dobry=${rcDobry} zwolniony=${rcZwol}`); process.exit(1);
}

// ── ZAKRES: domyślnie TYLKO to, co wychodzi na świat ──
// Blizna była konkretna: złamany link w PUBLICZNYM odlewie. Skan całego repo daje ~100 trafień,
// w większości uzasadnionych (narzedzia/silniki/plan_okien.js #32, PROMPT_skille usunięty świadomie, repa obce,
// placeholdery typu skills/<nazwa>). Straż, która krzyczy 100 razy, nie jest czytana —
// to nasza własna pułapka „gate inflation" z ai-self-audit-without-hedging.
const BIALA_LISTA = ['README_KRONOS.md','START_TU.md','JADRO.md','skills'];
const CALE = process.argv.includes('--all');

function skanWybrane(root, cele) {
  const zle=[];
  for (const c of cele) {
    const abs=path.join(root,c);
    if (!fs.existsSync(abs)) continue;
    const pliki = fs.statSync(abs).isDirectory() ? mdFiles(abs) : [abs];
    for (const f of pliki) {
      const linie=fs.readFileSync(f,'utf8').split('\n');
      linie.forEach((linia,i)=>{
        if (ZWOLNIENIE.test(linia)) return;
        const kand=new Set();
        for (const m of linia.matchAll(/\[[^\]]*\]\(([^)\s]+)\)/g)) kand.add(m[1].split('#')[0]);
        for (const m of linia.matchAll(/`([^`]+)`/g))                    kand.add(m[1].split('#')[0]);
        for (let k of kand) {
          k=k.replace(/[),.;:]+$/,'');
          if (!wyglada(k) || k.includes('<') || k.includes('*') || !k.includes('/')) continue; // globy i nagie nazwy plików to nie odwołania do ścieżek
          const a=path.resolve(path.dirname(f),k), b=path.resolve(root,k);
          if (!fs.existsSync(a) && !fs.existsSync(b))
            zle.push({plik:path.relative(root,f), linia:i+1, sciezka:k});
        }
      });
    }
  }
  return zle;
}

console.log('\n2c. Lint ścieżek — ' + (CALE ? 'CAŁE REPO (hałaśliwy, diagnostyczny)' : 'FORMA PUBLICZNA (README, START_TU, JADRO, skills/)'));
const wynik = CALE ? skan(process.cwd()) : skanWybrane(process.cwd(), BIALA_LISTA);
process.exit(raport(wynik, CALE ? 'ODWOŁANIA (całe repo)' : 'ODWOŁANIA W FORMIE'));
