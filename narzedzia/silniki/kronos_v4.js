// ============================================================
// KRONOS v4.0 — Niezależny System Biodynamiczny
// Silnik: astronomy-engine (VSOP87+NOVAS, ±1' łuku, JPL-tested)
// System Marii Thun (silnik liczy geocentrycznie — miejsce nieistotne dla pozycji w zodiaku)
// ============================================================
const A = require('astronomy-engine');
const norm = x => ((x%360)+360)%360;

// --- Strefa czasowa Polska (auto CET/CEST) ---
const TZ=require('./tz_pl.js');   // JEDNO ŹRÓDŁO czasu lokalnego (13.08.2026)
const localDate=TZ.localDate;
const fmt=TZ.fmt;

// --- Ayanamsa (precesja, globalna stała) ---
function ayan(date){const jd=2440587.5+date.getTime()/86400000;return 23.855+1.3972*(jd-2451545)/36525;}

// --- Pozycje syderyczne (Thun) ---
function sidLon(body,date){let lon;if(body==='Moon')lon=A.EclipticGeoMoon(date).lon;else lon=A.Ecliptic(A.GeoVector(A.Body[body],date,true)).elon;return norm(lon-ayan(date));}

// --- Konstelacje Thun (zwalidowane: 35 przejść Księżyca + daty Słońca) ---
const CONST=[
  {pl:"Ryby",sym:"♓",s:327.7,e:5.6,el:"Woda",typ:"Liść",em:"🌿"},
  {pl:"Baran",sym:"♈",s:5.6,e:29.9,el:"Ogień",typ:"Owoc",em:"🍎"},
  {pl:"Byk",sym:"♉",s:29.9,e:65.9,el:"Ziemia",typ:"Korzeń",em:"🌱"},
  {pl:"Bliźnięta",sym:"♊",s:65.9,e:93.5,el:"Światło",typ:"Kwiat",em:"🌸"},
  {pl:"Rak",sym:"♋",s:93.5,e:114.9,el:"Woda",typ:"Liść",em:"🌿"},
  {pl:"Lew",sym:"♌",s:114.9,e:149.8,el:"Ogień",typ:"Owoc",em:"🍎"},
  {pl:"Panna",sym:"♍",s:149.8,e:195.8,el:"Ziemia",typ:"Korzeń",em:"🌱"},
  {pl:"Waga",sym:"♎",s:195.8,e:213.7,el:"Światło",typ:"Kwiat",em:"🌸"},
  {pl:"Skorpion",sym:"♏",s:213.7,e:244.8,el:"Woda",typ:"Liść",em:"🌿"},
  {pl:"Strzelec",sym:"♐",s:244.8,e:274.7,el:"Ogień",typ:"Owoc",em:"🍎"},
  {pl:"Koziorożec",sym:"♑",s:274.7,e:302.7,el:"Ziemia",typ:"Korzeń",em:"🌱"},
  {pl:"Wodnik",sym:"♒",s:302.7,e:327.7,el:"Światło",typ:"Kwiat",em:"🌸"},
];
function getC(s){for(const c of CONST){if(c.s<=c.e){if(s>=c.s&&s<c.e)return c;}else{if(s>=c.s||s<c.e)return c;}}return CONST[0];}

// --- Faza Księżyca (astronomy-engine, dokładna) ---
function phaseInfo(date){
  const ang=A.MoonPhase(date); // 0=nów,90=I kw,180=pełnia,270=III kw
  const illum=A.Illumination(A.Body.Moon,date).phase_fraction; // 0..1 oświetlenie
  const wax=ang<180;
  let nm,sm;
  if(illum<0.02){nm="Nów";sm="🌑";}
  else if(illum>0.98){nm="Pełnia";sm="🌕";}
  else if(Math.abs(illum-0.5)<0.03){nm=wax?"Pierwsza kwadra":"Ostatnia kwadra";sm=wax?"🌓":"🌗";}
  else if(illum<0.5&&wax){nm="Sierp rosnący";sm="🌒";}
  else if(illum>=0.5&&wax){nm="Garbaty przybywający";sm="🌔";}
  else if(illum>=0.5&&!wax){nm="Garbaty ubywający";sm="🌖";}
  else{nm="Sierp malejący";sm="🌘";}
  return {ang,p:ang/360,illum,nm,sm,wax};
}

// --- Deklinacja / czas sadzenia ---
function moonDecl(date){const m=A.EclipticGeoMoon(date);const T=(2440587.5+date.getTime()/86400000-2451545)/36525;const eps=(23.439291-0.0130042*T)*Math.PI/180;const lam=m.lon*Math.PI/180,bet=m.lat*Math.PI/180;return Math.asin(Math.sin(bet)*Math.cos(eps)+Math.cos(bet)*Math.sin(eps)*Math.sin(lam))*180/Math.PI;}

// --- ASPEKTY planeta↔Księżyc (koniunkcja/trygon/opozycja) ---
const PLANETS=['Sun','Mercury','Venus','Mars','Jupiter','Saturn'];
const PSYM={Sun:'⊙',Mercury:'☿',Venus:'♀',Mars:'♂',Jupiter:'♃',Saturn:'♄'};
function aspects(date,orb=3){
  const mS=sidLon('Moon',date);const out=[];
  for(const p of PLANETS){
    const pS=sidLon(p,date);let d=norm(mS-pS);if(d>180)d=360-d;
    let a=null;
    if(Math.abs(d)<orb)a="☌";else if(Math.abs(d-120)<orb)a="▲";else if(Math.abs(d-180)<orb)a="☍";
    if(a){const c=getC(pS);out.push({asp:a,planet:p,sym:PSYM[p],lon:pS,konst:c});}
  }
  return out;
}

// --- API ---
function analyze(y,m,d,hLocal){
  const date=localDate(y,m,d,TZ.godzWejscia(hLocal));
  const s=sidLon('Moon',date);const c=getC(s);
  const ph=phaseInfo(date);
  const decl=moonDecl(date);
  const decl2=moonDecl(new Date(date.getTime()+3600000));
  const sadzenie=decl2<decl;
  const asp=aspects(date);
  let next=null;
  for(let h=1;h<=72;h++){const dd=new Date(date.getTime()+h*3600000);const cc=getC(sidLon('Moon',dd));if(cc.pl!==c.pl){next={h,c:cc};break;}}
  return {date,s,c,ph,decl,sadzenie,asp,next,off:TZ.offAt(date)};
}

// ayan eksportowany świadomie (23.06): scan_outer importuje go zamiast trzymać własną kopię
// — jedno źródło prawdy o ayanamsie dla całego systemu.

// --- DRAKONIAN (zero = węzeł wstępujący Księżyca, oś progu/[ODDECH]) — scalono z ZIP-A 26.06 ---
// Średni węzeł wstępujący (Meeus), tropikalny. Dokładność ±1.5° vs prawdziwy oscylujący.
function meanNode(date){const jd=2440587.5+date.getTime()/86400000;const T=(jd-2451545)/36525;let o=125.0445479-1934.1362891*T+0.0020754*T*T+T*T*T/467441;return norm(o);}
// Długość drakoniczna: tropikalna pozycja minus węzeł. Body: 'Moon' lub klucz A.Body.
function draconicLon(body,date){let lon;if(body==='Moon')lon=A.EclipticGeoMoon(date).lon;else lon=A.Ecliptic(A.GeoVector(A.Body[body],date,true)).elon;return norm(lon-meanNode(date));}

module.exports={analyze,aspects,sidLon,getC,phaseInfo,moonDecl,CONST,PLANETS,PSYM,ayan,meanNode,draconicLon};

// --- CLI ---
if(require.main===module){
  const [,,y,m,d,h]=process.argv.map(Number);
  const r=analyze(y,m,d,TZ.godzWejscia(h));
  console.log(`\n📅 ${d}.${String(m).padStart(2,'0')}.${y} ${String(TZ.godzWejscia(h)).padStart(2,'0')}:00 ${TZ.nazwa(r.off)}`);
  console.log(`${r.c.em} ${r.c.sym} ${r.c.pl} · ${r.c.el} · DZIEŃ ${r.c.typ.toUpperCase()}`);
  console.log(`${r.ph.sm} ${r.ph.nm} · oświetlenie ${Math.round(r.ph.illum*100)}% · ${r.ph.wax?'rosnący↑':'malejący↓'}`);
  console.log(`Deklinacja ${r.decl.toFixed(1)}° · ${r.sadzenie?'⬇ CZAS SADZENIA':'⬆ czas zbiorów'}`);
  if(r.next)console.log(`⏳ Przejście za ~${r.next.h}h → ${r.next.c.sym}${r.next.c.pl} (${r.next.c.typ})`);
  if(r.asp.length){
    console.log(`\n⚠ AKTYWNE ASPEKTY PLANETARNE (mogą nadpisać żywioł na pewne godziny):`);
    for(const a of r.asp)console.log(`   ☽ ${a.asp} ${a.sym}${a.planet} w ${a.konst.sym}${a.konst.pl} (${a.konst.el}/${a.konst.typ})`);
    console.log(`   → Dokładne godziny i kierunek nadpisania: SPRAWDŹ fizyczny kalendarz Thun`);
  } else {
    console.log(`\n✓ Brak silnych aspektów — żywioł dnia czysty (typ wg konstelacji)`);
  }
}
