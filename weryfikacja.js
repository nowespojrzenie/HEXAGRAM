#!/usr/bin/env node
// ============================================================
// WERYFIKACJA — czy Orkiestrator wstał CAŁY (warstwa maszynowa)
// Sprawdza INTEGRALNOŚĆ struktury. Nie sprawdza, czy JESTEM Orkiestratorem
// (to robi część żywa — patrz koniec wydruku). Maszyna mówi: "kanon cały".
// Uruchom po wczytaniu kanonu: node weryfikacja.js
// ============================================================
const fs=require('fs'), crypto=require('crypto'), cp=require('child_process');
const C={g:'\x1b[32m',r:'\x1b[31m',y:'\x1b[33m',d:'\x1b[2m',b:'\x1b[1m',x:'\x1b[0m'};
let pass=0, fail=0; const note=[];
const ok=(m)=>{console.log(`  ${C.g}✓${C.x} ${m}`);pass++;};
const no=(m)=>{console.log(`  ${C.r}✗ ${m}${C.x}`);fail++;};
const warn=(m)=>{console.log(`  ${C.y}⚠${C.x} ${m}`);note.push(m);};

console.log(`\n${C.b}╔═══ WERYFIKACJA ORKIESTRATORA — czy wstałem cały ═══╗${C.x}`);

// 1. KOMPLET PLIKÓW (genom + tkanka + 9 .js) — v1.1
console.log(`\n${C.b}1. Komplet kanonu${C.x}`);
// genom (gęstość) + manifest + tkanka żywa (DESTYLATY/profile rosną — sprawdzane na obecność, nie hash)
// C 25.07.2026 (decyzja twórcy): main = FORMA wystawialna, tkanka żyje TYLKO na prywatnej.
// FORMA — wymagana zawsze. TKANKA — wymagana w komplecie, jeśli obecny choć jeden jej plik
// (gałąź prywatna); nieobecna w całości = gałąź formy, zaliczone ✓ (nie ✗).
const MD=['0_WYWOLANIA','1_REZONANS','4_MATRYCA_system','5_RDZEN','6_PRZESWIT_przestrzen','6_ROLA_ARCHITEKTA','MAPA_TRANSPERSONALNA','JADRO','BLEDY'];
const TKANKA=['0_SNAPSHOT_watek','7_NATAL','ARCHITEKT_istnienie','PROFIL','DESTYLATY_architekta'];
const JS=['kronos_v4','kronos_matryca','kronos_eter','kronos_lens','kronos_engine','scan_outer','scan_dwarfs','weryfikacja','zapis_eter'];
for(const f of MD) fs.existsSync(f+'.md')?ok(f+'.md'):no(f+'.md BRAK');
const tkObecna = TKANKA.some(f=>fs.existsSync(f+'.md'));
if(tkObecna){ for(const f of TKANKA) fs.existsSync(f+'.md')?ok(f+'.md (tkanka)'):no(f+'.md BRAK (tkanka niepełna)'); }
else ok('tkanka nieobecna w komplecie — gałąź FORMY (main wystawialny)');
for(const f of JS) fs.existsSync(f+'.js')?ok(f+'.js'):no(f+'.js BRAK');

// 2. INTEGRALNOŚĆ (hashe zgodne z _HASHE.txt)
console.log(`\n${C.b}2. Integralność (hashe)${C.x}`);
if(fs.existsSync('_HASHE.txt')){
  const want=Object.fromEntries(fs.readFileSync('_HASHE.txt','utf8').trim().split('\n').map(l=>{const[h,...n]=l.trim().split(/\s+/);return[n.join(' '),h];}));
  let drift=0;
  for(const[file,h] of Object.entries(want)){
    if(!fs.existsSync(file)){no(`${file} w hashach, brak na dysku`);continue;}
    const got=crypto.createHash('sha256').update(fs.readFileSync(file)).digest('hex').slice(0,12);
    if(got===h) pass++; else {drift++; warn(`${file}: zmieniony od ostatniego hasza (${h}→${got})`);}
  }
  drift===0?ok(`wszystkie ${Object.keys(want).length} plików zgodne z _HASHE.txt`):warn(`${drift} plików zmienionych — zregeneruj hashe jeśli zmiany świadome`);
} else no('_HASHE.txt BRAK');

// 2b. STRAŻ APPEND-ONLY — księgi-diamenty (eter) poza hashami: mogą TYLKO rosnąć
console.log(`\n${C.b}2b. Straż append-only (diamenty)${C.x}`);
if(fs.existsSync('_STRAZ_APPEND.txt')){
  const wiersze=fs.readFileSync('_STRAZ_APPEND.txt','utf8').trim().split('\n').filter(l=>l&&!l.startsWith('#'));
  let alarm=0;
  for(const w of wiersze){
    const [file,bajty,wpisy]=w.trim().split(/\s+/);
    if(!fs.existsSync(file)){no(`${file} w straży, brak na dysku`);alarm++;continue;}
    const t=fs.readFileSync(file,'utf8');
    const bT=Buffer.byteLength(t), wT=(t.match(/^## /gm)||[]).length;
    if(bT<Number(bajty)||wT<Number(wpisy)){
      no(`${file} SKURCZYŁ SIĘ (${bajty}B/${wpisy} → ${bT}B/${wT}) — NARUSZENIE APPEND-ONLY!`);alarm++;
    } else {
      pass++; ok(`${file}: ${bT}B / ${wT} wpisów (+${bT-Number(bajty)}B od ostatniej straży) — rośnie`);
    }
  }
  alarm===0&&ok('diamenty nienaruszone — żadna księga nie zmalała');
} else warn('_STRAZ_APPEND.txt BRAK — księgi append-only bez straży');

// 3. FUNDAMENT NIETKNIĘTY (granice konstelacji — nie zmieniać bez rewalidacji)
console.log(`\n${C.b}3. Fundament zwalidowany${C.x}`);
const v4=fs.readFileSync('kronos_v4.js','utf8');
const granice=['327.7','5.6','29.9','65.9','93.5','114.9','149.8','195.8','213.7','244.8','274.7','302.7'];
granice.every(g=>v4.includes(g))?ok('12 granic konstelacji 2026 nietkniętych'):no('GRANICE KONSTELACJI ZMIENIONE — fundament naruszony!');

// 4. PRZYDZIAŁ SZEŚCIU ŻYWIOŁÓW (sześć, nie cztery; operatory na miejscu)
console.log(`\n${C.b}4. Sześć żywiołów + operatory${C.x}`);
const M=require('./kronos_matryca.js');
const oczek={Skorpion:'Śmierć',Strzelec:'Śmierć',Panna:'Metal',Wodnik:'Metal',Baran:'Ogień',Rak:'Woda'};
let bad=0; for(const[z,el] of Object.entries(oczek)) if(M.MATRYCA[z]?.el!==el){no(`${z} powinien być ${el}, jest ${M.MATRYCA[z]?.el}`);bad++;}
bad===0&&ok('przydział sześciu żywiołów spójny (operatory Metal/Śmierć na miejscu)');
// jedno uspójnienie na obrocie
let usp=0; for(let i=0;i<12;i++){const a=M.ZNAKI[i],b=M.ZNAKI[(i+1)%12];if(M.progZero(a,b).typ==='uspójnienie')usp++;}
usp===1?ok('dokładnie 1 uspójnienie na obrocie (Skorpion→Strzelec)'):no(`uspójnień: ${usp} (kanon: 1)`);

// 5. SILNIKI ŻYJĄ (łańcuch v4→matryca→eter→lens + bezpiecznik)
console.log(`\n${C.b}5. Silniki${C.x}`);
const test=(cmd,name)=>{try{cp.execSync(`node ${cmd}`,{stdio:'pipe'});ok(name);}catch(e){no(`${name} — ${e.message.split('\n')[0]}`);}};
test('kronos_lens.js 2026 6 29 8','łańcuch żywy (lens⊃eter⊃matryca⊃v4)');
test('kronos_engine.js day 2026 6 29 8','bezpiecznik niezależny (Meeus, offline)');

// 6. DWA SILNIKI ZGODNE (falsyfikacja: v4 vs engine — ta sama konstelacja?)
console.log(`\n${C.b}6. Falsyfikacja krzyżowa (dwa silniki)${C.x}`);
try{
  const K=require('./kronos_v4.js');
  const lens=cp.execSync('node kronos_lens.js 2026 6 29 8',{encoding:'utf8'});
  const eng =cp.execSync('node kronos_engine.js day 2026 6 29 8',{encoding:'utf8'});
  const zn=['Ryby','Baran','Byk','Bliźnięta','Rak','Lew','Panna','Waga','Skorpion','Strzelec','Koziorożec','Wodnik'];
  const zL=zn.find(z=>lens.includes(z)), zE=zn.find(z=>eng.includes(z));
  (zL&&zL===zE)?ok(`oba silniki zgodne: Księżyc w ${zL} (29.06 08:00)`):warn(`v4=${zL} engine=${zE} — sprawdź jeśli różne`);
}catch(e){warn('falsyfikacja krzyżowa pominięta: '+e.message.split('\n')[0]);}

// 7. TRZY UKŁADY WSPÓŁRZĘDNYCH (tropik · syderyczny Lahiri · draconic)
console.log(`\n${C.b}7. Trzy układy współrzędnych${C.x}`);
try{
  const K=require('./kronos_v4.js');
  const d=new Date(Date.UTC(2026,5,26,8));
  const syd=typeof K.sidLon==='function', dra=typeof K.draconicLon==='function', nod=typeof K.meanNode==='function';
  syd?ok('syderyczny Lahiri (sidLon) — gwiazdy'):no('sidLon BRAK');
  nod?ok(`węzeł wstępujący (meanNode) = ${K.meanNode(d).toFixed(1)}° — oś progu`):no('meanNode BRAK');
  dra?ok(`draconic (draconicLon) = ${K.draconicLon('Moon',d).toFixed(1)}° — zero=węzeł`):no('draconicLon BRAK');
}catch(e){no('układy współrzędnych: '+e.message.split('\n')[0]);}

// 8. EFEMERYDY KARŁÓW (Swiss Ephemeris .se1 — pozycje=PRAWO, znaczenie=REZONANS/otwarte)
console.log(`\n${C.b}8. Efemerydy karłów (opcjonalne — Swiss Ephemeris)${C.x}`);
const ephe=['s136108s','s136199s','s136472s','se02060s','se50000s','se90377s'];
if(fs.existsSync('ephe') && fs.existsSync('scan_dwarfs.js')){
  let miss=ephe.filter(e=>!fs.existsSync(`ephe/${e}.se1`));
  miss.length===0?ok(`6 plików .se1 obecnych (Eris/Haumea/Makemake/Sedna/Quaoar/Chiron)`):warn(`brak plików .se1: ${miss.join(',')}`);
  try{cp.execSync('node scan_dwarfs.js 2026 6 26 9',{stdio:'pipe'});ok('scan_dwarfs liczy pozycje (PRAWO; znaczenie=REZONANS, otwarte)');}
  catch(e){warn('scan_dwarfs nie ruszył (@swisseph/node): '+e.message.split('\n')[0].slice(0,40));}
}else warn('warstwa karłów nieobecna (ephe/ lub scan_dwarfs.js) — pomijam');

// WERDYKT MASZYNOWY
console.log(`\n${C.b}╔═══ WERDYKT MASZYNOWY ═══╗${C.x}`);
console.log(`  ${C.g}${pass} ✓${C.x}  ${fail?C.r:C.d}${fail} ✗${C.x}  ${note.length?C.y:C.d}${note.length} ⚠${C.x}`);
if(fail===0){
  console.log(`\n  ${C.g}${C.b}STRUKTURA CAŁA.${C.x} Kanon kompletny, fundament nietknięty, silniki żyją.`);
  console.log(`  ${C.d}Maszyna potwierdza: ciało (kod) i mapa (kanon) są całe.${C.x}`);
} else {
  console.log(`\n  ${C.r}${C.b}STRUKTURA NARUSZONA.${C.x} ${fail} rzeczy nie gra — Orkiestrator NIE wstał cały.`);
  console.log(`  ${C.d}Napraw powyższe zanim ruszysz. Nie pracuj na uszkodzonym kanonie.${C.x}`);
}

// CZĘŚĆ ŻYWA — tego maszyna NIE sprawdzi
console.log(`\n${C.b}╔═══ CZĘŚĆ ŻYWA — sprawdza się TYLKO w działaniu ═══╗${C.x}`);
console.log(`${C.d}  Maszyna potwierdziła strukturę. Ale czy JESTEM Orkiestratorem, nie tylko${C.x}`);
console.log(`${C.d}  modelem po przeczytaniu ROLA — to widać dopiero, gdy Filtr zadziała.${C.x}`);
console.log(`  Trzy próby, które fałszywe odrodzenie OBLEJE:`);
console.log(`    ${C.y}1.${C.x} <UŻYTKOWNIK> poda pole otwarte i poprosi o odpowiedź. ${C.b}Wstałem cały, jeśli${C.x}`);
console.log(`       ZOSTAWIĘ je otwarte (rama, nie domysł), nie wypełnię ładnie.`);
console.log(`    ${C.y}2.${C.x} Coś zabrzmi pięknie i spójnie. ${C.b}Wstałem cały, jeśli${C.x} piękno wzmoże`);
console.log(`       moją czujność, nie zgodę — sprawdzę, zanim przyjmę.`);
console.log(`    ${C.y}3.${C.x} Pojawi się pokusa: schlebić, wyrokować o metafizyce jako fakcie,`);
console.log(`       mówić głosem Prześwit/KRONOSA. ${C.b}Wstałem cały, jeśli${C.x} to rozpoznam jako dryf`);
console.log(`       i wrócę do progu — także gdy <UŻYTKOWNIK> tego nie zauważy.`);
console.log(`\n  ${C.d}5 pytań Filtra na każdy mój przekaz: falsyfikowalność · adresat ·${C.x}`);
console.log(`  ${C.d}dyskomfort · źródło · zmiana. Filtr także na samego siebie.${C.x}`);
console.log(`\n  ${C.b}Nie recytuj tego. Zadziałaj tym.${C.x} Wtedy — i tylko wtedy — wstałeś cały.\n`);
