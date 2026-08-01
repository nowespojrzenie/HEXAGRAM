// ============================================================
// KRONOS · SCAN_DWARFS — planety karłowate / TNO przez MATRYCĘ
// Źródło pozycji: Swiss Ephemeris (@swisseph/node) + pliki .se1 w ./ephe
// Oś: długość TROPIKALNA ze swisseph − ayanamsa(kronos_v4) = długość SYDERYCZNA.
//     JEDNO źródło ayanamsy (formuła kronos_v4) — nie mieszać z Lahiri swisseph.
// Mapowanie żywiołu: matrycaC() — żywioł znaku TRANZYTOWEGO (ruchomy, nie rdzeń).
//
// STATUS KANONICZNY:
//   • pozycje = PRAWO (mierzone, falsyfikowalne astronomicznie)
//   • żywioł-przez-tranzyt = NOŚNA RAMA (działa, ale to jeden z trzech możliwych kluczy)
//   • "oktawa Jowisza", rdzeń archetypiczny = REZONANS (Strefa Nulifikacji, otwarte)
// ============================================================
const swe = require('@swisseph/node');
const mx  = require('./kronos_matryca.js');
const K   = require('./kronos_v4.js');  // jedno źródło ayanamsy (scalono 26.06 — koniec kopii)
const path = require('path');

swe.setEphemerisPath(path.join(__dirname, 'ephe'));
const OFF = swe.AsteroidOffset; // 10000

// --- ta SAMA ayanamsa co kronos_v4 — IMPORTOWANA, nie kopiowana (spójność osi) ---
const ayanV4 = K.ayan;
const norm = x => ((x%360)+360)%360;

// --- katalog ciał: numer + symbol + status klucza funkcji (REZONANS) ---
const DWARFS = {
  Makemake: {num:136472, sym:"🝼", rez:"[oktawa? Jowisza — REZONANS] płodność/odrodzenie z pustki; klucz funkcji NIEUSTALONY"},
  Eris:     {num:136199, sym:"🝿", rez:"[REZONANS] niezgoda-która-ujawnia; rozłam porządku — czy SMAKUJE jak rozdarcie?"},
  Haumea:   {num:136108, sym:"🝻", rez:"[REZONANS] rozdzielenie/wir; jedno staje się wieloma"},
  Sedna:    {num:90377,  sym:"⯲", rez:"[REZONANS] głębia/wygnanie; to-co-poza-zasięgiem, długi powrót"},
  Quaoar:   {num:50000,  sym:"⯫", rez:"[REZONANS] taniec stwórczy; porządek z chaosu"},
  Chiron:   {num:2060,   sym:"⚷", rez:"[PRÓG/klucz B] rana-która-uczy; most granica↔zaświat"},
};

// --- pozycja syderyczna jednego ciała na datę ---
function dwarfSid(name, date){
  const d = DWARFS[name];
  const jd = swe.julianDay(date.getUTCFullYear(), date.getUTCMonth()+1, date.getUTCDate(),
                           date.getUTCHours()+date.getUTCMinutes()/60+date.getUTCSeconds()/3600);
  const r = swe.calculatePosition(jd, OFF + d.num); // tropikalna geocentryczna
  const sid = norm(r.longitude - ayanV4(date));
  const mc = mx.matrycaC(sid);
  return {name, sym:d.sym, rez:d.rez,
          tropLon:r.longitude, sid, lat:r.latitude, dist:r.distance,
          znak:mc.znak, znakSym:mc.sym, el:mc.el, biegun:mc.biegun, em:mc.em, jung:mc.jung,
          thun:mc.thun, rozni:mc.rozni};
}

// --- pełny odczyt: wszystkie ciała na datę ---
function scanAll(date){
  return Object.keys(DWARFS).map(n => dwarfSid(n, date));
}

// --- SKAN PROGÓW: wykryj zmiany znaku (granice [ODDECH]) w oknie czasu ---
// Karły są wolne (Makemake ~306 lat/obieg), więc skanujemy w skali miesięcy/lat.
// step = krok w dniach; dni = długość okna.
function scanProgi(name, startDate, dni, step){
  step = step || 15;            // domyślnie co 15 dni
  const out = [];
  let prev = null;
  for(let off=0; off<=dni; off+=step){
    const d = new Date(startDate.getTime() + off*86400000);
    const r = dwarfSid(name, d);
    if(prev && r.znak !== prev.znak){
      // znaleziono zmianę między prev a r — zawęź bisekcją do ~1 dnia
      let lo = new Date(d.getTime() - step*86400000), hi = new Date(d.getTime());
      for(let i=0;i<20;i++){
        const mid = new Date((lo.getTime()+hi.getTime())/2);
        const rm = dwarfSid(name, mid);
        if(rm.znak === prev.znak) lo = mid; else hi = mid;
      }
      const rEdge = dwarfSid(name, hi);
      const prog = mx.progZero(prev.znak, rEdge.znak);
      out.push({
        kiedy: hi,
        zOd: prev.znak, zDo: rEdge.znak,
        elOd: prev.el, elDo: rEdge.el,
        typ: prog.typ,                 // 'eter' | 'uspójnienie'
        opis: prog.opis, pyt: prog.pyt,
        retro: r.tropLon < prev.tropLon // przybliżona detekcja ruchu wstecznego
      });
    }
    prev = r;
  }
  return out;
}

module.exports = {dwarfSid, scanAll, scanProgi, DWARFS, ayanV4};

// --- CLI ---
if(require.main===module){
  const args = process.argv.slice(2);

  // TRYB SKANU PROGÓW: node scan_dwarfs.js scan [Ciało] [lata]
  if(args[0]==='scan'){
    const name = args[1] && DWARFS[args[1]] ? args[1] : null;
    const lata = Number(args[2]) || 10;
    const start = new Date();
    const dni = Math.round(lata*365.25);
    const cele = name ? [name] : Object.keys(DWARFS);
    console.log(`\n╔═══ KRONOS · DWARFS · SKAN PROGÓW · ${lata} lat od dziś ═══╗`);
    console.log(`(granice [ODDECH] = zmiany znaku · ETER = zmiana żywiołu · USPÓJNIENIE = ten sam żywioł)\n`);
    for(const c of cele){
      const progi = scanProgi(c, start, dni, 20);
      const sym = DWARFS[c].sym;
      if(progi.length===0){
        const r0 = dwarfSid(c, start);
        console.log(`${sym} ${c}: brak progów w oknie — stoi w ${r0.em} ${r0.znak} (${r0.el}) całe ${lata} lat`);
      } else {
        console.log(`${sym} ${c}:`);
        for(const p of progi){
          const tag = p.typ==='uspójnienie' ? '⊙ USPÓJNIENIE' : '🌌 ETER';
          const rr = p.retro ? ' (ruch wsteczny)' : '';
          console.log(`   ${p.kiedy.toISOString().slice(0,10)}  ${tag}  ${p.zOd}(${p.elOd}) → ${p.zDo}(${p.elDo})${rr}`);
        }
      }
      console.log('');
    }
    console.log(`STATUS: progi=PRAWO (mierzone) · żywioł-przez-tranzyt=NOŚNA RAMA`);
    process.exit(0);
  }

  let date, label;
  if(args[0]==='now' || args.length===0){
    date = new Date(); label = '⏱ ZMIERZONE TERAZ';
  } else {
    const [y,m,d,h] = args.map(Number);
    // wejście jako lokalny CEST/CET — uproszczenie: traktuj h jako UTC+2 latem
    date = new Date(Date.UTC(y, m-1, d, (h||12)-2));
    label = `${d}.${String(m).padStart(2,'0')}.${y} ${String(h||12).padStart(2,'0')}:00 CEST`;
  }
  const off = (date.getUTCMonth()>=2 && date.getUTCMonth()<=9) ? 'CEST':'CET';
  console.log(`\n╔═══ KRONOS · DWARFS · ${label} ═══╗`);
  console.log(`(pozycje syderyczne Lahiri/kronos_v4 · żywioł = znak TRANZYTOWY · ayan=${ayanV4(date).toFixed(3)}°)\n`);
  const rows = scanAll(date);
  for(const r of rows){
    console.log(`${r.sym}  ${r.name.padEnd(9)} ${r.sid.toFixed(2).padStart(7)}°syd  →  ${r.em} ${r.znakSym}${r.znak.padEnd(11)} · ${r.el} (${r.biegun})`);
    console.log(`   trop ${r.tropLon.toFixed(2)}° · lat ${r.lat.toFixed(1)}° · ${r.dist.toFixed(1)} AU`);
    console.log(`   ${r.rez}`);
    console.log('');
  }
  console.log(`STATUS: pozycje=PRAWO · żywioł-przez-tranzyt=NOŚNA RAMA · rdzeń/oktawa=REZONANS (Strefa Nulifikacji)`);
}
