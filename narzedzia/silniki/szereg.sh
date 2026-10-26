#!/usr/bin/env bash
# szereg.sh — JEDEN bufor szeregów (zlecenie 2 cz.4, 25.10.2026; słowo twórcy 25.10 07:54 „Zgadzamy się z kierunkiem”).
# PRZYCZYNA (zmierzone cz.3 §1): wstanie i commit dopisywały wiersze wprost do ŚLEDZONYCH rejestrów (ALARMY_szereg, POZIOM_rozjazd, ZAPIS_biegi, ZATRZYMYWACZ)
# → drzewo brudne po każdej czynności, rebase rc=3 przy zapis_git.sh w tle. Wiersz idzie do bufora w .git (nieśledzony); do pliku — dopiero `zlej`, tuż przed commitem,
# który i tak powstaje. ZASTĘPUJE dwa bufory z cz.2/cz.3 (ZAPIS_biegi.<SES>.bufor, zatrzymywacz.bufor). Ścieżka ignorowana i nieśledzona (gość, odlew) → zapis wprost.
# UŻYCIE: szereg.sh dopisz <ścieżka> <wiersz> · czytaj <ścieżka> (plik + wiersze jeszcze nie zlane) · zlej (bufory → pliki + git add; tylko poza rebase) ·
#         domknij (po rc=0 pushu: zlane wiersze znikają z bufora) · --test.  ZMIENNA: SZEREG_PRZEKIERUJ="prefiks=nowy ..." (cel zlania; fault-injection torów zapis_git).
set -u
cd "$(git rev-parse --show-toplevel 2>/dev/null)" 2>/dev/null || true
GD="$(git rev-parse --absolute-git-dir 2>/dev/null)"; NAGL=""; ETYK="szereg"
liczba() { case "$1" in ''|*[!0-9]*) echo 0 ;; *) echo "$1" ;; esac; }
do_bufora() { [ -n "$GD" ] || return 1; case "$1" in /*|../*) return 1 ;; esac; git check-ignore -q -- "$1" 2>/dev/null; [ $? -eq 1 ]; }
opis() {   # nagłówek i etykieta komunikatu per rejestr (po ścieżce w repo)
  case "$1" in
    kanon/pomiary/ZAPIS_biegi/*.txt) ETYK="bieg"; NAGL="# biegi zapis_git.sh, sesja $(basename "$1" .txt) · pola: data · rc · sekundy · rebase · oddech · plik winny przy rc=3 · [· scalone=pliki — tylko gdy tryb reczny scalil plik bez konfliktu, 08.10] [· furtka=NAZWA[:powod];… — tylko gdy furtka operatora zmienila bieg, 24.10] · append-only (S2, 04.10.2026)" ;;
    kanon/pomiary/ZATRZYMYWACZ_szereg.txt) ETYK="szereg ZATRZYMYWACZA"; NAGL="# ZATRZYMYWACZ — szereg odpowiedzi (append-only; wiersz = jedna odpowiedź; źródło: .claude/hooks/zatrzymywacz_stop.sh)" ;;
  esac
}
dopisz() { local b="$1"; do_bufora "$1" && b="$GD/szeregi/$1"; mkdir -p "$(dirname "$b")" && printf '%s\n' "$2" >> "$b"; }
czytaj() {
  cat "$1" 2>/dev/null
  [ -n "$GD" ] && [ -s "$GD/szeregi/$1" ] && tail -n +"$(( $(liczba "$(cat "$GD/szeregi/$1.zlane" 2>/dev/null)") + 1 ))" "$GD/szeregi/$1"
  return 0
}
zlej() {
  local b rel od n cel m rc=0
  [ -d "$GD/szeregi" ] || return 0
  if [ -d "$GD/rebase-merge" ] || [ -d "$GD/rebase-apply" ]; then return 0; fi   # w toku rebase śledzony plik brudziłby drzewo (rebase --continue odmówi)
  while IFS= read -r b; do
    rel="${b#"$GD"/szeregi/}"; od="$(liczba "$(cat "$b.zlane" 2>/dev/null)")"; n="$(wc -l < "$b" | tr -d ' ')"; [ "$n" -gt "$od" ] || continue
    NAGL=""; ETYK="szereg"; opis "$rel"; cel="$rel"
    for m in ${SZEREG_PRZEKIERUJ:-}; do case "$rel" in "${m%%=*}"|"${m%%=*}"/*) cel="${m#*=}${rel#"${m%%=*}"}" ;; esac; done
    { mkdir -p "$(dirname "$cel")" && { [ -f "$cel" ] || [ -z "$NAGL" ] || printf '%s\n' "$NAGL" > "$cel"; } \
      && sed -n "$((od + 1)),${n}p" "$b" >> "$cel" && echo "$n" > "$b.zlane"; } \
      || { echo "   ⚠ $ETYK niezapisany: nie moge dopisac do $cel (wiersze zostaja w buforze .git) — push idzie dalej." >&2; rc=1; continue; }
    git add -- "$cel" >/dev/null 2>&1 || true
  done < <(find "$GD/szeregi" -type f ! -name '*.zlane' 2>/dev/null | sort)
  return $rc
}
domknij() {
  local z b
  [ -d "$GD/szeregi" ] || return 0
  while IFS= read -r z; do
    b="${z%.zlane}"
    if tail -n +"$(( $(liczba "$(cat "$z" 2>/dev/null)") + 1 ))" "$b" > "$b.reszta" 2>/dev/null; then mv -f "$b.reszta" "$b"; rm -f "$z"; else rm -f "$b.reszta"; fi
  done < <(find "$GD/szeregi" -type f -name '*.zlane' 2>/dev/null)
}
case "${1:-}" in
  dopisz) [ $# -ge 3 ] || { echo "UŻYCIE: szereg.sh dopisz <ścieżka> <wiersz>" >&2; exit 2; }; dopisz "$2" "$3" ;;
  czytaj) czytaj "$2" ;;
  zlej) zlej ;;
  domknij) domknij ;;
  --test)
    SELF="$(cd "$(dirname "$0")" && pwd)/$(basename "$0")"; T="$(mktemp -d)"; z=0; o=0
    spr() { if [ "$2" = "$3" ]; then echo "  ✓ $1"; z=$((z+1)); else echo "  ✗ $1 (jest: $2, oczekiwano: $3)"; o=$((o+1)); fi; }
    sz() { ( cd "$T" && bash "$SELF" "$@" ); }; R=kanon/pomiary/ALARMY_szereg.txt; B="$T/.git/szeregi/$R"
    echo "╔═══ SZEREG.SH — AUTOTEST ═══╗"
    git -C "$T" init -q && git -C "$T" config user.email t@t && git -C "$T" config user.name t && mkdir -p "$T/kanon/pomiary" && printf 'a\n' > "$T/$R" && printf 'ign/\n' > "$T/.gitignore"
    git -C "$T" add -A && git -C "$T" commit -qm seed
    sz dopisz "$R" w1; sz dopisz "$R" w2
    spr "(+) dopisz: drzewo CZYSTE, wiersze w buforze .git" "$(git -C "$T" status --porcelain | wc -l | tr -d ' ')/$(wc -l < "$B" | tr -d ' ')" "0/2"
    spr "(+) czytaj: plik, potem bufor (kolejność czasu)" "$(sz czytaj "$R" | paste -sd,)" "a,w1,w2"
    sz zlej; spr "(+) zlej: wiersze w pliku, git add, licznik .zlane = 2" "$(paste -sd, "$T/$R")/$(git -C "$T" diff --cached --name-only)/$(cat "$B.zlane")" "a,w1,w2/$R/2"
    spr "(+) czytaj po zlaniu: BEZ dubli" "$(sz czytaj "$R" | paste -sd,)" "a,w1,w2"
    sz dopisz "$R" w3; sz zlej; spr "(+) drugi zlej dokłada tylko nowe (bez dubli)" "$(paste -sd, "$T/$R")" "a,w1,w2,w3"
    sz domknij; spr "(+) domknij: bufor pusty, .zlane zdjęty" "$(wc -c < "$B" | tr -d ' ')/$([ -e "$B.zlane" ] && echo jest || echo brak)" "0/brak"
    sz dopisz "ign/x.txt" wp; spr "(+) ścieżka ignorowana i nieśledzona → zapis wprost, bez bufora" "$(cat "$T/ign/x.txt")/$([ -e "$T/.git/szeregi/ign/x.txt" ] && echo bufor || echo brak)" "wp/brak"
    mkdir -p "$T/.git/rebase-merge"; sz dopisz "$R" w4; sz zlej; spr "(−) zlej w toku rebase NIE rusza pliku" "$(paste -sd, "$T/$R")" "a,w1,w2,w3"; rmdir "$T/.git/rebase-merge"
    git -C "$T" commit -qam c1; printf 'x' > "$T/blok"; SZEREG_PRZEKIERUJ="$R=blok/n.txt" sz zlej 2>/dev/null; RC=$?
    spr "(−) zlej oblany (cel pod plikiem): rc=1, bufor i licznik bez zmian" "$RC/$(wc -l < "$B" | tr -d ' ')/$(cat "$B.zlane" 2>/dev/null)" "1/1/"
    sz zlej; spr "(+) po naprawie: wiersz zlany dokładnie raz" "$(grep -c '^w4$' "$T/$R")" "1"
    rm -rf "$T/.git/szeregi" && printf 'x' > "$T/.git/szeregi"; sz dopisz "$R" w5 2>/dev/null; RC=$?
    spr "(−) dopisz oblany (bufor zablokowany): rc≠0" "$([ $RC -ne 0 ] && echo rc)" "rc"
    rm -rf "$T"; echo "── SZEREG.SH: $z zdanych · $o oblanych ──"; [ "$o" -eq 0 ] ;;
  *) echo "UŻYCIE: szereg.sh dopisz <ścieżka> <wiersz> | czytaj <ścieżka> | zlej | domknij | --test" >&2; exit 2 ;;
esac
