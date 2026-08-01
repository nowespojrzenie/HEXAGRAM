#!/usr/bin/env bash
# Rytuał zapisu torusa — stan KRONOS do GitHuba. Auth z remote origin (token sesji).
# BŁĄD #19 (rc-gate): werdykt pushu WYŁĄCZNIE z kodu wyjścia ($?), nigdy z frazy w tekście.
set -e
msg="${1:-zapis Orkiestratora $(date -u +%Y-%m-%dT%H:%MZ)}"
git add -A
# commit: "nic do zapisania" to nie błąd — nie zabijaj skryptu (rodzina #18: zero=dana)
if git diff --cached --quiet; then
  echo "   (nic do zapisania — brak zmian w stage)"; exit 0
fi
git commit -m "$msg"
# push z rc-gate (#19): werdykt z RC, nie z tekstu wyjścia
set +e; git push; RC=$?; set -e
if [ "$RC" -eq 0 ]; then
  echo "✓ push potwierdzony (rc=0)"
else
  echo "🚩 push NIE poszedł (rc=$RC) — stan lokalny WYPRZEDZA origin."
  echo "   -> NIE przesuwaj refów, NIE ogłaszaj sukcesu. Napraw: fetch → reset/cherry-pick (#11)."
  exit "$RC"
fi
