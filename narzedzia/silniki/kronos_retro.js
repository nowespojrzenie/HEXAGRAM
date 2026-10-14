#!/usr/bin/env node
/* ── KRONOS · RUCHY WSTECZNE I STACJE (29.09.2026) ─────────────────────────────
 * Słowo twórcy 29.09 10:30 (K2, `kanon/plany/linienie/DECYZJE_K1_K4_2909.md`):
 *   „retrogradacje powinny wpisać się w kanon gwiezdny — ruch wsteczny i przodujący,
 *    a tym bardziej punkty zaciszenia, to mocne formy nieba i trzeba brać je pod uwagę.”
 * Domyka wątek WATKI_OTWARTE „KANON · ruchy wsteczne wszystkich ciał” (28.09: 0 trafień w silnikach).
 *
 * CZYM JEST: suchy silnik. Liczy STACJE (punkty zaciszenia) ☿♀♂♃♄⛢♆♇ — chwilę, w której
 * ciało staje i zawraca — oraz OKRESY wsteczne z CIENIEM (wejście w cień → stacja R →
 * stacja D → wyjście z cienia). Zero interpretacji. Znaczenie żyje w soczewkach (REZONANS).
 *
 * UKŁAD (świadomy wybór, nie przypadek):
 *  · MOMENT stacji liczony na długości GEOCENTRYCZNEJ TROPIKALNEJ (definicja astronomiczna:
 *    prędkość = 0). Ayanamsa rośnie ~0,00004°/dobę — przy ciałach wolnych (♇ ~0°/dobę przy
 *    stacji) liczenie na syderycznej przesunęłoby moment o godziny; tropik go nie przesuwa.
 *  · POZYCJA i KONSTELACJA raportowane SYDERYCZNIE, przez `kronos_v4` (jedno źródło ayanamsy
 *    i granic Thun — import, nie kopia).
 *
 * CZEGO PILNUJE (prawa wpisane w kod — każde ma własny tor w --test):
 *  P0 · daty zgodne z efemerydą publikowaną (tolerancja 1 doba) — i test UMIE nie przejść
 *  P1 · DWA INTERPRETERY: moment stacji z astronomy-engine = moment ze Swiss Ephemeris (≤ 60 min)
 *  P2 · stacje każdego ciała NAPRZEMIENNE (R, D, R, D…) — dwie R z rzędu = błąd skanu
 *  P3 · cień spójny: wejście < R < D < wyjście, a długość na brzegu cienia = długość stacji
 *  P4 · okres przecięty horyzontem skanu jest OZNACZANY `>`/`<`, nie dopowiadany
 *
 * UŻYCIE:
 *   node narzedzia/silniki/kronos_retro.js <RRRR> <M> <D> [dni=120]   okresy i stacje od daty
 *   node narzedzia/silniki/kronos_retro.js --teraz [dni=120]            od chwili zmierzonej
 *   node narzedzia/silniki/kronos_retro.js --test                        tory P0–P4
 *   require('./kronos_retro.js').stacje(od, do)  → [{cialo, typ:'R'|'D', t, sid, konst}]
 * ─────────────────────────────────────────────────────────────────────────── */
const A  = require('astronomy-engine');
const K  = require('./kronos_v4.js');
const TZ = require('./tz_pl.js');

const CIALA = ["Mercury","Venus","Mars","Jupiter","Saturn","Uranus","Neptune","Pluto"];
const SYM = {Mercury:"☿",Venus:"♀",Mars:"♂",Jupiter:"♃",Saturn:"♄",Uranus:"⛢",Neptune:"♆",Pluto:"♇"};
const PL  = {Mercury:"Merkury",Venus:"Wenus",Mars:"Mars",Jupiter:"Jowisz",Saturn:"Saturn",
             Uranus:"Uran",Neptune:"Neptun",Pluto:"Pluton"};
const DOBA = 86400000, MIN = 60000;
const ZAPAS = 400*DOBA;                      // skan wewnętrzny poza oknem — by sparować stacje i cień
const norm = x => ((x%360)+360)%360;
const roz  = (a,b) => { let d = norm(a-b); return d>180 ? d-360 : d; };   // a−b w (−180,180]

function lonTrop(cialo, ms){ return A.Ecliptic(A.GeoVector(A.Body[cialo], new Date(ms), true)).elon; }
function predkosc(cialo, ms){ const h=6*3600000; return roz(lonTrop(cialo,ms+h), lonTrop(cialo,ms-h))/0.5; } // °/dobę

// bisekcja do 1 minuty na zmianie znaku f
function bisekcja(f, lo, hi){ return require('./szukaj.js').zero(f, lo, hi, {tol: MIN}); }   // jedno źródło szukania (03.10.2026, MOSTY #49)

/* STACJE w [od, do] (ms UTC). Krok 1 doba — najkrótsza przerwa między stacjami (☿) to ~3 tyg. */
function stacjeSurowe(cialo, od, do_){
  const out=[]; let t=od, v=predkosc(cialo,t);
  for (let n=t+DOBA; n<=do_; n+=DOBA){
    const vn = predkosc(cialo,n);
    if ((v<0)!==(vn<0)){
      const ts = bisekcja(ms=>predkosc(cialo,ms), n-DOBA, n);
      out.push({cialo, typ: v>0 ? 'R' : 'D', t: ts, trop: lonTrop(cialo,ts)});
    }
    v = vn;
  }
  return out;
}

function opis(s){
  const sid = K.sidLon(s.cialo, new Date(s.t)), c = K.getC(sid);
  return {...s, sid, konst: c.pl, konstSym: c.sym, typThun: c.typ};
}

/* chwila, gdy długość tropikalna ciała mija `cel`, szukana od `start` w kierunku `kier` (±1), do `limit` dób */
function przejscie(cialo, cel, start, kier, limit){
  const f = ms => roz(lonTrop(cialo,ms), cel);
  let t=start, ft=f(t);
  for (let i=1;i<=limit;i++){
    const n = start + kier*i*DOBA, fn=f(n);
    if (Math.abs(fn)<90 && (fn<0)!==(ft<0)) return kier>0 ? bisekcja(f,t,n) : bisekcja(f,n,t);
    t=n; ft=fn;
  }
  return null;                                  // P4: nie znaleziono w zasięgu → oznaczamy, nie zgadujemy
}

/* OKRESY wsteczne przecinające [od, do]: {cialo, cien_w, R, D, cien_j} (każde pole może być null = poza) */
function okresy(od, do_, ciala=CIALA){
  const wynik=[];
  for (const c of ciala){
    const st = stacjeSurowe(c, od-ZAPAS, do_+ZAPAS).map(opis);
    for (let i=0;i<st.length;i++){
      if (st[i].typ!=='R') continue;
      const R=st[i], D = (st[i+1] && st[i+1].typ==='D') ? st[i+1] : null;
      const koniec = D ? D.t : R.t;
      if (koniec < od || R.t > do_) continue;    // okres poza oknem raportu
      const limit = c==='Mercury'?60 : c==='Venus'?90 : c==='Mars'?120 : 250;
      const cw = D ? przejscie(c, D.trop, R.t, -1, limit) : null;
      const cj = D ? przejscie(c, R.trop, D.t, +1, limit) : null;
      wynik.push({cialo:c, R, D, cien_w:cw, cien_j:cj});
    }
  }
  return wynik.sort((a,b)=>a.R.t-b.R.t);
}

/* płaska lista stacji w oknie — dla kalendarium */
function stacje(od, do_, ciala=CIALA){
  const t0 = od instanceof Date ? od.getTime() : od, t1 = do_ instanceof Date ? do_.getTime() : do_;
  return ciala.flatMap(c => stacjeSurowe(c,t0,t1).map(opis)).sort((a,b)=>a.t-b.t);
}

/* ── DRUGI INTERPRETER (P1): Swiss Ephemeris, Moshier — prędkość analityczna ── */
let SWE=null;
function predkoscSwe(cialo, ms){
  if (!SWE) SWE = require('@swisseph/node');
  const jd = SWE.dateToJulianDay(new Date(ms));
  const F = SWE.CalculationFlag.Speed | SWE.CalculationFlag.MoshierEphemeris;
  return SWE.calculatePosition(jd, SWE.Planet[cialo], F).longitudeSpeed;
}
function stacjaSwe(cialo, okolo){
  const lo=okolo-2*DOBA, hi=okolo+2*DOBA;
  if ((predkoscSwe(cialo,lo)<0)===(predkoscSwe(cialo,hi)<0)) return null;
  return bisekcja(ms=>predkoscSwe(cialo,ms), lo, hi);
}

const rokL = ms => new Date(ms + TZ.offAt(ms)*3600000).getUTCFullYear();
const fmt = ms => ms==null ? '  (poza zasięgiem)' : TZ.fmt(ms).replace(/^(\d{2}\.\d{2})/, `$1.${rokL(ms)}`);  // rok jawnie: okresy ♄♆♇ przechodzą przez rok

function raport(od, dni){
  const do_ = od + dni*DOBA;
  console.log(`\n╔═ KRONOS · RUCHY WSTECZNE I STACJE ═╗`);
  console.log(`   od ${TZ.fmt(od)} przez ${dni} dni · moment: długość tropikalna (v=0) · pozycja: syderyczna Thun`);
  console.log(`   (stacja = FAKT astronomiczny · znaczenie = REZONANS, poza tym plikiem)\n`);
  const ok = okresy(od, do_);
  if (!ok.length) console.log("  Brak okresów wstecznych w tym oknie.");
  for (const o of ok){
    const s=SYM[o.cialo];
    console.log(`  ${s} ${PL[o.cialo]}`);
    console.log(`     cień wejście  ${fmt(o.cien_w)}`);
    console.log(`     ⏸ stacja R    ${fmt(o.R.t)}   @${o.R.sid.toFixed(1)}° ${o.R.konstSym} ${o.R.konst} (${o.R.typThun})`);
    console.log(`     ⏸ stacja D    ${o.D?fmt(o.D.t):'>  poza zasięgiem skanu'}${o.D?`   @${o.D.sid.toFixed(1)}° ${o.D.konstSym} ${o.D.konst} (${o.D.typThun})`:''}`);
    console.log(`     cień wyjście  ${fmt(o.cien_j)}`);
    const w = o.R.t<=od && (!o.D || o.D.t>=od) ? '  ◀ TERAZ WSTECZNY' : '';
    console.log(`     wsteczny: ${o.D?((o.D.t-o.R.t)/DOBA).toFixed(0)+' dni':'?'}${w}\n`);
  }
  const st = stacje(od, do_);
  console.log(`  ── punkty zaciszenia w oknie (${st.length}) ──`);
  for (const x of st) console.log(`   ${fmt(x.t)}  ${SYM[x.cialo]} ${x.typ==='R'?'staje → wstecz ℞':'staje → prosto D'}  @${x.sid.toFixed(1)}° ${x.konstSym}`);
  console.log('');
}

module.exports = {stacje, okresy, predkosc, CIALA, SYM, PL};

/* ── AUTOTEST — prawo #38: każde prawo z nagłówka ma własny tor; test musi UMIEĆ nie przejść ── */
if (require.main === module && process.argv.includes('--test')){
  let ok = true;
  const U = (y,m,d) => Date.UTC(y,m-1,d,12);
  const zgodne = (znal, ocz, tol) => znal.some(s => s.typ===ocz.typ && Math.abs(s.t-ocz.t) <= tol*DOBA);

  console.log("── TOR P0: daty z efemerydy publikowanej 2026 (±1 doba) · i test UMIE nie przejść ──");
  // Źródło odniesienia: powszechnie publikowane daty stacji 2026 (UTC, dzień).
  const WZOR = [
    ["Mercury",'R',U(2026,2,26)], ["Mercury",'D',U(2026,3,20)],
    ["Mercury",'R',U(2026,6,29)], ["Mercury",'D',U(2026,7,23)],
    ["Mercury",'R',U(2026,10,24)],["Mercury",'D',U(2026,11,13)],
    ["Venus",'R',U(2026,10,3)],   ["Venus",'D',U(2026,11,14)],
  ];
  const rok = stacje(U(2026,1,1), U(2026,12,31), ["Mercury","Venus"]);
  let p0 = true;
  for (const [c,typ,t] of WZOR){
    const z = zgodne(rok.filter(s=>s.cialo===c), {typ,t}, 1);
    console.log(`  ${z?'✓':'✗'} ${SYM[c]} ${typ} ${new Date(t).toISOString().slice(0,10)}`);
    p0 = p0 && z;
  }
  const falsz = zgodne(rok.filter(s=>s.cialo==="Venus"), {typ:'R', t:U(2026,10,8)}, 1);   // przesunięte o 5 dób
  console.log(`  ${!falsz?'✓':'✗'} data przesunięta o 5 dób NIE przechodzi (test ma zęby)`);
  const zlyTyp = zgodne(rok.filter(s=>s.cialo==="Venus"), {typ:'D', t:U(2026,10,3)}, 1);
  console.log(`  ${!zlyTyp?'✓':'✗'} właściwa data ze ZŁYM typem (D zamiast R) NIE przechodzi`);
  ok = ok && p0 && !falsz && !zlyTyp;

  console.log("\n── TOR P1: DWA INTERPRETERY — astronomy-engine vs Swiss Ephemeris (≤ 60 min) ──");
  const wszystkie = stacje(U(2026,1,1), U(2027,6,30));
  let p1 = wszystkie.length > 0, maks = 0;
  for (const s of wszystkie){
    const t2 = stacjaSwe(s.cialo, s.t);
    const d = t2==null ? Infinity : Math.abs(t2-s.t)/MIN;
    maks = Math.max(maks, d);
    if (!(d <= 60)){ p1=false; console.log(`  ✗ ${SYM[s.cialo]} ${s.typ} ${fmt(s.t)} · swe: ${t2==null?'brak stacji':fmt(t2)} · Δ ${d.toFixed(0)} min`); }
  }
  console.log(`  ${p1?'✓':'✗'} ${wszystkie.length} stacji 01.2026–06.2027, największa rozbieżność ${maks.toFixed(1)} min`);
  ok = ok && p1;

  console.log("\n── TOR P2: stacje każdego ciała NAPRZEMIENNE (R, D, R, D…) ──");
  let p2 = true;
  for (const c of CIALA){
    const s = stacjeSurowe(c, U(2020,1,1), U(2030,1,1));
    const naprzem = s.every((x,i)=> i===0 || x.typ!==s[i-1].typ);
    if (!naprzem || s.length<2){ p2=false; console.log(`  ✗ ${SYM[c]} ${s.map(x=>x.typ).join('')}`); }
  }
  console.log(`  ${p2?'✓':'✗'} 8 ciał × 10 lat — każda stacja R ma swoje D i odwrotnie`);
  ok = ok && p2;

  console.log("\n── TOR P3: cień spójny (wejście < R < D < wyjście; długość brzegu = długość stacji) ──");
  const ok3 = okresy(U(2026,1,1), U(2027,6,30));
  let p3 = ok3.length > 0;
  for (const o of ok3){
    if (!o.D || o.cien_w==null || o.cien_j==null){ p3=false; console.log(`  ✗ ${SYM[o.cialo]} okres niepełny`); continue; }
    const kol = o.cien_w < o.R.t && o.R.t < o.D.t && o.D.t < o.cien_j;
    const bw = Math.abs(roz(lonTrop(o.cialo,o.cien_w), o.D.trop)), bj = Math.abs(roz(lonTrop(o.cialo,o.cien_j), o.R.trop));
    if (!(kol && bw<0.01 && bj<0.01)){ p3=false; console.log(`  ✗ ${SYM[o.cialo]} kolejność=${kol} brzeg_w=${bw.toFixed(4)}° brzeg_j=${bj.toFixed(4)}°`); }
  }
  console.log(`  ${p3?'✓':'✗'} ${ok3.length} okresów 01.2026–06.2027 — kolejność i brzegi cienia zgodne`);
  ok = ok && p3;

  console.log("\n── TOR P4: horyzont — cień poza zasięgiem jest OZNACZANY (null), nie dopowiadany ──");
  const v = ok3.find(o=>o.cialo==="Venus");
  const krotko = v ? przejscie("Venus", v.D.trop, v.R.t, -1, 3) : undefined;   // 3 doby wstecz — za mało
  const p4 = v && krotko === null && v.cien_w != null;
  console.log(`  ${p4?'✓':'✗'} ♀ cień przy zasięgu 3 dób → ${krotko===null?'oznaczony jako poza':'ZMYŚLONY'}; przy pełnym zasięgu → ${v&&v.cien_w?fmt(v.cien_w):'brak'}`);
  ok = ok && p4;

  console.log(ok ? "\n  ✓ STRAŻ ŻYWA: każde deklarowane prawo (P0–P4) ma własny tor i przechodzi."
                 : "\n  ✗ STRAŻ MARTWA: któreś prawo nie przechodzi.");
  process.exit(ok?0:1);
}

if (require.main === module && !process.argv.includes('--test')){
  const a = process.argv.slice(2).filter(x=>!x.startsWith('--'));
  if (process.argv.includes('--teraz')) raport(Date.now(), +(a[0]||120));
  else if (a.length>=3) raport(TZ.localToUTC(+a[0],+a[1],+a[2],0), +(a[3]||120));
  else { console.log("użycie: node kronos_retro.js <RRRR> <M> <D> [dni] | --teraz [dni] | --test"); process.exit(2); }
}
