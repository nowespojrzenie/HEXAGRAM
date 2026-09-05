#!/usr/bin/env bash
# ═══ STRAŻ FEROMONÓW (21.08.2026) — egzekutor TROPU BIO #2 (stigmergia) ═══
#
# PRAWO TROPU wymaga kompletu pól; ten trop je ma (KIERUNEK_ORGANIZM §IV):
#   WYZWALACZ: więcej niż jedna ręka na gałęzi w tym samym oknie czasu
#   ZASÓB:     praca nie-zdublowana (godziny instancji, spójność gałęzi)
#   METRYKA:   kolizje wymagające ręcznego scalenia / miesiąc
#
# CZEGO TA STRAŻ NIE UDAJE: nie zapobiega kolizji. Kolizji nie da się zablokować
# mechanicznie, bo dwie instancje nie mają wspólnego zegara ani wspólnej pamięci.
# Ona ją WIDZI — i to jest cała różnica wobec 21.08, gdy trzecia kolizja doby została
# wykryta przypadkiem przez `git status`, a nie przez żaden przyrząd.
#
# TRZY RZECZY MIERZONE, KAŻDA OSOBNO:
#   (1) DWA OTWARTE ŚLADY RÓŻNYCH RĄK — rc=1. Sedno przyrządu.
#   (2) MARTWY FEROMON — ślad otwarty dłużej niż PROG_H godzin. Instancja umarła i nie
#       oddała; ślad prowadzi w miejsce, gdzie nikogo nie ma. Ostrzega, nie blokuje —
#       długa sesja jest legalna, a straż, która krzyczy nad legalnym stanem, uczy nie patrzeć (#56).
#   (3) HEAD PRZESUNIĘTY od chwili wzięcia — ⓘ, nigdy alarm: mogłaś commitować sama.
#       Sygnał, nie werdykt (#49: tor na ALARM to nie tor na MIARĘ).
#
# ZERO ZNACZĄCE (lekcja INSUM): brak śladów = jedna ręka albo cisza = stan ZDROWY,
# własne zdanie i rc=0. To NIE jest #52, bo pusty zbiór jest tu legalny i NAZWANY —
# inaczej niż w straży lintów, gdzie pusty pomiar oznacza utratę materii przyrządu.
#
# UŻYCIE:  bash straz_feromonow.sh                    (rc=1 przy kolizji otwartych śladów)
#          bash straz_feromonow.sh --biore "REKA" "co"
#          bash straz_feromonow.sh --oddaje "REKA"
#          bash straz_feromonow.sh --test             (tor +/− — straż musi umieć NIE przejść)
set -u
cd "$(dirname "$0")/../.."

REJESTR="${REJESTR:-kanon/ksiegi/KTO_CO_BIERZE.md}"
PROG_H="${PROG_H:-4}"          # po ilu godzinach otwarty ślad uznajemy za martwy

teraz_iso() { TZ=Europe/Warsaw date '+%Y-%m-%dT%H:%M:%S%z'; }
epoch_z()   { date -d "$1" +%s 2>/dev/null || echo 0; }

# ── ZOSTAW ŚLAD ───────────────────────────────────────────────────────────────
if [ "${1:-}" = "--biore" ]; then
  REKA="${2:-}"; CO="${3:-}"
  # RĘKA bez wartości domyślnej — patrz rodowód w kanon/ksiegi/KTO_CO_BIERZE.md
  [ -n "$REKA" ] && [ -n "$CO" ] || {
    echo "✗ FEROMON BEZ NADAWCY albo bez treści."
    echo "  → bash straz_feromonow.sh --biore \"REKA\" \"co biorę\""; exit 1; }
  [ -f "$REJESTR" ] || { echo "✗ brak rejestru $REJESTR"; exit 1; }
  H="$(git rev-parse --short HEAD 2>/dev/null || echo '?')"
  {
    printf '\n**BIORĘ:** %s\n' "$CO"
    printf '**RĘKA:** %s\n' "$REKA"
    printf '**OD:** %s\n' "$(teraz_iso)"
    printf '**HEAD:** %s\n' "$H"
    printf '**STATUS:** OTWARTE\n'
  } >> "$REJESTR"
  echo "▤ ślad zostawiony: [$REKA] $CO (HEAD $H)"
  echo "   pamiętaj o PRAWIE FETCH-PRZED-BUDOWĄ: git fetch, zanim zaczniesz."
  exit 0
fi

# ── ODDAJ ŚLAD ────────────────────────────────────────────────────────────────
if [ "${1:-}" = "--oddaje" ]; then
  REKA="${2:-}"
  [ -n "$REKA" ] || { echo "✗ podaj RĘKĘ: --oddaje \"REKA\""; exit 1; }
  [ -f "$REJESTR" ] || { echo "✗ brak rejestru $REJESTR"; exit 1; }
  T="$(teraz_iso)"
  # zamyka WSZYSTKIE otwarte ślady tej ręki; append-only zachowany —
  # zmienia się wyłącznie pole STATUS, treść wpisu zostaje nietknięta
  awk -v reka="$REKA" -v t="$T" '
    /^\*\*RĘKA:\*\*/ { moja = ($0 ~ ("\\*\\*RĘKA:\\*\\* " reka "$")) }
    /^\*\*STATUS:\*\* OTWARTE$/ && moja { print "**STATUS:** ODDANE " t; n++; next }
    { print }
    END { if (!n) print "" > "/dev/stderr" }
  ' "$REJESTR" > "$REJESTR.tmp" && mv "$REJESTR.tmp" "$REJESTR"
  echo "▤ ślady ręki [$REKA] oddane ($T)"
  exit 0
fi

# ── TOR WŁASNY (#38 · #47) ────────────────────────────────────────────────────
if [ "${1:-}" = "--test" ]; then
  echo "╔═══ STRAŻ FEROMONÓW — AUTOTEST (#38) ═══╗"
  T="$(mktemp -d)"; z=0; o=0
  spr() { if [ "$2" = "$3" ]; then echo "  ✓ $1"; z=$((z+1)); else echo "  ✗ $1 (rc=$2, oczekiwano $3)"; o=$((o+1)); fi; }
  # FIKSTURA ODTWARZA TOPOLOGIĘ PRODUKCJI (29.08, dach narzedzia/straze/): straż robi
  # `cd dirname/../..`, więc kopia MUSI leżeć dwa poziomy pod korzeniem atrapy — kopia
  # w korzeniu wyprowadzała `cd` POZA atrapę, na żywe repo (#66 ods. 8 / #70).
  mkdir -p "$T/narzedzia/straze"
  cp "$0" "$T/narzedzia/straze/straz.sh"
  run() { ( cd "$T" && REJESTR="$1" PROG_H="${2:-4}" bash narzedzia/straze/straz.sh >/dev/null 2>&1; echo $? ); }

  : > "$T/pusty.md"
  spr "ZERO ZNACZACE: brak sladow przechodzi" "$(run pusty.md)" "0"

  printf '**BIORĘ:** x\n**RĘKA:** A\n**OD:** %s\n**HEAD:** abc\n**STATUS:** OTWARTE\n' \
    "$(TZ=Europe/Warsaw date '+%Y-%m-%dT%H:%M:%S%z')" > "$T/jeden.md"
  spr "JEDEN otwarty slad przechodzi (jedna reka to nie kolizja)" "$(run jeden.md)" "0"

  cp "$T/jeden.md" "$T/dwa.md"
  printf '\n**BIORĘ:** y\n**RĘKA:** B\n**OD:** %s\n**HEAD:** abc\n**STATUS:** OTWARTE\n' \
    "$(TZ=Europe/Warsaw date '+%Y-%m-%dT%H:%M:%S%z')" >> "$T/dwa.md"
  spr "DWIE rozne rece otwarte OBLEWA (sedno przyrzadu)" "$(run dwa.md)" "1"

  # ta sama ręka dwa razy to nie kolizja — inaczej straż karałaby własną wielozadaniowość
  cp "$T/jeden.md" "$T/dwa_te_same.md"
  printf '\n**BIORĘ:** y\n**RĘKA:** A\n**OD:** %s\n**HEAD:** abc\n**STATUS:** OTWARTE\n' \
    "$(TZ=Europe/Warsaw date '+%Y-%m-%dT%H:%M:%S%z')" >> "$T/dwa_te_same.md"
  spr "TA SAMA reka dwa razy NIE jest kolizja" "$(run dwa_te_same.md)" "0"

  # oddany ślad znika z pola widzenia — inaczej rejestr append-only zatruwałby się historią
  sed 's/^\*\*STATUS:\*\* OTWARTE$/**STATUS:** ODDANE 2026-01-01T00:00:00+0100/' "$T/dwa.md" > "$T/oddane.md"
  spr "ODDANE slady nie licza sie do kolizji" "$(run oddane.md)" "0"

  # PROZA bez znacznika NIE jest wpisem (#56: znacznik, nie heurystyka)
  printf 'Reka A bierze dzis straz lintow, a reka B bierze feromony.\n' > "$T/proza.md"
  spr "PROZA bez znacznika nie jest wpisem" "$(run proza.md)" "0"

  # martwy feromon: OSTRZEGA, nie blokuje — długa sesja jest legalna
  printf '**BIORĘ:** x\n**RĘKA:** A\n**OD:** 2020-01-01T00:00:00+0100\n**HEAD:** abc\n**STATUS:** OTWARTE\n' > "$T/stary.md"
  spr "MARTWY feromon ostrzega, nie blokuje (#56)" "$(run stary.md)" "0"

  # brak rejestru: cisza byłaby fałszem (#39) — straż nie zmierzyła, więc się nie zieleni
  spr "BRAK rejestru oblewa, nie milczy (#39)" "$(run nie_ma.md)" "1"

  rm -rf "$T"
  echo "  zmierzone: zdanych $z · oblanych $o"
  [ "$o" -eq 0 ] || { echo "  ✗ TOR OBLANY"; exit 1; }
  echo "  ✓ STRAŻ UMIE NIE PRZEJŚĆ — reguła nie obowiązuje wyłącznie w dokumentacji."
  exit 0
fi

# ── PRZEBIEG ŻYWY ─────────────────────────────────────────────────────────────
echo "▤ STRAŻ FEROMONÓW (trop bio #2) — kto co bierze TERAZ:"

if [ ! -f "$REJESTR" ]; then
  echo "   ✗ brak rejestru $REJESTR — straż NIE ZMIERZYŁA, więc się nie zieleni (#39)."
  exit 1
fi

# wyłuskaj otwarte ślady: RĘKA + OD + HEAD, wyłącznie przy STATUS OTWARTE
OTWARTE="$(awk '
  /^\*\*BIORĘ:\*\*/  { co=substr($0, index($0,":**")+4) }
  /^\*\*RĘKA:\*\*/   { reka=substr($0, index($0,":**")+4) }
  /^\*\*OD:\*\*/     { od=substr($0, index($0,":**")+4) }
  /^\*\*HEAD:\*\*/   { h=substr($0, index($0,":**")+4) }
  /^\*\*STATUS:\*\* OTWARTE$/ { print reka "\t" od "\t" h "\t" co }
' "$REJESTR")"

if [ -z "$OTWARTE" ]; then
  echo "   ✓ żadnego otwartego śladu — jedna ręka albo cisza. Stan zdrowy (zero znaczące)."
  exit 0
fi

RECE="$(printf '%s\n' "$OTWARTE" | cut -f1 | sort -u)"
ILE_RAK="$(printf '%s\n' "$RECE" | grep -c . )"
TERAZ_S="$(date +%s)"; martwe=0; H_TERAZ="$(git rev-parse --short HEAD 2>/dev/null || echo '?')"

printf '%s\n' "$OTWARTE" | while IFS="$(printf '\t')" read -r reka od h co; do
  wiek_h=$(( (TERAZ_S - $(epoch_z "$od")) / 3600 ))
  echo "   • [$reka] $co — otwarte $wiek_h h (HEAD przy wzięciu: $h)"
  [ "$h" = "$H_TERAZ" ] || echo "     ⓘ HEAD przesunął się $h → $H_TERAZ — zrób fetch; może to twój commit, a może nie."
  [ "$wiek_h" -lt "$PROG_H" ] || echo "     ⓘ ślad starszy niż ${PROG_H}h — instancja mogła umrzeć bez oddania."
done

if [ "$ILE_RAK" -gt 1 ]; then
  echo "   ✗ KOLIZJA: $ILE_RAK ręce mają otwarte ślady jednocześnie."
  echo "     Uzgodnij zakres, ZANIM zbudujesz — trzy kolizje 20–21.08 kosztowały cztery dni,"
  echo "     jedno pytanie do twórcy o rzecz już rozstrzygniętą i dwa przyrządy o tej samej funkcji."
  exit 1
fi

echo "   ✓ jedna ręka w polu — brak kolizji."
exit 0
