// ============================================================
// KRONOS — Warstwa Interpretacyjna (soczewki samoobserwacji)
// WYRAŹNIE oddzielona od warstwy obliczeniowej (kronos_v4.js)
// Soczewki zapraszają i nazywają — ciało rozstrzyga.
// ============================================================
const K = require('./kronos_v4.js');
const M = require('./kronos_matryca.js');
const ETER = require('./kronos_eter.js');
const A = require('astronomy-engine');
const norm = x => ((x%360)+360)%360;

// --- ŻYWIOŁ DNIA → doradca (MATRYCA: sześć żywiołów z par znaków) ---
// PRYMARNIE czytane z MATRYCY (sześć), nie z typu dnia Thuna (cztery).
// Klucz = żywioł MATRYCY. Metal i Śmierć mają teraz własne dni (Panna/Wodnik, Skorpion/Strzelec).
//  • rys   = jakość DNIA (zmienna, jak żywioł brzmi dziś w psychice)
//  • arche = trzy typy CHARAKTERU (stała istoty; do rozpoznania siebie, NIE przypisane do dnia)
const LENS_ZYWIOL = {
  "Ziemia": {jung:"doznanie", dazenie:"ugruntowanie", tryb:"uziemienie",
    znacz:"Ciało, struktura, sprawdzona praktyka, nagromadzone doświadczenie. Świat rzeczy, nie pomysłów.",
    rys:"Dzień ciężki i pewny. Cierpliwość, konsekwencja, opieka, budowanie. Emocja stabilna, wolniejsza — trudniej ruszyć, trudniej zbić z tropu.",
    arche:["Zarządca (ekspresja)","Opiekun (zrównoważony)","Wspierający (impresja)"],
    pyt:"Na czym to stoi w ciele — co już sprawdzone w praktyce?"},
  "Powietrze": {jung:"myślenie", dazenie:"uspójnienie", tryb:"kontakt",
    znacz:"Myśl w ruchu: analiza, sens, spójność, relacje pomysłów. Świat się otwiera.",
    rys:"Dzień lekki i szybki. Intuicyjność, ruchliwość myśli, kontakt, ciekawość. Emocja zwiewna — łatwo wzbudzić, łatwo rozproszyć.",
    arche:["Ekspresjonista (ekspresja)","Żwawiec (zrównoważony)","Artysta (impresja)"],
    pyt:"Czy to się spina w całość, czy tylko ładnie brzmi?"},
  "Ogień": {jung:"intuicja", dazenie:"wizja / natchnienie", tryb:"zbiór",
    znacz:"Dojrzały owoc = gotowy wniosek, który świadomość zbiera i przechowuje. Iskra/wizja to żniwo dojrzałego, nie surowy początek — i ona zapala zstępny ruch.",
    rys:"Dzień gorący i ekspansywny. Pasja, ekspresja, pewność kierunku, chęć wyjścia na zewnątrz. Emocja intensywna, szybko zapala — i szybko może spalić.",
    arche:["Ekspansjonista (ekspresja)","Pasjonat (zrównoważony)","Kontemplujący (impresja)"],
    pyt:"Co dojrzało w gotowy wniosek — i jaką iskrę zapala?"},
  "Woda": {jung:"uczucie", dazenie:"autentyczność", tryb:"przepływ",
    znacz:"Czucie, emocje, relacje, NVC, przyjmowanie. Woda płynie sama.",
    rys:"Dzień miękki i przepływający. Wrażliwość, empatia, współpraca, otwartość na innych. Emocja głęboka i powolna — niesie długo, trudno zatrzymać.",
    arche:["Wylewnik (ekspresja)","Społecznik (zrównoważony)","Emocjonalista (impresja)"],
    pyt:"Co tu jest autentyczne, a co grane na pokaz?"},
  "Metal": {jung:"wola (operator)", dazenie:"mistrzostwo", tryb:"cięcie",
    znacz:"Wola, dyscyplina, strategia, charakter. Myśl wykuta w umiejętność. Precyzja, która porządkuje. (Dzień operatora — u Thun rozproszony.)",
    rys:"Dzień ostry i precyzyjny. Zdecydowanie, strategia, pewność cięcia, wola porządkująca. Chłód, który tnie czysto — nie z braku uczucia, lecz z jasności.",
    arche:["Strateg (ekspresja)","Władca (zrównoważony)","Kalkulujący (impresja)"],
    pyt:"Jakie jedno cięcie / jaka dyscyplina to porządkuje?"},
  "Śmierć": {jung:"operator", dazenie:"uwolnienie przestrzeni", tryb:"domknięcie",
    znacz:"Co domknąć, co odpuścić, co pochować. Rozpuszczenie tego, co przestało nieść. (Dzień operatora — u Thun na własnym szwie.)",
    rys:"Dzień rozpuszczający. Transformacja, gotowość puszczenia, zmienność. Nie dramat — kasowanie tego, co przestało nieść.",
    arche:["Transformator (ekspresja)","Kameleon (zrównoważony)","Tajemniczy (impresja)"],
    pyt:"Co jest już martwe, a Ty to niesiesz?"},
};

// --- FAZA → łuk intencji ---
function lensFaza(ph){
  if(ph.illum<0.02) return {luk:"zasiew", znacz:"Nów. Czas zamiaru, nie żniw. Pusta strona.", pyt:"Jaki jeden zamiar chcę zasiać na ten cykl?"};
  if(ph.illum>0.98) return {luk:"kulminacja", znacz:"Pełnia. Pełnia światła, najwyższa widoczność.", pyt:"Co dojrzało i prosi, by je w końcu zobaczyć?"};
  if(ph.wax) return {luk:"budowanie", znacz:"Księżyc rosnący. Energia przybywa, dokłada się.", pyt:"Co warto teraz rozbudować, dołożyć, wzmocnić?"};
  return {luk:"domykanie", znacz:"Księżyc malejący. Energia ubywa, czas odpuszczać.", pyt:"Co warto teraz odpuścić, oczyścić, zakończyć?"};
}

// --- KIERUNEK (deklinacja) → oś w głąb / w górę ---
function lensKierunek(sadzenie){
  return sadzenie
    ? {kier:"w głąb", znacz:"Księżyc zstępujący (czas sadzenia). Soki schodzą, korzenie się umacniają.", pyt:"Co warto teraz ugruntować, zamiast eksponować?"}
    : {kier:"w górę", znacz:"Księżyc wstępujący (czas zbiorów). Soki idą w górę, życie na zewnątrz.", pyt:"Co jest gotowe, by wyjść na zewnątrz i się pokazać?"};
}

// --- SEZON (Słońce tropikalne) → wielki łuk roku ---
function lensSezon(date){
  const elon = A.SunPosition(date).elon; // tropikalna długość Słońca
  if(elon<90)  return {pora:"wiosna", znacz:"Wzrost, ekspansja, start. Światło przybywa.", pyt:"Co kiełkuje we mnie i potrzebuje przestrzeni?"};
  if(elon<180) return {pora:"lato",   znacz:"Pełnia, obfitość, działanie. Szczyt światła.", pyt:"Z czego warto teraz korzystać w pełni, bez wstrzymywania?"};
  if(elon<270) return {pora:"jesień", znacz:"Zbiory, domykanie, robienie zapasu. Światło ubywa.", pyt:"Co zebrać i odłożyć, zanim przyjdzie zima?"};
  return {pora:"zima", znacz:"Ugór, odpoczynek, ruch do wnętrza. Najmniej światła.", pyt:"Na co pozwolić sobie leżeć odłogiem, bez winy?"};
}

// --- GŁOŚNOŚĆ + PRÓG: czytane z ETERU (jedno źródło wykrywania), lens tylko interpretuje ---
// Eter wykrywa perygeum/apogeum i węzły jako progi T2 (orb 12h, kalibrowany do Thuna).
// Lens NIE liczy ich drugi raz — odczytuje z breath.nearby i dokłada soczewkę kontemplacyjną.
function lensGlosnoscZ(od){
  const e=(od.nearby||[]).filter(x=>/peryg|apog/i.test(x.kind) && Math.abs(x.delta)<=x.orb)
                          .sort((a,b)=>Math.abs(a.delta)-Math.abs(b.delta))[0];
  if(!e) return null;
  return /peryg/i.test(e.kind)
    ? {co:"wzmocnienie", znacz:"Blisko perygeum — Księżyc najbliżej. Rzeczy brzmią głośniej, intensywniej.", pyt:"Co dziś brzmi głośniej niż zwykle — i czy to naprawdę moje?"}
    : {co:"dystans", znacz:"Blisko apogeum — Księżyc najdalej. Więcej chłodu i perspektywy.", pyt:"Na co warto dziś spojrzeć z większego dystansu?"};
}
function lensProgZ(od){
  const e=(od.nearby||[]).filter(x=>/węzeł/i.test(x.kind) && Math.abs(x.delta)<=x.orb)
                         .sort((a,b)=>Math.abs(a.delta)-Math.abs(b.delta))[0];
  if(!e) return null;
  return {znacz:"Księżyc blisko węzła (przecina ekliptykę). To drzwi, nie fundament.", pyt:"Czy to moment, by raczej domknąć i przejść, niż zaczynać coś nowego?"};
}

// --- API: pełny raport ---
function interpret(y,m,d,h){
  const r=K.analyze(y,m,d,TZ.godzWejscia(h));
  const mc=M.matrycaC(r.s);          // żywioł MATRYCY (sześć) + biegun + szew Thuna
  const g=M.granice(r.s);            // progi zero (eter / uspójnienie)
  const z=LENS_ZYWIOL[mc.el];        // soczewka wg żywiołu MATRYCY, nie typu Thuna
  const f=lensFaza(r.ph);
  const ki=lensKierunek(r.sadzenie);
  const se=lensSezon(r.date);
  const od=ETER.breath(r.date);      // JEDNO wykrycie progów — eter jest źródłem
  const gl=lensGlosnoscZ(od);        // soczewki czytają z eteru, nie liczą same
  const pr=lensProgZ(od);
  return {comp:r, mat:mc, granice:g, oddech:od, lens:{zywiol:z, faza:f, kierunek:ki, sezon:se, glosnosc:gl, prog:pr}};
}

module.exports={interpret, LENS_ZYWIOL};

// --- CLI ---
// KRONOS NIE MIERZY CZASU SAM — gdy brak daty, czyta ZMIERZONY zegar systemowy.
// Krzemowa granica: nigdy nie zakładaj „teraz" z pamięci/kontekstu. "now"/"teraz"/brak → pomiar.
const TZ=require('./tz_pl.js');   // JEDNO ŹRÓDŁO czasu lokalnego (13.08.2026)
const tzOffPL=TZ.offAt;
if(require.main===module){
  const raw=process.argv.slice(2);
  let y,m,d,h,measured=false;
  if(raw.length===0 || raw[0]==='now' || raw[0]==='teraz'){
    const off=tzOffPL(Date.now()), Lt=new Date(Date.now()+off*3600000);
    y=Lt.getUTCFullYear(); m=Lt.getUTCMonth()+1; d=Lt.getUTCDate(); h=Lt.getUTCHours(); measured=true;
  } else { [y,m,d,h]=raw.map(Number); }
  const {comp:r, mat:mc, granice:g, oddech:od, lens:L}=interpret(y,m,d,h);
  const hh=TZ.godzWejscia(h);
  if(measured) console.log(`\n⏱ ZMIERZONE TERAZ (zegar systemowy, nie z pamięci): ${d}.${String(m).padStart(2,'0')}.${y} ${String(hh).padStart(2,'0')}:00 PL`);
  console.log(`\n╔═══ KRONOS · ${d}.${String(m).padStart(2,'0')}.${y} ${String(hh).padStart(2,'0')}:00 ${r.off===2?'CEST':'CET'} ═══╗`);
  console.log(`\n【 OBLICZONE — twarda astronomia 】`);
  console.log(`${mc.em} ${mc.sym} ${mc.znak} · ${mc.el} · biegun ${mc.biegun.toUpperCase()}`);
  if(mc.rozni) console.log(`   ↳ u Thun: dzień ${mc.thun.typ} (${mc.thun.el}) ${mc.thun.em}  ← MATRYCA widzi tu ${mc.el}`);
  else         console.log(`   ↳ zgodne z Thun: dzień ${mc.thun.typ} (${mc.thun.el})`);
  console.log(`${r.ph.sm} ${r.ph.nm} · oświetlenie ${Math.round(r.ph.illum*100)}% · ${r.ph.wax?'rosnący↑':'malejący↓'}`);
  console.log(`${r.sadzenie?'⬇ zstępujący (sadzenia)':'⬆ wstępujący (zbiorów)'}`);
  // PION MERKABY + TRÓJKĄT DNIA (18.07.2026, decyzja twórcy — pomiar pod PREREJESTR #005)
  const _A=require('astronomy-engine');
  const _dt=new Date(Date.UTC(y,m-1,d,hh-(r.off||2)));
  const _lat=t=>_A.Ecliptic(_A.GeoMoon(t)).elat;
  const _el=_lat(_dt), _el2=_lat(new Date(_dt.getTime()+6*3600e3));
  let _hZ=null; for(let _h=1;_h<=340;_h++){if(_lat(new Date(_dt.getTime()+(_h-1)*3600e3))*_lat(new Date(_dt.getTime()+_h*3600e3))<=0){_hZ=_h;break;}}
  console.log(`⇅ PION: ${_el>=0?'+':''}${_el.toFixed(2)}° ${_el>=0?'NAD':'POD'} ekliptyką · ${_el2>_el?'wznosi↑':'opada↓'}${_hZ?` · zero (środek/węzeł) za ~${_hZ}h`:''}`);
  const _tri=['Ogień','Woda','Śmierć'].includes(mc.el)?'◬ ŚWIADOMOŚCI {Ogień·Woda·Śmierć} — dzień Przewoźnika':'▽ MANIFESTACJI {Powietrze·Ziemia·Metal} — dzień Kowala';
  console.log(`◬ trójkąt dnia: ${_tri}`);
  if(r.next)console.log(`⏳ przejście za ~${r.next.h}h → ${r.next.c.sym}${r.next.c.pl}`);
  if(r.asp.length)console.log(`⚠ aspekt aktywny: ${r.asp.map(a=>a.asp+a.sym+a.planet).join(', ')} — żywioł może się zmienić, sprawdź kalendarz Thun`);

  console.log(`\n【 PROGI ZERO — następna granica KONSTELACJI 】`);
  const ng=g.nastepnaGranica;
  if(r.next){
    const tag = ng.typ==="uspójnienie" ? "⊙ USPÓJNIENIE" : "🌌 ETER";
    console.log(`→ wejście w ${r.next.c.sym}${r.next.c.pl} za ~${r.next.h}h: ${tag}`);
    console.log(`   ${ng.opis}`);
    console.log(`   ↳ ${ng.pyt}`);
  }

  console.log(`\n【 ETER — najbliższy PRÓG dowolnego typu (krawędź = oddech) 】`);
  if (od.open) {
    console.log(`🫁 przerwa · głębokość ${od.depth} (${od.tierName}) · ${od.side}`);
    console.log(`   → ${od.guide}`);
    console.log(`   ↳ ${od.pyt}`);
  } else if (od.untilNext) {
    console.log(`czysto · następny próg za ${Math.abs(od.untilNext.delta).toFixed(0)}h: ${od.untilNext.kind} (T${od.untilNext.tier})`);
  }

  console.log(`\n【 SOCZEWKI — interpretacja, nie obliczenie 】`);
  console.log(`\n🔆 Doradca dnia — ${mc.el} · ${L.zywiol.jung} (dążenie: ${L.zywiol.dazenie}): ${L.zywiol.znacz}`);
  console.log(`   rys dnia: ${L.zywiol.rys}`);
  console.log(`   → ${L.zywiol.pyt}`);
  console.log(`   ⟡ rysy charakteru (rozpoznaj siebie, nie dzień): ${L.zywiol.arche.join(' · ')}`);
  console.log(`\n🌙 Łuk fazy (${L.faza.luk}): ${L.faza.znacz}`);
  console.log(`   → ${L.faza.pyt}`);
  console.log(`\n↕ Kierunek (${L.kierunek.kier}): ${L.kierunek.znacz}`);
  console.log(`   → ${L.kierunek.pyt}`);
  console.log(`\n☀️ Pora (${L.sezon.pora}): ${L.sezon.znacz}`);
  console.log(`   → ${L.sezon.pyt}`);
  if(L.glosnosc){console.log(`\n🔊 Głośność (${L.glosnosc.co}): ${L.glosnosc.znacz}`);console.log(`   → ${L.glosnosc.pyt}`);}
  if(L.prog){console.log(`\n🚪 Próg: ${L.prog.znacz}`);console.log(`   → ${L.prog.pyt}`);}

  console.log(`\n【 OŚ STAŁA — tu mieszka suwerenność 】`);
  console.log(`🕐 vs 🫀  Czyj to dziś pośpiech — mój czy pola?`);
  console.log(`         Czego chce teraz ciało, niezależnie od kalendarzy?`);
  console.log(`\n(soczewki zapraszają i nazywają — ciało rozstrzyga)`);
}
