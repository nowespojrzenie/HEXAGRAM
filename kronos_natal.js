// ============================================================
// KRONOS · NATAL/HOROSKOP — ASC, MC, DOMY + planety w 3 układach
// ------------------------------------------------------------
// JEDNO ŹRÓDŁO PRAWDY: ayan/meanNode/getC z kronos_v4, MATRYCA z kronos_matryca.
// Domy: swisseph calculateHouses (Placidus domyślnie, --hsys=W/K/A/...).
// DECYZJA (3.07.2026, twórca): czyta ORKIESTRATOR; odczyt WIELOUKŁADOWY
//   z jawnym rozróżnieniem co jest czym; interpretacja = KOMENTARZ, nie diagnoza.
// STATUSY: pozycje planet = OBLICZONE. ASC/MC/domy = NOŚNA RAMA⚠
//   (czułe na dokładność godziny i miejsca — weryfikuj akt urodzenia).
// Przypisanie planeta→dom liczone RAZ na tropiku (podział fizyczny,
//   niezależny od etykiet zodiaku — Lahiri/drakonian przesuwają cusps
//   i planety o tę samą wartość, dom zostaje ten sam).
// ============================================================
const A   = require('astronomy-engine');
const K   = require('./kronos_v4.js');
const M   = require('./kronos_matryca.js');
const swe = require('@swisseph/node');

const norm = x => ((x % 360) + 360) % 360;

// --- czas: wejście = czas polski (jak reszta KRONOS), --utc = wejście w UTC ---
function lastSun(y, m0){ const d = new Date(Date.UTC(y, m0 + 1, 0)); return d.getUTCDate() - d.getUTCDay(); }
function tzOffPL(y, m, d, h){
  const mar = lastSun(y, 2), oct = lastSun(y, 9);
  const t = Date.UTC(y, m - 1, d, h);
  return (t >= Date.UTC(y, 2, mar, 1) && t < Date.UTC(y, 9, oct, 1)) ? 2 : 1;
}

// --- znaki tropikalne: równe 30° od 0° Barana (konwencja zachodnia) ---
const ZNAKI_TROPIK = ["Baran","Byk","Bliźnięta","Rak","Lew","Panna","Waga","Skorpion","Strzelec","Koziorożec","Wodnik","Ryby"];
const SYM = {Baran:"♈",Byk:"♉","Bliźnięta":"♊",Rak:"♋",Lew:"♌",Panna:"♍",Waga:"♎",Skorpion:"♏",Strzelec:"♐","Koziorożec":"♑",Wodnik:"♒",Ryby:"♓"};
function znakTropik(lon){ const i = Math.floor(norm(lon) / 30); return { pl: ZNAKI_TROPIK[i], sym: SYM[ZNAKI_TROPIK[i]], st: norm(lon) - i * 30 }; }

// --- Lahiri: REALNE granice konstelacji (kanon kronos_v4/getC) + żywioł MATRYCY ---
function znakLahiri(lonSid){
  const c = K.getC(norm(lonSid));
  const m = M.MATRYCA[c.pl] || null;
  return { pl: c.pl, sym: c.sym, st: norm(lonSid) - c.s < 0 ? norm(lonSid) + 360 - c.s : norm(lonSid) - c.s,
           thun: c.el, el: m ? m.el : "—", biegun: m ? m.biegun : "—", em: m ? m.em : "" };
}

// --- pozycje tropikalne (astronomy-engine — ten sam tor co v4) ---
const CIALA = ["Sun","Moon","Mercury","Venus","Mars","Jupiter","Saturn","Uranus","Neptune","Pluto"];
const CSYM  = {Sun:"☉",Moon:"☽",Mercury:"☿",Venus:"♀",Mars:"♂",Jupiter:"♃",Saturn:"♄",Uranus:"♅",Neptune:"♆",Pluto:"♇"};
const CPL   = {Sun:"Słońce",Moon:"Księżyc",Mercury:"Merkury",Venus:"Wenus",Mars:"Mars",Jupiter:"Jowisz",Saturn:"Saturn",Uranus:"Uran",Neptune:"Neptun",Pluto:"Pluton"};
function tropLon(body, date){
  if (body === "Moon") return norm(A.EclipticGeoMoon(date).lon);
  return norm(A.Ecliptic(A.GeoVector(A.Body[body], date, true)).elon);
}

// --- dom dla długości tropikalnej przy tropikalnych cusps (1..12) ---
function domDla(lon, cusps){
  for (let i = 1; i <= 12; i++){
    const a = norm(cusps[i]), b = norm(cusps[i === 12 ? 1 : i + 1]);
    if (a <= b ? (lon >= a && lon < b) : (lon >= a || lon < b)) return i;
  }
  return 0;
}

function fmtPoz(lon, ayanV, nodeV){
  const t = znakTropik(lon);
  const l = znakLahiri(norm(lon - ayanV));
  const d = znakTropik(norm(lon - nodeV)); // drakonian: konwencja znaków równych
  return {
    trop: `${t.sym} ${t.pl} ${t.st.toFixed(1)}°`,
    lah:  `${l.sym} ${l.pl} ${l.st.toFixed(1)}° · ${l.el}/${l.biegun} ${l.em}`,
    drak: `${d.sym} ${d.pl} ${d.st.toFixed(1)}°`,
    elMatryca: l.el,
  };
}

// ================================= MAIN =================================
const argv = process.argv.slice(2);
const flags = Object.fromEntries(argv.filter(a => a.startsWith("--")).map(a => { const [k, v] = a.slice(2).split("="); return [k, v ?? true]; }));
const args  = argv.filter(a => !a.startsWith("--"));
const hsysKey = Object.entries(swe.HouseSystem).find(([, v]) => v === (flags.hsys || "P"));
const hsys = hsysKey ? hsysKey[1] : "P";
const hsysName = hsysKey ? hsysKey[0] : "Placidus";

let date, lat, lon, opisCzasu;
if (args[0] === "now"){
  date = new Date();
  lat = parseFloat(args[1]); lon = parseFloat(args[2]);
  opisCzasu = "⏱ ZMIERZONE TERAZ (zegar systemowy)";
} else {
  const [y, mo, d, h, mi] = args.slice(0, 5).map(Number);
  lat = parseFloat(args[5]); lon = parseFloat(args[6]);
  const off = flags.utc ? 0 : tzOffPL(y, mo, d, h);
  date = new Date(Date.UTC(y, mo - 1, d, h - off, mi || 0));
  opisCzasu = `wejście: ${d}.${mo}.${y} ${String(h).padStart(2,"0")}:${String(mi||0).padStart(2,"0")} ${flags.utc ? "UTC" : (off === 2 ? "CEST" : "CET")}`;
}
if (!isFinite(lat) || !isFinite(lon)){
  console.log("Użycie:\n  node kronos_natal.js YYYY M D HH MM LAT LON [--hsys=P|W|K|A|R|C] [--utc]\n  node kronos_natal.js now LAT LON [--hsys=...]\nPrzykład: node kronos_natal.js 1985 6 15 14 30 52.41 16.93");
  process.exit(1);
}

const jd = swe.dateToJulianDay(date);
const H  = swe.calculateHouses(jd, lat, lon, hsys);
const ayanV = K.ayan(date);
const nodeV = K.meanNode(date);

const P2 = n => String(n).padStart(2, " ");
console.log(`\n╔═══ KRONOS·NATAL — domy: ${hsysName} · φ${lat.toFixed(2)} λ${lon.toFixed(2)} ═══╗`);
console.log(`${opisCzasu}\nayanamsa Lahiri: ${ayanV.toFixed(2)}° · ☊ węzeł (średni, ±1.5°): ${nodeV.toFixed(1)}°\n`);

console.log(`【 OSIE — status: NOŚNA RAMA⚠ (czułe na dokładność godziny/miejsca) 】`);
for (const [naz, v] of [["ASC", H.ascendant], ["MC ", H.mc]]){
  const p = fmtPoz(norm(v), ayanV, nodeV);
  console.log(`${naz}  TROPIK ${p.trop}   |  LAHIRI ${p.lah}   |  DRAK ${p.drak}`);
}

console.log(`\n【 DOMY (cusps) — NOŚNA RAMA⚠ · układy rozróżnione jawnie 】`);
for (let i = 1; i <= 12; i++){
  const p = fmtPoz(norm(H.cusps[i]), ayanV, nodeV);
  console.log(`D${P2(i)}  TROPIK ${p.trop}   |  LAHIRI ${p.lah}`);
}

console.log(`\n【 PLANETY — status: OBLICZONE · dom liczony raz (podział fizyczny) 】`);
const bilans = {};
for (const b of CIALA){
  const L = tropLon(b, date);
  const p = fmtPoz(L, ayanV, nodeV);
  const dom = domDla(L, H.cusps);
  bilans[p.elMatryca] = (bilans[p.elMatryca] || 0) + 1;
  console.log(`${CSYM[b]} ${CPL[b].padEnd(8)} D${P2(dom)}  TROPIK ${p.trop}  | LAHIRI ${p.lah}  | DRAK ${p.drak}`);
}
{ // węzeł jako punkt
  const p = fmtPoz(nodeV, ayanV, nodeV);
  console.log(`☊ Węzeł    D${P2(domDla(nodeV, H.cusps))}  TROPIK ${p.trop}  | LAHIRI ${p.lah}`);
}

console.log(`\n【 BILANS ŻYWIOŁÓW MATRYCY (planety wg Lahiri) — surowe liczenie, nie werdykt 】`);
console.log(Object.entries(bilans).sort((a,b)=>b[1]-a[1]).map(([k,v])=>`${k}: ${v}`).join(" · "));
console.log(`\n(interpretacja = KOMENTARZ Orkiestratora, nie diagnoza — silnik podaje liczby)`);
