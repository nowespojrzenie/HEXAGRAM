#!/usr/bin/env bash
# ═══ STRAŻ NARODZIN (21.08.2026) — czy nowy artefakt dostał komplet ═══
#
# RODOWÓD Z POLICZONEJ HISTORII, NIE Z WRAŻENIA. W dobie 20–21.08 do repo weszło SZEŚĆ
# nowych plików. Wszystkie sześć wymagały RĘCZNEGO domknięcia rejestru — fraza
# „POZA REJESTREM / dopisany świadomie" pada w commitach tej doby sześć razy.
# Żadna z czternastu straży nie pytała „czy ten nowy artefakt dostał, co mu się należy".
#
# CO TO ZNACZY STRUKTURALNIE: system ma znakomite mechanizmy dla materii ISTNIEJĄCEJ
# (177 sprawdzeń, 36 straży z torami, 77 mutacji, zero ślepych) i prawie żadnych dla
# materii WCHODZĄCEJ. Wady nie brały się z niedbałości, tylko z TEMPA NARODZIN.
#
# TA STRAŻ NIE DOKŁADA DYSCYPLINY — ZDEJMUJE JĄ. Każdy z tych kroków trzeba było dotąd
# pamiętać. Warunek jej sensu postawiony PRZED budową: jeśli nie zmniejszy pracy ręcznej,
# jest tylko kolejnym plikiem podnoszącym R0.
#
# MIERZY NARODZINY, NIE STAN (lekcja #61). Zakres: pliki `A` (added) względem HEAD.
# Zastany dług jej z definicji nie dotyczy — inaczej weszłaby dopiero po jego spłacie,
# czyli „kiedyś". Zmierzone przed budową: 4 pliki z 57 w korzeniu nie mają dziś odcisku
# (`_rozdziel_okna.js` `_zdejmij_hub.js` `narzedzia/przyrzady/triage.js` `narzedzia/silniki/wezownik.js`) — ten dług widać
# w `--audyt`, ale nie blokuje niczyjego commita.
#
# ZAKRES WĄSKI, ZMIERZONY: śledzone `*.sh` i `*.js` w KORZENIU. Objęcie `*.md` dałoby
# ponad 20 trafień na zastanym stanie (`hashuj.sh` w trybie tkanki świadomie nie pokrywa
# wszystkich ksiąg) — straż wołająca nad legalnym stanem uczy nie patrzeć (#56).
#
# CZEGO NIE DUBLUJE — nazwane, żeby nie powstał drugi taki sam przyrząd:
#   wiersz w `kanon/ksiegi/MOSTY.md`        → `straz_mostow.sh` (pyta o KAŻDY przyrząd, nie tylko nowy)
#   pozycja na liście baterii  → zamek pokrycia w `tory_strazy.sh`
#   FORMAT wierszy `_HASHE`    → hook (`.githooks/pre-commit`)
# Ta straż pyta o to, czego nie pyta nikt: czy odcisk W OGÓLE ISTNIEJE i czy mechanizm
# ma mutację. `hashuj.sh` świadomie ODMAWIA tworzenia odcisków dla nowych plików
# (melduje „POZA REJESTREM" i przechodzi) — więc luka była po stronie czytnika, nie autora.
#
# UŻYCIE:  bash straz_narodzin.sh          (rc=1 gdy nowy artefakt niekompletny)
#          bash straz_narodzin.sh --audyt  (cały korzeń, informacyjnie, nigdy rc=1)
#          bash straz_narodzin.sh --test   (tor +/− — straż musi umieć NIE przejść)
set -u
cd "$(dirname "$0")/../.."

HASHE="${HASHE:-_HASHE.txt}"
MUTACJE="${MUTACJE:-mutacje.txt}"

# ── czy plik ma odcisk w rejestrze ──
ma_odcisk() { grep -q "  $1\$" "$HASHE" 2>/dev/null; }

# ── czy plik jest MECHANIZMEM (deklaruje własny tor) ──
# Kryterium jest ZACHOWANIEM pliku, nie jego nazwą: `straz_x.sh` bez toru nie jest
# mechanizmem w sensie tego prawa, a `narzedzia/przyrzady/rzut.js` z `--test` jest. Nazwa bywa myląca,
# obecność toru nie (#59: zamek nazwany czynnością, której nie wykonuje).
# WZMIANKA TO NIE OBSŁUGA (naprawione 21.08 — #56 na własnej ręce).
# Pierwsza wersja szukała literału `--test` gdziekolwiek w pliku i zgłaszała
# `testy_rdzen.js` jako mechanizm bez mutacji. Tymczasem ten plik NIE deklaruje toru —
# on sam JEST torem (`node --test testy_rdzen.js`), a jedyne wystąpienie stoi w KOMENTARZU
# z instrukcją uruchomienia. Straż wołała nad legalnym stanem, czyli uczyła nie patrzeć.
# Kryterium jest teraz OBSŁUGA FLAGI w kodzie — trzy formy używane w tym repo.
jest_mechanizmem() {
  grep -qE -- '(\$\{1:-\}" = "--test"|"\$1" = "--test"|argv\.includes\('"'"'--test'"'"'\)|args\.includes\('"'"'--test'"'"'\))' "$1" 2>/dev/null
}

# ── czy istnieje mutacja celująca w ten plik ──
ma_mutacje() { grep -q "|||$1|||" "$MUTACJE" 2>/dev/null; }

# ── NARZĘDZIA JEDNORAZOWE: prefiks `_` w zakresie *.sh/*.js ───────────────────
# Wykonane raz, na konkretnej materii, martwe z chwilą wykonania — deklarują to same
# w pierwszej linii. Odcisk pilnowałby niezmienności czegoś, czego nikt już nie uruchomi.
# ZWOLNIENIE JAWNE, z powodem i z torem: cicha nieobecność byłaby nieodróżnialna od
# przeoczenia (ta sama zasada, co POZA_BATERIA i sekcja ⓘ w MOSTY).
# Zmierzone przed regułą: w zakresie *.sh/*.js w korzeniu prefiks `_` noszą DOKŁADNIE
# dwa pliki i oba są jednorazowe — reguła nie zgarnia niczego żywego.
jednorazowy() { case "$(basename "$1")" in _*) return 0 ;; *) return 1 ;; esac; }

# ── sprawdź jeden plik; drukuje braki, zwraca liczbę braków ──
sprawdz() {
  local f="$1" braki=0
  jednorazowy "$f" && { echo "   ⓘ $f — narzędzie jednorazowe (prefiks _), zwolnione jawnie"; return 0; }
  ma_odcisk "$f" || { echo "   ✗ $f — BRAK ODCISKU w $HASHE (hashuj.sh nie tworzy go sam)"; braki=$((braki+1)); }
  if jest_mechanizmem "$f"; then
    ma_mutacje "$f" || { echo "   ✗ $f — deklaruje tor (--test), a NIE MA MUTACJI w $MUTACJE"; braki=$((braki+1)); }
  fi
  return $braki
}

# ── TOR WŁASNY (#38 · #47) ────────────────────────────────────────────────────
# PRAWO FIKSTURY zastosowane do samej siebie: przypadki ujemne napisane PRZED ciałem,
# każdy z materią, którą złamany kod BY ZNALAZŁ. Trzy razy dziś nie tor był za słaby,
# tylko dane (#51) — ten tor powstał z tamtej lekcji.
if [ "${1:-}" = "--test" ]; then
  echo "╔═══ STRAŻ NARODZIN — AUTOTEST (#38) ═══╗"
  T="$(mktemp -d)"; z=0; o=0
  spr() { if [ "$2" = "$3" ]; then echo "  ✓ $1"; z=$((z+1)); else echo "  ✗ $1 (rc=$2, oczekiwano $3)"; o=$((o+1)); fi; }
  # FIKSTURA ODTWARZA TOPOLOGIĘ PRODUKCJI (29.08, dach narzedzia/straze/): straż robi
  # `cd dirname/../..`, więc kopia MUSI leżeć dwa poziomy pod korzeniem atrapy — kopia
  # w korzeniu wyprowadzała `cd` POZA atrapę, na żywe repo (#66 ods. 8 / #70).
  mkdir -p "$T/narzedzia/straze"
  cp "$0" "$T/narzedzia/straze/straz.sh"
  ( cd "$T" && git init -q . && git config user.email z@z.z && git config user.name Z ) >/dev/null 2>&1
  # baza: jeden commit, żeby „nowy plik" miał względem czego być nowy
  ( cd "$T" && : > _HASHE.txt && : > mutacje.txt && git add -A && git commit -qm baza ) >/dev/null 2>&1
  run() { ( cd "$T"; bash narzedzia/straze/straz.sh >/dev/null 2>&1 && _r=0 || _r=$?; echo "$_r"; ); }

  # (1) ZERO ZNACZĄCE: żadnego nowego pliku — stan zdrowy, nie alarm
  spr "brak nowych plikow przechodzi (zero znaczace)" "$(run)" "0"

  # (2) ŚCIEŻKA UJEMNA #1: nowy plik BEZ odcisku — MUSI oblać
  printf '#!/bin/sh\necho x\n' > "$T/nowy.sh"; ( cd "$T" && git add nowy.sh ) >/dev/null 2>&1
  spr "NOWY plik bez odcisku OBLEWA" "$(run)" "1"

  # (3) ten sam plik z odciskiem — przechodzi (nie jest mechanizmem: brak --test)
  printf 'aaaaaaaaaaaa  nowy.sh\n' > "$T/_HASHE.txt"
  spr "nowy plik Z odciskiem przechodzi" "$(run)" "0"

  # (4) ŚCIEŻKA UJEMNA #2: nowy MECHANIZM (ma --test) bez mutacji — MUSI oblać.
  #     Materia niesie literał `--test`, czyli dokładnie to, czego szuka `jest_mechanizmem`;
  #     bez tego przypadek byłby nieodróżnialny od (3) i tor przechodziłby nad złamanym kodem.
  printf '#!/bin/sh\nif [ "$1" = "--test" ]; then exit 0; fi\n' > "$T/mech.sh"
  printf 'aaaaaaaaaaaa  nowy.sh\nbbbbbbbbbbbb  mech.sh\n' > "$T/_HASHE.txt"
  ( cd "$T" && git add mech.sh ) >/dev/null 2>&1
  spr "nowy MECHANIZM bez mutacji OBLEWA (prawo fikstury)" "$(run)" "1"

  # (5) ten sam mechanizm z mutacją — przechodzi
  printf 'jakas-mutacja|||mech.sh|||a|||b|||sh mech.sh --test\n' > "$T/mutacje.txt"
  spr "mechanizm Z mutacja przechodzi" "$(run)" "0"

  # (6) plik SPOZA zakresu (.md) nie jest pilnowany — inaczej 20+ trafień na zastanym stanie
  printf 'tresc\n' > "$T/ksiega.md"; ( cd "$T" && git add ksiega.md ) >/dev/null 2>&1
  spr "nowy .md poza zakresem, nie alarmuje (#56)" "$(run)" "0"

  # (7a) nowy .js BEZ odcisku — MUSI oblać. Fikstura dopisana po ŚLEPEJ MUTACJI
  #      `narodziny-zakres-gubi-js` (21.08): tor sprawdzał wyłącznie `.sh`, więc zwężenie
  #      zakresu do `.sh` przechodziło niezauważone. Znów nie tor był za słaby, tylko dane (#51).
  printf 'console.log(1)\n' > "$T/nowy.js"; ( cd "$T" && git add nowy.js ) >/dev/null 2>&1
  spr "nowy .js bez odcisku OBLEWA (zakres obejmuje js)" "$(run)" "1"
  printf 'aaaaaaaaaaaa  nowy.sh\nbbbbbbbbbbbb  mech.sh\ncccccccccccc  nowy.js\n' > "$T/_HASHE.txt"
  spr "nowy .js Z odciskiem przechodzi" "$(run)" "0"

  # (5a) WZMIANKA o `--test` w KOMENTARZU to NIE mechanizm — inaczej straż woła nad
  #      plikiem, który sam jest torem (`testy_rdzen.js`). Fikstura odróżnialna (#64):
  #      ten sam brak mutacji, dwa przeciwne werdykty — różnica w tym, czy flaga jest OBSŁUGIWANA.
  printf '// Uruchomienie: node --test wzmianka.js\nconsole.log(1)\n' > "$T/wzmianka.js"
  printf 'aaaaaaaaaaaa  nowy.sh\nbbbbbbbbbbbb  mech.sh\ncccccccccccc  nowy.js\neeeeeeeeeeee  wzmianka.js\n' > "$T/_HASHE.txt"
  ( cd "$T" && git add wzmianka.js ) >/dev/null 2>&1
  spr "WZMIANKA o --test w komentarzu nie czyni mechanizmu" "$(run)" "0"

  # (6a) NARZĘDZIE JEDNORAZOWE bez odcisku — przechodzi, ale MUSI być odróżnialne
  #      od zwykłego pliku bez odcisku. Fikstura wprost z prawa #64: ten sam brak,
  #      dwa przeciwne werdykty, różnica wyłącznie w prefiksie.
  printf '#!/bin/sh\n' > "$T/_jednorazowy.sh"; ( cd "$T" && git add _jednorazowy.sh ) >/dev/null 2>&1
  spr "narzedzie jednorazowe (_) bez odcisku PRZECHODZI" "$(run)" "0"
  printf '#!/bin/sh\n' > "$T/zwykly.sh"; ( cd "$T" && git add zwykly.sh ) >/dev/null 2>&1
  spr "ten sam brak BEZ prefiksu _ nadal OBLEWA (odroznialnosc)" "$(run)" "1"
  printf 'aaaaaaaaaaaa  nowy.sh\nbbbbbbbbbbbb  mech.sh\ncccccccccccc  nowy.js\ndddddddddddd  zwykly.sh\neeeeeeeeeeee  wzmianka.js\n' > "$T/_HASHE.txt"

  # (7) plik w PODKATALOGU poza zakresem — zakres to korzeń, i to jest jawne
  mkdir -p "$T/pod" && printf '#!/bin/sh\n' > "$T/pod/glebiej.sh"
  ( cd "$T" && git add pod/glebiej.sh ) >/dev/null 2>&1
  spr "nowy .sh w podkatalogu poza zakresem" "$(run)" "0"

  # (8) BRAK rejestru odcisków — cisza byłaby fałszem (#39)
  rm -f "$T/_HASHE.txt"
  spr "BRAK rejestru odciskow oblewa, nie milczy (#39)" "$(run)" "1"

  rm -rf "$T"
  echo "  zmierzone: zdanych $z · oblanych $o"
  [ "$o" -eq 0 ] || { echo "  ✗ TOR OBLANY"; exit 1; }
  echo "  ✓ STRAŻ UMIE NIE PRZEJŚĆ — reguła nie obowiązuje wyłącznie w dokumentacji."
  exit 0
fi

# ── AUDYT CAŁEGO KORZENIA (informacyjnie, nigdy rc=1) ─────────────────────────
if [ "${1:-}" = "--audyt" ]; then
  echo "▤ STRAŻ NARODZIN — audyt korzenia (zastany dług, NIE blokada):"
  braki=0
  for f in $(git ls-files -- '*.sh' '*.js' 2>/dev/null | grep -vE '/' ; git ls-files -- 'narzedzia/*/*.sh' 'narzedzia/*/*.js' 2>/dev/null); do   # korzeń + dach narzedzia/ (29.08)
    sprawdz "$f" || braki=$((braki+$?))
  done
  [ "$braki" -eq 0 ] && echo "   ✓ komplet — każdy przyrząd w korzeniu ma odcisk, każdy mechanizm mutację."
  echo "   zmierzone: braków $braki (audyt świeci, nie kroi — cięcia należą do twórcy)"
  exit 0
fi

# ── PRZEBIEG ŻYWY: NARODZINY ──────────────────────────────────────────────────
echo "▤ STRAŻ NARODZIN — czy nowy artefakt dostał komplet:"

if [ ! -f "$HASHE" ]; then
  echo "   ✗ brak rejestru odcisków ($HASHE) — straż NIE ZMIERZYŁA, więc się nie zieleni (#39)."
  exit 1
fi

if git rev-parse --verify -q HEAD >/dev/null 2>&1; then
  NOWE="$(git diff --cached --name-only --diff-filter=A 2>/dev/null | grep -E '^(narzedzia/[^/]+/)?[^/]+\.(sh|js)$' || true)"   # korzeń + dach narzedzia/ (29.08)
else
  NOWE="$(git ls-files -- '*.sh' '*.js' 2>/dev/null | grep -E '^(narzedzia/[^/]+/)?[^/]+\.(sh|js)$' || true)"
fi

if [ -z "$NOWE" ]; then
  echo "   ✓ żadnego nowego przyrządu w tym commicie — nic się dziś nie rodzi (zero znaczące)."
  exit 0
fi

braki=0
for f in $NOWE; do
  echo "   • rodzi się: $f"
  sprawdz "$f" || braki=$((braki+$?))
done

if [ "$braki" -eq 0 ]; then
  echo "   ✓ NARODZINY KOMPLETNE — odcisk jest, mechanizm ma mutację."
  echo "     (wiersz w MOSTY pyta straz_mostow, pozycję w baterii — zamek pokrycia)"
  exit 0
fi
echo "   ✗ $braki brak(ów). Artefakt bez rejestru jest obietnicą bez czytnika (#55),"
echo "     a mechanizm bez mutacji — życzeniem o mechanizmie (inwariant 5)."
exit 1
