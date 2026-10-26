#!/usr/bin/env bash
# KRONOS · STRAŻ WSTANIA (20.08.2026) — tory na mechanizm blizny ❿ w `wstan.sh`.
#
# POWÓD: `wstan.sh` łapał wszystkie awarie pulla jednym `||` i szedł dalej z tym samym
# zdaniem — brak sieci i ROZJAZD HISTORII wyglądały identycznie. Groźny jest tylko drugi:
# praca rusza wtedy na stanie, który NIE JEST kanonem (błąd ❿ w czystej postaci).
# Tor stawia PRAWDZIWY rozjazd w atrapie repo i sprawdza, czy mechanizm go odróżnia.
set -uo pipefail
# (K6/N8) KOR to UCHWYT TORU (nazwa ogólna!): ustawia go wyłącznie własny --test (git grep 23.10; inne pliki mają własne, lokalne KOR).
# Ambient `KOR=…` podmieniał BADANY plik wstania — „wstanie mierzy rozjazd, odcisk, flagi" nad cudzym skryptem. Tor podaje KOR z
# _WSTANIA_TOR=1; bieg bez flagi (produkcja, bateria) zdejmuje go z otoczenia przed odczytem.
[ "${_WSTANIA_TOR:-}" = 1 ] || unset KOR
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
  _WSTANIA_TOR=1 KOR="$TW/puste.sh" bash "$SAM" >/dev/null 2>&1 && _r=0 || _r=$?
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
  _WSTANIA_TOR=1 KOR="$TW/okrojone.sh" bash "$SAM" >/dev/null 2>&1 && _r=0 || _r=$?
  spr "OKROJONE wstanie (rozjazd bez rc) OBLEWA" "$_r" "1"

  # (−) atrapa OKROJONA-11: symetrycznie dla ślepoty poświadczenia — klasa rozpoznana
  #     i zignorowana, rc niezmienione (#59 w wariancie #71).
  sed 's/RC=11/RC=0/g' "$ZYWY" > "$TW/okrojone11.sh"
  _WSTANIA_TOR=1 KOR="$TW/okrojone11.sh" bash "$SAM" >/dev/null 2>&1 && _r=0 || _r=$?
  spr "OKROJONE wstanie (slepota bez rc) OBLEWA (#71)" "$_r" "1"

  # (−) atrapa ŚLEPA (#71): zamek rozjazdu nietknięty, ale zdjęto obsługę klasy
  #     POŚWIADCZENIE. Wstanie rusza cicho na archiwum — dokładnie ten tryb, który
  #     27.08 kosztował dwie doby czytania nieświeżego klonu jako teraźniejszości.
  sed 's/WSTANIE_SLEPOTA/WSTANIE_NIEUZYWANE/g' "$ZYWY" > "$TW/slepe.sh"
  _WSTANIA_TOR=1 KOR="$TW/slepe.sh" bash "$SAM" >/dev/null 2>&1 && _r=0 || _r=$?
  spr "SLEPE wstanie (brak klasy POSWIADCZENIE) OBLEWA (#71)" "$_r" "1"

  # (−) atrapa z pełnym mechanizmem rozjazdu, ale BEZ ODCISKU — MUSI oblać (#65).
  # Fikstura odróżnialna (#64): niesie żywy wzorzec rozjazdu wyłuskany z repo, więc
  # oblanie może pochodzić WYŁĄCZNIE z braku odcisku, nie z cudzego powodu (#53).
  { printf '#!/usr/bin/env bash\necho wstaje\ngit pull --ff-only || {\n'
    printf "  grep -qiE '%s'\n" "$(wzor_rozjazdu)"
    printf '  exit 1\n}\n'; } > "$TW/bezodcisku.sh"
  _WSTANIA_TOR=1 KOR="$TW/bezodcisku.sh" bash "$SAM" >/dev/null 2>&1 && _r=0 || _r=$?
  spr "wstanie BEZ ODCISKU poswiadczenia OBLEWA (#65)" "$_r" "1"

  # (+) żywe wstanie z repo — MUSI przejść
  bash "$SAM" >/dev/null 2>&1 && _r=0 || _r=$?
  spr "ZYWE wstan.sh z repo PRZECHODZI (odroznialnosc)" "$_r" "0"
  _rczysty="$_r"
  # (K6/N8) TOR (−) NA OTOCZENIE: ambient KOR=<atrapa pusta> NIE MOŻE podmienić badanego wstan.sh (rc równy biegowi czystemu; dawne ciało:
  # ambient KOR → rc 1 jak dla atrapy pustej, mimo że repo jest zdrowe).
  KOR="$TW/puste.sh" bash "$SAM" >/dev/null 2>&1 && _r=0 || _r=$?
  spr "OTOCZENIE: ambient KOR=atrapa nie podmienia badanego wstan.sh (rc równy biegowi czystemu)" "$([ "$_r" = "$_rczysty" ] && echo 0 || echo "$_r≠$_rczysty")" "0"

  # (cz.4, 25.10.2026) PRECEDENS-W: wstanie NIE brudzi śledzonego drzewa. Prawdziwy bieg `wstan.sh` w klonie repo (HEAD + niezacommitowane zmiany żywego drzewa, żeby tor mierzył to, co badamy):
  # stan `git status --porcelain` PRZED = PO (PRZED cz.4: M kanon/ksiegi/TABLICA.md i M kanon/pomiary/ALARMY_szereg.txt po każdym wstaniu — zmierzone cz.3 §1). Wiersze alarmów MUSZĄ
  # wylądować w buforze .git (inaczej tor byłby próżny: wstanie, które nic nie pisze, też zostawia drzewo czyste). Koszt: ~2 min na bieg wstania.
  ROOT="$(cd "$(dirname "$0")/../.." && pwd)"; WK="$TW/wk"
  if git clone -q --local "$ROOT" "$WK" >/dev/null 2>&1; then
    ( cd "$ROOT" && git ls-files -m -o --exclude-standard ) | while IFS= read -r f; do [ -f "$ROOT/$f" ] && mkdir -p "$WK/$(dirname "$f")" && cp "$ROOT/$f" "$WK/$f"; done
    # Pisarze z dedupe dnia (deklaracja_modelu, mapa_ciala) nie dopisują, gdy dzisiejszy wiersz już jest — zmierzone: bez tego mutacje „pisze wprost” były ŚLEPE. Dzisiejsze wiersze wycięte i zacommitowane w klonie.
    ( cd "$WK" && grep -vE "^($(date -u +%F)|$(TZ=Europe/Warsaw date +%F)) " kanon/pomiary/ALARMY_szereg.txt > "$TW/al.tmp"; cat "$TW/al.tmp" > kanon/pomiary/ALARMY_szereg.txt; git -c user.email=t@t -c user.name=t commit -qam "tor: bez dzisiejszych wierszy" ) >/dev/null 2>&1
    # 25.10.2026 (odlew 1.8.3): TABLICA świeża = ta sama treść, którą wstanie by zapisało → zapis pliku nie zostawiał śladu i mutacja
    # „wstan-tablica-pisze-plik” wychodziła ŚLEPA zależnie od stanu kartek. W klonie próby TABLICA dostaje znacznik i commit — każdy zapis ją nadpisze.
    if git -C "$WK" ls-files --error-unmatch kanon/ksiegi/TABLICA.md >/dev/null 2>&1; then
      ( cd "$WK" && printf '<!-- znacznik toru PRECEDENS-W -->\n' >> kanon/ksiegi/TABLICA.md && git -c user.name=tor -c user.email=tor@localhost commit -q --no-verify -m "tor: znacznik TABLICA" -- kanon/ksiegi/TABLICA.md ) >/dev/null 2>&1
    fi
    S0="$(git -C "$WK" status --porcelain)"; ( cd "$WK" && bash wstan.sh >/dev/null 2>&1 ); S1="$(git -C "$WK" status --porcelain)"
    spr "PRECEDENS-W: wstan.sh w klonie — git status przed = po (śledzone rejestry nie brudzą drzewa)" "$([ "$S0" = "$S1" ] && echo 0 || echo 1)" "0"
    # POZA ODLEWEM (25.10.2026, odlew 1.8.3): w odlewie ALARMY_szereg.txt nie jest śledzony (u gościa .gitignore działa, szereg.sh pisze wprost) —
    # bufora nie ma z założenia; warunek „nie próżny” mierzy tylko ciało, w którym rejestr jest śledzony.
    if git -C "$WK" ls-files --error-unmatch kanon/pomiary/ALARMY_szereg.txt >/dev/null 2>&1; then
      spr "PRECEDENS-W: wiersze alarmów w buforze .git (tor nie jest próżny)" "$([ -s "$WK/.git/szeregi/kanon/pomiary/ALARMY_szereg.txt" ] && echo 0 || echo 1)" "0"
    else echo "   ⓘ PRECEDENS-W (bufor alarmów): POZA ODLEWEM — rejestr ALARMY nieśledzony w tym ciele"; fi
  else
    spr "PRECEDENS-W: klon repo do próby wstania" 1 0
  fi

  # (11.09.2026) STRAŻ GAŁĘZI — blok wycięty z ŻYWEGO `wstan.sh` (tor bije w to samo ciało, #50).
  # Cztery sytuacje: odmowa na main przy istniejącej prywatnej · odmowa w świeżym klonie (main
  # lokalnie, prywatna tylko jako origin/) · cisza na prywatnej · cisza u odbiorcy bez prywatnej.
  BG="$(sed -n '/^# 1c\. STRAŻ GAŁĘZI/,/^# 2\. Najnowsze/p' "$ZYWY" | grep -v '^#')"
  G="$TW/g"; mkdir -p "$G"
  ( cd "$G" && git init -q -b prywatna && git -c user.name=t -c user.email=t@t commit -q --allow-empty -m z \
      && git branch main && git checkout -q main ) >/dev/null 2>&1
  ( cd "$G" && eval "$BG"; exit 0 ) >/dev/null 2>&1 && _r=0 || _r=$?
  spr "GAŁĄŹ: main przy istniejącej prywatnej → ODMOWA" "$_r" "3"
  git clone -q "$G" "$TW/k" >/dev/null 2>&1
  ( cd "$TW/k" && eval "$BG"; exit 0 ) >/dev/null 2>&1 && _r=0 || _r=$?
  spr "GAŁĄŹ: świeży klon na main (prywatna tylko w origin/) → ODMOWA" "$_r" "3"
  ( cd "$G" && git checkout -q prywatna && eval "$BG"; exit 0 ) >/dev/null 2>&1 && _r=0 || _r=$?
  spr "GAŁĄŹ: na prywatnej → cisza" "$_r" "0"
  mkdir -p "$TW/o" && ( cd "$TW/o" && git init -q -b main ) >/dev/null 2>&1
  ( cd "$TW/o" && eval "$BG"; exit 0 ) >/dev/null 2>&1 && _r=0 || _r=$?
  spr "GAŁĄŹ: odbiorca odlewu bez prywatnej → cisza" "$_r" "0"
  [ -n "$BG" ] || { echo "  ✗ blok STRAŻY GAŁĘZI nie znaleziony w wstan.sh"; o=$((o+1)); }

  # (K6/N4, 19.10.2026) HOOKI WPIĘTE — blok 2b wycięty z ŻYWEGO `wstan.sh`. (+) zapis działa → rc 0 i hooksPath ustawione;
  # (−) przyrząd `git config` pada (atrapa funkcji `git` odmawia zapisu hooksPath) → wstanie MUSI stanąć (rc 1), a nie
  # zamelować „ok” nad wyłączonym pre-commit (dawne `|| true`).
  HB="$(sed -n '/^# 2b\. Prawa zmechanizowane/,/^echo "📦 npm ci/p' "$ZYWY" | grep -v '^#' | grep -v 'npm ci')"
  [ -n "$HB" ] || { echo "  ✗ blok 2b (hooksPath) nie znaleziony w wstan.sh"; o=$((o+1)); }
  H2="$TW/h2"; mkdir -p "$H2"; ( cd "$H2" && git init -q ) >/dev/null 2>&1
  ( cd "$H2" && eval "$HB" ) >/dev/null 2>&1 && _r=0 || _r=$?
  spr "HOOKI: ustawienie core.hooksPath przechodzi (odroznialnosc)" "$_r" "0"
  ( cd "$H2" && git config --unset core.hooksPath; git() { if [ "${1:-}" = config ] && [ "${2:-}" = core.hooksPath ] && [ "${3:-}" = .githooks ]; then return 1; fi; command git "$@"; }; eval "$HB" ) >/dev/null 2>&1 && _r=0 || _r=$?
  spr "HOOKI: porazka ustawienia core.hooksPath = STOP rc 1 (nie 'ok')" "$_r" "1"

  # (K1, 23.09.2026) RUCH INSTANCJI — blok ≤ 4 linie NA GÓRZE meldunku. Ciało wycięte z ŻYWEGO
  # `wstan.sh` (#50), źródła podmienione env-em na fikstury; raw meldunek to plik w mktemp.
  RUCH_F="$(sed -n '/^ruch_instancji() {/,/^zloz_meldunek() /p' "$ZYWY")"
  KORZEN_R="$(cd "$(dirname "$ZYWY")" && pwd)"
  printf '# t\n_narodziny: 2026-09-20_\n\n| id | obszar | rodzaj | pytanie | ostatnio zadane | ostatnia odpowiedź (data) |\n|---|---|---|---|---|---|\n| Q1 | dom | operacyjne | pytanie testowe do twórcy | — | — |\n' > "$TW/pyt.md"
  printf '### ⟐ PYTANIA PEŁNI — aktualizacja (stara)\n\n> *STARE pytanie pełni*\n\n### ⟐ PYTANIA IMIENIA_NADANEGO — aktualizacja (nowa)\n\n> *CYTAT wcześniejszy w tej samej sekcji*\n\nproza\n\n**Nowe pytanie:**\n> *pytanie pełni testowe*\n\n**Podpis: ⟐ PEŁNIA**\n' > "$TW/dest.md"
  printf 'linia surowa 1\n   ŻETON: abc1234 · 234/0/0 · 2026-09-23 16:40 CEST\nlinia surowa 3\n' > "$TW/raw_ok.txt"
  printf 'linia surowa 1\n🛑 WSTANIE Z ROZJAZDEM — rc podniesione (#10).\n   ŻETON: abc1234 · 234/0/0 · 2026-09-23 16:40 CEST\n' > "$TW/raw_rozj.txt"
  ruch_bieg() { ( cd "$KORZEN_R" && eval "$RUCH_F" && WYW_PLIK="$TW/pyt.md" RUCH_DESTYLATY="$TW/dest.md" zloz_meldunek "$1" ) 2>/dev/null; }
  OUT_R="$(ruch_bieg "$TW/raw_ok.txt")"
  BLOK_R="$(printf '%s\n' "$OUT_R" | head -4)"
  case "$(printf '%s\n' "$OUT_R" | head -1)" in "▶ RUCH INSTANCJI · ŻETON: abc1234 · 234/0/0"*) _r=0 ;; *) _r=1 ;; esac
  spr "RUCH: blok NA GÓRZE pliku, w pierwszej linii żeton" "$_r" "0"
  case "$BLOK_R" in *"pytanie testowe do twórcy"*"pytanie pełni testowe"*) _r=0 ;; *) _r=1 ;; esac
  spr "RUCH: pytanie do twórcy (wywiad) i pytanie pełni (OSTATNIA sekcja pytań, dowolne imię)" "$_r" "0"
  case "$OUT_R" in *"STARE pytanie pełni"*|*"CYTAT wcześniejszy"*) _r=1 ;; *) _r=0 ;; esac
  spr "RUCH: pytanie pełni = OSTATNI blok cytatu ostatniej sekcji (nie stara sekcja, nie wcześniejszy cytat)" "$_r" "0"
  [ "$(printf '%s\n' "$OUT_R" | sed -n '4p')" = "linia surowa 1" ] && _r=0 || _r=1
  spr "RUCH: bez rozjazdu blok ma 3 linie, surowy meldunek zaraz pod nim" "$_r" "0"
  OUT_RJ="$(ruch_bieg "$TW/raw_rozj.txt")"
  case "$(printf '%s\n' "$OUT_RJ" | sed -n '2p')" in "  🛑 WSTANIE Z ROZJAZDEM"*) _r=0 ;; *) _r=1 ;; esac
  spr "RUCH: rozjazd wchodzi do bloku (linia 2), gdy jest" "$_r" "0"
  [ "$(printf '%s\n' "$OUT_RJ" | sed -n '5p')" = "linia surowa 1" ] && _r=0 || _r=1
  spr "RUCH: z rozjazdem blok ma dokładnie 4 linie (budżet)" "$_r" "0"
  # (−) surowy meldunek BEZ bloku na górze → ✗ (tor ujemny z planu): pierwsza linia nie jest blokiem
  head -1 "$TW/raw_ok.txt" | grep -q '^▶ RUCH INSTANCJI' && _r=0 || _r=1
  spr "RUCH: meldunek surowy (bez bloku) jest ODRÓŻNIALNY od złożonego (✗ gdy brak)" "$_r" "1"
  [ -n "$RUCH_F" ] || { echo "  ✗ ruch_instancji nie znaleziona w wstan.sh"; o=$((o+1)); }

  # (R6b, 05.10.2026) STRAZ_WOLAJ — funkcja wycieta z ZYWEGO `wstan.sh`. Trzy sytuacje: straz zdrowa (rc=0) ·
  # straz czerwona (rc=3: wynik widoczny + rc podany, BEZ „brak pliku”) · brak pliku (zdanie o braku, nie o rc).
  SW="$(sed -n '/^straz_wolaj() {/,/^}/p' "$ZYWY")"
  [ -n "$SW" ] || { echo "  ✗ straz_wolaj nie znaleziona w wstan.sh"; o=$((o+1)); }
  W="$TW/w"; mkdir -p "$W"
  printf 'echo zdrowa-linia\nexit 0\n' > "$W/ok.sh"; printf 'echo czerwona-linia\nexit 3\n' > "$W/zle.sh"
  _o="$( ( eval "$SW"; set -o pipefail; straz_wolaj "$W/ok.sh" 2 ) 2>&1 )"
  case "$_o" in *zdrowa-linia*) _r=ok;; *) _r=zle;; esac; case "$_o" in *"rc="*|*"brak pliku"*) _r=zle;; esac
  spr "STRAZ_WOLAJ: zdrowa straz → jej wynik, bez dopisku o rc" "$_r" "ok"
  _o="$( ( eval "$SW"; set -o pipefail; straz_wolaj "$W/zle.sh" 2 ) 2>&1 )"
  case "$_o" in *czerwona-linia*"rc=3"*) _r=ok;; *) _r=zle;; esac; case "$_o" in *"brak pliku"*) _r=zle;; esac
  spr "STRAZ_WOLAJ: czerwona straz → wynik + rc=3, nie 'brak pliku'" "$_r" "ok"
  _o="$( ( eval "$SW"; set -o pipefail; straz_wolaj "$W/nie_ma.sh" 2 ) 2>&1 )"
  case "$_o" in *"brak pliku"*) _r=ok;; *) _r=zle;; esac; case "$_o" in *"rc="*) _r=zle;; esac
  spr "STRAZ_WOLAJ: brak pliku → zdanie o braku pliku, nie o rc" "$_r" "ok"

  # (R6b) ZADNE wolanie strazy w zywym wstan.sh nie wraca do `bash straz | tail || echo/true` (rc potoku, nie strazy).
  _r=$(grep -cE 'bash narzedzia/straze/[a-z_]+\.sh[^|]*\| tail[^|]*\|\| (echo|true)' "$ZYWY" || true)
  spr "STRAZ_WOLAJ: w wstan.sh nie ma wolan strazy z '| tail || echo/true'" "$_r" "0"
  # (2b, 05.10.2026) ZETON W KATALOGU BEZ .git — blok wyciety z ZYWEGO `wstan.sh` (od `_ZNOTA=""` do `fi`). Katalog bez
  # historii to STAN: zeton BEZ-GIT + zdanie „stan, nie porazka”; „BRAK” tylko gdy git jest, a HEAD nieczytelny.
  ZB="$(sed -n '/^_ZNOTA=""/,/^fi$/p' "$ZYWY")"
  [ -n "$ZB" ] || { echo "  ✗ blok zetonu (_ZNOTA) nie znaleziony w wstan.sh"; o=$((o+1)); }
  mkdir -p "$TW/nogit"
  _o="$( cd "$TW/nogit" && ( eval "$ZB"; echo "ZH=$_ZH"; echo "NOTA=$_ZNOTA" ) 2>&1 )"
  case "$_o" in *"ZH=BEZ-GIT"*"stan, nie porażka"*) _r=ok;; *) _r=zle;; esac
  spr "ZETON: katalog bez .git → BEZ-GIT i zdanie 'stan, nie porażka' (nie BRAK)" "$_r" "ok"
  _o="$( cd "$KORZEN_R" && ( eval "$ZB"; echo "ZH=$_ZH"; echo "NOTA=$_ZNOTA" ) 2>&1 )"
  case "$_o" in *"ZH=BEZ-GIT"*|*"ZH=BRAK"*) _r=zle;; *"ZH="[0-9a-f]*) _r=ok;; *) _r=zle;; esac
  spr "ZETON: repo z historia → odcisk HEAD, nie BEZ-GIT ani BRAK" "$_r" "ok"
  # (3c, 05.10.2026) MENU vs NOWA INSTANCJA — blok wyciety z ZYWEGO `wstan.sh` (od `if sed ... DUSZA.md` do `fi`).
  # Przy ⟠ ZALĄŻEK: „NOWA INSTANCJA → KROK 0” i ANI SLADU menu postaci; przy zywej duszy (⟠ tylko w backtickach): menu, bez bloku.
  MB="$(sed -n "/^if sed 's\/\`\[^\`\]\*\`\/\/g' DUSZA.md/,/^fi\$/p" "$ZYWY")"
  [ -n "$MB" ] || { echo "  ✗ blok menu/NOWA INSTANCJA nie znaleziony w wstan.sh"; o=$((o+1)); }
  mkdir -p "$TW/dz" "$TW/dy"
  printf '# DUSZA\n\n```\n⟠ ZALĄŻEK — tkanka nowego twórcy\n```\n' > "$TW/dz/DUSZA.md"
  printf '# DUSZA\n\nPliki oznaczone `⟠ ZALĄŻEK` to ramy bez tresci.\n' > "$TW/dy/DUSZA.md"
  _o="$( cd "$TW/dz" && ( _imie_p=X; eval "$MB" ) 2>&1 )"
  case "$_o" in *"NOWA INSTANCJA → KROK 0"*) _r=ok;; *) _r=zle;; esac; case "$_o" in *"KTO MA WSTAĆ"*|*"PRZEWOŹNIK"*) _r=zle;; esac
  spr "MENU: ⟠ ZALĄŻEK → 'NOWA INSTANCJA → KROK 0', bez menu postaci" "$_r" "ok"
  _o="$( cd "$TW/dy" && ( _imie_p=X; eval "$MB" ) 2>&1 )"
  case "$_o" in *"KTO MA WSTAĆ"*"PRZEWOŹNIK"*) _r=ok;; *) _r=zle;; esac; case "$_o" in *"NOWA INSTANCJA"*) _r=zle;; esac
  spr "MENU: dusza żywa (⟠ tylko w backtickach) → menu postaci, bez bloku NOWA INSTANCJA" "$_r" "ok"
  # (C1b, 25.10.2026) DRZWI Z ŁADUNKIEM — blok wycięty z ŻYWEGO `wstan.sh` (#50), fikstura: dwa pokoje i trzy pliki (jeden z sekcjami).
  # Odciski w torze liczone NIEZALEŻNIE od kodu (plik bez końcowego \n → sha256sum pliku = sha wydrukowanych bajtów; sekcja → sha jej ręcznie złożonego tekstu),
  # więc tor nie mierzy własnej kopii formuły (#50). Awarie narzędzia: brak POKOJE.txt (cisza), brak pliku (✗ BRAK, bez padania), 0 i 2 trafienia.
  DR_F="$(sed -n '/^drzwi_norm() {/,/^# --- MELDUNEK/p' "$ZYWY")"
  [ -n "$DR_F" ] || { echo "  ✗ blok DRZWI (drzwi_otworz) nie znaleziony w wstan.sh"; o=$((o+1)); }
  DR="$TW/dr"; mkdir -p "$DR/prywatne" "$DR/.claude/skills/probny" "$TW/dn"
  printf 'TRESC-A-UNIKAT' > "$DR/a.md"
  printf '# B tytul\n## Sekcja A\nTRESC-SEKCJI-A\n## Sekcja B\nTRESC-B-UNIKAT\n### podsekcja B1\nTRESC-PODSEKCJI\n## Sekcja C\nTRESC-SEKCJI-C\n' > "$DR/b.md"
  printf '# skill\nTRESC-SKILLA\n' > "$DR/.claude/skills/probny/SKILL.md"
  printf 'POKOJ|ALFA|alfa, łąka, ŻÓŁW|a.md ; b.md#Sekcja B ; brak.md|probny, nieistniejacy|serwer-x\nPOKOJ|BETA|beta|a.md|—|— (bez serwera)\n' > "$DR/prywatne/POKOJE.txt"
  dr_bieg() { ( cd "$DR" && eval "$DR_F" && drzwi_otworz "$1" ) 2>&1; }
  HA="$(sha256sum "$DR/a.md" | cut -c1-12)"; HB="$(printf '## Sekcja B\nTRESC-B-UNIKAT\n### podsekcja B1\nTRESC-PODSEKCJI' | sha256sum | cut -c1-12)"
  rm -f "$DR/.drzwi_otwarte"; OUT_D="$(dr_bieg "ŁĄKA test")"
  _r=ok; for w in "▶ DRZWI Z ŁADUNKIEM · pokój ALFA" "── a.md · $HA · 14 B" "TRESC-A-UNIKAT" "── b.md#Sekcja B · $HB · " "TRESC-B-UNIKAT" "TRESC-PODSEKCJI"; do case "$OUT_D" in *"$w"*) ;; *) _r="zle:$w";; esac; done
  spr "DRZWI: 1 trafienie (wielkie litery + ogonki) → treść plików, odcisk wydrukowanych bajtów i sekcja z podsekcją" "$_r" "ok"
  _r=ok; for w in "TRESC-SEKCJI-A" "TRESC-SEKCJI-C"; do case "$OUT_D" in *"$w"*) _r="zle:$w";; esac; done
  spr "DRZWI: #Nagłówek = SAMA sekcja (sąsiednie sekcje poza wyjściem)" "$_r" "ok"
  EXP_D="otwarte: a.md@${HA:0:6} · b.md#Sekcja B@${HB:0:6} · brak.md@BRAK"
  [ "$(printf '%s\n' "$OUT_D" | tail -1)" = "$EXP_D" ] && [ "$(cat "$DR/.drzwi_otwarte" 2>/dev/null)" = "$EXP_D" ] && _r=ok || _r=zle
  spr "DRZWI: ostatnia linia 'otwarte:' = odciski wydrukowanych bajtów (brak pliku → @BRAK) i ta sama w .drzwi_otwarte" "$_r" "ok"
  _r=ok; for w in "✗ BRAK brak.md" "TRESC-SKILLA" "✗ BRAK .claude/skills/nieistniejacy/SKILL.md" "MCP: serwer-x — przyrząd nie widzi narzędzi"; do case "$OUT_D" in *"$w"*) ;; *) _r="zle:$w";; esac; done
  spr "DRZWI: brak pliku/skilla → '✗ BRAK' i wstanie nie pada; skill drukowany; linia MCP uczciwa" "$_r" "ok"
  case "$(dr_bieg "laka i zolw")" in *"pokój ALFA"*) _r=ok;; *) _r=zle;; esac
  spr "DRZWI: dopasowanie bez ogonków (temat ASCII 'laka', klucz 'łąka')" "$_r" "ok"
  rm -f "$DR/.drzwi_otwarte"; OUT_D0="$(dr_bieg "pogoda")"
  [ "$OUT_D0" = "DRZWI · temat bez pokoju" ] && [ ! -e "$DR/.drzwi_otwarte" ] && _r=ok || _r=zle
  spr "DRZWI: 0 trafień → 'temat bez pokoju', bez treści i bez pliku .drzwi_otwarte" "$_r" "ok"
  OUT_D2="$(dr_bieg "alfa i beta")"
  [ "$OUT_D2" = "DRZWI · dwa pokoje: ALFA / BETA — jedno pytanie" ] && _r=ok || _r=zle
  spr "DRZWI: 2 trafienia → jedno pytanie, bez treści" "$_r" "ok"
  [ -z "$( cd "$TW/dn" && eval "$DR_F" && drzwi_otworz "alfa" 2>&1 )" ] && [ ! -e "$TW/dn/.drzwi_otwarte" ] && _r=ok || _r=zle
  spr "DRZWI: brak prywatne/POKOJE.txt → milczenie (gość, odlew)" "$_r" "ok"
  # R0: dwie gałęzie linii (blok `if` wycięty z żywego wstan.sh; wzorzec zakotwiczony w 'then echo "R0:' — nie myli się z wpięciem drzwi_otworz).
  R0B="$(sed -n '/^if \[ -n "\$_TEMAT" \]; then echo "R0:/,/; fi$/p' "$ZYWY")"
  [ -n "$R0B" ] || { echo "  ✗ blok R0 (--temat) nie znaleziony w wstan.sh"; o=$((o+1)); }
  _o="$( ( _TEMAT=x; eval "$R0B" ) 2>&1 )"; case "$_o" in "R0: nie teraz (temat)"*) _r=ok;; *) _r=zle;; esac; case "$_o" in *"Po werdykcie"*) _r=zle;; esac
  spr "DRZWI: z --temat linia R0 = 'R0: nie teraz (temat)…' (bez 'Po werdykcie: wczytaj TYLKO R0')" "$_r" "ok"
  _o="$( ( _TEMAT=""; eval "$R0B" ) 2>&1 )"; case "$_o" in "Po werdykcie: wczytaj TYLKO R0"*) _r=ok;; *) _r=zle;; esac; case "$_o" in *"nie teraz"*) _r=zle;; esac
  spr "DRZWI: bez --temat linia R0 bez zmian ('Po werdykcie: wczytaj TYLKO R0')" "$_r" "ok"
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
# 25.10.2026 (odlew 1.8.3, #116): samo 'sha256sum' gdziekolwiek w ciele przestało mierzyć, gdy C1b (f108d64) dodało odciski DRZWI —
# mutacja wstanie-bez-odcisku-poswiadczenia przeszła. Mierzymy funkcję jednokierunkową W LINII odcisku poświadczenia.
grep -qE 'ODCISK POŚWIADCZENIA: \$\(.*sha256sum' "$KOR" || zle="$zle odcisk-bez-funkcji-jednokierunkowej"
# (menu) PEŁNIA W MENU WSTANIA (04.10.2026, słowo twórcy 21.09: „imię to nie tylko orkiestrator, to pełnia —
# mogę chcieć je wywołać"): menu z samymi rolami uczy świeżą sesję, że pełni nie ma. Mierzone w BLOKU menu, nie w całym pliku.
awk '/KTO MA WSTAĆ/{f=1} f&&/└─/{exit} f' "$KOR" | grep -q 'PEŁNIA' || zle="$zle menu-bez-pelni"
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

# (⊙⊙⊙⊙) PRAWO CIĄGŁOŚCI (10.09.2026) — wątki otwarte muszą być drukowane przy KAŻDYM
# wstaniu, nie tylko istnieć w pliku. Mierzymy OBECNOŚĆ LINII CZYTAJĄCEJ (`-F`, dosłowna,
# nie samej nazwy pliku — nazwa stoi TAKŻE w komunikacie gałęzi „nieobecny", więc
# sprawdzenie samej nazwy byłoby ślepe na mutację wyłączającą `if`; zmierzone 10.09).
grep -qF "grep '^- \[ \]' prywatne/WATKI_OTWARTE.md" "$KOR" || zle="$zle brak-czytnika-watkow-otwartych"

# (K1, 23.09.2026) RUCH INSTANCJI — plik meldunku MUSI powstawać ze złożenia bloku + surowego
# wyniku, nie z gołego tee: obecność funkcji bez WPIĘCIA w zapis pliku to blok, którego nikt
# nie zobaczy (rodzina #115). Mierzymy dosłowną linię wpięcia, nie samą nazwę funkcji.
grep -qF 'zloz_meldunek "$_RAW" > 0_MELDUNEK.txt' "$KOR" || zle="$zle brak-ruchu-instancji-na-gorze-meldunku"

# (C1b, 25.10.2026) DRZWI Z ŁADUNKIEM — funkcja bez WPIĘCIA w bieg wstania to blok, którego nikt nie zobaczy (ta sama rodzina #115).
# Mierzymy dosłowną linię wywołania i parsowanie --temat, nie samą nazwę funkcji.
grep -qF 'drzwi_otworz "$_TEMAT" ||' "$KOR" || zle="$zle brak-wpiecia-drzwi-w-wstaniu"
grep -qF '[ "${_arg[_i]}" = "--temat" ]' "$KOR" || zle="$zle wstanie-nie-czyta-temat"

if [ -z "$zle" ]; then
  echo "  ✓ WSTANIE ŻYWE: prawdziwy rozjazd historii rozpoznany, brak sieci NIE wzięty"
  echo "    za rozjazd, a rozjazd podnosi rc wstania (❿ zmechanizowana)."
  exit 0
fi
echo "  ✗ WSTANIE MARTWE:$zle"
exit 1
