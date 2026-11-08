#!/usr/bin/env bash
# rodowod.sh — RODOWÓD PRZED RADĄ (C1 pakietu 03.10.2026, prawo w AGENTS.md; blizny #78 · W18).
#
# PO CO. Trzy okna w jednej dobie dały tę samą złą radę o `straz_powtorzen.sh`, bo każde pracowało na własnym
# obrazie: drzewo nieświeże (P1), przyrząd-egzekutor bez wywołania na starcie (P2), prawo bez mechanizmu (P3).
# Ten przyrząd podaje pod nos, ZANIM instancja odpowie: czy drzewo jest świeże, jaka blizna przyrząd ustanowiła,
# co mówi o nim ostatni wątek i co o nim wie inwentarz. Nie wymusza PRZECZYTANIA (tego kod nie umie) —
# zostawia stempel, że rodowód został uruchomiony, i ślad, który C2 sprawdza przy commicie.
#
# UŻYCIE:  bash narzedzia/przyrzady/rodowod.sh <plik|fraza>      jedno wyjście, cztery bloki:
#   1 ŚWIEŻOŚĆ   git fetch (cicho, limit 20 s) → „drzewo świeże” albo „N commitów ZA origin” + tematy (do 8).
#                Brak sieci / brak origin → NIEZMIERZONE. Nigdy „świeże” bez pomiaru.
#   2 BLIZNY     numery #N z pierwszych 25 linii pliku → tytuł `## #N` i akapit **Klasa.** z kanon/ksiegi/BLEDY.md.
#   3 WĄTKI      wiersze prywatne/WATKI_OTWARTE.md z nazwą pliku (otwarte i zamknięte), od najnowszych, 300 znaków.
#   4 INWENTARZ  node narzedzia/przyrzady/inwentarz.js "<nazwa bez rozszerzenia>".
#   Stempel: .git/kronos_rodowod/<ścieżka z / → _> (data godzina) — czyta go ostrzeżenie C2 w pre-commit.
# rc=0 zawsze (to miara, nie bramka); rc=2 przy złym wywołaniu.
#
# ZMIENNE (testy): RODOWOD_BLEDY · RODOWOD_WATKI — ścieżki zamiast domyślnych.
set -u
_SS="$(dirname "$0")/../silniki/strefa_st.sh"; if [ -f "$_SS" ]; then . "$_SS"; else _STREFA_ST=Europe/Warsaw; fi   # strefa instancji (wspólny fragment strefa_st.sh → tz_pl.js: KRONOS_TZ > instancja.json > package.json); psuty instancja.json = „STREFA?" + komunikat, nie cichy powrót do Warszawy

if [ "${1:-}" = "--test" ]; then
  SAM="$(cd "$(dirname "$0")" && pwd)/$(basename "$0")"
  T="$(mktemp -d)"; trap 'rm -rf "$T"' EXIT
  z=0; o=0
  spr() { if [ "$2" = "$3" ]; then echo "  ✓ $1"; z=$((z+1)); else echo "  ✗ $1 (rc=$2, oczekiwano $3)"; o=$((o+1)); fi; }
  echo "╔═══ RODOWÓD — TOR ═══╗"
  git init -q --bare -b main "$T/origin.git"
  git clone -q "$T/origin.git" "$T/w" 2>/dev/null
  W="$T/w"; cd "$W" || exit 1
  git config user.email t@t; git config user.name t
  mkdir -p kanon/ksiegi prywatne narzedzia/straze
  cat > kanon/ksiegi/BLEDY.md <<'EOB'
## #78 (ręka) WŁASNY POPRZEDNI MELDUNEK PODANY JAKO POMIAR (29.08.2026) · RODZINA: POMIAR/TESTY

**Objaw.** Cztery tury tego samego alarmu.

**Klasa.** Reprodukowalność potwierdza TRWAŁOŚĆ zjawiska, nie jego ZASADNOŚĆ.

**Inne.** Nie to.

## #79 — INNA BLIZNA

**Klasa.** To nie ta.
EOB
  printf '#!/usr/bin/env bash\n# straz_a — nośnik blizny #78.\n' > narzedzia/straze/straz_a.sh
  printf '#!/usr/bin/env bash\n# straz_b — bez numeru w nagłówku.\n' > narzedzia/straze/straz_b.sh
  printf '%s\n' '- [x] **[01.10] straz_a: stary wątek** — coś' '- [ ] **[03.10] straz_a: nowy wątek** — coś nowszego' '- [ ] **[02.10] inny plik** — nie dotyczy' > prywatne/WATKI_OTWARTE.md
  git add -A; git commit -q -m init; git push -q origin main 2>/dev/null
  W1="$(bash "$SAM" narzedzia/straze/straz_a.sh 2>&1)"
  printf '%s' "$W1" | grep -q 'drzewo świeże'; spr "(+) bez nowych commitów na origin → „drzewo świeże”" $? 0
  printf '%s' "$W1" | grep -q 'WŁASNY POPRZEDNI MELDUNEK' && printf '%s' "$W1" | grep -q 'TRWAŁOŚĆ zjawiska'; spr "(+) plik z blizną #78 → tytuł i akapit Klasa z BLEDY" $? 0
  printf '%s' "$W1" | grep -q 'INNA BLIZNA'; spr "(−) cudza blizna (#79) NIE wchodzi" $? 1
  L1="$(printf '%s' "$W1" | grep -n 'nowy wątek' | head -1 | cut -d: -f1)"; L2="$(printf '%s' "$W1" | grep -n 'stary wątek' | head -1 | cut -d: -f1)"
  [ -n "$L1" ] && [ -n "$L2" ] && [ "$L1" -lt "$L2" ]; spr "(+) wątki od najnowszych ([03.10] przed [01.10]), cudzy wątek pominięty" $? 0
  printf '%s' "$W1" | grep -q 'inny plik'; spr "(−) wątek o innym pliku NIE wchodzi" $? 1
  grep -qE '^[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}$' .git/kronos_rodowod/narzedzia_straze_straz_a.sh 2>/dev/null; spr "(+) stempel powstał i niesie datę z godziną (.git/kronos_rodowod/…)" $? 0
  W2="$(bash "$SAM" narzedzia/straze/straz_b.sh 2>&1)"; rc=$?
  spr "(⊙) plik bez numeru → rc=0" $rc 0
  printf '%s' "$W2" | grep -q 'brak blizny w nagłówku'; spr "(−) plik bez numeru → „brak blizny w nagłówku” nazwane" $? 0
  git clone -q "$T/origin.git" "$T/w2" 2>/dev/null; ( cd "$T/w2" && git config user.email t@t && git config user.name t && echo x > nowy.txt && git add nowy.txt && git commit -q -m "ruch drugiego okna" && git push -q origin main 2>/dev/null )
  W3="$(bash "$SAM" narzedzia/straze/straz_a.sh 2>&1)"
  printf '%s' "$W3" | grep -q '1 commit.* ZA origin' && printf '%s' "$W3" | grep -q 'ruch drugiego okna'; spr "(−) origin poszedł dalej → „1 commit ZA origin” + temat" $? 0
  printf '%s' "$W3" | grep -q 'drzewo świeże'; spr "(−) drzewo za origin NIE jest „świeże”" $? 1
  printf '%s' "$W3" | grep -qE 'zmierzone [0-9]{2}:[0-9]{2}'; spr "(+) gałąź „N za origin” niesie stempel godziny (U1-05)" $? 0
  git remote set-url origin "$T/nie_ma_takiego.git"
  W4="$(bash "$SAM" narzedzia/straze/straz_a.sh 2>&1)"
  printf '%s' "$W4" | grep -q 'NIEZMIERZONE'; spr "(⊙) origin nieosiągalny → NIEZMIERZONE" $? 0
  printf '%s' "$W4" | grep -q 'drzewo świeże'; spr "(−) brak pomiaru NIGDY nie daje „świeże”" $? 1
  printf '%s' "$W4" | grep -qE 'zmierzone [0-9]{2}:[0-9]{2}'; spr "(+) gałąź „origin nieosiągalny” niesie stempel godziny (U1-05)" $? 0
  git remote remove origin
  W5="$(bash "$SAM" narzedzia/straze/straz_a.sh 2>&1)"
  printf '%s' "$W5" | grep -qE 'zmierzone [0-9]{2}:[0-9]{2}'; spr "(+) brak origin → linia ze stemplem godziny jest (U1-05)" $? 0
  printf '%s' "$W5" | grep -q 'drzewo świeże'; spr "(−) brak origin NIGDY nie daje „świeże”" $? 1
  bash "$SAM" >/dev/null 2>&1; spr "(⊙) bez argumentu → rc=2" $? 2
  echo "  zmierzone: zdanych $z · oblanych $o"
  [ "$o" -eq 0 ] && { echo "  ✓ RODOWÓD ŻYWY: podaje świeżość, bliznę i wątek; brak pomiaru nazywa."; exit 0; }
  echo "  ✗ RODOWÓD MARTWY"; exit 1
fi

CEL="${1:-}"
[ -n "$CEL" ] || { echo "użycie: bash narzedzia/przyrzady/rodowod.sh <plik|fraza> | --test" >&2; exit 2; }
ROOT="$(git rev-parse --show-toplevel 2>/dev/null)" || { echo "rodowod: nie jestem w repozytorium git" >&2; exit 2; }
cd "$ROOT" || exit 2
BLEDY="${RODOWOD_BLEDY:-kanon/ksiegi/BLEDY.md}"
WATKI="${RODOWOD_WATKI:-prywatne/WATKI_OTWARTE.md}"
NAZWA="$(basename "$CEL")"; NAZWA="${NAZWA%.*}"

echo "▤ RODOWÓD · $CEL"

# ── 1 ŚWIEŻOŚĆ ──
echo "── 1 ŚWIEŻOŚĆ"
BR="$(git rev-parse --abbrev-ref HEAD 2>/dev/null)"
ZM="zmierzone $(TZ="$_STREFA_ST" date '+%H:%M')"   # stempel godziny pomiaru w KAŻDEJ z czterech gałęzi (U1-05: dawniej tylko „świeże”)
if git remote get-url origin >/dev/null 2>&1 && [ -n "$BR" ] && [ "$BR" != "HEAD" ] \
   && timeout 20 git fetch -q origin "$BR" >/dev/null 2>&1; then
  N="$(git rev-list --count HEAD..FETCH_HEAD 2>/dev/null || echo "?")"
  if [ "$N" = "0" ]; then
    echo "   drzewo świeże (HEAD nie jest za origin/$BR; $ZM)"
  elif [ "$N" = "?" ]; then
    echo "   NIEZMIERZONE — fetch przeszedł, ale nie umiem policzyć HEAD..FETCH_HEAD ($ZM)"
  else
    echo "   ⚠ $N commitów ZA origin/$BR ($ZM) — przeczytaj, zanim odpowiesz (git log HEAD..FETCH_HEAD):"
    git log --format='      %h %s' HEAD..FETCH_HEAD | head -8 | cut -c1-150
  fi
else
  echo "   NIEZMIERZONE — brak osiągalnego origin albo fetch odmówił (nie zakładam, że drzewo jest świeże; $ZM)"
fi

# ── 2 BLIZNY ZAŁOŻYCIELSKIE ──
echo "── 2 BLIZNY ZAŁOŻYCIELSKIE (numery #N z pierwszych 25 linii)"
if [ -f "$CEL" ]; then
  NUMS="$(head -25 "$CEL" | grep -oE '#[0-9]{1,3}\b' | tr -d '#' | sort -un | head -6)"
  if [ -z "$NUMS" ]; then
    echo "   brak blizny w nagłówku — przyrząd nie niesie numeru swojej blizny; szukaj przez inwentarz (blok 4)"
  else
    for n in $NUMS; do
      if [ -f "$BLEDY" ] && grep -qE "^## #${n}([^0-9]|\$)" "$BLEDY"; then
        awk -v n="$n" 'BEGIN{pat="^## #" n "([^0-9]|$)"; c=0}
          $0 ~ pat && !on {print "   " substr($0,1,170); on=1; next}
          on && /^## #/ {exit}
          on && /^\*\*Klasa\.\*\*/ {k=1}
          on && k { if ($0 ~ /^[[:space:]]*$/) exit; if (c<4) printf "      %s\n", substr($0,1,300); c++ }' "$BLEDY"
      else
        echo "   #$n — numer z nagłówka bez wpisu w ${BLEDY##*/}"
      fi
    done
  fi
else
  echo "   „$CEL” nie jest plikiem — bloki 2 pomijam (blizny z nagłówka niedostępne); fraza idzie do wątków i inwentarza"
fi

# ── 3 WĄTKI ──
echo "── 3 WĄTKI (od najnowszych, $NAZWA)"
if [ -f "$WATKI" ] && grep -qF -- "$NAZWA" "$WATKI"; then
  grep -F -- "$NAZWA" "$WATKI" | awk '{ k=0; if (match($0,/\[[0-9][0-9]\.[0-9][0-9]\]/)) { d=substr($0,RSTART+1,2); m=substr($0,RSTART+4,2); k=m*100+d } printf "%04d\t%s\n", k, $0 }' \
    | sort -s -t$'\t' -k1,1nr | head -6 | cut -f2- | cut -c1-300 | sed 's/^/   /'
else
  echo "   brak wątku z „$NAZWA” w ${WATKI##*/}"
fi

# ── 4 INWENTARZ ──
echo "── 4 INWENTARZ"
if [ -f narzedzia/przyrzady/inwentarz.js ] && command -v node >/dev/null 2>&1; then
  node narzedzia/przyrzady/inwentarz.js "$NAZWA" 2>&1 | head -14 | cut -c1-150 | sed 's/^/   /'
else
  echo "   inwentarz.js niedostępny (brak pliku albo node) — nazwane, nie przemilczane"
fi

# ── STEMPEL ──
GD="$(git rev-parse --git-dir)"; mkdir -p "$GD/kronos_rodowod"
KLUCZ="$(printf '%s' "$CEL" | sed 's#^\./##; s#/#_#g')"
TZ="$_STREFA_ST" date '+%Y-%m-%d %H:%M' > "$GD/kronos_rodowod/$KLUCZ"
echo "── stempel: .git/kronos_rodowod/$KLUCZ ($(cat "$GD/kronos_rodowod/$KLUCZ")) — rada niesie bliznę + wątek + świeżość albo [BEZ RODOWODU]"
exit 0
