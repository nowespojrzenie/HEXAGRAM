#!/usr/bin/env bash
# ── STRAŻ ŚWIEŻOŚCI (27.08.2026) — mechanizm do blizny #71 ──
#
# POWÓD. `wstan.sh` miał JEDNĄ gałąź miękką na wszystko, co nie jest rozjazdem:
# „(pull niemożliwy — offline albo brak remote; pracuję na stanie lokalnym)".
# Ta gałąź połykała trzecią klasę, której nikt nie nazwał: REMOTE ISTNIEJE I SIEĆ ŻYJE,
# ale poświadczenie zostało zdjęte (prawo bezpieczeństwa: `git remote set-url` bez tokena
# po każdym pushu). Wtedy klon MILCZĄCO SIĘ STARZEJE, a każdy kolejny odczyt stanu repo
# udaje teraźniejszość. Zmierzone 27.08: instancja czytała kanon sprzed ~54 h i meldowała
# „repo bez zmian", podczas gdy zdalna gałąź miała 28 commitów twórcy.
#
# DLACZEGO NIE JEDNA TWARDA BRAMKA NA rc≠0: zimny start bez tokena MUSI działać —
# publiczny odlew HEXAGRAM rozpakowuje się i wstaje offline. Alarm szerszy niż sygnał
# uczy nie patrzeć (#56). Dlatego rozróżniamy klasy, zamiast podnosić rc na wszystko.
#
# UŻYCIE:
#   bash straz_swiezosci.sh --klasa "<wyjście pulla>" <rc>   # → ROZJAZD|POSWIADCZENIE|OFFLINE|OK
#   bash straz_swiezosci.sh --wiek                           # → wiek lokalnego HEAD w minutach
#   bash straz_swiezosci.sh --test                           # tor: umie przegrać?
set -u
cd "$(dirname "$0")/../.."

# ── JEDYNE ŹRÓDŁO KLASYFIKACJI (blizna #49: żadnej drugiej kopii tych wzorców) ──
WZ_ROZJAZD='non-fast-forward|diverge|not possible to fast-forward'
WZ_POSWIADCZENIE='could not read Username|could not read Password|Authentication failed|terminal prompts disabled|Invalid username or password|HTTP Basic: Access denied|remote: (Repository not found|Invalid username)|403 Forbidden|Permission denied \(publickey\)'

klasa() {
  local out="$1" rc="${2:-0}"
  [ "$rc" -eq 0 ] && { echo OK; return; }
  # ROZJAZD ma pierwszeństwo: to najgroźniejsza klasa (#10) i nie wolno jej przykryć.
  printf '%s' "$out" | grep -qiE "$WZ_ROZJAZD"       && { echo ROZJAZD; return; }
  printf '%s' "$out" | grep -qiE "$WZ_POSWIADCZENIE" && { echo POSWIADCZENIE; return; }
  echo OFFLINE
}

wiek_min() {
  local last now
  last=$(git log -1 --format=%ct 2>/dev/null) || { echo -1; return; }
  [ -z "$last" ] && { echo -1; return; }
  now=$(date -u +%s)
  echo $(( (now - last) / 60 ))
}

case "${1:-}" in
  --klasa) klasa "${2:-}" "${3:-1}"; exit 0 ;;
  --wiek)  wiek_min; exit 0 ;;
esac

# ── TOR (#38: reguła bez toru obowiązuje tylko w dokumentacji) ──
# Sonda, której nie da się PRZEGRAĆ, nie jest sondą. Dlatego obok fikstur zdrowych
# stoi MUTACJA: wzorzec poświadczenia wykastrowany do niedopasowującego się —
# tor MUSI wtedy oblać. Inaczej mierzyłby własną kopię, nie ciało (klasa błędu #64).
if [ "${1:-}" = "--test" ]; then
  echo "╔═══ STRAŻ ŚWIEŻOŚCI — TOR ═══╗"
  bledy=0
  spr() { # opis | oczekiwane | wejście | rc
    local got; got=$(klasa "$3" "$4")
    if [ "$got" = "$2" ]; then printf "  ✓ %-42s → %s\n" "$1" "$got"
    else printf "  ✗ %-42s → %s (oczekiwane %s)\n" "$1" "$got" "$2"; bledy=$((bledy+1)); fi
  }
  spr "pull czysty (rc=0)"            OK             "Already up to date."                                        0
  spr "rozjazd historii"              ROZJAZD        "fatal: Not possible to fast-forward, aborting."             1
  spr "rozjazd (diverged)"            ROZJAZD        "Your branch and 'origin/x' have diverged"                   1
  spr "token zdjęty z remote"         POSWIADCZENIE  "fatal: could not read Username for 'https://github.com'"    1
  spr "token martwy / 403"            POSWIADCZENIE  "remote: HTTP Basic: Access denied"                          1
  spr "prompty wyłączone"             POSWIADCZENIE  "fatal: could not read Username: terminal prompts disabled"  1
  spr "brak sieci (zimny start)"      OFFLINE        "fatal: unable to access: Could not resolve host: github.com" 1
  spr "brak remote"                   OFFLINE        "fatal: 'origin' does not appear to be a git repository"     1

  # PIERWSZEŃSTWO: wejście niosące OBA sygnały musi wyjść jako ROZJAZD, nie POSWIADCZENIE.
  spr "oba sygnały → wygrywa ROZJAZD" ROZJAZD \
      "fatal: could not read Username ... Not possible to fast-forward"                                            1

  echo "── MUTACJA (wzorzec poświadczenia wykastrowany — tor MUSI oblać):"
  WZ_POSWIADCZENIE='__nigdy_nie_dopasuje__'
  m=$(klasa "fatal: could not read Username for 'https://github.com'" 1)
  if [ "$m" = "OFFLINE" ]; then
    echo "  ✓ mutacja wykryta: bez wzorca klasa spada do OFFLINE — tor mierzy ciało, nie kopię"
  else
    echo "  ✗ MUTACJA PRZESZŁA NIEZAUWAŻONA (dostałem $m) — tor jest ozdobą"; bledy=$((bledy+1))
  fi

  echo
  if [ "$bledy" -eq 0 ]; then echo "✓ STRAŻ ŻYWA: 9 fikstur + mutacja, 0 rozbieżności"; exit 0; fi
  echo "✗ STRAŻ MARTWA: $bledy rozbieżności"; exit 1
fi

echo "użycie: straz_swiezosci.sh --klasa \"<wyjście>\" <rc> | --wiek | --test"
exit 0
