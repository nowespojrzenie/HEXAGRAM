#!/usr/bin/env node
/* ============================================================================
   wezownik.js — WĘŻOWNIK jako podsektor Skorpiona
   ----------------------------------------------------------------------------
   STATUS: REZONANS. Soczewka obserwacyjna, nie prawo. PREREJESTR_oddech #008.

   NIE MODYFIKUJE KANONU. Czyta z kronos_v4.js (sidLon, getC) i dokłada
   warstwę nad sektorem Skorpiona. Tablica CONST pozostaje dwunastoelementowa —
   zmiana granic unieważniłaby wstecz każdą kotwicę ZAPISY_eter i każde
   okno w rejestrach.

   GRUNT (zmierzony 07.08.2026):
     sektor Skorpion Thun : 213,7° – 244,8°  ·  Woda  ·  LIŚĆ 🌿
     Wężownik IAU w nim   : ~223,0° – 242,0°  (61,1% czasu Księżyca)
     Skorpion IAU właściwy: 213,7° – 223,0°  (29,9%)
     ogon                 : 242,0° – 244,8°  ( 9,0%)

   ⚠ STRAŻ E2: żaden opis z tego pliku nie może trafić na etykietę, do sklepu
   ani do materiałów marki żywnościowej. Rozporządzenie 1924/2006 — zero health claims.
   To jest kalendarz pracy własnej, nie tekst sprzedażowy.

   UŻYCIE:
     node wezownik.js now            — gdzie stoi Księżyc teraz
     node wezownik.js okna [dni]     — najbliższe okna (domyślnie 120 dni)
     node wezownik.js rok [YYYY]     — kalendarz roczny: Słońce + wszystkie okna
   ============================================================================ */

const A = require('astronomy-engine');
const K = require('./kronos_v4.js');
const TZ = require('./tz_pl.js');   // jedno źródło czasu lokalnego

/* GRANICE — konstelacja IAU (Constellation z astronomy-engine) na ekliptyce DATY, minus ayanamsa v4.
   Silnik liczy Księżyc i Słońce w ekliptyce daty (EclipticGeoMoon, Ecliptic), więc granicę trzeba mierzyć w TYM SAMYM układzie:
   wektor o długości L na ekliptyce daty → Rotation_ECT_EQJ → RA/dek J2000 → Constellation; od L odejmujemy ayan(). Tak liczona granica
   jest praktycznie stała w latach 1900–2100 (rozrzut ≤ 0,012°). NIE zaokrąglać, NIE liczyć na ekliptyce J2000.
   BLEDY #43 liczył ją na ekliptyce J2000 z ayanamsą daty (pomyłka układu odniesienia): stąd 223,413° i „dryf −1,4°/wiek”, który był
   artefaktem. Wartości #43 odwołane (BLEDY, U1-15, ULTRAREVIEW §6); granicaDlaEpoki() liczy granicę z biblioteki dla daty. */
const OPH_S = 223.787, OPH_E = 242.387;
const SCO_S = 213.7, SCO_E = 244.8;

/* granice Wężownika (syderyczne) dla daty — bisekcja Constellation do 1e-4°; `uklad: 'J2000'` tylko dla toru, który ma nazwać
   dawną pomyłkę (ekliptyka J2000 zamiast ekliptyki daty) */
function granicaDlaEpoki(date, uklad) {
  if (typeof A.Constellation !== 'function' || typeof A.Rotation_ECT_EQJ !== 'function') {
    throw new Error('wezownik: astronomy-engine bez Constellation/Rotation_ECT_EQJ — nie umiem policzyć granic Wężownika');
  }
  const t = A.MakeTime(date), ay = K.ayan(date);
  const rot = uklad === 'J2000' ? A.Rotation_ECL_EQJ() : A.Rotation_ECT_EQJ(t);
  const sym = L => {
    const r = L * Math.PI / 180, e = A.EquatorFromVector(A.RotateVector(rot, new A.Vector(Math.cos(r), Math.sin(r), 0, t)));
    return A.Constellation(e.ra, e.dec).symbol;
  };
  const dokladnie = (lo, hi, przed) => { while (hi - lo > 1e-5) { const m = (lo + hi) / 2; if (sym(m) === przed) lo = m; else hi = m; } return (lo + hi) / 2; };
  let s = null, e = null, prev = sym(ay + 215);
  for (let L = ay + 215.05; L <= ay + 250 && e === null; L += 0.05) {
    const cur = sym(L);
    if (cur !== prev) {
      if (prev === 'Sco' && cur === 'Oph') s = dokladnie(L - 0.05, L, 'Sco') - ay;
      else if (prev === 'Oph' && s !== null) e = dokladnie(L - 0.05, L, 'Oph') - ay;
      prev = cur;
    }
  }
  if (s === null || e === null) throw new Error('wezownik: nie znalazłem granic Wężownika dla daty ' + date.toISOString().slice(0, 10));
  return { s, e };
}

/* --- strefy wewnątrz sektora Skorpiona ---------------------------------- */
const STREFY = {
  PROG: {
    kod: 'PRÓG',
    nazwa: 'Skorpion właściwy (213,7–223,8°)',
    znak: '🦂',
    ton: 'Wejście. To, co domknięte, jeszcze osiada. Nie zaczynaj — zbieraj.',
  },
  OPH: {
    kod: 'WĘŻOWNIK',
    nazwa: 'Wężownik (223,8–242,4°)',
    znak: '⚕',
    ton: 'Lek z trucizny. Dawka, nie usunięcie.',
  },
  OGON: {
    kod: 'OGON',
    nazwa: 'wyjście ku Strzelcowi (242,4–244,8°)',
    znak: '🏹',
    ton: 'Domykanie. USPÓJNIENIE za progiem 244,8°.',
  },
};

function strefa(s) {
  if (s < SCO_S || s >= SCO_E) return null;
  if (s < OPH_S) return STREFY.PROG;
  if (s < OPH_E) return STREFY.OPH;
  return STREFY.OGON;
}

/* --- co robić: warstwa materialna i niematerialna ------------------------- */
const PRAKTYKA = {
  robic: [
    'Maceraty i wyciągi z surowca LIŚCIOWEGO — pokrzywa, mięta, melisa, szałwia,',
    '  bylica, babka. Świeże, przerabiane od razu.',
    'Nalewka propolisowa — żywica obronna ula, ta sama logika co Wężownik:',
    '  to, czym rodzina się broni, staje się lekiem.',
    'Zalewanie, moczenie, ciągnienie — wszystko, co polega na CIERPLIWYM',
    '  przechodzeniu substancji do rozpuszczalnika. Woda jest żywiołem sektora.',
    'Podlewanie, przesadzanie roślin liściowych, cięcie zieleni na przyrost.',
    'Rozmowy, które długo odkładałeś, a które nie mają być rozstrzygnięciem —',
    '  tylko wypuszczeniem tego, co uwiera.',
  ],
  unikac: [
    'Zbioru na SUSZ i do długiego przechowania — liść niesie najwięcej wody,',
    '  gorzej schnie, łatwiej pleśnieje. Susz rób w dniach owocu.',
    'Siewu nasion i prac korzeniowych — to nie ten żywioł.',
    'Miodobrania i wszystkiego, co ma być trwałe i klarowne.',
    'Decyzji nieodwracalnych. Sektor jest do rozpuszczania, nie do cięcia.',
  ],
  rdzen: [
    'Pytanie stoi WYŻEJ niż lista — patrz blok PYTANIE. Praktyki są węższe niż okno;',
    'pytanie jest szersze. Intencja wyłania się z pytania, nie z listy zadań.',
    '',
    'WĘŻOWNIK to nie „znak uzdrowiciela". To strefa styku z tym, co zabija.',
    'Tradycja pamięta obie strony: Pliniusz przypisywał tej konstelacji śmierć',
    'przez otrucie, Manilius — odporność na jad i umiejętność leczenia ukąszeń.',
    'Ta sama gwiazda. Różnica leży w DAWCE i w tym, kto trzyma węża.',
    '',
    'To nie jest zadanie do rozwiązania w oknie. To jest pytanie do noszenia.',
  ],
};

/* --- silnik ------------------------------------------------------------- */
function pozycjaKsiezyca(d) { return K.sidLon('Moon', d); }
function pozycjaSlonca(d)  { return K.sidLon('Sun', d); }

function fmtPL(d) {
  const off = TZ.offAt(d);
  const l = new Date(d.getTime() + off * 3600000);
  const p = n => String(n).padStart(2, '0');
  return `${p(l.getUTCDate())}.${p(l.getUTCMonth() + 1)}.${l.getUTCFullYear()} ${p(l.getUTCHours())}:${p(l.getUTCMinutes())} ${TZ.nazwa(off)}`;
}

// Okno = [początek, koniec, lewaOtwarta]. (K6/N9) Okno wciąż otwarte, gdy zakres się kończy, wraca jako [początek, null] — dawniej znikało
// (pętla kończyła się z prev=true bez wpisu), więc `okna DNI` i `rok` milczały o oknie, które trwa w chwili końca skanu.
// (zlecenie 3 · 01N9CoiA, część 5) Symetrycznie lewa krawędź: okno już otwarte w chwili `od` dostaje początek = `od` (pierwsza próbka), nie prawdziwy
// początek — trzeci element `true` mówi „otwarte przed początkiem zakresu”. Prawdziwego początku nie szukamy wstecz (silnik nie ma kroku wstecz).
function skanujOkna(od, doD, krokMs = 1800000) {
  if (isNaN(new Date(od)) || isNaN(new Date(doD))) throw new Error('wezownik.skanujOkna: zakres dat nie jest datą (' + od + ' → ' + doD + ')');
  const out = []; let t = new Date(od), start = null, prev = false, lewa = false, pierwsza = true;
  while (t < doD) {
    const inO = (() => { const s = pozycjaKsiezyca(t); return s >= OPH_S && s < OPH_E; })();
    if (inO && !prev) { start = new Date(t); lewa = pierwsza; }
    if (!inO && prev && start) { out.push([start, new Date(t), lewa]); start = null; lewa = false; }
    prev = inO; pierwsza = false; t = new Date(t.getTime() + krokMs);
  }
  if (prev && start) out.push([start, null, lewa]);
  return out;
}
const fmtKoniec = (o, doOpisu = ' otwarte do końca zakresu skanu (koniec okna poza skanem)') => o[1] ? fmtPL(o[1]) : doOpisu;
const fmtPoczatek = o => o[2] ? `otwarte przed początkiem zakresu (skan od ${fmtPL(o[0])})` : fmtPL(o[0]);

// (K6/N9) argument CLI: brak = domyślna; podany a nie-liczba = rc 2 (dawniej `parseInt(arg) || 120` cicho podstawiało domyślną).
function liczbaArg(nazwa, arg, domyslna, ok, opis) {
  if (arg === undefined) return domyslna;
  const n = Number(arg);
  if (!ok(n)) { console.error(`✗ wezownik.js: ${nazwa} musi być ${opis}, jest "${arg}"`); process.exit(2); }
  return n;
}

function blokPraktyki() {
  const L = [];
  L.push('');
  L.push('  ══ PYTANIE ' + '═'.repeat(53));
  L.push('');
  L.push('   „Co we mnie jest trucizną, której nie trzeba usuwać, tylko odmierzyć?"');
  L.push('');
  L.push('   Pytanie-PRZESTRZEŃ, nie atraktor. Nie domaga się odpowiedzi w oknie.');
  L.push('   Wyłonienie wolno gdzie indziej, później, w ciele albo wcale.');
  L.push('   Brak odpowiedzi jest odpowiedzią.');
  L.push('');
  L.push('  ── co MOŻNA (nie: co trzeba) ' + '─'.repeat(35));
  PRAKTYKA.robic.forEach(x => L.push(x.startsWith('  ') ? '    ' + x.trim() : '   • ' + x));
  L.push('');
  L.push('  ── CZEGO NIE ' + '─'.repeat(51));
  PRAKTYKA.unikac.forEach(x => L.push(x.startsWith('  ') ? '    ' + x.trim() : '   ✗ ' + x));
  L.push('');
  L.push('  ── RDZEŃ ' + '─'.repeat(55));
  PRAKTYKA.rdzen.forEach(x => L.push('   ' + x));
  return L.join('\n');
}

/* --- tryby -------------------------------------------------------------- */
function trybNow() {
  const d = new Date();
  const sM = pozycjaKsiezyca(d), sS = pozycjaSlonca(d);
  const c = K.getC(sM), st = strefa(sM), stS = strefa(sS);

  console.log('\n⚕ WĘŻOWNIK — ⏱ ZMIERZONE TERAZ: ' + fmtPL(d));
  console.log('─'.repeat(66));
  console.log(`  Księżyc  ${sM.toFixed(2)}°  →  ${c.sym} ${c.pl}  ·  ${c.el} / ${c.typ} ${c.em}`);
  console.log(`  Słońce   ${sS.toFixed(2)}°  →  ${K.getC(sS).pl}`);
  console.log('');

  if (!st) {
    console.log(`  ○ Księżyc poza sektorem Skorpiona. Wężownik nieaktywny.`);
    const n = skanujOkna(d, new Date(d.getTime() + 40 * 86400000))[0];
    if (n) console.log(`\n  następne okno:  ${fmtPoczatek(n)}  →  ${fmtKoniec(n)}`);
  } else if (st.kod === 'WĘŻOWNIK') {
    console.log(`  ⚕ ═══ OKNO WĘŻOWNIKA OTWARTE ═══`);
    console.log(`     ${st.nazwa}`);
    console.log(`     ${st.ton}`);
    if (stS && stS.kod === 'WĘŻOWNIK') console.log(`\n  ⊕⊕ PODWÓJNY — Słońce także w Wężowniku. Raz w roku.`);
    console.log(blokPraktyki());
  } else {
    console.log(`  ${st.znak} ${st.nazwa}`);
    console.log(`     ${st.ton}`);
    const doOph = st.kod === 'PRÓG' ? (OPH_S - sM).toFixed(2) : null;
    if (doOph) console.log(`\n     do Wężownika: ${doOph}°  (~${(doOph / 13.18 * 24).toFixed(1)} h)`);
  }
  console.log('\n  status: REZONANS · PREREJESTR_oddech #008 · nie jest prawem\n');
}

function trybOkna(dni) {
  const od = new Date(), doD = new Date(od.getTime() + dni * 86400000);
  const ok = skanujOkna(od, doD);
  console.log(`\n⚕ OKNA WĘŻOWNIKA — najbliższe ${dni} dni  (Księżyc ${OPH_S}–${OPH_E}° syd)`);
  console.log('   sektor Thun: SKORPION · Woda · LIŚĆ 🌿');
  console.log('─'.repeat(66));
  ok.forEach((o, i) => {
    const h = o[1] ? `   (${o[2] ? '≥ ' : ''}${((o[1] - o[0]) / 3600000).toFixed(1)} h${o[2] ? ' od początku zakresu' : ''})` : `   (≥ ${((doD - o[0]) / 3600000).toFixed(1)} h${o[2] ? ' w zakresie' : ' do końca zakresu'})`;
    console.log(`  ${String(i + 1).padStart(2)}.  ${fmtPoczatek(o)}  →  ${fmtKoniec(o)}${h}`);
  });
  const otw = ok.filter(o => !o[1]).length, otwL = ok.filter(o => o[2]).length;
  console.log(`\n  razem: ${ok.length} okien${otw ? ` (w tym ${otw} otwarte na końcu zakresu)` : ''}${otwL ? ` (w tym ${otwL} otwarte przed początkiem zakresu)` : ''}  ·  ~38 h każde  ·  13 razy w roku\n`);
}

function trybRok(y) {
  console.log(`\n⚕ KALENDARZ WĘŻOWNIKA ${y}`);
  console.log('═'.repeat(66));

  // Słońce
  let t = new Date(Date.UTC(y, 0, 1)), sIn = null, sOut = null, prev = false;
  while (t < new Date(Date.UTC(y + 1, 0, 1))) {
    const s = pozycjaSlonca(t), inO = s >= OPH_S && s < OPH_E;
    if (inO && !prev) sIn = new Date(t);
    if (!inO && prev) sOut = new Date(t);
    prev = inO; t = new Date(t.getTime() + 3600000);
  }
  console.log('\n  SŁOŃCE W WĘŻOWNIKU (raz w roku, ~19 dni):');
  if (sIn) console.log(`     ${fmtPL(sIn)}  →  ${sOut ? fmtPL(sOut) : '(przechodzi na kolejny rok)'}`);

  // Księżyc
  const ok = skanujOkna(new Date(Date.UTC(y, 0, 1)), new Date(Date.UTC(y + 1, 0, 1)));
  console.log(`\n  KSIĘŻYC W WĘŻOWNIKU — ${ok.length} okien:`);
  ok.forEach((o, i) => {
    const podw = sIn && o[0] >= sIn && (!sOut || o[0] < sOut);
    console.log(`     ${String(i + 1).padStart(2)}.  ${fmtPoczatek(o)}  →  ${fmtKoniec(o)}${podw ? '   ⊕⊕ PODWÓJNY' : ''}`);
  });
  console.log(blokPraktyki());
  console.log('\n  status: REZONANS · #008 · odczyt 15.02.2027\n');
}

/* --- wejście ------------------------------------------------------------ */
// ── TOR (#38, dopisany 30.08.2026) ────────────────────────────────────────────────
// Do dziś przyrząd nie miał trybu `--test` — więc `straz_dojrzalosci` trzymała go poza
// odlewem, a nikt nie umiał sprawdzić, czy soczewka mierzy to, co deklaruje.
// Przypadki dobrane DETERMINISTYCZNIE (granice sektora, nie „dzisiejsze niebo"), żeby tor
// nie zależał od dnia uruchomienia — inaczej zielone znaczyłoby „dziś akurat pasuje".
if (process.argv[2] === '--test') {
  let zle = [];
  const spr = (op, a, b) => { if (String(a) === String(b)) console.log('  ✓ ' + op);
    else { console.log(`  ✗ ${op} (było ${a}, miało ${b})`); zle.push(op); } };

  // (+) wnętrze Wężownika: długość między OPH_S a OPH_E ma dać strefę Wężownika
  const wSrodku = (OPH_S + OPH_E) / 2;
  spr('srodek Wezownika rozpoznany', /ężownik|ezownik/.test(strefa(wSrodku).nazwa || strefa(wSrodku)), true);
  // (−) tuż PRZED początkiem: NIE Wężownik — inaczej „wszystko jest Wężownikiem" (#75)
  spr('tuz przed granica to NIE Wezownik', /ężownik|ezownik/.test(strefa(OPH_S - 0.5).nazwa || strefa(OPH_S - 0.5)), false);
  // (−) tuż PO końcu: też nie
  spr('tuz za granica to NIE Wezownik', /ężownik|ezownik/.test(strefa(OPH_E + 0.5).nazwa || strefa(OPH_E + 0.5)), false);
  // (+) granica liczona dla daty w układzie ekliptyki DATY jest stała z dokładnością ≤ 0,02° w latach 1900–2100 i zgadza się ze stałymi
  //     OPH_S/OPH_E (U1-15: dawniej tor „granica przesuwa się z epoką” porównywał dwa obiekty przez !== i przechodził zawsze)
  for (const d of [Date.UTC(1900, 0, 1), Date.UTC(2026, 9, 8), Date.UTC(2100, 0, 1)]) {
    const g = granicaDlaEpoki(new Date(d)), dr = Math.max(Math.abs(g.s - OPH_S), Math.abs(g.e - OPH_E));
    spr('granica dla daty ' + new Date(d).toISOString().slice(0, 10) + ' w ekliptyce daty = stałe OPH_S/OPH_E (≤ 0,02°)', dr <= 0.02, true);
  }
  // (−) ta sama granica na ekliptyce J2000 dla 2026 różni się od OPH_S o > 0,3° — tor nazywa pomyłkę układu, żeby nie wróciła
  const gJ = granicaDlaEpoki(new Date(Date.UTC(2026, 9, 8)), 'J2000');
  spr('granica 2026 na ekliptyce J2000 odbiega od OPH_S o > 0,3° (pomyłka układu #43)', Math.abs(gJ.s - OPH_S) > 0.3, true);
  // (+) NIE RUSZA KANONU: tablica sektorów musi zostać dwunastoelementowa (nagłówek pliku)
  spr('sektory kanonu nietkniete (12)', require('./kronos_v4.js').CONST ? require('./kronos_v4.js').CONST.length : 12, 12);

  // (K6/N9) TOR (−): okno OTWARTE na końcu zakresu nie znika. Przypadek deterministyczny, z efemerydy: bierzemy pierwsze okno 2026,
  // potem kończymy skan w jego ŚRODKU. Dawne ciało zwracało [] (pętla kończyła się z prev=true bez wpisu).
  const o26 = skanujOkna(new Date(Date.UTC(2026, 0, 1)), new Date(Date.UTC(2026, 2, 1)));
  const [os, oe] = o26[0];
  const ucięte = skanujOkna(new Date(os.getTime() - 6 * 3600000), new Date((os.getTime() + oe.getTime()) / 2));
  spr('okno otwarte na końcu zakresu wraca (1 okno), nie znika', ucięte.length, 1);
  spr('…i jest oznaczone jako otwarte (koniec = null), początek jak w pełnym skanie', ucięte.length === 1 && ucięte[0][1] === null && Math.abs(ucięte[0][0] - os) <= 1800000, true);
  const pelne = skanujOkna(new Date(os.getTime() - 6 * 3600000), new Date(oe.getTime() + 6 * 3600000));
  spr('(+) okno zamknięte w zakresie ma koniec (nie null) — znacznik otwarcia nie przecieka', pelne.length === 1 && pelne[0][1] instanceof Date, true);
  // (zlecenie 3 · 01N9CoiA, cz. 5) TOR (−): okno otwarte na POCZĄTKU zakresu jest oznaczone (trzeci element), nie podawane jako prawdziwy początek.
  const odSrodka = new Date((os.getTime() + oe.getTime()) / 2);
  const lewe = skanujOkna(odSrodka, new Date(oe.getTime() + 6 * 3600000));
  spr('okno otwarte przed początkiem zakresu: 1 okno, znacznik lewej krawędzi = true, początek = pierwsza próbka zakresu', lewe.length === 1 && lewe[0][2] === true && lewe[0][0].getTime() === odSrodka.getTime(), true);
  spr('…a jego koniec jest prawdziwy (ten sam co w pełnym skanie)', lewe.length === 1 && lewe[0][1] instanceof Date && Math.abs(lewe[0][1] - oe) <= 1800000, true);
  spr('(+) okno zamknięte po obu stronach NIE ma znacznika lewej krawędzi', pelne.length === 1 && pelne[0][2] === false, true);
  const oba = skanujOkna(odSrodka, new Date(odSrodka.getTime() + 3600000));
  spr('okno otwarte z obu stron zakresu: koniec null i znacznik lewej krawędzi', oba.length === 1 && oba[0][1] === null && oba[0][2] === true, true);
  spr('zakres dat nie-datą RZUCA (nie pusta lista)', (() => { try { skanujOkna(new Date(NaN), new Date()); return 'brak'; } catch (e) { return 'rzucił'; } })(), 'rzucił');
  // argumenty CLI: podany a nie-liczba = rc 2 (dawniej `parseInt(arg) || 120` podstawiało domyślną); brak argumentu = domyślna (rc 0)
  const cpT = require('child_process'), wez = (...a) => cpT.spawnSync(process.execPath, [__filename, ...a], { encoding: 'utf8' });
  for (const [c, a] of [['okna', 'abc'], ['okna', '0'], ['rok', 'abc'], ['rok', '99']]) {
    const r = wez(c, a);
    spr(`CLI ${c} ${a} → rc 2 z powodem, bez raportu`, r.status === 2 && /wezownik\.js: /.test(r.stderr) && !/KALENDARZ|OKNA WĘŻOWNIKA/.test(r.stdout), true);
  }
  spr('CLI okna 5 (poprawne) → rc 0 i nagłówek „5 dni”', (() => { const r = wez('okna', '5'); return r.status === 0 && /najbliższe 5 dni/.test(r.stdout); })(), true);

  console.log('╔═══ WĘŻOWNIK — AUTOTEST ═══╗');
  if (zle.length) { console.log('  ✗ TOR OBLANY: ' + zle.join(' · ')); process.exit(1); }
  console.log('  ✓ TOR PRZESZEDŁ — soczewka rozpoznaje sektor i UMIE go NIE rozpoznać poza granicą.');
  process.exit(0);
}

const [, , cmd, arg] = process.argv;
if (cmd === 'now' || !cmd) trybNow();
else if (cmd === 'okna') trybOkna(liczbaArg('DNI', arg, 120, n => Number.isFinite(n) && n > 0, 'liczbą > 0'));
else if (cmd === 'rok') trybRok(liczbaArg('YYYY', arg, new Date().getUTCFullYear(), n => Number.isInteger(n) && n >= 1000 && n <= 9999, 'liczbą całkowitą 1000–9999'));
else { console.log('użycie: node wezownik.js [now | okna DNI | rok YYYY]'); process.exit(1); }

module.exports = { strefa, skanujOkna, STREFY, OPH_S, OPH_E, PRAKTYKA, granicaDlaEpoki };
