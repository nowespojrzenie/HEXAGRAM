// ============================================================
// KRONOS · ETER — tło wszystkich potencjałów
// Eter = pole/ekran, na którym kręci się koło (nie żywioł, nie faza; Prawo 4). „Eter — jest."
// Dwie twarze: ciągłe TŁO (zawsze obecne) + UJAWNIENIE w przerwach (oddech) na każdej skali.
// Ten moduł czyni eter widzialnym: łapie OTWARCIA (oddech), ich głębokość i stronę.
// W otwarciu: Śmierć (przed) → [eter / pustka potencjałów] → Metal (po).
// Świadomość (Prześwit) zapala się dopiero przy Ogniu; w eterze to jeszcze pre-świadomy potencjał.
// Warstwa addytywna. NIE zmienia silnika (kronos_v4.js).
// Optymalizacja 23.06: breath() rozdziela AKTYWNOŚĆ (gęsto, ±20h = maxOrb+margines)
//   od NAWIGACJI next/prev (tani skaner krawędzi krokiem 6h, zasięg 120h).
//   −72% wywołań efemeryd, 3× szybciej, wyniki open/strona/głębokość identyczne;
//   naprawiony cichy bug: stare okno ±72h gubiło próg przy odstępie >72h (Panna 46°).
//   Orby T1–T4 nadal = kalibracja do papieru Thuna (pole otwarte, niezmienione).
// ============================================================
const A = require('astronomy-engine');
const K = require('./kronos_v4.js');

// --- KALIBRACJA (orby w godzinach). Dostrajaj do fizycznego kalendarza Thun. ---
// To jest świadoma granica niezależności: KRONOS sygnalizuje głębokość,
// papier Thuna pozostaje autorytetem dla dokładnych okien.
const TIER = {
  1: { name: "mikro · przejście konstelacji", orb: 4  },
  2: { name: "próg · węzeł / perygeum",        orb: 12 },
  3: { name: "oddech fazy · nów / pełnia",     orb: 12 },
  4: { name: "wielki oddech · zaćmienie",      orb: 18 },
};
const ECLIPSE_LAT = 1.5; // |szer.| Księżyca przy syzygium < tyle° => zaćmienie prawdopodobne

// --- strefa PL (CET/CEST) ---
function lastSundayUTC(y,m0){const d=new Date(Date.UTC(y,m0+1,0));return d.getUTCDate()-d.getUTCDay();}
function tzOff(ms){const p=new Date(ms),y=p.getUTCFullYear();const mar=lastSundayUTC(y,2),oct=lastSundayUTC(y,9);return(ms>=Date.UTC(y,2,mar,1)&&ms<Date.UTC(y,9,oct,1))?2:1;}
function localMs(y,m,d,h){const g=Date.UTC(y,m-1,d,h);return g-tzOff(g)*3600000;}
function fmt(d){const ms=d.getTime(),off=tzOff(ms),l=new Date(ms+off*3600000);return `${String(l.getUTCDate()).padStart(2,'0')}.${String(l.getUTCMonth()+1).padStart(2,'0')} ${String(l.getUTCHours()).padStart(2,'0')}:${String(l.getUTCMinutes()).padStart(2,'0')} ${off===2?'CEST':'CET'}`;}

// --- pomiary ---
const phaseAng = d => A.MoonPhase(d); // 0=nów, 180=pełnia
// jedna próbka Księżyca: EclipticGeoMoon liczy lon+lat+dist RAZ; konstelacja z lon (bez 2. wywołania)
function moonSample(d){
  const m=A.EclipticGeoMoon(d);
  const sid=((m.lon - K.ayan(d))%360+360)%360;
  return {lat:m.lat, dist:m.dist, cpl:K.getC(sid).pl};
}
const lat  = d => A.EclipticGeoMoon(d).lat;  // używane tylko w refineZero (rzadko)
const dist = d => A.EclipticGeoMoon(d).dist; // używane tylko w refineExt (rzadko)

function refineZero(f,t0,t1,iter=44){let a=t0,b=t1,fa=f(a);for(let i=0;i<iter;i++){const m=(a+b)/2,fm=f(m);if((fa<0)===(fm<0)){a=m;fa=fm;}else b=m;}return new Date((a+b)/2);}
function refineExt(f,t0,t1,isMin,iter=60){let a=t0,b=t1;for(let i=0;i<iter;i++){const m1=a+(b-a)/3,m2=b-(b-a)/3;const f1=f(new Date(m1)),f2=f(new Date(m2));if(isMin?f1<f2:f1>f2)b=m2;else a=m1;}return new Date((a+b)/2);}

// --- wykrywanie wszystkich progów w [t0,t1] (ms) ---
// Jedna próbka na godzinę (moonSample = 1× EclipticGeoMoon + 1× MoonPhase).
// Perygeum/apogeum z bufora 3 kolejnych próbek (dist) — bez osobnej pętli.
function detectThresholds(t0,t1){
  const step=3600000, out=[]; let prev=null, prev2=null;
  for(let t=t0;t<=t1;t+=step){
    const d=new Date(t);
    const s=moonSample(d);
    const cur={t, cpl:s.cpl, lat:s.lat, dist:s.dist, ph:phaseAng(d)};
    if(prev){
      if(cur.cpl!==prev.cpl){
        const before=prev.cpl;
        const tt=refineZero(ms=>(moonSample(new Date(ms)).cpl===before)?-1:1, prev.t, cur.t);
        out.push({t:tt, tier:1, kind:`⌁ ${prev.cpl}→${cur.cpl}`});
      }
      if((prev.lat<0&&cur.lat>=0)||(prev.lat>0&&cur.lat<=0)){
        const tt=refineZero(ms=>lat(new Date(ms)), prev.t, cur.t);
        out.push({t:tt, tier:2, kind:(prev.lat<0?"☊ węzeł wstępujący":"☋ węzeł zstępujący")});
      }
      if(prev.ph>350&&cur.ph<10){
        const tt=refineZero(ms=>{const v=phaseAng(new Date(ms));return v>180?v-360:v;}, prev.t, cur.t);
        const ecl=Math.abs(lat(tt))<ECLIPSE_LAT;
        out.push({t:tt, tier:ecl?4:3, kind:ecl?"🌑 NÓW · zaćmienie Słońca":"🌑 NÓW"});
      }
      if(prev.ph<180&&cur.ph>=180){
        const tt=refineZero(ms=>phaseAng(new Date(ms))-180, prev.t, cur.t);
        const ecl=Math.abs(lat(tt))<ECLIPSE_LAT;
        out.push({t:tt, tier:ecl?4:3, kind:ecl?"🌕 PEŁNIA · zaćmienie Księżyca":"🌕 PEŁNIA"});
      }
      // perygeum/apogeum z bufora 3 próbek (prev2,prev,cur) — bez ponownego liczenia dist
      if(prev2){
        if(prev.dist<prev2.dist&&prev.dist<cur.dist) out.push({t:refineExt(dist,prev2.t,cur.t,true),  tier:2, kind:"Pg perygeum"});
        if(prev.dist>prev2.dist&&prev.dist>cur.dist) out.push({t:refineExt(dist,prev2.t,cur.t,false), tier:2, kind:"Ag apogeum"});
      }
    }
    prev2=prev; prev=cur;
  }
  out.sort((x,y)=>x.t-y.t);
  return out;
}

// --- maks. orb (najgłębsza warstwa) + margines: okno aktywności przerwy ---
const MAX_ORB = Math.max(...Object.values(TIER).map(t=>t.orb)); // 18
const ACTIVE_SPAN = (MAX_ORB + 2) * 3600000; // ±20h — wystarcza na każdą otwartą przerwę

// --- lekki skaner krawędzi: pierwszy próg w danym kierunku, bez gęstego liczenia całości ---
// Szuka grubym krokiem 6h aż wykryje JAKĄKOLWIEK zmianę (konstelacja/węzeł/faza/ekstremum),
// potem zawęża do godziny i oddaje do detectThresholds. Pokrywa odstępy >90h tanio.
function edgeThreshold(T0, dir){ // dir +1 = w przyszłość, -1 = w przeszłość
  const step = 6*3600000, limit = 120*3600000; // do 5 dni — pokrywa max odstęp 90h z zapasem
  let prev = sampleState(new Date(T0));
  for(let dt=step; dt<=limit; dt+=step){
    const t = T0 + dir*dt;
    const cur = sampleState(new Date(t));
    if(stateChanged(prev,cur)){
      const lo = Math.min(t, t-dir*step), hi = Math.max(t, t-dir*step);
      const found = detectThresholds(lo-3600000, hi+3600000);
      if(found.length){
        found.sort((a,b)=>dir*(a.t-b.t)>0?1:-1); // najbliższy w kierunku dir
        const pick = dir>0 ? found.filter(e=>e.t.getTime()>T0).sort((a,b)=>a.t-b.t)[0]
                           : found.filter(e=>e.t.getTime()<T0).sort((a,b)=>b.t-a.t)[0];
        if(pick){ // dołóż delta/orb tak jak gęste okno — inaczej wydruk sincePrev/untilNext pada (bug 24.06)
          pick.delta = (T0 - pick.t.getTime())/3600000;
          pick.orb = TIER[pick.tier].orb;
          return pick;
        }
      }
    }
    prev = cur;
  }
  return null;
}
function sampleState(d){const s=moonSample(d);return {cpl:s.cpl, lat:s.lat, ph:phaseAng(d), dist:s.dist};}
function stateChanged(a,b){return a.cpl!==b.cpl || (a.lat<0)!==(b.lat<0) || Math.abs(a.ph-b.ph)>40 || Math.sign(b.dist-a.dist)!==0;}

// --- ODDECH dla konkretnej chwili ---
function breath(T){
  const Tms=T.getTime();
  // 1) aktywność: gęsto, ale tylko w oknie ±ACTIVE_SPAN (20h) — tu mieści się każda przerwa
  const th=detectThresholds(Tms-ACTIVE_SPAN, Tms+ACTIVE_SPAN).map(e=>{
    const delta=(Tms-e.t.getTime())/3600000;
    return {...e, delta, orb:TIER[e.tier].orb, within:Math.abs(delta)<=TIER[e.tier].orb};
  });
  const active=th.filter(e=>e.within);
  // 2) nawigacja: najbliższy próg z każdej strony — najpierw w oknie aktywności, potem tani skan krawędzi
  let past  =th.filter(e=>e.delta>0).sort((a,b)=>a.delta-b.delta)[0]||null;
  let future=th.filter(e=>e.delta<0).sort((a,b)=>b.delta-a.delta)[0]||null;
  if(!past)   past   = edgeThreshold(Tms,-1);
  if(!future) future = edgeThreshold(Tms,+1);
  if(!active.length) return {open:false, nearby:th, sincePrev:past, untilNext:future};
  const depth=Math.max(...active.map(e=>e.tier));
  const dom=active.filter(e=>e.tier===depth).sort((a,b)=>Math.abs(a.delta)-Math.abs(b.delta))[0];
  const o=dom.orb; let side, guide, pyt;
  if(dom.delta < -o/3){ side="ŚMIERĆ (przed)"; guide="Domykanie. Oczyść, odpuść, zakończ — nie wnoś nowego w przerwę."; pyt="Co jest już martwe, a Ty to niesiesz?"; }
  else if(dom.delta > o/3){ side="METAL (po)"; guide="Wdech. Wola kuje strukturę — informacja dostaje po czym płynąć. Uświadomienie przyjdzie dopiero z Ogniem."; pyt="Jakie jedno cięcie / jaka dyscyplina to porządkuje?"; }
  else { side="ETER (w progu)"; guide="Pustka wszystkich potencjałów. Nie ładuj, nie wybieraj. Oddech — czekaj na wdech."; pyt="Co chce się tu narodzić, gdy niczego nie wybieram?"; }
  return {open:true, depth, tierName:TIER[depth].name, side, guide, pyt, dominant:dom, active, nearby:th, sincePrev:past, untilNext:future};
}

function scan(t0,t1){return detectThresholds(t0,t1);}

module.exports={breath, scan, detectThresholds, TIER};

// --- CLI ---
if(require.main===module){
  const a=process.argv.slice(2);
  if(a[0]==='scan'){
    const y=+a[1],m=+a[2],d=+a[3],days=+(a[4]||28);
    const t0=localMs(y,m,d,0), t1=t0+days*86400000;
    const th=scan(t0,t1);
    console.log(`\n╔═ KRONOS · ODDECH — przerwy ${d}.${m}.${y} (+${days} dni) ═╗`);
    console.log(`(głębokość: 1 mikro · 2 próg · 3 faza · 4 zaćmienie)\n`);
    for(const e of th) console.log(`  T${e.tier}  ${fmt(e.t).padEnd(16)} ${e.kind}`);
  } else {
    // KRONOS nie mierzy czasu sam — brak daty / "now" / "teraz" → ZMIERZONY zegar systemowy (krzemowa granica)
    let y,m,d,h,T,measured=false;
    if(a.length===0 || a[0]==='now' || a[0]==='teraz'){
      const Lt=new Date(Date.now()+tzOff(Date.now())*3600000);
      y=Lt.getUTCFullYear(); m=Lt.getUTCMonth()+1; d=Lt.getUTCDate(); h=Lt.getUTCHours();
      T=new Date(Date.now()); measured=true;
    } else {
      y=+a[0],m=+a[1],d=+a[2],h=+(a[3]??12); T=new Date(localMs(y,m,d,h));
    }
    const b=breath(T);
    if(measured) console.log(`\n⏱ ZMIERZONE TERAZ (zegar systemowy, nie z pamięci)`);
    console.log(`\n╔═ KRONOS · ODDECH — ${fmt(T)} ═╗`);
    if(!b.open){
      console.log(`\n  Brak otwartej przerwy — żywioł dnia czysty.`);
      if(b.untilNext) console.log(`  ⏳ następny próg: ${fmt(b.untilNext.t)}  ${b.untilNext.kind}  (T${b.untilNext.tier}, za ${Math.abs(b.untilNext.delta).toFixed(1)}h)`);
      if(b.sincePrev) console.log(`  ⌛ ostatni próg:  ${fmt(b.sincePrev.t)}  ${b.sincePrev.kind}  (T${b.sincePrev.tier}, ${b.sincePrev.delta.toFixed(1)}h temu)`);
    } else {
      console.log(`\n  🫁 PRZERWA OTWARTA · głębokość ${b.depth} (${b.tierName})`);
      console.log(`     strona oddechu: ${b.side}`);
      console.log(`     próg wiodący:   ${fmt(b.dominant.t)}  ${b.dominant.kind}  (Δ ${b.dominant.delta>0?'+':''}${b.dominant.delta.toFixed(1)}h)`);
      if(b.active.length>1) console.log(`     nakłada się:    ${b.active.filter(e=>e!==b.dominant).map(e=>`${e.kind} (T${e.tier})`).join(', ')}`);
      console.log(`\n  → ${b.guide}`);
      console.log(`     ↳ ${b.pyt}`);
    }
    console.log(`\n  (przerwa zaprasza — ciało rozstrzyga, kiedy wdech)`);
  }
}
