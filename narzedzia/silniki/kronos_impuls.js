#!/usr/bin/env node
// KRONOS · IMPULS ASPEKTOWY v1.0 (26.07.2026, polecenie twórcy)
// ─────────────────────────────────────────────────────────────
// GENEZA (INCYDENT LIŚCIA, 27.07.2026): plan okien zlepił ND26–WT28 jako Owoc,
// a kalendarium Thun drukowało na PN 27.07 okno LIŚCIA 4–13. Księżyc stał cały
// dzień w ♐ (Ogień) — odchyłka NIE była konstelacyjna. Pomiar: ⊙☍♇ dokładna
// 27.07 08:54 CEST, Słońce w ♋ Raku (WODA) → impuls wodny przebija dzień ognia.
// Okno druku 4–13 klamruje moment dokładny (~±4–5h). Walidacja wsteczna:
// ♃☍♇ dokładna 20.07 16:45 (♃ w Raku) = symbol ♃☍P w druku 20.07. ✓
// TĘ WARSTWĘ silnik dotąd pomijał. Ten moduł ją liczy.
//
// CO LICZY (OBLICZONE): dokładne czasy aspektów par planetarnych (bez Księżyca,
// jego aspekty nosi warstwa dzienna) — ☌0° ☍180° △120°, orb wejścia 1°,
// bisekcja do minuty — plus konstelacje i żywioły obu ciał w chwili dokładnej.
// CO NAZYWA (SOCZEWKA, oznaczone): żywioł transmitowany = żywioł(y) konstelacji
// ciał aspektu; okno robocze ±4h wokół momentu dokładnego (konwencja z druku
// Thun, nie prawo natury); przy udziale WODY — tendencja opadowa/burzowa
// (▲ Gewitterneigung u Thun; hipoteza korelacyjna, do falsyfikacji pogodą).
// Jedno źródło ayanamsy: kronos_v4 (sidLon, getC). Zegara nie zakłada — dostaje datę.
//
// UŻYCIE:  node kronos_impuls.js YYYY M D [dni=7]
// ─────────────────────────────────────────────────────────────
'use strict';
const k = require('./kronos_v4.js');
let A=null; try{ A=require('astronomy-engine'); }catch(e){ /* czarne okna wyłączone bez biblioteki */ }

const CIALA = ['Sun','Mercury','Venus','Mars','Jupiter','Saturn','Uranus','Neptune','Pluto'];
const SYM = {Sun:'⊙',Mercury:'☿',Venus:'♀',Mars:'♂',Jupiter:'♃',Saturn:'♄',Uranus:'♅',Neptune:'♆',Pluto:'♇'};
// PRAWO WALIDACJI (27.07, dane ze zdjęć kalendarza): koniunkcje NIE drukują się jako impuls (0/2),
// opozycje i trygony — 7/7. Koniunkcje liczymy, ale oznaczamy jako NIEDRUKOWANE.
const ASPEKTY = [ {kat:0,sym:'☌',nazwa:'koniunkcja',drukuje:false}, {kat:120,sym:'△',nazwa:'trygon',drukuje:true}, {kat:180,sym:'☍',nazwa:'opozycja',drukuje:true} ];
const ORB = 1.0;           // stopnie — próg wejścia w poszukiwanie dokładności
const OKNO_H = 4;          // ± godziny okna roboczego (konwencja druku Thun)

function katDelta(a,b,target){ let d=(a-b-target)%360; if(d<-180)d+=360; if(d>180)d-=360; return d; }

function bisekcja(bA,bB,target,t0,t1){
  const f = t => { const d=new Date(t); return katDelta(k.sidLon(bA,d), k.sidLon(bB,d), target); };
  let a=t0, b=t1, fa=f(a);
  for(let i=0;i<48;i++){ const m=(a+b)/2, fm=f(m); if((fa<0)!==(fm<0)) b=m; else { a=m; fa=fm; } }
  return new Date((a+b)/2);
}

function skanuj(start, dni){
  const wyniki=[]; const krokH=6, msH=3600e3;
  const t0=start.getTime(), t1=t0+dni*24*msH;
  for(let i=0;i<CIALA.length;i++) for(let j=i+1;j<CIALA.length;j++){
    const A=CIALA[i], B=CIALA[j];
    for(const asp of ASPEKTY){
      // trygon jest dwustronny (±120): sprawdzamy oba cele
      const cele = asp.kat===120 ? [120,-120] : [asp.kat];
      for(const cel of cele){
        let prev=null;
        for(let t=t0;t<=t1;t+=krokH*msH){
          const d=katDelta(k.sidLon(A,new Date(t)), k.sidLon(B,new Date(t)), cel);
          if(prev!==null && (prev<0)!==(d<0) && Math.abs(prev)<8 && Math.abs(d)<8){
            const ex=bisekcja(A,B,cel,t-krokH*msH,t);
            const cA=k.getC(k.sidLon(A,ex)), cB=k.getC(k.sidLon(B,ex));
            wyniki.push({t:ex,A,B,asp,cA,cB});
          }
          prev=d;
        }
      }
    }
  }
  // deduplikacja (ten sam aspekt złapany z dwóch celów trygonu w tym samym oknie)
  wyniki.sort((x,y)=>x.t-y.t);
  return wyniki.filter((w,idx)=> idx===0 || Math.abs(w.t - wyniki[idx-1].t) > 3600e3
    || w.A!==wyniki[idx-1].A || w.B!==wyniki[idx-1].B );
}

// CZARNE OKNA (PRAWO 27.07): perygeum/apogeum/węzły nadpisują bazę I impuls — druk daje kreski.
// Wykrywanie: ekstrema odległości Księżyca (Pg/Ag) i przejścia przez węzeł (szer. ekliptyczna ~0).
function czarneOkna(start, dni){
  if(!A) return [];
  const out=[], msH=3600e3, t0=start.getTime(), t1=t0+dni*24*msH;
  let prevD=null, prevDlt=null, prevB=null;
  for(let t=t0-24*msH; t<=t1+24*msH; t+=msH){
    const d=new Date(t);
    let dist=null, lat=null;
    try{ const m=A.EclipticGeoMoon(d); lat=m.lat; dist=m.dist; }catch(e){}
    if(dist!==null&&prevD!==null&&prevDlt!==null){
      const dlt=dist-prevD;
      if(prevDlt<0&&dlt>0) out.push({t:new Date(t-msH),typ:'Pg perygeum'});
      if(prevDlt>0&&dlt<0) out.push({t:new Date(t-msH),typ:'Ag apogeum'});
      prevDlt=dlt;
    } else if(dist!==null&&prevD!==null) prevDlt=dist-prevD;
    if(lat!==null&&prevB!==null&&(prevB<0)!==(lat<0)) out.push({t:new Date(t-msH),typ:(lat>0?'☊ węzeł wstępujący':'☋ węzeł zstępujący')});
    if(dist!==null) prevD=dist;
    if(lat!==null) prevB=lat;
  }
  return out.filter(o=>o.t>=start&&o.t<=new Date(t1));
}

function fmt(d){ return d.toLocaleString('pl-PL',{timeZone:'Europe/Warsaw',weekday:'short',day:'2-digit',month:'2-digit',hour:'2-digit',minute:'2-digit'}); }
function fmtH(d){ return d.toLocaleString('pl-PL',{timeZone:'Europe/Warsaw',hour:'2-digit',minute:'2-digit'}); }

function raport(start, dni){
  const w = skanuj(start, dni);
  console.log(`\n╔═══ KRONOS · IMPULS ASPEKTOWY · ${dni} dni od ${start.toLocaleDateString('pl-PL',{timeZone:'Europe/Warsaw'})} ═══╗`);
  if(!w.length){ console.log('  (czysto — brak dokładnych aspektów par planetarnych w oknie)'); return; }
  const czarne = czarneOkna(start, dni);
  if(czarne.length){
    console.log('\n【 CZARNE OKNA — nadpisują bazę I impuls (druk: kreski) 】');
    for(const c of czarne) console.log(`  ${fmt(c.t)}  ${c.typ}  → tego dnia rubryka MILCZY`);
  }
  console.log('\n【 OBLICZONE — momenty dokładne 】');
  for(const x of w){
    const zywioly=[...new Set([x.cA.el,x.cB.el])].join('+');
    const flaga = x.asp.drukuje ? '' : '   ⟨NIEDRUKOWANE — koniunkcje nie dają okna (0/2 w walidacji)⟩';
    console.log(`  ${fmt(x.t)}  ${SYM[x.A]} ${x.asp.sym} ${SYM[x.B]}  (${x.asp.nazwa})  ·  ${SYM[x.A]} w ${x.cA.pl}/${x.cA.el} · ${SYM[x.B]} w ${x.cB.pl}/${x.cB.el}${flaga}`);
  }
  console.log('\n【 SOCZEWKA — impuls żywiołowy (oznaczone; konwencja okna ±'+OKNO_H+'h z druku Thun) 】');
  for(const x of w){
    if(!x.asp.drukuje) continue;   // koniunkcje pomijamy w soczewce (prawo walidacji)
    const els=[...new Set([x.cA.el,x.cB.el])];
    const od=new Date(x.t.getTime()-OKNO_H*3600e3), doo=new Date(x.t.getTime()+OKNO_H*3600e3);
    const woda = els.includes('Woda') ? '  ▲ tendencja opadowa/burzowa (hipoteza Thun — falsyfikuj pogodą)' : '';
    console.log(`  ~${fmtH(od)}–${fmtH(doo)} (${x.t.toLocaleDateString('pl-PL',{timeZone:'Europe/Warsaw'})})  impuls: ${els.join(' + ')}${woda}`);
    console.log(`     → może PRZEBIĆ żywioł dnia z konstelacji Księżyca (INCYDENT LIŚCIA 27.07.2026)`);
  }
  console.log('\n  Prawo warstwy: żywioł dnia = Księżyc (baza) ⊕ impuls aspektowy (nakładka).');
  console.log('  Rubryka godzinowa rozstrzyga w oknie impulsu; poza nim — baza. Deszcz unieważnia obie.');
}

if(require.main===module){
  const a=process.argv.slice(2).map(Number);
  const [Y,M,D,dni=7] = a.length>=3 ? a : (()=>{ const n=new Date(); return [n.getUTCFullYear(),n.getUTCMonth()+1,n.getUTCDate(),7]; })();
  raport(new Date(Date.UTC(Y,M-1,D,0,0)), dni);
}
module.exports = { skanuj, OKNO_H };
