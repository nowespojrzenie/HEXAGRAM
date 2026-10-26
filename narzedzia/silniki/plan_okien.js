#!/usr/bin/env node
/* ── PLAN OKIEN (31.07.2026) ──────────────────────────────────────────────────
 * Domyka bliznę #32: dziennik obiecywał `plan_okien.js` od 26.07, plik nie istniał.
 * Przepis żył jako jednorazowy skrypt w /tmp (skan okna jowiszowego 29.07). Tutaj przestaje
 * być jednorazowy.
 *
 * CZYM JEST: suchy silnik. Liczy GRANICE okien — wejście, szczyt, wyjście — dla aspektów
 * tranzytujących ciał do punktów mapy natalnej. Zero interpretacji. Znaczenie to nie jest
 * robota tego pliku (KRONOS liczy, Orkiestrator czyta, człowiek rozstrzyga).
 *
 * CZEGO PILNUJE (prawa domu, wpisane w kod, nie w komentarz):
 *  · zegar MIERZONY przy każdym uruchomieniu, nigdy zakładany
 *  · skan idzie W TYŁ i W PRZÓD — okno ma dwa brzegi, nie jeden (błąd odczytu 29.07:
 *    zmierzyłam wyjście, wejście podałam jako „wniosek przy symetrii")
 *  · raportuje WSZYSTKIE aspekty w orbie, także trudne — raportowanie samych korzystnych
 *    jest konfabulacją przez pominięcie
 *  · brzeg poza horyzontem skanu jest oznaczany `>` (nie zmyślamy daty, której nie dotknęliśmy)
 *
 * UŻYCIE:
 *   node plan_okien.js <RRRR> <M> <D> <GG> <MM> <lat> <lon> [--mies=14] [--orb=3] [--krok=6]
 *   node plan_okien.js --test          test +/− (straż musi umieć NIE przejść)
 *   przykład: 50 20 · <lat> <lon> = TWOJE miejsce urodzenia, czas w UTC.
 * ─────────────────────────────────────────────────────────────────────────── */
const k = require('./kronos_v4.js');
const TZ = require('./tz_pl.js');   // jedno źródło czasu lokalnego

const WOLNE  = ["Jupiter","Saturn","Uranus","Neptune","Pluto"];
const CIALA  = ["Sun","Moon","Mercury","Venus","Mars",...WOLNE];
const ASPEKTY = [[0,"☌"],[60,"⚹"],[90,"□"],[120,"△"],[180,"☍"]];
const PL = {Sun:"Słońce",Moon:"Księżyc",Mercury:"Merkury",Venus:"Wenus",Mars:"Mars",
            Jupiter:"Jowisz",Saturn:"Saturn",Uranus:"Uran",Neptune:"Neptun",Pluto:"Pluton"};

const rozn = (a,b) => { let d=Math.abs(a-b)%360; return d>180 ? 360-d : d; };
const dzien = d => d.toLocaleString("pl-PL",{timeZone:TZ.STREFA,dateStyle:"short"});
const chwila= d => d.toLocaleString("pl-PL",{timeZone:TZ.STREFA});

function natal(y,m,d,hh,mm,lat,lon){
  const dt = new Date(Date.UTC(y,m-1,d,hh,mm,0));
  const n = {};
  for (const b of CIALA) { try { n[b]=k.sidLon(b,dt); } catch(e){} }
  return {dt, n, lat, lon};
}

// odległość od dokładnego aspektu (0 = dokładny)
function odchyl(when, ciało, natLon, kat){
  let tl; try { tl = k.sidLon(ciało, when); } catch(e){ return null; }
  return Math.abs(rozn(tl, natLon) - kat);
}

/* Skanuje jeden aspekt w obie strony od `teraz`. Zwraca brzegi i szczyt.
   Brzeg nieosiągnięty w horyzoncie → flaga poza:true (nie zmyślamy daty). */
function okno(teraz, ciało, natLon, kat, orb, godzHoryzont, krokH){
  const o0 = odchyl(teraz, ciało, natLon, kat);
  if (o0 === null || o0 > orb) return null;

  let wejscie=null, poza_w=true;
  for (let h=0; h>=-godzHoryzont; h-=krokH){
    const d=new Date(teraz.getTime()+h*3600e3);
    if (odchyl(d,ciało,natLon,kat) > orb){ wejscie=d; poza_w=false; break; }
  }
  let wyjscie=null, poza_j=true;
  for (let h=0; h<=godzHoryzont; h+=krokH){
    const d=new Date(teraz.getTime()+h*3600e3);
    if (odchyl(d,ciało,natLon,kat) > orb){ wyjscie=d; poza_j=false; break; }
  }
  // szczyt: co godzinę w oknie ±30 dni. Jeśli minimum wypada NA KRAWĘDZI okna szukania,
  // to nie jest szczyt — to koniec zasięgu. Oznaczamy, nie udajemy. (Deklamator w kodzie.)
  const ZAK=720; let best=1e9, bh=null;
  for (let h=-ZAK; h<=ZAK; h+=1){
    const d=new Date(teraz.getTime()+h*3600e3);
    const o=odchyl(d,ciało,natLon,kat);
    if (o!==null && o<best){ best=o; bh=h; }
  }
  const naKrawedzi = (Math.abs(bh) >= ZAK-1);
  return {teraz:o0, wejscie, poza_w, wyjscie, poza_j,
          szczyt:new Date(teraz.getTime()+bh*3600e3), szczytOrb:best, szczytPoza:naKrawedzi};
}

function raport(N, teraz, mies, orb, krokH){
  const H = Math.round(mies*30.44*24);
  console.log(`⏱ ZMIERZONE TERAZ: ${chwila(teraz)} (${TZ.STREFA})`);
  console.log(`   horyzont skanu: ±${mies} mies. · krok ${krokH}h · orb ${orb}° · układ: Lahiri syderyczny\n`);

  const wiersze=[];
  for (const t of WOLNE)
    for (const nb in N.n)
      for (const [kat,znak] of ASPEKTY){
        const w = okno(teraz, t, N.n[nb], kat, orb, H, krokH);
        if (w) wiersze.push({t,nb,znak,kat,w});
      }

  if (!wiersze.length){ console.log("  (brak aspektów ciał wolnych w orbie — okno puste)"); return 0; }
  wiersze.sort((a,b)=>a.w.teraz-b.w.teraz);

  console.log("【 OKNA OTWARTE TERAZ — ciała wolne 】");
  for (const {t,nb,znak,w} of wiersze){
    const we = w.poza_w ? `> ${mies} mies. wstecz` : dzien(w.wejscie);
    const wy = w.poza_j ? `> ${mies} mies. naprzód` : dzien(w.wyjscie);
    const dni = (w.poza_j || w.poza_w) ? "—" :
      Math.round((w.wyjscie-w.wejscie)/86400e3)+" dni";
    console.log(`  tranz.${(PL[t]||t).padEnd(8)} ${znak} natal.${(PL[nb]||nb).padEnd(8)} ` +
                `orb ${w.teraz.toFixed(2).padStart(5)}°  |  ${we} → ${wy}  (${dni})`);
    if (w.szczytPoza)
      console.log(`      szczyt: POZA oknem szukania (±30 dni) — orb wciąż maleje na krawędzi ${dzien(w.szczyt)}, ${w.szczytOrb.toFixed(3)}°`);
    else
      console.log(`      szczyt: ${chwila(w.szczyt)}  orb ${w.szczytOrb.toFixed(3)}°`);
  }
  const trudne = wiersze.filter(x=>x.kat===90||x.kat===180).length;
  console.log(`\n  zliczone: ${wiersze.length} okien (w tym ${trudne} kwadratur/opozycji).`);
  console.log("  KRONOS liczy. Znaczenia tu nie ma i nie będzie.");
  return wiersze.length;
}

/* ── AUTOTEST — prawo #38: każda REGUŁA deklarowana w nagłówku ma własny tor.
   Nie wystarczy „znajduje / nie znajduje". Trzy prawa = trzy tory. ── */
if (process.argv.includes('--test')){
  // FIKSTURA SYNTETYCZNA — nie jest niczyją datą ani niczyim miejscem (07.10.2026, słowo twórcy: dane osobowe nie mają czego szukać
  // w autoteście; wcześniej stała tu karta urodzenia, od 13.08). „Punkty natalne” wylicza się WZGLĘDEM NIEBA CHWILI TESTU, tak by
  // każdy tor dostał to, czego wymaga (tory zależą od zegara, więc stały punkt natalny mógłby oblać z powodu fikstury, nie kodu):
  //   Mars   := Jowisz za 5 dni + 0.4°   → Jowisz w orbie koniunkcji, dokładny aspekt wypada w oknie ±30 dni (TOR 0/1, klasa „prawdziwy szczyt” TORU 3)
  //   Wenus  := Saturn za 5 dni + 0.4°   → drugie ciało, drugie okno z oboma brzegami w horyzoncie 14 mies.
  //   Saturn := Pluton teraz − 91°       → Pluton w kwadraturze do tego punktu z odchyłem 1° < orb 3° (TOR 2; Pluton wolny → brzeg poza horyzontem doby;
  //                                        klasa „szczyt na krawędzi” TORU 3)
  // STAŁA CHWILA, nie zegar (U1-11, 08.10.2026): fikstura liczona względem nieba „teraz” oblewała w niektóre dni kalendarza (4–11.11.2027 i 3.12.2027: tor 3 —
  // 0 oznaczonych jako POZA oknem szukania, 9 z prawdziwym szczytem), a tor stoi w baterii zapis_git.sh, więc w te dni odmówiłby każdemu. Autotest ma dawać ten sam
  // wynik w każdym dniu; chwila dobrana tak, by wszystkie trzy tory miały swoje klasy (sprawdzone pod zegarem wstrzykniętym, patrz komunikat commita).
  const teraz = new Date(Date.UTC(2026, 9, 8, 12));
  const mod360 = x => ((x % 360) + 360) % 360;
  const nieboZa = (b, dh) => k.sidLon(b, new Date(teraz.getTime() + dh*3600e3));
  const N = (() => {
    const n = {};
    CIALA.forEach((b, i) => { n[b] = mod360(11 + i*33.7); });          // tło: rozstawione, bez znaczenia dla torów
    n["Mars"]   = mod360(nieboZa("Jupiter", 120) + 0.4);
    n["Venus"]  = mod360(nieboZa("Saturn", 120) + 0.4);
    n["Saturn"] = mod360(nieboZa("Pluto", 0) - 91);
    return {dt: teraz, n, lat: 50, lon: 20};
  })();
  const H = Math.round(14*30.44*24);
  let ok = true;

  console.log("── TOR 0: znajduje przy realnym orbie, NIE znajduje przy zerowym ──");
  const duzo = raport(N, teraz, 14, 3, 12);
  const zero = raport(N, teraz, 14, 0.0001, 12);
  const t0 = duzo>0 && zero===0;
  console.log(`  ${t0?'✓':'✗'} znaleziono ${duzo} / ${zero}`); ok = ok && t0;

  // zbierz okna raz, do trzech kolejnych torów
  const okna=[];
  for (const t of WOLNE) for (const nb in N.n) for (const [kat] of ASPEKTY){
    const w = okno(teraz, t, N.n[nb], kat, 3, H, 12); if (w) okna.push({t,nb,w});
  }

  console.log("\n── TOR 1 (PRAWO: skan w OBIE strony) ──");
  const obustronne = okna.filter(x=>!x.w.poza_w && !x.w.poza_j);
  const t1 = obustronne.length>0 && obustronne.every(x=>x.w.wejscie<teraz && x.w.wyjscie>teraz);
  console.log(`  ${t1?'✓':'✗'} ${obustronne.length} okien ma OBA brzegi zmierzone, każdy po właściwej stronie „teraz”`);
  ok = ok && t1;

  console.log("\n── TOR 2 (PRAWO: brzeg poza horyzontem OZNACZANY, nie zmyślany) ──");
  const waskie = okno(teraz, "Pluto", N.n["Saturn"], 90, 3, 24, 12);   // horyzont 1 doba
  const t2 = waskie && (waskie.poza_w || waskie.poza_j);
  console.log(`  ${t2?'✓':'✗'} przy horyzoncie 24h brzeg jest oznaczony jako poza (poza_w=${waskie&&waskie.poza_w}, poza_j=${waskie&&waskie.poza_j})`);
  ok = ok && t2;

  console.log("\n── TOR 3 (PRAWO: szczyt na KRAWĘDZI okna szukania NIE udaje szczytu) ──");
  const zKrawedzia = okna.filter(x=>x.w.szczytPoza);
  const zeSzczytem = okna.filter(x=>!x.w.szczytPoza);
  const t3 = zKrawedzia.length>0 && zeSzczytem.length>0;
  console.log(`  ${t3?'✓':'✗'} ${zKrawedzia.length} oznaczonych jako POZA oknem szukania, ${zeSzczytem.length} z prawdziwym szczytem`);
  console.log(`      (obie klasy MUSZĄ wystąpić — inaczej flaga nigdy nie zapala się albo zapala zawsze)`);
  ok = ok && t3;

  console.log(ok ? "\n  ✓ STRAŻ ŻYWA: każde deklarowane prawo ma własny tor i przechodzi."
                 : "\n  ✗ STRAŻ MARTWA: któreś deklarowane prawo nie ma pokrycia w teście.");
  process.exit(ok?0:1);
}

const a = process.argv.slice(2).filter(x=>!x.startsWith('--'));
const f = Object.fromEntries(process.argv.slice(2).filter(x=>x.startsWith('--'))
            .map(x=>{const [kk,v]=x.slice(2).split('='); return [kk, v??true];}));
if (a.length < 7){
  console.log("użycie: node plan_okien.js <RRRR> <M> <D> <GG> <MM> <lat> <lon> [--mies=14] [--orb=3] [--krok=6]");
  console.log("        node plan_okien.js --test");
  process.exit(2);
}
const N = natal(+a[0],+a[1],+a[2],+a[3],+a[4],+a[5],+a[6]);
raport(N, new Date(), +(f.mies||14), +(f.orb||3), +(f.krok||6));
