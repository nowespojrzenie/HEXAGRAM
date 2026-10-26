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
# (K6/N8) HOOK, HOOK_RT i ROOT_KLON to UCHWYTY TORU: nikt poza własnym --test ich nie ustawia (git grep 23.10, inwentarz
# kanon/pomiary/N8_zmienne_sterownika_1910.csv). Ambient export (zapomniany, cudzy) podmieniał BADANY plik — „HOOK ŻYWY" nad hookiem,
# którego nikt nie badał. Tor podaje je razem z _HOOKA_TOR=1; bieg bez flagi (produkcja, bateria, wstan) zdejmuje je z otoczenia
# ZANIM je odczyta.
[ "${_HOOKA_TOR:-}" = 1 ] || unset HOOK HOOK_RT ROOT_KLON
HOOK="${HOOK:-$(cd "$(dirname "$0")/../.." && pwd)/.githooks/pre-commit}"
# HOOK_RT liczony TU, PRZED jakimkolwiek `cd` w reszcie pliku (fikstura pre-commit niżej
# robi `cd "$T"` w GŁÓWNEJ powłoce, bez subshellu, i zostaje tam do końca skryptu — liczenie
# ścieżki względem `$0` PO tym `cd` rozwiązywałoby ją względem złego katalogu, #53).
HOOK_RT="${HOOK_RT:-$(cd "$(dirname "$0")/../.." && pwd)/.githooks/reference-transaction}"
ROOT_KLON="${ROOT_KLON:-$(cd "$(dirname "$0")/../.." && pwd)}"

# ── K0 (23.09.2026) TRYB HOOKÓW W KLONIE, KTÓRY STOI — nie tylko w próbie ──────────────────
# Zmierzone 23.09 (HEAD 2ca7087): `reference-transaction` było w indeksie 100644. Świeży klon
# na Linuksie POMIJA taki hook („ignored because it's not set as executable"), a ta straż
# mimo to meldowała „HOOK ŻYWY na KAŻDEJ platformie" — jej fikstury kopiują hook do mktemp
# i robią chmod +x SAME, więc testowały przyrząd we własnej próbie, nie plik z klona (#115).
# Pytanie o TEN klon: tryb w INDEKSIE (to on jedzie do klonów) + bit x na dysku tutaj.
sprawdz_tryb_hookow() {   # $1 = korzeń klonu; ustawia TRYB_ZLE (puste = zdrowo)
  local root="$1" mode f
  TRYB_ZLE=""
  while read -r mode _ _ f; do
    case "$f" in .githooks/*) ;; *) continue ;; esac
    if [ "$mode" != "100755" ]; then
      echo "  ✗ TRYB: $f w indeksie = $mode, nie 100755 — git w świeżym klonie POMINIE ten hook"
      TRYB_ZLE="$TRYB_ZLE tryb-indeksu-$(basename "$f")"
    fi
    if [ ! -x "$root/$f" ]; then
      echo "  ✗ TRYB: $f bez bitu wykonywalności w TYM klonie"
      TRYB_ZLE="$TRYB_ZLE brak-x-$(basename "$f")"
    fi
  done < <(git -C "$root" ls-files -s .githooks/ 2>/dev/null)
  # K6/N4: hooki w indeksie i z bitem x NIC nie znaczą, gdy ten klon ich nie WOŁA — wstan.sh ustawiał
  # `core.hooksPath` z `|| true`. Odczyt zamiast wiary: wskazanie musi kończyć się na `.githooks`.
  local hp; hp="$(git -C "$root" config --get core.hooksPath 2>/dev/null)"
  case "$hp" in
    .githooks|*/.githooks) ;;
    *) echo "  ✗ HOOKSPATH: core.hooksPath='${hp:-<puste>}' w TYM klonie — hooki leżą, ale git ich nie woła"
       TRYB_ZLE="$TRYB_ZLE hookspath-niewpiety" ;;
  esac
}

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
  WY="$(_HOOKA_TOR=1 HOOK="$TH/martwy" bash "$SAM" 2>&1)" && _r=0 || _r=$?
  spr "MARTWY hook (przepuszcza wszystko) OBLEWA" "$_r" "1"
  # SAM rc NIE WYSTARCZA — zmierzone mutacją `hooka-martwy-hook-przechodzi`, która przeszła
  # ŚLEPO: zdjęcie JEDNEGO z ośmiu sprawdzianów nie zmieniało werdyktu, bo martwy hook
  # oblewał nadal przez pozostałe siedem. Tor mierzył „czy straż w ogóle woła", a pytanie
  # brzmi „czy KAŻDY jej sprawdzian żyje" (#49). Ta sama lekcja co przy zamku #61: przyrząd
  # musi NAZWAĆ POWÓD, a tor — sprawdzić, że nazwał wszystkie.
  for _b in niepelny-ladunek-przeszedl artefakt-interpolacji-przeszedl PAT-przeszedl-przez-hook niepoprawny-py-przeszedl marker-konfliktu-przeszedl; do
    case "$WY" in *"$_b"*) z=$((z+1)); echo "  ✓ martwy hook zgłoszony po nazwie: $_b" ;;
      *) o=$((o+1)); echo "  ✗ BRAK zgłoszenia '$_b' — sprawdzian martwy, a werdykt zielony z cudzego powodu" ;;
    esac
  done

  # (−) atrapa NADGORLIWA: hook, który blokuje wszystko. Też MUSI oblać —
  #     straż pilnuje OBU stron, nie tylko przecieku (#56: alarm szerszy niż sygnał).
  printf '#!/usr/bin/env sh\nexit 1\n' > "$TH/nadgorliwy"; chmod +x "$TH/nadgorliwy"
  _HOOKA_TOR=1 HOOK="$TH/nadgorliwy" bash "$SAM" >/dev/null 2>&1 && _r=0 || _r=$?
  spr "NADGORLIWY hook (blokuje wszystko) OBLEWA" "$_r" "1"

  # (+) hook ŻYWY z repo — MUSI przejść. Bez tego przypadku dwa powyższe nie znaczą nic.
  bash "$SAM" >/dev/null 2>&1 && _r=0 || _r=$?
  spr "ZYWY hook z repo PRZECHODZI (odroznialnosc)" "$_r" "0"
  # (K6/N8) TOR (−) NA OTOCZENIE: ambient HOOK/HOOK_RT/ROOT_KLON (stary export) NIE MOŻE podmienić badanego pliku. Wynik biegu
  # z podrzuconym martwym hookiem musi być równy wynikowi biegu czystego (porównanie, nie "0": nie zależy od stanu klonu).
  # Dawne ciało: HOOK="$TH/martwy" w otoczeniu → ✗ MARTWY nad hookiem, którego nikt nie wskazał (rc 1 ≠ rc czystego).
  bash "$SAM" >/dev/null 2>&1 && _rczysty=0 || _rczysty=$?
  HOOK="$TH/martwy" bash "$SAM" >/dev/null 2>&1 && _r=0 || _r=$?
  spr "OTOCZENIE: ambient HOOK=martwy nie podmienia badanego pliku (rc równy biegowi czystemu)" "$([ "$_r" = "$_rczysty" ] && echo 0 || echo "$_r≠$_rczysty")" "0"
  HOOK_RT="$TH/nie_ma_takiego" ROOT_KLON="$TH" bash "$SAM" >/dev/null 2>&1 && _r=0 || _r=$?
  spr "OTOCZENIE: ambient HOOK_RT/ROOT_KLON nie podmieniają badanego klonu (rc równy biegowi czystemu)" "$([ "$_r" = "$_rczysty" ] && echo 0 || echo "$_r≠$_rczysty")" "0"

  # (K0) tryb hooków w klonie — bije w TO SAMO ciało funkcji (sed+eval, bez rekurencji).
  # (+) indeks 100755 i bit x → zdrowo; (−) indeks 100644 → MUSI oblać; (−) 100755 w indeksie,
  # ale bez bitu x na dysku → oblewa TYLKO gdzie `chmod -x` realnie gasi `[ -x ]` (Windows bywa
  # ślepy na bit x — zmierz i nazwij, nie zakładaj).
  CIALO_TR="$(sed -n '/^sprawdz_tryb_hookow() {/,/^}/p' "$SAM")"
  TK="$(mktemp -d)"
  ( cd "$TK" && git init -q . && git config user.name t && git config user.email t@t \
    && git config commit.gpgsign false && git config core.hooksPath .githooks && mkdir .githooks \
    && printf '#!/bin/sh\nexit 0\n' > .githooks/dobry && printf '#!/bin/sh\nexit 0\n' > .githooks/zly \
    && chmod +x .githooks/dobry .githooks/zly && git add -A \
    && git update-index --chmod=+x .githooks/dobry .githooks/zly && git commit -qm k ) >/dev/null 2>&1
  ( cd "$TK" && eval "$CIALO_TR" && sprawdz_tryb_hookow "$TK" >/dev/null && [ -z "$TRYB_ZLE" ] ) && _r=0 || _r=$?
  spr "TRYB: hooki 100755 + bit x → zdrowo" "$_r" "0"
  ( cd "$TK" && git update-index --chmod=-x .githooks/zly ) >/dev/null 2>&1
  ( cd "$TK" && eval "$CIALO_TR" && sprawdz_tryb_hookow "$TK" >/dev/null && [ -n "$TRYB_ZLE" ] ) && _r=0 || _r=$?
  spr "TRYB: hook 100644 w indeksie OBLEWA (mutacja K0)" "$_r" "0"
  # (K6/N4) hooksPath: hooki zdrowe w indeksie, ale klon ich NIE woła (core.hooksPath puste) → MUSI oblać i nazwać powód.
  ( cd "$TK" && git config --unset core.hooksPath ) >/dev/null 2>&1
  ( cd "$TK" && eval "$CIALO_TR" && sprawdz_tryb_hookow "$TK" >/dev/null && case "$TRYB_ZLE" in *hookspath-niewpiety*) true ;; *) false ;; esac ) && _r=0 || _r=$?
  spr "HOOKSPATH: klon bez core.hooksPath OBLEWA (hooki leżą, nikt ich nie woła)" "$_r" "0"
  ( cd "$TK" && git config core.hooksPath .githooks ) >/dev/null 2>&1
  # WPIĘCIE: bieg produkcyjny na klonie z hookiem 100644 MUSI oblać i nazwać powód —
  # bez tego funkcja mogłaby być poprawna, a nigdy niewołana (rodzina #115).
  WY_W="$(_HOOKA_TOR=1 ROOT_KLON="$TK" bash "$SAM" 2>&1)" && _r=0 || _r=$?
  spr "TRYB WPIĘTY: bieg produkcyjny na złym klonie oblewa" "$_r" "1"
  case "$WY_W" in *"tryb-indeksu-zly"*) z=$((z+1)); echo "  ✓ TRYB WPIĘTY: powód nazwany (tryb-indeksu-zly)" ;;
    *) o=$((o+1)); echo "  ✗ TRYB WPIĘTY: powód NIE nazwany w werdykcie produkcyjnym" ;; esac
  ( cd "$TK" && git update-index --chmod=+x .githooks/zly ) >/dev/null 2>&1
  chmod -x "$TK/.githooks/zly"
  if [ -x "$TK/.githooks/zly" ]; then
    echo "  ? TRYB: bit x na dysku niegaszalny na tej platformie — przypadek NIEMIERZALNY (nazwany, nie zaliczony)"
  else
    ( cd "$TK" && eval "$CIALO_TR" && sprawdz_tryb_hookow "$TK" >/dev/null && [ -n "$TRYB_ZLE" ] ) && _r=0 || _r=$?
    spr "TRYB: brak bitu x na dysku OBLEWA" "$_r" "0"
  fi
  rm -rf "$TK"

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

# (+/+/−) #121 WYJĄTEK KARTECZKI: rejestr karteczek poza stage NIE blokuje, gdy jego diff to
# wyłącznie linie karteczki; każda inna linia w tym pliku blokuje jak dotąd. Karteczkę pisze
# PRAWDZIWY przyrząd (wzorzec z przyrządu, nie z pamięci) — REJESTR bezwzględny, bo przyrząd
# robi `cd` do korzenia żywego repo; atrapa żyje w mktemp, żywy rejestr nie jest ruszany.
FER="$(dirname "$(dirname "$HOOK")")/narzedzia/straze/straz_feromonow.sh"
REJ="$T/kanon/ksiegi/KTO_CO_BIERZE.md"
mkdir -p kanon/ksiegi && printf '# KTO CO BIERZE (atrapa)\n' > "$REJ" && git add -A
git commit -qm "rejestr karteczek" >/dev/null 2>&1 || zle="$zle rejestr-karteczek-nie-wszedl"
# SESJA JAWNIE (03.10, pomiar PRACOWNI na Windows: bateria 76/2): przyrząd karteczek od 03.10 wymaga SESJI (kto wiesza) i bierze ją ze
# zmiennej CLAUDE_CODE_REMOTE_SESSION_ID, która istnieje TYLKO w sesji chmurowej. Fikstura bez `--sesja` przechodziła w chmurze i oblewała
# na maszynie lokalnej: zieleń zależna od środowiska gospodarza (#49), ten sam wzorzec co lista markerów w torze zaloz_goscia.
REJESTR="$REJ" bash "$FER" --biore "A" "fikstura · 121" --sesja SESHOOKA >/dev/null 2>&1 || zle="$zle przyrzad-karteczki-nie-pisze"
echo "k1" >> plik.md && git add plik.md
git commit -qm "karteczka biore" >/dev/null 2>&1 || zle="$zle karteczka-biore-blokuje"
REJESTR="$REJ" bash "$FER" --oddaje "A" --sesja SESHOOKA >/dev/null 2>&1
# STAN, nie kod wyjścia: `--oddaje` bez sesji kończy się rc 0 i nic nie zdejmuje (zmierzone 03.10) — rc nie odróżniał zdjęcia od niczego.
[ "$(grep -c 'STATUS:\*\* OTWARTE' "$REJ")" = "0" ] || zle="$zle przyrzad-karteczki-nie-oddaje"
echo "k2" >> plik.md && git add plik.md
git commit -qm "karteczka oddaje" >/dev/null 2>&1 || zle="$zle karteczka-oddaje-blokuje"
echo "cudza linia" >> "$REJ"
echo "k3" >> plik.md && git add plik.md
git commit -qm "nie-karteczka" >/dev/null 2>&1 && zle="$zle nie-karteczka-w-rejestrze-przeszla"
git add -A && git commit -qm "rejestr domkniety" >/dev/null 2>&1 \
  || zle="$zle rejestr-po-dodaniu-nadal-blokuje"

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

# (−/⊙/⊙) #37 MARKERY KONFLIKTU: marker ZAKOTWICZONY na początku wiersza MUSI zablokować;
# ten sam wzorzec w bloku ``` i w inline-code MUSI przejść — księgi cytują go w prozie
# (`grep -c "<<<<<<<"` stoi w PROMPCIE przeglądu), a alarm szerszy niż sygnał uczy nie
# patrzeć (#56, lekcja ZAMKA #12). Fikstury składane printf-em, nie literałem w tym pliku.
_M7='<<<<<<<'; _R7='======='; _P7='>>>>>>>'
printf '%s HEAD\na\n%s\nb\n%s galaz\n' "$_M7" "$_R7" "$_P7" > konflikt.md
git add -A
git commit -qm "marker konfliktu" >/dev/null 2>&1 && zle="$zle marker-konfliktu-przeszedl"
rm -f konflikt.md && git add -A && git commit -qm sprzatanie3 >/dev/null 2>&1
printf 'opis wzorca\n```\n%s HEAD\n%s\n%s b\n```\n' "$_M7" "$_R7" "$_P7" > cytat.md
git add -A
git commit -qm "marker w bloku kodu" >/dev/null 2>&1 || zle="$zle marker-w-bloku-kodu-blokuje"
printf 'zdanie o `%s` w prozie\n' "$_M7" > proza.md
git add -A
git commit -qm "marker inline" >/dev/null 2>&1 || zle="$zle marker-inline-blokuje"

# (−/+/⊙/−/⊙) C2 OSTRZEŻENIE RODOWODU (03.10): modyfikacja przyrządu bez stempla rodowodu młodszego niż 24 h
# OSTRZEGA (commit PRZECHODZI) i dopisuje wiersz do RODOWOD_pominiety.txt, który jedzie W TYM SAMYM commicie
# (inaczej zamek #35 zablokowałby następny commit — ostrzeżenie stałoby się zamkiem). Stempel świeży → cisza;
# plik NOWY → cisza; stempel starszy niż 24 h → znów ostrzega.
mkdir -p narzedzia/straze && printf 'v1\n' > narzedzia/straze/rod_x.sh && git add -A
_r_nowy="$(git commit -qm "rod nowy" 2>&1)"
printf '%s' "$_r_nowy" | grep -q 'RODOWÓD POMINIĘTY' && zle="$zle rodowod-ostrzega-o-pliku-NOWYM"
printf 'v2\n' >> narzedzia/straze/rod_x.sh && git add -A
_r_brak="$(git commit -qm "rod bez stempla" 2>&1)"; _r_rc=$?
[ "$_r_rc" = "0" ] || zle="$zle rodowod-blokuje-commit-zamiast-ostrzec"
printf '%s' "$_r_brak" | grep -q 'RODOWÓD POMINIĘTY' || zle="$zle rodowod-nie-ostrzega-bez-stempla"
git show --name-only --format= HEAD 2>/dev/null | grep -q 'kanon/pomiary/RODOWOD_pominiety.txt' \
  || zle="$zle rodowod-wiersz-nie-jedzie-w-commicie"
grep -q 'narzedzia/straze/rod_x.sh' kanon/pomiary/RODOWOD_pominiety.txt 2>/dev/null || zle="$zle rodowod-brak-wiersza-rejestru"
[ -z "$(git status --porcelain --untracked-files=no)" ] || zle="$zle rodowod-zostawil-brudne-drzewo"
mkdir -p .git/kronos_rodowod && date '+%Y-%m-%d %H:%M' > .git/kronos_rodowod/narzedzia_straze_rod_x.sh
printf 'v3\n' >> narzedzia/straze/rod_x.sh && git add -A
_r_swiezy="$(git commit -qm "rod ze stemplem" 2>&1)"
printf '%s' "$_r_swiezy" | grep -q 'RODOWÓD POMINIĘTY' && zle="$zle rodowod-ostrzega-mimo-swiezego-stempla"
touch -d '26 hours ago' .git/kronos_rodowod/narzedzia_straze_rod_x.sh 2>/dev/null
printf 'v4\n' >> narzedzia/straze/rod_x.sh && git add -A
_r_stary="$(git commit -qm "rod ze starym stemplem" 2>&1)"
printf '%s' "$_r_stary" | grep -q 'RODOWÓD POMINIĘTY' || zle="$zle rodowod-nie-ostrzega-przy-starym-stemplu"

if [ -z "$zle" ]; then
  echo "  ✓ pre-commit ŻYWY: blokuje niepełny ładunek (#35), nieświeży odcisk (#67), PAT, niesparsowany .py (⓬); ostrzega o rodowodzie (C2)"
  echo "    przepuszcza commit kompletny, plik nieśledzony i polską treść w potrójnych cudzysłowach."
else
  echo "  ✗ pre-commit MARTWY:$zle"
fi

# ═══ ZAMEK #31 · reference-transaction — BEZWARUNKOWO (22.09.2026, decyzje D1/D2) ═══════════
# Do 22.09 blok #31 stał tu, w tym pliku, pod `if [ -r "/proc/self/cmdline" ]` — bramka
# PLATFORMY, nie MECHANIZMU: `/proc/self/cmdline` jest czytelne na Windows/MSYS2 (zawsze),
# więc bramka nigdy nie chroniła tego, przed czym miała chronić — zamek #31 był wtedy w
# `pre-commit` i faktycznie nieuzbrojony na Windows (PPID hooka = 1, nie pid gita — dowód
# w WATKI_OTWARTE B2(a), `2bc71d6`), a TA bramka tylko UKRYWAŁA to jako „poza zasięgiem
# platformy" zamiast zmierzyć i zawołać MARTWY.
# Zamek przeniósł się do `.githooks/reference-transaction` (dostaje `old new ref` wprost od
# gita, bez introspekcji procesu) — więc żadna bramka platformy nie jest już potrzebna.
# Przypadki biegną BEZWARUNKOWO, na KAŻDEJ platformie, na fiksturze z prawdziwym bare originem
# (jak krok 1 EWALUACJI B2(a)). Werdykt „gałąź przesunięta" z `git rev-parse refs/heads/<gałąź>`
# PRZED/PO — NIE z samego `HEAD`: rebase zostawia HEAD chwilowo ODŁĄCZONY (detached) nawet gdy
# zablokowany ruch NIGDY nie dotarł do `refs/heads/*` — zmierzone w EWALUACJI kroku 1.
if [ ! -f "$HOOK_RT" ]; then
  echo "  ✗ brak .githooks/reference-transaction — zamek #31 bez ciała"
  zle="$zle brak-reference-transaction"
else
TRT="$(mktemp -d)"; TRT_ORIGIN="$(mktemp -d)"   # SIOSTRZANE katalogi, NIE origin zagnieżdżony w
# katalogu roboczym: bare repo jako PODKATALOG working tree wpadłby pod `git add -A` (drugi
# commit poniżej) i zaśmiecił drzewo swoimi własnymi plikami wewnętrznymi — zmierzone.
git init -q --bare "$TRT_ORIGIN" >/dev/null 2>&1
( cd "$TRT" \
    && mkdir -p h && cp "$HOOK_RT" h/reference-transaction && chmod +x h/reference-transaction \
    && git init -q . && git config core.hooksPath h \
    && git config user.name Straz && git config user.email s@s \
    && echo x > a.txt && git add -A && git commit -qm start \
    && git remote add origin "$TRT_ORIGIN" \
    && BR="$(git symbolic-ref --short HEAD)" \
    && git push -q origin "$BR:$BR" \
    && git branch -q --set-upstream-to="origin/$BR" "$BR" ) >/dev/null 2>&1
BR_RT="$(cd "$TRT" && git symbolic-ref --short HEAD)"
rev() { ( cd "$TRT" && git rev-parse "refs/heads/$BR_RT" 2>/dev/null ); }
spr_rt() {  # $1=opis $2=rc $3=oczek_rc $4=przed $5=po $6=oczek_ruch(TAK/NIE)
  local ok=1
  [ "$2" = "$3" ] || ok=0
  local ruch=NIE; [ "$4" != "$5" ] && ruch=TAK
  [ "$ruch" = "$6" ] || ok=0
  if [ "$ok" = 1 ]; then echo "  ✓ RT: $1 (rc=$2, gałąź_przesunięta=$ruch)"
  else echo "  ✗ RT: $1 (rc=$2 oczek=$3, przesunięta=$ruch oczek=$6)"; zle="$zle rt-$1"; fi
}

# (−) 1: amend na pushniętym, PUSTY stage — MUSI zablokować
P1=$(rev); ( cd "$TRT" && git commit --amend -qm "amend1" ) >/dev/null 2>&1; RC1=$?
spr_rt "amend-pushniety-pusty-stage" "$RC1" 128 "$P1" "$(rev)" NIE

# (−) 2: amend na pushniętym, PO git add — MUSI zablokować
P2=$(rev); ( cd "$TRT" && echo zm >> a.txt && git add a.txt && git commit --amend -qm "amend2" ) >/dev/null 2>&1; RC2=$?
spr_rt "amend-pushniety-po-add" "$RC2" 128 "$P2" "$(rev)" NIE
( cd "$TRT" && git checkout -q -- a.txt ) >/dev/null 2>&1

# drugi commit pushnięty, żeby rebase -i miał HEAD~1 do przepisania
( cd "$TRT" && echo b > b.txt && git add -A && git commit -qm drugi && git push -q origin "$BR_RT" ) >/dev/null 2>&1

# (−) 3: rebase -i przepisujący pushnięty commit — MUSI zablokować, `rebase --abort` wraca czysto
P3=$(rev)
( cd "$TRT" && GIT_SEQUENCE_EDITOR="sed -i '1s/^pick/reword/'" GIT_EDITOR="sh -c 'echo x > \"\$1\"' --" git rebase -i HEAD~1 ) >/dev/null 2>&1; RC3=$?
spr_rt "rebase-i-przepisujacy-pushniety" "$RC3" 128 "$P3" "$(rev)" NIE
( cd "$TRT" && git rebase --abort ) >/dev/null 2>&1; RCAB=$?
[ -d "$TRT/.git/rebase-merge" ] && zle="$zle rt-rebase-abort-nie-wyczyscil"
[ "$RCAB" -eq 0 ] || zle="$zle rt-rebase-abort-rc-nie-zero"
[ "$(rev)" = "$P3" ] || zle="$zle rt-rebase-abort-nie-wrocil-do-P3"
echo "  ✓ RT: rebase --abort przywraca czysty stan (rc=$RCAB, gałąź z powrotem na $P3)"

# (−) 4: reset --hard HEAD~1 na pushniętym — MUSI zablokować; kolejny zwykły commit MUSI przejść
P4=$(rev); ( cd "$TRT" && git reset --hard HEAD~1 ) >/dev/null 2>&1; RC4=$?
spr_rt "reset-hard-cofa-pushniety" "$RC4" 128 "$P4" "$(rev)" NIE
P4b=$(rev); ( cd "$TRT" && echo c > c.txt && git add -A && git commit -qm trzeci ) >/dev/null 2>&1; RC4b=$?
spr_rt "commit-po-zablokowanym-resecie" "$RC4b" 0 "$P4b" "$(rev)" TAK

# (+) 5: amend NIEpushnięty — MUSI przejść
P5=$(rev); ( cd "$TRT" && echo d >> c.txt && git add -A && git commit --amend -qm "amend-niepush" ) >/dev/null 2>&1; RC5=$?
spr_rt "amend-niepushniety" "$RC5" 0 "$P5" "$(rev)" TAK

# (+) 6: push i fetch — ZERO fałszywej blokady
( cd "$TRT" && git push -q origin "$BR_RT" ) >/dev/null 2>&1; RC6P=$?
( cd "$TRT" && git fetch ) >/dev/null 2>&1; RC6F=$?
{ [ "$RC6P" -eq 0 ] && [ "$RC6F" -eq 0 ]; } && echo "  ✓ RT: push i fetch bez fałszywej blokady" \
  || { echo "  ✗ RT: push/fetch (push_rc=$RC6P fetch_rc=$RC6F)"; zle="$zle rt-push-fetch"; }

# (+) 7: pull --rebase z lokalnym niepushniętym commitem, upstream rozjechany — MUSI przejść
TOTHER="$(mktemp -d)"
( git clone -q "$TRT_ORIGIN" "$TOTHER" \
    && cd "$TOTHER" && git config user.name O && git config user.email o@o \
    && echo cudzy > cudzy.txt && git add -A && git commit -qm cudzy && git push -q origin "$BR_RT" ) >/dev/null 2>&1
( cd "$TRT" && echo e > e.txt && git add -A && git commit -qm "lokalny-niepushniety" ) >/dev/null 2>&1
P7=$(rev); ( cd "$TRT" && git pull --rebase -q origin "$BR_RT" ) >/dev/null 2>&1; RC7=$?
spr_rt "pull-rebase-lokalny-vs-rozjazd" "$RC7" 0 "$P7" "$(rev)" TAK
rm -rf "$TOTHER"

# (+) 8: usunięcie gałęzi lokalnej, w tym takiej, która BYŁA pushnięta — MUSI przejść zawsze (D1)
( cd "$TRT" && git checkout -q -b poboczna && git push -q origin poboczna && git checkout -q "$BR_RT" ) >/dev/null 2>&1
( cd "$TRT" && git branch -D poboczna ) >/dev/null 2>&1; RC8=$?
[ "$RC8" -eq 0 ] && echo "  ✓ RT: usunięcie gałęzi lokalnej (nawet pushniętej) przechodzi (D1)" \
  || { echo "  ✗ RT: usunięcie gałęzi zablokowane (rc=$RC8)"; zle="$zle rt-branch-delete-zablokowane"; }

# (+) 9: reset --hard origin/<gałąź> — powrót do stanu origin, zawsze dozwolony
( cd "$TRT" && git push -q origin "$BR_RT" ) >/dev/null 2>&1
( cd "$TRT" && echo f > f.txt && git add -A && git commit -qm "do-cofniecia" ) >/dev/null 2>&1
( cd "$TRT" && git reset --hard "origin/$BR_RT" ) >/dev/null 2>&1; RC9=$?
[ "$RC9" -eq 0 ] && echo "  ✓ RT: reset --hard origin/<gałąź> przechodzi" \
  || { echo "  ✗ RT: reset --hard origin/<gałąź> zablokowany (rc=$RC9)"; zle="$zle rt-reset-do-origin-zablokowany"; }

# (+/−) 10: furtka KRONOS_ZAMEK31=off otwiera i LOGUJE; każda inna wartość NIE otwiera
( cd "$TRT" && git push -q origin "$BR_RT" ) >/dev/null 2>&1
P10=$(rev); ( cd "$TRT" && KRONOS_ZAMEK31=off git commit --amend -qm "amend-furtka" ) >/dev/null 2>&1; RC10=$?
spr_rt "furtka-off-otwiera" "$RC10" 0 "$P10" "$(rev)" TAK
if [ -s "$TRT/.git/KRONOS_FURTKA.log" ]; then echo "  ✓ RT: furtka zostawiła ślad w KRONOS_FURTKA.log"
else echo "  ✗ RT: furtka NIE zostawiła śladu"; zle="$zle rt-furtka-bez-sladu"; fi
( cd "$TRT" && git push -q --force origin "$BR_RT" ) >/dev/null 2>&1
P11=$(rev); ( cd "$TRT" && KRONOS_ZAMEK31=0 git commit --amend -qm "amend-zla-furtka" ) >/dev/null 2>&1; RC11=$?
spr_rt "furtka-zla-wartosc-nie-otwiera" "$RC11" 128 "$P11" "$(rev)" NIE

rm -rf "$TRT" "$TRT_ORIGIN"
fi

# K0: tryb hooków w TYM klonie (indeks 100755 + bit x) — po fikstury, przed werdyktem
sprawdz_tryb_hookow "$ROOT_KLON"
zle="$zle$TRYB_ZLE"

if [ -z "$zle" ]; then
  echo "  ✓ HOOK ŻYWY: pre-commit blokuje niepełny ładunek (#35), nieświeży odcisk (#67), PAT,"
  echo "    niesparsowany .py (⓬); reference-transaction blokuje przepisanie historii pushniętej —"
  echo "    amend, rebase, reset (#31, D1) — na KAŻDEJ platformie, furtka KRONOS_ZAMEK31=off"
  echo "    otwiera ze śladem, żadna inna wartość nie otwiera. Tryb hooków w TYM klonie: indeks"
  echo "    100755 + bit x (K0) — świeży klon nie pominie żadnego z nich."
  exit 0
fi
echo "  ✗ HOOK MARTWY:$zle"
exit 1
