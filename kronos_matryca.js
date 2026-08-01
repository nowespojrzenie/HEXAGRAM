// ============================================================
// KRONOS · MATRYCA — sześć żywiołów z par znaków + progi zero
// Warstwa PRYMARNA (MATRYCA). Thun = warstwa referencyjna (jawny szew).
// NIE nadpisuje kronos_v4.js CONST (granice zwalidowane). Dodaje drugą kolumnę.
// ============================================================
const K = require('./kronos_v4.js');

// --- PRZYDZIAŁ UŻYTKOWNIKA: 12 znaków → 6 żywiołów × 2 bieguny (wewn/zewn) ---
// Cztery czyste oddały po znaku; z oddanych powstały operatory.
// Ogień: Baran(w)/Lew(z) · Powietrze: Bliźnięta(w)/Waga(z) · Woda: Rak(w)/Ryby(z)
// Ziemia: Koziorożec(w)/Byk(z) · METAL: Panna(w)/Wodnik(z) · ŚMIERĆ: Skorpion(w)/Strzelec(z)
const MATRYCA = {
  "Baran":      {el:"Ogień",     biegun:"wewn", em:"🔥", jung:"intuicja"},
  "Lew":        {el:"Ogień",     biegun:"zewn", em:"🔥", jung:"intuicja"},
  "Bliźnięta":  {el:"Powietrze", biegun:"wewn", em:"💨", jung:"myślenie"},
  "Waga":       {el:"Powietrze", biegun:"zewn", em:"💨", jung:"myślenie"},
  "Rak":        {el:"Woda",      biegun:"wewn", em:"💧", jung:"uczucie"},
  "Ryby":       {el:"Woda",      biegun:"zewn", em:"💧", jung:"uczucie"},
  "Koziorożec": {el:"Ziemia",    biegun:"wewn", em:"🌍", jung:"doznanie"},
  "Byk":        {el:"Ziemia",    biegun:"zewn", em:"🌍", jung:"doznanie"},
  "Panna":      {el:"Metal",     biegun:"wewn", em:"🜔", jung:"wola (operator)"},
  "Wodnik":     {el:"Metal",     biegun:"zewn", em:"🜔", jung:"wola (operator)"},
  "Skorpion":   {el:"Śmierć",    biegun:"wewn", em:"☠️", jung:"operator"},
  "Strzelec":   {el:"Śmierć",    biegun:"zewn", em:"☠️", jung:"operator"},
};

// kolejność znaków po zodiaku (do wyznaczania sąsiada/następnej granicy)
const ZNAKI = ["Baran","Byk","Bliźnięta","Rak","Lew","Panna","Waga","Skorpion","Strzelec","Koziorożec","Wodnik","Ryby"];

// --- odczyt MATRYCY dla danej długości syderycznej ---
function matrycaC(s){
  const c = K.getC(s);              // znak + dane Thuna (el/typ zwalidowane)
  const m = MATRYCA[c.pl];          // żywioł MATRYCY + biegun
  const rozni = (m.el !== c.el);    // czy MATRYCA różni się od Thuna
  return {znak:c.pl, sym:c.sym, s:c.s, e:c.e,
          el:m.el, biegun:m.biegun, em:m.em, jung:m.jung,
          thun:{el:c.el, typ:c.typ, em:c.em}, rozni};
}

// --- PRÓG ZERO: typ przejścia na najbliższej granicy konstelacji ---
// Dwa rodzaje:
//  • ETER  — granica między RÓŻNYMI żywiołami (pustka potencjału; 11 na obrocie)
//  • USPÓJNIENIE — granica wewn→zewn TEGO SAMEGO żywiołu (tylko Skorpion→Strzelec, Śmierć)
//    "jak wewnątrz, tak na zewnątrz" — jedyne miejsce, gdzie bieguny żywiołu sąsiadują.
function progZero(znakA, znakB){
  const a = MATRYCA[znakA], b = MATRYCA[znakB];
  if(a.el === b.el){
    // ten sam żywioł po obu stronach granicy — przejście biegunów
    return {typ:"uspójnienie", el:a.el,
            opis:`Próg uspójnienia w żywiole ${a.el}: ${a.biegun}→${b.biegun}. Jak wewnątrz, tak na zewnątrz — bieguny domykają się bez przerwy.`,
            pyt:"Gdzie moje wewnętrzne i zewnętrzne to już jedno — i czy gram to samo w obie strony?"};
  }
  return {typ:"eter", elOd:a.el, elDo:b.el,
          opis:`Punkt zero (eter): ${a.el} → ${b.el}. Jedna jakość gaśnie, druga jeszcze nie zaczęła. Pustka potencjału.`,
          pyt:"Co chce się tu narodzić, gdy jednego już nie ma, a drugiego jeszcze nie wybieram?"};
}

// następna i poprzednia granica znaku (po długości syderycznej Księżyca)
function granice(s){
  const c = K.getC(s);
  const i = ZNAKI.indexOf(c.pl);
  const nast = ZNAKI[(i+1)%12];
  const poprz = ZNAKI[(i+11)%12];
  return {
    obecny:c.pl,
    nastepnaGranica: progZero(c.pl, nast),   // co nas czeka, gdy Księżyc wyjdzie
    poprzedniaGranica: progZero(poprz, c.pl), // przez co weszliśmy
  };
}

// --- API: pełny odczyt MATRYCY na datę ---
function matryca(y,m,d,h){
  const r = K.analyze(y,m,d,h||12);
  const mc = matrycaC(r.s);
  const g = granice(r.s);
  return {comp:r, m:mc, granice:g};
}

module.exports = {matryca, matrycaC, progZero, granice, MATRYCA, ZNAKI};

// --- CLI ---
if(require.main===module){
  const [,,y,m,d,h]=process.argv.map(Number);
  const {comp:r, m:mc, granice:g} = matryca(y,m,d,h);
  const hh=h||12;
  console.log(`\n╔═══ KRONOS · MATRYCA · ${d}.${String(m).padStart(2,'0')}.${y} ${String(hh).padStart(2,'0')}:00 ${r.off===2?'CEST':'CET'} ═══╗`);

  console.log(`\n【 ŻYWIOŁ MATRYCY — sześć, z par znaków 】`);
  console.log(`${mc.em} ${mc.sym} ${mc.znak} · ${mc.el} · biegun ${mc.biegun.toUpperCase()} · ${mc.jung}`);
  if(mc.rozni){
    console.log(`   ↳ u Thun: dzień ${mc.thun.typ} (${mc.thun.el}) ${mc.thun.em}  ← MATRYCA widzi tu ${mc.el}`);
  } else {
    console.log(`   ↳ zgodne z Thun: dzień ${mc.thun.typ} (${mc.thun.el})`);
  }

  console.log(`\n【 PROGI ZERO — przestrzenie przejścia 】`);
  const ng=g.nastepnaGranica, pg=g.poprzedniaGranica;
  if(r.next){
    const tag = ng.typ==="uspójnienie" ? "⊙ USPÓJNIENIE" : "🌌 ETER";
    console.log(`→ następny próg (za ~${r.next.h}h, wejście w ${r.next.c.sym}${r.next.c.pl}): ${tag}`);
    console.log(`   ${ng.opis}`);
    console.log(`   ↳ ${ng.pyt}`);
  }
  const tagP = pg.typ==="uspójnienie" ? "⊙ USPÓJNIENIE" : "🌌 ETER";
  console.log(`⌛ poprzedni próg (wejście w obecny znak): ${tagP}`);
  console.log(`   ${pg.opis}`);

  console.log(`\n(MATRYCA prymarna · Thun referencyjny · próg zero = eter; w Śmierci = uspójnienie)`);
}
