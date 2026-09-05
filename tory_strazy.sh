#!/usr/bin/env bash
# ── BATERIA TORÓW STRAŻY (31.07.2026) — mechanizm do prawa #38 ──
# PRAWO #38: reguła dopisana bez dopisania toru obowiązuje TYLKO w dokumentacji.
# Audyt 31.07 rano objął trzy straże, które tor miały. Ten skrypt zamyka klasę:
# uruchamia `--test` KAŻDEJ straży i melduje jedną tabelą.
#
# Straż bez `--test` jest tu WIDOCZNA jako „BRAK TORU" — cisza nie może uchodzić
# za zdrowie (to ta sama choroba, tylko odwrócona: brak sygnału ≠ brak wady).
#
# UŻYCIE:
#   bash tory_strazy.sh          # rc=0 gdy każdy tor przeszedł
#   bash tory_strazy.sh --cicho  # tylko tabela i werdykt (do wstan.sh)
set -u
cd "$(dirname "$0")"

CICHO=0
[ "${1:-}" = "--cicho" ] && CICHO=1

# ── TOR TESTOWY SAMEJ BATERII ──
# Sonda, której nie da się PRZEGRAĆ, nie jest sondą (skill #2). Bateria, która zawsze
# mówi ✓, byłaby tą samą chorobą piętro wyżej — więc ma własny tor: karmimy ją listą
# z komendą, która MUSI oblać, i sprawdzamy, czy bateria to zgłosi.
if [ "${1:-}" = "--test" ]; then
  SAM="$(cd "$(dirname "$0")" && pwd)/$(basename "$0")"
  echo "╔═══ BATERIA TORÓW — AUTOTEST ═══╗"
  # atrapy MUSZĄ być prawdziwymi plikami — bateria sprawdza istnienie pliku straży,
  # więc atrapa „node --eval ..." wpadłaby w gałąź BRAK PLIKU i tor przeszedłby fałszywie
  # (zmierzone przy pierwszym biegu tego autotestu — sonda nie umiała przegrać).
  TT="$(mktemp -d)"
  printf '#!/usr/bin/env bash\nexit 0\n' > "$TT/atrapa_ok.sh"
  printf '#!/usr/bin/env bash\nexit 1\n' > "$TT/atrapa_zla.sh"
  rc_zdrowy=$(TORY_LISTA="prawda|bash $TT/atrapa_ok.sh --test"  bash "$SAM" --cicho >/dev/null 2>&1; echo $?)
  rc_chory=$( TORY_LISTA="falsz|bash $TT/atrapa_zla.sh --test"  bash "$SAM" --cicho >/dev/null 2>&1; echo $?)
  rc_brak=$(  TORY_LISTA="widmo|bash $TT/nie_ma.sh --test"      bash "$SAM" --cicho >/dev/null 2>&1; echo $?)
  rm -rf "$TT"
  echo "── TEST + (tor zdrowy):        rc=$rc_zdrowy (oczekiwane 0)"
  echo "── TEST − (tor oblany):        rc=$rc_chory (oczekiwane 1)"
  echo "── TEST ⊙ (straż bez pliku):   rc=$rc_brak (oczekiwane 0, ale widoczna jako BRAK)"
  echo
  if [ "$rc_zdrowy" -eq 0 ] && [ "$rc_chory" -eq 1 ]; then
    echo "✓ BATERIA ŻYWA: umie przegrać — oblany tor podnosi rc, nie ginie w tabeli."
    exit 0
  fi
  echo "✗ BATERIA MARTWA: zdrowy=$rc_zdrowy chory=$rc_chory"
  exit 1
fi

# nazwa | komenda toru
STRAZE="${TORY_LISTA:-
weryfikacja|node weryfikacja.js --test
lint_bledy|node narzedzia/linty/lint_bledy.js --test
lint_artefaktow|node narzedzia/linty/lint_artefaktow.js --test
lint_sciezek|node narzedzia/linty/lint_sciezek.js --test
lint_klas_znakow|node narzedzia/linty/lint_klas_znakow.js --test
straz_duszy|bash narzedzia/straze/straz_duszy.sh --test
straz_deklamatora|bash narzedzia/straze/straz_deklamatora.sh --test
straz_prerejestrow|bash narzedzia/straze/straz_prerejestrow.sh --test
hashuj|bash hashuj.sh --test
publikuj|bash publikuj.sh --test
zapis_git|bash zapis_git.sh --test
plan_okien|node narzedzia/silniki/plan_okien.js --test
rzut.js|node narzedzia/przyrzady/rzut.js --test
destyluj_ksiege|node narzedzia/przyrzady/destyluj_ksiege.js --test
wezownik|node narzedzia/silniki/wezownik.js --test
odduplikuj|node narzedzia/przyrzady/odduplikuj.js --test
ewaluacja|node narzedzia/przyrzady/ewaluacja.js --test
narodziny|bash narodziny.sh --test
straz_odlewu|bash narzedzia/straze/straz_odlewu.sh --test
testy_rdzen|node testy_rdzen.js --test
bateria_sond|node narzedzia/przyrzady/bateria_sond.js --test
licznik_markerow|node narzedzia/przyrzady/licznik_markerow.js --test
gotowosc|bash gotowosc.sh --test
mutacje|bash mutacje.sh --test
straz_r0|bash narzedzia/straze/straz_r0.sh --test
pokrycie_m|node narzedzia/przyrzady/pokrycie_m.js --test
straz_kryteriow|bash narzedzia/straze/straz_kryteriow.sh --test
prog_pytan|bash narzedzia/przyrzady/prog_pytan.sh --test
zniwo_destylatow|bash narzedzia/przyrzady/zniwo_destylatow.sh --test
anatomia|node narzedzia/przyrzady/anatomia.js --test
straz_mostow|bash narzedzia/straze/straz_mostow.sh --test
przed_cieciem|node narzedzia/przyrzady/przed_cieciem.js --test
inwentarz|node narzedzia/przyrzady/inwentarz.js --test
wywiad|node narzedzia/przyrzady/wywiad.js --test
homunculus|node narzedzia/przyrzady/homunculus.js --test
spis_ciala|node narzedzia/przyrzady/spis_ciala.js --test
spis_projektow|node narzedzia/przyrzady/spis_projektow.js --test
oko_tworcy|node narzedzia/przyrzady/oko_tworcy.js --test
crash_izolacja|bash narzedzia/przyrzady/crash_izolacja.sh --test
hook_pre_commit|bash narzedzia/straze/straz_hooka.sh
wstanie_rozjazd|bash narzedzia/straze/straz_wstania.sh
zamki_z_dowodem|bash narzedzia/straze/straz_zamkow.sh --test
straz_interpolacji|bash narzedzia/straze/straz_interpolacji.sh --test
straz_tropu|bash narzedzia/straze/straz_tropu.sh --test
straz_feromonow|bash narzedzia/straze/straz_feromonow.sh --test
straz_zalazkow|bash narzedzia/straze/straz_zalazkow.sh --test
straz_przyrzadu|bash narzedzia/straze/straz_przyrzadu.sh --test
straz_powtorzen|bash narzedzia/straze/straz_powtorzen.sh --test
straz_wywolan|bash narzedzia/straze/straz_wywolan.sh --test
zalazkuj|sh narzedzia/przyrzady/zalazkuj.sh --test
straz_zamkow|bash narzedzia/straze/straz_zamkow.sh --test
markery_z_ciala|bash narzedzia/straze/markery_z_ciala.sh --test
straz_czystosci|sh narzedzia/straze/straz_czystosci.sh --test
straz_hooka|bash narzedzia/straze/straz_hooka.sh --test
straz_wstania|bash narzedzia/straze/straz_wstania.sh --test
straz_zetonu|bash narzedzia/straze/straz_zetonu.sh --test
rzut|node narzedzia/przyrzady/rzut.js --test
straz_dojrzalosci|bash narzedzia/straze/straz_dojrzalosci.sh --test
straz_narodzin|bash narzedzia/straze/straz_narodzin.sh --test
straz_mianownika|bash narzedzia/straze/straz_mianownika.sh --test
straz_lintow|bash narzedzia/straze/straz_lintow.sh --test
straz_swiezosci|bash narzedzia/straze/straz_swiezosci.sh --test
straz_aktora|bash narzedzia/straze/straz_aktora.sh --test
tory_strazy|bash tory_strazy.sh --test
}"

ZDANE=0; OBLANE=0; BEZTORU=0
WYNIKI=""

while IFS= read -r wiersz; do
  [ -n "$wiersz" ] || continue
  nazwa="${wiersz%%|*}"; komenda="${wiersz#*|}"
  plik="$(echo "$komenda" | awk '{print $2}')"
  if [ ! -f "$plik" ]; then
    WYNIKI="$WYNIKI\n  ⓘ $nazwa — BRAK PLIKU ($plik)"
    BEZTORU=$((BEZTORU+1)); continue
  fi
  out="$($komenda 2>&1)"; rc=$?
  if [ "$rc" -eq 0 ]; then
    ZDANE=$((ZDANE+1)); WYNIKI="$WYNIKI\n  ✓ $nazwa — tor przeszedł"
  elif [ "$rc" -eq 2 ]; then
    BEZTORU=$((BEZTORU+1)); WYNIKI="$WYNIKI\n  ⓘ $nazwa — BRAK TORU albo tor niedostępny (rc=2)"
  else
    OBLANE=$((OBLANE+1))
    # DŁUG Z MOSTY DOMKNIĘTY (29.08.2026): do dziś bateria meldowała nazwę straży i rc,
    # ale NIE to, KTÓRY podtest oblał — `straz_zalazkow` świeciła dwa dni jako anonimowa
    # linijka, a diagnoza zajmowała osobne uruchomienie. Podtesty mają jeden kształt
    # w całym repo (`  ✗ <opis>`), więc da się je wyciąć bez zgadywania.
    _ktore="$(printf '%s\n' "$out" | grep -E '^[[:space:]]*✗ ' | grep -vE 'TOR OBLANY|STRAŻ MARTWA' \
              | sed 's/^[[:space:]]*✗ *//' | head -3 | awk 'NR>1{printf " · "}{printf "%s",$0}')"
    if [ -n "$_ktore" ]; then
      WYNIKI="$WYNIKI\n  ✗ $nazwa — TOR OBLANY (rc=$rc) · podtest: $_ktore"
    else
      WYNIKI="$WYNIKI\n  ✗ $nazwa — TOR OBLANY (rc=$rc) · podtestu nie nazwał (straż melduje zbiorczo)"
    fi
    [ "$CICHO" -eq 0 ] && WYNIKI="$WYNIKI\n$(echo "$out" | sed 's/^/      /' | tail -6)"
  fi
done <<EOF
$STRAZE
EOF

# ── ZAMEK POKRYCIA (21.08.2026) — czy LISTA pokrywa REPO ─────────────────────
# KLASA: LICZNIK ZGODNY MIMO NIEPEŁNEGO ZBIORU. Bateria meldowała „0 bez toru" i to
# była prawda — o jej własnej liście. Zmierzone 21.08: w repo leżały 14 plików straz_*.sh,
# na liście 10. Cztery przyrządy, wszystkie wołane przez `publikuj.sh`, były POZA ZASIĘGIEM
# pytania „czy umiesz nie przejść" — a bateria meldowała komplet.
# Rodzina #49 (tor na ALARM to nie tor na MIARĘ) · #52 (zielono nad zbiorem, który nie jest
# tym, o który pytamy) · kandydat M z 21.08 („licznik zgodny mimo kolizji"), tu w wariancie
# zbioru zamiast numeru. ZWOLNIENIE MUSI BYĆ JAWNE I Z POWODEM — cicha nieobecność na liście
# jest nieodróżnialna od przeoczenia, a to właśnie różnica, dla której ten zamek istnieje.
POZA_BATERIA=""   # DŁUG SPŁACONY 21.08: `straz_hooka` i `straz_wstania` dostały własne tory
# i weszły do baterii. Uzasadnienie zwolnienia („mierzą kontekst, w którym bateria biegnie",
# #50) okazało się ZA SZEROKIE — pytanie „czy umiem wykryć martwy hook / okrojone wstanie"
# da się zadać uczciwie na ATRAPIE w mktemp, bez dotykania żywego ciała (#54).
# Lista zostaje PUSTA, ale nie znika: zwolnienie musi mieć gdzie stać jawnie, gdy wróci.
# Zamek NIE biegnie, gdy bateria dostała listę z zewnątrz (TORY_LISTA): mierzy wtedy
# atrapy toru własnego, nie repo. Mieszanie dwóch wielkości w jednym rc to #49 —
# „czy umiem przegrać" i „czy lista pokrywa repo" to osobne pytania i osobne werdykty.
# ZAKRES ZAMKA ROZSZERZONY 21.08 — pierwsza wersja pytała wyłącznie o `straz_*.sh`.
# Zmierzone: `narzedzia/przyrzady/rzut.js` miał żywy tor (13/13), mutację i odcisk, a NIKT GO REGULARNIE
# NIE URUCHAMIAŁ — bo nie nazywa się „straz". Kryterium było NAZWĄ, a musi być ZACHOWANIEM:
# obsługuje flagę `--test`, więc deklaruje tor, więc podlega pytaniu „czy umiesz nie przejść".
# Ta sama korekta co w `narzedzia/straze/straz_narodzin.sh` godzinę wcześniej (wzmianka a obsługa) — kryterium
# oparte na nazwie pliku zawsze zostawia sierotę o innej nazwie.
BRAK_NA_LISCIE=""
if [ -z "${TORY_LISTA:-}" ]; then
for _p in *.sh *.js narzedzia/*/*.sh narzedzia/*/*.js; do   # dach narzedzia/ (29.08): zamek pokrycia widzi pokoje
  [ -f "$_p" ] || continue
  _f="$(basename "$_p")"   # klucz baterii = nazwa bazowa; plik czytany po ścieżce
  grep -qE -- '(\$\{1:-\}" = "--test"|"\$1" = "--test"|argv\.includes\('"'"'--test'"'"'\)|args\.includes\('"'"'--test'"'"'\))' "$_p" 2>/dev/null || continue
  case " $POZA_BATERIA " in *" $_f "*) continue ;; esac
  grep -q "^${_f%.*}|" "$0" || BRAK_NA_LISCIE="$BRAK_NA_LISCIE $_f"
done
for _p in straz_*.sh narzedzia/*/straz_*.sh; do
  [ -f "$_p" ] || continue
  _f="$(basename "$_p")"
  case " $POZA_BATERIA " in *" $_f "*) continue ;; esac
  grep -q "^${_f%.sh}|" "$0" || BRAK_NA_LISCIE="$BRAK_NA_LISCIE $_f"
done
fi

echo "╔═══ BATERIA TORÓW STRAŻY (#38) ═══╗"
printf '%b\n' "$WYNIKI"
echo "  zmierzone: zdanych $ZDANE · oblanych $OBLANE · bez toru $BEZTORU"
if [ -n "$BRAK_NA_LISCIE" ]; then
  echo "  ✗ POZA BATERIĄ (straż w repo, której lista nie zna):$BRAK_NA_LISCIE"
  echo "    Licznik wyżej jest zgodny z LISTĄ, nie z repo — dopisz do listy albo do"
  echo "    POZA_BATERIA z powodem. Cicha nieobecność = przeoczenie nie do odróżnienia."
  exit 1
fi
if [ "$OBLANE" -eq 0 ] && [ "$BEZTORU" -eq 0 ]; then
  echo "  ✓ KAŻDA STRAŻ MA ŻYWY TOR — żadna reguła nie obowiązuje wyłącznie w dokumentacji."
  exit 0
fi
if [ "$OBLANE" -gt 0 ]; then
  echo "  ✗ $OBLANE straż(y) oblało własny tor — napraw, zanim zaufasz ich werdyktom."
  exit 1
fi
echo "  ⚠ wszystkie uruchomione tory przeszły, ale $BEZTORU straż(y) toru nie ma (rc=2)."
exit 0
