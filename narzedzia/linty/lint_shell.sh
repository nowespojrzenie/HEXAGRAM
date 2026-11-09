#!/usr/bin/env bash
# lint_shell.sh — shellcheck na skryptach z commita: `error` blokuje zawsze, `warning` tylko WZROST względem HEAD.
# Zewnętrzny standard (EWALUACJA_0911_harness.md §3, prawo 1) zamiast własnych reguł; zastany dług nie blokuje (jak zamek #61).
# Wołany z .githooks/pre-commit. Bez argumentów: sprawdza staged *.sh i .githooks/* (jedyny tryb; --test = tor). rc 0 = czysto, 1 = naruszenie.
# Brak shellchecka = głośne „nie sprawdzono” (rc 0): brak pomiaru to nie zielone światło.
set -u
if ! command -v shellcheck >/dev/null 2>&1; then
  echo "ⓘ lint_shell: shellcheck niezainstalowany — skryptów NIE sprawdzono (brak pomiaru ≠ zero). Instalacja: pip install shellcheck-py"
  exit 0
fi
if [ "${1:-}" = "--test" ]; then   # tor: wzrost warning i error oblewają, czysty przechodzi
  me="$(cd "$(dirname "$0")" && pwd)/lint_shell.sh"; d="$(mktemp -d)"; bad=0
  ( cd "$d" && git init -q . && git config user.email t@t && git config user.name t
    printf '#!/usr/bin/env bash\necho ok\n' >a.sh && git add a.sh && git commit -qm a
    printf '#!/usr/bin/env bash\necho ok2\n' >a.sh && git add a.sh && bash "$me" >/dev/null || exit 1
    printf '#!/usr/bin/env bash\ncd /tmp\n' >a.sh && git add a.sh && { bash "$me" >/dev/null && exit 2; }
    printf '#!/usr/bin/env bash\nprintf "x" y\n' >b.sh && git add b.sh && { bash "$me" >/dev/null && exit 3; }; exit 0 ) || bad=$?
  rm -rf "$d"; echo "lint_shell --test: $([ "$bad" = 0 ] && echo przeszedł || echo "OBLANY (krok $bad)")"; exit "$bad"
fi
files="$(git diff --cached --name-only --diff-filter=ACM | grep -E '\.sh$|^\.githooks/' || true)"
[ -n "$files" ] || exit 0

rc=0; n=0
while IFS= read -r f; do
  [ -n "$f" ] || continue
  n=$((n + 1))
  teraz="$(git show ":$f" | shellcheck -S warning -f gcc - 2>&1)"
  err="$(printf '%s\n' "$teraz" | grep -c ': error: ')"
  w_teraz="$(printf '%s\n' "$teraz" | grep -c ': \(warning\|error\): ')"
  w_przed=0
  if git cat-file -e "HEAD:$f" 2>/dev/null; then
    w_przed="$(git show "HEAD:$f" | shellcheck -S warning -f gcc - 2>&1 | grep -c ': \(warning\|error\): ')"
  fi
  if [ "$err" -gt 0 ] || [ "$w_teraz" -gt "$w_przed" ]; then
    echo "✗ $f: shellcheck error=$err, warning+error $w_przed → $w_teraz"
    printf '%s\n' "$teraz" | grep ': \(warning\|error\): ' | head -8 | sed 's/^-:/    linia /'
    rc=1
  fi
done <<EOF
$files
EOF
[ "$rc" -ne 0 ] || echo "ⓘ lint_shell: $n plik(ów) — error=0, warning nie wzrosło"
exit "$rc"
