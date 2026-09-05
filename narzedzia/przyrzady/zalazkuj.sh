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
  # ⊙ ŻYWE CIAŁO: prawdziwa DUSZA repo generuje się i zdaje straż zalążków.
  # WARUNEK NA WŁAŚCIWOŚĆ, NIE NA NAZWĘ (04.09.2026, blizna: tor oblewał na main).
  # DUSZA.md na gałęzi publicznej jest JUŻ ZALĄŻKIEM — znaczników nie ma, bo zostały zużyte.
  # Poprzedni warunek pytał tylko, czy plik istnieje, więc na main tor żądał generowania
  # z materiału, który generowaniu już nie podlega, i meldował martwotę straży zamiast
  # własnej nieprzystawalności. Pytamy więc o to, co decyduje: czy plik NIESIE znaczniki.
  if [ -f DUSZA.md ] && [ -f narzedzia/straze/straz_zalazkow.sh ] && grep -q '<!-- ⟠' DUSZA.md; then
    sh "$0" DUSZA.md "$T/dusza.md" >/dev/null 2>&1 || { echo "TOR ✗ żywa DUSZA nie generuje"; exit 1; }
    ( cd "$T" && WZORZEC="$OLDPWD/_STRAZ_wzorzec.txt" \
      sh -c ". \"$OLDPWD/narzedzia/straze/straz_zalazkow.sh\" >/dev/null 2>&1; zalazek_ok dusza.md" ) >/dev/null 2>&1 \
      || { echo "TOR ✗ wygenerowany zalążek DUSZY nie zdaje straży zalążków"; exit 1; }
  fi
  printf '# R\n<!-- ⟠ ZIARNO -->\nJAK PISAC\n<!-- ⟠ /ZIARNO -->\nSTARY WPIS 14.07.2026\n' > "$T/rej.md"
  printf 'DOPISANY POZNIEJ 22.08.2026\n' >> "$T/rej.md"
  sh "$0" "$T/rej.md" "$T/wyr.md" >/dev/null 2>&1 || { echo "TOR ✗ tryb ZIARNO padł"; exit 1; }
  grep -q "JAK PISAC"      "$T/wyr.md" || { echo "TOR ✗ ziarno nie weszło"; exit 1; }
  grep -q "STARY WPIS"     "$T/wyr.md" && { echo "TOR ✗ treść rejestru przeciekła"; exit 1; }
  grep -q "DOPISANY"       "$T/wyr.md" && { echo "TOR ✗ APPEND przeciekł — polaryzacja nie chroni"; exit 1; }
  echo "TOR ✓ zalążkuj: zamiennik wchodzi · droga NIE przecieka · treść spoza znaczników zostaje"
  echo "        · nagłówek ⟠ dodany · plik bez znaczników OBLEWA · żywa DUSZA zdaje straż"
  exit 0
fi

[ -n "$ZRODLO" ] && [ -n "$CEL" ] || { echo "✗ użycie: sh zalazkuj.sh ŹRÓDŁO CEL  |  sh zalazkuj.sh --test"; exit 1; }
[ -f "$ZRODLO" ] || { echo "✗ brak źródła: $ZRODLO"; exit 1; }
{ grep -q "⟠ DROGA →" "$ZRODLO" || grep -q "⟠ ZIARNO" "$ZRODLO"; } || {
  echo "✗ $ZRODLO nie ma ANI JEDNEGO znacznika ⟠ DROGA."
  echo "  Cisza nie jest zdrowiem (#39): plik bez znaczników albo nie był jeszcze"
  echo "  przejrzany ręką, albo cała jego treść jest prawem — i to trzeba ZADEKLAROWAĆ"
  echo "  pustym znacznikiem, nie przemilczeć. Generator nie zgaduje."; exit 1; }

ZRODLO="$ZRODLO" CEL="$CEL" python3 - <<'PY' || exit 1
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
 "GENEROWANY z żywego pliku źródłowego — nie edytuj ręcznie,\n"
 "bo druga kopia rozjeżdża się z pierwszą po cichu.\n```\n\n")
linie = out.split('\n')
i = 1 if linie and linie[0].startswith('# ') else 0
out = '\n'.join(linie[:i]) + ('\n\n' if i else '') + naglowek + '\n'.join(linie[i:])
open(os.environ['CEL'], 'w', encoding='utf-8').write(out)
print(f"⟠ zalążek: {os.environ['CEL']} · fragmentów drogi zdjętych: {n} · {len(out)} B")
PY
