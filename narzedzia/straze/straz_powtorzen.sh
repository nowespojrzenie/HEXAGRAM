#!/usr/bin/env bash
# ═══ STRAŻ POWTÓRZEŃ (30.08.2026) — nośnik blizny #78 „MELDUNEK JAKO POMIAR" ═══
#
# PRAWO (#78, NOŚNA RAMA → M z nośnikiem): reprodukowalność potwierdza TRWAŁOŚĆ zjawiska,
# nie jego ZASADNOŚĆ. Stabilny fałszywy alarm wygląda jak trwały dług i tym różni się od
# pomiaru, że nie może zaprzeczyć. Zmierzone 29.08: „50 z 52 niedojrzałych" przez cztery tury —
# każda tura cytowała poprzednią; 50 było fałszywym alarmem jednej klasy predykatu.
#
# CO ROBI: (1) `--zapisz STRAZ STAN` dopisuje wiersz do rejestru append-only (data · straż · stan)
# — TYLKO alarmy aktywne, cisza nie jest wierszem. (2) bieg liczy, ile razy POD RZĄD ten sam
# stan tej samej straży stoi na końcu rejestru. Od PROG powtórzeń straż ŻĄDA odpowiedzi na
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
straz_kryteriow|bash narzedzia/straze/straz_kryteriow.sh|([0-9]+) pliki
pokrycie_m|node narzedzia/przyrzady/pokrycie_m.js|· ([0-9]+) bez mechanizmu
straz_prerejestrow|bash narzedzia/straze/straz_prerejestrow.sh|PREREJESTR po terminie'

sonda() {
  printf '%s\n' "$LICZNIKI" | while IFS='|' read -r klucz kom wyr; do
    [ -n "$klucz" ] || continue
    _o="$($kom 2>&1 || true)"
    case "$wyr" in
      *'('*) _st="$(printf '%s' "$_o" | grep -oE "$wyr" | head -1 | grep -oE '[0-9]+' | head -1)" ;;
      *)     printf '%s' "$_o" | grep -qE "$wyr" && _st="AKTYWNY" || _st="" ;;
    esac
    # CISZA NIE JEST WIERSZEM (prawo tej straży): zero i brak trafienia nie trafiają do rejestru.
    [ -n "$_st" ] && [ "$_st" != "0" ] && zapisz "$klucz" "$_st"
  done
}

zapisz() {   # STRAZ STAN
  mkdir -p "$(dirname "$REJ")"
  printf '%s %s %s\n' "$(TZ=Europe/Warsaw date '+%Y-%m-%d')" "$1" "$2" >> "$REJ"
}

# ile razy POD RZĄD ostatni stan straży $1 powtarza się na końcu jej szeregu
seria() {
  awk -v s="$1" '$2==s {v[++n]=$3} END{ if(n==0){print 0; exit}; k=0; for(i=n;i>=1;i--){ if(v[i]==v[n]) k++; else break }; print k }' "$REJ"
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
    if [ "$n" -ge "$PROG" ]; then
      if ma_odpowiedz "$s" "$st"; then
        echo "   ✓ $s = $st ×$n — odpowiedziano na drugie pytanie (z komendą dowodu)."
      else
        echo "   ✗ $s = $st ×$n POD RZĄD, BEZ ODPOWIEDZI. Drugie pytanie: CZY PREDYKAT TRAFIA? (nie: czy regres)"
        echo "      → wiersz w $ODP: | data | $s | $st | TAK/NIE | \`komenda, która to rozstrzygnęła\` |"
        zle=1
      fi
    else
      echo "   · $s = $st ×$n (poniżej progu $PROG)"
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
  echo "  zmierzone: zdanych $z · oblanych $o"
  [ "$o" -eq 0 ] && { echo "  ✓ STRAŻ ŻYWA: umie zażądać drugiego pytania i odrzucić odpowiedź bez dowodu."; exit 0; }
  echo "  ✗ STRAŻ MARTWA"; exit 1
fi

bieg
