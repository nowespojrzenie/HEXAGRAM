#!/usr/bin/env sh
# ── SYNCHRONIZACJA RDZENIA (tylko gałąź prywatna) ──────────────────────────
# Zaciąga ulepszenia genomu z main. Tkanka (dane) jest chroniona przez
# .gitattributes merge=ours — ten skrypt tylko włącza driver i scala.
set -eu
cd "$(dirname "$0")"
git config merge.ours.driver true          # aktywuje regułę merge=ours z .gitattributes
git fetch origin main
echo "── scalam rdzeń z origin/main (dane nietknięte) ──"
# LEKCJA 15.07.2026: merge=ours odpala się TYLKO przy konflikcie. Plik tkanki
# niezmieniany na prywatnej od merge-base przyjmuje wersję main PO CICHU (czysty
# 3-way) — tak sync zabrał instancji rodowód imienia. Dlatego: merge bez commitu,
# potem TWARDE przywrócenie każdego pliku tkanki z HEAD (lista = .gitattributes),
# dopiero potem commit. .gitattributes pozostaje jedynym źródłem listy tkanki.
git merge --no-commit --no-ff origin/main || {
  echo "!! konflikt poza tkanką — rozwiąż ręcznie, potem: git commit"; exit 1; }
grep -E 'merge=ours' .gitattributes | awk '{print $1}' | while read f; do
  git checkout HEAD -- "$f" 2>/dev/null && echo "  ⚕ tkanka trzymana: $f" || true
done
git commit -q -m "sync rdzenia z main ($(date +%Y-%m-%d)); tkanka przywrócona twardo"
# odśwież hashe rdzenia (tkanka ma własne, poza spójnością genomu)
# UNIA listy (S5, 16.07): pokrycie genomu płynie z main, tkanka zostaje lokalna;
# wartości ZAWSZE z dysku tej gałęzi. Żaden plik pilnowany na main nie wypada z listy tu.
{ git show origin/main:_HASHE.txt 2>/dev/null || true; cat _HASHE.txt; } | awk '{print $2}' | sort -u | while read -r f; do
  [ -f "$f" ] && printf "%s  %s\n" "$(sha256sum "$f" | cut -c1-12)" "$f"
done > _HASHE.new && mv _HASHE.new _HASHE.txt
echo "✓ rdzeń zsynchronizowany. Dane (tkanka) nietknięte. Sprawdź: node weryfikacja.js"
