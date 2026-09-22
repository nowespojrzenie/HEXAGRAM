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

// ── CIAŁO PRZED NARODZINAMI (N1+/Z, 21.09.2026) ──────────────────────────────────────────────
// Zmierzone 21.09 na świeżym klonie HEXAGRAM (K2): `START_TU.md` odsyła do `ZAPISY_eter.md` i
// `DESTYLATY_architekta.md`, które zakłada dopiero `narodziny.sh` — lint meldował rc=1 o stanie
// NORMALNYM przed aktem. Sygnał Z = `⟠ ZALĄŻEK` otwiera wiersz w DUSZA.md; lista plików aktu to
// linia `# PLIKI_AKTU:` w `narodziny.sh` (JEDNO źródło, jej zgodność z aktem asertuje tor tamtego
// skryptu). Tylko odwołania do plików Z TEJ LISTY schodzą do ⓘ (z liczbą i nazwami — nie milczy);
// każde inne złamane odwołanie zostaje ✗ także przed narodzinami, a bez sygnału Z nic nie schodzi.
function rozdzielPrzedNarodzinami(root, zle) {
  const dusza = path.join(root, 'DUSZA.md'), nar = path.join(root, 'narodziny.sh');
  if (!fs.existsSync(dusza) || !/^⟠ ZALĄŻEK/m.test(fs.readFileSync(dusza, 'utf8'))) return { zle, info: [] };
  const m = fs.existsSync(nar) ? fs.readFileSync(nar, 'utf8').match(/^# PLIKI_AKTU: *(.+)$/m) : null;
  const lista = m ? m[1].trim().split(/\s+/) : [];
  const info = [], twarde = [];
  for (const z of zle) (lista.includes(z.sciezka.replace(/^\.\//, '')) ? info : twarde).push(z);
  return { zle: twarde, info };
}

function raport(zle, etykieta, info = []) {
  if (info.length) {
    const nazwy = [...new Set(info.map(z => z.sciezka))];
    console.log(`  ⓘ odwołań do plików, które powstaną przy narodzinach: ${info.length} (plików: ${nazwy.length} — ${nazwy.join(', ')}) — nie błąd, ciało przed aktem`);
  }
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
  // (N1+/Z) CIAŁO PRZED NARODZINAMI — pary +/−: z sygnałem Z odwołanie do pliku z PLIKI_AKTU → ⓘ (rc=0);
  // bez sygnału ten sam brak → ✗; z sygnałem, ale brak pliku SPOZA listy → ✗ (lista nie jest furtką).
  fs.unlinkSync(path.join(tmp,'zwolniony.md'));
  fs.writeFileSync(path.join(tmp,'narodziny.sh'), '#!/bin/sh\n# PLIKI_AKTU: kanon/ksiegi/ZAPISY_eter.md _STRAZ_APPEND.txt\n');
  fs.writeFileSync(path.join(tmp,'start.md'), 'zobacz `kanon/ksiegi/ZAPISY_eter.md` (powstanie przy akcie)\n');
  const DUSZA_Z = '# DUSZA\n\n```\n⟠ ZALĄŻEK — tkanka nowego twórcy\n```\n';
  fs.writeFileSync(path.join(tmp,'DUSZA.md'), DUSZA_Z);
  const sz = rozdzielPrzedNarodzinami(tmp, skan(tmp));
  const rcZ = raport(sz.zle, 'TEST ⓘ (przed narodzinami: brak pliku z PLIKI_AKTU, MUSI przepuścić z ⓘ)', sz.info);
  const zOk = rcZ === 0 && sz.info.length === 1;
  fs.writeFileSync(path.join(tmp,'DUSZA.md'), '# DUSZA\n\nDusza żyje.\n');
  const sn = rozdzielPrzedNarodzinami(tmp, skan(tmp));
  const rcBezZ = raport(sn.zle, 'TEST − (dusza żywa, ten sam brak, MUSI oblać)', sn.info);
  fs.writeFileSync(path.join(tmp,'DUSZA.md'), DUSZA_Z);
  fs.writeFileSync(path.join(tmp,'start.md'), 'zobacz `kanon/ksiegi/ZAPISY_eter.md` oraz `kanon/ksiegi/INNY_plik.md`\n');
  const sp = rozdzielPrzedNarodzinami(tmp, skan(tmp));
  const rcSpoza = raport(sp.zle, 'TEST − (⟠ jest, brak pliku SPOZA PLIKI_AKTU, MUSI oblać)', sp.info);
  fs.rmSync(tmp,{recursive:true,force:true});
  if (rcZly === 1 && rcDobry === 0 && rcZwol === 0 && zOk && rcBezZ === 1 && rcSpoza === 1 && sp.zle.length === 1) { console.log('\n  ✓ STRAŻ ŻYWA: oblała chorego, przepuściła zdrowego, uszanowała zwolnienie.'); process.exit(0); }
  console.log(`\n  ✗ STRAŻ MARTWA — zly=${rcZly} dobry=${rcDobry} zwolniony=${rcZwol} przednarodz=${zOk} bezZ=${rcBezZ} spozaListy=${rcSpoza}`); process.exit(1);
}

// ── ZAKRES: domyślnie TYLKO to, co wychodzi na świat ──
// Blizna była konkretna: złamany link w PUBLICZNYM odlewie. Skan całego repo daje ~100 trafień,
// w większości uzasadnionych (narzedzia/silniki/plan_okien.js #32, PROMPT_skille usunięty świadomie, repa obce,
// placeholdery typu skills/<nazwa>). Straż, która krzyczy 100 razy, nie jest czytana —
// to nasza własna pułapka „gate inflation" z ai-self-audit-without-hedging.
const BIALA_LISTA = ['README.md','START_TU.md','JADRO.md','skills'];
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
const surowe = CALE ? skan(process.cwd()) : skanWybrane(process.cwd(), BIALA_LISTA);
const wynik = rozdzielPrzedNarodzinami(process.cwd(), surowe);
process.exit(raport(wynik.zle, CALE ? 'ODWOŁANIA (całe repo)' : 'ODWOŁANIA W FORMIE', wynik.info));
