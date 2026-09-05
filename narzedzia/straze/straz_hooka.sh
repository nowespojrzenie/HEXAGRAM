#!/usr/bin/env bash
# KRONOS · STRAŻ HOOKA (20.08.2026) — tory na `.githooks/pre-commit`.
#
# POWÓD ISTNIENIA: pre-commit niósł cztery zmechanizowane prawa (⓯ ⓰ ⓱ + PAT) i ANI
# JEDNEGO toru. `tory_strazy.sh` melduje „każda straż ma żywy tor", bo hook nie był
# w jego rejestrze — czyli miara nie obejmowała miejsca, w którym prawa są najtwardsze.
# Klasa #38 (reguła wyłącznie w dokumentacji) w przyrządzie, który sam mechanizuje reguły.
#
# Każdy tor: przypadek + (MUSI przejść) i przypadek − (MUSI zablokować). Hook uruchamiany
# w ATRAPIE REPO w /tmp — nigdy na żywym ciele (#54).
set -uo pipefail
HOOK="${HOOK:-$(cd "$(dirname "$0")/../.." && pwd)/.githooks/pre-commit}"

# ═══ TOR WŁASNY (#38 · #47) — 21.08.2026, dług nazwany w MOSTY #31 ═══
# TA STRAŻ SAMA JEST TOREM — i właśnie dlatego długo nie miała własnego. Zwolnienie
# uzasadniano tym, że mierzy kontekst, w którym bateria biegnie (#50). Zmierzone dziś:
# to uzasadnienie było za szerokie. Pytanie „czy umiem wykryć MARTWY hook" da się zadać
# uczciwie — podaje się jej ATRAPĘ hooka, o której z góry wiadomo, że nic nie blokuje,
# i wymaga OBLANIA. Rekurencji nie ma: atrapa żyje w mktemp, żywy hook nie jest ruszany (#54).
# Fikstura ODRÓŻNIALNA (#64): ten sam przebieg na atrapie ŻYWEJ musi przejść — inaczej
# „straż oblewa" byłoby nieodróżnialne od „straż oblewa zawsze".
if [ "${1:-}" = "--test" ]; then
  echo "╔═══ STRAŻ HOOKA — AUTOTEST (#38) ═══╗"
  TH="$(mktemp -d)"; z=0; o=0
  spr() { if [ "$2" = "$3" ]; then echo "  ✓ $1"; z=$((z+1)); else echo "  ✗ $1 (rc=$2, oczekiwano $3)"; o=$((o+1)); fi; }
  SAM="$(cd "$(dirname "$0")" && pwd)/$(basename "$0")"

  # (−) atrapa MARTWA: hook, który przepuszcza wszystko. Straż MUSI oblać.
  printf '#!/usr/bin/env sh\nexit 0\n' > "$TH/martwy"; chmod +x "$TH/martwy"
  WY="$(HOOK="$TH/martwy" bash "$SAM" 2>&1)" && _r=0 || _r=$?
  spr "MARTWY hook (przepuszcza wszystko) OBLEWA" "$_r" "1"
  # SAM rc NIE WYSTARCZA — zmierzone mutacją `hooka-martwy-hook-przechodzi`, która przeszła
  # ŚLEPO: zdjęcie JEDNEGO z ośmiu sprawdzianów nie zmieniało werdyktu, bo martwy hook
  # oblewał nadal przez pozostałe siedem. Tor mierzył „czy straż w ogóle woła", a pytanie
  # brzmi „czy KAŻDY jej sprawdzian żyje" (#49). Ta sama lekcja co przy zamku #61: przyrząd
  # musi NAZWAĆ POWÓD, a tor — sprawdzić, że nazwał wszystkie.
  for _b in niepelny-ladunek-przeszedl artefakt-interpolacji-przeszedl PAT-przeszedl-przez-hook niepoprawny-py-przeszedl; do
    case "$WY" in *"$_b"*) z=$((z+1)); echo "  ✓ martwy hook zgłoszony po nazwie: $_b" ;;
      *) o=$((o+1)); echo "  ✗ BRAK zgłoszenia '$_b' — sprawdzian martwy, a werdykt zielony z cudzego powodu" ;;
    esac
  done

  # (−) atrapa NADGORLIWA: hook, który blokuje wszystko. Też MUSI oblać —
  #     straż pilnuje OBU stron, nie tylko przecieku (#56: alarm szerszy niż sygnał).
  printf '#!/usr/bin/env sh\nexit 1\n' > "$TH/nadgorliwy"; chmod +x "$TH/nadgorliwy"
  HOOK="$TH/nadgorliwy" bash "$SAM" >/dev/null 2>&1 && _r=0 || _r=$?
  spr "NADGORLIWY hook (blokuje wszystko) OBLEWA" "$_r" "1"

  # (+) hook ŻYWY z repo — MUSI przejść. Bez tego przypadku dwa powyższe nie znaczą nic.
  bash "$SAM" >/dev/null 2>&1 && _r=0 || _r=$?
  spr "ZYWY hook z repo PRZECHODZI (odroznialnosc)" "$_r" "0"

  rm -rf "$TH"
  echo "  zmierzone: zdanych $z · oblanych $o"
  [ "$o" -eq 0 ] || { echo "  ✗ TOR OBLANY"; exit 1; }
  echo "  ✓ STRAŻ UMIE NIE PRZEJŚĆ — odróżnia hook żywy od martwego i od nadgorliwego."
  exit 0
fi

[ -f "$HOOK" ] || { echo "✗ brak .githooks/pre-commit"; exit 1; }

T="$(mktemp -d)"; trap 'rm -rf "$T"' EXIT
export GIT_AUTHOR_NAME=Straz GIT_AUTHOR_EMAIL=s@s GIT_COMMITTER_NAME=Straz GIT_COMMITTER_EMAIL=s@s
cd "$T" && git init -q . && mkdir -p h && cp "$HOOK" h/pre-commit && chmod +x h/pre-commit
git config core.hooksPath h
zle=""

# (+) commit kompletny MUSI przejść
echo "tresc" > plik.md && git add -A
git commit -qm start >/dev/null 2>&1 || zle="$zle kompletny-commit-zablokowany"

# (−) #35: plik ŚLEDZONY ma zmiany poza commitem → MUSI zablokować
echo "zmiana" >> plik.md
echo "nowy" > drugi.md && git add drugi.md
git commit -qm niepelny >/dev/null 2>&1 && zle="$zle niepelny-ladunek-przeszedl"
git add -A && git commit -qm "pelny" >/dev/null 2>&1 \
  || zle="$zle po-dodaniu-calosci-nadal-blokuje"

# (⊙) plik NIEŚLEDZONY obok commita NIE blokuje — nowy plik to normalna praca,
# a alarm szerszy niż sygnał uczy nie patrzeć (#56).
echo "luzem" > luzem.txt
echo "x" >> plik.md && git add plik.md
git commit -qm "z plikiem luzem" >/dev/null 2>&1 \
  || zle="$zle niesledzony-plik-blokuje-commit"

# (−) #12 ARTEFAKT INTERPOLACJI: literalne \n poza blokiem kodu MUSI zablokować
printf 'tresc z literalnym \\n w srodku\n' > art.md && git add -A
git commit -qm artefakt >/dev/null 2>&1 && zle="$zle artefakt-interpolacji-przeszedl"
rm -f art.md
# (⊙) ten sam znak w INLINE-CODE jest legalnym cytatem — nie może blokować.
# Złapane na pierwszym prawdziwym commicie: zamek zatrzymał opisy własnych blizn.
printf 'opis sklejki `3\\n99` w zdaniu\n' > inline.md && git add -A
git commit -qm "inline code" >/dev/null 2>&1 || zle="$zle inline-code-zablokowany"

# (⊙) ten sam znak WEWNĄTRZ bloku kodu jest legalną treścią — nie może blokować (#56)
printf 'opis\n```\necho "a\\nb"\n```\n' > kod.md && git add -A
git commit -qm "blok kodu" >/dev/null 2>&1 || zle="$zle blok-kodu-zablokowany"

# (−) PAT w treści MUSI zablokować (prawo starsze, dotąd bez toru)
# Fikstura PAT składana W LOCIE z kawałków — zapisana dosłownie blokowałaby commit
  # tego właśnie pliku przez ten właśnie hook (zmierzone: hook zatrzymał commit straży).
  PRE="github"; SRO="_pat_11"; POST="ABCDEFGHIJKLMNOPQRSTU_vwxyz0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ012"
  printf 'token: %s%s%s\n' "$PRE" "$SRO" "$POST" > sekret.md
git add -A
git commit -qm "z patem" >/dev/null 2>&1 && zle="$zle PAT-przeszedl-przez-hook"
rm -f sekret.md && git add -A && git commit -qm sprzatanie >/dev/null 2>&1

# (⊙/−) #12 SKŁADNIA PYTHONA: plik z polską treścią w POTRÓJNYCH cudzysłowach przechodzi,
# plik z niedomkniętym literałem NIE. Mierzymy skutek (parsowanie), nie formę cytowania —
# literalny lint reguły dawał 58 fałszywych trafień na jednym pliku repo (#56).
printf 'x = """polska treść z cudzysłowem: \u201eaaa\u201d"""\n' > dobry.py
git add -A
git commit -qm "poprawny py" >/dev/null 2>&1 || zle="$zle poprawny-py-zablokowany"
printf 'x = "treść z " cudzysłowem"\n' > zly.py
git add -A
git commit -qm "zly py" >/dev/null 2>&1 && zle="$zle niepoprawny-py-przeszedl"
rm -f zly.py && git add -A && git commit -qm sprzatanie2 >/dev/null 2>&1

# (−/+/⊙) #67 ŚWIEŻOŚĆ ODCISKU: plik w stage z NIEŚWIEŻYM odciskiem w _HASHE.txt MUSI
# zablokować; po odnowieniu odcisku MUSI przejść; plik SPOZA rejestru NIE blokuje (#56).
# Odcisk liczony tak, jak liczy go weryfikacja.js i hashuj.sh: sha256 pierwsze 12 znaków.
printf 'wersja pierwsza\n' > odc.md
printf '%s  odc.md\n' "$(sha256sum odc.md | cut -c1-12)" > _HASHE.txt
git add -A && git commit -qm "odcisk swiezy" >/dev/null 2>&1 || zle="$zle swiezy-odcisk-zablokowany"
printf 'wersja druga\n' > odc.md && git add odc.md
git commit -qm "odcisk nieswiezy" >/dev/null 2>&1 && zle="$zle nieswiezy-odcisk-przeszedl"
printf '%s  odc.md\n' "$(sha256sum odc.md | cut -c1-12)" > _HASHE.txt && git add -A
git commit -qm "odcisk odnowiony" >/dev/null 2>&1 || zle="$zle odnowiony-odcisk-zablokowany"
printf 'poza rejestrem\n' > obcy.md && git add obcy.md
git commit -qm "poza rejestrem" >/dev/null 2>&1 || zle="$zle plik-poza-rejestrem-blokuje"

if [ -z "$zle" ]; then
  echo "  ✓ HOOK ŻYWY: blokuje niepełny ładunek (#35), nieświeży odcisk (#67), PAT i niesparsowany .py (⓬);"
  echo "    przepuszcza commit kompletny, plik nieśledzony i polską treść w potrójnych"
  echo "    cudzysłowach (bez alarmu szerszego niż sygnał)."
  exit 0
fi
echo "  ✗ HOOK MARTWY:$zle"
exit 1
