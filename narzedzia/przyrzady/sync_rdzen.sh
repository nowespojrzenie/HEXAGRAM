#!/usr/bin/env sh
# ── SYNCHRONIZACJA RDZENIA (tylko gałąź prywatna) ──────────────────────────
# Zaciąga ulepszenia genomu z main. Tkanka (dane) jest chroniona przez
# .gitattributes merge=ours — ten skrypt tylko włącza driver i scala.
set -eu

# ── TOR (#38 · K6/N6, 19.10.2026) ──────────────────────────────────────────────
# Przyrząd, który zmienia drzewo, ma tor „−” na awarię WŁASNYCH narzędzi: `git checkout` tkanki, `hashuj.sh`,
# `weryfikacja.js`. Fikstura: bare origin + klon na `prywatna`; kopia TEGO skryptu w atrapie (dwa poziomy pod korzeniem,
# jak w produkcji), atrapy hashuj.sh/weryfikacja.js, a `git` podmieniony na wtyczkę tylko w przypadku D.
if [ "${1:-}" = "--test" ]; then
  echo "╔═══ SYNC_RDZEN — AUTOTEST (#38) ═══╗"
  SAM="$(cd "$(dirname "$0")" && pwd)/$(basename "$0")"
  GITBIN="$(command -v git)"
  T="$(mktemp -d)"; z=0; o=0
  spr() { if [ "$2" = "$3" ]; then echo "  ✓ $1"; z=$((z+1)); else echo "  ✗ $1 (rc=$2, oczekiwano $3)"; o=$((o+1)); fi; }
  export GIT_AUTHOR_NAME=T GIT_AUTHOR_EMAIL=t@t GIT_COMMITTER_NAME=T GIT_COMMITTER_EMAIL=t@t
  zbuduj() {   # $1 = katalog fikstury; $2 = rc atrapy weryfikacja.js; $3 = rc atrapy hashuj.sh
    local W="$1"
    rm -rf "$W" "$W.git" "$W.w2"; "$GITBIN" init -q --bare "$W.git"; "$GITBIN" clone -q "$W.git" "$W" 2>/dev/null
    ( cd "$W" && "$GITBIN" checkout -q -b main && mkdir -p narzedzia/przyrzady && cp "$SAM" narzedzia/przyrzady/sync_rdzen.sh \
      && printf 'tkanka.txt merge=ours\n' > .gitattributes && echo "tkanka main" > tkanka.txt && echo r1 > rdzen.txt \
      && printf 'abc  rdzen.txt\n' > _HASHE.txt \
      && printf '#!/bin/sh\n[ "$1" = "--odcisk" ] || exit 0\n[ "%s" = 0 ] || exit %s\necho deadbeef0000\n' "$3" "$3" > hashuj.sh \
      && printf 'process.exit(%s)\n' "$2" > weryfikacja.js \
      && "$GITBIN" add -A && "$GITBIN" commit -qm m1 && "$GITBIN" push -q origin main \
      && "$GITBIN" checkout -q -b prywatna && echo "tkanka prywatna" > tkanka.txt && "$GITBIN" commit -qam p1 ) >/dev/null 2>&1
    "$GITBIN" clone -q "$W.git" "$W.w2" 2>/dev/null
    ( cd "$W.w2" && "$GITBIN" checkout -q main && echo r2 > rdzen.txt && echo "tkanka main 2" > tkanka.txt && "$GITBIN" commit -qam m2 && "$GITBIN" push -q origin main ) >/dev/null 2>&1
  }
  uruchom() { ( cd "$1" && sh narzedzia/przyrzady/sync_rdzen.sh 2>&1 ); }
  ma_ok() { case "$1" in *"✓ rdzeń zsynchronizowany"*) return 0 ;; *) return 1 ;; esac; }

  # (A) + zdrowo: rc 0, „✓”, rdzeń z main, tkanka prywatna zachowana
  zbuduj "$T/a" 0 0; WY="$(uruchom "$T/a")" && _r=0 || _r=$?
  spr "A zdrowy sync przechodzi (odroznialnosc)" "$_r" "0"
  ma_ok "$WY" && _r=0 || _r=1; spr "A melduje ✓ po weryfikacji" "$_r" "0"
  [ "$(cat "$T/a/rdzen.txt")" = "r2" ] && [ "$(cat "$T/a/tkanka.txt")" = "tkanka prywatna" ] && _r=0 || _r=1
  spr "A rdzen z main, tkanka prywatna nietknieta" "$_r" "0"
  # (B) − weryfikacja.js pada: rc != 0 i ZERO „✓ rdzeń zsynchronizowany”
  zbuduj "$T/b" 1 0; WY="$(uruchom "$T/b")" && _r=0 || _r=$?
  [ "$_r" != 0 ] && _r=1 || _r=0; spr "B weryfikacja.js rc 1 = sync NIE konczy sie sukcesem" "$_r" "1"
  ma_ok "$WY" && _r=1 || _r=0; spr "B brak falszywego ✓" "$_r" "0"
  # (C) − hashuj.sh pada: rc != 0, _HASHE.txt nietkniety, brak _HASHE.new, brak „✓”
  zbuduj "$T/c" 0 7
  WY="$(uruchom "$T/c")" && _r=0 || _r=$?
  [ "$_r" != 0 ] && _r=1 || _r=0; spr "C hashuj.sh pada = sync NIE konczy sie sukcesem" "$_r" "1"
  [ -e "$T/c/_HASHE.new" ] && _r=1 || _r=0; spr "C brak osieroconego _HASHE.new" "$_r" "0"
  ma_ok "$WY" && _r=1 || _r=0; spr "C brak falszywego ✓" "$_r" "0"
  ( cd "$T/c" && "$GITBIN" show HEAD:_HASHE.txt | cmp -s - _HASHE.txt ) && _r=0 || _r=1
  spr "C _HASHE.txt nie zostal podmieniony na polowiczny" "$_r" "0"
  # (D) − `git checkout` tkanki pada (wtyczka): rc != 0, brak „✓”
  zbuduj "$T/d" 0 0; mkdir -p "$T/bin"
  printf '#!/bin/sh\nif [ "${1:-}" = checkout ]; then exit 1; fi\nexec "%s" "$@"\n' "$GITBIN" > "$T/bin/git"; chmod +x "$T/bin/git"
  WY="$( cd "$T/d" && PATH="$T/bin:$PATH" sh narzedzia/przyrzady/sync_rdzen.sh 2>&1 )" && _r=0 || _r=$?
  [ "$_r" != 0 ] && _r=1 || _r=0; spr "D checkout tkanki pada = sync NIE konczy sie sukcesem" "$_r" "1"
  ma_ok "$WY" && _r=1 || _r=0; spr "D brak falszywego ✓" "$_r" "0"

  rm -rf "$T"
  echo "  zmierzone: zdanych $z · oblanych $o"
  [ "$o" -eq 0 ] || { echo "  ✗ TOR OBLANY"; exit 1; }
  echo "  ✓ SYNC UMIE NIE PRZEJŚĆ — awaria własnych narzędzi nie kończy się „✓”."
  exit 0
fi

cd "$(dirname "$0")/../.."   # dach narzedzia/przyrzady/ (29.08): korzeń repo
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
# K6/N6: `|| true` połykał porażkę przywrócenia tkanki — plik z main zostawał w commicie „tkanka przywrócona twardo”.
# Teraz: plik JEST w HEAD, a checkout padł → STOP (merge zostaje w toku: `git merge --abort`). Pliku nie ma w HEAD =
# wpis .gitattributes bez ciała w tej instancji → ⓘ, nie błąd. Pętla czyta z listy (nie z potoku), żeby `exit` działał.
_TK="$(grep -E 'merge=ours' .gitattributes | awk '{print $1}')"
while read -r f; do
  [ -n "$f" ] || continue
  if git checkout HEAD -- "$f" 2>/dev/null; then
    echo "  ⚕ tkanka trzymana: $f"
  elif [ -n "$(git ls-tree -r --name-only HEAD -- "$f" 2>/dev/null)" ]; then
    echo "!! przywrócenie tkanki NIE powiodło się: $f — merge w toku, tkanka mogła przyjąć wersję main."
    echo "   Cofnij: git merge --abort"; exit 1
  else
    echo "  ⓘ tkanka (wpis w .gitattributes) bez pliku w HEAD: $f"
  fi
done <<ZAKONCZ
$_TK
ZAKONCZ
git commit -q -m "sync rdzenia z main ($(date +%Y-%m-%d)); tkanka przywrócona twardo"
# odśwież hashe rdzenia (tkanka ma własne, poza spójnością genomu)
# UNIA listy (S5, 16.07): pokrycie genomu płynie z main, tkanka zostaje lokalna;
# wartości ZAWSZE z dysku tej gałęzi. Żaden plik pilnowany na main nie wypada z listy tu.
# K6/N6: dawne `[ -f ] && printf` robiło z nieistniejącego pliku rc 1 pętli (mv pomijany po cichu), a z awarii hashuj.sh —
# wiersz bez odcisku. Teraz: brak pliku = pominięty; hashuj padł / pusty odcisk = STOP, _HASHE.txt NIETKNIĘTY, brak _HASHE.new.
_hrc=0
{ git show origin/main:_HASHE.txt 2>/dev/null || true; cat _HASHE.txt; } | awk '{print $2}' | sort -u | while read -r f; do
  [ -f "$f" ] || continue
  _o="$(bash hashuj.sh --odcisk "$f")" || { echo "!! hashuj.sh --odcisk padł dla: $f" >&2; exit 1; }
  [ -n "$_o" ] || { echo "!! hashuj.sh --odcisk oddał pusty odcisk dla: $f" >&2; exit 1; }
  printf "%s  %s\n" "$_o" "$f"   # odcisk kanoniczny (tura CRLF 02.09)
done > _HASHE.new || _hrc=$?
if [ "$_hrc" -ne 0 ]; then
  rm -f _HASHE.new
  echo "!! odświeżenie _HASHE.txt przerwane (rc=$_hrc) — _HASHE.txt NIETKNIĘTY. Rdzeń scalony, hashe NIE odświeżone."; exit 1
fi
mv _HASHE.new _HASHE.txt || { echo "!! mv _HASHE.new → _HASHE.txt padł"; exit 1; }
# „✓” dopiero po mierzeniu: weryfikacja.js rc 0 (K6/N6). Dotąd komunikat sukcesu stał przed pomiarem i kazał go zrobić ręką.
_wrc=0; node weryfikacja.js >/dev/null 2>&1 || _wrc=$?
if [ "$_wrc" -ne 0 ]; then
  echo "!! weryfikacja.js po syncu: rc=$_wrc — rdzeń scalony, ale genom NIE jest spójny. Uruchom: node weryfikacja.js"; exit 1
fi
echo "✓ rdzeń zsynchronizowany. Dane (tkanka) nietknięte; weryfikacja.js rc 0."
