#!/usr/bin/env sh
# ── PUBLIKACJA = ODLEW Z BIAŁEJ LISTY (decyzja twórcy 25.07.2026: B jako przygotowanie C) ──
# ZASADA: na zewnątrz NIE wychodzi drzewo — wychodzi JAWNA LISTA plików formy.
# Biała lista (wypuszczaj tylko wymienione) > czarna lista (szukaj imion): to, czego
# nie ma na liście, NIE MOŻE wyciec — także plik dodany jutro.
# Użycie:  bash publikuj.sh [katalog_docelowy]   (domyślnie ../KRONOS_publiczny)
set -eu
cd "$(dirname "$0")"
DST="${1:-../KRONOS_publiczny}"

# ── BIAŁA LISTA FORMY (jedyne, co wychodzi; zmiana listy = decyzja twórcy) ──
FORMA_MD="START_TU.md README_KRONOS.md JADRO.md 0_WYWOLANIA.md 1_REZONANS.md \
4_MATRYCA_system.md 5_RDZEN.md 6_PRZESWIT_przestrzen.md 6_ROLA_ARCHITEKTA.md \
MAPA_TRANSPERSONALNA.md BLEDY.md PIEC_INWARIANTOW.md SUBSTRAT.md \
RDZEN_SAMOOBSERWACJI.md PROTOKOL_GLOSU.md PROTOKOL_brama.md PUKANIE.md DZWONKI.md DUSZA.md \
WARTOSCI_UNIWERSALNE.md STANDARD_TRESCI.md _TORUS.md _GRANICA.md \
SIEGNIECIE_protokol.md"
FORMA_JS="kronos_v4.js kronos_matryca.js kronos_eter.js kronos_lens.js kronos_engine.js \
kronos_natal.js kronos_pelnia.js scan_outer.js scan_dwarfs.js scan_aspekty.js \
weryfikacja.js zapis_eter.js testy_rdzen.js testy_rdzen_zlote.json \
lint_bledy.js lint_artefaktow.js kronos_impuls.js"
FORMA_SH="wstan.sh publikuj.sh sync_rdzen.sh zapis_git.sh straz_czystosci.sh hashuj.sh straz_duszy.sh"
FORMA_INNE="package.json hexagram_matrycy.svg _HASHE.txt _STRAZ_APPEND.txt LICENSE LICENSE-CONTENT"
FORMA_DIRS=".githooks ephe szablony skills"

# 0. Bezpiecznik: tylko z main i tylko z czystym drzewem
BR="$(git branch --show-current)"
[ "$BR" = "main" ] || { echo "✗ publikacja wyłącznie z main (jesteś: $BR)"; exit 1; }
[ -z "$(git status --porcelain)" ] || { echo "✗ drzewo brudne — commit lub stash przed odlewem"; exit 1; }

# 1. Bezpiecznik treści (drugi zamek): wzorzec żyje POZA odlewem (_STRAZ_wzorzec.txt,
#    nie na białej liście) — sam wzorzec z imionami nigdy nie wychodzi na zewnątrz.
if [ -f _STRAZ_wzorzec.txt ]; then
  # WYJĄTKI JAWNE (28.07.2026): atrybucje za zgodą osoby (np. Holisses) nie są wyciekiem.
  # Plik _STRAZ_wyjatki.txt istniał od początku, ale NIE MIAŁ CIAŁA — wzorzec go nie czytał.
  # Efekt: zamek zgłaszał fałszywy alarm na legalnej atrybucji i blokował odlew. Naprawione.
  WZOR="$(cat _STRAZ_wzorzec.txt)"
  LEAK=""
  for F in $FORMA_MD $FORMA_JS $FORMA_SH $FORMA_INNE; do
    [ -f "$F" ] || continue
    if [ -s _STRAZ_wyjatki.txt ]; then
      HIT="$(grep -vFf _STRAZ_wyjatki.txt "$F" | grep -cE "$WZOR" || true)"
    else
      HIT="$(grep -cE "$WZOR" "$F" || true)"
    fi
    [ "$HIT" = "0" ] || LEAK="$LEAK $F"
  done
  # gałąź katalogowa MUSI honorować wyjątki tak samo jak plikowa —
  # inaczej ta sama jawnie dozwolona atrybucja przechodzi w README i blokuje w skills/ (31.07)
  for D in $FORMA_DIRS; do
    [ -d "$D" ] || continue
    for F2 in $(grep -rlE "$WZOR" "$D" 2>/dev/null || true); do
      if [ -s _STRAZ_wyjatki.txt ]; then
        H3="$(grep -vFf _STRAZ_wyjatki.txt "$F2" | grep -cE "$WZOR" || true)"
      else
        H3="$(grep -cE "$WZOR" "$F2" || true)"
      fi
      [ "$H3" = "0" ] || LEAK="$LEAK $F2"
    done
  done
  [ -z "$LEAK" ] || { echo "✗ WYCIEK w plikach białej listy:"; echo "$LEAK"; echo "   dezynfekcja przed publikacją."; exit 1; }
else
  echo "⚠ _STRAZ_wzorzec.txt brak — drugi zamek pominięty (biała lista = zamek pierwszy)"
fi

# 2. Weryfikacja kanonu — odlew tylko ze struktury całej
node weryfikacja.js | grep -q "STRUKTURA CAŁA" || { echo "✗ kanon niecały — napraw przed odlewem"; exit 1; }

# 3. Odlew: WYŁĄCZNIE biała lista → świeże repo, jeden commit, zero historii
rm -rf "$DST"; mkdir -p "$DST"
git archive HEAD -- $FORMA_MD $FORMA_JS $FORMA_SH $FORMA_INNE $FORMA_DIRS | tar -x -C "$DST"
( cd "$DST" && git init -q && git add -A \
  && git -c user.name="Orkiestrator" -c user.email="orkiestrator@kronos.local" \
       commit -q -m "KRONOS — wydanie publiczne ($(date +%Y-%m-%d)); forma z białej listy, bez historii warsztatu" )
echo "✓ odlew gotowy: $DST ($(ls "$DST" | wc -l) pozycji, jeden commit, zero historii). Remote i push — decyzja twórcy."
