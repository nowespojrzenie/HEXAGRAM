# strefa_st.sh — WSPÓLNY fragment strefy instancji dla skryptów powłoki (v1.8.2 C5, U1-14c; 14.10.2026).
# Użycie (źródłowany, nie uruchamiany):  . "<katalog skryptu>/…/silniki/strefa_st.sh"   → ustawia _STREFA_ST
#
# BLIZNA: dwanaście skryptów miało `node tz_pl.js --strefa 2>/dev/null || echo Europe/Warsaw` — psuty `instancja.json`
# (tz_pl.js kończy rc=2 z komunikatem) znikał w /dev/null i stempel czasu cicho mówił „Warszawa/CEST".
# Reguła tz_pl.js: nieparsowalna strefa = BŁĄD, nigdy cichy powrót do Warszawy. Tu ta sama reguła w powłoce.
#
# ZACHOWANIE:  brak node albo brak tz_pl.js  → Europe/Warsaw (jedyny dozwolony fallback; nic do zmierzenia)
#              tz_pl.js rc=0                  → jego strefa
#              tz_pl.js rc≠0 (np. rc=2)       → komunikat tz_pl na stderr WIDOCZNY + _STREFA_ST="STREFA?" (stempel to pokaże)
# Zawsze wraca 0 (bezpieczne pod `set -e`).
_TZ_JS="$(dirname "${BASH_SOURCE[0]}")/tz_pl.js"
if command -v node >/dev/null 2>&1 && [ -f "$_TZ_JS" ]; then
  _STREFA_ST="$(node "$_TZ_JS" --strefa)" || _STREFA_ST="STREFA?"
else
  _STREFA_ST="Europe/Warsaw"
fi
true

# TOR:  bash narzedzia/silniki/strefa_st.sh --test   (uruchamiany, nie źródłowany; stub tz_pl.js w katalogu tymczasowym)
if [ "${BASH_SOURCE[0]}" = "$0" ] && [ "${1:-}" = "--test" ]; then
  _T="$(mktemp -d)"; cp "${BASH_SOURCE[0]}" "$_T/strefa_st.sh"; _rc=0
  _st() { bash -c '. "$1"; printf "%s" "$_STREFA_ST"' _ "$_T/strefa_st.sh" 2>"$_T/err"; }
  echo "╔═══ STREFA_ST — TOR ═══╗"
  [ "$(_st)" = "Europe/Warsaw" ] && echo "  ✓ T1 brak tz_pl.js → Europe/Warsaw" || { echo "  ✗ T1 OBLANY — brak tz_pl.js"; _rc=1; }
  echo 'if (process.argv.includes("--strefa")) console.log("America/New_York");' > "$_T/tz_pl.js"
  [ "$(_st)" = "America/New_York" ] && echo "  ✓ T2 tz_pl.js rc=0 → jego strefa" || { echo "  ✗ T2 OBLANY — strefa z tz_pl.js"; _rc=1; }
  echo 'console.error("✗ tz_pl.js: instancja.json nieparsowalny: x"); process.exit(2);' > "$_T/tz_pl.js"
  [ "$(_st)" = "STREFA?" ] && grep -q 'nieparsowalny' "$_T/err" && echo "  ✓ T3 tz_pl.js rc=2 → STREFA? + komunikat widoczny" || { echo "  ✗ T3 OBLANY — rc=2 nie daje STREFA? z komunikatem"; _rc=1; }
  rm -rf "$_T"; [ $_rc -eq 0 ] && echo "  TOR PRZESZEDŁ" || echo "  TOR OBLANY"; exit $_rc
fi
