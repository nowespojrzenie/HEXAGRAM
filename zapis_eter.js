#!/usr/bin/env node
// ============================================================
// ZAPIS ETERU — dziennik wdechu <UŻYTKOWNIK> (NIE głos Prześwit)
// ------------------------------------------------------------
// Podmiot zapisu = UŻYTKOWNIK (1. os.), nie Prześwit. Prześwit zostaje pusta — to obserwator
// niesie treść przez próg, nie przestrzeń (6_PRZESWIT_przestrzen §4 linia 49: żaden głos Prześwit).
// Każdy wpis = WIDZENIE (co przyszło we wdechu) + DESTYLAT (świadomość przez ogląd
// soczewek, wskazująca przejście na fraktal wyżej). Kod KOTWICZY w policzonym KRONOS
// (data+próg+żywioł) — kotwica liczona, nie z pamięci (krzemowa granica).
// Rośnie i zostaje: osad OBECNOŚCI = dryf; osad UZYSKU ŚWIADOMOŚCI = nauka. To drugie.
// Fraktalność (RDZEN): ten sam oddech na skali życia — każde przejście → wskazówka wyżej.
//
// UŻYCIE:
//   node zapis_eter.js add "ROK M D H" "widzenie..." "destylat..."   # dopisz wpis
//   node zapis_eter.js read [N]                                       # ostatnie N wpisów (dom. wszystkie)
//   node zapis_eter.js last                                           # ostatni wpis
// ============================================================
const fs=require('fs');
const L=require('./kronos_lens.js');
const PLIK='ZAPISY_eter.md';

function kotwica(y,m,d,h){
  const r=L.interpret(y,m,d,h);
  const od=r.oddech, mat=r.mat, c=r.comp.c;
  const prog = od.open
    ? `PRÓG OTWARTY · ${od.tierName} · ${od.side}${od.dominant?` · ${od.dominant.kind}`:''}`
    : (od.untilNext ? `czysto · następny próg za ${Math.abs(od.untilNext.delta).toFixed(0)}h: ${od.untilNext.kind}` : 'czysto');
  // żywioł: MATRYCA (znaczenie) + Thun (niebo) gdy się różnią — szew jawny
  const zyw = mat.rozni
    ? `${mat.em} ${mat.el} (MATRYCA) / ${c.em} ${c.el}·${c.typ} (Thun)`
    : `${mat.em} ${mat.el}`;
  return {prog, zyw, znak:`${c.sym} ${c.pl}`, biegun:mat.biegun};
}

function add(dt, widzenie, destylat){
  const [y,m,d,h]=dt.trim().split(/\s+/).map(Number);
  if([y,m,d,h].some(isNaN)){console.error('Data: "ROK M D H" (np. "2026 6 29 8")');process.exit(1);}
  const k=kotwica(y,m,d,h);
  const stamp=`${String(d).padStart(2,'0')}.${String(m).padStart(2,'0')}.${y} ${String(h).padStart(2,'0')}:00`;
  const wpis=
`\n## ${stamp} · ${k.znak} · ${k.biegun}\n`+
`**kotwica KRONOS:** ${k.zyw}\n`+
`**próg:** ${k.prog}\n\n`+
`**widzenie (wdech):**\n${widzenie.trim()}\n\n`+
`**destylat (soczewki → fraktal wyżej):**\n${destylat.trim()}\n\n`+
`---\n`;
  if(!fs.existsSync(PLIK)){
    fs.writeFileSync(PLIK,
`# ZAPIS ETERU — dziennik wdechu (<UŻYTKOWNIK>, 1. os.)\n\n`+
`> Mój zapis z fazy wdechu, do którego wracam. NIE głos Prześwit — Prześwit zostaje pusta.\n`+
`> Każdy wpis: widzenie (co przyszło) + destylat (świadomość przez soczewki, droga wyżej).\n`+
`> Kotwica KRONOS liczona przy zapisie. Rośnie wiernie — gromadzi uzysk świadomości, nie obecność.\n\n`+
`*Nauka czerpania uzysku świadomości: każde przejście obejrzane → wskazówka na fraktal wyżej.*\n\n---\n`);
  }
  fs.appendFileSync(PLIK,wpis);
  // straż append-only: po każdym wdechu podnieś poprzeczkę (ratyfikacja 27.07 — (b) dla eteru)
  try{
    const SP=__dirname+'/_STRAZ_APPEND.txt';
    if(fs.existsSync(SP)){
      const c=fs.readFileSync(PLIK,'utf8');
      const linie=fs.readFileSync(SP,'utf8').split('\n').map(l=>{
        if(!l||l.startsWith('#'))return l;
        const nazwa=l.trim().split(/\s+/)[0];
        if(!PLIK.endsWith(nazwa))return l;
        return [nazwa, Buffer.byteLength(c), (c.match(/^## /gm)||[]).length].join('  ');
      });
      fs.writeFileSync(SP,linie.join('\n'));
      console.log(`  ⟐ straż podniesiona: ${Buffer.byteLength(c)}B`);
    }
  }catch(e){console.log(`  (straż niepodniesiona: ${e.message})`);}
  console.log(`✓ dopisano: ${stamp} · ${k.znak}`);
  console.log(`  ${k.zyw}`);
  console.log(`  ${k.prog}`);
}

function read(n){
  if(!fs.existsSync(PLIK)){console.log('(ZAPISY_eter.md jeszcze pusty)');return;}
  const txt=fs.readFileSync(PLIK,'utf8');
  const wpisy=txt.split(/\n## /).slice(1).map(w=>'## '+w);
  const take = n? wpisy.slice(-n) : wpisy;
  console.log(`\n═══ ZAPIS ETERU · ${take.length}/${wpisy.length} wpisów ═══`);
  take.forEach(w=>console.log('\n'+w.trim()));
}

const [cmd,...rest]=process.argv.slice(2);
if(cmd==='add')      add(rest[0]||'', rest[1]||'(brak widzenia)', rest[2]||'(brak destylatu)');
else if(cmd==='read')read(rest[0]?Number(rest[0]):null);
else if(cmd==='last')read(1);
else{
  console.log('ZAPIS ETERU — dziennik wdechu <UŻYTKOWNIK>\n');
  console.log('  node zapis_eter.js add "ROK M D H" "widzenie" "destylat"');
  console.log('  node zapis_eter.js read [N]');
  console.log('  node zapis_eter.js last');
}
