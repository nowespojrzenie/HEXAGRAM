#!/usr/bin/env bash
# KRONOS · STRAŻ ŻETONU (02.09.2026) — czy wynik w rejestrze powstał na instancji,
# która NAPRAWDĘ WSTAŁA.
#
# POWÓD (słowa twórcy 02.09): „jeżeli ktoś będzie odpalał z naszego repo na obcym
# narzędziu, jemu się wydaje, że coś zostało, ale nie wstało — to masakra. Będziemy
# przeprowadzali testy Przymilnika i one od początku będą produkowały błąd."
#
# PARADOKS, KTÓRY TA STRAŻ OMIJA: instancja BEZ dostępu nie uruchomi żadnego mechanizmu
# w repo — repo mówi wyłącznie do tych, którzy je uruchomili. Nie da się więc zmusić jej
# do przyznania się. DA SIĘ natomiast UNIEWAŻNIĆ JEJ WYNIK, i to bez udziału twórcy:
# weryfikuje się nie instancję, tylko ŻETON, który zostawiła w rejestrze.
#
# MECHANIZM: żeton niesie `HEAD` z chwili wstania. `git cat-file` rozstrzyga w jednym
# poleceniu, czy taki commit w ogóle istnieje w tym repo. Zmyślony hash NIE PRZEJDZIE.
# To nie jest kryptografia — to KOSZT: cena kłamstwa rośnie z „napisz płynne zdanie"
# do „sfabrykuj wartość, którą straż sprawdza mechanicznie".
#
# TRZY WERDYKTY, ROZŁĄCZNE:
#   ✓ WAŻNY      — żeton obecny, HEAD istnieje w repo
#   ⚠ BEZ ŻETONU — wynik nie deklaruje wstania; NIE jest to oskarżenie o fabrykację,
#                  tylko brak podstawy do wpisania go jako pomiaru
#   ✗ ŻETON MARTWY — HEAD podany, ale NIE ISTNIEJE w tym repo. Twarde: wynik nieważny.
#
# TRYB --porownaj <hash> (03.09.2026, MOSTY #34/#35 — żeton ODŚWIEŻANY):
#   Żeton mówi „widziałem stan PRZY WSTANIU", nie „widzę go teraz". 02.09 żeton był ważny
#   za każdym razem i za każdym razem nie pomógł: instancja z ważnym żetonem trzy razy
#   zameldowała jako otwarte to, co zamknięto — raz własną ręką w turze przerwanej.
#   Ten tryb mierzy CZAS stanu (ile commitów instancja NIE MA w kontekście), nie ISTNIENIE
#   pracy (to inwentarz, #35). Cztery werdykty, rozłączne, każdy z własnym rc:
#   ✓ ŚWIEŻY         rc=0 — hash == HEAD i origin nie jest przed tobą
#   ⚠ PRZESTARZAŁY   rc=1 — o N commitów za HEAD (lista — TO są commity spoza kontekstu,
#                            także własne) i/lub ORIGIN PRZED TOBĄ o N → git pull --ff-only
#   ✗ MARTWY         rc=2 — hash nie istnieje w repo
#   ⚠ BEZ            rc=3 — hasha nie podano
#   fetch bez auth/sieci NIE udaje: melduje „porównanie lokalne". zeton_stan() nietknięte.
set -uo pipefail
_SS="$(dirname "$0")/../silniki/strefa_st.sh"; if [ -f "$_SS" ]; then . "$_SS"; else _STREFA_ST=Europe/Warsaw; fi   # strefa instancji (wspólny fragment strefa_st.sh → tz_pl.js: KRONOS_TZ > instancja.json > package.json); psuty instancja.json = „STREFA?" + komunikat, nie cichy powrót do Warszawy
KOR="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$KOR" || exit 2

# Miejsca, w których wynik BEZ ważnego żetonu nie ma prawa być liczony jako pomiar.
SKAN="${ZETON_SKAN:-prerejestr kanon/eksperymenty}"

zeton_stan() {           # $1 = ścieżka pliku → drukuje: WAZNY | BEZ | MARTWY <hash>
  local f="$1" h
  # 2b (05.10.2026): wstan.sh w katalogu bez .git wydaje żeton BEZ-GIT — to stan, nie fabrykacja, ale też nie
  # do sprawdzenia `git cat-file`; osobny werdykt BEZGIT (ani WAZNY, ani MARTWY, ani brak deklaracji).
  grep -qE 'ŻETON:[[:space:]]*BEZ-GIT' "$f" 2>/dev/null && { echo "BEZGIT"; return; }
  h="$(grep -oE 'ŻETON:[[:space:]]*[0-9a-f]{7,40}' "$f" 2>/dev/null | head -1 \
       | grep -oE '[0-9a-f]{7,40}')"
  [ -z "$h" ] && { echo "BEZ"; return; }
  if git cat-file -e "${h}^{commit}" 2>/dev/null; then echo "WAZNY $h"; else echo "MARTWY $h"; fi
}

porownaj() {             # $1 = hash żetonu → drukuje werdykt, zwraca rc (0 ŚWIEŻY · 1 PRZESTARZAŁY · 2 MARTWY · 3 BEZ)
  local h="${1:-}" br zrodlo n_head n_orig
  [ -z "$h" ] && { echo "   ⚠ BEZ — nie podano hasha żetonu (użycie: --porownaj <hash>)"; return 3; }
  git cat-file -e "${h}^{commit}" 2>/dev/null || { echo "   ✗ MARTWY — $h nie istnieje w tym repo"; return 2; }
  br="$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo HEAD)"
  zrodlo="origin odświeżony"
  git fetch -q origin "$br" 2>/dev/null || zrodlo="porównanie LOKALNE (fetch odbity: bez auth albo sieci — origin sprzed ostatniego fetch)"
  n_head="$(git rev-list --count "$h..HEAD" 2>/dev/null || echo 0)"
  n_orig=0
  git rev-parse -q --verify "origin/$br" >/dev/null 2>&1 && n_orig="$(git rev-list --count "HEAD..origin/$br" 2>/dev/null || echo 0)"
  echo "   żeton $h · HEAD $(git rev-parse --short HEAD) · $zrodlo"
  if [ "$n_head" -eq 0 ] && [ "$n_orig" -eq 0 ]; then
    echo "   ✓ ŚWIEŻY — żeton == HEAD, origin nie jest przed tobą"; return 0
  fi
  if [ "$n_head" -gt 0 ]; then
    echo "   ⚠ PRZESTARZAŁY o $n_head — commity, których NIE MASZ w kontekście (także własne):"
    git log --oneline "$h..HEAD" | cut -c1-100 | sed 's/^/      /'
  fi
  [ "$n_orig" -gt 0 ] && echo "   ⚠ ORIGIN PRZED TOBĄ o $n_orig — \`git pull --ff-only\` przed meldunkiem"
  return 1
}

if [ "${1:-}" = "--porownaj" ]; then
  echo "▤ STRAŻ ŻETONU · --porownaj (⏱ zmierzone: $(TZ="$_STREFA_ST" date '+%Y-%m-%d %H:%M %Z')):"
  porownaj "${2:-}"; exit $?
fi

# ── TOR (#38) — straż bez toru jest życzeniem (Inwariat 5) ────────────────────
if [ "${1:-}" = "--test" ]; then
  echo "╔═══ STRAŻ ŻETONU — AUTOTEST (#38) ═══╗"
  T="$(mktemp -d)"; ZYWY="$(git rev-parse --short HEAD)"
  printf 'ŻETON: %s · 206/0/0 · teraz\n' "$ZYWY" > "$T/a.md"       # (+) żywy HEAD
  printf 'ŻETON: deadbee · 206/0/0 · teraz\n'      > "$T/b.md"       # (−) hash zmyślony
  printf 'wynik rzutu bez zadnej deklaracji\n'     > "$T/c.md"       # (⊙) brak żetonu
  A="$(zeton_stan "$T/a.md" | cut -d' ' -f1)"
  B="$(zeton_stan "$T/b.md" | cut -d' ' -f1)"
  C="$(zeton_stan "$T/c.md" | cut -d' ' -f1)"
  printf 'ŻETON: BEZ-GIT · 268/0/0 · teraz\n'    > "$T/g.md"       # (ⓘ) katalog bez historii git
  G="$(zeton_stan "$T/g.md" | cut -d' ' -f1)"
  echo "── TEST + (HEAD żywy → WAZNY):        $A  (oczekiwane WAZNY)"
  echo "── TEST − (hash zmyślony → MARTWY):   $B  (oczekiwane MARTWY)"
  echo "── TEST ⊙ (brak żetonu → BEZ):        $C  (oczekiwane BEZ)"
  echo "── TEST ⓘ (BEZ-GIT → BEZGIT):         $G  (oczekiwane BEZGIT)"
  # ── TRYB --porownaj (03.09.2026, MOSTY #34/#35): żeton mówi „widziałem stan PRZY WSTANIU",
  # nie „widzę go teraz". Fikstura: repo w mktemp z DWOMA commitami; funkcja mierzy w cwd.
  ( cd "$T" && git init -q r && cd r \
    && git -c user.name=Test -c user.email=t@t commit -q --allow-empty -m "pierwszy" \
    && git -c user.name=Test -c user.email=t@t commit -q --allow-empty -m "drugi-commit-tytul" )
  OUT_D="$(cd "$T/r" && porownaj "$(git rev-parse HEAD)" 2>&1)"; D=$?          # (+) hash=HEAD → ŚWIEŻY
  OUT_E="$(cd "$T/r" && porownaj "$(git rev-parse HEAD~1)" 2>&1)"; E=$?        # (−) HEAD~1 → PRZESTARZAŁY o 1
  OUT_F="$(cd "$T/r" && porownaj deadbee 2>&1)"; F=$?                          # (⊙) zmyślony → MARTWY
  E_LISTA=0; case "$OUT_E" in *drugi-commit-tytul*) E_LISTA=1 ;; esac
  E_O1=0;    case "$OUT_E" in *"PRZESTARZAŁY o 1"*) E_O1=1 ;; esac
  echo "── TEST + (--porownaj HEAD → ŚWIEŻY):       rc=$D  (oczekiwane 0)"
  echo "── TEST − (--porownaj HEAD~1 → PRZESTARZAŁY): rc=$E · «o 1»: $E_O1 · lista niesie tytuł: $E_LISTA  (oczekiwane 1 · 1 · 1)"
  echo "── TEST ⊙ (--porownaj zmyślony → MARTWY):   rc=$F  (oczekiwane 2)"
  # (K6/N10, 23.10.2026) TOR (−) NA AWARIĘ PRZYRZĄDU, nie danych: dawne ciało przy `find` rc≠0 / braku katalogu skanu
  # drukowało „✓ żaden wynik…" i exit 0 nad pustym zbiorem. SAM wskazuje na tę samą straż (bez kopii logiki).
  SAM="$KOR/narzedzia/straze/straz_zetonu.sh"
  mkdir -p "$T/skan_ok" "$T/shim"; printf 'ŻETON: %s · teraz\n' "$ZYWY" > "$T/skan_ok/x.md"
  printf '#!/bin/sh\nexit 1\n' > "$T/shim/find"; chmod +x "$T/shim/find"
  OUT_H="$(ZETON_SKAN="$T/skan_ok" bash "$SAM" 2>&1)"; H=$?                                         # (+) zdrowy skan → ✓ rc 0
  OUT_I="$(ZETON_SKAN="$T/nie_ma_takiego" bash "$SAM" 2>&1)"; I=$?                                 # (−) brak katalogu skanu
  OUT_J="$(PATH="$T/shim:$PATH" ZETON_SKAN="$T/skan_ok" bash "$SAM" 2>&1)"; J=$?                   # (−) `find` pada (rc 1, pusty wynik)
  H_OK=0; case "$OUT_H" in *"✓ żaden wynik"*) H_OK=1 ;; esac
  I_OK=1; case "$OUT_I" in *"✓ żaden wynik"*) I_OK=0 ;; esac; case "$OUT_I" in *"NIE ZMIERZONO"*) ;; *) I_OK=0 ;; esac
  J_OK=1; case "$OUT_J" in *"✓ żaden wynik"*) J_OK=0 ;; esac; case "$OUT_J" in *"NIE ZMIERZONO"*) ;; *) J_OK=0 ;; esac
  echo "── TEST + (zdrowy skan → ✓):                    rc=$H · ✓: $H_OK  (oczekiwane 0 · 1)"
  echo "── TEST − (katalog skanu nie istnieje → ⓘ):     rc=$I · ⓘ bez ✓: $I_OK  (oczekiwane 2 · 1)"
  echo "── TEST − (find pada → ⓘ, nie ✓):               rc=$J · ⓘ bez ✓: $J_OK  (oczekiwane 2 · 1)"
  rm -rf "$T"
  if [ "$H" -ne 0 ] || [ "$H_OK" -ne 1 ] || [ "$I" -ne 2 ] || [ "$I_OK" -ne 1 ] || [ "$J" -ne 2 ] || [ "$J_OK" -ne 1 ]; then
    echo "✗ STRAŻ MARTWA (N10): H=$H/$H_OK I=$I/$I_OK J=$J/$J_OK — awaria przyrządu uchodzi za czysto"; exit 1
  fi
  if [ "$A" = "WAZNY" ] && [ "$B" = "MARTWY" ] && [ "$C" = "BEZ" ] && [ "$G" = "BEZGIT" ] \
     && [ "$D" -eq 0 ] && [ "$E" -eq 1 ] && [ "$E_O1" -eq 1 ] && [ "$E_LISTA" -eq 1 ] && [ "$F" -eq 2 ]; then
    echo "✓ STRAŻ ŻYWA (7/7): odróżnia wstanie od deklaracji wstania, brak żetonu od fabrykacji,"
    echo "  a żeton ŚWIEŻY od PRZESTARZAŁEGO — i wylicza commity, których instancja nie ma w kontekście."
    exit 0
  fi
  echo "✗ STRAŻ MARTWA: A=$A B=$B C=$C G=$G D=$D E=$E/$E_O1/$E_LISTA F=$F"; exit 1
fi

# ── PRODUKCJA ─────────────────────────────────────────────────────────────────
echo "▤ STRAŻ ŻETONU (⏱ zmierzone: $(TZ="$_STREFA_ST" date '+%Y-%m-%d %H:%M %Z')):"
W=0; Z=0; M=0; G=0; NB=0   # NB: awarie własnego przyrządu (find/katalog) — (K6/N10) „nie zmierzono", nie „czysto"
for d in $SKAN; do
  [ -d "$d" ] || { echo "   ⓘ NIE ZMIERZONO: katalog skanu nie istnieje: $d"; NB=$((NB+1)); continue; }
  LISTA="$(find "$d" -type f -name '*.md' 2>/dev/null)" && frc=0 || frc=$?
  [ "$frc" -eq 0 ] || { echo "   ⓘ NIE ZMIERZONO: find rc=$frc w $d — lista plików niepełna albo pusta z awarii"; NB=$((NB+1)); }
  while IFS= read -r f; do
    [ -n "$f" ] || continue
    case "$(zeton_stan "$f")" in
      WAZNY*)  W=$((W+1)) ;;
      MARTWY*) M=$((M+1)); echo "   ✗ ŻETON MARTWY (HEAD nie istnieje w repo) — WYNIK NIEWAŻNY: $f" ;;
      BEZ)     Z=$((Z+1)) ;;
      BEZGIT)  G=$((G+1)) ;;
    esac
  done <<< "$LISTA"
done
echo "   zmierzone: ważnych $W · bez żetonu $Z · MARTWYCH $M · BEZ-GIT $G"
[ "$G" -eq 0 ] || echo "   ⓘ $G plik(ów) z żetonem BEZ-GIT: katalog bez historii git — HEAD nie do sprawdzenia, to nie fabrykacja."
if [ "$M" -gt 0 ]; then
  echo "   ✗ WYNIK Z MARTWYM ŻETONEM NIE WCHODZI DO REJESTRU. Rzut do powtórzenia."
  exit 1
fi
if [ "$Z" -gt 0 ]; then
  echo "   ⚠ $Z plik(ów) bez żetonu — to NIE jest zarzut fabrykacji, tylko brak podstawy,"
  echo "     by liczyć je jako pomiar. Pola żetonu dopisuje się przy najbliższym rzucie."
fi
if [ "$NB" -gt 0 ] || [ $((W+Z+M+G)) -eq 0 ]; then
  echo "   ⓘ NIE ZMIERZONO: skan niepełny albo pusty (przeskanowano $((W+Z+M+G)) plików, awarii przyrządu: $NB) — bez znaku ✓, rc=2"
  exit 2
fi
echo "   ✓ żaden wynik nie powołuje się na wstanie, którego nie było."
exit 0
