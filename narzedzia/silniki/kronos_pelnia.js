// ============================================================
// KRONOS · PEŁNIA — rozszerzony odczyt natalny/momentu
// Uzupełnia kronos_natal.js o: gwiazdy stałe, Lilith (śr. apogeum),
// węzeł prawdziwy, TNO/Chirona w domach, detekcję ZBITEK i ASPEKTÓW.
//
// ŹRÓDŁA POZYCJI:
//   • planety, węzły, Lilith, domy: Swiss Ephemeris (@swisseph/node)
//   • TNO/Chiron: SwissEph + pliki .se1 w ./ephe (jak scan_dwarfs.js)
//   • gwiazdy stałe: katalog J2000 (długości ekliptyczne) + precesja
//     liniowa 50.29″/rok — zweryfikowano vs astro.com (≤1′ na 1983 r.)
//   • ayanamsa: kronos_v4 (JEDNO źródło — import, nie kopia)
//
// STATUS KANONICZNY:
//   • pozycje planet/gwiazd/Lilith/TNO = PRAWO (mierzone, falsyfikowalne)
//   • osie i domy = NOŚNA RAMA⚠ (czułe na godzinę/miejsce)
//   • strefa czasowa z reguły UE (ost. niedziela III–X) = NOŚNA RAMA⚠
//     dla dat sprzed 1996 (PL miewała inne daty zmiany czasu) — użyj --utc
//     przy wątpliwościach
//   • tagi tradycji przy gwiazdach = REZONANS (Strefa Nulifikacji)
//   • Varuna (se20000s.se1): jeśli pliku brak w ./ephe — jawna LUKA,
//     nie cichy błąd; plik do dogrania z ftp.astro.com/pub/swisseph/ephe/long/ast20/
//
// Użycie:
//   node kronos_pelnia.js YYYY M D HH MM LAT LON [--orb-gw=2.5] [--orb-tno=3] [--utc]
//   node kronos_pelnia.js now LAT LON
// ============================================================
const swe = require('@swisseph/node');
const K   = require('./kronos_v4.js');   // jedno źródło ayanamsy + getC
const mx  = require('./kronos_matryca.js');
const path = require('path');
// dach narzedzia/silniki/ (29.08): efemerydy .se1 stoją w KORZENIU repo, nie przy silniku —
// bez '..','..'  SwissEph cicho spada na Moshiera i liczy INNE liczby, nie zgłaszając błędu.
swe.setEphemerisPath(path.join(__dirname, '..', '..', 'ephe'));

const norm = x => ((x % 360) + 360) % 360;
const OFF  = swe.AsteroidOffset; // 10000

// ── znaki tropikalne ──
const ZN = ["Baran","Byk","Bliźnięta","Rak","Lew","Panna","Waga","Skorpion","Strzelec","Koziorożec","Wodnik","Ryby"];
const SY = ["♈","♉","♊","♋","♌","♍","♎","♏","♐","♑","♒","♓"];
function fmtTrop(lon){ const L=norm(lon), i=Math.floor(L/30), st=L-i*30;
  const d=Math.floor(st), m=Math.round((st-d)*60);
  return `${SY[i]} ${ZN[i]} ${d}°${String(m).padStart(2,"0")}'`; }
function elLahiri(lonTrop, ayan){
  const c = K.getC(norm(lonTrop - ayan));
  const m = mx.MATRYCA[c.pl];
  return m ? `${m.em} ${c.pl} · ${m.el}/${m.biegun}` : `${c.sym} ${c.pl}`;
}

// ── katalog gwiazd stałych: długość ekliptyczna J2000 (tropik) ──
// tag = tradycja, status REZONANS — nie werdykt
const GWIAZDY = [
  ["Regulus",   149.833, "★królewska · serce Lwa — wyniesienie pod warunkiem integralności"],
  ["Aldebaran",  69.786, "★królewska · oko Byka — sukces przez prawość"],
  ["Antares",   249.764, "★królewska · serce Skorpiona — intensywność: regeneracja albo spalenie"],
  ["Fomalhaut", 333.868, "★królewska · ryba południowa — ideały, próba czystości"],
  ["Spica",     203.837, "kłos Panny — dar, plon, łagodna pomyślność"],
  ["Arcturus",  204.223, "strażnik — pionierstwo, prowadzenie innych"],
  ["Algol",      56.170, "głowa Meduzy — cień zbiorowy, wymaga świadomego obchodzenia"],
  ["Sirius",    104.084, "najjaśniejsza — sława/spalanie, przewodnik"],
  ["Vega",      285.318, "harfa — czar, sztuka, magnetyzm"],
  ["Capella",    81.865, "koza — ruchliwość, wolność, ciekawość"],
  ["Rigel",      76.833, "stopa Oriona — nauczyciel, budowniczy"],
  ["Betelgeuse", 88.756, "ramię Oriona — powodzenie bez łatwości"],
  ["Procyon",   105.786, "mały pies — szybki wzrost, wymaga utrwalenia"],
  ["Pollux",    113.222, "bokser — siła zmagania"],
  ["Castor",    110.235, "jeździec — dwoistość, intelekt"],
  ["Altair",    301.776, "orzeł — śmiałość, lot"],
  ["Alcyone",    60.000, "Plejady — wizja zbiorowa, żałoba/światło"],
  ["C.Galaktyki",266.850,"Sgr A* — źródło; punkt zerowy (nie gwiazda)"],
];
const RATE = 50.29 / 3600; // precesja °/rok

// ── TNO / Chiron / Lilith ──
const CIALA_EX = [
  ["Chiron",   OFF+2060,  "⚷"], ["Makemake", OFF+136472,"Mk"],
  ["Eris",     OFF+136199,"Er"], ["Haumea",  OFF+136108,"Ha"],
  ["Sedna",    OFF+90377, "Se"], ["Quaoar",  OFF+50000, "Qu"],
  ["Varuna",   OFF+20000, "Va"],
  ["Lilith",   12,        "⚸"],  ["Węzeł.pr", 11,       "☊t"],
];
const PLANETY = [["Słońce",0,"☉"],["Księżyc",1,"☽"],["Merkury",2,"☿"],["Wenus",3,"♀"],
  ["Mars",4,"♂"],["Jowisz",5,"♃"],["Saturn",6,"♄"],["Uran",7,"♅"],
  ["Neptun",8,"♆"],["Pluton",9,"♇"],["Węzeł.śr",10,"☊"]];

// ── aspekty ──
const ASPEKTY = [[0,"koniunkcja",8],[60,"sekstyl",4],[90,"kwadrat",6],[120,"trygon",6],[180,"opozycja",8]];

// ── czas ── JEDNO ŹRÓDŁO: tz_pl.js (29.08.2026, BADANIE_UKLADU_NERWOWEGO §II.1).
// Do 29.08 ten plik niósł własne dstEU(y,m,d) o ziarnie DOBOWYM — klasa #46/#47, ta sama,
// którą tz_pl zabił 13.08 w sześciu innych kopiach. Rozjazd zmierzony: 25.10.2026 00:30–02:59 PL
// → +1 zamiast +2. Offset zależy od INSTANTU, nie od doby.
const TZ = require('./tz_pl.js');

// ── wejście ──
const args = process.argv.slice(2);
const flags = Object.fromEntries(args.filter(a=>a.startsWith('--')).map(a=>{const[k,v]=a.slice(2).split('=');return[k,v??true];}));
const pos = args.filter(a=>!a.startsWith('--'));
let jd, opis;
if (pos[0]==='now' || pos.length===0){
  const n=new Date();
  jd = swe.julianDay(n.getUTCFullYear(),n.getUTCMonth()+1,n.getUTCDate(),n.getUTCHours()+n.getUTCMinutes()/60,1);
  opis = `⏱ ZMIERZONE TERAZ (${n.toISOString().slice(0,16)}Z)`;
} else {
  const [y,m,d,hh,mi] = pos.map(Number);
  const utcFlag = !!flags.utc;
  const off = utcFlag ? 0 : TZ.offLocal(y,m,d,hh+(mi||0)/60);
  jd = swe.julianDay(y,m,d,(hh+(mi||0)/60)-off,1);
  opis = `${d}.${String(m).padStart(2,'0')}.${y} ${String(hh).padStart(2,'0')}:${String(mi||0).padStart(2,'0')} ${utcFlag?'UTC':(off===2?'CEST':'CET')}`;
}
const LAT = Number(pos[pos.length-2]) || 52.41, LON = Number(pos[pos.length-1]) || 16.93;
const ORB_GW  = Number(flags['orb-gw'])  || 2.5;
const ORB_TNO = Number(flags['orb-tno']) || 3.0;
const rokUl = (jd - 2451545.0) / 365.25;
const ayan  = K.ayan(new Date((jd - 2440587.5) * 86400000)); // v4 przyjmuje Date

// ── obliczenia ──
const H = swe.calculateHouses(jd, LAT, LON, swe.HouseSystem.Placidus);
const cusps = H.cusps; // [0,c1..c12]
// JEDNO ŹRÓDŁO od 13.08.2026 (faza A) — było: własna kopia z closure na cusps.
const domDla = require('./domy.js').domDlaZ(cusps);

const punkty = []; // {naz,sym,lon,typ}
for (const [naz,id,sym] of PLANETY){
  const r = swe.calculatePosition(jd, id);
  punkty.push({naz,sym,lon:norm(r.longitude),typ:'planeta',retro:r.longitudeSpeed<0});
}
const luki = [];
for (const [naz,id,sym] of CIALA_EX){
  try { const r = swe.calculatePosition(jd, id);
    punkty.push({naz,sym,lon:norm(r.longitude),typ:'ex',retro:r.longitudeSpeed<0});
  } catch(e){ luki.push(naz); }
}
const osie = [ {naz:"ASC",lon:norm(H.ascendant)}, {naz:"MC",lon:norm(H.mc)},
               {naz:"DSC",lon:norm(H.ascendant+180)}, {naz:"IC",lon:norm(H.mc+180)} ];
const gwiazdy = GWIAZDY.map(([naz,l2000,tag]) => ({naz, tag, lon:norm(l2000 + RATE*rokUl)}));

// ── wydruk ──
console.log(`\n╔═══ KRONOS · PEŁNIA — φ${LAT} λ${LON} · Placidus ═══╗`);
console.log(`wejście: ${opis} · JD ${jd.toFixed(4)} · ayanamsa(v4): ${ayan.toFixed(3)}°`);
if (luki.length) console.log(`⚠ LUKA EFEMERYD: ${luki.join(', ')} — dograj plik(i) .se1 do ./ephe`);

console.log(`\n【 OSIE — NOŚNA RAMA⚠ 】`);
for (const o of osie.slice(0,2)) console.log(`${o.naz.padEnd(4)} ${fmtTrop(o.lon)}   | Lahiri: ${elLahiri(o.lon,ayan)}`);

console.log(`\n【 PLANETY + WĘZŁY + LILITH + TNO — pozycje: PRAWO 】`);
for (const p of punkty){
  const r = p.retro ? ' ℞' : '';
  console.log(`${p.sym.padEnd(2)} ${p.naz.padEnd(9)} D${String(domDla(p.lon)).padStart(2)}  ${fmtTrop(p.lon)}${r}  | ${elLahiri(p.lon,ayan)}`);
}

console.log(`\n【 GWIAZDY STAŁE (precesja do epoki) — pozycje: PRAWO · tagi: REZONANS 】`);
console.log(`— wypisywane tylko ZBITKI ≤ ${ORB_GW}° z planetami/osiami/TNO —`);
const cele = [...punkty, ...osie.map(o=>({naz:o.naz,sym:o.naz,lon:o.lon,typ:'oś'}))];
let nG=0;
for (const g of gwiazdy){
  for (const c of cele){
    let d = Math.abs(g.lon - c.lon) % 360; d = Math.min(d, 360-d);
    if (d <= ORB_GW){
      nG++;
      console.log(`★ ${g.naz.padEnd(12)} ${fmtTrop(g.lon)} — koniunkcja ${c.naz} (orb ${d.toFixed(1)}°)`);
      console.log(`    ↳ [REZONANS] ${g.tag}`);
    }
  }
}
if (!nG) console.log(`(brak zbitek w orbie ${ORB_GW}° — gwiazdy milczą w tym odczycie)`);

console.log(`\n【 ZBITKI TNO/LILITH → planety i osie ≤ ${ORB_TNO}° 】`);
let nT=0;
const exy = punkty.filter(p=>p.typ==='ex');
const bazowe = [...punkty.filter(p=>p.typ==='planeta'), ...osie.map(o=>({naz:o.naz,lon:o.lon}))];
for (const e of exy){ for (const b of bazowe){
  let d = Math.abs(e.lon-b.lon)%360; d=Math.min(d,360-d);
  if (d<=ORB_TNO){ nT++; console.log(`${e.sym.padEnd(2)} ${e.naz} — koniunkcja ${b.naz} (orb ${d.toFixed(1)}°)`); }
}}
if (!nT) console.log(`(brak zbitek w orbie ${ORB_TNO}°)`);

console.log(`\n【 ASPEKTY PLANETARNE (orby: kon/op 8° · kw/tr 6° · sx 4°) 】`);
const pl = punkty.filter(p=>p.typ==='planeta');
for (let i=0;i<pl.length;i++) for (let j=i+1;j<pl.length;j++){
  let d = Math.abs(pl[i].lon-pl[j].lon)%360; d=Math.min(d,360-d);
  for (const [ang,naz,orb] of ASPEKTY){
    if (Math.abs(d-ang)<=orb){
      console.log(`${pl[i].sym} ${pl[i].naz} — ${naz} — ${pl[j].sym} ${pl[j].naz} (orb ${Math.abs(d-ang).toFixed(1)}°)`);
      break;
    }
  }
}
console.log(`\nSTATUS: pozycje=PRAWO · osie/domy/strefa-czasu=NOŚNA RAMA · tagi gwiazd=REZONANS`);
console.log(`(interpretacja = KOMENTARZ Orkiestratora, nie diagnoza — silnik podaje liczby)`);
