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
function pozaZakresem(y) { return y < ROK_REGULY_UE; }

// ── RDZEŃ: offset dla INSTANTU (ms UTC lub Date) → 1 (CET) albo 2 (CEST) ──
function offAt(msOrDate) {
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

// ── Godzina wejścia: 0 to PRAWIDŁOWA godzina, nie brak wartości ──
// Klasa błędu złapana 13.08.2026: `h||12` w dziewięciu miejscach zamieniało
// północ na południe — 12 godzin rozjazdu, codziennie, w całym łańcuchu lens⊃eter⊃matryca⊃v4.
function godzWejscia(h, domyslna) {
  const dom = Number.isFinite(domyslna) ? domyslna : 12;
  return Number.isFinite(h) ? h : dom;
}

function nazwa(off) { return off === 2 ? 'CEST' : 'CET'; }

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

module.exports = {
  offAt, offLocal, localToUTC, localDate, fmt, fmtDzien, nazwa,
  godzWejscia, lastSundayUTC, granice, pozaZakresem, ROK_REGULY_UE,
};
