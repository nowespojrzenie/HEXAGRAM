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

  # ── KAŻDA ALTERNATYWA WZORCA MA WŁASNĄ FIKSTURĘ (U7, 21.09.2026) ──
  # Zmierzone mutacją Fable (rzut 013): usunięcie „Authentication failed" ze wzorca przechodziło
  # na zielono, bo fikstury poświadczenia pokrywały trzy alternatywy z ośmiu — reszta wzorca
  # była ozdobą. Każda poniższa linia niesie DOKŁADNIE JEDNĄ alternatywę i żadnej sąsiedniej
  # (#49: fikstura oblewa z jednego powodu), więc zdjęcie którejkolwiek z nich oblewa tor.
  spr "rozjazd: non-fast-forward"     ROZJAZD        "! [rejected] main -> main (non-fast-forward)"               1
  spr "poświadczenie: brak hasła"     POSWIADCZENIE  "fatal: could not read Password for 'https://x@github.com'" 1
  spr "poświadczenie: Authentication" POSWIADCZENIE  "fatal: Authentication failed for 'https://github.com/x/y.git/'" 1
  spr "poświadczenie: zły login/hasło" POSWIADCZENIE "fatal: Invalid username or password."                       1
  spr "poświadczenie: repo nie znane" POSWIADCZENIE  "remote: Repository not found."                              1
  spr "poświadczenie: zły użytkownik" POSWIADCZENIE  "remote: Invalid username or token."                         1
  spr "poświadczenie: 403"            POSWIADCZENIE  "HTTP/1.1 403 Forbidden"                                      1
  spr "poświadczenie: klucz ssh"      POSWIADCZENIE  "git@github.com: Permission denied (publickey)."             1

  # PIERWSZEŃSTWO: wejście niosące OBA sygnały musi wyjść jako ROZJAZD, nie POSWIADCZENIE.
  spr "oba sygnały → wygrywa ROZJAZD" ROZJAZD \
      "fatal: could not read Username ... Not possible to fast-forward"                                            1

  # ── TOR `--wiek` (U7, 21.09.2026) ──
  # Funkcja, która drukuje „czytasz kanon sprzed X h", nie miała toru: dzielnik /60 → /3600
  # i „zawsze -1" przechodziły na zielono (rzut 013, mutacje Fable). Fikstura to mini-repo
  # w mktemp z commitem o ZNANYM wieku — mierzymy funkcję na ciele, którego wiek znamy,
  # nigdy na żywym HEAD (ten zmienia się z każdym commitem). Para +/−: repo → liczba,
  # katalog bez repo → -1 (brak pomiaru nazwany, nie zero).
  wiek_z() {  # $1 = wiek commitu w sekundach → drukuje ścieżkę fikstury
    local d t; d=$(mktemp -d); t=$(( $(date -u +%s) - $1 ))
    ( cd "$d" && git init -q . && git config user.name t && git config user.email t@t \
      && git config commit.gpgsign false && echo x > a && git add a \
      && GIT_AUTHOR_DATE="@$t +0000" GIT_COMMITTER_DATE="@$t +0000" git commit -q -m x ) >/dev/null 2>&1
    printf '%s' "$d"
  }
  WEK_A=$(wiek_z 7200); WEK_B=$(wiek_z 5430); WEK_PUSTY=$(mktemp -d)
  wa=$(cd "$WEK_A" && wiek_min); wb=$(cd "$WEK_B" && wiek_min); wp=$(cd "$WEK_PUSTY" && wiek_min)
  # okno [n, n+1]: fikstura powstała kilka sekund przed pomiarem, a dzielenie całkowite obcina
  wiek_ok() { [ "$1" -ge "$2" ] 2>/dev/null && [ "$1" -le "$(( $2 + 1 ))" ] 2>/dev/null; }
  if wiek_ok "$wa" 120; then printf "  ✓ %-42s → %s\n" "wiek: commit sprzed 2 h" "$wa min"
  else printf "  ✗ %-42s → %s (oczekiwane 120)\n" "wiek: commit sprzed 2 h" "$wa"; bledy=$((bledy+1)); fi
  if wiek_ok "$wb" 90; then printf "  ✓ %-42s → %s\n" "wiek: commit sprzed 90,5 min" "$wb min"
  else printf "  ✗ %-42s → %s (oczekiwane 90)\n" "wiek: commit sprzed 90,5 min" "$wb"; bledy=$((bledy+1)); fi
  if [ "$wp" = "-1" ]; then printf "  ✓ %-42s → %s\n" "wiek: katalog bez repo (brak pomiaru)" "$wp"
  else printf "  ✗ %-42s → %s (oczekiwane -1)\n" "wiek: katalog bez repo (brak pomiaru)" "$wp"; bledy=$((bledy+1)); fi
  # Ścieżka CLI (`--wiek`) — dyspozytor `case` też ma być osiągalny przez fasadę (#53).
  wc=$(bash "$0" --wiek 2>/dev/null)
  case "$wc" in ''|*[!0-9-]*) printf "  ✗ %-42s → '%s' (oczekiwana liczba)\n" "wiek: CLI --wiek drukuje liczbę" "$wc"; bledy=$((bledy+1)) ;;
                *) printf "  ✓ %-42s → %s\n" "wiek: CLI --wiek drukuje liczbę" "$wc" ;; esac
  rm -rf "$WEK_A" "$WEK_B" "$WEK_PUSTY"

  echo "── MUTACJA (wzorzec poświadczenia wykastrowany — tor MUSI oblać):"
  WZ_POSWIADCZENIE='__nigdy_nie_dopasuje__'
  m=$(klasa "fatal: could not read Username for 'https://github.com'" 1)
  if [ "$m" = "OFFLINE" ]; then
    echo "  ✓ mutacja wykryta: bez wzorca klasa spada do OFFLINE — tor mierzy ciało, nie kopię"
  else
    echo "  ✗ MUTACJA PRZESZŁA NIEZAUWAŻONA (dostałem $m) — tor jest ozdobą"; bledy=$((bledy+1))
  fi

  echo
  if [ "$bledy" -eq 0 ]; then echo "✓ STRAŻ ŻYWA: klasyfikacja (każda alternatywa wzorca) + wiek + mutacja, 0 rozbieżności"; exit 0; fi
  echo "✗ STRAŻ MARTWA: $bledy rozbieżności"; exit 1
fi

echo "użycie: straz_swiezosci.sh --klasa \"<wyjście>\" <rc> | --wiek | --test"
exit 0
