#!/usr/bin/env bash
# ═══ STRAŻ DOJRZAŁOŚCI (21.08.2026) — czy przyrząd jest gotów WYJŚĆ ═══
#
# SYMETRIA DO NARODZIN (zamówienie twórcy 21.08: „obserwacja narodzin jest ważna,
# dojrzałości podobnie"). `straz_narodzin.sh` pyta o CHWILĘ WEJŚCIA — czy nowy artefakt
# dostał komplet. Ta pyta o CHWILĘ WYJŚCIA — czy to, co ma trafić do publicznego odlewu,
# jest dojrzałe, i czy coś już dojrzało, a nikt tego nie zauważył.
#
# DOJRZAŁOŚĆ NIE JEST WIEKIEM. To nie jest przywrócona bramka 1: cisza nie dowodzi
# stabilności (odwołanie 21.08), więc żadne kryterium tutaj nie liczy dni. Wszystkie
# sześć jest POKRYCIOWE — mierzą, czy przyrząd ma świadków, nie jak długo leży.
#
# SZEŚĆ KRYTERIÓW, każde zmierzone osobno (brak choćby jednego = NIEDOJRZAŁY):
#   1. TOR W BATERII        — zdolność do odmowy dowiedziona i uruchamiana regularnie
#   2. MUTACJA ZŁAPANA      — tor ma świadka innego niż własny autor (#47)
#   3. ODCISK w `_HASHE`    — niezmienność pilnowana
#   4. MOST albo AMNESTIA   — odpowiedział „z czym jestem równoległy" (#26 · MOSTY)
#   5. WOŁANY               — co najmniej jeden inny przyrząd go uruchamia; sierota
#                             nie jest dojrzała, jest nieużywana
#   6. BEZ NAZWANEGO DŁUGU  — w `kanon/ksiegi/MOSTY.md` nie stoi przy nim „DŁUG NAZWANY, NIE ZAMKNIĘTY"
#
# KRYTERIUM 6 JEST TU NAJWAŻNIEJSZE I NAJTAŃSZE. Repo od miesiąca zapisuje własne
# niedomknięcia w `kanon/ksiegi/MOSTY.md` pełnym zdaniem — a nikt tego nigdy nie odczytywał maszynowo.
# To jest SAMODEKLARACJA NIEDOJRZAŁOŚCI, leżąca w kanonie i niewidzialna dla przyrządów
# (#55: obietnica bez czytnika to proza). Ten tryb daje jej czytnika.
#
# CO TA STRAŻ NAZYWA, A CZEGO NIE ROZSTRZYGA: mierzy dojrzałość, NIE decyduje o wydaniu.
# „Dojrzały i poza odlewem" to KANDYDAT, nie polecenie — biała lista publikacji należy
# do twórcy (to samo rozgraniczenie, co przy bramce 6 `gotowosc.sh`).
#
# UŻYCIE:  bash straz_dojrzalosci.sh            (przyrządy W odlewie; rc=1 gdy któryś niedojrzały)
#          bash straz_dojrzalosci.sh --kandydaci (dojrzałe POZA odlewem — „dojrzało, zauważ")
#          bash straz_dojrzalosci.sh --test      (tor +/− — straż musi umieć NIE przejść)
set -u
cd "$(dirname "$0")/../.."

BATERIA="${BATERIA:-tory_strazy.sh}"
MUTACJE="${MUTACJE:-mutacje.txt}"
HASHE="${HASHE:-_HASHE.txt}"
MOSTY="${MOSTY:-kanon/ksiegi/MOSTY.md}"
PUBLIKUJ="${PUBLIKUJ:-publikuj.sh}"

# ── przyrządy na białej liście odlewu (sekcje JS + SH) ──
# C3 · tura 4 (02.09.2026): JEDNO ŹRÓDŁO ODCZYTU. Własny sed zdjęty — czwarty wzorzec
# na tę samą listę był czwartą prawdą o tym samym (#4). `$PUBLIKUJ` znaczy odtąd
# SKRYPT DO ZAPYTANIA, nie plik do sparsowania; fikstury toru odpowiadają na `--lista`.
# Równoważność zmierzona przed cięciem: ten sam zbiór ścieżek, diff pusty.
w_odlewie() {
  { sh "$PUBLIKUJ" --lista JS; sh "$PUBLIKUJ" --lista SH; } 2>/dev/null \
    | grep -E '\.(sh|js)$' | sort -u
}

# KLUCZ BATERII = nazwa bazowa (29.08.2026, dach narzedzia/): przyrząd z domem
# pod dachem nadal ma tor pod gołą nazwą — ścieżka nie jest częścią klucza.
ma_tor_w_baterii() { local _b; _b="$(basename "$1")"; grep -q "^${_b%.*}|" "$BATERIA" 2>/dev/null; }
ma_odcisk()        { grep -q "  $1\$" "$HASHE" 2>/dev/null; }
# AMNESTIA CZYTANA Z JEDNEGO ŹRÓDŁA (#4: jedno źródło każdej funkcji). `straz_mostow.sh`
# trzyma listę ZASTANE — przyrządy sprzed prawa mostów (16.07), zwolnione jawnie.
# Druga własna lista byłaby drugą prawdą o tym samym; ta straż CZYTA tamtą.
zastany_w_mostach() {
  # dach narzedzia/ (29.08): ZASTANE i MOSTY mówią NAZWAMI, straż pyta ŚCIEŻKAMI —
  # porównanie po basename po obu stronach. Bez tego przenosiny podniosły liczbę braków
  # z 23 na 52 i cały skok był fałszywym alarmem (ta sama klasa co klucz baterii, tura 4).
  local _b; _b="$(basename "$1")"
  sed -n '/^ZASTANE="/,/"$/p' narzedzia/straze/straz_mostow.sh 2>/dev/null | tr -s ' \n"' ' ' \
    | tr ' ' '\n' | while read -r _z; do [ -n "$_z" ] && basename "$_z"; done | grep -qx "$_b"
}
ma_most()          { grep -q "$(basename "$1")" "$MOSTY" 2>/dev/null || zastany_w_mostach "$1"; }
# WOŁANY W PRACY, NIE W TEŚCIE. Bateria z definicji wymienia każdy tor, więc gdyby ją
# liczyć, kryterium 5 byłoby kopią kryterium 1 i nie mierzyłoby nic własnego — zmierzone
# na własnym torze, gdzie „sierota" przechodziła, bo wołał ją plik baterii (#49: dwa liczniki
# tej samej wielkości udające dwa kryteria). Bateria i rejestr mutacji są wyłączone.
wolany() {
  # Wyłączeni z liczenia, każdy z własnego powodu:
  #   $1        — plik nie jest użytkownikiem samego siebie
  #   $BATERIA  — wymienia każdy tor z definicji (kopia kryterium 1)
  #   $MUTACJE  — rejestr, nie wołanie
  #   $PUBLIKUJ — LISTA tego, co ma wyjść; wymienienie na niej to nie użycie, tylko
  #               dokładnie ta wielkość, o którą pytamy — liczenie jej czyniłoby
  #               „jest w odlewie" dowodem na „jest używany" (#49, argument kołowy)
  #   ta straż  — jej własne fikstury noszą nazwy plików; policzenie ich uczyniłoby
  #               ją wołającym wszystkiego, co mierzy (#50 na własnej ręce, zmierzone
  #               na torze: „sierota" przechodziła, bo nazwa stała w ciele fikstury)
  # dach narzedzia/straze/ (29.08): grep zwraca ŚCIEŻKI, a wykluczenia były po nazwie —
  # własna kopia pod dachem przestawała się wykluczać i czyniła straż wołającym wszystkiego,
  # co mierzy (ten sam #50, o który tor już raz się rozbił; teraz porównanie po basename).
  local JA; JA="$(basename "$0")"
  # WYMIENIENIE ≠ WYWOŁANIE (29.08.2026). Do dziś `$PUBLIKUJ` był wyłączony W CAŁOŚCI —
  # słusznie dla białej listy (#49: „jest w odlewie" nie dowodzi „jest używany"), ale przez to
  # przyrząd, który publikuj.sh REALNIE WOŁA w potoku odlewu (`bash narzedzia/.../x.sh`),
  # meldował się jako niewołany. Dziesięć pozycji naraz — alarm szerszy niż sygnał (#56).
  # Rozdzielone: linie deklaracji FORMA_* nadal się nie liczą, linie wywołań liczą się.
  if grep -nE '(bash|sh|node) +[A-Za-z0-9_./-]*'"$(basename "$1")" "$PUBLIKUJ" 2>/dev/null \
     | grep -qvE 'FORMA_(MD|JS|SH|INNE|DIRS)='; then return 0; fi
  # RĘKA TO TEŻ WOŁANIE (29.08): narzędzie uruchamiane świadomie z pulpitu (`0_WYWOLANIA.md`)
  # ma wołającego — człowieka. Liczy się WYŁĄCZNIE linia z komendą, nie wzmianka w prozie,
  # inaczej pulpit stałby się listą, która dowodzi użycia samym wymienieniem (#49).
  if grep -qE '(bash|sh|node) +[A-Za-z0-9_./-]*'"$(basename "$1")" "${PULPIT:-0_WYWOLANIA.md}" 2>/dev/null; then
    return 0
  fi
  # SZUKAMY NAZWY BAZOWEJ, NIE ŚCIEŻKI (29.08): wołający używają obu form — `bash narzedzia/
  # straze/x.sh` w potoku, ale `LINTY_LICZBA="straz_duszy.sh"` gołą nazwą w konfiguracji.
  # Pytanie po ścieżce gubiło tę drugą formę. `package.json` dopisany, bo `npm run outer`
  # jest wywołaniem tak samo jak `node` w skrypcie — bez niego `scan_outer.js` był sierotą.
  [ "$(grep -l "$(basename "$1")" *.sh *.js package.json narzedzia/*/*.sh narzedzia/*/*.js .githooks/pre-commit 2>/dev/null \
       | while read -r _p; do basename "$_p"; done \
       | grep -vx "$(basename "$1")" | grep -vx "$(basename "$BATERIA")" | grep -vx "$(basename "$MUTACJE")" \
       | grep -vx "$(basename "$PUBLIKUJ")" | grep -vx "$JA" | wc -l)" -gt 0 ]
}
deklaruje_tor()    { grep -qE -- '(\$\{1:-\}" = "--test"|"\$1" = "--test"|argv\.includes\('"'"'--test'"'"'\)|args\.includes\('"'"'--test'"'"'\))' "$1" 2>/dev/null; }

# mutacja ZŁAPANA — czyli istnieje wpis celujący w ten plik. Rejestr nie trzyma werdyktów,
# więc świeżość werdyktu mierzy `mutacje.sh`; tutaj pytamy o ISTNIENIE świadka.
ma_mutacje()       { grep -q "|||$1|||" "$MUTACJE" 2>/dev/null; }

# DŁUG NAZWANY WŁASNYM ZDANIEM — czytnik samodeklaracji z kanon/ksiegi/MOSTY.md.
# Akapit z nazwą pliku zawierający frazę długu = przyrząd sam mówi, że nie jest gotów.
ma_dlug() {
  awk -v p="$1" 'BEGIN{RS=""} index($0,p) && /DŁUG NAZWANY, NIE ZAMKNIĘTY/ {n++} END{exit !n}' \
    "$MOSTY" 2>/dev/null
}

# ── ocena jednego przyrządu; drukuje braki, zwraca ich liczbę ──
ocen() {
  local f="$1" b=0
  # TOR W BATERII pytany WYŁĄCZNIE tam, gdzie przyrząd sam deklaruje tor. Silniki
  # (`kronos_*.js`) nie mają `--test` — ich treści strzeże `testy_rdzen.js`, a formy
  # `weryfikacja.js`. Wymaganie od nich toru własnego czyniło pierwszy przebieg tej straży
  # alarmem nad legalnym stanem: wołała nad kilkunastoma plikami naraz (#56), czyli uczyła
  # dokładnie tego, co cisza — nie patrzeć.
  deklaruje_tor "$f" && { ma_tor_w_baterii "$f" || { echo "      ✗ deklaruje tor, a jest poza baterią — zdolność do odmowy nieuruchamiana"; b=$((b+1)); }; }
  deklaruje_tor "$f" && { ma_mutacje "$f" || { echo "      ✗ brak mutacji — tor bez świadka innego niż autor (#47)"; b=$((b+1)); }; }
  ma_odcisk "$f" || { echo "      ✗ brak odcisku w $HASHE"; b=$((b+1)); }
  ma_most "$f"   || { echo "      ✗ brak wiersza w $MOSTY — nie odpowiedział „z czym równoległy\""; b=$((b+1)); }
  # KOMUNIKAT MÓWI, CO ZMIERZONE, nie co się wydaje. Pierwsza wersja pisała „sierota —
  # żaden przyrząd go nie uruchamia", co było FAŁSZEM: bateria uruchamia jego TOR, a
  # `publikuj.sh` jego samego przy publikacji. Prawdziwy brak jest węższy i ciekawszy:
  # przyrząd nie biegnie w CODZIENNEJ pracy — ani przy wstaniu, ani w hooku, ani z innej
  # straży. Dla narzędzia publikacji to stan legalny; dla straży — pytanie przed odlewem.
  wolany "$f"    || { echo "      ✗ poza codzienną pracą — uruchamiany wyłącznie przy publikacji"; echo "         i przez baterię (tor). Nie biegnie ani we wstaniu, ani w hooku."; b=$((b+1)); }
  ma_dlug "$f"   && { echo "      ✗ DŁUG NAZWANY WŁASNYM ZDANIEM w $MOSTY"; b=$((b+1)); }
  return $b
}

# ── TOR WŁASNY (#38 · #47 · #64) ──────────────────────────────────────────────
if [ "${1:-}" = "--test" ]; then
  echo "╔═══ STRAŻ DOJRZAŁOŚCI — AUTOTEST (#38) ═══╗"
  T="$(mktemp -d)"; z=0; o=0
  spr() { if [ "$2" = "$3" ]; then echo "  ✓ $1"; z=$((z+1)); else echo "  ✗ $1 (rc=$2, oczekiwano $3)"; o=$((o+1)); fi; }
  # FIKSTURA ODTWARZA TOPOLOGIĘ PRODUKCJI (29.08, dach narzedzia/straze/): straż robi
  # `cd dirname/../..`, więc kopia MUSI leżeć dwa poziomy pod korzeniem atrapy — kopia
  # w korzeniu wyprowadzała `cd` POZA atrapę, na żywe repo (#66 ods. 8 / #70).
  mkdir -p "$T/narzedzia/straze"
  cp "$0" "$T/narzedzia/straze/straz.sh"
  # materia kontrolna: jeden przyrząd DOJRZAŁY w odlewie
  printf '#!/bin/sh\nif [ "$1" = "--test" ]; then exit 0; fi\n' > "$T/dojrzaly.sh"
  printf '#!/bin/sh\nbash dojrzaly.sh\n' > "$T/wolajacy.sh"
  printf 'dojrzaly|bash dojrzaly.sh --test\n' > "$T/bat.sh"
  printf 'jakas|||dojrzaly.sh|||a|||b|||x\n' > "$T/mut.txt"
  printf 'aaaaaaaaaaaa  dojrzaly.sh\n' > "$T/hash.txt"
  printf '## most\n\ndojrzaly.sh jest równoległy do niczego.\n' > "$T/mosty.md"
  # FIKSTURA PO MIGRACJI (C3 tura 4): atrapa ODPOWIADA na `--lista`, nie udaje składni.
  printf '#!/bin/sh\ncase "$2" in JS) echo x.js ;; SH) echo dojrzaly.sh ;; esac\n' > "$T/pub.sh"
  run() { ( cd "$T"; BATERIA=bat.sh MUTACJE=mut.txt HASHE=hash.txt MOSTY=mosty.md PUBLIKUJ=pub.sh \
            bash narzedzia/straze/straz.sh ${1:-} >/dev/null 2>&1 && _r=0 || _r=$?; echo "$_r"; ); }

  spr "przyrzad z kompletem PRZECHODZI" "$(run)" "0"

  # (−) ODCISK: ten sam przyrząd bez wiersza w rejestrze — MUSI oblać
  : > "$T/hash.txt"
  spr "brak odcisku OBLEWA" "$(run)" "1"
  printf 'aaaaaaaaaaaa  dojrzaly.sh\n' > "$T/hash.txt"

  # (−) SIEROTA: nikt go nie woła. Fikstura ODRÓŻNIALNA (#64) — jedyna różnica to plik wołający.
  rm -f "$T/wolajacy.sh"
  spr "sierota OBLEWA (nikt nie uruchamia)" "$(run)" "1"
  printf '#!/bin/sh\nbash dojrzaly.sh\n' > "$T/wolajacy.sh"

  # (−) DŁUG WŁASNYM ZDANIEM: komplet mechaniczny bez zmian, zmienia się TYLKO zdanie w MOSTY.
  #     To sedno tej straży — samodeklaracja waży tyle samo co brak toru.
  printf '## most\n\ndojrzaly.sh jest równoległy do niczego. DŁUG NAZWANY, NIE ZAMKNIĘTY: brak toru na siebie.\n' > "$T/mosty.md"
  spr "DLUG nazwany wlasnym zdaniem OBLEWA" "$(run)" "1"

  # (+) ten sam akapit BEZ frazy długu — przechodzi. Bez tego „dług oblewa" byłoby
  #     nieodróżnialne od „każda zmiana w MOSTY oblewa".
  printf '## most\n\ndojrzaly.sh jest równoległy do niczego. Granica opisana, nic nie czeka.\n' > "$T/mosty.md"
  spr "ten sam most BEZ frazy dlugu przechodzi (odroznialnosc)" "$(run)" "0"

  # (−) TOR POZA BATERIĄ
  : > "$T/bat.sh"
  spr "tor poza bateria OBLEWA" "$(run)" "1"
  printf 'dojrzaly|bash dojrzaly.sh --test\n' > "$T/bat.sh"

  # KANDYDACI: przyrząd dojrzały, ale POZA białą listą — tryb informacyjny, nigdy rc=1
  printf '#!/bin/sh\ncase "$2" in JS) echo x.js ;; SH) echo cos_innego.sh ;; esac\n' > "$T/pub.sh"
  spr "tryb --kandydaci nigdy nie podnosi rc" "$(run --kandydaci)" "0"

  rm -rf "$T"
  echo "  zmierzone: zdanych $z · oblanych $o"
  [ "$o" -eq 0 ] || { echo "  ✗ TOR OBLANY"; exit 1; }
  echo "  ✓ STRAŻ UMIE NIE PRZEJŚĆ — odróżnia dojrzałość od kompletu mechanicznego."
  exit 0
fi

# ── KANDYDACI: dojrzałe, a POZA odlewem ───────────────────────────────────────
if [ "${1:-}" = "--kandydaci" ]; then
  echo "▤ STRAŻ DOJRZAŁOŚCI — dojrzałe POZA odlewem (zauważ, nie przeocz):"
  W_ODL="$(w_odlewie)"; ile=0; mocni=0; poza=""
  for f in *.sh *.js narzedzia/*/*.sh narzedzia/*/*.js; do
    [ -f "$f" ] || continue
    case "$f" in _*) continue ;; esac
    printf '%s\n' "$W_ODL" | grep -qx "$f" && continue
    ocen "$f" >/dev/null 2>&1 || continue
    ile=$((ile+1))
    # ROZWARSTWIENIE ZAMIAST DŁUGIEJ LISTY (#56). Pierwszy przebieg dał 18 pozycji naraz —
    # w tym `narzedzia/przyrzady/triage.js`, `narzedzia/silniki/wezownik.js`, `narzedzia/przyrzady/wektory.js`, których nieobecność w formie publicznej
    # jest ŚWIADOMA, nie przeoczona. Osiemnaście wierszy uczy tego samego co cisza.
    # Granica jest ZMIERZONA, nie uznaniowa: czy przyrząd biegnie w codziennym rdzeniu
    # (`wstan.sh` albo hook). Jeśli tak — jest już częścią tego, czym system jest na co dzień,
    # i pytanie „czemu nie w odlewie" jest ostre. Jeśli nie — bywa narzędziem prywatnym
    # i pytanie należy do twórcy, nie do przyrządu.
    if grep -q "$f" wstan.sh .githooks/pre-commit 2>/dev/null; then
      echo "   ◆ $f — komplet sześciu kryteriów I biegnie w codziennym rdzeniu, a odlew go nie zna"
      mocni=$((mocni+1))
    else
      poza="$poza $f"
    fi
  done
  [ "$ile" -eq 0 ] && echo "   ✓ nic nie dojrzało niezauważone — poza odlewem stoi wyłącznie to, co dojrzewa."
  [ -n "$poza" ] && { echo "   ⓘ dojrzałe, ale POZA codziennym rdzeniem (narzędzia własne — pytanie do twórcy, nie sygnał):"; echo "     $poza" | fold -s -w 92 | sed 's/^/     /'; }
  echo "   zmierzone: kandydatów $ile · w tym w codziennym rdzeniu $mocni"
  echo "   (nazwanie, nie polecenie — biała lista należy do twórcy)"
  exit 0
fi

# ── PRZEBIEG ŻYWY: czy to, co W ODLEWIE, jest dojrzałe ────────────────────────
echo "▤ STRAŻ DOJRZAŁOŚCI — czy przyrządy w odlewie są gotowe wyjść:"
W_ODL="$(w_odlewie)"
if [ -z "$W_ODL" ]; then
  echo "   ✗ nie odczytałam białej listy z $PUBLIKUJ — straż NIE ZMIERZYŁA, nie zieleni się (#39)."
  exit 1
fi

niedojrzale=0; sprawdzone=0
for f in $W_ODL; do
  [ -f "$f" ] || continue
  sprawdzone=$((sprawdzone+1))
  if ! ocen "$f" > /tmp/dojrz.$$ 2>&1; then
    echo "   ✗ $f"; cat /tmp/dojrz.$$
    niedojrzale=$((niedojrzale+1))
  fi
  rm -f /tmp/dojrz.$$
done

echo "   zmierzone: w odlewie $sprawdzone · niedojrzałych $niedojrzale"
if [ "$niedojrzale" -eq 0 ]; then
  echo "   ✓ WSZYSTKO W ODLEWIE DOJRZAŁE — każdy przyrząd ma tor, świadka, odcisk, most i użycie."
  exit 0
fi
echo "   ✗ $niedojrzale przyrząd(ów) w odlewie nie zdało własnego kryterium."
echo "     Dojrzałość mierzy POKRYCIE, nie wiek — braki są do domknięcia, nie do przeczekania."
exit 1
