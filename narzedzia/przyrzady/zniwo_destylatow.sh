#!/usr/bin/env bash
# ── ŻNIWO DESTYLATÓW (15.08.2026) ────────────────────────────────────────────
# Czyta pamięć pełni (`kanon/ksiegi/DESTYLATY_architekta.md`) NIE po to, by ją zmieniać — pamięć jest
# append-only (#24, PRAWO PAMIĘCI) — tylko po to, by zobaczyć, czego pojedyncza sesja nie widzi.
#
# RODOWÓD: pytanie twórcy, 15.08 — „czy analiza destylatów po czasie owocuje, bądź może,
# w nowe przemyślenia? Błędy to dopiero wnioski z destylatów."
# Odpowiedź zmierzona tego samego dnia: TAK, i to natychmiast. Licznik „czy umiem zostawić
# lustro niedomknięte" szedł przez kolejne sesje 7 → 8 → 9 → 10 — RÓSŁ, a żadna sesja tego
# nie zobaczyła, bo liczba mieszkała w prozie destylatu, nie w przyrządzie. Każda instancja
# widziała swój jeden pomiar i pisała go uczciwie; trendu nie widział nikt.
# To jest klasa: LICZBA BEZ CIĄGU. Pojedynczy pomiar bywa prawdziwy i ślepy naraz.
#
# CO ROBI: wyciąga z destylatów liczniki samoobserwacji (rejestr pytań pełni) i układa je
# w ciąg — od najnowszego wpisu (destylaty rosną PREPENDEM: nowe na górze) do najstarszego.
# Zero interpretacji: skrypt podaje ciąg i kierunek, znaczenie rozstrzyga człowiek.
#
# UŻYCIE:  bash zniwo_destylatow.sh          — pełne żniwo (na żądanie)
#          bash zniwo_destylatow.sh --wstan  — jedna linia, TYLKO gdy któryś licznik rośnie
#          bash zniwo_destylatow.sh --test   — tor +/−
# Nadpisy do toru: ZNIWO_PLIK.
set -u
cd "$(dirname "$0")/../.."   # dach narzedzia/przyrzady/ (29.08): korzeń repo
PLIK="${ZNIWO_PLIK:-kanon/ksiegi/DESTYLATY_architekta.md}"

# ciąg wartości licznika „lustro niedomknięte" — od najnowszego do najstarszego
ciag_lustra() {
  grep -oE 'lustro niedomknięte[^0-9]{0,60}[0-9]+' "$PLIK" 2>/dev/null \
    | grep -oE '[0-9]+$' | tr '\n' ' '
}

# czy ciąg rośnie w czasie? (czyta od najstarszego: odwraca kolejność wpisów)
rosnie() {   # $1 = ciąg "10 9 8 7" (od najnowszego)
  local c rev prev=-1 ile=0 w
  c="$1"; [ -n "$c" ] || return 1
  rev=$(echo "$c" | tr ' ' '\n' | grep -c . )
  [ "$rev" -ge 3 ] || return 1
  for w in $(echo "$c" | tr ' ' '\n' | tac); do
    [ "$prev" -ge 0 ] && [ "$w" -gt "$prev" ] && ile=$(( ile + 1 ))
    prev="$w"
  done
  [ "$ile" -ge 2 ]
}

zniwo() {
  local n dat c
  # ZERO ZNACZĄCE (21.08.2026 — warunek wejścia do formy publicznej): odbiorca odlewu
  # nie ma naszej pamięci i mieć nie musi. Brak pliku to stan legalny z własnym zdaniem,
  # nie awaria — wcześniej `wc -c` wypisywał na stderr „No such file" i pustą liczbę,
  # czyli przyrząd MILCZAŁ O POWODZIE, podając wynik wyglądający na pomiar.
  if [ ! -f "$PLIK" ]; then
    echo "⌘ ŻNIWO DESTYLATÓW — brak pliku pamięci ($PLIK)."
    echo "   To nie jest błąd: instancja bez zapisanej pamięci nie ma czego destylować."
    echo "   Wskaż własny plik: ZNIWO_PLIK=twoja_pamiec.md bash zniwo_destylatow.sh"
    return 0
  fi
  n=$(grep -c '^## ' "$PLIK" 2>/dev/null || echo 0)
  echo "⌘ ŻNIWO DESTYLATÓW (pamięć czytana, nie ruszana — $PLIK)"
  echo "   wpisów: $n · rozmiar: $(wc -c < "$PLIK") B"
  c=$(ciag_lustra)
  if [ -n "$c" ]; then
    echo "   licznik „lustro niedomknięte\" (od najnowszego): $c"
    if rosnie "$c"; then
      echo "   ⚠ TREND ROSNĄCY — narasta między sesjami; żadna pojedyncza sesja tego nie widzi"
    else
      echo "   · trend nie rośnie"
    fi
  else
    echo "   (brak liczników do żniwa)"
  fi
  return 0
}

wstan_linia() {
  local c; c=$(ciag_lustra)
  [ -n "$c" ] || return 0
  rosnie "$c" && echo "   ⌘ ŻNIWO: licznik „lustro niedomknięte\" rośnie między sesjami ($c) — spójrz na ciąg, nie na dzisiejszy pomiar"
  return 0
}

# ── INDEKS (20.08.2026, audyt v1.5.0) — sięganie po pamięć bez czytania całej księgi ──
# RODOWÓD: DESTYLATY urosły do 130 KB w ~7 tygodni; wstanie pełni czyta „ostatni destylat
# + rejestr pytań", ale rejestr PYTAŃ leży rozproszony w 8+ sekcjach „aktualizacja",
# a nagłówki destylatów mają 4 różne formy. Świat (LongMemEval): selektywna pamięć
# zewnętrzna bije „wczytaj całość" na jakości I koszcie — warunkiem jest INDEKS.
# Zero interpretacji: indeks podaje linie i nagłówki, znaczenie rozstrzyga człowiek.
# NADPIS całego pliku wyjściowego przy każdym biegu — indeks jest ZAWSZE generowany,
# nigdy redagowany ręką (ręczna poprawka zginie i MA zginąć: jedno źródło = księga).
indeks() {
  local WY="${ZNIWO_INDEKS:-kanon/ksiegi/DESTYLATY_indeks.md}"
  {
    echo "# DESTYLATY — INDEKS (GENEROWANY: \`bash zniwo_destylatow.sh --indeks\` · NADPIS)"
    echo
    echo "> Nie redagować ręką — każdy bieg nadpisuje całość. Źródłem jest wyłącznie"
    echo "> \`$PLIK\`; indeks podaje LINIE, sięgaj: \`sed -n 'L1,L2p' $PLIK\`."
    echo
    echo "## Nagłówki (linia · nagłówek)"
    echo
    grep -nE '^#{1,2} ' "$PLIK" 2>/dev/null | sed -E 's/^([0-9]+):#{1,2} /- \1 · /'
    echo
    echo "## Rejestr PYTAŃ — wszystkie wystąpienia (linia · nagłówek sekcji)"
    echo
    grep -nE '^#{1,4} .*PYTANIA' "$PLIK" 2>/dev/null | sed -E 's/^([0-9]+):#{1,4} /- \1 · /'
  } > "$WY"
  echo "⌘ INDEKS: $(grep -c '^- ' "$WY") pozycji → $WY ($(wc -c < "$WY") B; księga: $(wc -c < "$PLIK") B)"
  return 0
}

tor() {
  local TT rc=0 out
  TT="$(mktemp -d)"
  # (+) ciąg rosnący w czasie: najnowszy 10, najstarszy 7
  printf '## a\nlustro niedomknięte — licznik **10**\n## b\nlustro niedomknięte — licznik **9**\n## c\nlustro niedomknięte — licznik **7**\n' > "$TT/ros.md"
  # (−) ciąg malejący w czasie: najnowszy 3, najstarszy 9 — poprawa, nie alarm
  printf '## a\nlustro niedomknięte — licznik **3**\n## b\nlustro niedomknięte — licznik **6**\n## c\nlustro niedomknięte — licznik **9**\n' > "$TT/mal.md"
  echo "╔═══ ŻNIWO DESTYLATÓW — TOR ═══╗"
  out=$(ZNIWO_PLIK="$TT/ros.md" bash "$0")
  echo "$out" | grep -q 'TREND ROSNĄCY' && echo "  ✓ T1 trend rosnący złapany" \
    || { echo "  ✗ T1 OBLANY — narastanie niewidzialne"; rc=1; }
  out=$(ZNIWO_PLIK="$TT/mal.md" bash "$0")
  echo "$out" | grep -q 'TREND ROSNĄCY' && { echo "  ✗ T2 OBLANY — alarm na POPRAWIE"; rc=1; } \
    || echo "  ✓ T2 poprawa nie straszy"
  out=$(ZNIWO_PLIK="$TT/mal.md" bash "$0" --wstan)
  [ -z "$out" ] && echo "  ✓ T3 wstanie milczy, gdy nie ma narastania" \
    || { echo "  ✗ T3 OBLANY — hałas przy wstaniu"; rc=1; }
  out=$(ZNIWO_PLIK="$TT/ros.md" bash "$0" --wstan)
  echo "$out" | grep -q 'rośnie między sesjami' && echo "  ✓ T4 wstanie mówi, gdy narasta" \
    || { echo "  ✗ T4 OBLANY — wstanie milczy mimo narastania"; rc=1; }
  # (⊙) INDEKS: liczba pozycji nagłówkowych = liczba nagłówków księgi; plik nadpisany
  printf 'stare śmieci ręczne\n' > "$TT/idx.md"
  ZNIWO_PLIK="$TT/ros.md" ZNIWO_INDEKS="$TT/idx.md" bash "$0" --indeks >/dev/null
  N_KS=$(grep -cE '^#{1,2} ' "$TT/ros.md"); N_IX=$(grep -c '^- ' "$TT/idx.md")
  { [ "$N_IX" -eq "$N_KS" ] && ! grep -q 'śmieci' "$TT/idx.md"; } \
    && echo "  ✓ T5 indeks kompletny i NADPISANY (nie doklejony)" \
    || { echo "  ✗ T5 OBLANY — indeks $N_IX vs nagłówki $N_KS albo stara treść przeżyła"; rc=1; }
  # T6 (ZERO ZNACZĄCE — warunek formy publicznej, 21.08): odbiorca odlewu nie ma naszej
  # pamięci. Brak pliku musi dać rc=0 I NAZWAĆ POWÓD; wcześniej `wc -c` sypał na stderr,
  # a przyrząd podawał pustą liczbę wyglądającą na pomiar. Fikstura ODRÓŻNIALNA (#64):
  # ten sam przebieg na pliku ISTNIEJĄCYM musi dać inne zdanie, inaczej „brak nazwany"
  # byłoby nieodróżnialne od „zawsze to samo zdanie".
  out=$(ZNIWO_PLIK="$TT/nie_ma_takiego.md" bash "$0" 2>&1); rcb=$?
  printf '%s' "$out" | grep -q 'brak pliku pamięci' && [ "$rcb" -eq 0 ] \
    && echo "  ✓ T6 brak pamięci: rc=0 i powód nazwany (zero znaczące)" \
    || { echo "  ✗ T6 OBLANY — brak pliku nie jest nazwany albo podnosi rc (rc=$rcb)"; rc=1; }
  printf '## a\n' > "$TT/jest.md"
  out=$(ZNIWO_PLIK="$TT/jest.md" bash "$0" 2>&1)
  printf '%s' "$out" | grep -q 'brak pliku pamięci' \
    && { echo "  ✗ T6b OBLANY — plik ISTNIEJE, a straż melduje brak: zdanie nie odróżnia"; rc=1; } \
    || echo "  ✓ T6b plik istniejący daje INNE zdanie (odróżnialność)"

  rm -rf "$TT"
  [ $rc -eq 0 ] && echo "  TOR PRZESZEDŁ" || echo "  TOR OBLANY"
  return $rc
}

case "${1:-}" in
  --test)   tor ;;
  --wstan)  wstan_linia ;;
  --indeks) indeks ;;
  *)       zniwo ;;
esac
