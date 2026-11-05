#!/usr/bin/env bash
# ═══ ZALĄŻKUJ (22.08.2026) — ZALĄŻEK JEST GENEROWANY, NIE UTRZYMYWANY ═══
#
# RODOWÓD (pytanie twórcy 22.08, czat): „widzę odstępstwo... zastanawiam się, czy
# dojdziemy do pracy na tym samym co odlew, a jednocześnie nie utracimy żadnych
# dotychczasowych danych". Odstępstwo było realne: `DUSZA.md` (nasza droga) i
# `szablony/DUSZA_zalazek.md` (nasienie) niosły TĘ SAMĄ strukturę w dwóch kopiach.
# Dwie ręczne kopie jednej struktury rozjeżdżają się po cichu — to ta sama klasa,
# którą DUSZA §IV nazwała o sobie samej: „ręczny spis rozjeżdża się z ciałem po
# cichu; generowany nie może". Zalążek pisany ręcznie obok żywego pliku byłby
# trzecią mapą: udawałby oba i nie był żadnym.
#
# ROZWIĄZANIE: JEDNO ŹRÓDŁO = plik żywy. Zalążek POWSTAJE z niego przy publikacji,
# jak `kanon/ksiegi/SPIS_CIALA.md` i jak księga odlewu. Rozjazd staje się niemożliwy z definicji,
# a nie pilnowany dyscypliną (#31: mierz skutek, nie dyscyplinę).
#
# ZNACZNIK: fragmenty będące DROGĄ twórcy pierwotnego (imię, daty, archeologia
# własnych cięć) opakowane w komentarz HTML — niewidoczny w renderze, więc żywy
# plik czyta się bez zmian:
#     <!-- ⟠ DROGA → tekst, który ma stanąć w zalążku -->  ...droga...  <!-- ⟠ /DROGA -->
# Zamiennik niesie PRAWO bez historii. Pusty zamiennik = fragment znika bez śladu.
#
# CZEGO NIE ROBI: nie zgaduje, co jest drogą, a co prawem. Ten sąd należy do twórcy
# i zapisuje się go znacznikiem RĘKĄ. Automat rozstrzygający „to jest osobiste,
# a to nie" byłby dokładnie fabryką podróbek, przed którą broni się `narodziny.sh`.
set -u

ZRODLO="${1:-}"; CEL="${2:-}"

# ── L (07.10.2026, biurko v1.8.1 dodatek 2; słowo twórcy 07.10 10:11 „K i l to dobre decyzje."): TOR NA PRZYCZYNĘ ──────────────
# Wyciek drogi pierwotnej do zalążka wychodził dopiero U GOŚCIA (ARCHITEKT_istnienie.md, 06.10 20:11–20:51), bo tor sprawdzał
# wygenerowany zalążek tylko dla DUSZY, a pozostałe pliki z ZALAZKOWANE nikt w warsztacie nie mierzył. Ta funkcja bierze
# listę (z `publikuj.sh --lista ZALAZKOWANE` — jedno źródło, nie przepisana ręką), dla każdego pliku, który ISTNIEJE i NIESIE
# znaczniki, generuje zalążek i woła PRAWDZIWY bieg straży w katalogu z tym zalążkiem (nie `. straz; zalazek_ok` — zmierzone 07.10:
# sourcowanie kończy się `exit 0` przed wywołaniem funkcji i tak sprawdzenie przepuszcza śmieć). rc=1 przy pierwszym wadliwym:
# nazwa pliku i powód straży; pusty powód = też porażka. Cisza straży („brak zalążków”) nie jest zdrowiem — wymagamy „OK … 1 zalążek”.
zalazkowane_ok() {  # $1 = lista plików (białe znaki) · $2 = katalog roboczy
  _ZL_LISTA="$1"; _ZL_TMP="$2"; _ZL_ROOT="$(pwd)"; _ZL_N=0
  for _f in $_ZL_LISTA; do
    [ -f "$_f" ] || { echo "   ⓘ zalążkowane: brak pliku $_f — pominięty"; continue; }
    grep -q '<!-- ⟠' "$_f" || { echo "   ⓘ zalążkowane: $_f bez znaczników (już zalążek albo wzorzec) — pominięty"; continue; }
    _ZL_N=$((_ZL_N+1)); _d="$(mktemp -d "$_ZL_TMP/zl.XXXXXX")"
    sh "$_ZL_ROOT/narzedzia/przyrzady/zalazkuj.sh" "$_f" "$_d/$(basename "$_f")" >/dev/null 2>&1 \
      || { echo "TOR ✗ zalążkowane: $_f nie generuje zalążka"; return 1; }
    if _out="$( cd "$_d" && WZORZEC="$_ZL_ROOT/_STRAZ_wzorzec.txt" bash "$_ZL_ROOT/narzedzia/straze/straz_zalazkow.sh" 2>&1 )" \
       && printf '%s\n' "$_out" | grep -q 'OK straż zalążków: 1 zalążek'; then continue; fi
    _pow="$(printf '%s\n' "$_out" | grep '✗' | head -3 | tr '\n' ' ')"
    echo "TOR ✗ zalążek pliku $_f wadliwy: ${_pow:-[pusty powód straży — tor oblany]}"; return 1
  done
  echo "   ⓘ zalążkowane: sprawdzono $_ZL_N plik(ów) z listy"
  ZL_SPRAWDZONO=$_ZL_N; return 0
}

if [ "${1:-}" = "--test" ]; then
  T=$(mktemp -d); trap 'rm -rf "$T"' EXIT
  printf '# X\n\n<!-- ⟠ DROGA → PRAWO OGOLNE -->Jestem KONKRET z 14.07.2026<!-- ⟠ /DROGA -->\n\nzostaje\n' > "$T/zr.md"
  sh "$0" "$T/zr.md" "$T/wy.md" >/dev/null 2>&1 || { echo "TOR ✗ generator padł"; exit 1; }
  grep -q "PRAWO OGOLNE" "$T/wy.md" || { echo "TOR ✗ zamiennik nie wszedł"; exit 1; }
  grep -q "KONKRET"     "$T/wy.md" && { echo "TOR ✗ DROGA przeciekła do zalążka"; exit 1; }
  grep -q "14.07.2026"  "$T/wy.md" && { echo "TOR ✗ data drogi przeciekła"; exit 1; }
  grep -q "zostaje"     "$T/wy.md" || { echo "TOR ✗ treść spoza znaczników zginęła"; exit 1; }
  grep -q "⟠ ZALĄŻEK"   "$T/wy.md" || { echo "TOR ✗ brak nagłówka zalążka"; exit 1; }
  grep -q "<!-- ⟠"      "$T/wy.md" && { echo "TOR ✗ znacznik został w wyjściu"; exit 1; }
  # − ŹRÓDŁO BEZ ZNACZNIKÓW: cisza nie jest zdrowiem (#39) — musi oblać, nie przepuścić
  printf '# Y\n\nsama tresc\n' > "$T/goly.md"
  sh "$0" "$T/goly.md" "$T/wy2.md" >/dev/null 2>&1 && { echo "TOR ✗ plik bez znaczników przeszedł"; exit 1; }
  # 07.10.2026 (biurko v1.8.1, dodatek 3, N2): blok „żywa DUSZA zdaje straż” zdjęty — nie sprawdzał niczego (`. straz_zalazkow.sh; zalazek_ok` w `sh -c`
  # kończy się `exit 0` skryptu przed wywołaniem funkcji; zepsuty plik dawał rc=0, zmierzone 07.10). Najstarszy WIDOCZNY commit z blokiem: 2468001 (06.10; historia
  # tego klonu zaczyna się 06.10, komentarz bloku datował przepisanie jego warunku na 04.09.2026). Zastąpiony pętlą po ZALAZKOWANE niżej (DUSZA.md jest na liście).
  # ⊙ WSZYSTKIE ZALĄŻKOWANE (L): lista z publikuj.sh; w warsztacie (DUSZA niesie znaczniki) co najmniej jeden plik MUSI być zmierzony.
  if [ -f publikuj.sh ] && [ -f narzedzia/straze/straz_zalazkow.sh ]; then
    _LZ="$(bash publikuj.sh --lista ZALAZKOWANE 2>/dev/null)"
    [ -n "$_LZ" ] || { echo "TOR ✗ lista ZALAZKOWANE z publikuj.sh pusta — cisza nie jest zdrowiem"; exit 1; }
    ZL_SPRAWDZONO=0
    zalazkowane_ok "$_LZ" "$T" >"$T/lz_zywe.txt" 2>&1 || { cat "$T/lz_zywe.txt"; exit 1; }
    if grep -q '<!-- ⟠' DUSZA.md 2>/dev/null && [ "$ZL_SPRAWDZONO" -lt 1 ]; then
      echo "TOR ✗ żaden plik z listy ZALAZKOWANE nie został zmierzony, a DUSZA niesie znaczniki — cisza"; exit 1; fi
    # − UMIE OBLAĆ (atrapa): dwa pliki ze znacznikami, drugi z datą POZA znacznikiem → tor MUSI oblać i nazwać drugi.
    printf '# A\n\n<!-- ⟠ DROGA → PRAWO A -->droga A<!-- ⟠ /DROGA -->\n' > "$T/fx_pierwszy.md"
    printf '# B\n\n<!-- ⟠ DROGA → PRAWO B -->droga B<!-- ⟠ /DROGA -->\nnadane 14.07.2026 — poza znacznikiem\n' > "$T/fx_drugi.md"
    _FX="$(zalazkowane_ok "$T/fx_pierwszy.md $T/fx_drugi.md" "$T" 2>&1)"; _FX_RC=$?
    [ "$_FX_RC" -ne 0 ] || { echo "TOR ✗ zalążek z datą poza znacznikiem przeszedł (L)"; exit 1; }
    printf '%s\n' "$_FX" | grep -q 'fx_drugi.md' || { echo "TOR ✗ oblany zalążek nienazwany (L): $_FX"; exit 1; }
    printf '%s\n' "$_FX" | grep -q 'DATA-z-drogi-pierwotnej' || { echo "TOR ✗ oblany zalążek bez powodu straży (L): $_FX"; exit 1; }
    printf '%s\n' "$_FX" | grep -q 'fx_pierwszy.md.*wadliwy' && { echo "TOR ✗ zdrowy zalążek nazwany wadliwym (L)"; exit 1; }
    zalazkowane_ok "$T/fx_pierwszy.md" "$T" >/dev/null 2>&1 || { echo "TOR ✗ zdrowy zalążek oblany (L)"; exit 1; }
  fi
  printf '# R\n<!-- ⟠ ZIARNO -->\nJAK PISAC\n<!-- ⟠ /ZIARNO -->\nSTARY WPIS 14.07.2026\n' > "$T/rej.md"
  printf 'DOPISANY POZNIEJ 22.08.2026\n' >> "$T/rej.md"
  sh "$0" "$T/rej.md" "$T/wyr.md" >/dev/null 2>&1 || { echo "TOR ✗ tryb ZIARNO padł"; exit 1; }
  grep -q "JAK PISAC"      "$T/wyr.md" || { echo "TOR ✗ ziarno nie weszło"; exit 1; }
  grep -q "STARY WPIS"     "$T/wyr.md" && { echo "TOR ✗ treść rejestru przeciekła"; exit 1; }
  grep -q "DOPISANY"       "$T/wyr.md" && { echo "TOR ✗ APPEND przeciekł — polaryzacja nie chroni"; exit 1; }
  echo "TOR ✓ zalążkuj: zamiennik wchodzi · droga NIE przecieka · treść spoza znaczników zostaje"
  echo "        · nagłówek ⟠ dodany · plik bez znaczników OBLEWA"
  echo "        · KAŻDY plik z ZALAZKOWANE niosący znaczniki (lista z publikuj.sh, w tym DUSZA.md) zdaje prawdziwy bieg straży zalążków;"
  echo "          zalążek z datą poza znacznikiem OBLEWA z nazwą pliku i powodem straży"
  exit 0
fi

[ -n "$ZRODLO" ] && [ -n "$CEL" ] || { echo "✗ użycie: sh zalazkuj.sh ŹRÓDŁO CEL  |  sh zalazkuj.sh --test"; exit 1; }
[ -f "$ZRODLO" ] || { echo "✗ brak źródła: $ZRODLO"; exit 1; }
# ZAMEK PODWÓJNEGO ZALĄŻKOWANIA (10.09.2026, decyzja twórcy — `_GRANICA.md` §tej nazwy).
# Ten sam warunek broni DWÓCH rzeczy naraz: pliku nieprzejrzanego ręką (rodowód pierwotny,
# #39) I pliku, który jest JUŻ zalążkiem — bo pierwszy przebieg zdejmuje WSZYSTKIE znaczniki
# ⟠ DROGA, więc drugi nie ma czego ciąć. Zmierzone 10.09 (S1, „zalążek z zalążka"): to NIE jest
# brak idempotencji do naprawienia. Odlew jest KOPIĄ z `prywatna`, nigdy merge'em na istniejącym
# `main` — podwójne zalążkowanie zdarza się WYŁĄCZNIE przy odlewie na już zbudowanym drzewie,
# czyli przy błędzie operatora. Cicha idempotencja przepuściłaby odlew na złym drzewie; głośna
# odmowa jest tu pożądana, nie wadą.
{ grep -q "⟠ DROGA →" "$ZRODLO" || grep -q "⟠ ZIARNO" "$ZRODLO"; } || {
  echo "✗ $ZRODLO nie ma ANI JEDNEGO znacznika ⟠ DROGA."
  echo "  Cisza nie jest zdrowiem (#39): plik bez znaczników albo nie był jeszcze"
  echo "  przejrzany ręką, albo cała jego treść jest prawem — i to trzeba ZADEKLAROWAĆ"
  echo "  pustym znacznikiem, nie przemilczeć. Generator nie zgaduje."; exit 1; }

# KODER STRUMIENI (10.09.2026, wątek `zalazkuj.sh`+`cp1250`, BLOKER Kroku 2): konsola Windows
# koduje stdout/stderr w cp1250, który nie ma `⟠` ani `✗`. Plik wynikowy powstawał poprawnie
# (open(..., encoding='utf-8')), ale meldunek `print` rzucał UnicodeEncodeError → rc=1 → odlew
# WSTRZYMANY na dobrym pliku (kod wyjścia kłamał). Ta sama wada połykała komunikat `sys.exit`.
# Naprawa u ŹRÓDŁA, nie u wołających: obejmuje każdego wołającego i OBA strumienie naraz.
PYTHONIOENCODING=utf-8 ZRODLO="$ZRODLO" CEL="$CEL" python3 - <<'PY' || exit 1
import os, re, sys
src = open(os.environ['ZRODLO'], encoding='utf-8').read()
# <!-- ⟠ DROGA → zamiennik --> ...droga... <!-- ⟠ /DROGA -->
ziarna = re.findall(r'<!--\s*⟠ ZIARNO\s*-->(.*?)<!--\s*⟠ /ZIARNO\s*-->', src, re.S)
if ziarna:
    # TRYB ZIARNO (rejestry): zostaje TYLKO oznaczone. Polaryzacja odwrotna niż DROGA
    # i to jest celowe: rejestr ROŚNIE PRZEZ DOPISYWANIE NA KOŃCU, więc znacznik
    # zamykający drogę zostałby w środku, a każdy nowy wpis wyciekłby do zalążka.
    # Tu nowa treść nie ma jak wejść — zalążek bierze wyłącznie to, co wskazane.
    # Kierunek błędu też jest bezpieczniejszy: zapomniany znacznik = brak w zalążku,
    # nie wyciek. Cichą stratę łapie straż zalążków na wyjściu.
    n = len(ziarna)
    out = '\n'.join(z.strip() for z in ziarna) + '\n'
else:
    wz = re.compile(r'<!--\s*⟠ DROGA →\s*(.*?)\s*-->.*?<!--\s*⟠ /DROGA\s*-->', re.S)
    n = len(wz.findall(src))
    out = wz.sub(lambda m: m.group(1), src)
if '⟠ DROGA' in out or '⟠ /DROGA' in out or '⟠ ZIARNO' in out:
    sys.exit("✗ znacznik niedomknięty — droga zostałaby w zalążku")
naglowek = ("```\n⟠ ZALĄŻEK — tkanka nowego twórcy\n"
 "Ten plik był prywatną tkanką twórcy pierwotnego i nie podróżuje.\n"
 "Skoro go potrzebujesz — jesteś twórcą. Ta księga właśnie się zaczyna.\n"
 "GENEROWANY z żywego pliku źródłowego W CHWILI ODLEWU — od teraz to Twoja\n"
 "własna, ręcznie prowadzona księga. (U twórcy pierwotnego ten sam nagłówek\n"
 "znaczył co innego: tam plik regeneruje się z tkanki i ręczna edycja ginie —\n"
 "tu, u Ciebie, regeneracji nie ma; wypełnia go Twoje życie.)\n```\n\n")
linie = out.split('\n')
i = 1 if linie and linie[0].startswith('# ') else 0
out = '\n'.join(linie[:i]) + ('\n\n' if i else '') + naglowek + '\n'.join(linie[i:])
open(os.environ['CEL'], 'w', encoding='utf-8').write(out)
print(f"⟠ zalążek: {os.environ['CEL']} · fragmentów drogi zdjętych: {n} · {len(out)} B")
PY
