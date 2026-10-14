#!/usr/bin/env node
// mapa_ciala — jeden narząd autofagii (AUTOFAGIA.md §8.1, spec Opusa 13.10, słowo twórcy 13.10 12:40).
// Plik żyje, gdy ma czytelnika z adresem: mechanizm (skrypt go otwiera), umysł (R0 / wejścia ról) albo
// łańcuch dokumentów o długości ≤ 2 skoków od takiego korzenia. Liczy, nie pisze (poza --szereg).
//
// BLOKADA: 107 plików ciała bez czytelnika, niewidocznych dla miar W1–W16 (pomiar 13.10 12:0x, 77df95c)
// ŚMIERĆ:  30 dni, w których lista KOMPOST rośnie, a nikt jej nie wykonał (narząd stał się szumem)
// ZASTĘPUJE: ręczne W1, W3, W4, W9, W14, W16, S1–S4 i budżet pierścieni R1/R2 w wstan.sh
//
// UŻYCIE:  node mapa_ciala.js               jedna linia ▤ MAPA CIAŁA
//          node mapa_ciala.js --pelny       tabela per katalog + 20 najcięższych KOMPOST/ŁAŃCUCH
//          node mapa_ciala.js --lista [--od <sha>]   same ścieżki KOMPOST (--od: tylko dodane od <sha>)
//          node mapa_ciala.js --lancuch     lista ŁAŃCUCH (3+ skoki) do osądu Opusa, nie do git rm
//          node mapa_ciala.js --sieroty     NIKT z wiekiem i organem (z anatomii)
//          node mapa_ciala.js --martwe [N]  NIKT bez ruchu ≥ N dni (domyślnie 14)
//          node mapa_ciala.js --organ X     spis jednego organu: wiek · liczba czytelników · pieczęć
//          node mapa_ciala.js --duplikaty [próg] [prefiks]  pary podobne TREŚCIĄ (5-gramy + Jaccard; prefiks np. narzedzia/)
//          node mapa_ciala.js --zombi       wpis otwarty w TASKI/ZADANIA, a artefakt już istnieje
//          node mapa_ciala.js --czytelnicy <plik>  karta PRZED CIĘCIEM: osiem warstw + klasa narządu, werdykt ostatni
//          node mapa_ciala.js --liczba      sama liczba NIKT (dla wektory.js)
//          node mapa_ciala.js --szereg      linia + wiersz „RRRR-MM-DD mapa_ciala N” do ALARMY_szereg.txt
//          node mapa_ciala.js --test        tor +/− (fikstura w pamięci; mutacja „limit skoków 0” musi oblać)
// SCAL 13.10.2026 (AUTOFAGIA §8.2 pkt 1 + §8.3): narząd przejął funkcje `anatomia.js` (15.08; sieroty, organ, martwe, duplikaty, zombi),
// `przed_cieciem.js` (15.08; karta jednego pliku) i ciężar ksiąg z `pomiar_ksiag.sh` (18.09; sekcja WAGA w --pelny). Tamte trzy → KOMPOST.
// ZNANE OGRANICZENIE: odwołanie = ścieżka albo nazwa pliku z rozszerzeniem (.md .txt .js .sh .json) jako osobny
// token; martwe skrypty wołające się nawzajem wciąż podtrzymują się przy życiu (brak czytelnika spoza klastra).
'use strict';
const fs = require('fs');
const path = require('path');
const { execFileSync } = require('child_process');

const SKOKI = process.env.MAPA_SKOKI !== undefined ? Number(process.env.MAPA_SKOKI) : 2;
const POZA = ['projekty/', 'prywatne/', 'szablony/', 'ephe/', 'node_modules/', 'keep_import/'];
const BINARIA = /\.(pdf|png|jpe?g|gif|ico|webp|zip|gz|tgz|bin|xlsx?|docx?|pptx?|mp[34]|mov|woff2?|ttf|otf|se1|bmp|svg|jar)$/i;
const R0 = ['DUSZA.md', '0_SNAPSHOT_watek.md', '0_WYWOLANIA.md'];
const WEJSCIA_ROL = [/^AGENTS\.md$/, /^CLAUDE\.md$/, /^START_TU\.md$/, /^README\.md$/, /^\.claude\/skills\/[^/]+\/SKILL\.md$/, /^\.claude\/agents\/[^/]+\.md$/, /^skills\/[^/]+\/SKILL\.md$/];
const ZRODLA_MECH = /\.(sh|js|json|bat|cmd)$/;
const DOKUMENT = /\.(md|txt)$/;
const TKANKA_STALA = [/^prerejestr\//, /^kanon\/pomiary\/ZAPIS_biegi\//, /^kanon\/pomiary\/ALARMY_szereg\.txt$/,
  // rodzaj zwalniający (AUTOFAGIA krok 5, 14.10): wyniki eksperymentów czekają na odczyt, nie na czytelnika (kanon/eksperymenty/goscie celowo poza listą — dane #018)
  /^kanon\/eksperymenty\/(skille\/pilot|skille\/przebieg-research|stol\/rzuty)\//];
// Plan autofagii wymienia kandydatów do KOMPOSTU po nazwie — wzmianka w nim nie jest czytelnikiem (inaczej plan podtrzymywałby przy życiu wszystko, co każe skasować).
const NIE_CZYTELNIK = new Set(['kanon/plany/linienie/AUTOFAGIA.md']);
// Spisy GENEROWANE (SPIS_CIALA.md, SPIS_PROJEKTOW.md) wymieniają wszystko, co istnieje — spis nie jest czytelnikiem (13.10: po regeneracji SPIS_CIALA cała mapa urosła do ŻYWE 576).
const SPIS_GENEROWANY = /^kanon\/ksiegi\/SPIS_[A-Z_]+\.md$/;
// KARTKI SESJI = TKANKA SESJI (AUTOFAGIA §8.3, 13.10): czytane mechanizmem (straz_feromonow, zapis_git), więc nie NIKT.
// Własne kryterium KOMPOST: WSZYSTKIE bloki STATUS = ODDANE ∧ ostatni commit starszy niż 14 dni.
const KARTKI = /^kanon\/ksiegi\/kartki\//;
const KARTKA_PROG_DNI = 14;
function kartkaDoKompostu(tresc, dni, prog = KARTKA_PROG_DNI) {
  const statusy = [...tresc.matchAll(/^\*\*STATUS:\*\*\s*(\S+)/gm)].map((m) => m[1]);
  return statusy.length > 0 && statusy.every((x) => x === 'ODDANE') && dni !== null && dni > prog;
}
const ROZSZERZENIA_MOSTU = /\.(md|txt|js|sh|json)$/;

process.stdout.on('error', (e) => { if (e.code === 'EPIPE') process.exit(0); throw e; });
const w = (s) => process.stdout.write(s + '\n');
const wBlad = (s) => process.stderr.write(s + '\n');

function wZakresie(p) {
  if (POZA.some((x) => p.startsWith(x))) return false;
  if (BINARIA.test(p)) return false;
  if (/^LICENSE/i.test(path.basename(p))) return false;
  return true;
}

function tokeny(tresc) {
  const out = new Set();
  for (let t of tresc.split(/[^\p{L}\p{N}_.\-/]+/u)) {
    t = t.replace(/^(\.\/)+/, '').replace(/[.\-]+$/, '');
    if (!t || t.length < 3) continue;
    out.add(t);
    if (t.includes('/')) out.add(path.posix.basename(t));
  }
  return out;
}

// pliki: Map ścieżka → treść ('' dla pominiętych/dużych). opcje: {tkanka:Set, skoki, istnieje:Set (wszystkie śledzone)}
function analizuj(pliki, opcje) {
  const skoki = opcje.skoki !== undefined ? opcje.skoki : SKOKI;
  const tkankaSet = new Set(opcje.tkanka || []);
  const wszystkie = opcje.istnieje || new Set(pliki.keys());
  const cialo = [...pliki.keys()].filter(wZakresie);
  const kartkiKompost = new Set(opcje.kartkiKompost || []);
  const jestTkanka = (p) => tkankaSet.has(p) || (KARTKI.test(p) && !kartkiKompost.has(p)) || (opcje.stala || TKANKA_STALA).some((re) => re.test(p));

  // indeks nazw → pliki ciała (nie-tkanka)
  const poNazwie = new Map(); const poSciezce = new Map();
  for (const p of cialo) {
    if (jestTkanka(p)) continue;
    poSciezce.set(p, p);
    const b = path.posix.basename(p);
    if (!poNazwie.has(b)) poNazwie.set(b, []);
    poNazwie.get(b).push(p);
  }
  const dzieci = (p, tok) => {
    const r = new Set();
    for (const t of tok) {
      if (poSciezce.has(t) && t !== p) r.add(t);
      const lista = poNazwie.get(t);
      if (lista) for (const q of lista) if (q !== p) r.add(q);
    }
    return r;
  };

  // korzenie
  const klasa = new Map(); const gleb = new Map(); const kolejka = [];
  const dodaj = (p, k, g) => { if (!klasa.has(p)) { klasa.set(p, k); gleb.set(p, g); kolejka.push(p); } };
  for (const p of cialo) {
    if (jestTkanka(p)) continue;
    if (R0.includes(p)) dodaj(p, 'R0', 0);
  }
  for (const p of cialo) {
    if (jestTkanka(p)) continue;
    if (WEJSCIA_ROL.some((re) => re.test(p))) dodaj(p, 'ROLA', 0);
  }
  // MECH: wejścia konfiguracyjne (ładowane przez git/npm/harness) + odwołanie w treści innego skryptu / haka
  for (const p of cialo) {
    if (jestTkanka(p)) continue;
    if (/^\./.test(p) || /^package(-lock)?\.json$/.test(p)) dodaj(p, 'MECH', 0);
  }
  const zrodla = cialo.filter((p) => ZRODLA_MECH.test(p) || p.startsWith('.githooks/'));
  for (const s of zrodla) {
    const tok = tokeny(pliki.get(s) || '');
    for (const q of dzieci(s, tok)) dodaj(q, 'MECH', 0);
  }

  // BFS przez dokumenty (korzenie-dokumenty i dokumenty osiągnięte; tkanka nie propaguje)
  for (let i = 0; i < kolejka.length; i++) {
    const p = kolejka[i];
    if (!DOKUMENT.test(p) || NIE_CZYTELNIK.has(p) || SPIS_GENEROWANY.test(p)) continue;
    if (gleb.get(p) >= 99) continue;
    const tok = tokeny(pliki.get(p) || '');
    for (const q of dzieci(p, tok)) {
      if (klasa.has(q)) continue;
      const g = gleb.get(p) + 1;
      const k = klasa.get(p) === 'R0' ? 'R1' : klasa.get(p) === 'R1' ? 'R1' : klasa.get(p);
      klasa.set(q, k); gleb.set(q, g); kolejka.push(q);
    }
  }

  const wynik = [];
  for (const p of cialo) {
    let kl;
    if (jestTkanka(p)) kl = 'TKANKA';
    else if (!klasa.has(p)) kl = 'NIKT';
    else if (gleb.get(p) > skoki) kl = 'ŁAŃCUCH';
    else kl = klasa.get(p);
    wynik.push({ p, kl, glebia: gleb.has(p) ? gleb.get(p) : null, bajty: Buffer.byteLength(pliki.get(p) || '', 'utf8') });
  }

  // mosty zerwane: odwołanie ze ścieżką do pliku, którego nie ma — ze źródeł ŻYWYCH i ŁAŃCUCHA, bez tkanki,
  // z pominięciem linii „(nazwa historyczna)”
  const mosty = [];
  const zywe = new Set(wynik.filter((r) => r.kl !== 'NIKT' && r.kl !== 'TKANKA').map((r) => r.p));
  const sufiksy = [...wszystkie];
  for (const p of zywe) {
    if (!DOKUMENT.test(p)) continue;
    const dir = path.posix.dirname(p);
    for (const linia of (pliki.get(p) || '').split('\n')) {
      if (/nazwa historyczna/i.test(linia)) continue;
      for (let t of linia.split(/[^\p{L}\p{N}_.\-/]+/u)) {
        t = t.replace(/^(\.\/)+/, '').replace(/[.\-]+$/, '');
        if (!t.includes('/') || !ROZSZERZENIA_MOSTU.test(t)) continue;
        if (/^[/~]/.test(t) || t.includes('//') || t.startsWith('..')) continue;
        const pierwszy = t.split('/')[0];
        if (pierwszy.includes('.') && !pierwszy.startsWith('.')) continue;   // adresy www
        if (/^(node_modules|ephe)\//.test(t)) continue;
        if (wszystkie.has(t) || wszystkie.has(path.posix.join(dir, t))) continue;
        if (sufiksy.some((s) => s.endsWith('/' + t))) continue;
        mosty.push({ zrodlo: p, cel: t });
      }
    }
  }
  return { wynik, mosty };
}

function podsumuj(a, sciezki = []) {
  const n = { ZYWE: 0, TKANKA: 0, LANCUCH: 0, KOMPOST: 0 };
  const kb = { TKANKA: 0, KOMPOST: 0, LANCUCH: 0, ZYWE: 0 };
  for (const r of a.wynik) {
    const k = r.kl === 'TKANKA' ? 'TKANKA' : r.kl === 'NIKT' ? 'KOMPOST' : r.kl === 'ŁAŃCUCH' ? 'LANCUCH' : 'ZYWE';
    n[k]++; kb[k] += r.bajty / 1024;
  }
  return { n, kb, mosty: a.mosty.length, w14: licznikW14(sciezki) };
}

function wczytajRepo() {
  const git = (...a) => execFileSync('git', ['-c', 'core.quotepath=false', ...a], { encoding: 'utf8', maxBuffer: 1 << 28 });
  const lista = git('ls-files', '-z').split('\0').filter(Boolean);
  const pliki = new Map();
  for (const p of lista) {
    if (!wZakresie(p)) { pliki.set(p, ''); continue; }
    try {
      const st = fs.statSync(p);
      pliki.set(p, st.size > 1500000 ? '' : fs.readFileSync(p, 'utf8'));
    } catch (e) { /* plik śledzony, ale nieobecny na dysku (usunięty, niezacommitowany) */ }
  }
  let tkanka = [];
  try {
    const h = fs.readFileSync('hashuj.sh', 'utf8');
    const m = h.match(/TKANKA="([^"]*)"/);
    if (m) tkanka = m[1].replace(/\\\n/g, ' ').split(/\s+/).filter(Boolean);
  } catch (e) { /* brak hashuj.sh (odlew/gość) — tkanka tylko ze stałych wzorców */ }
  return { pliki, tkanka, istnieje: new Set(pliki.keys()) };
}

function wiekiOstatnichCommitow(sciezki) {
  const mapa = new Map();
  try {
    const out = execFileSync('git', ['-c', 'core.quotepath=false', 'log', '--format=@%ct', '--name-only'], { encoding: 'utf8', maxBuffer: 1 << 28 });
    let t = 0;
    for (const l of out.split('\n')) {
      if (l.startsWith('@')) { t = Number(l.slice(1)); continue; }
      if (l && !mapa.has(l)) mapa.set(l, t);
    }
  } catch (e) { /* bez historii (płytki klon) — wiek nieznany */ }
  const teraz = Date.now() / 1000;
  return (p) => (mapa.has(p) ? Math.floor((teraz - mapa.get(p)) / 86400) : null);
}

function ostatniWierszSzeregu(plik) {
  try {
    const l = fs.readFileSync(plik, 'utf8').split('\n').filter((x) => / mapa_ciala \d+\s*$/.test(x));
    if (!l.length) return null;
    return { linia: l[l.length - 1], wartosc: Number(l[l.length - 1].match(/mapa_ciala (\d+)/)[1]), data: l[l.length - 1].slice(0, 10) };
  } catch (e) { return null; }
}

// W14 (§8.2 pkt 2): nazwy-kopie (regex ścieżek) + pliki w katalogu archiwum — bez sieci; gałęzie zdalne zostają komendą §4.
const KOPIA_RE = /(_stara|_old|_v[0-9]|_kopia|_bak|\.orig)/i;
function licznikW14(sciezki) {
  const nazw = sciezki.filter((p) => KOPIA_RE.test(p)).length;
  const archiwum = sciezki.filter((p) => /^kanon\/archiwum\//.test(p) || /^archiwum\//.test(p)).length;
  return { nazw, archiwum };
}
function liniaPodsumowania(s, delta) {
  const d = delta === null ? 'Δ brak wiersza w szeregu' : `Δ ${delta > 0 ? '+' : ''}${delta} do ostatniego wiersza szeregu`;
  return `▤ MAPA CIAŁA: ŻYWE ${s.n.ZYWE} · TKANKA ${s.n.TKANKA} (${Math.round(s.kb.TKANKA)} KB) · ŁAŃCUCH ${s.n.LANCUCH} · KOMPOST ${s.n.KOMPOST} (${Math.round(s.kb.KOMPOST)} KB) · mosty zerwane ${s.mosty} · kopie W14 ${s.w14.nazw + s.w14.archiwum} (nazw ${s.w14.nazw} · archiwum ${s.w14.archiwum}) · ${d}`;
}

// ── SCAL: z anatomii, przed_cieciem i pomiar_ksiag ───────────────────────────────────────────
const SKLAD_RE = /^(keep_import|archiwum|kanon\/archiwum)\//;
const ORGANY = [
  ['SKŁADNICA',   f => SKLAD_RE.test(f)],
  ['FORMA',       f => /^skills\//.test(f) || /^do_publikacji\//.test(f) || /^(README|START_TU|INSTALL|JADRO)/.test(f)],
  ['DORADCY',     f => /^doradcy\//.test(f)],
  ['BADANIA',     f => /^prerejestr\//.test(f) || /^(PROGNOZY|PROBY_wartosci|SAMOOBSERWACJA|UCHWYTY|ROZMOW|KSIEGA_SIEGNIEC|SIEGNIECIE)/.test(path.basename(f))],
  ['PAMIĘĆ',      f => /^(ZAPISY_eter|DESTYLATY_architekta|LOG_SESJI|PRZESWIT_eter)\.md$/.test(path.basename(f))],
  ['KSIĘGI',      f => /^(BLEDY|KOLEJKA_M|TASKI|ZADANIA|MOSTY|KANON_LOG|PYTANIA_PROGOW)\.md$/.test(path.basename(f))],
  ['PRZYRZĄDY',   f => /\.(sh|js)$/.test(path.basename(f)) && /^(straz_|lint_|tory_|mutacje|weryfikacja|hashuj|pokrycie|gotowosc|zapis_git|publikuj|zniwo|prog_|rzut|plan_okien|licznik_|bateria_|skan_|testy_|ewaluacja|mapa_ciala|wstan)/.test(path.basename(f))],
  ['SILNIKI',     f => /\.(js|py)$/.test(f)],
  ['RDZEŃ',       f => /^(DUSZA|0_|1_|2_|3_|4_|5_|6_|7_|PIEC_INWARIANTOW|SUBSTRAT|ARCHITEKT_istnienie|PROTOKOL_|ATRAKTOR_)/.test(path.basename(f))],
  ['TKANKA',      () => true],
];
const organ = (f) => (ORGANY.find(([, t]) => t(f)) || ['?'])[0];

// kto (z korpusu [[ścieżka, treść]]) wymienia plik po nazwie bazowej albo ścieżce; sam siebie nie czyta
function czytelnicyLista(cel, korpus) {
  const base = path.posix.basename(cel);
  const r = [];
  for (const [nazwa, tresc] of korpus) {
    if (nazwa === cel || path.posix.basename(nazwa) === base) continue;
    if (tokeny(tresc).has(base) || tokeny(tresc).has(cel)) r.push(nazwa);
  }
  return r;
}
// objęcie ZBIOROWE: katalog wymieniony jako cała całość (biała lista publikacji), bez wskazania pliku
function objetyZbiorowo(katalog, korpus) {
  if (!katalog) return false;
  const wzory = [`"${katalog}`, ` ${katalog} `, `${katalog}"`, '`' + katalog + '`', `${katalog}/*`];
  return korpus.filter(([, t]) => wzory.some((x) => t.includes(x))).map(([f]) => f);
}
function pieciogramy(tresc) {
  const ws = tresc.toLowerCase().replace(/[^a-ząćęłńóśźż0-9\s]/g, ' ').split(/\s+/).filter((x) => x.length > 3);
  const set = new Set();
  for (let i = 0; i + 4 < ws.length; i++) set.add(ws.slice(i, i + 5).join(' '));
  return set;
}
function jaccard(A, B) {
  let inter = 0;
  for (const x of A) if (B.has(x)) inter++;
  return inter / (A.size + B.size - inter);
}
function werdykt(wk) {
  if (!wk.istnieje) return ['BRAK', 'pliku nie ma — nie ma czego rozstrzygać'];
  if (wk.nietykalny) return ['NIETYKALNY', 'pamięć / prerejestr / księga sięgnięć — cięcie wykluczone z mocy #24'];
  const powody = [];
  if (wk.czytelnicy.length) powody.push(`czyta go ${wk.czytelnicy.length} plik(ów)`);
  if (wk.zbiorowo.length) powody.push(`wynoszony zbiorowo przez ${wk.zbiorowo.length}`);
  if (wk.mapa.length) powody.push(`zna go mapa: ${wk.mapa.join(', ')}`);
  if (wk.most) powody.push('jest brzegiem mostu');
  if (wk.unikalnychLinii > 0) powody.push(`ma ${wk.unikalnychLinii} linii, których nie ma bliźniak`);
  if (powody.length) return ['ŻYWY', powody.join(' · ')];
  return ['KANDYDAT', 'wszystkie warstwy milczą — to zgoda na ROZMOWĘ o cięciu, nie na cięcie'];
}
const tekstowy = (f) => /\.(md|sh|js|txt|json|html|py)$/.test(f);
function korpusRepo(repo) {
  return [...repo.pliki.keys()].filter((f) => tekstowy(f) && !SKLAD_RE.test(f) && !/^(ephe|node_modules)\//.test(f)).map((f) => [f, repo.pliki.get(f) || '']);
}
function plytki() {
  try { return execFileSync('git', ['rev-parse', '--is-shallow-repository'], { encoding: 'utf8' }).trim() === 'true'; } catch (e) { return false; }
}
const NIEZM = 'niezmierzone (klon płytki — pełny klon albo `git fetch --unshallow`)';

function kartaPrzedCieciem(cel, repo, a) {
  const base = path.posix.basename(cel);
  const katalog = cel.includes('/') ? cel.split('/')[0] : null;
  const t = fs.existsSync(cel) ? fs.readFileSync(cel, 'utf8') : '';
  const korpus = korpusRepo(repo).filter(([f]) => f !== cel);
  const wk = { istnieje: t.length > 0, pierwszaLinia: (t.split('\n')[0] || '').slice(0, 80), bajtow: t.length };
  wk.czytelnicy = czytelnicyLista(cel, korpus);
  wk.zbiorowo = katalog ? objetyZbiorowo(katalog, korpus) : [];
  wk.mapa = ['DUSZA.md', 'wstan.sh', 'weryfikacja.js', '_HASHE.txt'].filter((m) => (repo.pliki.get(m) || (fs.existsSync(m) ? fs.readFileSync(m, 'utf8') : '')).includes(base));
  wk.blizniak = null; wk.unikalnychLinii = null;
  if (t.length > 200) {
    const A = pieciogramy(t); let best = [0, null];
    for (const [f, c] of korpus) { if (c.length < 200) continue; const jac = jaccard(A, pieciogramy(c)); if (jac > best[0]) best = [jac, f]; }
    if (best[0] > 0.12) {
      wk.blizniak = { plik: best[1], podobienstwo: Math.round(best[0] * 100) };
      const norm = (l) => l.trim().toLowerCase().replace(/[|`*_#>-]/g, ' ').replace(/\s+/g, ' ').trim();
      const wszystkie = new Set();
      for (const [, c] of korpus) for (const l of c.split('\n').map(norm)) if (l.length > 40) wszystkie.add(l);
      wk.unikalnychLinii = t.split('\n').map(norm).filter((l) => l.length > 40 && !wszystkie.has(l)).length;
    }
  }
  wk.most = (repo.pliki.get('kanon/ksiegi/MOSTY.md') || '').includes(base);
  wk.nietykalny = /^(ZAPISY_eter|DESTYLATY_architekta|LOG_SESJI|PRZESWIT_eter)\.md$/.test(cel) || /^prerejestr\//.test(cel) || /^KSIEGA_SIEGNIEC\.md$/.test(cel);
  try { wk.ostatni = execFileSync('git', ['log', '-1', '--format=%cI · %an · %s', '--', cel], { encoding: 'utf8' }).trim().slice(0, 100); } catch (e) { wk.ostatni = '?'; }
  const r = a.wynik.find((x) => x.p === cel);
  wk.klasa = r ? r.kl + (r.glebia !== null ? ` (${r.glebia} skoki od korzenia)` : '') : 'poza ciałem narządu';
  // klasa narządu jest dodatkowym powodem „żywy” tylko gdy to korzeń/żywe — nie dubluje warstw 2–6
  wk.klasaZywa = r && !['NIKT', 'TKANKA'].includes(r.kl);
  return wk;
}
function pokazKarte(cel, wk) {
  const [v, d] = werdykt(wk);
  w(`\n╔═ KARTA PRZED CIĘCIEM · ${cel}`);
  w(`  1 CZYM JEST    ${wk.bajtow} B · ${wk.pierwszaLinia}`);
  w(`  2 CZYTELNICY   ${wk.czytelnicy.length}${wk.czytelnicy.length ? ': ' + wk.czytelnicy.slice(0, 4).join(', ') : ''}`);
  w(`  3 ZBIOROWO     ${wk.zbiorowo.length}${wk.zbiorowo.length ? ': ' + wk.zbiorowo.slice(0, 4).join(', ') : ''}`);
  w(`  4 MAPA         ${wk.mapa.length ? wk.mapa.join(', ') : '—'}`);
  w(`  5 UZYSK        ${wk.blizniak ? `bliźniak ${wk.blizniak.plik} (${wk.blizniak.podobienstwo}%) · linii tylko tutaj: ${wk.unikalnychLinii}` : '— (brak bliźniaka)'}`);
  w(`  6 MOST         ${wk.most ? 'TAK — brzeg pary w kanon/ksiegi/MOSTY.md' : '—'}`);
  w(`  7 NIETYKALNY   ${wk.nietykalny ? 'TAK' : '—'}`);
  w(`  8 DRUGA RĘKA   ${wk.ostatni}`);
  w(`  9 KLASA NARZĄDU ${wk.klasa}`);
  w(`  ⇒ WERDYKT: ${v} — ${d}\n`);
}
function wagaKsiag() {
  const pliki = ['AGENTS.md', '0_WYWOLANIA.md', 'START_TU.md', 'JADRO.md', 'DUSZA.md', 'README.md', 'kanon/ksiegi/BLEDY.md', 'kanon/ksiegi/DESTYLATY_architekta.md', 'mutacje.txt'];
  w('\n── WAGA KSIĄG — co model niesie (z pomiar_ksiag.sh) ──');
  for (const f of pliki) {
    if (!fs.existsSync(f)) { w('  ' + f.padEnd(40) + ' (brak)'); continue; }
    const t = fs.readFileSync(f, 'utf8');
    w('  ' + f.padEnd(40) + String(t.split('\n').length - (t.endsWith('\n') ? 1 : 0)).padStart(5) + ' linii ' + String(Buffer.byteLength(t, 'utf8')).padStart(8) + ' B');
  }
  try { w(`  ── plików .md w repo: ${execFileSync('git', ['ls-files', '*.md'], { encoding: 'utf8' }).split('\n').filter(Boolean).length}`); } catch (e) { /* bez gita */ }
}
function zombi() {
  const rejestry = ['prywatne/TASKI.md', 'prywatne/ZADANIA.md'].filter((f) => fs.existsSync(f));
  let n = 0;
  w('\n⌘ KANDYDACI NA ZOMBI — wpis otwarty, artefakt istnieje:');
  for (const rej of rejestry) {
    fs.readFileSync(rej, 'utf8').split('\n').forEach((l, i) => {
      if (!/^- \[ \]/.test(l)) return;
      const art = [...l.matchAll(/`([A-Za-z0-9_\-/]+\.(?:sh|js|md))`/g)].map((m) => m[1]);
      const ist = art.filter((x) => fs.existsSync(x));
      if (!ist.length) return;
      n++;
      w(`  ${rej}:${i + 1} · istnieje: ${ist.join(', ')}`);
      w(`      ${l.slice(0, 120)}`);
    });
  }
  if (!n) w('  (brak — każdy otwarty wpis mówi o czymś, czego jeszcze nie ma)');
  w('  (artefakt bywa kontekstem, nie produktem — czytaj wpis, nie tylko nazwę pliku)\n');
}
function duplikaty(prog, prefiks, repo) {
  const pliki = [...repo.pliki.keys()].filter((f) => /\.(md|sh|js)$/.test(f) && !SKLAD_RE.test(f) && !/^(ephe|node_modules)\//.test(f) && (!prefiks || f.startsWith(prefiks)));
  const M = pliki.map((f) => [f, pieciogramy(repo.pliki.get(f) || '')]).filter(([, st]) => st.size > 30);
  const wyn = [];
  for (let i = 0; i < M.length; i++) for (let j = i + 1; j < M.length; j++) { const jac = jaccard(M[i][1], M[j][1]); if (jac > prog) wyn.push([jac, M[i][0], M[j][0]]); }
  wyn.sort((x, y) => y[0] - x[0]);
  w(`\n⌘ PODOBNE TREŚCIĄ (próg ${(prog * 100).toFixed(0)}%${prefiks ? ', prefiks ' + prefiks : ''}, porównanych ${M.length}): ${wyn.length} par`);
  for (const [j, x, y] of wyn) w(`  ${(j * 100).toFixed(0)}%  ${x}  ∥  ${y}`);
  w('  (bliźniactwo bywa zamierzone — sprawdź MOSTY, zanim uznasz za duplikat)\n');
}

// ── TOR +/− ──────────────────────────────────────────────────────────────────────────────────
function fikstura() {
  const p = new Map([
    ['AGENTS.md', 'wejście. Czytaj a.md oraz uruchom t.sh oraz kanon/pozno.md oraz kanon/plany/linienie/AUTOFAGIA.md oraz kanon/ksiegi/SPIS_CIALA.md'],
    ['a.md', 'dalej b.md i kanon/nieistnieje.md\nkanon/historia_z_dawna.md (nazwa historyczna)'],
    ['b.md', 'dalej x.md'],
    ['x.md', 'dalej y.md'],
    ['y.md', 'koniec'],
    ['kanon/plany/linienie/AUTOFAGIA.md', 'kandydat do KOMPOSTU: e.md'],
    ['e.md', 'wymieniony tylko w planie autofagii'],
    ['kanon/ksiegi/SPIS_CIALA.md', 'spis generowany: f.md'],
    ['f.md', 'wymieniony tylko w spisie generowanym'],
    ['t.sh', 'cat s.md'],
    ['s.md', 'żyje przez mechanizm'],
    ['c.md', 'wskazuje d.md'],
    ['d.md', 'nikt nie czyta c.md'],
    ['kanon/rej.md', 'rejestr bez czytelnika'],
    ['kanon/pozno.md', 'ok'],
    ['DUSZA.md', 'zerówka: patrz r1.md'],
    ['r1.md', 'osobowość'],
  ]);
  return { pliki: p, tkanka: ['kanon/rej.md'] };
}
function sprawdzFikstura(a) {
  const kl = new Map(a.wynik.map((r) => [r.p, r.kl]));
  const bledy = [];
  const chce = (p, k) => { if (kl.get(p) !== k) bledy.push(`${p}: ${kl.get(p)} ≠ ${k}`); };
  chce('a.md', 'ROLA'); chce('b.md', 'ROLA');            // ≤ 2 skoków od wejścia roli
  chce('x.md', 'ŁAŃCUCH'); chce('y.md', 'ŁAŃCUCH');      // 3+ skoków
  chce('s.md', 'MECH'); chce('t.sh', 'ROLA');             // mechanizm czyta s.md
  chce('c.md', 'NIKT'); chce('d.md', 'NIKT');
  chce('e.md', 'NIKT'); chce('f.md', 'NIKT');                                     // wzmianka w planie autofagii nie jest czytelnikiem
  chce('kanon/rej.md', 'TKANKA');                          // tkanka bez czytelnika nie jest kandydatem
  chce('DUSZA.md', 'R0'); chce('r1.md', 'R1');
  const cele = a.mosty.map((m) => m.cel);
  if (!(cele.length === 1 && cele[0] === 'kanon/nieistnieje.md')) bledy.push('mosty: ' + JSON.stringify(cele));
  return bledy;
}
function tor() {
  let oblane = 0;
  const f = fikstura();
  const dobry = analizuj(f.pliki, { tkanka: f.tkanka, skoki: 2 });
  const bd = sprawdzFikstura(dobry);
  if (bd.length) { oblane++; w('  ✗ tor +: fikstura niezgodna: ' + bd.join(' | ')); } else w('  ✓ tor +: ŻYWE (≤2 skoki, mechanizm, R0/R1), ŁAŃCUCH (3+), NIKT, TKANKA poza kandydatami, 1 most zerwany');
  const lista = dobry.wynik.filter((r) => r.kl === 'NIKT').map((r) => r.p).sort().join(',');
  if (lista !== 'c.md,d.md,e.md,f.md') { oblane++; w('  ✗ tor +: lista KOMPOST = ' + lista); } else w('  ✓ tor +: lista KOMPOST = c.md,d.md,e.md,f.md (bez tkanki, bez łańcucha, bez wzmianek z planu i ze spisu generowanego)');
  // mutacja: limit skoków 0 musi oblać fikstury
  const zmutowany = analizuj(f.pliki, { tkanka: f.tkanka, skoki: 0 });
  if (sprawdzFikstura(zmutowany).length === 0) { oblane++; w('  ✗ tor −: mutacja „limit skoków 0” NIE oblała fikstury (miara nie widzi limitu)'); } else w('  ✓ tor −: mutacja „limit skoków 0” obleciała fikstury');
  // mutacja: tkanka propagująca (czytelnik-dokument = czytelnik) nie może istnieć; tkanka bez listy trafia na KOMPOST
  const bezTkanki = analizuj(f.pliki, { tkanka: [], skoki: 2 });
  const k = bezTkanki.wynik.find((r) => r.p === 'kanon/rej.md');
  if (!k || k.kl !== 'NIKT') { oblane++; w('  ✗ tor −: plik bez czytelnika i bez statusu TKANKI nie trafił do NIKT'); } else w('  ✓ tor −: ten sam plik bez statusu TKANKI trafia do NIKT (lista tkanki działa)');
  // ── testy przejęte z anatomia.js (T1 organy · T2/T3 czytelnicy · T4 kolejność reguł · T6 Jaccard · T7 objęcie zbiorowe · Z1 składnica)
  const ok = (nazwa, war, opis) => { if (war) w(`  ✓ ${nazwa} ${opis}`); else { oblane++; w(`  ✗ ${nazwa} OBLANY — ${opis}`); } };
  ok('T1', organ('narzedzia/straze/straz_kryteriow.sh') === 'PRZYRZĄDY' && organ('narzedzia/silniki/kronos_v4.js') === 'SILNIKI' && organ('kanon/ksiegi/DESTYLATY_architekta.md') === 'PAMIĘĆ'
    && organ('kanon/ksiegi/BLEDY.md') === 'KSIĘGI' && organ('keep_import/x.md') === 'SKŁADNICA' && organ('prerejestr/P.md') === 'BADANIA', 'organy rozpoznane poprawnie');
  ok('T2', czytelnicyLista('widziany.md', [['a.md', 'odwołanie do widziany.md w treści'], ['b.md', 'nic']]).length === 1 && czytelnicyLista('niewidziany.md', [['a.md', 'odwołanie do widziany.md w treści'], ['b.md', 'nic']]).length === 0, 'czytelnicy liczeni w obie strony');
  ok('T3', czytelnicyLista('sam.md', [['sam.md', 'sam.md wspomina sam.md']]).length === 0, 'plik nie jest własnym czytelnikiem');
  ok('T4', organ('kanon/ksiegi/PYTANIA_PROGOW.md') === 'KSIĘGI' && organ('prog_pytan.sh') === 'PRZYRZĄDY', 'kolejność reguł zachowana (pierwsze trafienie wygrywa)');
  ok('T6', jaccard(new Set(['a b c d e', 'b c d e f']), new Set(['a b c d e', 'b c d e f'])) === 1 && jaccard(new Set(['a b c d e']), new Set(['x y z q w'])) === 0, 'miara podobieństwa: bliźniak 100%, obcy 0%');
  ok('T7', objetyZbiorowo('szablony', [['p.sh', 'FORMA_DIRS="ephe szablony skills"']]).length === 1 && objetyZbiorowo('szablony', [['p.sh', 'nic tu nie ma']]).length === 0
    && czytelnicyLista('x.md', [['p.sh', 'FORMA_DIRS="ephe szablony skills"']]).length === 0, 'objęcie zbiorowe ≠ czytelnik (rozdzielone)');
  ok('Z1', organ('kanon/archiwum/x.md') === 'SKŁADNICA' && organ('kanon/archiwumx/y.md') !== 'SKŁADNICA', 'kanon/archiwum = SKŁADNICA');
  // ── testy przejęte z przed_cieciem.js (werdykt ostatni)
  const wk0 = { istnieje: true, nietykalny: false, czytelnicy: [], zbiorowo: [], mapa: [], most: false, unikalnychLinii: 0 };
  ok('W1', werdykt({ ...wk0, nietykalny: true })[0] === 'NIETYKALNY', 'nietykalny nie do cięcia');
  ok('W2', werdykt({ ...wk0, zbiorowo: ['publikuj.sh'] })[0] === 'ŻYWY', 'wynoszony zbiorowo = ŻYWY (zamek na #57)');
  ok('W3', werdykt({ ...wk0, most: true })[0] === 'ŻYWY', 'brzeg mostu = ŻYWY');
  ok('W4', werdykt({ ...wk0, unikalnychLinii: 7 })[0] === 'ŻYWY', 'nieodzyskany uzysk = ŻYWY');
  ok('W5', werdykt(wk0)[0] === 'KANDYDAT', 'pełna cisza = KANDYDAT (nie werdykt cięcia)');
  // ── kartki = TKANKA SESJI
  const od = '**STATUS:** ODDANE 2026-10-01T10:00:00\n', ot = '**STATUS:** OTWARTE · X\n';
  ok('K1', kartkaDoKompostu(od, 20) === true, 'oddana > 14 dni = KOMPOST');
  ok('K2', kartkaDoKompostu(od, 3) === false && kartkaDoKompostu(od, 14) === false, 'oddana ≤ 14 dni = jeszcze TKANKA');
  ok('K3', kartkaDoKompostu(ot, 40) === false && kartkaDoKompostu(od + ot, 40) === false, 'otwarty blok (choćby jeden) = nigdy KOMPOST');
  ok('K4', kartkaDoKompostu(od, null) === false && kartkaDoKompostu('brak statusu\n', 99) === false, 'wiek niezmierzony albo brak STATUS = nie KOMPOST');
  const fk = new Map([['kanon/ksiegi/kartki/A.md', od], ['kanon/ksiegi/kartki/B.md', ot], ['kanon/ksiegi/kartki/C.md', od]]);
  const ak = analizuj(fk, { kartkiKompost: ['kanon/ksiegi/kartki/A.md'] });
  const klk = new Map(ak.wynik.map((r) => [r.p, r.kl]));
  ok('K5', klk.get('kanon/ksiegi/kartki/A.md') === 'NIKT' && klk.get('kanon/ksiegi/kartki/B.md') === 'TKANKA' && klk.get('kanon/ksiegi/kartki/C.md') === 'TKANKA', 'kartka to TKANKA SESJI, na listę wchodzi tylko spełniająca kryterium');
  const fr = new Map([['kanon/eksperymenty/stol/rzuty/r1.md', 'wynik rzutu bez czytelnika']]);
  const kr = (o) => analizuj(fr, o).wynik[0].kl;
  ok('R1', kr({}) === 'TKANKA' && kr({ stala: TKANKA_STALA.slice(0, 3) }) === 'NIKT', 'rzuty stołu bez czytelnika = TKANKA; mutacja bez regexu oblewa (NIKT)');
  // ── licznik W14
  const l14 = licznikW14(['a_old.md', 'b_v2.md', 'PLAN_v1.5.md', 'c.orig', 'x_kopia.txt', 'ok.md', 'kanon/archiwum/p.md', 'kanon/archiwum/q.md', 'zywy/archiwum_nie.md']);
  ok('C1', l14.nazw === 5 && l14.archiwum === 2, 'licznik W14: nazwy-kopie i archiwum liczone osobno');
  ok('C2', licznikW14(['czysty.md', 'kanon/plany/a.md']).nazw === 0 && licznikW14([]).archiwum === 0, 'licznik W14: plik bez kopii i pusta lista = 0');
  w(`  zmierzone: oblanych ${oblane}`);
  return oblane === 0 ? 0 : 1;
}

// ── GŁÓWNE ───────────────────────────────────────────────────────────────────────────────────
function main() {
  const arg = process.argv.slice(2);
  if (arg.includes('--test')) { w('▤ MAPA CIAŁA — AUTOTEST'); process.exit(tor()); }
  const repo = wczytajRepo();
  const kartki = [...repo.pliki.keys()].filter((f) => KARTKI.test(f));
  const wiekKartek = kartki.length && !plytki() ? wiekiOstatnichCommitow() : () => null;
  const kartkiKompost = kartki.filter((f) => kartkaDoKompostu(repo.pliki.get(f) || '', wiekKartek(f)));
  const a = analizuj(repo.pliki, { tkanka: repo.tkanka, istnieje: repo.istnieje, kartkiKompost });
  const s = podsumuj(a, [...repo.istnieje]);
  const szereg = 'kanon/pomiary/ALARMY_szereg.txt';
  const ost = ostatniWierszSzeregu(szereg);
  const delta = ost ? s.n.KOMPOST - ost.wartosc : null;

  const zArg = (flaga) => { const i = arg.indexOf(flaga); return i >= 0 ? arg[i + 1] : undefined; };
  const wiekDni = () => { if (plytki()) return () => null; return wiekiOstatnichCommitow(); };
  const nikt = () => a.wynik.filter((r) => r.kl === 'NIKT');
  if (arg.includes('--liczba')) { w(String(nikt().length)); return; }
  if (arg.includes('--zombi')) { zombi(); return; }
  if (arg.includes('--duplikaty')) {
    const rest = arg.slice(arg.indexOf('--duplikaty') + 1).filter((x) => !x.startsWith('--'));
    const prog = rest.find((x) => /^0?\.\d+$/.test(x));
    const prefiks = rest.find((x) => !/^0?\.\d+$/.test(x));
    duplikaty(prog ? parseFloat(prog) : 0.12, prefiks, repo);
    return;
  }
  if (arg.includes('--czytelnicy')) {
    const cel = zArg('--czytelnicy');
    if (!cel) { wBlad('użycie: mapa_ciala.js --czytelnicy <ścieżka>'); process.exit(2); }
    const wk = kartaPrzedCieciem(cel, repo, a);
    if (wk.klasaZywa && !wk.czytelnicy.length && !wk.zbiorowo.length && !wk.mapa.length && !wk.most) wk.czytelnicy = ['(klasa narządu: ' + wk.klasa + ')'];
    pokazKarte(cel, wk);
    return;
  }
  if (arg.includes('--sieroty') || arg.includes('--martwe')) {
    const wiek = wiekDni();
    const prog = arg.includes('--martwe') ? parseInt(zArg('--martwe') || '14', 10) : null;
    const korpus = korpusRepo(repo);
    let lista = nikt().map((r) => ({ ...r, dni: wiek(r.p), zbior: objetyZbiorowo(r.p.includes('/') ? r.p.split('/')[0] : null, korpus).length > 0 }));
    if (prog !== null) lista = lista.filter((r) => !r.zbior && r.dni !== null && r.dni >= prog);
    lista.sort((x, y) => (y.dni ?? 0) - (x.dni ?? 0));
    w(prog === null ? `\n⌘ OSIEROCONE (klasa NIKT) — nikt do nich nie prowadzi (${lista.length}):` : `\n⌘ KANDYDACI DO KOMPOSTU — NIKT, bez ruchu ≥${prog} dni, nie wynoszeni zbiorowo (${lista.length}):`);
    for (const r of lista) w(`  ${String(r.dni ?? '?').padStart(3)} dni · ${organ(r.p).padEnd(11)} · ${r.zbior ? '[wynoszony zbiorowo] ' : ''}${r.p}`);
    if (plytki()) w(`  · wiek bez ruchu: ${NIEZM}`);
    w('  (brak czytelnika ≠ zbędny; znaczy: niewidoczny — najpierw uzysk, potem cięcie)\n');
    return;
  }
  if (arg.includes('--organ')) {
    const org = (zArg('--organ') || '').toUpperCase();
    const wiek = wiekDni();
    const tok = korpusRepo(repo).map(([f, c]) => [f, tokeny(c)]);
    const hashe = repo.pliki.get('_HASHE.txt') || '';
    for (const r of a.wynik.filter((x) => organ(x.p) === org)) {
      const b = path.posix.basename(r.p);
      const czyt = tok.filter(([f, t]) => f !== r.p && path.posix.basename(f) !== b && (t.has(b) || t.has(r.p))).length;
      w(`  ${String(wiek(r.p) ?? '?').padStart(3)} dni · czyt ${String(czyt).padStart(3)} · ${hashe.includes('  ' + r.p + '\n') ? '🔒' : '  '} ${r.p}`);
    }
    return;
  }
  if (arg.includes('--lista')) {
    let kand = a.wynik.filter((r) => r.kl === 'NIKT').map((r) => r.p);
    const i = arg.indexOf('--od');
    if (i >= 0 && arg[i + 1]) {
      const dod = new Set(execFileSync('git', ['diff', '--diff-filter=A', '--name-only', arg[i + 1], 'HEAD'], { encoding: 'utf8' }).split('\n').filter(Boolean));
      kand = kand.filter((p) => dod.has(p));
    }
    kand.sort().forEach((p) => w(p));
    return;
  }
  if (arg.includes('--lancuch')) {
    a.wynik.filter((r) => r.kl === 'ŁAŃCUCH').sort((x, y) => x.glebia - y.glebia || x.p.localeCompare(y.p)).forEach((r) => w(`${r.glebia} skoki  ${r.p}`));
    return;
  }
  w(liniaPodsumowania(s, delta));
  if (arg.includes('--pelny')) {
    const katalogi = new Map();
    for (const r of a.wynik) {
      const k = r.p.includes('/') ? r.p.split('/')[0] + (r.p.startsWith('kanon/') ? '/' + r.p.split('/')[1] : '') : '(korzeń)';
      if (!katalogi.has(k)) katalogi.set(k, { ZYWE: 0, TKANKA: 0, LANCUCH: 0, KOMPOST: 0, kb: 0 });
      const e = katalogi.get(k);
      const kk = r.kl === 'TKANKA' ? 'TKANKA' : r.kl === 'NIKT' ? 'KOMPOST' : r.kl === 'ŁAŃCUCH' ? 'LANCUCH' : 'ZYWE';
      e[kk]++; e.kb += r.bajty / 1024;
    }
    w('\n katalog                        ŻYWE TKANKA ŁAŃCUCH KOMPOST     KB');
    for (const [k, e] of [...katalogi.entries()].sort((x, y) => y[1].kb - x[1].kb)) {
      w(' ' + k.padEnd(30) + String(e.ZYWE).padStart(5) + String(e.TKANKA).padStart(7) + String(e.LANCUCH).padStart(8) + String(e.KOMPOST).padStart(8) + String(Math.round(e.kb)).padStart(7));
    }
    const wiek = plytki() ? () => null : wiekiOstatnichCommitow();
    const ciezkie = a.wynik.filter((r) => r.kl === 'NIKT' || r.kl === 'ŁAŃCUCH').sort((x, y) => y.bajty - x.bajty).slice(0, 20);
    w('\n 20 najcięższych KOMPOST/ŁAŃCUCH:');
    for (const r of ciezkie) w('  ' + r.kl.padEnd(8) + String(Math.round(r.bajty / 1024)).padStart(5) + ' KB  ' + (wiek(r.p) === null ? '  ?d' : String(wiek(r.p)).padStart(3) + 'd') + '  ' + r.p);
    w(`\n kartki sesji: ${kartki.length} (TKANKA SESJI) · do KOMPOSTU (wszystkie bloki ODDANE ∧ ostatni commit > ${KARTKA_PROG_DNI} dni): ${kartkiKompost.length}${plytki() ? ' · wiek: ' + NIEZM : ''}`);
    wagaKsiag();
    if (a.mosty.length) {
      w('\n mosty zerwane (pierwsze 20):');
      for (const m of a.mosty.slice(0, 20)) w(`  ${m.zrodlo} → ${m.cel}`);
    }
  }
  if (arg.includes('--szereg')) {
    const dzien = new Date().toLocaleDateString('sv-SE', { timeZone: process.env.KRONOS_TZ || 'Europe/Warsaw' });
    const wiersz = `${dzien} mapa_ciala ${s.n.KOMPOST}`;
    if (!fs.existsSync(path.dirname(szereg))) {   // U2 v1.8.2 F6: u gościa nie ma kanon/pomiary/ — nazwane, nie ENOENT połknięte przez wstan.sh
      w(`   (szereg: brak katalogu ${path.dirname(szereg)} — nie dopisano)`);
    } else if (!(ost && ost.linia.trim() === wiersz)) {
      fs.appendFileSync(szereg, wiersz + '\n');
      w(`   (szereg: dopisano „${wiersz}”)`);
    }
  }
}
main();
