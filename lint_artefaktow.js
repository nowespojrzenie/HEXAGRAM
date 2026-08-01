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
// ============================================================
const fs = require('fs');
const { execSync } = require('child_process');

// rejestry, które mają prawo twierdzić — tu szukamy
const REJESTRY = [
  'nowespojrzenie/HEXAGRAM_dziennik_projektu.md',
  'ZADANIA.md', 'TASKI.md', 'MOSTY.md', '0_SNAPSHOT_watek.md',
  'DESTYLATY_architekta.md', 'KANON_LOG.md', 'LOG_SESJI.md',
];

// czasowniki twierdzenia o istnieniu (PL)
const TWIERDZI = /(prototyp|istnieje|istnieją|powstał|powstała|powstało|powstały|gotowy|gotowa|gotowe|zapisany|zapisana|zapisane|utworzony|utworzona|leży|znajduje się|mamy plik)/i;
// jawne zwolnienie z obowiązku istnienia w repo
const ZWOLNIENIE = /(POZA REPO|u twórcy|nie w repo|nie ma go w repo|generowany|do pobrania|bez gwarancji istnienia|na dysku twórcy|planowany|do zrobienia|do napisania|kandydat)/i;
// co uznajemy za nazwę artefaktu w backtickach
const NAZWA = /`([A-Za-z0-9_][A-Za-z0-9_./-]*\.(md|js|sh|txt|json|svg|pdf|csv|ai|indd|xlsx|pptx|docx))`|`([A-Z][A-Z0-9_]{3,})`/g;

let sledzone;
try {
  sledzone = new Set(execSync('git ls-files', { encoding: 'utf8' }).trim().split('\n'));
} catch (e) {
  console.log('  ⓘ poza repo git — lint artefaktów pominięty');
  process.exit(0);
}
const bazy = new Set([...sledzone].map(p => p.split('/').pop()));

let zarzuty = [], sprawdzonych = 0;

for (const rej of REJESTRY) {
  if (!fs.existsSync(rej)) continue;
  const linie = fs.readFileSync(rej, 'utf8').split('\n');
  linie.forEach((l, i) => {
    if (!TWIERDZI.test(l)) return;
    if (ZWOLNIENIE.test(l)) return;
    for (const m of l.matchAll(NAZWA)) {
      const naz = m[1] || m[3];
      if (!naz) continue;
      // pomijamy odwołania czysto pojęciowe (WIELKIE bez kropki) jeśli nie wyglądają na plik
      if (!naz.includes('.')) continue;
      sprawdzonych++;
      const jest = sledzone.has(naz) || bazy.has(naz.split('/').pop());
      if (!jest) zarzuty.push(rej + ':' + (i + 1) + ' → twierdzi o `' + naz + '`, którego NIE MA wśród plików śledzonych');
    }
  });
}

console.log('╔═══ LINT ARTEFAKTÓW (prawo #32) ═══╗');
console.log('  rejestrów przeszukanych: ' + REJESTRY.filter(r => fs.existsSync(r)).length +
            ' · twierdzeń sprawdzonych: ' + sprawdzonych);
if (zarzuty.length === 0) {
  console.log('  ✓ KAŻDE TWIERDZENIE MA POKRYCIE — rejestry nie obiecują plików, których nie ma.');
  process.exit(0);
} else {
  for (const z of zarzuty) console.log('  ✗ ' + z);
  console.log('  BEZ POKRYCIA: ' + zarzuty.length + ' — zacommituj plik albo oznacz twierdzenie jako POZA REPO.');
  process.exit(1);
}
