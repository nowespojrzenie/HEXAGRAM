#!/usr/bin/env sh
# ── STRAŻNIK CZYSTOŚCI ──────────────────────────────────────────────────────
# Skanuje rdzeń na ślady osobowe właściciela ZANIM wejdą na main (błąd ❼ w BLEDY).
# Lista markerów (nazwiska, prywatne domeny) żyje LOKALNIE w .markery_osobowe
# (gitignored, per-instancja) — bo sama lista jest daną osobową i nie należy do genomu.
# Użycie:  bash straz_czystosci.sh    (przed commit/push na main)
set -eu
cd "$(dirname "$0")"
M=".markery_osobowe"
if [ ! -f "$M" ]; then
  echo "ℹ  brak $M — utwórz (jedno wyrażenie/linia: nazwiska, prywatne domeny), jest w .gitignore."
  echo "   Czysta instancja może nie mieć markerów — to nie błąd."
  exit 0
fi
HIT=0
while IFS= read -r m; do
  [ -z "$m" ] && continue
  case "$m" in \#*) continue ;; esac
  found=$(git grep -nI "$m" -- '*.md' '*.js' '*.sh' 2>/dev/null || true)
  if [ -n "$found" ]; then HIT=1; echo "✗ ślad '$m':"; echo "$found" | sed 's/^/    /'; fi
done < "$M"
if [ "$HIT" -eq 0 ]; then
  echo "✓ czysto — brak śladów osobowych (z $M) w rdzeniu."
else
  echo ""; echo "!! Rdzeń nosi ślady osobowe. Zdejmij (wiedza = destylat, nie nazwiska) przed wejściem na main."; exit 1
fi
