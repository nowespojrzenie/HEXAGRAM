#!/usr/bin/env sh
# ── STRAŻNIK CZYSTOŚCI ──────────────────────────────────────────────────────
# Skanuje rdzeń na ślady osobowe właściciela ZANIM wejdą na main (błąd ❼ w BLEDY).
# Lista markerów (nazwiska, prywatne domeny) żyje LOKALNIE w .markery_osobowe
# (gitignored, per-instancja) — bo sama lista jest daną osobową i nie należy do genomu.
# Użycie:  bash straz_czystosci.sh    (przed commit/push na main)
set -eu
cd "$(dirname "$0")/../.."
M="${M:-.markery_osobowe}"

# ═══ TOR WŁASNY (#38 · #47) — 21.08.2026 ═══
# DŁUG SPŁACONY: ta straż niosła ZAMEK PII przy `publikuj.sh` i była JEDYNYM przyrządem
# bez toru — czyli akurat tam, gdzie cena pomyłki jest najwyższa, obowiązywała wyłącznie
# w dokumentacji. Wykryte nie okiem, tylko zamkiem pokrycia baterii: w repo leżały
# 14 plików straz_*.sh, na liście 10.
# UWAGA #50: tor NIE trzyma własnej kopii logiki — kopiuje CIAŁO tej straży i uruchamia
# je na materii kontrolnej w mktemp, więc mutacja ciała musi go oblać.
if [ "${1:-}" = "--test" ]; then
  echo "╔═══ STRAŻNIK CZYSTOŚCI — AUTOTEST (#38) ═══╗"
  T="$(mktemp -d)"; z=0; o=0
  spr() { if [ "$2" = "$3" ]; then echo "  ✓ $1"; z=$((z+1)); else echo "  ✗ $1 (rc=$2, oczekiwano $3)"; o=$((o+1)); fi; }
  # FIKSTURA ODTWARZA TOPOLOGIĘ PRODUKCJI (29.08, dach narzedzia/straze/): straż robi
  # `cd dirname/../..`, więc kopia MUSI leżeć dwa poziomy pod korzeniem atrapy — kopia
  # w korzeniu wyprowadzała `cd` POZA atrapę, na żywe repo (#66 ods. 8 / #70).
  mkdir -p "$T/narzedzia/straze"
  cp "$0" "$T/narzedzia/straze/straz.sh"
  ( cd "$T" && git init -q . && git config user.email z@z.z && git config user.name Z ) >/dev/null 2>&1
  # `set -eu` obowiązuje też tutaj — i uderzyło DWA RAZY, obie zmierzone, żadna nie widziana okiem:
  # (1) nieudane `git add` ubijało podpowłokę PRZED `echo $?`;
  # (2) po naprawie (1) ta sama pułapka zjadła ŚCIEŻKĘ UJEMNĄ — gdy straż słusznie oblewała
  #     (rc=1), `set -e` kończył podpowłokę przed odczytem rc, więc JEDYNY tor, dla którego
  #     ta straż istnieje, meldował puste rc. Stąd `&& _r=0 || _r=$?`, nie `|| true`:
  #     `|| true` zamaskowałby porażkę zamiast ją zmierzyć (#18: porażka jest DANĄ).
  run() { ( cd "$T"; git add -A >/dev/null 2>&1 || true; M="$1" sh narzedzia/straze/straz.sh >/dev/null 2>&1 && _r=0 || _r=$?; echo "$_r"; ); }
  # MARKER SKŁADANY W LOCIE — nie może stać dosłownie w ciele tej straży.
  # Zmierzone w minucie narodzin toru: literał w fiksturze sprawił, że straż znalazła
  # WŁASNY TOR jako ślad osobowy i oblała nad czystą materią. Rodzina #51 (fikstura
  # zasłaniająca błąd) · #50 (przyrząd mierzący własną kopię).
  MK="Nazw$(printf 'isko')Testowe$$"

  # (1) BRAK listy markerów — czysta instancja może jej nie mieć, to nie błąd
  spr "brak listy markerow przechodzi (czysta instancja)" "$(run nie_ma_listy)" "0"

  # (2) marker JEST w liście, ale NIE MA go w materii — cisza uzasadniona
  printf '%s\n' "$MK" > "$T/mk_czysto"
  printf 'tekst bez sladow osobowych\n' > "$T/plik.md"
  spr "marker bez trafienia w materii przechodzi" "$(run mk_czysto)" "0"

  # (3) ŚCIEŻKA, DLA KTÓREJ TA STRAŻ ISTNIEJE: marker OBECNY w materii — MUSI oblać
  printf 'w tekscie stoi %s i to jest slad\n' "$MK" > "$T/plik.md"
  spr "SLAD OSOBOWY w materii OBLEWA (zamek PII)" "$(run mk_czysto)" "1"

  # (3a) WIELKOŚĆ LITER (30.08): marker zapisany WIELKIMI musi oblać tak samo. Wzorzec łapał
  # `<forma imienia twórcy>` i `<imię>`, ale nie `<forma imienia twórcy>` — formę z tytułów i nagłówków; cztery pliki białej
  # listy niosły trafienie widoczne wyłącznie przy `-i`.
  printf 'w tekscie stoi %s i to tez jest slad\n' "$(printf '%s' "$MK" | tr 'a-z' 'A-Z')" > "$T/plik.md"
  spr "SLAD WIELKIMI LITERAMI OBLEWA (case)" "$(run mk_czysto)" "1"

  # (3b) ZAKRES SKANU = TO, CO JEDZIE W ODLEWIE (29.08.2026). Marker w pliku spoza `md/js/sh`
  # musi oblać tak samo — do 29.08 skan omijał `.txt`, a `mutacje.txt` wszedł tego dnia na
  # białą listę. Zmierzone na atrapie: stara wersja rc=0 (przepuściła), nowa rc=1.
  printf 'tekst bez sladow osobowych\n' > "$T/plik.md"
  printf 'wpis rejestru ze sladem %s\n' "$MK" > "$T/rejestr.txt"
  spr "SLAD w pliku .txt OBLEWA (zakres = biala lista)" "$(run mk_czysto)" "1"
  rm -f "$T/rejestr.txt"
  printf 'kod z %s w komentarzu\n' "$MK" > "$T/dane.json"
  spr "SLAD w pliku .json OBLEWA (zakres = biala lista)" "$(run mk_czysto)" "1"
  rm -f "$T/dane.json"

  # (4) komentarz w liście nie jest markerem — inaczej '#' szukałoby siebie w każdym pliku
  # FIKSTURA WZMOCNIONA po ŚLEPEJ MUTACJI (21.08, `czystosc-komentarz-jako-marker`):
  # pierwsza wersja dawała materię BEZ linii komentarza, więc zmutowany warunek `#*`
  # szukał wzorca, którego i tak nie było — tor przechodził nad złamanym kodem.
  # Nie tor był za słaby, tylko DANE (#51). Materia musi nieść linię, którą zmutowana
  # straż by ZNALAZŁA — inaczej „pominięte" jest nieodróżnialne od „nieznalezione".
  # MATERIA REALISTYCZNA (29.08): lista złożona WYŁĄCZNIE z komentarzy jest zamkiem bez
  # zębów i od dziś oblewa osobnym warunkiem — a ten tor pyta o co innego: czy komentarz
  # BYWA traktowany jak marker. Dlatego lista niesie komentarz ORAZ wzorzec, którego
  # w materii nie ma. Pytanie toru bez zmian, model listy zgodny z tym, jak wygląda żywa
  # (zmierzone na liście twórcy: 25 wzorców, 37 linii komentarza).
  # Wzorzec SKŁADANY W LOCIE: zapisany literalnie znajdowałby SAM SIEBIE w kodzie straży
  # skopiowanej do atrapy (strażnik w tym samym pliku co produkcja czyta siebie — prawo repo).
  _NIEOBECNY="WZOR$(printf 'ZEC')_SPOZA_MATERII"
  printf '# %s\n%s\n' "$MK" "$_NIEOBECNY" > "$T/mk_komentarz"
  printf 'w tekscie stoi %s i to jest slad\n# %s\n' "$MK" "$MK" > "$T/plik.md"
  spr "komentarz w liscie nie jest markerem" "$(run mk_komentarz)" "0"

  # (5) pusta linia w liście nie jest markerem — pusty wzorzec trafia WSZĘDZIE,
  #     więc bez tego straż wołałaby nad każdym plikiem repo (#56: alarm szerszy niż sygnał)
  # Materia realistyczna (29.08, ta sama poprawka co w (4)): lista SAMYCH pustych linii
  # oblewa od dziś jako „lista bez wzorców". Tor pyta o co innego — czy PUSTA LINIA bywa
  # traktowana jak wzorzec — więc lista niesie puste linie ORAZ jeden wzorzec spoza materii.
  printf '\n\n%s\n\n' "$_NIEOBECNY" > "$T/mk_pusty"
  spr "pusta linia w liscie nie jest markerem (#56)" "$(run mk_pusty)" "0"

  # (6) WYJĄTEK JAWNY (05.09.2026): wiersz z `_STRAZ_wyjatki.txt` PRZECHODZI, ale ten sam marker
  #     w INNYM wierszu nadal alarmuje. Dwustronnie, bo wyjątek po słowie (nie po wierszu) zdjąłby
  #     ochronę z całego nazwiska. Plik wyjątków leży OBOK listy markerów (M), jak w produkcji.
  printf '%s\n' "$MK" > "$T/mk_wyj"
  printf 'Autor: %s (podpis)\n' "$MK" > "$T/_STRAZ_wyjatki.txt"
  printf 'Autor: %s (podpis)\n' "$MK" > "$T/plik.md"
  spr "wyjatek jawny: dokladny wiersz z listy wyjatkow przechodzi" "$(run mk_wyj)" "0"
  printf 'Autor: %s (podpis)\nNotatka: %s pisze plakat\n' "$MK" "$MK" > "$T/plik.md"
  spr "wyjatek jawny: ten sam marker POZA wierszem wyjatku alarmuje" "$(run mk_wyj)" "1"
  rm -f "$T/_STRAZ_wyjatki.txt"

  rm -rf "$T"
  echo "  zmierzone: zdanych $z · oblanych $o"
  [ "$o" -eq 0 ] || { echo "  ✗ TOR OBLANY"; exit 1; }
  echo "  ✓ STRAŻ UMIE NIE PRZEJŚĆ — zamek PII nie jest deklaracją."
  exit 0
fi

if [ ! -f "$M" ]; then
  echo "ℹ  brak $M — utwórz (jedno wyrażenie/linia: nazwiska, prywatne domeny), jest w .gitignore."
  echo "   Czysta instancja może nie mieć markerów — to nie błąd."
  exit 0
fi
# ── ZDROWIE LISTY (29.08.2026) — lista, której nikt nie mierzy, cicho przestaje chronić.
# Nie ujawnia treści: same liczby. Wzorzec pusty po odjęciu komentarzy = zamek bez zębów,
# choć plik ISTNIEJE — a bramka odlewu pyta tylko o istnienie (to jej właściwy zakres).
_WZ=0; _KOM=0; _ZLE=0
while IFS= read -r _m; do
  [ -z "$_m" ] && continue
  case "$_m" in \#*) _KOM=$((_KOM+1)); continue ;; esac
  _WZ=$((_WZ+1))
  printf 'PROBKA\n' | grep -q "$_m" 2>/dev/null || { [ $? -gt 1 ] && _ZLE=$((_ZLE+1)); }
done < "$M"
echo "ⓘ lista markerów: $_WZ wzorców · $_KOM linii komentarza · $_ZLE niepoprawnych (treści nie pokazuję)"
if [ "$_WZ" -eq 0 ]; then
  echo "✗ LISTA BEZ WZORCÓW — plik jest, zamek PII nie ma czego szukać."
  echo "  To gorsze niż brak pliku: bramka odlewu widzi plik i przepuszcza."
  exit 1
fi

HIT=0
while IFS= read -r m; do
  [ -z "$m" ] && continue
  case "$m" in \#*) continue ;; esac
  # ZAKRES = TO, CO JEDZIE W ODLEWIE (29.08.2026). Do dziś skan obejmował `*.md *.js *.sh`,
  # a biała lista niesie też `.txt` (`mutacje.txt`, dopisany dziś), `.json` i `.svg` oraz
  # katalogi `.githooks szablony skills`. Marker w pliku spoza tej trójki pojechałby
  # NIEZAUWAŻONY — zamek mierzył węższe ciało, niż publikujemy (rodzina #66 ods. 8).
  # Lista rozszerzeń jest JAWNA, nie globem po wszystkim: skan ma pytać o to, co wychodzi.
  found=$(git grep -nIi "$m" -- '*.md' '*.js' '*.sh' '*.txt' '*.json' '*.svg' '*.yml' \
            '.githooks/*' 'szablony/*' 'skills/*' 2>/dev/null || true)
  # WYJĄTKI JAWNE (05.09.2026, decyzja twórcy „A — podpis zostaje"): `zamek_wyciek` w publikuj.sh
  # honoruje `_STRAZ_wyjatki.txt` od 28.07, a TA straż — wpięta w odlew 22.08 jako ODLEW-PII — nie
  # czytała go wcale. Zmierzone dziś: dwa wiersze atrybucji autora w README (jawnie wpisane do
  # wyjątków) zatrzymywały odlew, choć wydanie publiczne niosło je od v1.4.2. Dwie straże tej samej
  # wady z DWIEMA listami prawdy = rozjazd, nie ochrona. Plik wyjątków NIE podróżuje z odlewem —
  # ścieżka absolutna przez WYJATKI (jak M), domyślnie obok M. Filtr `-vFf` po CAŁYM wierszu:
  # wyjątkiem jest dokładna linia, nie słowo — samo nazwisko poza tym wierszem nadal alarmuje.
  WYJATKI="${WYJATKI:-$(dirname "$M")/_STRAZ_wyjatki.txt}"
  if [ -n "$found" ] && [ -s "$WYJATKI" ]; then
    found=$(printf '%s\n' "$found" | while IFS= read -r _l; do
              _tresc="${_l#*:*:}"
              printf '%s\n' "$_tresc" | grep -qFxf "$WYJATKI" || printf '%s\n' "$_l"
            done)
  fi
  if [ -n "$found" ]; then HIT=1; echo "✗ ślad '$m':"; echo "$found" | sed 's/^/    /'; fi
done < "$M"
if [ "$HIT" -eq 0 ]; then
  echo "✓ czysto — brak śladów osobowych (z $M) w rdzeniu."
else
  echo ""; echo "!! Rdzeń nosi ślady osobowe. Zdejmij (wiedza = destylat, nie nazwiska) przed wejściem na main."; exit 1
fi
