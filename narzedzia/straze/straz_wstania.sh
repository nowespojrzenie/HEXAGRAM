#!/usr/bin/env bash
# KRONOS · STRAŻ WSTANIA (20.08.2026) — tory na mechanizm blizny ❿ w `wstan.sh`.
#
# POWÓD: `wstan.sh` łapał wszystkie awarie pulla jednym `||` i szedł dalej z tym samym
# zdaniem — brak sieci i ROZJAZD HISTORII wyglądały identycznie. Groźny jest tylko drugi:
# praca rusza wtedy na stanie, który NIE JEST kanonem (błąd ❿ w czystej postaci).
# Tor stawia PRAWDZIWY rozjazd w atrapie repo i sprawdza, czy mechanizm go odróżnia.
set -uo pipefail
KOR="${KOR:-$(cd "$(dirname "$0")/../.." && pwd)/wstan.sh}"
ZRODLO_WZORCOW="$(cd "$(dirname "$0")" && pwd)/straz_swiezosci.sh"

# PRZENOSINY ŹRÓDŁA (27.08.2026, blizna #71): wzorce rozpoznania wyprowadziły się
# z ciała `wstan.sh` do `straz_swiezosci.sh` (jedno źródło klasyfikacji, #49).
# Tor NADAL nie nosi własnej kopii wzorca — tylko czyta go spod nowego adresu (#50/#64).
wzor_rozjazdu() {
  grep -oE "^WZ_ROZJAZD='[^']+'" "$ZRODLO_WZORCOW" 2>/dev/null | head -1 \
    | sed "s/^WZ_ROZJAZD='//; s/'$//"
}

# ═══ TOR WŁASNY (#38 · #47) — 21.08.2026, dług nazwany w MOSTY #31 ═══
# Ta straż sprawdza, czy `wstan.sh` ODRÓŻNIA prawdziwy rozjazd historii od braku sieci.
# Pytanie o nią samą brzmi: czy zauważy, gdy wstanie PRZESTANIE to odróżniać?
# Podaje się jej ATRAPĘ wstania, z której zdjęto mechanizm, i wymaga OBLANIA.
# Fikstura ODRÓŻNIALNA (#64): ten sam przebieg na ŻYWYM `wstan.sh` musi przejść —
# inaczej „straż oblewa" byłoby nieodróżnialne od „straż oblewa zawsze".
if [ "${1:-}" = "--test" ]; then
  echo "╔═══ STRAŻ WSTANIA — AUTOTEST (#38) ═══╗"
  TW="$(mktemp -d)"; z=0; o=0
  spr() { if [ "$2" = "$3" ]; then echo "  ✓ $1"; z=$((z+1)); else echo "  ✗ $1 (rc=$2, oczekiwano $3)"; o=$((o+1)); fi; }
  SAM="$(cd "$(dirname "$0")" && pwd)/$(basename "$0")"
  ZYWY="$(cd "$(dirname "$0")/../.." && pwd)/wstan.sh"

  # (−) atrapa PUSTA: wstanie bez jakiegokolwiek mechanizmu rozjazdu
  printf '#!/usr/bin/env bash\necho wstaje\n' > "$TW/puste.sh"
  KOR="$TW/puste.sh" bash "$SAM" >/dev/null 2>&1 && _r=0 || _r=$?
  spr "PUSTE wstanie (brak mechanizmu rozjazdu) OBLEWA" "$_r" "1"

  # (−) atrapa OKROJONA: mechanizm jest, ale zdjęto podniesienie rc — czyli rozjazd
  #     zostałby ROZPOZNANY i ZIGNOROWANY. To groźniejszy wariant niż brak mechanizmu,
  #     bo wygląda na działający (#59: zamek nazwany czynnością, której nie wykonuje).
  # ROZDZIELNOŚĆ FIKSTUR (27.08, wykryte mutacją): każda atrapa musi być łapana przez
  # DOKŁADNIE JEDNĄ asercję. Gdy `okrojone` gasiło rc rozjazdu I rc ślepoty naraz,
  # nowa asercja RC=11 przykryła starą RC=10 — mutacja `wstania-rozjazd-bez-rc-przechodzi`
  # przestała cokolwiek mierzyć (ŚLEPY PUNKT). Zamek, który przykrywa inny zamek,
  # nie dodaje ochrony, tylko odbiera ją pomiarowi.
  sed 's/RC=10/RC=0/g' "$ZYWY" > "$TW/okrojone.sh"
  KOR="$TW/okrojone.sh" bash "$SAM" >/dev/null 2>&1 && _r=0 || _r=$?
  spr "OKROJONE wstanie (rozjazd bez rc) OBLEWA" "$_r" "1"

  # (−) atrapa OKROJONA-11: symetrycznie dla ślepoty poświadczenia — klasa rozpoznana
  #     i zignorowana, rc niezmienione (#59 w wariancie #71).
  sed 's/RC=11/RC=0/g' "$ZYWY" > "$TW/okrojone11.sh"
  KOR="$TW/okrojone11.sh" bash "$SAM" >/dev/null 2>&1 && _r=0 || _r=$?
  spr "OKROJONE wstanie (slepota bez rc) OBLEWA (#71)" "$_r" "1"

  # (−) atrapa ŚLEPA (#71): zamek rozjazdu nietknięty, ale zdjęto obsługę klasy
  #     POŚWIADCZENIE. Wstanie rusza cicho na archiwum — dokładnie ten tryb, który
  #     27.08 kosztował dwie doby czytania nieświeżego klonu jako teraźniejszości.
  sed 's/WSTANIE_SLEPOTA/WSTANIE_NIEUZYWANE/g' "$ZYWY" > "$TW/slepe.sh"
  KOR="$TW/slepe.sh" bash "$SAM" >/dev/null 2>&1 && _r=0 || _r=$?
  spr "SLEPE wstanie (brak klasy POSWIADCZENIE) OBLEWA (#71)" "$_r" "1"

  # (−) atrapa z pełnym mechanizmem rozjazdu, ale BEZ ODCISKU — MUSI oblać (#65).
  # Fikstura odróżnialna (#64): niesie żywy wzorzec rozjazdu wyłuskany z repo, więc
  # oblanie może pochodzić WYŁĄCZNIE z braku odcisku, nie z cudzego powodu (#53).
  { printf '#!/usr/bin/env bash\necho wstaje\ngit pull --ff-only || {\n'
    printf "  grep -qiE '%s'\n" "$(wzor_rozjazdu)"
    printf '  exit 1\n}\n'; } > "$TW/bezodcisku.sh"
  KOR="$TW/bezodcisku.sh" bash "$SAM" >/dev/null 2>&1 && _r=0 || _r=$?
  spr "wstanie BEZ ODCISKU poswiadczenia OBLEWA (#65)" "$_r" "1"

  # (+) żywe wstanie z repo — MUSI przejść
  bash "$SAM" >/dev/null 2>&1 && _r=0 || _r=$?
  spr "ZYWE wstan.sh z repo PRZECHODZI (odroznialnosc)" "$_r" "0"

  rm -rf "$TW"
  echo "  zmierzone: zdanych $z · oblanych $o"
  [ "$o" -eq 0 ] || { echo "  ✗ TOR OBLANY"; exit 1; }
  echo "  ✓ STRAŻ UMIE NIE PRZEJŚĆ — odróżnia wstanie żywe od pustego i od okrojonego."
  exit 0
fi
[ -f "$KOR" ] || { echo "✗ brak wstan.sh"; exit 1; }
zle=""
T="$(mktemp -d)"; trap 'rm -rf "$T"' EXIT
export GIT_AUTHOR_NAME=Straz GIT_AUTHOR_EMAIL=s@s GIT_COMMITTER_NAME=Straz GIT_COMMITTER_EMAIL=s@s

# Wyłuskujemy WZORZEC ROZPOZNANIA z żywego wstan.sh — tor nie może nosić własnej kopii
# wzorca, bo wtedy mierzyłby siebie (#50, trzykrotnie złapane 20.08).
WZOR=$(wzor_rozjazdu)
# Ścieżka zgodności: atrapy w torze własnym niosą wzorzec inline (nie mają straży obok).
[ -n "$WZOR" ] || WZOR=$(grep -oE "grep -qiE '[^']+'" "$KOR" | head -1 | sed "s/grep -qiE '//; s/'$//")
[ -n "$WZOR" ] || { echo "✗ nie znaleziono wzorca rozjazdu (ani w $ZRODLO_WZORCOW, ani inline w wstan.sh)"; exit 1; }

# (−) PRAWDZIWY ROZJAZD: dwie ręce pchają rozbieżne historie, `pull --ff-only` odmawia.
cd "$T" && git init -q --bare zdalne.git && git clone -q zdalne.git lok 2>/dev/null
cd "$T/lok" && echo "a" > p.md && git add -A && git commit -qm a >/dev/null
git push -q origin HEAD >/dev/null 2>&1
git clone -q "$T/zdalne.git" "$T/druga" 2>/dev/null
( cd "$T/druga" && echo "b" >> p.md && git add -A && git commit -qm b >/dev/null \
  && git push -q origin HEAD >/dev/null 2>&1 )
echo "c" >> p.md && git add -A && git commit -qm c >/dev/null
OUT=$(git pull --ff-only 2>&1); RC=$?
[ "$RC" -ne 0 ] || zle="$zle rozjazd-nie-podnosi-rc-pulla"
printf '%s' "$OUT" | grep -qiE "$WZOR" || zle="$zle wzorzec-nie-rozpoznaje-prawdziwego-rozjazdu"

# (−) ODCISK POŚWIADCZENIA (blizna #65, 21.08.2026): wstanie MUSI drukować odcisk
# użytego tokenu, bo bez niego nie ma trzeciego punktu danych i pojedyncze `401`
# jest nieodróżnialne od rotacji po stronie twórcy. Mierzymy OBECNOŚĆ MECHANIZMU
# w ciele wstania — nie jego wyjście, bo tor nie ma prawa znać żywego tokenu.
grep -q 'ODCISK POŚWIADCZENIA' "$KOR" || zle="$zle brak-odcisku-poswiadczenia"
grep -q 'sha256sum' "$KOR" || zle="$zle odcisk-bez-funkcji-jednokierunkowej"
# Sam token NIGDY nie może trafić do meldunku — to warunek, bez którego mechanizm
# byłby lekarstwem gorszym od choroby.
grep -qE 'echo[^|]*\$\{?KRONOS_PAT\}?[^|]*$' "$KOR" && zle="$zle token-drukowany-jawnie"

# (⊙) BRAK SIECI to NIE rozjazd — zimny start bez tokena musi działać, a alarm szerszy
# niż sygnał uczy nie patrzeć (#56).
cd "$T" && git init -q brak && cd "$T/brak" && echo x > y.md && git add -A \
  && git commit -qm x >/dev/null
OUT2=$(git pull --ff-only 2>&1); RC2=$?
[ "$RC2" -ne 0 ] || zle="$zle brak-remote-nie-podnosi-rc"
printf '%s' "$OUT2" | grep -qiE "$WZOR" && zle="$zle brak-sieci-wziety-za-rozjazd"

# (⊙⊙) MECHANIZM PODNOSI rc WSTANIA — meldunek bez zmiany kodu wyjścia jest zdaniem
# w logu (#19: werdykt z rc, nie z frazy).
grep -q 'WSTANIE_ROZJAZD' "$KOR"            || zle="$zle brak-flagi-rozjazdu"
grep -q 'RC=10' "$KOR"                       || zle="$zle rozjazd-nie-zmienia-rc-wstania"

# (⊙⊙⊙) ZAMEK #71 (27.08.2026) — trzecia klasa pulla. Remote osiągalny, ale bez
# poświadczenia: klon starzeje się MILCZĄCO. Mechanizm bez toru obowiązuje tylko
# w dokumentacji (#38), więc obecność zamka mierzymy tu, a nie ufamy komentarzowi.
grep -q 'WSTANIE_SLEPOTA' "$KOR"             || zle="$zle brak-flagi-slepoty-poswiadczenia"
grep -q 'RC=11' "$KOR"                       || zle="$zle slepota-nie-zmienia-rc-wstania"
grep -q 'straz_swiezosci.sh --klasa' "$KOR"  || zle="$zle wstanie-nie-pyta-strazy-o-klase"
# Klasyfikacja MUSI mieszkać w jednym miejscu — inline'owa kopia wzorca w `wstan.sh`
# byłaby powrotem blizny #49 (druga kopia formuły, która rozjeżdża się po cichu).
grep -qE "grep -qiE '(non-fast-forward|could not read)" "$KOR" \
  && zle="$zle wzorzec-skopiowany-z-powrotem-do-wstania"

if [ -z "$zle" ]; then
  echo "  ✓ WSTANIE ŻYWE: prawdziwy rozjazd historii rozpoznany, brak sieci NIE wzięty"
  echo "    za rozjazd, a rozjazd podnosi rc wstania (❿ zmechanizowana)."
  exit 0
fi
echo "  ✗ WSTANIE MARTWE:$zle"
exit 1
