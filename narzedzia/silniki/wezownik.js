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

/* GRANICE — z pomiaru bezpośredniego konstelacji IAU na ekliptyce (07.08.2026).
   NIE zaokrąglać. Granica dryfuje ~0,6°/43 lata (IAU zamrożone w B1875,
   ayanamsa Lahiri jedzie własnym tempem):
       1983: 224,017° – 242,612°
       2026: 223,413° – 242,013°
   Dla odczytów bieżących używamy epoki 2026. Dla kart natalnych — funkcja
   granicaDlaEpoki(). Poprzednia wartość 223,0 była zaokrągleniem pomiaru
   pomocniczego → BLEDY #43. */
const OPH_S = 223.413, OPH_E = 242.013;
const SCO_S = 213.7, SCO_E = 244.8;

/* granice Wężownika przeliczone na epokę daty (interpolacja liniowa 1983↔2026) */
function granicaDlaEpoki(date) {
  const y = date.getUTCFullYear() + date.getUTCMonth() / 12;
  const f = (y - 1983.73) / (2026.60 - 1983.73);
  return { s: 224.017 + f * (223.413 - 224.017), e: 242.612 + f * (242.013 - 242.612) };
}

/* --- strefy wewnątrz sektora Skorpiona ---------------------------------- */
const STREFY = {
  PROG: {
    kod: 'PRÓG',
    nazwa: 'Skorpion właściwy (213,7–223,0°)',
    znak: '🦂',
    ton: 'Wejście. To, co domknięte, jeszcze osiada. Nie zaczynaj — zbieraj.',
  },
  OPH: {
    kod: 'WĘŻOWNIK',
    nazwa: 'Wężownik (223,4–242,0°)',
    znak: '⚕',
    ton: 'Lek z trucizny. Dawka, nie usunięcie.',
  },
  OGON: {
    kod: 'OGON',
    nazwa: 'wyjście ku Strzelcowi (242,0–244,8°)',
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
  const y = d.getUTCFullYear(), m = d.getUTCMonth(), dd = d.getUTCDate();
  const last = (yy, mm) => { const x = new Date(Date.UTC(yy, mm + 1, 0)); return x.getUTCDate() - x.getUTCDay(); };
  const t = Date.UTC(y, m, dd);
  const cest = t >= Date.UTC(y, 2, last(y, 2), 1) && t < Date.UTC(y, 9, last(y, 9), 1);
  const l = new Date(d.getTime() + (cest ? 2 : 1) * 3600000);
  const p = n => String(n).padStart(2, '0');
  return `${p(l.getUTCDate())}.${p(l.getUTCMonth() + 1)}.${l.getUTCFullYear()} ${p(l.getUTCHours())}:${p(l.getUTCMinutes())} ${cest ? 'CEST' : 'CET'}`;
}

function skanujOkna(od, doD, krokMs = 1800000) {
  const out = []; let t = new Date(od), start = null, prev = false;
  while (t < doD) {
    const inO = (() => { const s = pozycjaKsiezyca(t); return s >= OPH_S && s < OPH_E; })();
    if (inO && !prev) start = new Date(t);
    if (!inO && prev && start) { out.push([start, new Date(t)]); start = null; }
    prev = inO; t = new Date(t.getTime() + krokMs);
  }
  return out;
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
    if (n) console.log(`\n  następne okno:  ${fmtPL(n[0])}  →  ${fmtPL(n[1])}`);
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
    const h = ((o[1] - o[0]) / 3600000).toFixed(1);
    console.log(`  ${String(i + 1).padStart(2)}.  ${fmtPL(o[0])}  →  ${fmtPL(o[1])}   (${h} h)`);
  });
  console.log(`\n  razem: ${ok.length} okien  ·  ~38 h każde  ·  13 razy w roku\n`);
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
    console.log(`     ${String(i + 1).padStart(2)}.  ${fmtPL(o[0])}  →  ${fmtPL(o[1])}${podw ? '   ⊕⊕ PODWÓJNY' : ''}`);
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
  // (+) granica ZALEŻY OD EPOKI — precesja; dwie odległe daty nie mogą dać tej samej liczby
  const g1 = granicaDlaEpoki(new Date(Date.UTC(1900, 0, 1)));
  const g2 = granicaDlaEpoki(new Date(Date.UTC(2100, 0, 1)));
  spr('granica przesuwa sie z epoka (precesja)', g1 !== g2, true);
  // (+) NIE RUSZA KANONU: tablica sektorów musi zostać dwunastoelementowa (nagłówek pliku)
  spr('sektory kanonu nietkniete (12)', require('./kronos_v4.js').CONST ? require('./kronos_v4.js').CONST.length : 12, 12);

  console.log('╔═══ WĘŻOWNIK — AUTOTEST ═══╗');
  if (zle.length) { console.log('  ✗ TOR OBLANY: ' + zle.join(' · ')); process.exit(1); }
  console.log('  ✓ TOR PRZESZEDŁ — soczewka rozpoznaje sektor i UMIE go NIE rozpoznać poza granicą.');
  process.exit(0);
}

const [, , cmd, arg] = process.argv;
if (cmd === 'now' || !cmd) trybNow();
else if (cmd === 'okna') trybOkna(parseInt(arg) || 120);
else if (cmd === 'rok') trybRok(parseInt(arg) || new Date().getUTCFullYear());
else { console.log('użycie: node wezownik.js [now | okna DNI | rok YYYY]'); process.exit(1); }

module.exports = { strefa, skanujOkna, STREFY, OPH_S, OPH_E, PRAKTYKA, granicaDlaEpoki };
