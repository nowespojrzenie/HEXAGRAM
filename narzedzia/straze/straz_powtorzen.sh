#!/usr/bin/env bash
# ═══ STRAŻ POWTÓRZEŃ (30.08.2026) — nośnik blizny #78 „MELDUNEK JAKO POMIAR" ═══
#
# PRAWO (#78, NOŚNA RAMA → M z nośnikiem): reprodukowalność potwierdza TRWAŁOŚĆ zjawiska,
# nie jego ZASADNOŚĆ. Stabilny fałszywy alarm wygląda jak trwały dług i tym różni się od
# pomiaru, że nie może zaprzeczyć. Zmierzone 29.08: „50 z 52 niedojrzałych" przez cztery tury —
# każda tura cytowała poprzednią; 50 było fałszywym alarmem jednej klasy predykatu.
#
# CO ROBI: (1) `--zapisz STRAZ STAN` dopisuje wiersz do rejestru (data · straż · stan), najwyżej
# jeden na KAŻDE wstanie (jednostka serii = wstanie, #78) — TYLKO alarmy aktywne; cisza nie jest wierszem, z jednym wyjątkiem (03.10, słowo
# twórcy „wiersz alarmu — jasne"): gdy alarm, który był w rejestrze, zgasł NA DOWODZIE ciszy (zmierzone zero
# albo jawny wzorzec ciszy w wyjściu straży), `--zgas STRAZ` dopisuje jeden wiersz końca `data straż OK` i seria
# wygasa. BRAK WYNIKU NIE JEST DOWODEM CISZY (licznik, który nie zmierzył, nie zamyka alarmu — 03.10 złapane
# na wzorcu „pliki" niepasującym do „plików"). (2) bieg liczy, ile WSTAŃ POD
# RZĄD ten sam stan tej samej straży stoi na końcu rejestru. Od PROG powtórzeń straż ŻĄDA odpowiedzi na
# DRUGIE pytanie — „czy predykat trafia" (nie: „czy regres") — w rejestrze odpowiedzi.
# Odpowiedź LICZY SIĘ tylko, gdy niesie komendę dowodu w grawisach (`…`) — „TAK" bez komendy
# jest rytuałem, przed którym ostrzega KOLEJKA_M.
#
# ZĘBY — DECYZJA 30.08 (twórca: „decyduj"): MIARA, nie bramka. rc=0 domyślnie, rc=1 tylko
# z `--twardo`. Powód: #74/#75/#77 to ta sama klasa (nie da się kodem wymusić, żeby ręka
# SPRAWDZIŁA zamiast zacytować); twarda bramka na rytualnej odpowiedzi odhaczałaby sama siebie.
# Zęby po trzech odlewach, z pomiarem: ile odpowiedzi niosło komendę, ile było „TAK".
# Mechanizm wymusza ZADANIE pytania, nie prawdę odpowiedzi — tyle, ile umie.
#
# ZAKRES (#56): rejestr i odpowiedzi to dwa pliki w kanon/pomiary; straż nie czyta innych rejestrów.
set -u
_STREFA_ST="$(node "$(dirname "$0")/../silniki/tz_pl.js" --strefa 2>/dev/null || echo Europe/Warsaw)"   # strefa instancji (tz_pl.js: KRONOS_TZ > instancja.json > package.json); stemple czasu
TRYB="${1:-}"
REJ="${POWT_REJESTR:-kanon/pomiary/ALARMY_szereg.txt}"
ODP="${POWT_ODPOWIEDZI:-kanon/pomiary/ALARMY_odpowiedzi.md}"
PROG="${POWT_PROG:-3}"

# ── SONDA: JAWNA LISTA LICZNIKÓW (scalone 30.08 z równolegle zbudowanego `echo_alarmu.sh`) ──
# DWIE RĘCE ZBUDOWAŁY TEN SAM NOŚNIK #78 tego samego dnia. Rozstrzygnięcie twórcy brzmiało
# „wyciągnij najlepsze z obu": z tamtej wersji wchodzi TO — lista alarmów śledzonych stoi
# W JEDNYM MIEJSCU, w przyrządzie, zamiast rosnąć w `wstan.sh` po dwie linie na licznik.
# Z tej wersji zostaje wszystko inne: rejestr append-only (cisza nie jest wierszem),
# odpowiedź ważna tylko z komendą dowodu, miara zamiast bramki.
# Format: klucz|komenda|wyrażenie. Wyrażenie z grupą → liczba; bez grupy → sam fakt trafienia
# daje stan symboliczny (tożsamość alarmu, nie jego rozmiar — liczba dryfuje, alarm stoi).
# KRYTERIUM WEJŚCIA: alarm, który ŚWIECI, ale NIE ZATRZYMUJE. Bramka twarda sondy nie
# potrzebuje — jej powtórzenie zatrzymuje pracę i samo się przypomina.
LICZNIKI="${POWT_LICZNIKI:-}"
[ -n "$LICZNIKI" ] || LICZNIKI='straz_dojrzalosci|bash narzedzia/straze/straz_dojrzalosci.sh|niedojrzałych ([0-9]+)
straz_kryteriow|bash narzedzia/straze/straz_kryteriow.sh|PRZETERMINOWANE[^:]*: ([0-9]+) plik|PRZETERMINOWANE: 0
pokrycie_m|node narzedzia/przyrzady/pokrycie_m.js|· ([0-9]+) bez mechanizmu
straz_prerejestrow|bash narzedzia/straze/straz_prerejestrow.sh|PREREJESTR po terminie|nic po terminie|nic do pilnowania'

# Format rozszerzony (03.10): klucz|komenda|wyrażenie|DOWÓD CISZY (opcjonalny, ERE). Licznik liczbowy ma dowód
# w samym zerze (zmierzone „0"). Licznik symboliczny zamyka alarm WYŁĄCZNIE, gdy wyjście niesie dowód ciszy;
# bez czwartego pola i bez zera brak trafienia znaczy „niezmierzone" — alarm nie jest zamykany.
sonda() {
  printf '%s\n' "$LICZNIKI" | while IFS='|' read -r klucz kom wyr gasnie; do
    [ -n "$klucz" ] || continue
    _o="$($kom 2>&1 || true)"
    case "$wyr" in
      *'('*) _st="$(printf '%s' "$_o" | grep -oE "$wyr" | head -1 | grep -oE '[0-9]+' | head -1)" ;;
      *)     printf '%s' "$_o" | grep -qE "$wyr" && _st="AKTYWNY" || _st="" ;;
    esac
    if [ -n "$_st" ] && [ "$_st" != "0" ]; then
      zapisz "$klucz" "$_st"                                   # alarm aktywny → wiersz
    elif [ "$_st" = "0" ]; then
      zgas "$klucz"                                            # zmierzone zero = dowód ciszy
    elif [ -n "$gasnie" ] && printf '%s' "$_o" | grep -qE "$gasnie"; then
      zgas "$klucz"                                            # jawny dowód ciszy w wyjściu straży
    fi                                                         # inaczej: niezmierzone, rejestr bez zmian
  done
}

zgas() {   # STRAZ — wiersz końca `data straż OK`, tylko po alarmie (ostatni stan ≠ OK); drugi raz nie dopisze, bo ostatni stan już OK
  [ -f "$REJ" ] || return 0
  _zs="$(ostatni_stan "$1")"
  [ -n "$_zs" ] && [ "$_zs" != "OK" ] && zapisz "$1" OK
  return 0
}

zapisz() {   # STRAZ STAN — jeden wiersz na każde wstanie z aktywnym alarmem (jednostka serii = wstanie, #78)
  mkdir -p "$(dirname "$REJ")"
  printf '%s\n' "$(TZ="$_STREFA_ST" date '+%Y-%m-%d') $1 $2" >> "$REJ"
}

# ile WSTAŃ pod rząd ostatni stan straży $1 powtarza się na końcu jej szeregu.
# JEDNOSTKA = WSTANIE — bo tak mierzy #78: powtórzenia z meldunku do meldunku, nie z doby do doby.
# RODOWÓD (zapisany, żeby rada nie wróciła czwarty raz): wariant A „×N wstań" (03.10 12:54, po sprostowaniu
# B→A) → „dzień" (14:34–14:50, ta sesja, rada na nieświeżym drzewie, wykonana jako e479935) → A znów (C0 pakietu
# PAKIET_0310_rodowod_przed_rada). Argument „dublety z wielu wstań jednego dnia zawyżają serię" jest prawdziwy
# (zmierzone: pokrycie_m 25→13, straz_prerejestrow 26→7), ale to jest wypowiedź przyrządu o tym, ile razy alarm
# NIE dostał odpowiedzi — wstanie bez odpowiedzi to powtórzenie. Cena A (nazwana, nie naprawiana tu): każde wstanie
# zostawia zmianę w śledzonym rejestrze; rejestr gubi wstania sesji, które nie wypchnęły.
seria() {
  awk -v s="$1" '$2==s { v[++n]=$3 } END{ if(n==0){print 0; exit}; k=0; for(i=n;i>=1;i--){ if(v[i]==v[n]) k++; else break }; print k }' "$REJ"
}
ostatni_stan() { awk -v s="$1" '$2==s {v=$3} END{print v}' "$REJ"; }

# 0 = jest odpowiedź z komendą dla (straż, stan); 1 = brak
ma_odpowiedz() {
  [ -f "$ODP" ] || return 1
  grep -F "| $1 |" "$ODP" | grep -F "| $2 |" | grep -qE '`[^`]+`'
}

bieg() {
  echo "▤ STRAŻ POWTÓRZEŃ (#78) — czy alarm, który się powtarza, dostał drugie pytanie:"
  if [ ! -s "$REJ" ]; then echo "   ⓘ rejestr alarmów pusty — zero znaczące (żaden alarm nie był aktywny przy wstaniu)."; return 0; fi
  local zle=0 s n st
  for s in $(awk '{print $2}' "$REJ" | sort -u); do
    n="$(seria "$s")"; st="$(ostatni_stan "$s")"
    if [ "$st" = "OK" ]; then echo "   · $s zgasł (wiersz końca OK) — seria wygasła"; continue; fi
    if [ "$n" -ge "$PROG" ]; then
      if ma_odpowiedz "$s" "$st"; then
        echo "   ✓ $s = $st ×$n wstań — odpowiedziano na drugie pytanie (z komendą dowodu)."
      else
        echo "   ✗ $s = $st ×$n wstań POD RZĄD, BEZ ODPOWIEDZI. Drugie pytanie: CZY PREDYKAT TRAFIA? (nie: czy regres)"
        echo "      → wiersz w $ODP: | data | $s | $st | TAK/NIE | \`komenda, która to rozstrzygnęła\` |"
        zle=1
      fi
    else
      echo "   · $s = $st ×$n wstań (poniżej progu $PROG)"
    fi
  done
  [ "$zle" -eq 0 ] && return 0
  echo "   (MIARA: rc=0 — zęby po trzech odlewach; \`--twardo\` daje rc=1)"
  [ "$TRYB" = "--twardo" ] && return 1
  return 0
}

# --sonda: zbierz stany z jawnej listy liczników, potem PRZEJDŹ DO BIEGU. Wywołanie stoi TU,
# a nie przy odczycie $1 — funkcje muszą już istnieć (pierwsza wersja wołała sondę o dwadzieścia
# linii przed jej definicją: shell czyta plik sekwencyjnie).
if [ "$TRYB" = "--sonda" ]; then sonda; TRYB=""; fi
if [ "$TRYB" = "--zapisz" ]; then zapisz "$2" "$3"; exit 0; fi
if [ "$TRYB" = "--zgas" ]; then zgas "$2"; exit 0; fi

if [ "$TRYB" = "--test" ]; then
  # ── TOR SONDY (30.08, wkład ze scalonej wersji) ──────────────────────────────────
  # Dwustronny: licznik z wartością MUSI trafić do rejestru, licznik z zerem NIE MOŻE.
  # „Cisza nie jest wierszem" to prawo tej straży — sonda nie ma prawa go złamać hurtem.
  _TS="$(mktemp -d)"
  POWT_REJESTR="$_TS/rej" POWT_LICZNIKI='a|echo 7|^([0-9]+)$' bash "$0" --sonda >/dev/null 2>&1
  grep -q ' a 7$' "$_TS/rej" 2>/dev/null || { echo "  ✗ sonda nie zapisala wartosci"; rm -rf "$_TS"; exit 1; }
  POWT_REJESTR="$_TS/rej0" POWT_LICZNIKI='z|echo 0|^([0-9]+)$' bash "$0" --sonda >/dev/null 2>&1
  if [ -s "$_TS/rej0" ]; then echo "  ✗ sonda zapisala ZERO (cisza nie jest wierszem)"; rm -rf "$_TS"; exit 1; fi
  rm -rf "$_TS"
  T="$(mktemp -d)"; trap 'rm -rf "$T"' EXIT
  z=0; o=0
  spr() { if [ "$2" = "$3" ]; then echo "  ✓ $1"; z=$((z+1)); else echo "  ✗ $1 (rc=$2, oczekiwano $3)"; o=$((o+1)); fi; }
  echo "╔═══ STRAŻ POWTÓRZEŃ — TOR (#38) ═══╗"
  export POWT_REJESTR="$T/rej.txt" POWT_ODPOWIEDZI="$T/odp.md"
  SAM="$(cd "$(dirname "$0")" && pwd)/$(basename "$0")"
  : > "$POWT_REJESTR"
  bash "$SAM" --twardo >/dev/null; spr "(⊙) pusty rejestr = zero znaczące" $? 0
  printf '2026-08-27 dojrzalosc 52\n2026-08-28 dojrzalosc 52\n' > "$POWT_REJESTR"
  bash "$SAM" --twardo >/dev/null; spr "(+) ×2 poniżej progu — bez żądania" $? 0
  printf '2026-08-29 dojrzalosc 52\n' >> "$POWT_REJESTR"
  bash "$SAM" --twardo >/dev/null; spr "(−) ×3 pod rząd bez odpowiedzi — ŻĄDA (twardo rc=1)" $? 1
  bash "$SAM" >/dev/null; spr "(⊙) to samo jako MIARA — rc=0, żądanie w tekście" $? 0
  printf '| 2026-08-29 | dojrzalosc | 52 | TAK |  |\n' > "$POWT_ODPOWIEDZI"
  bash "$SAM" --twardo >/dev/null; spr "(−) odpowiedź BEZ komendy nie liczy się (rytuał)" $? 1
  printf '| 2026-08-29 | dojrzalosc | 52 | NIE | `bash straz_dojrzalosci.sh --debug` |\n' > "$POWT_ODPOWIEDZI"
  bash "$SAM" --twardo >/dev/null; spr "(+) odpowiedź z komendą zamyka żądanie" $? 0
  printf '2026-08-30 dojrzalosc 0\n2026-08-31 dojrzalosc 52\n2026-09-01 dojrzalosc 52\n' >> "$POWT_REJESTR"
  bash "$SAM" --twardo >/dev/null; spr "(+) przerwana seria liczy od nowa (×2)" $? 0
  # ── JEDNOSTKA = WSTANIE (C0, 03.10): każde wstanie z alarmem to powtórzenie; dedup „dzień" był błędem tej sesji ──
  R2="$T/rej2.txt"
  printf '2026-09-02 wiele 7\n2026-09-02 wiele 7\n2026-09-02 wiele 7\n2026-09-02 wiele 7\n2026-09-02 wiele 7\n' > "$R2"
  POWT_REJESTR="$R2" bash "$SAM" --twardo >/dev/null; spr "(−) pięć wstań jednego dnia = ×5 — ŻĄDA (jednostka = wstanie)" $? 1
  R2b="$T/rej2b.txt"; printf '2026-09-02 dwa 7\n2026-09-02 dwa 7\n' > "$R2b"
  POWT_REJESTR="$R2b" bash "$SAM" --twardo >/dev/null; spr "(+) dwa wstania = ×2, poniżej progu — bez żądania" $? 0
  printf '2026-09-05 wiele 8\n2026-09-05 wiele 7\n' >> "$R2"
  POWT_REJESTR="$R2" bash "$SAM" --twardo >/dev/null; spr "(+) powrót stanu (8→7) liczy od nowa" $? 0
  R3="$T/rej3.txt"; : > "$R3"
  POWT_REJESTR="$R3" bash "$SAM" --zapisz x 5; POWT_REJESTR="$R3" bash "$SAM" --zapisz x 5
  [ "$(wc -l < "$R3" | tr -d ' ')" = "2" ]; spr "(−) to samo wstanie dwa razy = DWA wiersze (nie gubi powtórzenia)" $? 0
  POWT_REJESTR="$R3" bash "$SAM" --zapisz x 6
  [ "$(wc -l < "$R3" | tr -d ' ')" = "3" ]; spr "(−) zmiana stanu DOPISUJE (nie gubi zmiany)" $? 0
  # ── WIERSZ KOŃCA ALARMU (03.10): zamyka tylko na DOWODZIE ciszy; brak wyniku nie jest ciszą ──
  R4="$T/rej4.txt"; : > "$R4"
  POWT_REJESTR="$R4" bash "$SAM" --zgas nic
  [ ! -s "$R4" ]; spr "(⊙) zgas bez wcześniejszego alarmu = zero znaczące (cisza nie jest wierszem)" $? 0
  printf '2026-09-02 pal 4\n2026-09-03 pal 4\n2026-09-04 pal 4\n' > "$R4"
  POWT_REJESTR="$R4" bash "$SAM" --twardo >/dev/null; spr "(−) alarm ×3 dni bez odpowiedzi — ŻĄDA (przed zgaśnięciem)" $? 1
  POWT_REJESTR="$R4" bash "$SAM" --zgas pal; POWT_REJESTR="$R4" bash "$SAM" --zgas pal
  [ "$(grep -c ' pal OK$' "$R4")" = "1" ]; spr "(+) zgas po alarmie dopisuje JEDEN wiersz końca (drugi nie — ostatni stan już OK)" $? 0
  POWT_REJESTR="$R4" bash "$SAM" --twardo >/dev/null; spr "(+) po wierszu końca seria wygasa — brak żądania" $? 0
  printf '2026-09-30 pal 4\n' >> "$R4"
  POWT_REJESTR="$R4" bash "$SAM" --twardo >/dev/null; spr "(+) alarm wraca po OK — liczy od ×1" $? 0
  R5="$T/rej5.txt"; printf '2026-09-01 k 5\n' > "$R5"
  POWT_REJESTR="$R5" POWT_LICZNIKI='k|echo 0|^([0-9]+)$' bash "$SAM" --sonda >/dev/null 2>&1
  [ "$(tail -1 "$R5" | awk '{print $3}')" = "OK" ]; spr "(+) sonda: zmierzone ZERO zamyka alarm" $? 0
  printf '2026-09-01 k 5\n' > "$R5"
  POWT_REJESTR="$R5" POWT_LICZNIKI='k|echo brak|^([0-9]+)$' bash "$SAM" --sonda >/dev/null 2>&1
  [ "$(tail -1 "$R5" | awk '{print $3}')" = "5" ]; spr "(−) sonda: BRAK wyniku NIE zamyka (niezmierzone ≠ cisza)" $? 0
  POWT_REJESTR="$R5" POWT_LICZNIKI='k|bash /nie/ma/skryptu.sh|^([0-9]+)$' bash "$SAM" --sonda >/dev/null 2>&1
  [ "$(tail -1 "$R5" | awk '{print $3}')" = "5" ]; spr "(−) sonda: nieistniejąca komenda NIE zamyka" $? 0
  printf '2026-09-01 p AKTYWNY\n' > "$R5"
  POWT_REJESTR="$R5" POWT_LICZNIKI='p|echo cos innego|PREREJESTR po terminie|nic po terminie' bash "$SAM" --sonda >/dev/null 2>&1
  [ "$(tail -1 "$R5" | awk '{print $3}')" = "AKTYWNY" ]; spr "(−) licznik symboliczny bez dowodu ciszy NIE zamyka" $? 0
  POWT_REJESTR="$R5" POWT_LICZNIKI='p|echo ✓ 3 daty nic po terminie|PREREJESTR po terminie|nic po terminie' bash "$SAM" --sonda >/dev/null 2>&1
  [ "$(tail -1 "$R5" | awk '{print $3}')" = "OK" ]; spr "(+) licznik symboliczny z jawnym dowodem ciszy zamyka" $? 0
  # ── WZORZEC straz_kryteriow (03.10): „pliki" nie trafiał w „plików" (≥5) — rejestr miał tylko 2/3/4 ──
  _wk="$(printf '%s\n' "$LICZNIKI" | awk -F'|' '$1=="straz_kryteriow"{print $3}')"
  _gk="$(printf '%s\n' "$LICZNIKI" | awk -F'|' '$1=="straz_kryteriow"{print $4}')"
  _ex() { printf '%s' "$1" | grep -oE "$_wk" | head -1 | grep -oE '[0-9]+' | head -1; }
  [ "$(_ex '   ⚠ PRZETERMINOWANE — rozlicz (odhacz · przedłuż jawnie · skompostuj): 17 plików · 26 dat')" = "17" ]; spr "(+) straz_kryteriow: 17 plików trafia (odmiana ≥5)" $? 0
  [ "$(_ex '   ⚠ PRZETERMINOWANE — rozlicz (odhacz · przedłuż jawnie · skompostuj): 1 plik · 1 data')" = "1" ]; spr "(+) straz_kryteriow: 1 plik trafia" $? 0
  [ -z "$(_ex '   ◔ ≤7 DNI — wróć, zanim minie: 11 plików · 14 dat · 20 wierszy')" ]; spr "(−) linia ≤7 DNI NIE jest alarmem przeterminowanych" $? 0
  [ -n "$_gk" ] && printf '%s' '   ✓ PRZETERMINOWANE: 0 — żadna obietnica nie czeka po terminie' | grep -qE "$_gk"; spr "(+) dowód ciszy straz_kryteriow trafia w komunikat stanu czystego" $? 0
  echo "  zmierzone: zdanych $z · oblanych $o"
  [ "$o" -eq 0 ] && { echo "  ✓ STRAŻ ŻYWA: umie zażądać drugiego pytania i odrzucić odpowiedź bez dowodu."; exit 0; }
  echo "  ✗ STRAŻ MARTWA"; exit 1
fi

bieg
