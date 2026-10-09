#!/usr/bin/env bash
# ── STRAŻ DEKLAMATORA (29.07.2026) — mechanizm do blizny #34 i krzesła DEKLAMATOR ──
# PRAWO: zdanie o wyniku musi być FUNKCJĄ wyniku. Werdykt postawiony OBOK pomiaru,
# a nie wyprowadzony Z pomiaru, jest dekoracją — nawet gdy przypadkiem trafia.
#
# UCZCIWY STATUS: R+M-CZĘŚCIOWE, nie M✓.
#   Ten strażnik NIE przechwytuje komend w locie — nie ma takiej możliwości w tym środowisku.
#   Umie tylko przeczytać TEKST komendy, który mu podasz. Jest więc mechanizmem dla tekstu,
#   a nawykiem dla ręki. Nie udaję, że to pełna mechanizacja (inwariant 5: prawo bez mechanizmu
#   = życzenie; ale mechanizm ogłoszony ponad swój zasięg = ta sama choroba, tylko odwrotnie).
#
# UŻYCIE:
#   bash straz_deklamatora.sh --lint <plik|->     # szuka werdyktów-dekoracji w tekście komendy
#   bash straz_deklamatora.sh --raport <plik>     # ZAMIAST echo: werdykt wyprowadzony z pliku
#   bash straz_deklamatora.sh --test              # test +/− (straż musi umieć NIE przejść)

set -u

# Słowa, które NIOSĄ WERDYKT (nie dane). Deklamator mówi właśnie nimi.
WERDYKT='zero|pusto|puste|pusta|czysto|czyste|brak |bez trafien|bez trafień|OK:|sukces|gotowe|zgodne|w porzadku|w porządku|nic do|✓'
# Konstrukcje, które dowodzą, że werdykt WYNIKA z pomiaru.
DOWOD='if |then|else|fi|\[ |\[\[|test |\$\?|-s |-z |-n |&&|\|\||case '

raport() {
  f="${1:-}"
  [ -n "$f" ] || { echo "raport: podaj plik"; return 2; }
  if [ ! -e "$f" ]; then echo "NIE ISTNIEJE: $f"; return 2; fi
  n=$(wc -l < "$f" | tr -d ' ')
  if [ -s "$f" ]; then
    echo "TRAFIENIA ($n):"; cat "$f"; return 0
  else
    echo "zmierzone: plik pusty (0 linii) — brak trafień"; return 1
  fi
}

lint() {
  src="${1:--}"
  if [ "$src" = "-" ]; then tekst="$(cat)"; else tekst="$(cat "$src")"; fi
  ile=0
  # analizujemy linia po linii; interesują nas echo/printf niosące werdykt
  while IFS= read -r linia; do
    case "$linia" in
      *echo*|*printf*) ;;
      *) continue ;;
    esac
    printf '%s\n' "$linia" | grep -qE "$WERDYKT" || continue
    # czy w TEJ SAMEJ linii jest dowód wyprowadzenia werdyktu z pomiaru?
    if printf '%s\n' "$linia" | grep -qE "$DOWOD"; then continue; fi
    ile=$((ile+1))
    echo "  [Deklamator] werdykt bez wyprowadzenia:"
    echo "      $linia"
  done <<EOF
$tekst
EOF
  if [ "$ile" -gt 0 ]; then
    echo "  ✗ DEKLAMATOR MÓWI — $ile zdanie(a) o wyniku postawione obok pomiaru."
    echo "    Napraw wzorcem:  if [ -s plik ]; then echo \"TRAFIENIA:\"; cat plik; else echo \"zero\"; fi"
    echo "    albo:            bash straz_deklamatora.sh --raport plik"
    return 1
  fi
  echo "  ✓ brak werdyktów-dekoracji w podanym tekście (zmierzone: $ile trafień)"
  return 0
}

# ── TRYB --liczby (11.08.2026, ratyfikacja twórcy po ROZMOWIE #2) ──
# MECHANIKA CZĘŚCIOWA dla klasy #30 (LICZBA BEZ LICZNIKA). Rodowód: 5 zmierzonych
# przypadków — A (33/41), B (19/22), odlew v1.1 (10/?), żywa (46/45), liczniki META
# hurtem. Rytuał (R) nie utrzymał klasy nawet w dokumencie pieczętowanym.
# ZASIĘG NAZWANY: dokumenty rejestrowe (prerejestr/, ROZMOW*, pieczęcie) — NIE mowa
# w czacie. Uzupełniacz w mowie zostaje; ta straż domyka dokumenty, nie klasę.
# ZASADA: liczba + rzeczownik rejestrowy w akapicie wymaga ŚLADU LICZNIKA w TYM SAMYM
# akapicie (nazwa komendy zliczającej albo słowo „zmierzon*"/„licznik:"). Akapit = blok
# między pustymi liniami.
RZECZOWNIK='wpis(y|ów|ami)?|commit(y|ów|ami)?|plik(i|ów|ami)?|tor(y|ów|ami)?|pozycj(i|e|ach)|blizn(y|ach)?|nagłówk(i|ów)|naglowk(i|ow)|straż(y|e)?|odcisk(i|ów)?'
SLAD='grep|wc |wc<|rev-list|ls-tree|--count|uniq -c|licznik:|zmierzon|policzon.*grep|sha256'

liczby() {
  f="${1:-}"
  [ -n "$f" ] || { echo "liczby: podaj plik"; return 2; }
  [ -e "$f" ] || { echo "NIE ISTNIEJE: $f"; return 2; }
  ile=0
  # akapity: awk łamie na pustych liniach; badamy każdy akapit osobno
  while IFS= read -r akapit; do
    [ -n "$akapit" ] || continue
    printf '%s' "$akapit" | grep -qE "[0-9]+[[:space:]]*($RZECZOWNIK)" || continue
    printf '%s' "$akapit" | grep -qiE "$SLAD" && continue
    ile=$((ile+1))
    echo "  [#30] liczba rejestrowa bez śladu licznika w akapicie:"
    printf '%s' "$akapit" | grep -E "[0-9]+[[:space:]]*($RZECZOWNIK)" | head -2 | sed 's/^/      /'
  done <<EOF
$(awk 'BEGIN{RS=""; ORS="\n"} {gsub(/\n/," "); print}' "$f")
EOF
  if [ "$ile" -gt 0 ]; then
    echo "  ✗ #30 W DOKUMENCIE — $ile akapit(ów) z liczbą bez licznika."
    echo "    Napraw: dopisz w akapicie ślad komendy (grep -c / wc / rev-list) albo „licznik: <komenda>\"."
    return 1
  fi
  echo "  ✓ każda liczba rejestrowa ma ślad licznika w swoim akapicie (zmierzone: 0 braków)"
  return 0
}

autotest() {
  tmp_zly="$(mktemp)"; tmp_dobry="$(mktemp)"
  cat > "$tmp_zly" <<'EOF'
grep -rn "wzorzec" . > /tmp/wynik.txt
echo "(pusto = zero kolizji)"
find . -name "*.md" | head
echo "(brak linii = czysto)"
EOF
  cat > "$tmp_dobry" <<'EOF'
grep -rn "wzorzec" . > /tmp/wynik.txt
if [ -s /tmp/wynik.txt ]; then echo "TRAFIENIA:"; cat /tmp/wynik.txt; else echo "zero trafien"; fi
RC=$?; [ "$RC" = 0 ] && echo "OK: zgodne" || echo "rozjazd"
EOF
  echo "── TEST − (straż MUSI oblać przykład chory) ──"
  lint "$tmp_zly"; rc_zly=$?
  echo "── TEST + (straż MUSI przepuścić przykład zdrowy) ──"
  lint "$tmp_dobry"; rc_dobry=$?
  # PRAWO #38: --raport też jest deklarowaną regułą („werdykt wyprowadzony z pliku”) → własny tor.
  echo "── TEST ⊙ (--raport: pusty MUSI dać rc=1, niepusty rc=0) ──"
  tmp_pusty="$(mktemp)"; tmp_pelny="$(mktemp)"; echo "trafienie" > "$tmp_pelny"
  raport "$tmp_pusty" >/dev/null; rc_pusty=$?
  raport "$tmp_pelny" >/dev/null; rc_pelny=$?
  echo "  pusty rc=$rc_pusty (oczekiwane 1) · niepusty rc=$rc_pelny (oczekiwane 0)"
  # PRAWO #38: tryb --liczby (11.08) dostaje tor w dniu narodzin, nie później.
  echo "── TEST ⊘ (--liczby: liczba bez śladu MUSI oblać, ze śladem przejść) ──"
  tmp_l_zly="$(mktemp)"; tmp_l_dobry="$(mktemp)"; tmp_l_cyt="$(mktemp)"
  printf 'W księdze stoi 46 wpisów i 15 torów.\n' > "$tmp_l_zly"
  printf 'Zmierzone grep -c: 45 wpisów. Bateria: 16 torów (tory_strazy --cicho).\n' > "$tmp_l_dobry"
  printf 'Rozdział cytuje 300 pozycji katalogu Messiera.\n\nlicznik: wc -l katalog.txt = 110 pozycji\n' > "$tmp_l_cyt"
  liczby "$tmp_l_zly"   >/dev/null; rc_l_zly=$?
  liczby "$tmp_l_dobry" >/dev/null; rc_l_dobry=$?
  liczby "$tmp_l_cyt"   >/dev/null; rc_l_cyt=$?
  echo "  bez śladu rc=$rc_l_zly (oczek. 1) · ze śladem rc=$rc_l_dobry (oczek. 0) · mieszany rc=$rc_l_cyt (oczek. 1 — cytat BEZ śladu to nadal brak)"
  rm -f "$tmp_l_zly" "$tmp_l_dobry" "$tmp_l_cyt"
  rm -f "$tmp_zly" "$tmp_dobry" "$tmp_pusty" "$tmp_pelny"
  echo
  if [ "$rc_zly" -eq 1 ] && [ "$rc_dobry" -eq 0 ] && [ "$rc_pusty" -eq 1 ] && [ "$rc_pelny" -eq 0 ] && [ "$rc_l_zly" -eq 1 ] && [ "$rc_l_dobry" -eq 0 ] && [ "$rc_l_cyt" -eq 1 ]; then
    echo "✓ STRAŻ ŻYWA: oblała chorego, przepuściła zdrowego, --raport wyprowadza werdykt z pliku."; return 0
  else
    echo "✗ STRAŻ MARTWA: rc_zly=$rc_zly rc_dobry=$rc_dobry rc_pusty=$rc_pusty rc_pelny=$rc_pelny liczby=$rc_l_zly/$rc_l_dobry/$rc_l_cyt"; return 1
  fi
}

case "${1:-}" in
  --lint)   shift; lint "${1:--}" ;;
  --raport) shift; raport "${1:-}" ;;
  --liczby) shift; liczby "${1:-}" ;;
  --test)   autotest ;;
  *) echo "użycie: --lint <plik|-> | --raport <plik> | --liczby <plik> | --test"; exit 2 ;;
esac
