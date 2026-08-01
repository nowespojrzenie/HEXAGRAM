// ============================================================
// KRONOS · OKNA WOLNYCH PLANET — Księżyc ☌▲☍ Uran/Neptun/Pluton (+Chiron opcjonalnie)
// ------------------------------------------------------------
// JEDNO ŹRÓDŁO PRAWDY: sidLon/getC/ayan importowane z kronos_v4 (NIE kopiowane).
//   Skaner liczy w DOKŁADNIE tym samym układzie syderycznym co reszta KRONOS.
//   (Scalono 23.06: scan_outer + scan_outer_ext → jeden plik. Chiron za flagą --chiron,
//    bo wisi na 'ephemeris'/Moshier = NISKIE zaufanie, SNAPSHOT 23.06. Domyślnie OFF.)
// Orb 1° (~okno 3–4h). Skan 1h + rafinacja złotym cięciem. Okno=FAKT, rezonans=KONWENCJA.
// ============================================================
const A = require('astronomy-engine');
const K = require('./kronos_v4.js');
const norm = x => ((x%360)+360)%360;

function lastSundayUTC(y,m0){const d=new Date(Date.UTC(y,m0+1,0));return d.getUTCDate()-d.getUTCDay();}
function tzOff(ms){const p=new Date(ms),y=p.getUTCFullYear();const mar=lastSundayUTC(y,2),oct=lastSundayUTC(y,9);return(ms>=Date.UTC(y,2,mar,1)&&ms<Date.UTC(y,9,oct,1))?2:1;}
function fmt(ms){const off=tzOff(ms),l=new Date(ms+off*3600000);const dni=["niedz","pon","wt","śr","czw","pt","sob"];return `${dni[l.getUTCDay()]} ${String(l.getUTCDate()).padStart(2,'0')}.${String(l.getUTCMonth()+1).padStart(2,'0')} ${String(l.getUTCHours()).padStart(2,'0')}:${String(l.getUTCMinutes()).padStart(2,'0')} ${off===2?'CEST':'CET'}`;}

let eph=null;
function sidLon(body,date){
  if(body==='Chiron'){
    if(!eph) throw new Error('Chiron wymaga modułu ephemeris (--chiron, npm i ephemeris)');
    const r=eph.getAllPlanets(date,0,52,0);
    return norm(r.observed.chiron.apparentLongitudeDd - K.ayan(date));
  }
  return K.sidLon(body,date);
}
const znak = s => K.getC(s).pl;

const OUTER = {
  Uranus:  {sym:"♅", rezonans:"wyrwa / nagłe zerwanie wzorca — coś chce wyskoczyć z koleiny"},
  Neptune: {sym:"♆", rezonans:"rozmycie granic / mgła / sen na jawie — kontur się rozpuszcza"},
  Pluto:   {sym:"♇", rezonans:"napięcie obsesyjne / przymus / to, co spod spodu pcha w górę"},
};
const CHIRON = {sym:"⚷", rezonans:"[PRÓG/klucz B] rana-która-uczy; most między granicą a zaświatem — czy okno SMAKUJE jak przejście, nie jak żywioł?"};
const ASPEKTY=[{kat:0,nazwa:"koniunkcja",sym:"☌"},{kat:120,nazwa:"trygon",sym:"▲"},{kat:180,nazwa:"opozycja",sym:"☍"}];
const ORB=1.0;

function sep(date,planet){let d=Math.abs(norm(sidLon('Moon',date)-sidLon(planet,date)));if(d>180)d=360-d;return d;}
function aspectDist(date,planet){const d=sep(date,planet);let best=null;for(const a of ASPEKTY){const diff=Math.abs(d-a.kat);if(best===null||diff<best.diff)best={...a,diff,sep:d};}return best;}

function scan(y,m,d,days,planets){
  const t0=Date.UTC(y,m-1,d)-tzOff(Date.UTC(y,m-1,d))*3600000, step=3600000, windows=[];
  for(const planet of planets){
    const meta=planet==='Chiron'?CHIRON:OUTER[planet];
    let inWin=false,winStart=null,minDiff=999,minAt=null,aspNazwa=null,aspSym=null;
    for(let t=t0;t<=t0+days*86400000;t+=step){
      const ad=aspectDist(new Date(t),planet), within=ad.diff<=ORB;
      if(within&&!inWin){inWin=true;winStart=t;minDiff=ad.diff;minAt=t;aspNazwa=ad.nazwa;aspSym=ad.sym;}
      else if(within&&inWin){if(ad.diff<minDiff){minDiff=ad.diff;minAt=t;aspNazwa=ad.nazwa;aspSym=ad.sym;}}
      else if(!within&&inWin){
        let lo=minAt-step,hi=minAt+step;
        for(let i=0;i<30;i++){const m1=lo+(hi-lo)/3,m2=hi-(hi-lo)/3;if(aspectDist(new Date(m1),planet).diff<aspectDist(new Date(m2),planet).diff)hi=m2;else lo=m1;}
        const peak=(lo+hi)/2;
        windows.push({planet,sym:meta.sym,asp:aspNazwa,aspSym,start:winStart,end:t,peak,
          exact:aspectDist(new Date(peak),planet).diff,znak:znak(sidLon(planet,new Date(peak))),rez:meta.rezonans});
        inWin=false;
      }
    }
  }
  windows.sort((a,b)=>a.peak-b.peak);
  return windows;
}

module.exports={scan, sidLon};

if(require.main===module){
  const args=process.argv.slice(2);
  const useChiron=args.includes('--chiron');
  const [Y,M,D,N]=args.filter(a=>!a.startsWith('--')).map(Number);
  const planets=Object.keys(OUTER);
  if(useChiron){try{eph=require('ephemeris');planets.push('Chiron');}catch(e){console.log('⚠ Chiron pominięty: brak modułu ephemeris (npm i ephemeris)');}}
  const w=scan(Y,M,D,N||30,planets);
  console.log(`\n╔═ KRONOS · OKNA WOLNYCH PLANET — Księżyc ☌▲☍ ${planets.join('/')} ═╗`);
  console.log(`   od ${D}.${M}.${Y} przez ${N||30} dni · orb ${ORB}° · godzina lokalna PL`);
  console.log(`   (okno = FAKT astronomiczny · rezonans = KONWENCJA, do potwierdzenia w ciele)\n`);
  if(!w.length){console.log("  Brak ścisłych aspektów w tym oknie.");}
  for(const e of w){
    console.log(`  ${e.sym} ${e.aspSym} ${e.planet.padEnd(7)} w ${e.znak}`);
    console.log(`     szczyt:  ${fmt(e.peak)}  (ścisłość ${e.exact.toFixed(2)}°)`);
    console.log(`     okno:    ${fmt(e.start)}  →  ${fmt(e.end)}   (~${((e.end-e.start)/3600000).toFixed(1)}h)`);
    console.log(`     rezonans: ${e.rez}\n`);
  }
}
