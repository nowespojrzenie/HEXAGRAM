#!/usr/bin/env bash
# ═══ STRAŻ MIANOWNIKA (25.08.2026) — jak wchodzi wpis, który jeszcze nie ma mechanizmu ═══
#
# KSZTAŁT RATYFIKOWANY 22.08 (TASKI, DECYZJA 1), zbudowany 25.08 po weryfikacji weta.
# Wpis do `kanon/ksiegi/BLEDY.md` bez działającego mechanizmu wchodzi jako **NOŚNA RAMA** —
# jawne „jeszcze nie", nie ciche „R". Powód: „R" wygląda jak stan docelowy i przez to
# wypada z pola widzenia; NOŚNA RAMA sama mówi, że czeka.
#
# DLACZEGO ZAMEK, A NIE PROŚBA: prawo bez mechanizmu jest życzeniem (piąty inwariant) —
# a prawo O TYM, JAK WCHODZĄ PRAWA, byłoby życzeniem drugiego stopnia.
#
# DWIE LICZBY, NIE JEDNA (zamek anty-Goodhart mieszka w `narzedzia/przyrzady/pokrycie_m.js`):
#   pokrycie M rośnie ⟶ dobrze, ale KOLEJKA RAM natychmiast pokazuje cenę,
#   a NIEPOKRYTE (bez+rama+w drodze) NIE DRGA przy samym przepisaniu statusu.
#   Jedną liczbę da się zoptymalizować, dwóch nie.
#
# CZEGO NIE DUBLUJE — nazwane, żeby nie powstał drugi taki sam przyrząd (lekcja straży narodzin):
#   parytet numer↔wiersz w `kanon/ksiegi/KOLEJKA_M.md` → `lint_bledy.js` reguła 6 (obie strony, rc=1)
#   klasyfikacja i procent pokrycia                    → `narzedzia/przyrzady/pokrycie_m.js` (jedyne źródło formuły)
#   nagłówek w korpusie dla numeru z indeksu           → `narzedzia/przyrzady/pokrycie_m.js` (świadek krzyżowy)
# Ta straż pyta o JEDNO, czego nie pyta nikt: czy NOWY wiersz indeksu ma legalny status wejścia.
#
# MIERZY NARODZINY, NIE STAN (#61): zakres = wiersze DODANE względem HEAD. Zastane 32 wpisy
# „bez mechanizmu" jej nie dotyczą — inaczej weszłaby dopiero po spłacie długu, czyli „kiedyś",
# a straż wołająca nad legalnym stanem uczy nie patrzeć (#56).
#
# UŻYCIE:  bash straz_mianownika.sh          (rc=1 gdy nowy wpis wchodzi bez legalnego statusu)
#          bash straz_mianownika.sh --audyt  (stan całej księgi, informacyjnie, nigdy rc=1)
#          bash straz_mianownika.sh --test   (tor +/− — straż musi umieć NIE przejść)
set -u
cd "$(dirname "$0")/../.."

KSIEGA="${KSIEGA:-kanon/ksiegi/BLEDY.md}"

# ── STATUS Z WIERSZA: piąta kolumna tabeli `| # | legacy | prawo | rodzina | status |` ──
# Cięcie po `|`, nie po treści: tytuły praw zawierają przecinki, myślniki i „M" w środku zdania.
status_wiersza() {
  printf '%s\n' "$1" | awk -F'|' '{ gsub(/\*/,"",$6); gsub(/^[ \t]+|[ \t]+$/,"",$6); print $6 }'
}

# ── WERDYKT DLA JEDNEGO WIERSZA: 0 = legalne wejście, 1 = zatrzymanie ──
# Legalne są trzy: mechanizm z dowodem (✓), świadoma niemechanizowalność (POSTAWA),
# jawne „jeszcze nie" (NOŚNA RAMA). Nielegalne jest „R"/„P"/„—" na NOWYM wpisie.
legalny_status() {
  local s n; s="$(status_wiersza "$1")"
  case "$s" in
    *✓*)            return 0 ;;
    *POSTAWA*)      return 0 ;;
    *"NOŚNA RAMA"*) return 0 ;;
    *"NOSNA RAMA"*) return 0 ;;
  esac
  # ── „M" BEZ PTASZKA: LEGALNE, ALE Z NOŚNIKIEM (29.08.2026) ────────────────────────
  # ROZSTRZYGNIĘTE POMIAREM, nie gustem: `pokrycie_m.js` — jedyne źródło formuły — ma dla
  # „M" bez ✓ WŁASNY kubełek „w drodze", odrębny od „bez mechanizmu" (R/P/—) i od RAMY.
  # System już traktuje ten status jako legalny stan przejściowy; ta straż jedna o tym
  # nie wiedziała i odrzucała go, choć wszystkie cztery wpisy „M" w księdze (#2 #4 #9 #71)
  # mają wiersz w KOLEJKA_M. Warunek nośnika jest TEN SAM co dla NOŚNEJ RAMY — bez niego
  # „M" byłoby obietnicą bez adresu, czyli dokładnie tym, przed czym stoi ta straż.
  case "$s" in
    *M*)
      n="$(printf '%s\n' "$1" | awk -F'|' '{gsub(/[^0-9]/,"",$2); print $2}')"
      [ -n "$n" ] || return 1
      grep -qE "^\| *${n} *\|" "${KOLEJKA:-kanon/ksiegi/KOLEJKA_M.md}" 2>/dev/null && return 0
      return 1 ;;
  esac
  return 1
}

# ── TOR TESTOWY (#38) — bez niego ta straż byłaby życzeniem o mechanizmie ──
if [ "${1:-}" = "--test" ]; then
  echo "╔═══ STRAŻ MIANOWNIKA — AUTOTEST ═══╗"
  zle=""
  # (+) trzy legalne wejścia MUSZĄ przejść
  legalny_status '| 61 | — | prawo | POMIAR | **M✓** |' || zle="$zle ptaszek-oblewa"
  # M z nośnikiem PRZECHODZI, M bez nośnika OBLEWA (29.08) — dwustronnie, bo sama czułość
  # to połowa toru (#75). #71 ma wiersz w KOLEJCE; numer 999 nie ma i mieć nie będzie.
  legalny_status '| 71 | — | prawo | ŻYWE REPO | **M** |'  || zle="$zle M-z-nosnikiem-oblewa"
  legalny_status '| 999 | — | prawo | POMIAR | **M** |'    && zle="$zle M-bez-nosnika-przechodzi"
  legalny_status '| 62 | — | prawo | — | **POSTAWA** (niemechanizowalne) |' || zle="$zle postawa-oblewa"
  legalny_status '| 63 | — | prawo | GIT | **NOŚNA RAMA** |' || zle="$zle rama-oblewa"
  # (−) stare ciche statusy na NOWYM wpisie MUSZĄ oblać
  legalny_status '| 64 | — | prawo | GIT | R |'  && zle="$zle R-przechodzi"
  legalny_status '| 65 | — | prawo | GIT | P |'  && zle="$zle P-przechodzi"
  legalny_status '| 66 | — | prawo | GIT | — |'  && zle="$zle myslnik-przechodzi"
  # (−) MIARA, NIE ALARM (#49/#60): „M" w treści prawa nie może udawać statusu.
  # Wiersz ma status R, a w kolumnie prawa stoi słowo z ✓ — cięcie po kolumnie musi to znieść.
  legalny_status '| 67 | — | prawo o tym, że M✓ bywa mylone z M | POMIAR | R |' && zle="$zle tresc-udaje-status"
  # (−) NOŚNA RAMA w TREŚCI prawa, a status R — nie wolno zaliczyć
  legalny_status '| 68 | — | wpis bez mechanizmu wchodzi jako NOŚNA RAMA | META | R |' && zle="$zle rama-w-tresci-przechodzi"
  if [ -n "$zle" ]; then echo "✗ TOR OBLANY:$zle"; exit 1; fi
  echo "✓ TOR PRZESZEDŁ — straż umie NIE przejść."
  exit 0
fi

[ -f "$KSIEGA" ] || { echo "  ⓘ brak $KSIEGA (rc=2)"; exit 2; }

# ── TRYB AUDYTU: cały stan księgi, nigdy rc=1 (dług zastany nie jest wadą tej ręki) ──
if [ "${1:-}" = "--audyt" ]; then
  echo "╔═══ STRAŻ MIANOWNIKA — AUDYT (informacyjnie) ═══╗"
  node narzedzia/przyrzady/pokrycie_m.js --liczba
  echo "  ⓘ zakres zamka: wyłącznie wiersze DODANE względem HEAD. Powyższe to stan, nie werdykt."
  exit 0
fi

# ── ZAMEK: wiersze indeksu DODANE względem HEAD ──
# NOWY WPIS ≠ ZMIENIONY WIERSZ (29.08.2026, złapane na własnym commicie tuż przed wpięciem
# w hak). Zakresem jest wiersz DODANY, ale „dodany" w diffie obejmuje też KOREKTĘ istniejącego
# wpisu — uzupełnienie brakujących kolumn w #73/#74/#77 straż zgłosiła jako trzy nowe prawa
# wchodzące bez mechanizmu. Alarm szerszy niż sygnał (#56) i to na zamku, który ma stać w haku:
# blokowałby każdą naprawę formatu starych wierszy. Rozstrzyga NUMER: jest w HEAD → nie rodzi się.
_NUMERY_HEAD="$(git show "HEAD:$KSIEGA" 2>/dev/null | grep -oE '^\| *[0-9]+ *\|' | tr -cd '0-9\n')"
DIFF="$(git diff HEAD -- "$KSIEGA" | grep -E '^\+\| *[0-9]+ *\|' | sed 's/^+//' \
  | while IFS= read -r _w; do
      _n="$(printf '%s' "$_w" | awk -F'|' '{gsub(/[^0-9]/,"",$2); print $2}')"
      printf '%s\n' "$_NUMERY_HEAD" | grep -qx "$_n" || printf '%s\n' "$_w"
    done)"
if [ -z "$DIFF" ]; then
  echo "  ✓ straż mianownika: brak nowych wpisów w indeksie — nie ma czego pilnować."
  exit 0
fi

rc=0; ile=0
while IFS= read -r linia; do
  [ -z "$linia" ] && continue
  ile=$((ile + 1))
  numer="$(printf '%s\n' "$linia" | awk -F'|' '{gsub(/[^0-9]/,"",$2); print $2}')"
  if ! legalny_status "$linia"; then
    echo "  ✗ #${numer}: status „$(status_wiersza "$linia")\" — nowy wpis bez mechanizmu wchodzi jako NOŚNA RAMA."
    rc=1
  else
    echo "  ✓ #${numer}: status „$(status_wiersza "$linia")\" — legalne wejście."
  fi
done <<< "$DIFF"

echo "  ⓘ nowych wierszy indeksu: ${ile}"
node narzedzia/przyrzady/pokrycie_m.js --liczba
[ $rc -eq 1 ] && echo "  → legalne wejścia: **M✓** · **POSTAWA** · **NOŚNA RAMA** (+ wiersz w KOLEJKA_M — pilnuje lint_bledy reguła 6)"
exit $rc
