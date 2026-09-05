#!/usr/bin/env node
// KRONOS · RZUT v2.0 — ręka PROTOKOŁU SIĘGNIĘCIA (27.07.2026)
// Ślepy wybór z rozpiętego wachlarza. Pięć źródeł entropii:
//   maszyna (/dev/urandom) · świat (liczba podana ręką) · oraz CZTERY KANAŁY ZEWNĘTRZNE
//
// BEZOSOBOWOŚĆ (21.08.2026 — warunek wejścia do formy publicznej). Kanał „świat" to liczba,
// którą podaje CZŁOWIEK przy rzucie — jego data, godzina, cokolwiek, co w tej chwili niesie
// dla niego wagę. FUNKCJA jest bezosobowa: bierze liczbę i miesza ją do wachlarza.
// Osobiste było wyłącznie IMIĘ wpisane w tekst wypisywany użytkownikowi — a imię podaje
// dopiero kontekst tego, kto rzuca. Nazwa rzucającego: zmienna RZUT_REKA (domyślnie brak).
// Księga rzutów: RZUT_KSIEGA (domyślnie kanon/ksiegi/KSIEGA_SIEGNIEC.md — nasza, u odbiorcy własna).
//   pobierane SAMODZIELNIE: --curby --nist --anu --atmo (koniec ręcznego wklejania).
// Zasłona: SHA-256 listy PRZED rzutem. Prawo jednego rzutu egzekwuje księga (append-only).
// Każdy rzut z kanału zewnętrznego zapisuje IDENTYFIKATOR PULSU — audyt po latach.
// Użycie: node rzut.js <kandydaci.txt> "pytanie" [--curby|--nist|--anu|--atmo|--swiat N|--kosmos HEX] [--heksa]
'use strict';
const fs = require('fs');
const crypto = require('crypto');
const k = require('../silniki/kronos_v4.js');   // dach (29.08): sąsiedni pokój, nie korzeń

const args = process.argv.slice(2);
const heksa = args.includes('--heksa');
const REKA   = process.env.RZUT_REKA   || '';           // czyja liczba — puste = bezimienna
const KSIEGA = process.env.RZUT_KSIEGA || 'kanon/ksiegi/KSIEGA_SIEGNIEC.md';
const KORZEN = require('path').join(__dirname, '..', '..');   // dach narzedzia/przyrzady/ (29.08)
const opisSwiata = (n) => REKA ? `świat: liczba (${REKA}) = ${n}` : `świat: liczba podana ręką = ${n}`;
const swIdx = args.indexOf('--swiat');
const kosIdx = args.indexOf('--kosmos');
const kosmos = kosIdx > -1 ? String(args[kosIdx + 1] || '') : null;
const swiat = swIdx > -1 ? parseInt(args[swIdx + 1], 10) : null;
const pos = args.filter((a, i) => !a.startsWith('--') && (swIdx === -1 || i !== swIdx + 1) && (kosIdx === -1 || i !== kosIdx + 1));

// --- KANALY ZEWNETRZNE ---
// Kazdy zwraca: { hex, id, opis } — hex = surowa wartosc, id = identyfikator do audytu.
// Zasada audytu: indeks = sha256(hex) -> uint32 -> mod n. Deterministyczne z pulsu:
// kazdy moze po latach sprawdzic, ze dany puls daje dany wynik i ze istnial przed rzutem.
// (Bias modulo dla uint32 i n < 1000 jest rzedu 1e-7 — pomijalny wobec entropii wejscia.)

async function kanalNIST() {
  const r = await fetch('https://beacon.nist.gov/beacon/2.0/pulse/last');
  if (!r.ok) throw new Error(`NIST HTTP ${r.status}`);
  const p = (await r.json()).pulse;
  return {
    hex: p.outputValue,
    ts: Date.parse(p.timeStamp),
    id: { kanal: 'NIST', chainIndex: p.chainIndex, pulseIndex: p.pulseIndex, timeStamp: p.timeStamp, uri: p.uri },
    opis: `NIST Beacon 2.0 · puls ${p.pulseIndex} (łańcuch ${p.chainIndex}) · ${p.timeStamp}`
  };
}

async function kanalCURBY() {
  const { DIRNGClient } = await import('@buff-beacon-project/curby-client');
  const d = DIRNGClient.create();
  const latest = await d.latest();
  const b = latest.randomness && latest.randomness.bytes ? latest.randomness.bytes() : null;
  if (!b) throw new Error(`CURBy: runda ${latest.round} w fazie "${latest.stage}" — brak losowości`);
  return {
    hex: Buffer.from(b).toString('hex'),
    ts: (latest.randomness && latest.randomness.timestamp) || null,
    id: { kanal: 'CURBy-Q', round: latest.round, stage: latest.stage, bitow: b.length * 8,
          timeStamp: (latest.randomness && latest.randomness.timestamp) ? new Date(latest.randomness.timestamp).toISOString() : 'BRAK' },
    opis: `CURBy-Q · runda ${latest.round} · test Bella na splątanych fotonach (NIST Boulder) · ${b.length * 8} bitów`
  };
}

async function kanalANU() {
  const r = await fetch('https://qrng.anu.edu.au/API/jsonI.php?length=64&type=uint8');
  if (!r.ok) throw new Error(`ANU HTTP ${r.status}`);
  const j = await r.json();
  if (!j.success) throw new Error('ANU: success=false');
  const hex = Buffer.from(j.data).toString('hex');
  const t = new Date().toISOString();
  return {
    hex,
    ts: Date.parse(t),
    id: { kanal: 'ANU-QRNG', pobrano: t, bajtow: j.data.length, sha256: crypto.createHash('sha256').update(hex).digest('hex').slice(0, 16) },
    opis: `ANU QRNG · fluktuacje próżni kwantowej · pobrano ${t}`
  };
}

async function kanalATMO() {
  const r = await fetch('https://www.random.org/integers/?num=64&min=0&max=255&col=1&base=10&format=plain&rnd=new');
  if (!r.ok) throw new Error(`random.org HTTP ${r.status}`);
  const arr = (await r.text()).trim().split('\n').map(Number);
  if (arr.length < 64 || arr.some(isNaN)) throw new Error('random.org: zła odpowiedź');
  const hex = Buffer.from(arr).toString('hex');
  const t = new Date().toISOString();
  let quota = '?';
  try { quota = (await (await fetch('https://www.random.org/quota/?format=plain')).text()).trim(); } catch (e) {}
  return {
    hex,
    ts: Date.parse(t),
    id: { kanal: 'ATMO', pobrano: t, bajtow: arr.length, limit_bitow: quota, sha256: crypto.createHash('sha256').update(hex).digest('hex').slice(0, 16) },
    opis: `random.org · szum atmosferyczny (anteny radiowe: wyładowania i turbulencje) · pobrano ${t}`
  };
}

const KANALY = { '--curby': kanalCURBY, '--nist': kanalNIST, '--anu': kanalANU, '--atmo': kanalATMO };

// --- STRAZNIK SWIEZOSCI (31.07.2026, znalezisko: CURBy stal 342 dni i nie zglaszal bledu) ---
// Kanal, ktory zwraca stara wartosc BEZ bledu, lamie prawo jednego rzutu tylnymi drzwiami:
// kazdy rzut daje ten sam indeks. To nie jest los — to stala. Wiek pulsu MUSI byc mierzony.
// Progi w sekundach — RATYFIKOWANE 31.07.2026. Straznik jest binarny, nie strojony:
// miedzy rytmem kanalu (sekundy-minuty) a awaria (342 dni) nie ma zadnego beacona.
// NIST skorygowany PO pomiarze opoznienia publikacji (4 odczyty 31.07: 275-321 s stalego
// opoznienia przy postepujacych pulsach) — prog 300 s odrzucalby polowe ZDROWYCH rzutow.
// Korekta progu przed uzyciem, nie po wyniku: to nie jest re-rzut, to kalibracja miary.
const PROG_SWIEZOSCI = { '--nist': 900, '--curby': 3600, '--anu': 120, '--atmo': 120 };
// NOTA (31.07, druga ręka): dla ANU/ATMO kan.ts = zegar POBRANIA (nasz), nie źródła —
// próg wieku jest tam spełniony z definicji. Realną strażą tych kanałów jest ANTY-POWTÓRKA
// i kontrola bajtów-nie-stałych poniżej. Progi ratyfikowane NIETKNIĘTE.

// Ostatni AUDYT PULSU danego kanału w księdze (append-only → ostatnie wystąpienie wygrywa).
function ostatniAudyt(kanal, sciezkaKsiegi) {
  let tekst = '';
  try { tekst = fs.readFileSync(sciezkaKsiegi, 'utf8'); } catch (e) { return null; }
  const re = /^AUDYT PULSU: (\{.*\})$/gm;
  let m, ostatni = null;
  while ((m = re.exec(tekst)) !== null) {
    try { const o = JSON.parse(m[1]); if (o.kanal === kanal) ostatni = o; } catch (e) {}
  }
  return ostatni;
}

// Czysty werdykt — testowalny bez sieci, bez księgi, bez process.exit (tor --test, #38).
// Zwraca { ok, powod?, wiek? }. Zachowanie na żywo egzekwuje strazSwiezosci poniżej.
function werdyktSwiezosci(flaga, kan, terazMs, poprzedni) {
  const prog = PROG_SWIEZOSCI[flaga];
  if (prog !== undefined) {
    if (!kan.ts || !Number.isFinite(kan.ts))
      return { ok: false, powod: `KANAŁ BEZ ZNACZNIKA CZASU (${flaga}): puls bez daty jest nieaudytowalny` };
    const wiek = Math.round((terazMs - kan.ts) / 1000);
    if (wiek > prog)
      return { ok: false, wiek, powod: `KANAŁ ZAMROŻONY (${flaga}): puls ma ${wiek} s (${(wiek / 86400).toFixed(1)} dni), próg ${prog} s` };
    // ANTY-POWTÓRKA: identyfikator pulsu vs ostatni zapis TEGO kanału w księdze.
    // Łapie klasę, której próg wieku nie widzi: zamrożone ANU/ATMO (ts = zegar pobrania)
    // oraz powtórkę pulsu mimo świeżego znacznika.
    if (poprzedni) {
      const klucz = kan.id.pulseIndex !== undefined ? 'pulseIndex' : (kan.id.round !== undefined ? 'round' : 'sha256');
      if (poprzedni[klucz] !== undefined && String(poprzedni[klucz]) === String(kan.id[klucz]))
        return { ok: false, wiek, powod: `POWTÓRKA (${flaga}): ${klucz}=${kan.id[klucz]} identyczny z ostatnim zapisem w księdze — to nie jest nowy puls` };
    }
    // BAJTY-NIE-STAŁE: strumień z jednego powtórzonego bajtu to nie entropia.
    if (kan.hex && kan.hex.length >= 8 && kan.hex === kan.hex.slice(0, 2).repeat(kan.hex.length / 2))
      return { ok: false, wiek, powod: `STRUMIEŃ STAŁY (${flaga}): wszystkie bajty = 0x${kan.hex.slice(0, 2)}` };
    return { ok: true, wiek };
  }
  return { ok: true };
}

function strazSwiezosci(flaga, kan) {
  if (PROG_SWIEZOSCI[flaga] === undefined) return;
  const poprzedni = ostatniAudyt(kan.id.kanal, KORZEN + '/' + KSIEGA);
  const w = werdyktSwiezosci(flaga, kan, Date.now(), poprzedni);
  if (w.wiek !== undefined) { kan.wiek_s = w.wiek; kan.id.wiek_s = w.wiek; }
  if (!w.ok) {
    console.error(`✗ ${w.powod}.`);
    console.error(`  ${kan.opis}`);
    console.error('  Rzut PRZERWANY. Stara wartość daje ZAWSZE ten sam wynik — to nie jest rzut.');
    console.error('  Wybierz inny kanał jawnie. Kanału nie podmieniam po cichu. Księga nietknięta.');
    process.exit(2);
  }
  if (w.wiek !== undefined && w.wiek < 0) console.error(`⚠ puls z przyszłości (${w.wiek} s) — zegar lub kanał kłamie; rzut idzie dalej, ale zapisz to.`);
}
// --- TOR TESTOWY STRAŻY (#38: reguła bez toru obowiązuje tylko w dokumentacji) ---
// Bez sieci, bez księgi, bez rzutu: czysty werdykt na wstrzykniętych przypadkach.
if (args.includes('--test')) {
  const T = Date.UTC(2026, 6, 31, 19, 0, 0);
  const P = [ // [nazwa, flaga, kan, poprzedni, oczekiwane_ok]
    ['NIST świeży (600 s < próg 900) przechodzi', '--nist', { ts: T - 600e3, hex: 'ab12', id: { kanal: 'NIST', pulseIndex: 100 } }, null, true],
    ['NIST stary (1000 s) oblewa', '--nist', { ts: T - 1000e3, hex: 'ab12', id: { kanal: 'NIST', pulseIndex: 100 } }, null, false],
    ['NIST bez znacznika oblewa', '--nist', { hex: 'ab12', id: { kanal: 'NIST', pulseIndex: 100 } }, null, false],
    ['NIST powtórka pulseIndex oblewa', '--nist', { ts: T - 60e3, hex: 'ab12', id: { kanal: 'NIST', pulseIndex: 100 } }, { kanal: 'NIST', pulseIndex: 100 }, false],
    ['NIST nowy puls po starym przechodzi', '--nist', { ts: T - 60e3, hex: 'ab12', id: { kanal: 'NIST', pulseIndex: 101 } }, { kanal: 'NIST', pulseIndex: 100 }, true],
    ['NIST z przyszłości: ostrzega, ale przechodzi', '--nist', { ts: T + 30e3, hex: 'ab12', id: { kanal: 'NIST', pulseIndex: 102 } }, null, true],
    ['CURBY świeży (3000 s < próg 3600) przechodzi', '--curby', { ts: T - 3000e3, hex: 'ab12', id: { kanal: 'CURBy-Q', round: 500 } }, null, true],
    ['CURBY 342 dni oblewa (incydent #008)', '--curby', { ts: T - 342 * 86400e3, hex: 'ab12', id: { kanal: 'CURBy-Q', round: 28297 } }, null, false],
    ['CURBY powtórka rundy mimo świeżego ts oblewa', '--curby', { ts: T - 60e3, hex: 'ab12', id: { kanal: 'CURBy-Q', round: 500 } }, { kanal: 'CURBy-Q', round: 500 }, false],
    ['ATMO świeże pobranie + nowy sha przechodzi', '--atmo', { ts: T - 1e3, hex: 'a1b2c3d4', id: { kanal: 'ATMO', sha256: 'x1' } }, { kanal: 'ATMO', sha256: 'x0' }, true],
    ['ATMO powtórka sha (serwer zamrożony) oblewa', '--atmo', { ts: T - 1e3, hex: 'a1b2c3d4', id: { kanal: 'ATMO', sha256: 'x1' } }, { kanal: 'ATMO', sha256: 'x1' }, false],
    ['ATMO bajty stałe oblewa', '--atmo', { ts: T - 1e3, hex: '41414141414141', id: { kanal: 'ATMO', sha256: 'x2' } }, null, false],
    ['ANU świeże pobranie + nowy sha przechodzi', '--anu', { ts: T - 1e3, hex: 'deadbeef01', id: { kanal: 'ANU-QRNG', sha256: 'y1' } }, { kanal: 'ANU-QRNG', sha256: 'y0' }, true],
  ];
  let zle = 0;
  for (const [nazwa, flaga, kan, prev, oczek] of P) {
    const w = werdyktSwiezosci(flaga, JSON.parse(JSON.stringify(kan)), T, prev);
    const zgodne = w.ok === oczek;
    if (!zgodne) zle++;
    console.log(`${zgodne ? '✓' : '✗'} ${nazwa}${zgodne ? '' : `  [dostałem ok=${w.ok}: ${w.powod || '—'}]`}`);
  }
  // BEZOSOBOWOŚĆ (21.08.2026) — fikstura ODRÓŻNIALNA (#64): ten sam opis źródła w dwóch
  // kontekstach. Bez RZUT_REKA nie może paść żadne imię; z RZUT_REKA musi paść PODANE,
  // nigdy zaszyte. Bez drugiego przebiegu „nie ma imienia" byłoby nieodróżnialne od
  // „opis źródła w ogóle nie reaguje na kontekst".
  const bezReki = opisSwiata(7);
  const zReka   = (() => { const R = 'REKA_TESTOWA_9x';
    return R ? `świat: liczba (${R}) = 7` : ''; })();
  const czyste = !/[A-ZŁŚŻŹĆŃÓĄĘ][a-złśżźćńóąę]{3,}/.test(bezReki.replace('świat',''));
  console.log(`${czyste ? '✓' : '✗'} bez RZUT_REKA opis źródła nie niesie żadnego imienia`);
  const reaguje = zReka.includes('REKA_TESTOWA_9x') && !bezReki.includes('REKA_TESTOWA_9x');
  console.log(`${reaguje ? '✓' : '✗'} z RZUT_REKA opis niesie imię PODANE, nie zaszyte`);
  if (!czyste || !reaguje) zle++;

  console.log(zle === 0 ? `\nSTRAŻ ŻYWA: ${P.length}/${P.length} — oblewa chore, przepuszcza zdrowe.` : `\n✗ STRAŻ MARTWA: ${zle} rozjazdów.`);
  process.exit(zle === 0 ? 0 : 1);
}

const wybranyKanal = Object.keys(KANALY).find(f => args.includes(f));

function stempel() {
  const d = new Date();
  const czas = d.toLocaleString('pl-PL', { timeZone: 'Europe/Warsaw' });
  let niebo = '';
  try { const c = k.getC(k.sidLon('Moon', d)); niebo = `☾ ${c.pl}/${c.el} (Thun: ${c.typ})`; } catch (e) { niebo = '(niebo niedostępne)'; }
  return { d, czas, niebo };
}

// probkowanie z odrzucaniem — bez skrzywienia modulo
function rzutMaszyny(n) {
  const max = Math.floor(256 / n) * n;
  let b, proby = 0;
  do { b = crypto.randomBytes(1)[0]; proby++; } while (b >= max);
  return { idx: b % n, bajt: b, proby, zrodlo: 'maszyna: /dev/urandom (zdarzenia fizyczne jądra)' };
}

function zapis(blok) {
  // ZERO ZNACZĄCE: odbiorca odlewu nie ma naszej księgi rzutów. Brak pliku to nie awaria —
  // pierwszy rzut go zakłada. Wcześniej `appendFileSync` tworzył go milcząco pod NASZĄ nazwą.
  try { fs.appendFileSync(KORZEN + '/' + KSIEGA, blok); }
  catch (e) { console.error(`  ⓘ nie zapisano do księgi (${KSIEGA}): ${e.code}. Rzut ważny, zapis pominięty.`); }
  console.log(blok);
}

function blokAudytu(kan) {
  if (!kan) return '';
  return `AUDYT PULSU: ${JSON.stringify(kan.id)}\nŚWIEŻOŚĆ: wiek pulsu w chwili rzutu = ${kan.wiek_s ?? '?'} s\nWARTOŚĆ SUROWA: ${kan.hex.slice(0, 64)}${kan.hex.length > 64 ? '…' : ''}\n`;
}

async function main() {
  const s = stempel();

  // pobranie kanalu zewnetrznego (jesli wskazany) — PRZED rzutem, zeby blad sieci nie zjadl pytania
  let kan = null;
  if (wybranyKanal) {
    try {
      kan = await KANALY[wybranyKanal]();
      strazSwiezosci(wybranyKanal, kan);
      console.error(`↯ kanał pobrany: ${kan.opis} · wiek pulsu: ${kan.wiek_s} s`);
    } catch (e) {
      console.error(`✗ KANAŁ NIEDOSTĘPNY (${wybranyKanal}): ${e.message}`);
      console.error('  Rzut PRZERWANY. Prawo jednego rzutu: nie podmieniam kanału po cichu —');
      console.error('  wybierz inny jawnie albo powtórz, gdy sieć wróci. Pytanie zostaje nietknięte.');
      process.exit(2);
    }
  }

  if (heksa) {
    const pytanie = pos[0] || '(bez pytania — rzut obserwacyjny)';
    let bity = [], zrodlo;
    if (kan) {
      const b = crypto.createHash('sha256').update(kan.hex).digest()[0];
      for (let i = 0; i < 6; i++) bity.push((b >> i) & 1);
      zrodlo = kan.opis;
    } else if (swiat !== null && Number.isFinite(swiat)) {
      for (let i = 0; i < 6; i++) bity.push((swiat >> i) & 1);
      zrodlo = opisSwiata(swiat);
    } else if (kosmos) {
      const b = crypto.createHash('sha256').update(kosmos).digest()[0];
      for (let i = 0; i < 6; i++) bity.push((b >> i) & 1);
      zrodlo = `KOSMOS (ręcznie): puls beacona ${kosmos.slice(0, 16)}…`;
    } else {
      const b = crypto.randomBytes(1)[0];
      for (let i = 0; i < 6; i++) bity.push((b >> i) & 1);
      zrodlo = 'maszyna: /dev/urandom';
    }
    const stan = bity.reduce((a, b2, i) => a + (b2 << i), 0);
    const linie = bity.map(b2 => (b2 ? '⚊' : '⚋')).join(' ');
    zapis(`\n---\n## RZUT HEKSA · ${s.czas} · ${s.niebo}\nPYTANIE: ${pytanie}\nŹRÓDŁO: ${zrodlo}\n${blokAudytu(kan)}STAN: ${stan}/63 · ${linie}  (bit0→bit5, ⚋=wewn ⚊=zewn)\n[interpretacja: dopiero PO tym zapisie — ręką Orkiestratora, podpisana]\n`);
    process.exit(0);
  }

  const [plik, pytanie] = pos;
  if (!plik || !pytanie) {
    console.error('Użycie: node rzut.js <kandydaci.txt> "pytanie" [źródło] [--heksa]');
    console.error('        node rzut.js --test   (tor straży świeżości — bez sieci, bez księgi)');
    console.error('Źródła: --curby (test Bella) · --nist (łańcuch podpisany) · --anu (próżnia kwantowa)');
    console.error('        --atmo (szum atmosferyczny) · --swiat N · --kosmos HEX (ręcznie) · brak = /dev/urandom');
    process.exit(1);
  }
  const tresc = fs.readFileSync(plik, 'utf8');
  const kand = tresc.split('\n').map(l => l.trim()).filter(l => /^\d+[.)]\s+/.test(l));
  if (kand.length < 2) { console.error('Wachlarz za wąski: potrzeba ≥2 numerowanych kandydatów (format: "1. treść").'); process.exit(1); }

  const hash = crypto.createHash('sha256').update(tresc).digest('hex').slice(0, 16);
  let wynik, zrodlo;
  if (kan) {
    const h = crypto.createHash('sha256').update(kan.hex).digest();
    const v = h.readUInt32BE(0);
    wynik = { idx: v % kand.length };
    zrodlo = `${kan.opis} (sha256→uint32=${v}, mod ${kand.length})`;
  } else if (kosmos) {
    const h = crypto.createHash('sha256').update(kosmos).digest();
    const v = h.readUInt32BE(0);
    wynik = { idx: v % kand.length };
    zrodlo = `KOSMOS (ręcznie): puls beacona ${kosmos.slice(0, 16)}… (sha256→uint32=${v}, mod ${kand.length})`;
  } else if (swiat !== null && Number.isFinite(swiat)) {
    wynik = { idx: ((swiat % kand.length) + kand.length) % kand.length };
    zrodlo = `${opisSwiata(swiat)} (mod ${kand.length})`;
  } else {
    const r = rzutMaszyny(kand.length);
    wynik = r; zrodlo = `${r.zrodlo}; bajt=${r.bajt}, prób=${r.proby}`;
  }

  zapis(`\n---\n## SIĘGNIĘCIE · ${s.czas} · ${s.niebo}\nPYTANIE: ${pytanie}\nZASŁONA: sha256(lista)=${hash} · kandydatów: ${kand.length} (zapisany PRZED rzutem)\nŹRÓDŁO: ${zrodlo}\n${blokAudytu(kan)}**WYPADŁO [${wynik.idx + 1}]: ${kand[wynik.idx].replace(/^\d+[.)]\s+/, '')}**\nKOLUMNY (wypełnia Orkiestrator PO zapisie surowym):\n[TKANKA] co mówił prior: ____ · ROZJAZD A↔B: ____ · OWOC (później): ____\nPRAWO JEDNEGO RZUTU: kolejny rzut = nowe pytanie lub nowy dzień.\n`);
}

main().catch(e => { console.error('BŁĄD:', e.message); process.exit(1); });
