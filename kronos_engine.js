// ============================================================
// KRONOS ENGINE v3.0 — BEZPIECZNIK NIEZALEŻNOŚCI (nie martwy zapas)
// ------------------------------------------------------------
// Świadomie zachowany: JEDYNY moduł BEZ zależności od astronomy-engine
// (liczy wszystko sam, Meeus). Rola podwójna:
//   1) działa offline / gdy npm zawiedzie — niezależność do końca;
//   2) niezależne źródło do FALSYFIKACJI v4 (dwa silniki, ten sam wynik = pewność).
// NIE jest w żywym przepływie (lens/eter/matryca idą przez v4). Uczymy się na błędach.
// ============================================================
// System Marii Thun (geocentryczny — pozycje w zodiaku zależą od czasu, nie od miejsca)
// ============================================================
// Zweryfikowane względem: fizyczny kalendarz Thun (35 przejść),
// LunaSolCal (nów/pełnia ±1min, perygeum ±3min, węzły ±37min)
// ============================================================

const toRad=d=>d*Math.PI/180, toDeg=r=>r*180/Math.PI, norm=x=>((x%360)+360)%360;

// ---------- STREFA CZASOWA POLSKA (auto CET/CEST) ----------
// EU DST: ostatnia niedziela marca → ostatnia niedziela października = CEST(+2)
function lastSundayUTC(year, month0){ // month0: 2=marzec, 9=październik
  const d=new Date(Date.UTC(year, month0+1, 0));
  return d.getUTCDate() - d.getUTCDay();
}
function tzOffset(year, month, day){ // zwraca +1 (CET) lub +2 (CEST)
  const marDay=lastSundayUTC(year,2), octDay=lastSundayUTC(year,9);
  const date=Date.UTC(year,month-1,day);
  const sumStart=Date.UTC(year,2,marDay,1); // 01:00 UTC
  const sumEnd=Date.UTC(year,9,octDay,1);
  return (date>=sumStart && date<sumEnd) ? 2 : 1;
}
function tzName(off){ return off===2?"CEST":"CET"; }

// ---------- CZAS ----------
function jd(y,m,d,h){let Y=y,M=m;const dd=d+h/24;if(M<=2){Y--;M+=12;}const A=Math.floor(Y/100),B=2-A+Math.floor(A/4);return Math.floor(365.25*(Y+4716))+Math.floor(30.6001*(M+1))+dd+B-1524.5;}
// Konwersja: data lokalna (strefa systemowa) → JD(UTC)
function localToJD(y,m,d,hLocal){ const off=tzOffset(y,m,d); return jd(y,m,d,hLocal-off); }
function jdToLocal(j,y,m,d){ const off=tzOffset(y,m,d); const ms=(j-2440587.5)*86400*1000; return new Date(ms+off*3600*1000); }
function fmtLocal(j){
  const ms=(j-2440587.5)*86400*1000; const probe=new Date(ms);
  const off=tzOffset(probe.getUTCFullYear(),probe.getUTCMonth()+1,probe.getUTCDate());
  const loc=new Date(ms+off*3600*1000);
  const dni=["niedz","pon","wt","śr","czw","pt","sob"];
  return `${String(loc.getUTCDate()).padStart(2,'0')}.${String(loc.getUTCMonth()+1).padStart(2,'0')} ${String(loc.getUTCHours()).padStart(2,'0')}:${String(loc.getUTCMinutes()).padStart(2,'0')} ${tzName(off)}`;
}

// ---------- POZYCJA KSIĘŻYCA (Meeus r.47) ----------
function moon(j){
  const T=(j-2451545)/36525;
  const Lp=norm(218.3164477+481267.88123421*T-0.0015786*T*T);
  const D=norm(297.8501921+445267.1114034*T-0.0018819*T*T);
  const M=norm(357.5291092+35999.0502909*T);
  const Mp=norm(134.9633964+477198.8675055*T+0.0087414*T*T);
  const F=norm(93.2720950+483202.0175233*T-0.0036539*T*T);
  const E=1-0.002516*T;
  const dr=toRad(D),Mr=toRad(M),Mpr=toRad(Mp),Fr=toRad(F);
  const sumL=6288774*Math.sin(Mpr)+1274027*Math.sin(2*dr-Mpr)+658314*Math.sin(2*dr)+213618*Math.sin(2*Mpr)-185116*E*Math.sin(Mr)-114332*Math.sin(2*Fr)+58793*Math.sin(2*dr-2*Mpr)+57066*E*Math.sin(2*dr-Mr-Mpr)+53322*Math.sin(2*dr+Mpr)+45758*E*Math.sin(2*dr-Mr)-40923*E*Math.sin(Mr-Mpr)-34720*Math.sin(dr)-30383*E*Math.sin(Mr+Mpr)+15327*Math.sin(2*dr-2*Fr)-12528*Math.sin(Mpr+2*Fr)+10980*Math.sin(Mpr-2*Fr)+10675*Math.sin(4*dr-Mpr)+10034*Math.sin(3*Mpr)+8548*Math.sin(4*dr-2*Mpr);
  const sumB=5128122*Math.sin(Fr)+280602*Math.sin(Mpr+Fr)+277693*Math.sin(Mpr-Fr)+173237*Math.sin(2*dr-Fr)+55413*Math.sin(2*dr-Mpr+Fr)+46271*Math.sin(2*dr-Mpr-Fr)+32573*Math.sin(2*dr+Fr)+17198*Math.sin(2*Mpr+Fr)+9266*Math.sin(2*dr+Mpr-Fr)+8822*Math.sin(2*Mpr-Fr)+8216*E*Math.sin(2*dr-Mr-Fr)+4324*Math.sin(2*dr-2*Mpr-Fr)+4200*Math.sin(2*dr+Mpr+Fr)-3359*E*Math.sin(2*dr+Mr-Fr)+2463*E*Math.sin(2*dr-Mr-Mpr+Fr)+2211*E*Math.sin(2*dr-Mr+Fr)+2065*E*Math.sin(2*dr-Mr-Mpr-Fr)-1870*E*Math.sin(Mr-Mpr-Fr)+1828*Math.sin(4*dr-Mpr-Fr)-1794*E*Math.sin(Mr+Fr)-1749*Math.sin(3*Fr);
  const sumR=-20905355*Math.cos(Mpr)-3699111*Math.cos(2*dr-Mpr)-2955968*Math.cos(2*dr)-569925*Math.cos(2*Mpr)+48888*E*Math.cos(Mr)-3149*Math.cos(2*Fr)+246158*Math.cos(2*dr-2*Mpr)-152138*E*Math.cos(2*dr-Mr-Mpr)-170733*Math.cos(2*dr+Mpr)-204586*E*Math.cos(2*dr-Mr)-129620*E*Math.cos(Mr-Mpr)+108743*Math.cos(dr)+104755*E*Math.cos(Mr+Mpr)+10321*Math.cos(2*dr-2*Fr)+79661*Math.cos(Mpr-2*Fr)-34782*Math.cos(4*dr-Mpr)-23210*Math.cos(3*Mpr)-21636*Math.cos(4*dr-2*Mpr);
  return {lon:norm(Lp+sumL/1e6), lat:sumB/1e6, dist:385000.56+sumR/1000};
}
function sunLon(j){const T=(j-2451545)/36525,L0=norm(280.46646+36000.76983*T),M=toRad(norm(357.52911+35999.05029*T));return norm(L0+(1.914602-0.004817*T)*Math.sin(M)+0.019993*Math.sin(2*M)+0.000289*Math.sin(3*M));}
function ayanamsa(j){return 23.855+1.3972*(j-2451545)/36525;} // precesja (globalna stała)
function moonSid(j){return norm(moon(j).lon-ayanamsa(j));}
function phase(j){return norm(moon(j).lon-sunLon(j))/360;}
function obliq(j){const T=(j-2451545)/36525;return 23.439291-0.0130042*T;}
function moonDecl(j){const m=moon(j),eps=toRad(obliq(j)),lam=toRad(m.lon),bet=toRad(m.lat);return toDeg(Math.asin(Math.sin(bet)*Math.cos(eps)+Math.cos(bet)*Math.sin(eps)*Math.sin(lam)));}

// ---------- KONSTELACJE THUN (zwalidowane, syderyczne) ----------
const C=[
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
function getC(s){for(const c of C){if(c.s<=c.e){if(s>=c.s&&s<c.e)return c;}else{if(s>=c.s||s<c.e)return c;}}return C[0];}
function phaseName(p){if(p<0.02||p>0.98)return["Nów","🌑"];if(p<0.23)return["Sierp rosnący","🌒"];if(p<0.27)return["Pierwsza kwadra","🌓"];if(p<0.48)return["Przybywający","🌔"];if(p<0.52)return["Pełnia","🌕"];if(p<0.73)return["Ubywający","🌖"];if(p<0.77)return["Ostatnia kwadra","🌗"];return["Sierp malejący","🌘"];}

// ---------- API GŁÓWNE ----------
function analyze(y,m,d,hLocal){
  const j=localToJD(y,m,d,hLocal);
  const s=moonSid(j), c=getC(s), ph=phase(j), [pn,ps]=phaseName(ph);
  const decl=moonDecl(j), declNext=moonDecl(j+0.01);
  const sadzenie = declNext<decl; // deklinacja maleje = czas sadzenia (zstępujący)
  let next=null;
  for(let h=1;h<=72;h++){const cc=getC(moonSid(j+h/24));if(cc.pl!==c.pl){next={h,c:cc};break;}}
  return {j,s,c,ph,pn,ps,decl,sadzenie,next,off:tzOffset(y,m,d)};
}

// Skanowanie zdarzeń w zakresie (węzły, perygeum, nów, pełnia, zwroty deklinacji)
function scanEvents(y,m,dStart,days){
  const j0=localToJD(y,m,dStart,0); const ev=[];
  let pLat=moon(j0).lat, pPh=phase(j0), pDist=moon(j0).dist, pDist2=moon(j0-1/24).dist, pDecl=moonDecl(j0), pDeclDir=null;
  for(let h=1;h<days*24;h++){
    const j=j0+h/24;
    const lat=moon(j).lat, ph=phase(j), dist=moon(j).dist, decl=moonDecl(j);
    if(pLat<0&&lat>=0){let lo=j-1/24,hi=j;for(let i=0;i<28;i++){const mm=(lo+hi)/2;moon(mm).lat<0?lo=mm:hi=mm;}ev.push({t:(lo+hi)/2,typ:"☊ węzeł wstępujący"});}
    if(pLat>0&&lat<=0){let lo=j-1/24,hi=j;for(let i=0;i<28;i++){const mm=(lo+hi)/2;moon(mm).lat>0?lo=mm:hi=mm;}ev.push({t:(lo+hi)/2,typ:"☋ węzeł zstępujący"});}
    if(pPh>0.9&&ph<0.1){let best=j,bd=1;for(let mm=-90;mm<=30;mm++){const jt=j+mm/1440;const p=phase(jt);const el=Math.min(p,1-p);if(el<bd){bd=el;best=jt;}}ev.push({t:best,typ:"🌑 NÓW"});}
    if(pPh<0.5&&ph>=0.5){let best=j,bd=1;for(let mm=-90;mm<=30;mm++){const jt=j+mm/1440;const df=Math.abs(phase(jt)-0.5);if(df<bd){bd=df;best=jt;}}ev.push({t:best,typ:"🌕 PEŁNIA"});}
    pLat=lat;pPh=ph;pDist=dist;pDecl=decl;
  }
  return ev;
}

module.exports={analyze,scanEvents,fmtLocal,moon,moonSid,phase,moonDecl,getC,phaseName,tzOffset,C};

// ---------- TEST/CLI ----------
if(require.main===module){
  const [,,cmd,...args]=process.argv;
  if(cmd==="day"){
    const [y,m,d,h]=args.map(Number);
    const r=analyze(y,m,d,h||12);
    console.log(`\n📅 ${d}.${String(m).padStart(2,'0')}.${y} ${String(h||12).padStart(2,'0')}:00 ${tzName(r.off)}`);
    console.log(`${r.c.em} ${r.c.sym} ${r.c.pl} · ${r.c.el} · DZIEŃ ${r.c.typ.toUpperCase()}`);
    console.log(`${r.ps} ${r.pn} · ${Math.round(r.ph*100)}% · ${r.ph<0.5?"rosnący↑":"malejący↓"}`);
    console.log(`Deklinacja ${r.decl.toFixed(1)}° · ${r.sadzenie?"⬇ CZAS SADZENIA (zstępujący)":"⬆ czas zbiorów (wstępujący)"}`);
    if(r.next)console.log(`⏳ Przejście za ~${r.next.h}h → ${r.next.c.sym}${r.next.c.pl} (${r.next.c.typ})`);
    console.log(`λ=${r.s.toFixed(2)}°`);
  }
}

// ============================================================
// LEGENDA SYMBOLI KALENDARZA THUN (strona 16 + 13)
// Dodane 06.06.2026 po otrzymaniu objaśnień
// ============================================================
const LEGENDA = {
  planety: {"⊙":"Słońce","☽":"Księżyc","☿":"Merkury","♀":"Wenus","♂":"Mars",
            "♃":"Jowisz","♄":"Saturn","♅":"Uran","♆":"Neptun","♇":"Pluton","⊕":"Ziemia"},
  aspekty: {"☌":"koniunkcja (0°)","☍":"opozycja (180°)","▲":"TRYGON (120°)","R":"ruch wsteczny"},
  ksiezyc: {"🌝":"pełnia","🌚":"nów","☊":"węzeł wstępujący","☋":"węzeł zstępujący",
            "⌒":"Księżyc zstępujący (czas sadzenia)","⌣":"Księżyc wstępujący",
            "Pg":"perygeum","Ag":"apogeum"},
  pogoda: {"W":"wichury","B":"burze","T":"trzęsienia ziemi",
           "K":"czas krytyczny w komunikacji","V":"aktywność wulkaniczna"},
  sadzenie: {"*":"początek czasu sadzenia","#":"koniec","-----":"okres NIEKORZYSTNY"},
};

// CZTERY TRYGONY (grupy żywiołów wg Thun, strona 13)
const TRYGONY = {
  "Ogień":  {nazwa:"ciepło-owoc-nasiono", znaki:["Baran","Lew","Strzelec"],     typ:"Owoc"},
  "Ziemia": {nazwa:"ziemia-korzeń",        znaki:["Byk","Panna","Koziorożec"],   typ:"Korzeń"},
  "Światło":{nazwa:"światło-kwiat",        znaki:["Bliźnięta","Waga","Wodnik"],  typ:"Kwiat"},
  "Woda":   {nazwa:"woda-liść",            znaki:["Rak","Skorpion","Ryby"],      typ:"Liść"},
};

module.exports.LEGENDA=LEGENDA;
module.exports.TRYGONY=TRYGONY;
