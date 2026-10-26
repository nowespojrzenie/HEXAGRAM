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
#   bash straz_deklamatora.sh --model [dni=30] [--szereg]   # czytnik kanon/pomiary/MODEL_deklarowany.txt (BLEDY #134 P6, 13.10)
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

# ── TRYB --model (13.10.2026, BLEDY #134 P6 — decyzja Fable 22:5x) ──
# Czytnik rejestru MODEL_deklarowany.txt (do 13.10 pisany, nigdy czytany przy wstaniu). Jedna linia, bez czytania ręką:
#   ▤ DEKLARACJA MODELU (30 dni): tur N · rozjazd tabeli k (p %) · bez noty m
# tur = wiersze z datą w oknie i zgodnością dokładnie T albo N (mieszane „N … / T …”, „?” i puste nie są mierzalne) · rozjazd = kolumna 5 dokładnie „N” (wiersze mieszane „N … / T …” i „?” nie liczą się) ·
# bez noty = rozjazd ∧ kolumna 6 bez świadectwa „przed”. NOTA = pierwszy znak T · słowo STOP · tekst z „przed (pracą|robotą|wykonaniem|ruchem)” lub „w nagłówku”
#   BEZ znacznika „po” (po fakcie · post factum · po biegu · po robocie · po pracy · w meldunku po · wstecz). Litera N to werdykt autora o sobie, tekst „przed …” to
#   świadectwo czasu — świadectwo wygrywa (Fable 14.10, WATKI l.769 pkt 2; zawęża „N zostaje N” z 925a9e1). rc=1 gdy bez noty ≥ 3 (alarm), inaczej 0; rc=2 zły argument.
# Daty: „RRRR-MM-DD HH:MM…” (z ~, zakresem, 'x') i „DD.MM HH:Mx” (rok z dnia pomiaru). --szereg dopisuje „RRRR-MM-DD deklaracja_modelu <m>”.
# ZASIĘG NAZWANY: mierzy deklarację (picker↔tabela) i notę w chwili mówienia — NIE mierzy, kto faktycznie pisał (niemierzalne, #114).
model() {
  local dni=30 szereg=0 plik="${MODEL_PLIK:-kanon/pomiary/MODEL_deklarowany.txt}" rej="${MODEL_SZEREG:-kanon/pomiary/ALARMY_szereg.txt}"
  while [ $# -gt 0 ]; do
    case "$1" in
      --szereg) szereg=1 ;;
      ''|*[!0-9]*) echo "model: nieznany argument '$1' (oczekiwane: liczba dni albo --szereg)" >&2; return 2 ;;
      *) dni="$1" ;;
    esac
    shift
  done
  # GOŚĆ (14.10, odlew v1.8.2, gotowosc bramka 7): instancja bez rejestru deklaracji = zero znaczące, nie „niedostępna”.
  [ -f "$plik" ] || { echo "   ⓘ model: brak rejestru $plik — instancja bez deklaracji modelu (zero znaczące)"; return 0; }
  local dzis="${STRAZ_DZIS:-$(date +%F)}" granica
  granica="$(date -d "$dzis - $dni days" +%F 2>/dev/null)" || { echo "model: nie umiem policzyć okna (date -d)" >&2; return 2; }
  local wynik tur roz bez
  wynik="$(awk -F'|' -v dzis="$dzis" -v gr="$granica" '
    function trim(x){ gsub(/^[ \t]+|[ \t]+$/, "", x); return x }
    BEGIN { rok = substr(dzis,1,4) + 0; mies = substr(dzis,6,2) + 0 }
    /^#/ || NF < 6 { next }
    {
      split(trim($1), t, " "); d = t[1]; data = ""
      if (d ~ /^[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]$/) data = d
      else if (d ~ /^[0-9]+\.[0-9][0-9]$/) {
        split(d, dm, "."); r = rok; if (dm[2] + 0 > mies) r = rok - 1
        data = sprintf("%04d-%02d-%02d", r, dm[2] + 0, dm[1] + 0)
      } else next
      if (data < gr || data > dzis) next
      zg = trim($5)
      if (zg == "T" || zg == "N") tur++
      n6 = trim($6); nota = substr(n6, 1, 1); t6 = tolower(n6)
      przed = (t6 ~ /przed (prac|robot|wykonani|ruch)|w nagłówk|w naglowk/)                   # świadectwo czasu: nazwane PRZED ruchem
      po = (t6 ~ /po fakcie|post factum|po biegu|po robocie|po pracy|w meldunku po|wstecz/)   # znacznik „po” unieważnia „przed” (wiersz 13: „PO fakcie … nie przeze mnie w chwili mówienia”)
      if (zg == "N") { roz++; if (nota != "T" && substr(n6, 1, 4) != "STOP" && !(przed && !po)) bez++ }   # STOP = nota (Opus 13.10 23:1x); tekst „przed” bez „po” = nota (Fable 14.10)
    }
    END { printf "%d %d %d\n", tur + 0, roz + 0, bez + 0 }' "$plik")"
  set -- $wynik; tur=$1; roz=$2; bez=$3
  local pr=0; [ "$tur" -gt 0 ] && pr=$(( (roz * 100 + tur / 2) / tur ))
  echo "▤ DEKLARACJA MODELU ($dni dni): tur $tur · rozjazd tabeli $roz ($pr %) · bez noty $bez"
  if [ "$szereg" = 1 ]; then
    local wiersz="$dzis deklaracja_modelu $bez" ost
    local sz; sz="$(dirname "$0")/../silniki/szereg.sh"   # cz.4 25.10: wiersz serii przez bufor szereg.sh (drzewo czyste po wstaniu); bez przyrządu — wprost jak dotąd
    if [ -f "$sz" ]; then ost="$(bash "$sz" czytaj "$rej" 2>/dev/null | grep ' deklaracja_modelu ' | tail -1)"; else ost="$(grep ' deklaracja_modelu ' "$rej" 2>/dev/null | tail -1)"; fi
    if [ "$ost" != "$wiersz" ]; then if [ -f "$sz" ]; then bash "$sz" dopisz "$rej" "$wiersz" || echo "   ⚠ szereg niezapisany: $rej"; else printf '%s\n' "$wiersz" >> "$rej"; fi; fi
  fi
  if [ "$bez" -ge 3 ]; then
    echo "   ✗ ALARM: $bez rozjazdy bez noty w oknie — nota ma stać w chwili mówienia, nie po (AGENTS.md „STOP PRZED, NIE KOMENTARZ PO”)."
    return 1
  fi
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
  # TOR --model (13.10, BLEDY #134 P6; 14.10 Fable: świadectwo „przed”): fikstura 8 wierszy w oknie, oba formaty daty, jeden poza oknem.
  # Oczekiwane: tur 8, rozjazd 6, bez noty 2 (d „—”, i pusta), rc=0 · h „N — … w nagłówku przed robotą” = nota · m3: „—”, „po biegu”, „w nagłówku … po robocie” = 3 braki, rc=1.
  echo "── TEST ⊛ (--model: fikstura → bez noty 2 rc=0; trzy bez noty → rc=1; N z tekstem „przed” = nota; pusta = brak; „po” unieważnia „przed”) ──"
  tmp_m="$(mktemp)"; tmp_m3="$(mktemp)"; tmp_mr="$(mktemp)"
  cat > "$tmp_m" <<'EOF'
# komentarz
2026-10-13 21:00–21:3x | a | Sonnet | Sonnet | T | —
13.10 21:1x | b | Sonnet | Opus | N | T (nazwane w nagłówku w chwili mówienia)
2026-10-12 ~09:2x | c | Fable | Opus | N | T — nazwane
2026-10-11 10:00 | d | Sonnet | Haiku | N | —
2026-10-10 10:00 | e | Sonnet | Sonnet | T | T (zbędna nota)
2026-10-09 10:00 | g | Sonnet | Opus | N | STOP — prośba o przełączenie (gołe STOP, bez słowa „przed”: świadek dla mutacji stop-nie-jest-nota)
2026-10-08 10:00 | h | Sonnet | Opus | N | N — nazwane w nagłówku przed robotą (część 1; słowo twórcy „Sonnet część 2")
2026-10-07 10:00 | i | Sonnet | Opus | N |
2026-08-01 10:00 | f | x | y | N | —
EOF
  printf '2026-10-13 10:00 | a | S | O | N | —\n2026-10-12 10:00 | b | S | O | N | N (nazwane w meldunku po biegu)\n2026-10-11 10:00 | c | S | O | N | N — rozjazd nazwany w nagłówku dopiero po robocie, wstecz\n' > "$tmp_m3"
  out_m="$(STRAZ_DZIS=2026-10-13 MODEL_PLIK="$tmp_m" bash "$0" --model 30 2>&1)"; rc_m=$?
  out_m3="$(STRAZ_DZIS=2026-10-13 MODEL_PLIK="$tmp_m3" bash "$0" --model 30 2>&1)"; rc_m3=$?
  : > "$tmp_mr"; STRAZ_DZIS=2026-10-13 MODEL_PLIK="$tmp_m" MODEL_SZEREG="$tmp_mr" bash "$0" --model 30 --szereg >/dev/null 2>&1
  STRAZ_DZIS=2026-10-13 MODEL_PLIK="$tmp_m" MODEL_SZEREG="$tmp_mr" bash "$0" --model 30 --szereg >/dev/null 2>&1
  out_mb="$(MODEL_PLIK=/nonexistent/MODEL_brak.txt bash "$0" --model 7 2>&1)"; rc_mb=$?
  mb_ok=0; printf '%s' "$out_mb" | grep -q 'brak rejestru' && mb_ok=1
  m_ok=0; printf '%s' "$out_m" | grep -q 'tur 8 · rozjazd tabeli 6 (75 %) · bez noty 2' && m_ok=1
  m3_ok=0; printf '%s' "$out_m3" | grep -q 'bez noty 3' && m3_ok=1
  sz_ok=0; [ "$(cat "$tmp_mr")" = "2026-10-13 deklaracja_modelu 2" ] && sz_ok=1
  echo "  fikstura: rc=$rc_m (oczek. 0) linia=$m_ok (oczek. 1) · trzy bez noty: rc=$rc_m3 (oczek. 1) linia=$m3_ok · szereg bez dubla=$sz_ok (oczek. 1) · brak rejestru: rc=$rc_mb (oczek. 0) nota=$mb_ok (oczek. 1)"
  rm -f "$tmp_m" "$tmp_m3" "$tmp_mr"
  rm -f "$tmp_zly" "$tmp_dobry" "$tmp_pusty" "$tmp_pelny"
  echo
  if [ "$rc_zly" -eq 1 ] && [ "$rc_dobry" -eq 0 ] && [ "$rc_pusty" -eq 1 ] && [ "$rc_pelny" -eq 0 ] && [ "$rc_l_zly" -eq 1 ] && [ "$rc_l_dobry" -eq 0 ] && [ "$rc_l_cyt" -eq 1 ] && [ "$rc_m" -eq 0 ] && [ "$m_ok" -eq 1 ] && [ "$rc_m3" -eq 1 ] && [ "$m3_ok" -eq 1 ] && [ "$sz_ok" -eq 1 ] && [ "$rc_mb" -eq 0 ] && [ "$mb_ok" -eq 1 ]; then
    echo "✓ STRAŻ ŻYWA: oblała chorego, przepuściła zdrowego, --raport wyprowadza werdykt z pliku."; return 0
  else
    echo "✗ STRAŻ MARTWA: rc_zly=$rc_zly rc_dobry=$rc_dobry rc_pusty=$rc_pusty rc_pelny=$rc_pelny liczby=$rc_l_zly/$rc_l_dobry/$rc_l_cyt model=$rc_m/$m_ok/$rc_m3/$m3_ok/$sz_ok/$rc_mb/$mb_ok"; return 1
  fi
}

case "${1:-}" in
  --lint)   shift; lint "${1:--}" ;;
  --raport) shift; raport "${1:-}" ;;
  --liczby) shift; liczby "${1:-}" ;;
  --model)  shift; model "$@" ;;
  --test)   autotest ;;
  *) echo "użycie: --lint <plik|-> | --raport <plik> | --liczby <plik> | --model [dni] [--szereg] | --test"; exit 2 ;;
esac
