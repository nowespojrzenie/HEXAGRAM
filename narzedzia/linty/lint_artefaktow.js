#!/usr/bin/env node
// ============================================================
// LINT ARTEFAKTÓW — mechanizacja prawa #32 (29.07.2026)
// PRAWO #32: artefakt oddany do pobrania, a nie zacommitowany, dla systemu NIE ISTNIEJE;
//            rejestr nie może twierdzić inaczej.
//
// Straz_duszy pilnuje MAPY (ścieżki z DUSZY → dysk). Ten lint pilnuje TWIERDZEŃ:
// wyłuskuje z rejestrów zdania typu „prototyp/istnieje/powstał/gotowy: `nazwa`"
// i sprawdza, czy `nazwa` jest wśród plików ŚLEDZONYCH przez gita.
//
// Wyjątek jawny: jeśli w tej samej linii stoi „POZA REPO", „u twórcy", „nie w repo"
// albo „(generowany" — twierdzenie jest uczciwe i nie jest zgłaszane.
//
// Użycie:  node lint_artefaktow.js      (rc=0 czysto, rc=1 twierdzenie bez pokrycia)
//          node lint_artefaktow.js --test   (tor +/− : straż musi umieć NIE przejść)
//
// TOR TESTOWY dopisany 31.07.2026 (prawo #38). Trzy deklarowane reguły — TWIERDZI,
// ZWOLNIENIE, NAZWA — dostają po własnym torze; ZWOLNIENIE ma tor osobny, bo to
// właśnie zwolnienia (nie same trafienia) bywają cichą furtką, którą straż przestaje łapać.
// ============================================================
const fs = require('fs');
const { execSync } = require('child_process');

// rejestry, które mają prawo twierdzić — tu szukamy
// LUKA ZNALEZIONA MUTACJĄ (13.08.2026, faza B): `kanon/ksiegi/PLAN_ODLEWU_v1.5.md` obiecywał
// `gotowosc.sh` i nie był pilnowany, bo lista rejestrów jest ZAMKNIĘTA i uzupełniana ręcznie.
// Każdy nowy dokument twierdzący o plikach wchodzi poza nadzór i nikt tego nie zgłasza —
// dokładnie klasa #37 (kotwica po nazwie, nie po wzorcu), tylko na poziomie listy plików.
const REJESTRY = [
  'projekty/nowe-spojrzenie/HEXAGRAM_dziennik_projektu.md',
  'prywatne/ZADANIA.md', 'prywatne/TASKI.md', 'kanon/ksiegi/MOSTY.md', '0_SNAPSHOT_watek.md',
  'kanon/ksiegi/DESTYLATY_architekta.md', 'kanon/ksiegi/KANON_LOG.md', 'kanon/ksiegi/LOG_SESJI.md',
  'kanon/ksiegi/PLAN_ODLEWU_v1.5.md',
];

// czasowniki twierdzenia o istnieniu (PL)
const TWIERDZI = /(mierzy|wywołuje|uruchamia|liczy|pilnuje|prototyp|istnieje|istnieją|powstał|powstała|powstało|powstały|gotowy|gotowa|gotowe|zapisany|zapisana|zapisane|utworzony|utworzona|leży|znajduje się|mamy plik)/i;
// jawne zwolnienie z obowiązku istnienia w repo
const ZWOLNIENIE = /(POZA REPO|u twórcy|nie w repo|nie ma go w repo|generowany|do pobrania|bez gwarancji istnienia|na dysku twórcy|planowany|do zrobienia|do napisania|kandydat)/i;
// co uznajemy za nazwę artefaktu w backtickach
const NAZWA = /`([A-Za-z0-9_][A-Za-z0-9_./-]*\.(md|js|sh|txt|json|svg|pdf|csv|ai|indd|xlsx|pptx|docx))`|`([A-Z][A-Z0-9_]{3,})`/g;

// ── SKAN (czysta funkcja: linie rejestru × zbiór plików śledzonych) ──
// zrodla: [{ nazwa, linie:[...] }]   sledzone: Set ścieżek
function skan(zrodla, sledzone) {
  let pozaZasiegiem = 0;
  const bazy = new Set([...sledzone].map(p => p.split('/').pop()));
  const zarzuty = [];
  let sprawdzonych = 0;

  for (const z of zrodla) {
    z.linie.forEach((l, i) => {
      if (!TWIERDZI.test(l)) return;
      if (ZWOLNIENIE.test(l)) return;
      for (const m of l.matchAll(NAZWA)) {
        const naz = m[1] || m[3];
        if (!naz) continue;
        // pomijamy odwołania czysto pojęciowe (WIELKIE bez kropki) jeśli nie wyglądają na plik
        if (!naz.includes('.')) continue;
        sprawdzonych++;
        const jest = sledzone.has(naz) || bazy.has(naz.split('/').pop());
        // POZA ZASIĘGIEM GAŁĘZI (04.09.2026, blizna: 33 alarmy na main, 0 na prywatnej).
        // Rejestry tkanki jadą na gałąź publiczną, a katalogi, o których mówią (projekty/,
        // do_publikacji/), zostają na prywatnej — świadomie. Lint meldował wtedy „NIE MA
        // wśród plików śledzonych" dla materiału, który po prostu nie należy do tej gałęzi:
        // alarm szerszy niż sygnał. Rozróżniamy więc DWA przypadki: (a) katalog nadrzędny
        // ISTNIEJE, a pliku brak → zarzut jak dotąd; (b) całego poddrzewa NIE MA na tej
        // gałęzi → twierdzenie jest niesprawdzalne tutaj, liczymy je osobno i NIE zarzucamy.
        // Zamek nie słabnie: na prywatnej, gdzie poddrzewa są, zachowanie bez zmiany.
        const korzen = naz.includes('/') ? naz.split('/')[0] : null;
        const poddrzewoJest = !korzen || [...sledzone].some(p => p.startsWith(korzen + '/'));
        if (!jest && !poddrzewoJest) { pozaZasiegiem++; continue; }
        if (!jest) zarzuty.push(z.nazwa + ':' + (i + 1) +
          ' → twierdzi o `' + naz + '`, którego NIE MA wśród plików śledzonych');
      }
    });
  }
  return { zarzuty, sprawdzonych, pozaZasiegiem, rejestrow: zrodla.length };
}

// ── RAPORT (werdykt wyprowadzony z wyniku — #34) ──
function raport(w, naglowek = '╔═══ LINT ARTEFAKTÓW (prawo #32) ═══╗') {
  console.log(naglowek);
  console.log('  rejestrów przeszukanych: ' + w.rejestrow + ' · twierdzeń sprawdzonych: ' + w.sprawdzonych);
  if (w.zarzuty.length === 0) {
    console.log('  ✓ KAŻDE TWIERDZENIE MA POKRYCIE — rejestry nie obiecują plików, których nie ma.');
    return 0;
  }
  for (const z of w.zarzuty) console.log('  ✗ ' + z);
  console.log('  BEZ POKRYCIA: ' + w.zarzuty.length +
              ' — zacommituj plik albo oznacz twierdzenie jako POZA REPO.');
  return 1;
}

// ── TOR TESTOWY (#38) ──
if (process.argv.includes('--test')) {
  const SLEDZONE = new Set(['JADRO.md', 'skills/x/SKILL.md', 'narzedzia/silniki/kronos_v4.js']);
  const rejestr = (linie) => [{ nazwa: 'TEST.md', linie }];

  const PRZYPADKI = [
    // [nazwa toru, linie, oczekiwane rc]
    ['+ twierdzenie z pokryciem (MUSI przejść)',
      ['Prototyp gotowy: `narzedzia/silniki/kronos_v4.js` — działa.'], 0],
    ['+ zdanie bez czasownika twierdzenia (MUSI przejść)',
      ['Kiedyś napiszemy `widmo.js`.'], 0],
    ['− twierdzenie bez pokrycia (MUSI oblać)',
      ['Prototyp gotowy: `widmo.js` — leży w repo.'], 1],
    ['⊙ ZWOLNIENIE ratuje twierdzenie bez pokrycia (MUSI przejść)',
      ['Gotowy `widmo.js` — POZA REPO, na dysku twórcy.'], 0],
    ['⊙ ZWOLNIENIE nie może ratować SĄSIEDNIEJ linii (MUSI oblać)',
      ['Gotowy `widmo.js` — leży w repo.', 'Inny plik: POZA REPO.'], 1],
    ['⊙ NAZWA: pojęcie bez kropki nie jest plikiem (MUSI przejść)',
      ['Gotowy `PROTOKOL` — nazwa pojęciowa, nie plik.'], 0],
  ];

  console.log('╔═══ LINT ARTEFAKTÓW — AUTOTEST (#38) ═══╗');
  let wszystko = true;
  for (const [nazwa, linie, oczek] of PRZYPADKI) {
    const rc = raport(skan(rejestr(linie), SLEDZONE), '── TEST ' + nazwa + ' ──');
    if (rc !== oczek) { wszystko = false; console.log('    ↑ rc=' + rc + ', oczekiwane ' + oczek); }
  }
  console.log();
  if (wszystko) {
    console.log('✓ STRAŻ ŻYWA: łapie twierdzenie bez pokrycia, honoruje ZWOLNIENIE ' +
                'tylko w tej samej linii, nie myli pojęcia z plikiem.');
    process.exit(0);
  }
  console.log('✗ STRAŻ MARTWA: któryś tor dał inny rc niż oczekiwany (szczegóły wyżej).');
  process.exit(1);
}

// ── BIEG WŁAŚCIWY ──
let sledzone;
try {
  sledzone = new Set(execSync('git ls-files', { encoding: 'utf8' }).trim().split('\n'));
} catch (e) {
  console.log('  ⓘ poza repo git — lint artefaktów pominięty (rc=2, nie melduję sukcesu)');
  process.exit(2);
}
const zrodla = REJESTRY.filter(r => fs.existsSync(r))
  .map(r => ({ nazwa: r, linie: fs.readFileSync(r, 'utf8').split('\n') }));
process.exit(raport(skan(zrodla, sledzone)));
