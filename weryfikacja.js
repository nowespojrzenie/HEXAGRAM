#!/usr/bin/env node
// ============================================================
// WERYFIKACJA — czy Orkiestrator wstał CAŁY (warstwa maszynowa)
// Sprawdza INTEGRALNOŚĆ struktury. Nie sprawdza, czy JESTEM Orkiestratorem
// (to robi część żywa — patrz koniec wydruku). Maszyna mówi: "kanon cały".
// Uruchom po wczytaniu kanonu: node weryfikacja.js
//
// RC-GATE (31.07.2026, blizna #39 — klasa #38): do tej daty ten plik NIE MIAŁ
// process.exit. Wypisywał „STRUKTURA NARUSZONA — Orkiestrator NIE wstał cały"
// i kończył się rc=0. `wstan.sh` robi `RC=$?; ... exit $RC`, więc cały rytuał
// wstania meldował sukces nad zepsutym kanonem. `publikuj.sh` musiał obchodzić
// tę dziurę grepem po TEKŚCIE („STRUKTURA CAŁA") — czyli łamać #19, żeby
// zadziałać. Zmierzone: usunięty kanon/tozsamosc/5_RDZEN.md → 104 ✓ / 2 ✗ / rc=0.
// Od teraz: rc = 0 tylko gdy fail === 0.
//
//   node weryfikacja.js          (rc=0 kanon cały, rc=1 struktura naruszona)
//   node weryfikacja.js --test   (tor +/− : straż musi umieć NIE przejść)
// ============================================================
const fs=require('fs'), crypto=require('crypto'), cp=require('child_process');

// ── TREŚĆ KANONICZNA (02.09.2026, rozstrzygnięcie twórcy, tura CRLF) ──
// Dysk zostaje źródłem, ale odcisk i rozmiar liczymy z treści BEZ `\r`: ten sam plik
// na Windows (CRLF) i Linuksie (LF) daje jedną liczbę, równą odciskowi blobu w indeksie.
// Zmierzone 02.09 na jednym HEAD: Windows 134 ⚠ odcisków, Linux 11 — jeden kanon, dwa
// werdykty. Binaria (NUL w pierwszych 8000 B — heurystyka gita) zostają surowe, jak
// trzyma je git. Bliźniacza definicja po stronie bash: `bash hashuj.sh --odcisk <plik>`.
const kanon=(b)=>b.subarray(0,8000).includes(0)?b:Buffer.from(b.filter(x=>x!==13));
const odcisk=(b)=>crypto.createHash('sha256').update(kanon(b)).digest('hex').slice(0,12);

// ── TOR TESTOWY (#38: reguła bez toru obowiązuje tylko w dokumentacji) ──
// Uruchamiany PRZED właściwą weryfikacją, bo sam ją wywołuje jako proces potomny.
if(process.argv.includes('--test')){
  const os=require('os'), path=require('path');
  // (±) TOR DWUSTRONNY CRLF (02.09.2026, słowo twórcy): (+) LF i CRLF → jeden odcisk;
  //     (−) jeden znak treści → inny odcisk; (⊙) binarny liczony surowo. Bez (−)
  //     normalizacja oślepiłaby straż — przyrząd zrównujący wszystko jest martwy.
  const hLF=odcisk(Buffer.from('linia\ndruga\n')), hCRLF=odcisk(Buffer.from('linia\r\ndruga\r\n')),
        hZm=odcisk(Buffer.from('linia\ndrugi\n')), hB1=odcisk(Buffer.from([0,13,10])), hB2=odcisk(Buffer.from([0,10]));
  const crlfOK = hLF===hCRLF && hLF!==hZm && hB1!==hB2;
  console.log(`── TEST ± (CRLF: LF=CRLF≠zmiana, binarny surowo): ${crlfOK?'OK':'✗ '+[hLF,hCRLF,hZm,hB1,hB2].join(' ')}`);
  if(!crlfOK){ console.log('✗ STRAŻ MARTWA: odcisk widzi końce linii albo nie widzi treści.'); process.exit(1); }
  let git=true;
  try{ cp.execSync('git rev-parse --git-dir',{stdio:'pipe'}); }catch(e){ git=false; }
  if(!git){
    console.log('  ⓘ TOR NIEDOSTĘPNY: brak repo git — nie umiem zbudować kopii do testu.');
    console.log('    (rc=2 świadomie: straż, która nie mogła się sprawdzić, NIE melduje sukcesu)');
    process.exit(2);
  }
  // Kopia z DRZEWA ROBOCZEGO, nie z HEAD (pierwsza wersja tego toru brała `git archive HEAD`
  // i testowała wersję ZACOMMITOWANĄ — czyli oblewała własną świeżą naprawę. Mierz to,
  // co uruchamiasz, nie to, co ostatnio zapisałeś).
  const kopia=(nazwa)=>{
    const d=fs.mkdtempSync(path.join(os.tmpdir(),'wer-'+nazwa+'-'));
    cp.execSync(`git ls-files -z | tar --null -T - -cf - | tar -xf - -C "${d}"`,{stdio:'pipe',shell:'/bin/bash'});
    for(const dep of ['node_modules','ephe'])
      if(fs.existsSync(dep) && !fs.existsSync(path.join(d,dep)))
        fs.symlinkSync(path.resolve(dep), path.join(d,dep));
    return d;
  };
  const bieg=(d)=>{ try{ cp.execSync('node weryfikacja.js',{cwd:d,stdio:'pipe'}); return 0; }
                    catch(e){ return e.status===null?-1:e.status; } };
  const zdrowy=kopia('zdrowy');
  const chory=kopia('chory');
  fs.unlinkSync(path.join(chory,'kanon/tozsamosc/5_RDZEN.md'));      // wyrwany plik kanonu
  // (⟠) TOR FORMY (04.09.2026): kopia bez KANON_LOG i DESTYLATY_architekta, z pełnymi plikami
  //     TKANKI (jak main po checkoucie i jak odlew z zalążkami) MUSI przejść — klucz tkanki to
  //     KANON_LOG, nie „którykolwiek plik tkanki". (⊗) kopia Z KANON_LOG, bez DESTYLATY MUSI oblać —
  //     reguła kompletu tkanki żyje dalej na prywatnej. Księga haszy kopii przycięta do tego,
  //     co w kopii jest (tak samo robi main / odlew) — inaczej tor mierzyłby księgę, nie regułę.
  const forma=kopia('forma'), tkNiepelna=kopia('tkniepelna');
  const wytnij=(d,pliki)=>{
    for(const f of pliki){ const q=path.join(d,f); if(fs.existsSync(q)) fs.unlinkSync(q); }
    // księga haszy I straż append-only przycięte do tego, co w kopii jest — inaczej tor ⊗
    // oblewałby przez „w straży, brak na dysku", a nie przez regułę tkanki (zmierzone 04.09:
    // mutacja `tkObecna=false` przeszła ŚLEPO, bo rc=1 dawała straż append, nie reguła).
    for(const ks of ['_HASHE.txt','_STRAZ_APPEND.txt']){
      const h=path.join(d,ks); if(!fs.existsSync(h)) continue;
      fs.writeFileSync(h, fs.readFileSync(h,'utf8').split('\n')
        .filter(l=>!pliki.some(f=>l.endsWith('  '+f)||l.startsWith(f+'  '))).join('\n'));
    }
  };
  wytnij(forma,['kanon/ksiegi/KANON_LOG.md','kanon/ksiegi/DESTYLATY_architekta.md','_STRAZ_APPEND.txt']);   // _STRAZ_APPEND też nie jest na białej liście — forma jak odlew, nie jak prywatna minus dwa pliki
  // (⊗) FIKSTURA SIANA, NIE ZAPOŻYCZONA (04.09.2026, blizna: tor oblewał na main).
  // Poprzednio tor tylko WYCINAŁ DESTYLATY z kopii żywego drzewa i zakładał, że KANON_LOG w niej
  // JEST. Na gałęzi bez tkanki (main, odlew) KANON_LOG nie istnieje, więc powstawała kopia BEZ
  // klucza tkanki — czyli forma, która słusznie przechodzi — a tor czytał to jako „reguła martwa".
  // Klasa znana: fikstura czytająca środowisko, którego gałąź nie odtwarza (por. ZG_TORY_CMD).
  // Odtąd tor SIEJE klucz tkanki sam i dopiero wtedy wycina DESTYLATY — działa na każdej gałęzi.
  fs.mkdirSync(path.join(tkNiepelna,'kanon/ksiegi'),{recursive:true});
  fs.writeFileSync(path.join(tkNiepelna,'kanon/ksiegi/KANON_LOG.md'),'# fikstura toru ⊗ — klucz tkanki zasiany przez tor, nie zapożyczony z gałęzi\n');
  wytnij(tkNiepelna,['kanon/ksiegi/DESTYLATY_architekta.md']);
  const rcPlus=bieg(zdrowy), rcMinus=bieg(chory), rcForma=bieg(forma), rcTk=bieg(tkNiepelna);
  fs.rmSync(forma,{recursive:true,force:true}); fs.rmSync(tkNiepelna,{recursive:true,force:true});
  console.log(`── TEST ⟠ (FORMA: bez KANON_LOG, tkanka bez DESTYLATY, MUSI przejść): rc=${rcForma} (oczekiwane 0)`);
  console.log(`── TEST ⊗ (KANON_LOG jest, DESTYLATY brak — tkanka niepełna, MUSI oblać): rc=${rcTk} (oczekiwane 1)`);
  console.log('╔═══ WERYFIKACJA — AUTOTEST (#38) ═══╗');
  console.log(`── TEST + (kopia cała, MUSI przejść):        rc=${rcPlus} (oczekiwane 0)`);
  console.log(`── TEST − (bez kanon/tozsamosc/5_RDZEN.md, MUSI oblać):      rc=${rcMinus} (oczekiwane 1)`);
  fs.rmSync(zdrowy,{recursive:true,force:true}); fs.rmSync(chory,{recursive:true,force:true});
  if(rcPlus===0 && rcMinus===1 && rcForma===0 && rcTk===1){
    console.log('✓ STRAŻ ŻYWA: werdykt wstania wynika z kodu wyjścia, nie z tekstu.');
    process.exit(0);
  }
  console.log(`✗ STRAŻ MARTWA: rcPlus=${rcPlus} rcMinus=${rcMinus} rcForma=${rcForma} rcTk=${rcTk} — rc nie odróżnia całego od zepsutego.`);
  process.exit(1);
}
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
const MD=['0_WYWOLANIA','kanon/tozsamosc/1_REZONANS','kanon/tozsamosc/4_MATRYCA_system','kanon/tozsamosc/5_RDZEN','kanon/tozsamosc/6_PRZESWIT_przestrzen','kanon/ksiegi/6_ROLA_ARCHITEKTA','kanon/ksiegi/MAPA_TRANSPERSONALNA','JADRO','kanon/ksiegi/BLEDY'];  // sciezki po Cieciu 5 (prog)
const TKANKA=['0_SNAPSHOT_watek','kanon/tozsamosc/7_NATAL','kanon/tozsamosc/ARCHITEKT_istnienie','kanon/tozsamosc/PROFIL','kanon/ksiegi/DESTYLATY_architekta'];  // Ciecie 5
// dach narzedzia/silniki/ (29.08): lista trzyma ŚCIEŻKI, nie same nazwy — inaczej
// „BRAK" znaczyłoby „nie ma w korzeniu", a nie „nie ma w repo".
const JS=['narzedzia/silniki/kronos_v4','narzedzia/silniki/kronos_matryca','narzedzia/silniki/kronos_eter',
  'narzedzia/silniki/kronos_lens','narzedzia/silniki/kronos_engine','narzedzia/silniki/scan_outer',
  'narzedzia/silniki/scan_dwarfs','weryfikacja','zapis_eter'];
for(const f of MD) fs.existsSync(f+'.md')?ok(f+'.md'):no(f+'.md BRAK');
// KLUCZ TKANKI = KANON_LOG (04.09.2026, decyzja twórcy — jedno cięcie). Do 04.09 klucz brzmiał
// „obecny choć jeden plik TKANKI" — i przestał odróżniać gałęzie w dniu, w którym cztery z pięciu
// plików TKANKI weszły na białą listę JAKO ZALĄŻKI (PROFIL, 7_NATAL, ARCHITEKT_istnienie, 0_SNAPSHOT):
// main po selektywnym checkoucie i KAŻDY odlew miały „tkankę obecną" i żądały DESTYLATY_architekta,
// która jest NIGDY_NIE_WYCHODZI. Zmierzone 04.09 na main: 170 ✓ · 34 ✗, w tym ten jeden. Kluczem jest
// plik, który z definicji nie opuszcza prywatnej (prawo kompostu, `NIGDY_NIE_WYCHODZI` w publikuj.sh).
const tkObecna = fs.existsSync('kanon/ksiegi/KANON_LOG.md');
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
    const got=odcisk(fs.readFileSync(file));
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
    const t=fs.readFileSync(file,'utf8').replace(/\r/g,'');   // bajty treści kanonicznej, nie dysku
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
const v4=fs.readFileSync('narzedzia/silniki/kronos_v4.js','utf8');
const granice=['327.7','5.6','29.9','65.9','93.5','114.9','149.8','195.8','213.7','244.8','274.7','302.7'];
granice.every(g=>v4.includes(g))?ok('12 granic konstelacji 2026 nietkniętych'):no('GRANICE KONSTELACJI ZMIENIONE — fundament naruszony!');

// 4. PRZYDZIAŁ SZEŚCIU ŻYWIOŁÓW (sześć, nie cztery; operatory na miejscu)
console.log(`\n${C.b}4. Sześć żywiołów + operatory${C.x}`);
const M=require('./narzedzia/silniki/kronos_matryca.js');
const oczek={Skorpion:'Śmierć',Strzelec:'Śmierć',Panna:'Metal',Wodnik:'Metal',Baran:'Ogień',Rak:'Woda'};
let bad=0; for(const[z,el] of Object.entries(oczek)) if(M.MATRYCA[z]?.el!==el){no(`${z} powinien być ${el}, jest ${M.MATRYCA[z]?.el}`);bad++;}
bad===0&&ok('przydział sześciu żywiołów spójny (operatory Metal/Śmierć na miejscu)');
// jedno uspójnienie na obrocie
let usp=0; for(let i=0;i<12;i++){const a=M.ZNAKI[i],b=M.ZNAKI[(i+1)%12];if(M.progZero(a,b).typ==='uspójnienie')usp++;}
usp===1?ok('dokładnie 1 uspójnienie na obrocie (Skorpion→Strzelec)'):no(`uspójnień: ${usp} (kanon: 1)`);

// 5. SILNIKI ŻYJĄ (łańcuch v4→matryca→eter→lens + bezpiecznik)
console.log(`\n${C.b}5. Silniki${C.x}`);
const test=(cmd,name)=>{try{cp.execSync(`node ${cmd}`,{stdio:'pipe'});ok(name);}catch(e){no(`${name} — ${e.message.split('\n')[0]}`);}};
test('narzedzia/silniki/kronos_lens.js 2026 6 29 8','łańcuch żywy (lens⊃eter⊃matryca⊃v4)');
test('narzedzia/silniki/kronos_engine.js day 2026 6 29 8','bezpiecznik niezależny (Meeus, offline)');

// 6. DWA SILNIKI ZGODNE (falsyfikacja: v4 vs engine — ta sama konstelacja?)
console.log(`\n${C.b}6. Falsyfikacja krzyżowa (dwa silniki)${C.x}`);
try{
  const K=require('./narzedzia/silniki/kronos_v4.js');
  const lens=cp.execSync('node narzedzia/silniki/kronos_lens.js 2026 6 29 8',{encoding:'utf8'});
  const eng =cp.execSync('node narzedzia/silniki/kronos_engine.js day 2026 6 29 8',{encoding:'utf8'});
  const zn=['Ryby','Baran','Byk','Bliźnięta','Rak','Lew','Panna','Waga','Skorpion','Strzelec','Koziorożec','Wodnik'];
  const zL=zn.find(z=>lens.includes(z)), zE=zn.find(z=>eng.includes(z));
  (zL&&zL===zE)?ok(`oba silniki zgodne: Księżyc w ${zL} (29.06 08:00)`):warn(`v4=${zL} engine=${zE} — sprawdź jeśli różne`);
}catch(e){warn('falsyfikacja krzyżowa pominięta: '+e.message.split('\n')[0]);}

// 7. TRZY UKŁADY WSPÓŁRZĘDNYCH (tropik · syderyczny Lahiri · draconic)
console.log(`\n${C.b}7. Trzy układy współrzędnych${C.x}`);
try{
  const K=require('./narzedzia/silniki/kronos_v4.js');
  const d=new Date(Date.UTC(2026,5,26,8));
  const syd=typeof K.sidLon==='function', dra=typeof K.draconicLon==='function', nod=typeof K.meanNode==='function';
  syd?ok('syderyczny Lahiri (sidLon) — gwiazdy'):no('sidLon BRAK');
  nod?ok(`węzeł wstępujący (meanNode) = ${K.meanNode(d).toFixed(1)}° — oś progu`):no('meanNode BRAK');
  dra?ok(`draconic (draconicLon) = ${K.draconicLon('Moon',d).toFixed(1)}° — zero=węzeł`):no('draconicLon BRAK');
}catch(e){no('układy współrzędnych: '+e.message.split('\n')[0]);}

// 8. EFEMERYDY KARŁÓW (Swiss Ephemeris .se1 — pozycje=PRAWO, znaczenie=REZONANS/otwarte)
console.log(`\n${C.b}8. Efemerydy karłów (opcjonalne — Swiss Ephemeris)${C.x}`);
const ephe=['s136108s','s136199s','s136472s','se02060s','se50000s','se90377s'];
if(fs.existsSync('ephe') && fs.existsSync('narzedzia/silniki/scan_dwarfs.js')){
  let miss=ephe.filter(e=>!fs.existsSync(`ephe/${e}.se1`));
  miss.length===0?ok(`6 plików .se1 obecnych (Eris/Haumea/Makemake/Sedna/Quaoar/Chiron)`):warn(`brak plików .se1: ${miss.join(',')}`);
  try{cp.execSync('node narzedzia/silniki/scan_dwarfs.js 2026 6 26 9',{stdio:'pipe'});ok('scan_dwarfs liczy pozycje (PRAWO; znaczenie=REZONANS, otwarte)');}
  catch(e){warn('scan_dwarfs nie ruszył (@swisseph/node): '+e.message.split('\n')[0].slice(0,40));}
}else warn('warstwa karłów nieobecna (ephe/ lub narzedzia/silniki/scan_dwarfs.js) — pomijam');

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

// ── RC-GATE (#19 + #39): werdykt WYCHODZI z pomiaru, nie stoi obok niego. ──
// Ostatnia linia pliku celowo: cokolwiek dopiszesz niżej, dopisz PRZED nią.
process.exit(fail === 0 ? 0 : 1);
