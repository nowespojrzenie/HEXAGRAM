// ═══ tz_pl.js — JEDNO ŹRÓDŁO PRAWDY o czasie lokalnym PL ═══
//
// RODOWÓD (13.08.2026): warstwa wejścia (godzina twórcy → instant) żyła w SZEŚCIU
// kopiach o TRZECH różnych ziarnach czasowych. Dwie z nich — kronos_v4 i kronos_engine —
// dzieliły ziarno DOBOWE, czyli ten sam błąd. Falsyfikacja krzyżowa była tu ślepa
// Z ZAŁOŻENIA: dwa silniki nie są dwoma świadkami, gdy powielają jedną pomyłkę.
// Zmierzony skutek: 25.10.2026 12:00 PL → 35,4 arcmin na longitudzie Księżyca,
// przy własnej tolerancji projektu 10 arcmin. Do tego siódma kopia w scan_dwarfs
// (stała -2, czyli CEST przez cały rok) i klasa `h||12` zjadająca północ.
//
// PRAWO TEGO MODUŁU: ziarno jest MILISEKUNDOWE. Offset zależy od INSTANTU,
// nie od doby ani od godziny. Każda inna granulacja to błąd czekający na kalendarz.
//
// ZAKRES: reguła UE obowiązuje od 1996 (ostatnia niedziela marca / października,
// przełączenie o 01:00 UTC). Dla dat < 1996 moduł NIE jest prawem — patrz `poza_zakresem`.
//
// DRUGI ŚWIADEK: tory w testy_rdzen.js porównują ten moduł z Intl/tzdata —
// przyrządem spoza naszej ręki. Narzędzie własnej roboty nie jest świadkiem
// własnej poprawności (blizna #46→#47).

'use strict';

const ROK_REGULY_UE = 1996;

// ═══ STREFA INSTANCJI (07.10.2026, projekt `SZKIC_strefa_0710.md`; słowo twórcy 12:19 „Czas twórcy zrobiłbym w tym cyklu.”) ═══
// Pierwszeństwo: zmienna `KRONOS_TZ` > pole `strefa` w `instancja.json` (korzeń repo, czytany względem POŁOŻENIA TEGO PLIKU, nie `cwd`)
// > pole `kronos.strefa` w `package.json` (domyślna rdzenia) > stała 'Europe/Warsaw'. `instancja.json` nieobecny = w porządku;
// obecny, ale nieparsowalny albo z nieznaną strefą → BŁĄD (silniki kończą rc=2), nigdy cichy powrót do Warszawy.
// Gałąź Warszawy poniżej to dzisiejszy kod DOSŁOWNIE; obca strefa idzie osobną gałęzią (tzdata). Faza 1: tylko offset pełnogodzinny.
const fs = require('fs');
const path = require('path');
const KORZEN = path.join(__dirname, '..', '..');

function czytajStrefe() {
  const env = process.env.KRONOS_TZ;
  let nazwa = null;
  if (env && String(env).trim() !== '') nazwa = String(env).trim();
  if (nazwa === null) {
    const plikInstancji = path.join(KORZEN, 'instancja.json');
    if (fs.existsSync(plikInstancji)) {
      let j;
      try { j = JSON.parse(fs.readFileSync(plikInstancji, 'utf8')); }
      catch (e) { throw new Error('instancja.json nieparsowalny: ' + e.message); }
      if (j && j.strefa !== undefined && j.strefa !== null) {
        if (typeof j.strefa !== 'string' || j.strefa.trim() === '') throw new Error('instancja.json: pole "strefa" musi być niepustym napisem (nazwa IANA)');
        nazwa = j.strefa.trim();
      }
    }
  }
  if (nazwa === null) {
    const plikPkg = path.join(KORZEN, 'package.json');
    try {
      const k = JSON.parse(fs.readFileSync(plikPkg, 'utf8')).kronos;
      if (k && typeof k.strefa === 'string' && k.strefa.trim() !== '') nazwa = k.strefa.trim();
    } catch (e) { /* package.json nieobecny albo bez pola: bierze stałą */ }
  }
  if (nazwa === null) nazwa = 'Europe/Warsaw';
  if (nazwa !== 'Europe/Warsaw' && nazwa !== 'UTC') {          // walidacja nazwy: lista z Intl + jawnie dopuszczone UTC
    // Lista Intl zawiera nazwy KANONICZNE ICU (np. Asia/Calcutta, nie Asia/Kolkata) — alias, który Intl przyjmuje, jest nazwą IANA i nie jest „nieznany”.
    const lista = typeof Intl.supportedValuesOf === 'function' ? Intl.supportedValuesOf('timeZone') : null;
    const aliasIntl = n => { try { new Intl.DateTimeFormat('en', { timeZone: n }); return true; } catch (e) { return false; } };
    if (!((lista && lista.includes(nazwa)) || aliasIntl(nazwa))) throw new Error('nieznana strefa czasu: "' + nazwa + '" (oczekiwana nazwa IANA, np. Europe/Warsaw albo America/New_York)');
    // NAZWA KANONICZNA (U1-14a, 08.10.2026): Intl przyjmuje wielkość liter i aliasy (`europe/warsaw`, `Poland`), ale OBCA = STREFA !== 'Europe/Warsaw'
    // porównuje napis — bez tego kroku `europe/warsaw` szło gałęzią obcej strefy (etykieta „UTC+2” zamiast „CEST”). Wynik zna ICU, nie my.
    nazwa = new Intl.DateTimeFormat('en', { timeZone: nazwa }).resolvedOptions().timeZone;
  }
  return nazwa;
}

let STREFA;
try { STREFA = czytajStrefe(); }
catch (e) { console.error('✗ tz_pl.js: ' + e.message); process.exit(2); }
const OBCA = STREFA !== 'Europe/Warsaw';
const ETYKIETA = OBCA ? STREFA : 'PL';   // napis „czas lokalny” w wyjściach silników: Warszawa = „PL” (bez zmian), obca strefa = jej nazwa

// Ostatnia niedziela miesiąca m0 (0-indeks: 2=marzec, 9=październik) w roku y.
function lastSundayUTC(y, m0) {
  const d = new Date(Date.UTC(y, m0 + 1, 0));
  return d.getUTCDate() - d.getUTCDay();
}

// Instanty przełączeń dla roku y (ms UTC). Przełączenie o 01:00 UTC.
function granice(y) {
  return {
    lato: Date.UTC(y, 2, lastSundayUTC(y, 2), 1),   // CET → CEST
    zima: Date.UTC(y, 9, lastSundayUTC(y, 9), 1),   // CEST → CET
  };
}

// Czy data leży poza zakresem, w którym ten moduł jest PRAWEM.
function pozaZakresem(y) {
  if (OBCA) return false;                     // obca strefa: tzdata obejmuje każdy rok, reguła UE nie jest tu prawem
  return y < ROK_REGULY_UE;
}

// ── RDZEŃ: offset dla INSTANTU (ms UTC lub Date) → 1 (CET) albo 2 (CEST) ──
function offAt(msOrDate) {
  if (OBCA) return offTzdataAt(msOrDate instanceof Date ? msOrDate.getTime() : msOrDate);
  const ms = msOrDate instanceof Date ? msOrDate.getTime() : msOrDate;
  const y = new Date(ms).getUTCFullYear();
  const g = granice(y);
  return (ms >= g.lato && ms < g.zima) ? 2 : 1;
}

// ── Godzina LOKALNA → instant UTC (ms) ──
// Algorytm dwóch prób: sprawdź, który offset jest samospójny.
// KONWENCJE dla dwóch godzin patologicznych w roku:
//   • marzec, 02:00–02:59 lokalnie NIE ISTNIEJE  → przesuwamy do przodu (wynik: 03:00 CEST)
//   • październik, 02:00–02:59 lokalnie JEST DWA RAZY → bierzemy PIERWSZE wystąpienie (CEST)
// Obie zgodne z zachowaniem tzdata/ICU dla trybu „earlier".
function localToUTC(y, m, d, h, min) {
  if (OBCA) return localToUTCObca(y, m, d, h, min);
  const hh = godzWejscia(h);
  const mm = Number.isFinite(min) ? min : 0;
  const naiwny = Date.UTC(y, m - 1, d, hh, mm);
  for (const off of [2, 1]) {                 // CEST najpierw → „earlier" przy dwuznaczności
    const kandydat = naiwny - off * 3600000;
    if (offAt(kandydat) === off) return kandydat;
  }
  return naiwny - 1 * 3600000;                // godzina nieistniejąca → skok do przodu
}

function localDate(y, m, d, h, min) { return new Date(localToUTC(y, m, d, h, min)); }

// Offset obowiązujący dla podanej godziny LOKALNEJ (nie dla doby!).
function offLocal(y, m, d, h) { return offAt(localToUTC(y, m, d, h)); }

// ── Offset ze strefy Europe/Warsaw (tzdata) dla INSTANTU — świadek dla lat < 1996 ──
// Rzuca, gdy Node nie ma danych strefy albo offset nie jest całą godziną: cichy wynik
// dla daty historycznej to ta sama klasa błędu, co #46 (zegar skłamał bez ostrzeżenia).
function offTzdataAt(ms) {
  let p;
  try {
    p = new Intl.DateTimeFormat('en-GB', {
      timeZone: STREFA, hourCycle: 'h23',
      year: 'numeric', month: 'numeric', day: 'numeric', hour: 'numeric', minute: 'numeric',
    }).formatToParts(ms).reduce((o, x) => { o[x.type] = x.value; return o; }, {});
  } catch (e) {
    throw new Error('brak danych tzdata ' + STREFA + ' w tym Node: ' + e.message);
  }
  const lokalnyJakUTC = Date.UTC(+p.year, +p.month - 1, +p.day, +p.hour, +p.minute);
  const off = (lokalnyJakUTC - Math.floor(ms / 60000) * 60000) / 3600000;
  if (OBCA && Number.isFinite(off) && off !== Math.round(off)) {
    throw new Error('strefa ' + STREFA + ': offset niepełnogodzinny nieobsługiwany — podaj czas w UTC (--utc)');
  }
  const lo = OBCA ? -12 : 0, hi = OBCA ? 14 : 3;       // Warszawa: 0…3 jak dotąd; obca strefa: −12…+14
  if (!Number.isFinite(off) || off !== Math.round(off) || off < lo || off > hi) {
    throw new Error('tzdata ' + STREFA + ' zwróciło offset nie do przyjęcia: ' + off);
  }
  return off;
}

// ── Godzina LOKALNA → { off, zrodlo }: 'UE' (reguła modułu, od 1996) albo 'tzdata' (< 1996) ──
// Dla y < 1996 ta sama samospójność dwóch prób co w localToUTC, ale offset z Intl.
// Brak danych → RZUCA (silnik łapie i kończy rc=2). Nigdy cichy +2 dla daty sprzed reguły.
function offLokalny(y, m, d, h) {
  if (OBCA) return offLokalnyObca(y, m, d, h);
  if (!pozaZakresem(y)) return { off: offLocal(y, m, d, h), zrodlo: 'UE' };
  const hh = godzWejscia(h);
  const naiwny = Date.UTC(y, m - 1, d, hh, 0);
  for (const off of [2, 1]) {                 // jak w localToUTC: pierwsze wystąpienie przy dwuznaczności
    if (offTzdataAt(naiwny - off * 3600000) === off) return { off, zrodlo: 'tzdata' };
  }
  return { off: offTzdataAt(naiwny - 1 * 3600000), zrodlo: 'tzdata' };   // godzina nieistniejąca → skok do przodu
}

// ── Godzina wejścia: 0 to PRAWIDŁOWA godzina, nie brak wartości ──
// Klasa błędu złapana 13.08.2026: `h||12` w dziewięciu miejscach zamieniało
// północ na południe — 12 godzin rozjazdu, codziennie, w całym łańcuchu lens⊃eter⊃matryca⊃v4.
function godzWejscia(h, domyslna) {
  const dom = Number.isFinite(domyslna) ? domyslna : 12;
  return Number.isFinite(h) ? h : dom;
}

function nazwa(off) {
  if (OBCA) return nazwaObca(off);
  return off === 2 ? 'CEST' : 'CET';
}

// ── Format lokalny „DD.MM HH:MM CEST" ──
function fmt(msOrDate) {
  const ms = msOrDate instanceof Date ? msOrDate.getTime() : msOrDate;
  const off = offAt(ms);
  const l = new Date(ms + off * 3600000);
  const p = n => String(n).padStart(2, '0');
  return `${p(l.getUTCDate())}.${p(l.getUTCMonth() + 1)} ${p(l.getUTCHours())}:${p(l.getUTCMinutes())} ${nazwa(off)}`;
}

// Wariant z dniem tygodnia (potrzeba scan_outer).
function fmtDzien(msOrDate) {
  const ms = msOrDate instanceof Date ? msOrDate.getTime() : msOrDate;
  const off = offAt(ms);
  const l = new Date(ms + off * 3600000);
  const dni = ['niedz', 'pon', 'wt', 'śr', 'czw', 'pt', 'sob'];
  return `${dni[l.getUTCDay()]} ${fmt(ms)}`;
}

// ═══ GAŁĄŹ OBCEJ STREFY (STREFA ≠ Europe/Warsaw) ═══
// Offset z tzdata dla STREFA (`offTzdataAt`, −12…+14, tylko pełne godziny). Konwencja jak w gałęzi Warszawy: godzina dwuznaczna → PIERWSZE wystąpienie
// (największy samospójny offset), godzina nieistniejąca → skok do przodu (offset sprzed luki, czyli mniejszy).
function localToUTCObca(y, m, d, h, min) {
  const hh = godzWejscia(h);
  const mm = Number.isFinite(min) ? min : 0;
  const naiwny = Date.UTC(y, m - 1, d, hh, mm);
  for (let off = 14; off >= -12; off--) {      // od największego: „earlier" przy dwuznaczności
    const kandydat = naiwny - off * 3600000;
    if (offTzdataAt(kandydat) === off) return kandydat;
  }
  const przed = offTzdataAt(naiwny - 15 * 3600000), po = offTzdataAt(naiwny + 13 * 3600000);
  if (przed === po) throw new Error('strefa ' + STREFA + ': nie da się ustalić instantu godziny lokalnej ' + y + '-' + m + '-' + d + ' ' + hh + ':' + mm);
  return naiwny - Math.min(przed, po) * 3600000;   // godzina nieistniejąca → skok do przodu
}

// Godzina LOKALNA (także ułamkowa: pełnia podaje godzinę z minutami) → { off, zrodlo: 'strefa' }; licz w minutach, nie obcinaj.
function offLokalnyObca(y, m, d, h) {
  const hh = godzWejscia(h);
  const minuty = Math.round(hh * 60);
  const naiwny = Date.UTC(y, m - 1, d, 0, minuty);
  for (let off = 14; off >= -12; off--) {
    if (offTzdataAt(naiwny - off * 3600000) === off) return { off, zrodlo: 'strefa' };
  }
  const przed = offTzdataAt(naiwny - 15 * 3600000), po = offTzdataAt(naiwny + 13 * 3600000);
  if (przed === po) throw new Error('strefa ' + STREFA + ': nie da się ustalić offsetu godziny lokalnej');
  return { off: Math.min(przed, po), zrodlo: 'strefa' };
}

// Nazwa offsetu obcej strefy: UTC+N / UTC−N / UTC (znak minus U+2212).
function nazwaObca(off) { return off === 0 ? 'UTC' : (off > 0 ? 'UTC+' + off : 'UTC−' + (-off)); }

// Przy obcej strefie rejestr pełnogodzinności sprawdzamy od razu (wczytanie modułu), żeby silnik kończył rc=2 z powodem, nie stosem.
if (OBCA) {
  try { offTzdataAt(Date.UTC(2026, 0, 1)); offTzdataAt(Date.UTC(2026, 6, 1)); }
  catch (e) { console.error('✗ tz_pl.js: ' + e.message); process.exit(2); }
}

// Tryb wiersza poleceń: `node narzedzia/silniki/tz_pl.js --strefa` drukuje strefę instancji (jedna linia, rc=0).
if (require.main === module && process.argv.includes('--strefa')) { console.log(STREFA); }

module.exports = {
  offAt, offLocal, offLokalny, offTzdataAt, localToUTC, localDate, fmt, fmtDzien, nazwa,
  godzWejscia, lastSundayUTC, granice, pozaZakresem, ROK_REGULY_UE, STREFA, ETYKIETA,
};
