#!/usr/bin/env node
// ═══ KRONOS · scan_aspekty — aspekty planeta↔planeta (geocentrycznie) ═══
// PRAWO: aspekt = różnica długości ekliptycznych — wynik identyczny
//        w układzie syderycznym i tropikalnym (ayanamsa się skraca).
// PODZIAŁ RÓL: Księżyc ↔ wolne planety obsługuje scan_outer.js.
//              Ten skaner liczy WYŁĄCZNIE planeta↔planeta (Słońce–Pluton).
// FAKT = kąt i czas ścisłości. KONWENCJA = orb, nazwy aspektów, rezonans.
//
// Użycie:
//   node scan_aspekty.js [RRRR M D] [dni] [orb]
//   node scan_aspekty.js now                    → 14 dni od teraz, orb 1.5°
//   node scan_aspekty.js 2026 7 7 30 1.0        → 30 dni od 7.07, orb 1.0°
//   node scan_aspekty.js stacje [RRRR M D dni]  → tylko stacje (retro/direct)
//   node scan_aspekty.js teraz-kąty             → surowa macierz separacji TERAZ

const A = require('astronomy-engine');
const TZ = require('./tz_pl.js');   // jedno źródło czasu lokalnego

const CIALA = ['Sun','Mercury','Venus','Mars','Jupiter','Saturn','Uranus','Neptune','Pluto'];
const PL = { Sun:'☉ Słońce', Mercury:'☿ Merkury', Venus:'♀ Wenus', Mars:'♂ Mars',
  Jupiter:'♃ Jowisz', Saturn:'♄ Saturn', Uranus:'♅ Uran', Neptune:'♆ Neptun', Pluto:'♇ Pluton' };
const ASPEKTY = [
  { kat: 0,   sym: '☌', nazwa: 'koniunkcja' },
  { kat: 60,  sym: '⚹', nazwa: 'sekstyl' },
  { kat: 90,  sym: '□', nazwa: 'kwadratura' },
  { kat: 120, sym: '△', nazwa: 'trygon' },
  { kat: 180, sym: '☍', nazwa: 'opozycja' },
];
const KROK_H = 2;            // krok skanu [h]
const KAZIMI_ORB = 0.283;    // 17' — KONWENCJA klasyczna

function lon(body, date) {
  return A.Ecliptic(A.GeoVector(A.Body[body], date, true)).elon;
}
function sep(a, b) { // najkrótsza separacja kątowa 0–180
  let d = Math.abs(a - b) % 360;
  return d > 180 ? 360 - d : d;
}
function fmt(d) {
  return d.toLocaleString('pl-PL', { timeZone: TZ.STREFA,
    weekday: 'short', day: '2-digit', month: '2-digit',
    hour: '2-digit', minute: '2-digit' }) + ' ' + TZ.ETYKIETA;
}
// minimum |f| przez trójpodział — jedno źródło = szukaj.js (03.10.2026, MOSTY #49).
// Nazwa zmieniona z `bisekcja`: to nigdy nie było połowienie i nazwa myliła czytającego.
function minimumAbs(f, t0, t1, iter = 40) {
  return new Date(require('./szukaj.js').ekstremum(ms => Math.abs(f(new Date(ms))), t0.getTime(), t1.getTime(), { iter }));
}

function skanAspekty(start, dni, orb) {
  const wyniki = [];
  const pary = [];
  for (let i = 0; i < CIALA.length; i++)
    for (let j = i + 1; j < CIALA.length; j++) pary.push([CIALA[i], CIALA[j]]);

  for (const [b1, b2] of pary) {
    for (const asp of ASPEKTY) {
      const f = d => {
        const s = sep(lon(b1, d), lon(b2, d)) - asp.kat;
        return s;
      };
      // |f| — przy 0° i 180° odchyłka odbija się od granicy bez zmiany znaku,
      // więc szukamy MINIMÓW LOKALNYCH |f|, nie przejść przez zero
      const g = d => Math.abs(f(d));
      let p2 = g(start), p2T = new Date(start);
      let p1 = g(new Date(start.getTime() + KROK_H * 3600e3));
      let p1T = new Date(start.getTime() + KROK_H * 3600e3);
      const kroki = Math.ceil(dni * 24 / KROK_H);
      for (let k = 2; k <= kroki; k++) {
        const t = new Date(start.getTime() + k * KROK_H * 3600e3);
        const cur = g(t);
        // minimum lokalne: p2 > p1 <= cur, w pobliżu kąta aspektu
        if (p1 <= p2 && p1 <= cur && p1 < 5) {
          const szczyt = minimumAbs(g, p2T, t);
          const odch = g(szczyt);
          if (odch <= orb) {
            const rec = { b1, b2, asp, szczyt, odch };
            // kazimi: koniunkcja dolna/górna Słońce–Merkury w orbie 17'
            if (asp.kat === 0 && ((b1 === 'Sun' && b2 === 'Mercury') || (b1 === 'Mercury' && b2 === 'Sun')))
              rec.kazimi = odch <= KAZIMI_ORB;
            wyniki.push(rec);
          }
        }
        p2 = p1; p2T = p1T; p1 = cur; p1T = t;
      }
    }
  }
  wyniki.sort((x, y) => x.szczyt - y.szczyt);
  return wyniki;
}

// STACJE: jedno źródło prawdy = kronos_retro.stacje() (scalenie 03.10.2026, słowo twórcy „Scal”;
// MOSTY #45: dwa świadki → jeden). Własna pętla (znak prędkości co 12 h + bisekcja) usunięta —
// kronos_retro ma tory P0–P4 w tym drugi interpreter (Swiss Ephemeris). Format wyjścia bez zmian.
function skanStacje(start, dni) {
  const R = require('./kronos_retro.js');
  return R.stacje(start.getTime(), start.getTime() + dni * 86400e3)
    .map(s => ({ b: s.cialo, szczyt: new Date(s.t), kierunek: s.typ === 'R' ? 'RETRO ℞' : 'DIRECT →' }));
}

// ── CLI ──
const args = process.argv.slice(2);
let start = new Date(), dni = 14, orb = 1.5, tryb = 'aspekty';

if (args[0] === 'stacje') { tryb = 'stacje'; args.shift(); }
if (args[0] === 'teraz-katy' || args[0] === 'teraz-kąty') { tryb = 'macierz'; args.shift(); }
if (args[0] && args[0] !== 'now') {
  start = new Date(Date.UTC(+args[0], +args[1] - 1, +args[2] || 1, 0, 0));
  if (args[3]) dni = +args[3];
  if (args[4]) orb = +args[4];
} else if (args[0] === 'now') {
  if (args[1]) dni = +args[1];
  if (args[2]) orb = +args[2];
}

console.log(`\n╔═ KRONOS · ASPEKTY PLANETA↔PLANETA ═╗`);
console.log(`   od ${fmt(start)} · ${dni} dni · orb ścisłości ${orb}° (KONWENCJA)`);
console.log(`   (czas szczytu = FAKT · nazwa aspektu i orb = KONWENCJA)\n`);

if (tryb === 'macierz') {
  const t = new Date();
  console.log(`  Separacje TERAZ (${fmt(t)}):`);
  for (let i = 0; i < CIALA.length; i++)
    for (let j = i + 1; j < CIALA.length; j++) {
      const s = sep(lon(CIALA[i], t), lon(CIALA[j], t));
      for (const a of ASPEKTY)
        if (Math.abs(s - a.kat) <= 3)
          console.log(`  ${PL[CIALA[i]]} ${a.sym} ${PL[CIALA[j]]}  ${s.toFixed(2)}° (odch. ${(s - a.kat).toFixed(2)}°)`);
    }
} else if (tryb === 'stacje') {
  for (const s of skanStacje(start, dni))
    console.log(`  ${fmt(s.szczyt)}  ${PL[s.b]}  stacja → ${s.kierunek}`);
} else {
  for (const w of skanAspekty(start, dni, orb)) {
    const kaz = w.kazimi ? '  ★ KAZIMI (<17′, konwencja)' : '';
    console.log(`  ${fmt(w.szczyt)}  ${PL[w.b1]} ${w.asp.sym} ${PL[w.b2]}  ${w.asp.nazwa}  (odch. ${w.odch.toFixed(3)}°)${kaz}`);
  }
  const st = skanStacje(start, dni);
  if (st.length) {
    console.log(`\n  ── STACJE (zwroty biegu) ──`);
    for (const s of st) console.log(`  ${fmt(s.szczyt)}  ${PL[s.b]}  stacja → ${s.kierunek}`);
  }
}
console.log(`\n  (skaner liczy — znaczenie pozostaje w polu REZONANSU)\n`);
