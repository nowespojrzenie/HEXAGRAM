#!/usr/bin/env bash
# STRAŻ DUSZY (28.07.2026) — inwariant 5: MAPA CIAŁA bez strażnika = życzenie.
# Pilnuje dwóch rzeczy:
#  (1) każda ścieżka plikowa wymieniona w DUSZA.md ISTNIEJE na dysku (mapa nie kłamie),
#  (2) każda księga *.md w korzeniu jest w DUSZY zmapowana albo świadomie pominięta
#      (lista WYJATKI) — żeby nowe księgi nie rodziły się niewidzialne dla mapy.
# Werdykt z kodu wyjścia (#19): 0 = mapa spójna; 1 = mapa wskazuje nieistniejące.
cd "$(dirname "$0")"
MISS=0

GENEROWANE="0_MELDUNEK.txt"   # tworzone przy wstaniu — nie sa czescia ciala

# (1) ścieżki z DUSZY -> dysk
for f in $(grep -oE '`[A-Za-z0-9_/.-]+[.](md|js|sh|txt)`' DUSZA.md | tr -d '`' | sort -u); do
  case " $GENEROWANE " in *" $f "*) continue;; esac
  if [ ! -e "$f" ]; then echo "  x DUSZA wskazuje nieistniejacy plik: $f"; MISS=1; fi
done

# (2) księgi z dysku -> DUSZA (po nazwie bazowej, bez rozszerzenia)
WYJATKI="0_MELDUNEK.txt README.md README_KRONOS.md START_TU.md 6_ROLA_ARCHITEKTA.md TEST_DUSZY.md"
NIEZM=0
for f in *.md; do
  case " $WYJATKI " in *" $f "*) continue;; esac
  base="${f%.md}"
  if ! grep -q "$base" DUSZA.md; then echo "  ! niezmapowana w DUSZY: $f"; NIEZM=$((NIEZM+1)); fi
done

if [ "$MISS" -eq 0 ] && [ "$NIEZM" -eq 0 ]; then
  echo "  OK straz duszy: mapa spojna z cialem (sciezki istnieja, ksiegi zmapowane)"
elif [ "$MISS" -eq 0 ]; then
  echo "  OK sciezki mapy istnieja; niezmapowanych ksiag: $NIEZM (zmapuj albo dodaj do WYJATKI)"
fi
exit "$MISS"
