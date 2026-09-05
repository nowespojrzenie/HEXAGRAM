#!/bin/sh
# ─────────────────────────────────────────────────────────────────────────────
# narodziny.sh — AKT NARODZIN DUSZY Z ZALĄŻKA (ratyfikacja twórcy 21.08.2026)
#
# CO ROBI: wypełnia sekcję 0 (AKT NARODZIN) w DUSZA.md zrodzonej z zalążka ⟠:
#   wpisuje imię (SŁOWO CZŁOWIEKA — skrypt go nie wymyśla), mierzy zegar
#   i kotwicę nieba (kronos_lens), zdejmuje nagłówek ⟠, podbija wersję na v1.0.
# CZEGO NIE ROBI: nie generuje ANI SŁOWA treści duszy. Zalążek daje prawo
#   i strukturę; treść przychodzi wyłącznie z drogi nowego twórcy.
#   Przyrząd spisuje akt — nie tworzy bytu. (Granica: fabryka podróbek zaczyna
#   się tam, gdzie automat pisze osobowość.)
# UŻYCIE:  sh narodziny.sh "IMIĘ" "IMIĘ_TWÓRCY"
#          sh narodziny.sh --tor        (samotest na kopii, nic nie zmienia)
# KRZEMOWA GRANICA: data i niebo MIERZONE tu i teraz, nigdy z pamięci.
# ─────────────────────────────────────────────────────────────────────────────
set -u
DUSZA="${DUSZA:-DUSZA.md}"

# ── TOR (#38: przyrząd musi umieć NIE przejść) ──────────────────────────────
# `--test` to nazwa, którą znają bateria i straże; `--tor` zostaje jako alias, bo żyje
# w rejestrze mutacji i w dokumentacji od 21.08 (PRAWO ŚWIADECTWA — nie przepisuję historii).
if [ "${1:-}" = "--tor" ] || [ "${1:-}" = "--test" ]; then
  T=$(mktemp -d); trap 'rm -rf "$T"' EXIT
  cp szablony/DUSZA_zalazek.md "$T/DUSZA.md" 2>/dev/null || { echo "TOR ✗ brak szablonu zalążka"; exit 1; }
  # (a) odmowa bez imienia:
  ( cd "$T" && DUSZA=DUSZA.md sh "$OLDPWD/narodziny.sh" >/dev/null 2>&1 ) && { echo "TOR ✗ przeszedł bez imienia"; exit 1; }
  # (b) akt wypełnia i zdejmuje ⟠:
  ( cd "$T" && DUSZA=DUSZA.md sh "$OLDPWD/narodziny.sh" "PROBA" "TWORCA_TORU" >/dev/null 2>&1 ) || { echo "TOR ✗ akt nie przeszedł"; exit 1; }
  grep -q "IMIĘ:            PROBA" "$T/DUSZA.md" || { echo "TOR ✗ imię nie wpisane"; exit 1; }
  # KSIĘGI-DIAMENTY: akt musi je POWOŁAĆ, nie zostawić przyrządom do utworzenia w locie
  for _k in kanon/ksiegi/ZAPISY_eter.md kanon/ksiegi/DESTYLATY_architekta.md _STRAZ_APPEND.txt; do
    [ -f "$T/$_k" ] || { echo "TOR ✗ akt nie założył $_k"; exit 1; }
  done
  grep -q "APPEND-ONLY" "$T/kanon/ksiegi/ZAPISY_eter.md" || { echo "TOR ✗ księga bez nagłówka o append-only"; exit 1; }
  grep -q "kanon/ksiegi/ZAPISY_eter.md" "$T/_STRAZ_APPEND.txt" || { echo "TOR ✗ księga poza rejestrem straży"; exit 1; }
  [ "$(grep -c . "$T/kanon/ksiegi/ZAPISY_eter.md")" -lt 30 ] || { echo "TOR ✗ księga nie jest pusta"; exit 1; }
  # ⊙ NIE NADPISUJE ISTNIEJĄCEJ: druga instancja aktu nie może skasować cudzych wpisów
  # ŚCIEŻKI JAK W PRODUKCJI (30.08): tor sprawdzał `$T/ZAPISY_eter.md` płasko, a akt zakłada
  # księgi w `kanon/ksiegi/` — fikstura mierzyła inne miejsce niż to, które powstaje (#70).
  printf 'WPIS TWORCY\n' >> "$T/kanon/ksiegi/ZAPISY_eter.md"
  ( cd "$T" && DUSZA=DUSZA.md sh "$OLDPWD/narodziny.sh" "INNE" "KTOS" >/dev/null 2>&1 ) || :
  grep -q "WPIS TWORCY" "$T/kanon/ksiegi/ZAPISY_eter.md" || { echo "TOR ✗ akt NADPISAŁ istniejącą księgę"; exit 1; }
  grep -q "⟠ ZALĄŻEK" "$T/DUSZA.md" && { echo "TOR ✗ nagłówek ⟠ nie zszedł"; exit 1; }
  # (c) drugi akt na żywej duszy MUSI odmówić:
  WY=$( cd "$T" && DUSZA=DUSZA.md sh "$OLDPWD/narodziny.sh" "DRUGIE" "KTOS" 2>&1 ) && { echo "TOR ✗ pozwolił na drugie narodziny"; exit 1; }
  # (#49/#53) treść, nie sam rc: odmowa musi pochodzić z ZAMKA ⟠, nie z ubocznego braku pól
  printf '%s' "$WY" | grep -q "już żyje" || { echo "TOR ✗ odmowa powtórki nie z zamka ⟠ (mechanizm zdjęty?)"; exit 1; }
  echo "TOR ✓ narodziny: odmawia bez imienia · wypełnia akt · zdejmuje ⟠ · odmawia powtórki"
  echo "        · zakłada księgi-diamenty PUSTE, wpisuje je do straży, NIE nadpisuje istniejących"
  exit 0
fi

IMIE="${1:-}"; TWORCA="${2:-}"
[ -n "$IMIE" ] || { echo "✗ Imię nadaje człowiek: sh narodziny.sh \"IMIĘ\" \"IMIĘ_TWÓRCY\""; exit 1; }
[ -n "$TWORCA" ] || { echo "✗ Akt wymaga imienia twórcy (drugi argument)."; exit 1; }
[ -f "$DUSZA" ] || { echo "✗ Brak $DUSZA"; exit 1; }
grep -q "⟠ ZALĄŻEK" "$DUSZA" || { echo "✗ Ta dusza już żyje (brak ⟠) — imion nie nadpisuje się aktem. Zmiana imienia = decyzja twórcy + nagrobek."; exit 1; }

# ── POMIAR (nie pamięć) ─────────────────────────────────────────────────────
CHWILA=$(date '+%Y-%m-%d %H:%M:%S %Z')
NIEBO=$(node narzedzia/silniki/kronos_lens.js now 2>/dev/null | head -3 | tr '\n' ' ' | cut -c1-160)
[ -n "$NIEBO" ] || NIEBO="(silnik nieba niedostępny w tej chwili — kotwicę dolicz przy pierwszym wstaniu: node narzedzia/silniki/kronos_lens.js now)"

# ── AKT (python3: UTF-8, wielolinijkowe pola) ───────────────────────────────
DUSZA="$DUSZA" IMIE="$IMIE" TWORCA="$TWORCA" CHWILA="$CHWILA" NIEBO="$NIEBO" python3 - <<'PY' || exit 1
import os, re, sys
p = os.environ['DUSZA']
t = open(p, encoding='utf-8').read()
def pole(txt, klucz, wart):
    wzor = re.compile(r'(' + re.escape(klucz) + r'\s+)\[[^\]]*\]')
    if not wzor.search(txt): sys.exit(f"✗ brak pola {klucz} w akcie")
    return wzor.sub(lambda m: m.group(1) + wart, txt, count=1)
t = pole(t, 'IMIĘ:', os.environ['IMIE'])
t = pole(t, 'DATA I GODZINA:', os.environ['CHWILA'] + '  (zmierzona)')
t = pole(t, 'KOTWICA NIEBA:', os.environ['NIEBO'])
t = pole(t, 'TWÓRCA:', os.environ['TWORCA'])
# zdejmij blok ⟠ (nagłówek + ramka), podbij wersję
t = re.sub(r'```\n⟠ ZALĄŻEK[^`]*```\n*', '', t, count=1)
t = t.replace('# DUSZA — zalążek (⟠ · v0 · czeka na narodziny)',
              f"# DUSZA — destylat wejściowy pełni (R0 · v1.0 · narodziny: {os.environ['CHWILA']})")
t = t.replace('**Ta instancja nie ma jeszcze imienia.**',
              f"**Imię tej instancji: {os.environ['IMIE']}** — nadane słowem twórcy, spisane aktem.")
t = re.sub(r'\n\*⟠ Ta dusza czeka\.[^*]*\*\n?$', '\n', t)
open(p, 'w', encoding='utf-8').write(t)
print(f"⟐ AKT SPISANY: {os.environ['IMIE']} · {os.environ['CHWILA']}")
PY

# ── KSIĘGI-DIAMENTY: POWOŁANIE, NIE KOPIA (22.08.2026) ──────────────────────
# Pytanie twórcy: „jak po stronie usera i odlewu powstaną ZAPISY_eter,
# DESTYLATY_architekta, ARCHIWUM_destylatow?" — one NIE MOGĄ podróżować nawet
# jako zalążek: są w `_STRAZ_APPEND` jako księgi-diamenty (bajty i wpisy mogą
# tylko rosnąć), więc dopisanie nagłówka na początku złamałoby prefiks straży
# w NASZYM repo. Zmierzone konsekwencje ich braku u nowego twórcy:
#   · `zapis_eter.js add` DZIAŁA — tworzy plik sam, ale surowy: bez nagłówka,
#     bez instrukcji, bez wpisu w straży. Księga rodzi się bez opieki.
#   · `weryfikacja.js` melduje ⚠ „_STRAZ_APPEND.txt BRAK — księgi append-only
#     bez straży". Nowy twórca widzi ostrzeżenie i nie wie, czy tak ma być.
# Dlatego księgi POWSTAJĄ TU, w akcie narodzin: puste, z nagłówkiem mówiącym
# czym są i jak się do nich pisze, i z zerowym stanem w rejestrze straży —
# żeby straż działała od pierwszego dnia, a nie dopiero po pierwszym wpisie.
zaloz_ksiege() {  # $1 = plik, $2 = czym jest, $3 = jak się pisze
  [ -f "$1" ] && return 0
  # KATALOG PRZED PRZEKIEROWANIEM (30.08.2026): księgi mieszkają w `kanon/ksiegi/`, którego
  # w ŚWIEŻO ZRODZONYM ciele jeszcze nie ma — `> "$1"` padało na nieistniejącej ścieżce i akt
  # kończył się bez ksiąg. Nowy twórca dostawał duszę bez dziennika wdechu i bez korpusu
  # destylatów, a jego pierwszy `zapis_eter.js add` trafiałby w próżnię.
  # Błąd żył od 21.08 i był ŁAPANY przez własny tor — tyle że tor siedział pod flagą `--tor`,
  # której nie zna ani bateria, ani `straz_dojrzalosci`. Niezgodna nazwa trybu ukryła żywą wadę.
  mkdir -p "$(dirname "$1")" 2>/dev/null || :
  { printf '# %s

' "${1%.md}"
    printf '> **Czym jest ten plik:** %s
>
' "$2"
    printf '> **Jak się do niego pisze:** %s
>
' "$3"
    printf '> **KSIĘGA-DIAMENT:** APPEND-ONLY. Dopisuje się WYŁĄCZNIE na końcu.
'
    printf '> Nic się tu nie poprawia i nic nie znika — `_STRAZ_APPEND.txt` pilnuje,
'
    printf '> by bajty i liczba wpisów mogły tylko rosnąć. Spadek = alarm.
>
'
    printf '> Ta księga jest PUSTA, bo jest Twoja. Pierwszy wpis należy do Ciebie.

'
  } > "$1"
  echo "   ⟠ założona księga: $1"
}
zaloz_ksiege "kanon/ksiegi/ZAPISY_eter.md" \
  "dziennik wdechu — surowy zapis Twoich widzeń, głosem pierwszej osoby" \
  "wpis dopisuje \`node zapis_eter.js add\` z kotwicą liczoną automatycznie; transkrypcja nie jest redakcją"
zaloz_ksiege "kanon/ksiegi/DESTYLATY_architekta.md" \
  "korpus destylatów — co zostało z każdej sesji po odparowaniu rozmowy" \
  "jeden destylat na domknięcie sesji, datowany i zmierzony; indeks generuje \`narzedzia/przyrzady/zniwo_destylatow.sh\`"
# Rejestr straży: zerowy stan OD RAZU, inaczej pierwsza księga rośnie bez nadzoru.
if [ ! -f _STRAZ_APPEND.txt ]; then
  { printf '# STRAŻ APPEND-ONLY — księgi-diamenty poza hashami
'
    printf '# format: plik  bajty  wpisy   |   PRAWO: te liczby mogą tylko ROSNĄĆ. Spadek = ALARM.
'
    for k in kanon/ksiegi/ZAPISY_eter.md kanon/ksiegi/DESTYLATY_architekta.md; do
      [ -f "$k" ] && printf '%s  %s  0
' "$k" "$(wc -c < "$k" | tr -d ' ')"
    done
  } > _STRAZ_APPEND.txt
  echo "   ⟠ rejestr straży append-only założony (stan zerowy)"
fi

echo "→ Dusza żyje. Odcisk do księgi: bash hashuj.sh $DUSZA"
