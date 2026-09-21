#!/usr/bin/env bash
# ═══ STRAŻ TROPU (20.08.2026, 23:0x CEST) — egzekutor PRAWA TROPU ═══
#
# RODOWÓD: kanon/ksiegi/KIERUNEK_ORGANIZM.md §III — test anty-kargo-kultowy dla inspiracji
# biologicznych. Sekcja weszła do repo jako PROPOZYCJA (a2963fc: „prawa nie nadaje
# dokument o sobie samym, a testu nie egzekwuje żaden przyrząd"). RATYFIKACJA TWÓRCY
# 20.08.2026 ~23:00, słowo w czacie: „Zbuduj nośnik-szablon dla §III — ratyfikuję
# z mechanizmem." Ten plik jest tym mechanizmem — bez niego §III byłaby regułą
# wyłącznie w dokumentacji (#38), czyli dokładnie kargo-kultem, przed którym ostrzega.
#
# PRAWO TROPU: inspiracja biologiczna wchodzi do kanonu tylko z trzema polami
# wypełnionymi JEDNOCZEŚNIE: WYZWALACZ (kiedy mechanizm się odpala) · ZASÓB (co
# oszczędza albo chroni) · METRYKA (co da się pogorszyć i poprawić).
#
# NOŚNIK: znacznik czytany maszynowo (wzór #55/#56: obietnica bez czytnika to proza,
# alarm szerszy niż sygnał uczy nie patrzeć). Wpis = blok czterech pól bold-markdown:
#   linia startu z ZN (TROP-BIO), a w NASTĘPNYCH ≤8 liniach trzy pola z niepustą
#   treścią po dwukropku. Proza używająca słów „wyzwalacz/zasób/metryka" BEZ znacznika
#   NIE jest wpisem — zero fałszywych trafień na cytowaniach (policzone przed budową:
#   0 znaczników w korpusie przed §IV, słowa opisowe liczne).
#
# ZERO ZNACZĄCE (lekcja INSUM, 20.08): korpus bez żadnego tropu to stan zdrowy
# (odbiorca odlewu może nie nieść rejestru badawczego) — dostaje własne zdanie
# i rc=0, nigdy alarm; to NIE jest #52, bo pusty zbiór jest tu legalny i NAZWANY.
#
# UŻYCIE:  bash straz_tropu.sh          (skan .md śledzonych; rc=1 przy tropie bez pól)
#          bash straz_tropu.sh --test   (tor +/− — straż musi umieć NIE przejść)
set -u
cd "$(dirname "$0")/../.."

ZN='TROP-BIO:'
OKNO=8

# Iniekcja zależności (#50): funkcja przyjmuje PLIKI — tor bije w to samo ciało.
skan_tropow() {
  local f n_tropow=0 brak=0
  for f in "$@"; do
    [ -f "$f" ] || continue
    while IFS=: read -r ln _; do
      [ -n "$ln" ] || continue
      n_tropow=$((n_tropow+1))
      local okno_tresc brakuje=""
      okno_tresc=$(sed -n "$((ln+1)),$((ln+OKNO))p" "$f")
      for pole in 'WYZWALACZ' 'ZASÓB' 'METRYKA'; do
        # pole musi istnieć I nieść niepustą treść po dwukropku (poza gwiazdkami)
        if ! printf '%s\n' "$okno_tresc" | grep -qE "\*\*${pole}:\*\*[[:space:]]*[^[:space:]]"; then
          brakuje="$brakuje $pole"
        fi
      done
      if [ -n "$brakuje" ]; then
        echo "   ✗ $f:$ln — trop bez pól:$brakuje (PRAWO TROPU: trzy pola albo wpis nie wchodzi)"
        brak=$((brak+1))
      fi
    done < <(grep -nF "$ZN" "$f" 2>/dev/null | grep -v '`' | cut -d: -f1 | sed 's/$/:/')
  done
  echo "$n_tropow" > "${TROPY_LICZNIK:-/dev/null}" 2>/dev/null || true
  N_OSTATNI=$n_tropow
  [ "$brak" -eq 0 ]
}

# ── TOR TESTOWY (#38) ──
if [ "${1:-}" = "--test" ]; then
  echo "╔═══ STRAŻ TROPU — AUTOTEST (#38) ═══╗"
  zle=""
  T="$(mktemp -d)"
  # (+) trop kompletny przechodzi
  { printf '**%s** sen instancji\n' "$ZN"
    printf '**WYZWALACZ:** cisza między sesjami\n**ZASÓB:** tokeny\n**METRYKA:** koszt wstania\n'
  } > "$T/pelny.md"
  skan_tropow "$T/pelny.md" >/dev/null || zle="$zle pelny-alarmuje"
  # (−) brak METRYKI MUSI oblać
  { printf '**%s** homeostat\n' "$ZN"
    printf '**WYZWALACZ:** próg\n**ZASÓB:** budżet\n'
  } > "$T/bez_metryki.md"
  skan_tropow "$T/bez_metryki.md" >/dev/null && zle="$zle brak-metryki-przechodzi"
  # (−) pole PUSTE (sam znacznik pola, zero treści) MUSI oblać
  { printf '**%s** feromony\n' "$ZN"
    printf '**WYZWALACZ:** kolizja\n**ZASÓB:**\n**METRYKA:** kolizje/mies\n'
  } > "$T/puste_pole.md"
  skan_tropow "$T/puste_pole.md" >/dev/null && zle="$zle puste-pole-przechodzi"
  # (⊙) proza ze słowami wyzwalacz/zasób/metryka BEZ znacznika NIE jest wpisem
  printf 'W prozie: wyzwalacz bywa mylony z zasobem, a metryka z życzeniem.\n' > "$T/proza.md"
  skan_tropow "$T/proza.md" >/dev/null || zle="$zle proza-liczona-jako-trop"
  # (⊙⊙) dwa tropy, jeden chory → dokładnie jeden alarm, rc oblewa
  cat "$T/pelny.md" "$T/bez_metryki.md" > "$T/mieszany.md"
  W=$(skan_tropow "$T/mieszany.md"; echo "rc=$?")
  A=$(printf '%s' "$W" | grep -c '✗'); R=$(printf '%s' "$W" | grep -oE 'rc=[0-9]+')
  { [ "$A" -eq 1 ] && [ "$R" = "rc=1" ]; } || zle="$zle mieszany-zle-liczy($A/$R)"
  # (⊙⊙⊙) ZERO ZNACZĄCE: brak tropów w ogóle = rc=0 (pusty zbiór legalny i nazwany)
  printf 'zwykła treść bez tropów\n' > "$T/cichy.md"
  skan_tropow "$T/cichy.md" >/dev/null; [ $? -eq 0 ] || zle="$zle zero-znaczace-alarmuje"
  # (⊙4) znacznik w kodzie (linia z grawisem) nie liczy się jako wpis — dokumentacja wzorca
  printf 'przykład w kodzie: `%s` nie jest wpisem\n' "$ZN" > "$T/kod.md"
  skan_tropow "$T/kod.md" >/dev/null || zle="$zle grawis-nie-zwalnia"
  rm -rf "$T"
  if [ -z "$zle" ]; then
    echo "  ✓ STRAŻ ŻYWA — 7 torów: komplet przechodzi, brak pola i puste pole oblewa,"
    echo "    proza i kod nie są wpisem, mieszany liczy co do sztuki, zero jest znaczące."
    exit 0
  fi
  echo "  ✗ STRAŻ MARTWA — oblane:$zle"
  exit 1
fi

# ── TRYB POMIARU: wszystkie śledzone .md ──
PLIKI=$(git ls-files '*.md' 2>/dev/null)
if [ -z "$PLIKI" ]; then
  echo "   ⓘ straz_tropu: brak śledzonych .md (poza repo?)"
  exit 0
fi
N_OSTATNI=0
# shellcheck disable=SC2086
if skan_tropow $PLIKI; then
  if [ "${N_OSTATNI:-0}" -eq 0 ]; then
    echo "   ✓ zero tropów bio w korpusie — zero ZNACZĄCE: rejestr badawczy pusty albo nieobecny, to stan legalny (PRAWO TROPU czuwa)"
  else
    echo "   ✓ PRAWO TROPU trzyma — tropów bio: ${N_OSTATNI}, każdy z kompletem WYZWALACZ·ZASÓB·METRYKA"
  fi
  exit 0
fi
echo "   ✗ trop bez kompletu pól — uzupełnij albo zdejmij znacznik (inspiracja bez testu nie wchodzi do kanonu)"
exit 1
