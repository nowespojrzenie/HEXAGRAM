#!/usr/bin/env bash
# ═══ mutacje.sh — CZY STRAŻE UMIEJĄ OBLAĆ NA PRAWDZIWYM BŁĘDZIE ═══
#
# RODOWÓD (13.08.2026, pytanie twórcy): „mamy mnóstwo strażników i wciąż błędy".
# Zmierzone: straże 2311 linii vs silniki 2711 · 18 straży w baterii · KOMPLET zielony —
# a trzy blizny tej samej doby przeszły przez wszystkie. `tory_strazy.sh` pyta
# „czy straż umie NIE przejść na SWOIM WŁASNYM torze". To za mało: tor bywa ślepy
# na tę samą klasę co ciało (blizna #49 i jej nawrót godzinę później — tor trzymał
# własną kopię listy i mierzył siebie).
#
# TEN PLIK PYTA INACZEJ: wstrzykuję PRAWDZIWY BŁĄD i sprawdzam, czy KTOKOLWIEK go złapie.
#
# PRAWO (ratyfikacja twórcy 13.08.2026 — piąte piętro inwariantu 5):
#   MECHANIZM BEZ MUTACJI = ŻYCZENIE O MECHANIZMIE.
#
# TO NIE JEST KOLEJNA STRAŻ — to przyrząd do WYCENY straży. Tor, który przechodzi
# mimo mutacji, jest dekoracją i wolno go USUNĄĆ. Narzędzie do zmniejszania systemu.
#
# UŻYCIE:  bash mutacje.sh          (pełny przebieg rejestru)
#          bash mutacje.sh --test   (tor własny — musi umieć NIE przejść)
set -uo pipefail
_SS="$(dirname "$0")/narzedzia/silniki/strefa_st.sh"; if [ -f "$_SS" ]; then . "$_SS"; else _STREFA_ST=Europe/Warsaw; fi   # strefa instancji (wspólny fragment strefa_st.sh → tz_pl.js: KRONOS_TZ > instancja.json > package.json); psuty instancja.json = „STREFA?" + komunikat, nie cichy powrót do Warszawy
# KATALOG PRACY: przechodzimy do repo TYLKO gdy rejestr nie został wskazany z zewnątrz.
# Tor własny uruchamia skrypt na atrapie w mktemp — `cd` zjadłby mu ścieżkę rejestru.
# (Złapane własnym torem w minucie narodzin: przyrząd nie jest świadkiem własnej poprawności.)
if [ -z "${REJESTR:-}" ]; then cd "$(dirname "$0")"; REJESTR="mutacje.txt"; fi
# R3b (05.10.2026, seria R): REJESTR jest zmienną TEGO przyrządu, nie otoczenia świadków. Podana z zewnątrz
# (`REJESTR=podzbior bash mutacje.sh` — tak dobiega się resztę po ubitym biegu) była eksportowana i szła do każdej
# KOMENDY_TORU. Zmierzone: `straz_feromonow.sh --test` czyta zmienną o tej samej nazwie jako plik kartek — z nią
# w otoczeniu oblewa 19 z 49 podtestów na ZDROWYM ciele i dopisuje wpisy do wskazanego pliku, więc każda mutacja
# feromonów w biegu na podzbiorze meldowała się „ZŁAPANA” bez pomiaru (preflight świadka działa tylko dla mutacje.txt).
# Zdejmujemy atrybut eksportu; wartość zostaje dla skryptu. Tor: „rejestr nie przecieka do świadka”.
export -n REJESTR
# R4b (05.10.2026): ta sama klasa, zmierzona w pierwszym żywym biegu R4 — MUTACJE_POSTEP/MUTACJE_WZNOW szły z otoczenia
# do świadków, a świadkowie wołający ten przyrząd na fiksturach (`mutacje.sh --test`, `gotowosc.sh --test`) nadpisali
# zapis postępu biegu zewnętrznego swoim (nagłówek „HEAD=brak”, 22 linie zamiast ~120). Wartości bierzemy do zmiennych
# własnych i zdejmujemy z otoczenia, zanim ruszy cokolwiek, co może zawołać ten plik ponownie.
_MUT_POSTEP="${MUTACJE_POSTEP:-}"; _MUT_WZNOW="${MUTACJE_WZNOW:-0}"
unset MUTACJE_POSTEP MUTACJE_WZNOW

# ── ŚCIEŻKA WSTECZNA: cokolwiek się stanie, pliki wracają bajt w bajt NA SWOJE MIEJSCE ──
# BLIZNA 21.08.2026: zapas nazywany był `basename`, więc plik mutowany z PODKATALOGU
# wracał do KORZENIA jako sierota (tak urodziła się kopia `pre-commit` obok
# `.githooks/pre-commit`). Klucz zapasu koduje teraz PEŁNĄ ścieżkę: `/` → `%`.
ZAPAS="$(mktemp -d)"
klucz() { printf '%s' "$1" | tr '/' '%'; }
# ── ŚCIEŻKA WSTECZNA Z PONOWIENIAMI (03.09.2026, słowo twórcy) ──
# Montaż zwracał `cp: Invalid argument` PRZEJŚCIOWO (40 cp pod rząd przechodziło zaraz po
# awarii), a jedna próba mierzy chwilę, nie środowisko. Trzy próby z sekundą pauzy; rc ostatniej.
cp3() {
  local _p
  for _p in 1 2 3; do
    cp "$1" "$2" 2>/dev/null && return 0
    sleep 0.5
  done
  cp "$1" "$2"   # czwarta, JAWNA — jej komunikat idzie na stderr, jej rc wraca
}
# J (07.10.2026, biurko v1.8.1): cofnięcie JEDNEJ mutacji zdejmuje też jej wpis z zapasu. Zapas trwały (niżej) trzyma wtedy
# wyłącznie plik, który jest AKTUALNIE zmutowany — odzysk po ubitym biegu nie nadpisze legalnych zmian w plikach, które
# poprzedni bieg zdążył już cofnąć. Gdy cp3 padnie, wpis ZOSTAJE (końcowy `przywroc` ponowi próbę).
# B4 (08.10.2026, U1-10): obok kopii (`<klucz>`) zapas trzyma odcisk pliku PO mutacji (`<klucz>.odcisk`). Odzysk po ubitym biegu przywraca plik TYLKO wtedy,
# gdy jest on dokładnie tym, co zostawiła mutacja; plik równy kopii wymaga tylko zdjęcia wpisu; każdy inny stan to zmiana legalna (ręka przywróciła plik i dopisała
# linię, jak radzi komunikat rc=13) i NIE jest nadpisywany. Dawniej odzysk kopiował kopię na plik bez pytania i kasował dopisaną linię.
_odcisk() { if command -v sha256sum >/dev/null 2>&1; then sha256sum < "$1" | cut -d' ' -f1; else cksum < "$1" | tr ' ' '_'; fi; }
cofnij() { cp3 "$ZAPAS/$(klucz "$1")" "$1" && rm -f "$ZAPAS/$(klucz "$1")" "$ZAPAS/$(klucz "$1").odcisk"; }
przywroc() {
  for k in "$ZAPAS"/*; do
    [ -e "$k" ] || continue
    case "$k" in *.odcisk) continue ;; esac
    cel="$(printf '%s' "$(basename "$k")" | tr '%' '/')"
    mkdir -p "$(dirname "./$cel")" 2>/dev/null || true
    cp3 "$k" "./$cel" || echo "  ✗ ŚCIEŻKA WSTECZNA: $cel NIE WRÓCIŁ z zapasu (cp ×4 padło)" >&2
  done
  rm -rf "$ZAPAS" "${KESZ_SWIADKOW:-}"
  # ── ZAMEK BIEGU (#112) — sprzątanie DOPISANE do TEGO SAMEGO trapu, nie osobnym `trap ...` ──
  # bash NIE ŁĄCZY wielu `trap SYG` — druga rejestracja NADPISAŁABY tę wyżej i ŚCIEŻKA WSTECZNA
  # przestałaby działać przy SIGKILL/SIGTERM. `$ZAMEK_BIEGU` jest ustawiany PÓŹNIEJ w pliku
  # (tylko w biegu produkcyjnym, nie w `--test`, nie przy wczesnym `exit 2` na braku rejestru)
  # — stąd strażnik `${ZAMEK_BIEGU:-}` pod `set -u`, żeby wcześniejsze wyjścia nie padały.
  [ -n "${ZAMEK_BIEGU:-}" ] && [ -f "$ZAMEK_BIEGU" ] && rm -f "$ZAMEK_BIEGU" 2>/dev/null
}
trap przywroc EXIT INT TERM

# ── TOR WŁASNY (#38): ten przyrząd też nie jest świadkiem własnej poprawności ──
if [ "${1:-}" = "--test" ]; then
  echo "╔═══ MUTACJE — AUTOTEST (#38) ═══╗"
  # Tor własny pracuje WYŁĄCZNIE na atrapie w mktemp, więc zamek rekurencji go nie
  # dotyczy — ale znacznik odziedziczony z zewnątrz (np. gdy autotest jest komendą
  # toru innej mutacji) kazałby jego własnym podbiegom odmówić i tor oblałby
  # z fałszywego powodu. Czyścimy jawnie; tor (⊙⊙) ustawia go z powrotem punktowo.
  unset MUTACJE_W_BIEGU
  zle=""
  niemierzalne=""   # przypadki, których FIKSTURA nie startuje na tej platformie (znacznik `?`, blizna #84)
  T="$(mktemp -d)"
  printf 'const x=1;\nif(x!==1) process.exit(1);\n' > "$T/ofiara.js"
  printf 'atrapa|||ofiara.js|||const x=1;|||const x=2;|||node ofiara.js\n' > "$T/rej.txt"
  # (+) mutacja, którą tor MUSI złapać → skrypt kończy rc=0 (wszystko wykryte)
  ( cd "$T" && REJESTR=rej.txt bash "$OLDPWD/mutacje.sh" >/dev/null 2>&1 )
  [ $? -eq 0 ] || zle="$zle wykryta-mutacja-raportowana-jako-porazka"
  # (−) mutacja NIEWYKRYWALNA → skrypt MUSI zgłosić rc=1 (straż ślepa)
  printf 'const x=1;\nprocess.exit(0);\n' > "$T/ofiara.js"
  ( cd "$T" && REJESTR=rej.txt bash "$OLDPWD/mutacje.sh" >/dev/null 2>&1 )
  [ $? -ne 0 ] || zle="$zle slepa-straz-przeszla-jako-zdrowa"
  # (⊙) ŚCIEŻKA WSTECZNA: plik po przebiegu identyczny co do bajta
  SUMA_PRZED=$(sha256sum "$T/ofiara.js" | cut -c1-16)
  ( cd "$T" && REJESTR=rej.txt bash "$OLDPWD/mutacje.sh" >/dev/null 2>&1 )
  SUMA_PO=$(sha256sum "$T/ofiara.js" | cut -c1-16)
  [ "$SUMA_PRZED" = "$SUMA_PO" ] || zle="$zle mutacja-nie-cofnieta($SUMA_PRZED/$SUMA_PO)"
  # (⊙⊙) ZAMEK NA REKURENCJĘ: bieg zagnieżdżony MUSI odmówić (rc=4) i NIE tknąć materii.
  # Fikstura celowo taka sama jak wyżej — dowód jest w rc UNIKALNYM dla odmowy (4),
  # nieosiągalnym ani przy wykryciu (0), ani przy ślepocie (1). Usunięcie zamka
  # przestawia rc na 0/1 i tor oblewa (mutacja `mutacje-zamek-rekurencji-zdjety`).
  # 18.09.2026: flaga niesie TOŻSAMOŚĆ ciała, nie `1`. Stary tor ustawiał `=1` i mierzył
  # sam widok flagi — dokładnie predykat, który 13.09 okazał się wadliwy. Tu (⊙⊙) ta sama
  # tożsamość → MUSI odmówić; (+) obca tożsamość (fikstura w innym katalogu) → MUSI ruszyć.
  TOZ_T=$(cd "$T" && stat -c '%d:%i' .)
  TOZ_OBCA=$(stat -c '%d:%i' "$(dirname "$T")")
  SUMA_Z_PRZED=$(sha256sum "$T/ofiara.js" | cut -c1-16)
  ( cd "$T" && MUTACJE_W_BIEGU="$TOZ_T" REJESTR=rej.txt bash "$OLDPWD/mutacje.sh" >/dev/null 2>&1 )
  RC_Z=$?
  SUMA_Z_PO=$(sha256sum "$T/ofiara.js" | cut -c1-16)
  [ "$RC_Z" -eq 4 ] || zle="$zle zagniezdzony-bieg-wystartowal(rc=$RC_Z)"
  [ "$SUMA_Z_PRZED" = "$SUMA_Z_PO" ] || zle="$zle zagniezdzony-tknal-materie"
  ( cd "$T" && MUTACJE_W_BIEGU="$TOZ_OBCA" REJESTR=rej.txt bash "$OLDPWD/mutacje.sh" >/dev/null 2>&1 )
  RC_O=$?
  [ "$RC_O" -ne 4 ] || zle="$zle obca-tozsamosc-zablokowana(zamek-po-obecnosci)"
  [ "$SUMA_Z_PRZED" = "$(sha256sum "$T/ofiara.js" | cut -c1-16)" ] || zle="$zle bieg-pod-obca-flaga-nie-cofnal"

  # ── ZAMEK BIEGU (#112) — RÓŻNE zjawisko niż zamek rekurencji wyżej: ślad NA DYSKU między
  # NIEZALEŻNYMI wywołaniami, nie tożsamość katalogu w JEDNYM zagnieżdżonym biegu. (−) zamek
  # ŻYWY (PID realnie działający — $$ tego toru) MUSI odmówić start (rc=11), NIE tknąć materii.
  # (+) zamek OSIEROCONY (PID gwarantowanie martwy — proces odpalony i zebrany `wait`) MUSI
  # OSTRZEC, ale POZWOLIĆ ruszyć (rc jak zdrowy bieg, nie 11) — jedna awaria nie blokuje trwale.
  # RESET MATERII: `ofiara.js` niesie w tym miejscu SLEPA wersję (l.78, ostatnia zmiana przed
  # tym blokiem) — moje testy potrzebują ZDROWEGO, wykrywalnego rejestru, żeby "osierocony"
  # naprawdę doszedł do (+) rc=0, a nie mylił "zamek zadziałał" z "materiał był ślepy".
  printf 'const x=1;\nif(x!==1) process.exit(1);\n' > "$T/ofiara.js"
  sh -c 'exit 0' & DEADPID=$!; wait "$DEADPID" 2>/dev/null
  SUMA_ZB_PRZED=$(sha256sum "$T/ofiara.js" | cut -c1-16)
  printf '%s:2026-01-01T00:00:00Z' "$$" > "$T/.mutacje_lock"
  OUT_ZB_ZYW="$(cd "$T" && REJESTR=rej.txt bash "$OLDPWD/mutacje.sh" 2>&1)"; RC_ZB_ZYW=$?
  [ "$RC_ZB_ZYW" -eq 11 ] || zle="$zle zamek-biegu-zywy-nie-odmowil(rc=$RC_ZB_ZYW)"
  case "$OUT_ZB_ZYW" in *"ODMOWA STARTU — bieg mutacyjny już trwa"*"PID $$"*) ;; *) zle="$zle zamek-biegu-zywy-bez-nazwy-pid" ;; esac
  [ "$SUMA_ZB_PRZED" = "$(sha256sum "$T/ofiara.js" | cut -c1-16)" ] || zle="$zle zamek-biegu-zywy-tknal-materie"
  printf '%s:2026-01-01T00:00:00Z' "$DEADPID" > "$T/.mutacje_lock"
  OUT_ZB_OS="$(cd "$T" && REJESTR=rej.txt bash "$OLDPWD/mutacje.sh" 2>&1)"; RC_ZB_OS=$?
  [ "$RC_ZB_OS" -eq 0 ] || zle="$zle zamek-biegu-osierocony-zablokowal(rc=$RC_ZB_OS)"
  case "$OUT_ZB_OS" in *"ZAMEK OSIEROCONY"*"PID $DEADPID"*) ;; *) zle="$zle zamek-biegu-osierocony-bez-ostrzezenia" ;; esac
  [ -f "$T/.mutacje_lock" ] && zle="$zle zamek-biegu-nie-posprzatany-po-biegu"
  printf 'const x=1;\nif(x!==1) process.exit(1);\n' > "$T/ofiara.js"   # przywróć materiał do stanu (+) na następne tory
  # (⊙⊙⊙⊙) ŚCIEŻKA WSTECZNA NIE GUBI KATALOGU — blizna 21.08.2026.
  # `przywroc()` (trap EXIT) kopiowała zapasy do `./$(basename)`, więc plik mutowany
  # z PODKATALOGU wracał do KORZENIA jako sierota bajt w bajt. Tak urodziła się kopia
  # `pre-commit` obok `.githooks/pre-commit` — przez tydzień brana za ślad „dwóch rąk".
  # Tor MUSI oblać na starym kodzie: po przebiegu w korzeniu atrapy nie wolno zastać
  # pliku o nazwie bazowej mutowanego pliku z podkatalogu.
  mkdir -p "$T/pod"
  printf 'const y=1;\nif(y!==1) process.exit(1);\n' > "$T/pod/ofiara2.js"
  printf 'atrapa2|||pod/ofiara2.js|||const y=1;|||const y=2;|||node pod/ofiara2.js\n' > "$T/rej2.txt"
  ( cd "$T" && REJESTR=rej2.txt bash "$OLDPWD/mutacje.sh" >/dev/null 2>&1 )
  [ -f "$T/ofiara2.js" ] && zle="$zle sciezka-wsteczna-gubi-katalog(sierota-w-korzeniu)"
  [ -f "$T/pod/ofiara2.js" ] || zle="$zle sciezka-wsteczna-nie-oddala-oryginalu"


  # Tor (⊙⊙) ustawia MUTACJE_W_BIEGU sam, więc sprawdza ZAMEK, a nie DROGĘ, którą
  # znacznik ma do zamka dotrzeć. Mutacja `mutacje-znacznik-nie-schodzi-w-dol`
  # (zdjęcie prefiksu przed `eval`) przechodziła przez komplet zielony — zamek stał,
  # tylko nikt go nie zawiadamiał. Sonda mierzy to WPROST: komenda toru zapisuje
  # wartość zmiennej, jaką REALNIE zobaczyła. Zero rekurencji — sonda nie woła mutatora.
  printf '#!/usr/bin/env bash\nprintf "%%s" "${MUTACJE_W_BIEGU:-BRAK}" > znacznik.txt\nexit 1\n' > "$T/sonda.sh"
  printf 'sonda|||ofiara.js|||const x=1;|||const x=2;|||bash sonda.sh\n' > "$T/rej2.txt"
  rm -f "$T/znacznik.txt"
  ( cd "$T" && REJESTR=rej2.txt bash "$OLDPWD/mutacje.sh" >/dev/null 2>&1 )
  WIDZIANY=$(cat "$T/znacznik.txt" 2>/dev/null || echo BRAK-PLIKU)
  [ "$WIDZIANY" = "$TOZ_T" ] || zle="$zle znacznik-nie-doszedl-do-komendy($WIDZIANY!=$TOZ_T)"
  # (⊗) ZAMEK NA CISZĘ — DWUSTRONNIE. Tor jednostronny by tu nie wystarczył:
  # sama strona (−) przeszłaby też wtedy, gdyby poprawka wyciszała ZDROWY przebieg,
  # a tego nikt by nie zauważył (blizna: „tor jednostronny to połowa asercji").
  # (−) rejestr, w którym NIC nie da się wstrzyknąć (plik-ofiara nie istnieje) →
  #     0 złapanych, 0 ślepych, wszystko pominięte → MUSI dać rc=5, nigdy 0.
  printf 'widmo|||niema.js|||const q=1;|||const q=2;|||node niema.js\n' > "$T/rej3.txt"
  ( cd "$T" && REJESTR=rej3.txt bash "$OLDPWD/mutacje.sh" >/dev/null 2>&1 )
  RC_CISZA=$?
  [ "$RC_CISZA" -eq 5 ] || zle="$zle cisza-zameldowana-jako-sukces(rc=$RC_CISZA)"
  # (+) strona przeciwna: rejestr z JEDNĄ mutacją wykrywalną → MUSI dać rc=0.
  #     Bez tej asercji zamek mógłby oblewać zdrowy bieg i tor by milczał.
  printf 'const x=1;\nif(x!==1) process.exit(1);\n' > "$T/ofiara.js"
  ( cd "$T" && REJESTR=rej.txt bash "$OLDPWD/mutacje.sh" >/dev/null 2>&1 )
  RC_ZDROWY=$?
  [ "$RC_ZDROWY" -eq 0 ] || zle="$zle zamek-ciszy-oblewa-zdrowy-bieg(rc=$RC_ZDROWY)"
  # NAGROBEK: cztery tory preflightu python3 (zaślepka/brak/zwolnienie-platformy/żywy)
  # zdjęte 21.09.2026 razem z zależnością, którą mierzyły — patrz nagrobek przy właściwym
  # preflightcie niżej w pliku i `git log -- mutacje.sh` sprzed tego commitu dla treści.
  # (⊛⊛) SONDA ŚCIEŻKI WSTECZNEJ (03.09.2026, słowo twórcy: „Działaj") — TRZY STRONY.
  # Rodowód: montaż Cowork zwracał `cp: Invalid argument` w połowie biegu i przerwany bieg
  # zostawił ZMUTOWANY plik w żywym drzewie pięć razy jednego dnia (crash_izolacja.sh ×2,
  # straz_mostow.sh, BLEDY.md, tz_pl.js, mutacje.sh). `trap przywroc EXIT` był bezradny, bo
  # padało samo `cp`, którym przywraca. Preflight T1 pyta „czy umiem wstrzyknąć" — ta sonda
  # pyta „czy umiem COFNĄĆ". Asymetria kosztów rozstrzyga o ZATRZYMANIU: fałszywe zatrzymanie
  # = powtórzona tura; fałszywa cisza = mutacja w `git add -A` następnego pushu (blizna #54, 13.08).
  # (−) zapis do katalogu pracy pada → rc=7 PRZED pierwszą mutacją, słowo PREFLIGHT + WSTECZNA
  # NAPRAWA 04.09.2026 (dług środowiskowy 63/1, zlecenie twórcy „napraw bramkę"): fikstura
  # odbierała prawo zapisu przez `chmod 555` na katalogu — a to ZAŁOŻENIE O ŚRODOWISKU, nie
  # pomiar właściwości. Pod uid 0 (kontener, CI, sandbox) chmod nie odbiera nic: zmierzone
  # `id -u`=0 → zapis do katalogu 555 UDAJE SIĘ, więc preflight nie miał czego złapać i tor
  # meldował MARTWĄ SONDĘ tam, gdzie sonda była żywa, a nieprzystawalna była FIKSTURA.
  # Teraz fikstura mierzy tę samą właściwość mechanizmem niezależnym od uid: atrapa `cp`
  # w PATH pada ZAWSZE (zasłona PATH wyłącznie w atrapie — #54, nigdy na żywym ciele).
  mkdir -p "$T/ro" "$T/cpstop" && printf 'const r=1;\n' > "$T/ro/ofiara.js" \
    && printf 'atrapa|||ofiara.js|||const r=1;|||const r=2;|||node ofiara.js\n' > "$T/ro/rej.txt"
  printf '#!/usr/bin/env bash\necho "cp: atrapa: kazda kopia pada" >&2\nexit 1\n' > "$T/cpstop/cp"
  chmod +x "$T/cpstop/cp"
  OUT_RO="$(cd "$T/ro" && PATH="$T/cpstop:$PATH" REJESTR=rej.txt bash "$OLDPWD/mutacje.sh" 2>&1)"; RC_RO=$?
  [ "$RC_RO" -eq 7 ] || zle="$zle sonda-wsteczna-nie-zatrzymala(rc=$RC_RO)"
  case "$OUT_RO" in *PREFLIGHT*WSTECZN*) ;; *) zle="$zle sonda-wsteczna-bez-nazwy-przyczyny" ;; esac
  case "$OUT_RO" in *ZŁAPANA*|*ŚLEPA*) zle="$zle sonda-wsteczna-po-pierwszej-mutacji" ;; esac
  # (⊙) awaria PRZEJŚCIOWA: atrapa `cp` w PATH pada za PIERWSZYM razem, potem deleguje do
  #     prawdziwego cp → ponowienie MUSI uratować bieg (rc=0, zero słowa PREFLIGHT).
  #     Zasłona PATH wyłącznie w atrapie (#54). Bez tej strony ponowienia byłyby życzeniem.
  mkdir -p "$T/cpbin"
  printf '#!/usr/bin/env bash\nL="$(dirname "$0")/licznik"\nn=$(cat "$L" 2>/dev/null || echo 0)\necho $((n+1)) > "$L"\nif [ "$n" -eq 0 ]; then echo "cp: atrapa: pierwsza proba pada" >&2; exit 1; fi\nexec %s "$@"\n' "$(command -v cp)" > "$T/cpbin/cp"
  chmod +x "$T/cpbin/cp"; rm -f "$T/cpbin/licznik"
  printf 'const x=1;\nif(x!==1) process.exit(1);\n' > "$T/ofiara.js"
  OUT_TR="$(cd "$T" && PATH="$T/cpbin:$PATH" REJESTR=rej.txt bash "$OLDPWD/mutacje.sh" 2>&1)"; RC_TR=$?
  [ "$RC_TR" -eq 0 ] || zle="$zle ponowienie-nie-ratuje-przejsciowej-awarii(rc=$RC_TR)"
  case "$OUT_TR" in *PREFLIGHT*) zle="$zle przejsciowa-awaria-zatrzymala-bieg" ;; esac
  [ "$(cat "$T/cpbin/licznik" 2>/dev/null || echo 0)" -ge 2 ] || zle="$zle cp-wolany-tylko-raz"
  # (⊗) CIAŁO NIE WRÓCIŁO: przywrócenie z ZAPAS pada PO wstrzykniętej mutacji; kontrola PO
  #     pętli MUSI nazwać plik imiennie i dać rc=8, nie ciszę. Fikstura w repo git (kontrola
  #     czyta `git status --porcelain`).
  #     NAPRAWA 04.09.2026 (ta sama klasa co strona (−)): niepowrót wymuszał `chmod 444` na
  #     ofierze — pod uid 0 cp nadpisuje plik 444 bez mrugnięcia, ciało wracało i tor meldował
  #     ciszę tam, gdzie kontroli nie było czego pokazać. Teraz atrapa `cp` pada WYŁĄCZNIE gdy
  #     celem jest ofiara w drzewie pracy (ścieżka względna): zapas do /tmp i sonda preflightu
  #     przechodzą, przywrócenie pada — dokładnie ta właściwość, bez oglądania się na uid.
  mkdir -p "$T/g" "$T/cpofiara" && ( cd "$T/g" && git init -q && printf 'const q=1;\n' > ofiara.js \
    && printf 'zamek|||ofiara.js|||const q=1;|||const q=2;|||false\n' > rej.txt \
    && git add -A && git -c user.name=T -c user.email=t@t commit -qm start )
  printf '#!/usr/bin/env bash\nfor a; do _cel="$a"; done\ncase "$_cel" in ofiara.js|./ofiara.js) echo "cp: atrapa: przywrocenie do drzewa pracy pada" >&2; exit 1 ;; esac\nexec %s "$@"\n' "$(command -v cp)" > "$T/cpofiara/cp"
  chmod +x "$T/cpofiara/cp"
  OUT_NW="$(cd "$T/g" && PATH="$T/cpofiara:$PATH" REJESTR=rej.txt bash "$OLDPWD/mutacje.sh" 2>&1)"; RC_NW=$?
  [ "$RC_NW" -eq 8 ] || zle="$zle cialo-nie-wrocilo-a-bieg-milczy(rc=$RC_NW)"
  case "$OUT_NW" in *ofiara.js*NIE*WRÓCI*|*NIE*WRÓCI*ofiara.js*) ;; *) zle="$zle cialo-nie-wrocilo-bez-imienia-pliku" ;; esac
  rm -rf "$T"

  # ═══ ROZDZIELENIE KODÓW WYJŚCIA MUTATORA (09.09.2026) — TRZY TORY WZAJEMNIE IZOLOWANE ═══
  # Blizna tej sesji (#84 sąsiedztwo): trzy człony pod jednym kodem wyjścia sprawiają, że
  # mutacja jednego z nich jest niewidzialna. Każdy przypadek niżej ma WŁASNĄ, niezależną
  # fikstury i WŁASNĄ asercję rc + WŁASNĄ asercję podłańcucha przyczyny.
  T3="$(mktemp -d)"
  # (−) AWARIA MUTATORA NIE JEST POMINIĘCIEM (zaadaptowane na node 21.09.2026 — atrapa
  # celuje teraz w $MUTATOR_NODE, nie w PATH, więc nie zasłania prawdziwego `node`, którego
  # reszta pliku używa do uruchamiania KOMEND w tym samym biegu). Atrapa mutatora zwraca
  # rc=4 — kod inny niż 0 (sukces) i 3 (wzorzec). Bieg MUSI dać NOWY kod wyjścia (rc=9),
  # wydrukować słowo AWARIA, i NIE wpaść cicho do POMINIĘTA.
  mkdir -p "$T3/awaria_bin"
  printf '#!/usr/bin/env bash\nexit 4\n' > "$T3/awaria_bin/zly_mutator"
  chmod +x "$T3/awaria_bin/zly_mutator"
  printf 'const a=1;\n' > "$T3/ofiara_a.js"
  printf 'awaria|||ofiara_a.js|||const a=1;|||const a=2;|||true\n' > "$T3/rej_a.txt"
  OUT_AW="$(cd "$T3" && MUTATOR_NODE="$T3/awaria_bin/zly_mutator" REJESTR=rej_a.txt bash "$OLDPWD/mutacje.sh" 2>&1)"; RC_AW=$?
  [ "$RC_AW" -eq 9 ] || zle="$zle awaria-mutatora-zly-kod(rc=$RC_AW)"
  case "$OUT_AW" in *AWARIA*) ;; *) zle="$zle awaria-mutatora-bez-slowa-awaria" ;; esac
  case "$OUT_AW" in *POMINIĘTA*) zle="$zle awaria-mutatora-wpadla-do-pominietej" ;; esac
  # (−) KOD 3 NADAL JEST POMINIĘCIEM: wzorzec nie występuje w pliku dokładnie raz (0 razy) —
  # żywy mutator, rc mutatora naturalnie = 3. Bieg zachowuje się jak dotąd: POMINIĘTA,
  # rc biegu BEZ ZMIAN (jedyna pozycja rejestru jest niemutowalna → zamek ciszy, rc=5),
  # a słowo AWARIA nie może się pojawić.
  printf 'const b=1;\n' > "$T3/ofiara_b.js"
  printf 'wzorzec|||ofiara_b.js|||NIE_MA_TAKIEGO_CIAGU|||cokolwiek|||true\n' > "$T3/rej_b.txt"
  OUT_WZ="$(cd "$T3" && REJESTR=rej_b.txt bash "$OLDPWD/mutacje.sh" 2>&1)"; RC_WZ=$?
  [ "$RC_WZ" -eq 5 ] || zle="$zle kod3-nadal-pominieta-zmienil-rc(rc=$RC_WZ)"
  case "$OUT_WZ" in *POMINIĘTA*) ;; *) zle="$zle kod3-nie-zaraportowany-jako-pominieta" ;; esac
  case "$OUT_WZ" in *AWARIA*) zle="$zle kod3-falszywie-oznaczony-jako-awaria" ;; esac
  # (⊙) ZERO AWARII MELDUJE SIĘ WŁASNYM ZDANIEM: bieg zdrowy (jedna mutacja wykrywalna,
  # żywy mutator) MUSI wypisać jawne „AWARII mutatora: 0", nie milczeć o nieobecności.
  printf 'const c=1;\nif(c!==1) process.exit(1);\n' > "$T3/ofiara_c.js"
  printf 'zdrowa|||ofiara_c.js|||const c=1;|||const c=2;|||node ofiara_c.js\n' > "$T3/rej_c.txt"
  OUT_ZERO="$(cd "$T3" && REJESTR=rej_c.txt bash "$OLDPWD/mutacje.sh" 2>&1)"; RC_ZERO=$?
  [ "$RC_ZERO" -eq 0 ] || zle="$zle zero-awarii-bieg-nie-zdrowy(rc=$RC_ZERO)"
  case "$OUT_ZERO" in *"AWARII mutatora: 0"*) ;; *) zle="$zle zero-awarii-nie-zameldowane-wlasnym-zdaniem" ;; esac
  rm -rf "$T3"

  # Znacznik `?` melduje się ZAWSZE i GŁOŚNO — po obu stronach werdyktu. Nieobecność pomiaru
  # przemilczana byłaby ciszą podaną jako zdrowie (#39), czyli dokładnie tym, czego ten
  # przyrząd pilnuje u innych.
  # ── PARA TORÓW: POZA ODLEWEM ≠ POMINIĘTA (13.09.2026) ─────────────────────────────
  # Ścieżka aktywna TYLKO dla rejestru nazwanego `mutacje.txt` (granica preflightu), więc
  # fikstura musi go tak nazwać i dostarczyć własną atrapę `publikuj.sh --lista MAIN`.
  # Dwustronnie (#75): plik NA liście ma być mierzony normalnie, plik POZA listą ma dostać
  # WŁASNE słowo — samo „nie oblało" dowodziłoby tylko, że coś przeszło, nie ŻE ROZRÓŻNIA.
  TO="$(mktemp -d)"
  printf 'const x=1;\nif(x!==1) process.exit(1);\n' > "$TO/jedzie.js"
  printf 'const y=1;\nif(y!==1) process.exit(1);\n' > "$TO/niejedzie.js"
  { echo '#!/bin/sh'; echo '[ "$1" = "--lista" ] && [ "$2" = "MAIN" ] && echo jedzie.js'; echo 'exit 0'; } > "$TO/publikuj.sh"
  printf 'na-liscie|||jedzie.js|||const x=1;|||const x=2;|||node jedzie.js\npoza-lista|||niejedzie.js|||const y=1;|||const y=2;|||node niejedzie.js\n' > "$TO/mutacje.txt"
  # (+) GAŁĄŹ PRACY: plik spoza listy JEST na dysku — MUSI być mierzony normalnie.
  # To jest tor, którego brak kosztował mnie cichą utratę sześciu pozycji: pytanie
  # o samą listę wycinało je także tam, gdzie materiał istniał i był mierzalny.
  OUT_OD="$(cd "$TO" && REJESTR=mutacje.txt bash "$OLDPWD/mutacje.sh" 2>&1)"; RC_OD=$?
  case "$OUT_OD" in *"✓ ZŁAPANA    na-liscie"*) ;; *) zle="$zle odlew-plik-z-listy-nie-mierzony" ;; esac
  case "$OUT_OD" in *"✓ ZŁAPANA    poza-lista"*) ;; *) zle="$zle praca-plik-spoza-listy-niemierzony" ;; esac
  case "$OUT_OD" in *"POZA ODLEWEM"*) zle="$zle praca-wycina-obecny-plik" ;; *) ;; esac
  [ "$RC_OD" -eq 0 ] || zle="$zle odlew-poza-lista-liczona-jako-wada"
  # (⊗⊗) PLIK SPOZA LISTY, KTÓREGO NIE MA NA DYSKU — dokładnie stan gałęzi odlewu.
  # Pierwsza wersja miała zamek „brak pliku" PRZED pytaniem o listę, więc te pozycje
  # dostawały etykietę POMINIĘTA, czyli słowo oznaczające UTRATĘ pomiaru. Zmierzone na
  # `main`: 10 pozycji tak zaklasyfikowanych. Kolejność pytań jest tu treścią, nie stylem.
  rm -f "$TO/niejedzie.js"
  OUT_NIEMA="$(cd "$TO" && REJESTR=mutacje.txt bash "$OLDPWD/mutacje.sh" 2>&1)"
  case "$OUT_NIEMA" in *"POZA ODLEWEM  poza-lista"*) ;; *) zle="$zle odlew-nieobecny-plik-bez-wlasnego-slowa" ;; esac
  case "$OUT_NIEMA" in *"POMINIĘTA  poza-lista"*) zle="$zle odlew-nieobecny-mylony-z-utrata" ;; *) ;; esac
  printf 'const y=1;\nif(y!==1) process.exit(1);\n' > "$TO/niejedzie.js"
  # (⊗) BEZ atrapy publikuj.sh lista jest pusta — NIC nie wolno wycinać (cicha utrata zakazana)
  rm -f "$TO/publikuj.sh"
  OUT_BEZ="$(cd "$TO" && REJESTR=mutacje.txt bash "$OLDPWD/mutacje.sh" 2>&1)"
  case "$OUT_BEZ" in *"POZA ODLEWEM"*) zle="$zle odlew-wycina-bez-listy" ;; *) ;; esac
  rm -rf "$TO"

  # ── #116: REGRES ZBIORU POMINIĘTYCH — bieg 1 (bootstrap, cisza) → drift → bieg 2 (alarm,
  # rc=12) → bieg 3 bez dalszej zmiany (już w śladzie, cisza znów) ──────────────────────
  T116="$(mktemp -d)"
  printf 'const z=1;\nif(z!==1) process.exit(1);\n' > "$T116/ofiara116.js"
  printf 'x1|||ofiara116.js|||const z=1;|||const z=2;|||node ofiara116.js\n' > "$T116/mutacje.txt"
  SLAD116="$T116/slad_pominiete.txt"
  OUT116_A="$(cd "$T116" && REJESTR=mutacje.txt POMINIETE_SLAD="$SLAD116" bash "$OLDPWD/mutacje.sh" 2>&1)"; RC116_A=$?
  case "$OUT116_A" in *"REGRES POMINIĘTYCH"*) zle="$zle regres116-falszywy-alarm-bootstrap" ;; *) ;; esac
  [ "$RC116_A" -eq 0 ] || zle="$zle regres116-bootstrap-nie-rc0(rc=$RC116_A)"
  [ -f "$SLAD116" ] || zle="$zle regres116-slad-nie-zapisany"
  printf 'const z=9;\nif(z!==9) process.exit(1);\n' > "$T116/ofiara116.js"   # drift: SZUKAJ już nie pasuje
  OUT116_B="$(cd "$T116" && REJESTR=mutacje.txt POMINIETE_SLAD="$SLAD116" bash "$OLDPWD/mutacje.sh" 2>&1)"; RC116_B=$?
  case "$OUT116_B" in *"REGRES POMINIĘTYCH (#116):"*"x1"*) ;; *) zle="$zle regres116-nie-zlapany" ;; esac
  [ "$RC116_B" -eq 12 ] || zle="$zle regres116-zly-rc(rc=$RC116_B)"
  OUT116_C="$(cd "$T116" && REJESTR=mutacje.txt POMINIETE_SLAD="$SLAD116" bash "$OLDPWD/mutacje.sh" 2>&1)"; RC116_C=$?
  case "$OUT116_C" in *"REGRES POMINIĘTYCH"*) zle="$zle regres116-utrwalony-nadal-alarmuje" ;; *) ;; esac
  rm -rf "$T116"

  # ── R3b (05.10.2026): REJESTR NIE PRZECIEKA DO ŚWIADKA ─────────────────────────────
  # Świadek przechodzi (rc=0), gdy widzi zmienną w otoczeniu — wtedy mutacja wychodzi ŚLEPA i bieg daje rc=1.
  # Bez przecieku świadek uruchamia ofiarę, ta oblewa na mutacji → ZŁAPANA, rc=0.
  TPR="$(mktemp -d)"
  printf 'const x=1;\nif(x!==1) process.exit(1);\n' > "$TPR/ofiara.js"
  printf '%s\n' 'przeciek|||ofiara.js|||const x=1;|||const x=2;|||sh -c '"'"'[ -n "${REJESTR+x}" ] || node ofiara.js'"'" > "$TPR/rej.txt"
  OUT_PR="$(cd "$TPR" && REJESTR=rej.txt bash "$OLDPWD/mutacje.sh" 2>&1)"; RC_PR=$?
  [ "$RC_PR" -eq 0 ] || zle="$zle rejestr-przecieka-do-swiadka(rc=$RC_PR)"
  case "$OUT_PR" in *"ZŁAPANA    przeciek"*) ;; *) zle="$zle rejestr-przeciek-nie-zmierzony" ;; esac
  rm -rf "$TPR"

  # ── R4 (05.10.2026): PUNKT WZNOWIENIA — zapis postępu i bieg, który NIE liczy od początku ──────────
  # Trzy pozycje, każdy świadek zostawia ślad uruchomienia (plik uruchomien_<x>). Bieg 1 pisze zapis postępu.
  # „Ubicie” = zapis obcięty do nagłówka i dwóch pierwszych werdyktów. Bieg 2 ze wznowieniem ma uruchomić
  # WYŁĄCZNIE trzeciego świadka i zameldować trzy złapane. Bieg 3: rejestr zmieniony → zapis należy do innego
  # ciała → odrzucony głośno, wszystkie pozycje biegną. Bieg 4 (repo git): śledzony plik zmieniony → rc=13.
  TW="$(mktemp -d)"
  for _x in a b c; do
    printf 'const x=1;\nif(x!==1) process.exit(1);\n' > "$TW/ofiara_$_x.js"
    printf '%s|||ofiara_%s.js|||const x=1;|||const x=2;|||sh -c '"'"'echo u >> uruchomien_%s; node ofiara_%s.js'"'"'\n' "$_x" "$_x" "$_x" "$_x" >> "$TW/rej.txt"
  done
  ( cd "$TW" && MUTACJE_POSTEP="$TW/postep.txt" REJESTR=rej.txt bash "$OLDPWD/mutacje.sh" >/dev/null 2>&1 ); RC_W1=$?
  [ "$RC_W1" -eq 0 ] || zle="$zle wznow-bieg-pierwszy(rc=$RC_W1)"
  [ "$(grep -c '^ZLAPANA|||' "$TW/postep.txt" 2>/dev/null)" = "3" ] || zle="$zle wznow-zapis-postepu-niepelny"
  head -3 "$TW/postep.txt" > "$TW/postep.ubity" 2>/dev/null && mv "$TW/postep.ubity" "$TW/postep.txt"
  rm -f "$TW"/uruchomien_*
  OUT_W2="$(cd "$TW" && MUTACJE_POSTEP="$TW/postep.txt" MUTACJE_WZNOW=1 REJESTR=rej.txt bash "$OLDPWD/mutacje.sh" 2>&1)"; RC_W2=$?
  [ "$RC_W2" -eq 0 ] || zle="$zle wznow-bieg-drugi(rc=$RC_W2)"
  { [ ! -e "$TW/uruchomien_a" ] && [ ! -e "$TW/uruchomien_b" ]; } || zle="$zle wznowienie-liczy-od-poczatku"
  [ "$(wc -l < "$TW/uruchomien_c" 2>/dev/null | tr -d ' ')" = "1" ] || zle="$zle wznowienie-nie-dobieglo-reszty"
  case "$OUT_W2" in *"złapanych 3 · ŚLEPYCH 0"*) ;; *) zle="$zle wznowienie-gubi-wczesniejsze-werdykty" ;; esac
  [ "$(grep -c '^ZLAPANA|||' "$TW/postep.txt" 2>/dev/null)" = "3" ] || zle="$zle wznowienie-nie-dopisuje-zapisu"
  printf '# zmiana rejestru\n' >> "$TW/rej.txt"; rm -f "$TW"/uruchomien_*
  OUT_W3="$(cd "$TW" && MUTACJE_POSTEP="$TW/postep.txt" MUTACJE_WZNOW=1 REJESTR=rej.txt bash "$OLDPWD/mutacje.sh" 2>&1)"
  case "$OUT_W3" in *"WZNOWIENIE ODRZUCONE"*) ;; *) zle="$zle wznowienie-z-obcego-ciala-przyjete" ;; esac
  { [ -e "$TW/uruchomien_a" ] && [ -e "$TW/uruchomien_b" ] && [ -e "$TW/uruchomien_c" ]; } || zle="$zle obcy-zapis-pominal-pozycje"
  if ( cd "$TW" && git init -q . && git add -A && git -c user.name=t -c user.email=t@t commit -qm start ) >/dev/null 2>&1; then
    ( cd "$TW" && MUTACJE_POSTEP="$TW/postep4.txt" REJESTR=rej.txt bash "$OLDPWD/mutacje.sh" >/dev/null 2>&1 )
    printf '// zostawione przez ubity bieg\n' >> "$TW/ofiara_b.js"; rm -f "$TW"/uruchomien_*
    ( cd "$TW" && MUTACJE_POSTEP="$TW/postep4.txt" MUTACJE_WZNOW=1 REJESTR=rej.txt bash "$OLDPWD/mutacje.sh" >/dev/null 2>&1 ); RC_W4=$?
    [ "$RC_W4" -eq 13 ] || zle="$zle wznowienie-na-zmienionym-ciele-ruszylo(rc=$RC_W4)"
    [ ! -e "$TW/uruchomien_c" ] || zle="$zle wznowienie-na-zmienionym-ciele-mierzylo"
  else niemierzalne="$niemierzalne wznowienie-na-zmienionym-ciele(git-init)"; fi
  rm -rf "$TW"
  # ── R4b: zapis postępu NIE PRZECIEKA DO ŚWIADKA (świadek przechodzi, gdy widzi którąś zmienną → ŚLEPA, rc=1) ──
  TWP="$(mktemp -d)"
  printf 'const x=1;\nif(x!==1) process.exit(1);\n' > "$TWP/ofiara.js"
  printf '%s\n' 'przeciek|||ofiara.js|||const x=1;|||const x=2;|||sh -c '"'"'[ -n "${MUTACJE_POSTEP+x}${MUTACJE_WZNOW+x}" ] || node ofiara.js'"'" > "$TWP/rej.txt"
  ( cd "$TWP" && MUTACJE_POSTEP="$TWP/postep.txt" MUTACJE_WZNOW=1 REJESTR=rej.txt bash "$OLDPWD/mutacje.sh" >/dev/null 2>&1 ); RC_WP=$?
  [ "$RC_WP" -eq 0 ] || zle="$zle postep-przecieka-do-swiadka(rc=$RC_WP)"
  [ "$(grep -c '^ZLAPANA|||przeciek$' "$TWP/postep.txt" 2>/dev/null)" = "1" ] || zle="$zle postep-przeciek-nie-zmierzony"
  rm -rf "$TWP"

  # ── J (07.10.2026, biurko v1.8.1): BIEG UBITY BEZ SZANSY NA TRAP — następny bieg sam przywraca z zapasu trwałego ──
  # Bieg 1 w tle (PID z `$!`, nie pgrep), komenda `sleep 30` trzyma plik zmutowany; SIGKILL; asercje: plik nadal zmutowany,
  # zapas istnieje i nie jest pusty. Bieg 2 (inny rejestr, ten sam katalog): komunikat „POPRZEDNI BIEG UBITY”, plik bajt w bajt
  # jak wzorzec (`cmp`), zapas po biegu pusty/nieobecny, a sama mutacja biegu 2 nadal mierzy (ZŁAPANA).
  TU="$(mktemp -d)"
  printf 'const x=1;\nif(x!==1) process.exit(1);\n' > "$TU/ofiara.js"; cp "$TU/ofiara.js" "$TU/wzorzec.js"
  printf 'ubity|||ofiara.js|||const x=1;|||const x=2;|||sleep 30\n' > "$TU/rej.txt"
  printf 'drugi|||ofiara.js|||const x=1;|||const x=2;|||node ofiara.js\n' > "$TU/rej2.txt"
  _ZU="${TMPDIR:-/tmp}/kronos_mut_zapas_$(cd "$TU" && pwd -P | cksum | cut -d' ' -f1)"
  ( cd "$TU" && REJESTR=rej.txt exec bash "$OLDPWD/mutacje.sh" </dev/null >/dev/null 2>&1 ) &
  _PID_U=$!
  for _i in $(seq 1 30); do cmp -s "$TU/ofiara.js" "$TU/wzorzec.js" || break; sleep 0.5; done
  if cmp -s "$TU/ofiara.js" "$TU/wzorzec.js"; then niemierzalne="$niemierzalne ubity-bieg(plik-nie-zmutowany-w-15s)"
  else
    kill -9 "$_PID_U" 2>/dev/null; wait "$_PID_U" 2>/dev/null
    cmp -s "$TU/ofiara.js" "$TU/wzorzec.js" && zle="$zle ubity-bieg-sam-sprzatnal(test-niewazny)"
    { [ -d "$_ZU" ] && [ -n "$(ls -A "$_ZU" 2>/dev/null)" ]; } || zle="$zle ubity-bieg-nie-zostawil-zapasu"
    OUT_U2="$(cd "$TU" && REJESTR=rej2.txt bash "$OLDPWD/mutacje.sh" 2>&1)"; RC_U2=$?
    case "$OUT_U2" in *"POPRZEDNI BIEG UBITY"*) ;; *) zle="$zle po-ubiciu-brak-komunikatu-odzysku" ;; esac
    cmp -s "$TU/ofiara.js" "$TU/wzorzec.js" || zle="$zle po-ubiciu-plik-nie-wrocil-bajt-w-bajt"
    { [ ! -d "$_ZU" ] || [ -z "$(ls -A "$_ZU" 2>/dev/null)" ]; } || zle="$zle po-biegu-zapas-niepusty"
    case "$OUT_U2" in *"ZŁAPANA    drugi"*) ;; *) zle="$zle po-odzysku-bieg-nie-mierzy" ;; esac
    [ "$RC_U2" -eq 0 ] || zle="$zle po-odzysku-zly-rc(rc=$RC_U2)"
  fi
  rm -rf "$TU" "$_ZU"

  # ── J2 (08.10.2026, U1-04): TA SAMA ścieżka wsteczna, ale OFIARA W PODKATALOGU. Po J `cofnij()` zdejmuje wpis od razu, więc
  # odwzorowanie klucz → ścieżka (`tr '%' '/'`) pracuje już tylko w odzysku po ubiciu — a tor J trzymał ofiarę w korzeniu
  # i wiersz mutacje-sciezka-wsteczna-gubi-katalog przestał mieć świadka. Asercje: plik wraca bajt w bajt, w korzeniu NIE
  # powstaje `ofiara.js` (sierota po zgubionym katalogu), zapas po biegu pusty.
  TU2="$(mktemp -d)"; mkdir -p "$TU2/pod"
  printf 'const x=1;\nif(x!==1) process.exit(1);\n' > "$TU2/pod/ofiara.js"; cp "$TU2/pod/ofiara.js" "$TU2/wzorzec.js"
  printf 'ubity|||pod/ofiara.js|||const x=1;|||const x=2;|||sleep 30\n' > "$TU2/rej.txt"
  printf 'drugi|||pod/ofiara.js|||const x=1;|||const x=2;|||node pod/ofiara.js\n' > "$TU2/rej2.txt"
  _ZU2="${TMPDIR:-/tmp}/kronos_mut_zapas_$(cd "$TU2" && pwd -P | cksum | cut -d' ' -f1)"
  ( cd "$TU2" && REJESTR=rej.txt exec bash "$OLDPWD/mutacje.sh" </dev/null >/dev/null 2>&1 ) &
  _PID_U2=$!
  for _i in $(seq 1 30); do cmp -s "$TU2/pod/ofiara.js" "$TU2/wzorzec.js" || break; sleep 0.5; done
  if cmp -s "$TU2/pod/ofiara.js" "$TU2/wzorzec.js"; then niemierzalne="$niemierzalne ubity-bieg-podkatalog(plik-nie-zmutowany-w-15s)"
  else
    kill -9 "$_PID_U2" 2>/dev/null; wait "$_PID_U2" 2>/dev/null
    OUT_U3="$(cd "$TU2" && REJESTR=rej2.txt bash "$OLDPWD/mutacje.sh" 2>&1)"
    cmp -s "$TU2/pod/ofiara.js" "$TU2/wzorzec.js" || zle="$zle po-ubiciu-podkatalog-plik-nie-wrocil-bajt-w-bajt"
    [ ! -e "$TU2/ofiara.js" ] || zle="$zle po-ubiciu-podkatalog-sierota-w-korzeniu"
    { [ ! -d "$_ZU2" ] || [ -z "$(ls -A "$_ZU2" 2>/dev/null)" ]; } || zle="$zle po-ubiciu-podkatalog-zapas-niepusty"
  fi
  rm -rf "$TU2" "$_ZU2"
  rm -rf "$TU2" "$_ZU2"

  # ── J3 (08.10.2026, U1-10): ODZYSK NIE NADPISUJE LEGALNEJ ZMIANY. Po SIGKILL ręka przywraca plik i dopisuje linię (tak radzi komunikat rc=13) — następny bieg
  # przywracał kopię z zapasu i kasował dopisaną linię (rc=0). Teraz: plik równy odciskowi mutacji → przywróć (tor J) · plik równy kopii → tylko zdejmij wpis
  # · plik inny → rc=14, „plik zmieniony po ubiciu — nie nadpisuję”, nazwa pliku, zapas zostaje.
  for _scen in legalna rowna; do
    TU3="$(mktemp -d)"
    printf 'const x=1;\nif(x!==1) process.exit(1);\n' > "$TU3/ofiara.js"; cp "$TU3/ofiara.js" "$TU3/wzorzec.js"
    printf 'ubity|||ofiara.js|||const x=1;|||const x=2;|||sleep 30\n' > "$TU3/rej.txt"
    printf 'drugi|||ofiara.js|||const x=1;|||const x=2;|||node ofiara.js\n' > "$TU3/rej2.txt"
    _ZU3="${TMPDIR:-/tmp}/kronos_mut_zapas_$(cd "$TU3" && pwd -P | cksum | cut -d' ' -f1)"
    ( cd "$TU3" && REJESTR=rej.txt exec bash "$OLDPWD/mutacje.sh" </dev/null >/dev/null 2>&1 ) &
    _PID_U3=$!
    for _i in $(seq 1 30); do cmp -s "$TU3/ofiara.js" "$TU3/wzorzec.js" || break; sleep 0.5; done
    if cmp -s "$TU3/ofiara.js" "$TU3/wzorzec.js"; then niemierzalne="$niemierzalne ubity-bieg-$_scen(plik-nie-zmutowany-w-15s)"
    else
      kill -9 "$_PID_U3" 2>/dev/null; wait "$_PID_U3" 2>/dev/null
      cp "$TU3/wzorzec.js" "$TU3/ofiara.js"                                   # ręka przywraca plik...
      [ "$_scen" = legalna ] && printf '// legalna zmiana po ubiciu\n' >> "$TU3/ofiara.js"   # ...i (scenariusz iii) dopisuje własną linię
      OUT_U3="$(cd "$TU3" && REJESTR=rej2.txt bash "$OLDPWD/mutacje.sh" 2>&1)"; RC_U3=$?
      if [ "$_scen" = legalna ]; then
        [ "$RC_U3" -eq 14 ] || zle="$zle odzysk-nadpisal-legalna-zmiane(rc=$RC_U3)"
        grep -q 'legalna zmiana po ubiciu' "$TU3/ofiara.js" || zle="$zle odzysk-skasowal-legalna-linie"
        case "$OUT_U3" in *"plik zmieniony po ubiciu — nie nadpisuję"*ofiara.js*) ;; *) zle="$zle odzysk-bez-komunikatu-z-nazwa-pliku" ;; esac
        { [ -d "$_ZU3" ] && [ -n "$(ls -A "$_ZU3" 2>/dev/null)" ]; } || zle="$zle odzysk-zdjal-zapas-mimo-odmowy"
      else
        [ "$RC_U3" -eq 0 ] || zle="$zle odzysk-pliku-rownego-kopii-zly-rc(rc=$RC_U3)"
        cmp -s "$TU3/ofiara.js" "$TU3/wzorzec.js" || zle="$zle odzysk-pliku-rownego-kopii-zmienil-plik"
        case "$OUT_U3" in *"już w stanie sprzed mutacji"*) ;; *) zle="$zle odzysk-pliku-rownego-kopii-bez-meldunku" ;; esac
        { [ ! -d "$_ZU3" ] || [ -z "$(ls -A "$_ZU3" 2>/dev/null)" ]; } || zle="$zle odzysk-pliku-rownego-kopii-zapas-niepusty"
      fi
    fi
    rm -rf "$TU3" "$_ZU3"
  done

  [ -n "$niemierzalne" ] && echo "  ? POZA ZASIĘGIEM PLATFORMY — brak pomiaru, NIE zaliczenie:$niemierzalne"
  if [ -z "$zle" ]; then
    echo "  ✓ MUTACJE ŻYWE — 8 torów: wykrytą melduje zielono, ŚLEPĄ STRAŻ melduje czerwono,"
    echo "    plik po przebiegu wraca bajt w bajt, bieg ZAGNIEŻDŻONY odmawia (rc=4) bez tknięcia materii,"
    echo "    a BRAK POMIARU melduje się osobnym kodem (rc=5) zamiast udawać sukces,"
    echo "    ŚCIEŻKA WSTECZNA: cel bez zapisu zatrzymuje PRZED pętlą (rc=7), awaria przejściowa ratowana ponowieniem,"
    echo "    a ciało, które nie wróciło, jest nazwane imiennie (rc=8) — nigdy ciszą."
    echo "    AWARIA MUTATORA (rc mutatora ≠ 0 i ≠ 3) jest kategorią OSOBNĄ od POMINIĘTA — rc=9, słowo AWARIA, nigdy cicho."
    echo "    ZAMEK BIEGU (#112): PID żywy z poprzedniego biegu odmawia startu (rc=11); PID martwy"
    echo "    (zamek osierocony) ostrzega i pozwala ruszyć — jedna awaria nie blokuje na trwałe."
    echo "    REGRES POMINIĘTYCH (#116): pierwszy bieg milczy (bootstrap), pozycja nowo pominięta"
    echo "    melduje się rc=12, ta sama pozycja w kolejnym biegu (już w śladzie) znów milczy."
    echo "    BIEG UBITY (SIGKILL): następny bieg sam przywraca plik z zapasu trwałego i mówi o tym wprost."
    echo "    ODZYSK NIE NADPISUJE: plik zmieniony po ubiciu (legalna linia) → rc=14 z nazwą pliku, zapas zostaje; plik równy kopii → tylko zdjęty wpis."
    exit 0
  fi
  echo "  ✗ MUTACJE MARTWE — oblane:$zle"
  exit 1
fi

# ── ZAMEK NA REKURENCJĘ (13.08.2026, blizna ujawniona pomiarem) ──
# OBSERWACJA: trzy mutacje `gotowosc-*` mają w torze `bash gotowosc.sh --test`, a
# `gotowosc.sh --test` woła `slepe_punkty()` → `bash mutacje.sh`. Przyrząd mutował
# przyrząd, który go uruchamia. Bieg zagnieżdżony robił kopię pliku JUŻ ZMUTOWANEGO
# (l. 82) i na swojej ścieżce wstecznej przywracał WERSJĘ USZKODZONĄ (l. 97) —
# ścieżka wsteczna działała bez zarzutu, tylko wracała do złego stanu.
# ZMIERZONE SKUTKI: trzy mutacje utrwalone w `gotowosc.sh` + stała `-2` wstrzyknięta
# w `narzedzia/silniki/tz_pl.js` (jedyne źródło czasu PL) — dokładnie klasa błędu zamknięta tego ranka.
# Zamek NIE obejmuje `--test`: tor własny pracuje na atrapie w mktemp, nie tyka repo.
# ZAMEK PO TOŻSAMOŚCI CIAŁA (18.09.2026, zmierzone): do dziś zamek odmawiał na SAM WIDOK
# flagi. 13.09 okazało się, że to fałszywie oblewa świadków mierzących własną fiksturę
# w mktemp, więc `gotowosc.sh` zaczął zdejmować flagę (`env -u`) — i rozbroił zamek także
# tam, gdzie zagnieżdżenie było REALNE: 18.09 bieg `publikuj.sh` urósł do 3182 procesów
# w 21 h. Flaga niesie teraz tożsamość ciała (urządzenie:inode katalogu biegu), a zamek
# odmawia tylko, gdy nowy bieg startuje W TYM SAMYM ciele. `pwd -P` odrzucone pomiarem:
# na Git Bash nie normalizuje wielkości liter (/c/Users vs /c/users — dwa napisy, jeden
# katalog), `stat %d:%i` daje jedną wartość. Tożsamość nieczytelna → odmowa (fail-closed).
_TOZSAMOSC="$(stat -c '%d:%i' . 2>/dev/null)"
if [ -n "${MUTACJE_W_BIEGU:-}" ] && { [ -z "$_TOZSAMOSC" ] || [ "$MUTACJE_W_BIEGU" = "$_TOZSAMOSC" ]; }; then
  echo "  ⛔ ODMOWA STARTU — bieg mutacyjny już trwa (zagnieżdżenie)."
  echo "     Kopia zapasowa zagnieżdżonego biegu byłaby zdjęta z pliku ZMUTOWANEGO."
  exit 4
fi

# ── ZAMEK BIEGU (#112, 22.09.2026) — RÓŻNE zjawisko niż ZAMEK NA REKURENCJĘ wyżej ──────────
# Tamten pilnuje TOŻSAMOŚCI KATALOGU wewnątrz JEDNEGO biegu, który sam siebie zagnieżdża
# (świadek `bash gotowosc.sh --test` woła `mutacje.sh` z wnętrza `mutacje.sh` — ten sam proces,
# ten sam katalog, w LOCIE). TEN zamek pilnuje ŚLADU NA DYSKU między NIEZALEŻNYMI wywołaniami:
# (a) DWA SIBLING procesy wystartowane osobno na tym samym drzewie (żaden nie zna drugiego,
# `MUTACJE_W_BIEGU` nie jest ustawiony w środowisku ŻADNEGO z nich — istniejący zamek ich NIE
# widzi) — dokładnie klasa z incydentu 21.09 wieczór; (b) bieg PRZERWANY (SIGKILL nie łapie
# `trap … EXIT` — zmierzone, mutant zostaje na dysku) zostawiający zamek, którego następny bieg
# nie powinien ślepo ufać. Plik-zamek w korzeniu niesie `PID:czas_startu (ISO)`.
ZAMEK_BIEGU="${ZAMEK_BIEGU_PLIK:-.mutacje_lock}"
if [ -f "$ZAMEK_BIEGU" ]; then
  _ZB_PID="$(cut -d: -f1 "$ZAMEK_BIEGU" 2>/dev/null)"
  _ZB_CZAS="$(cut -d: -f2- "$ZAMEK_BIEGU" 2>/dev/null)"
  case "$_ZB_PID" in ''|*[!0-9]*) _ZB_PID="" ;; esac
  if [ -n "$_ZB_PID" ] && kill -0 "$_ZB_PID" 2>/dev/null; then
    echo "  ⛔ ODMOWA STARTU — bieg mutacyjny już trwa (PID $_ZB_PID od ${_ZB_CZAS:-?})."
    echo "     Dwa biegi na jednym drzewie nie brudzą go (ŚCIEŻKA WSTECZNA), ale psują POMIAR —"
    echo "     rc jednego biegu przestaje znaczyć to, co deklaruje (#112, incydent 21.09 wieczór)."
    exit 11
  else
    echo "  ⚠ ZAMEK OSIEROCONY: poprzedni bieg (PID ${_ZB_PID:-?} od ${_ZB_CZAS:-?}) już nie żyje —"
    echo "    NIE UFAJ jego ostatniemu pomiarowi (mógł przerwać się w środku mutacji, SIGKILL nie"
    echo "    łapie ścieżki wstecznej). Startuję mimo to — jedna awaria nie blokuje na trwałe."
  fi
fi
printf '%s:%s' "$$" "$(date -u +%Y-%m-%dT%H:%M:%SZ)" > "$ZAMEK_BIEGU"

# ── ZAPAS TRWAŁY (J, 07.10.2026, biurko v1.8.1; POMIARY_progu §11b, zarzut CD L23) ───────────────────────────
# ZMIERZONE 07.10: SIGKILL w trakcie mutacji zostawiał plik zmutowany, a NASTĘPNY bieg brał go za stan wyjściowy
# i „przywracał” zepsuty (md5 po drugim biegu = md5 uszkodzenia). Przyczyna: `ZAPAS` (mktemp -d, l.44) żył tylko w pamięci procesu.
# Teraz po zamkach (rekurencji i biegu — czyli GDY WIEMY, że nie żyje inny bieg w tym katalogu) bieg przejmuje zapas o ścieżce
# WYLICZALNEJ z katalogu ciała (dwa klony = dwa zapasy). Niepusty zapas = poprzedni bieg umarł w trakcie mutacji → najpierw odzysk,
# dopiero potem `_PRZED` i pętla. Odzysk, który padł (cp ×4), zatrzymuje bieg (rc=14; rc=6 zostaje zarezerwowany, patrz preflight python3 niżej) — nie mutujemy na niepewnym stanie.
# Zapas wcześniejszy (losowy, l.44) obsługuje wszystkie wyjścia PRZED tym miejscem i --test, więc zagnieżdżony bieg (rc=4)
# ani odmowa zamka (rc=11) nie dotykają zapasu biegu, który żyje.
_ZAPAS_TRWALY="${TMPDIR:-/tmp}/kronos_mut_zapas_$(pwd -P | cksum | cut -d' ' -f1)"
if [ -d "$_ZAPAS_TRWALY" ] && [ -n "$(ls -A "$_ZAPAS_TRWALY" 2>/dev/null)" ]; then
  _ODZ=""; _JUZ=""
  for k in "$_ZAPAS_TRWALY"/*; do
    [ -e "$k" ] || continue
    case "$k" in *.odcisk) continue ;; esac
    case "$k" in "$_ZAPAS_TRWALY"/sonda.txt|"$_ZAPAS_TRWALY"/sonda2.txt) rm -f "$k"; continue ;; esac   # resztka sondy zapisu (bieg ubity w jej trakcie), nie plik pracy
    cel="$(printf '%s' "$(basename "$k")" | tr '%' '/')"
    mkdir -p "$(dirname "./$cel")" 2>/dev/null || true
    # B4 (U1-10): trzy stany pliku. (1) równy odciskowi mutacji → przywróć (jak dotąd) · (2) równy kopii → tylko zdejmij wpis · (3) inny → NIE nadpisuj.
    _AKT=""; [ -f "./$cel" ] && _AKT="$(_odcisk "./$cel")"
    _MUT=""; [ -f "$k.odcisk" ] && _MUT="$(cat "$k.odcisk")"
    if [ -n "$_AKT" ] && [ -n "$_MUT" ] && [ "$_AKT" = "$_MUT" ]; then
      if cp3 "$k" "./$cel"; then _ODZ="$_ODZ $cel"
      else echo "  ✗ ODZYSK Z ZAPASU NIE UDAŁ SIĘ: $cel (cp ×4) — nie mutuję na niepewnym stanie; zapas zostaje: $_ZAPAS_TRWALY"; exit 14; fi
    elif [ -n "$_AKT" ] && cmp -s "$k" "./$cel"; then
      _JUZ="$_JUZ $cel"
    else
      echo "  ✗ plik zmieniony po ubiciu — nie nadpisuję: $cel (nie jest ani zmutowany przez poprzedni bieg, ani równy kopii sprzed mutacji)."
      echo "    Zapas zostaje: $_ZAPAS_TRWALY — obejrzyj plik (git diff), potem usuń zapas (rm -rf) i uruchom ponownie. Nie mutuję na niepewnym stanie."
      exit 14
    fi
  done
  [ -n "$_ODZ" ] && echo "  ⚠ POPRZEDNI BIEG UBITY — przywrócono z zapasu:$_ODZ"
  [ -n "$_JUZ" ] && echo "  ⓘ POPRZEDNI BIEG UBITY — pliki już w stanie sprzed mutacji (zdjęto tylko wpis zapasu):$_JUZ"
fi
rm -rf "$ZAPAS" "$_ZAPAS_TRWALY"; mkdir -p "$_ZAPAS_TRWALY"; ZAPAS="$_ZAPAS_TRWALY"

# ── PRZEBIEG ──
echo "╔═══ TEST MUTACYJNY — czy straże łapią PRAWDZIWY błąd ═══╗"
[ -f "$REJESTR" ] || { echo "  ✗ brak rejestru $REJESTR"; exit 2; }

# ── NAGROBEK: PREFLIGHT ZDATNOŚCI python3 (żył 03.09–21.09.2026, zdjęty przy migracji) ──
# Rodowód powodu istnienia: alias Microsoft Store `python3` bywał w PATH, ale nie wykonywał
# się — mutator padał cicho na każdej pozycji, a bieg meldował „każda wada złapana" (0/0/160,
# rc=0). Preflight nazywał PRZYCZYNĘ przed pętlą i odróżniał ZAŚLEPKĘ od BRAKU (rc=6).
# ZDJĘTY 21.09.2026 (WATKI_OTWARTE, migracja mutatora na node): przyczyna zniknęła wraz
# z zależnością, którą preflight strzegł. `node` nie jest tu drugą, dodaną zależnością —
# jest już wymagany przez `weryfikacja.js` i większość reszty ciała; preflight na niego
# powtarzałby pytanie, na które cały system już musiał odpowiedzieć „tak", zanim ten skrypt
# w ogóle mógł wystartować. **rc=6 pozostaje ZAREZERWOWANY, nieosiągalny** — nie przypisuję
# go ponownie, żeby stara dokumentacja czytana po fakcie nie wskazywała na inny stan niż ten,
# który faktycznie wystąpił (ta sama zasada co nagrobek imienia w DUSZA.md: martwe nie
# znika po cichu). Testy tego preflightu (zaślepka/brak) zdjęte tą samą ręką — historia
# w `git log -- mutacje.sh` sprzed tego commitu, nie tu.

# ── PREFLIGHT ŚCIEŻKI WSTECZNEJ (03.09.2026, słowo twórcy: zatrzymywać, nie świecić) ──
# Bliźniak preflightu python3 (ta sama nazwa, to samo pytanie „czy środowisko jest zdatne",
# to samo obciążenie — MOSTY #36 rozstrzyga: rozszerzenie, nie nowy przyrząd). Pyta nie
# „czy umiem wstrzyknąć", lecz „czy umiem COFNĄĆ": próbny plik z ZAPAS do katalogu pracy
# i z powrotem, trzema próbami. rc=7 — własny, nieosiągalny dla 0·1·2·3·4·5·6.
# Sprzątanie sondy też jest pomiarem: śmieć, którego nie da się usunąć, wszedłby w `git add -A`.
_SONDA="./.mutacje_sonda_$$"
printf 'sonda\n' > "$ZAPAS/sonda.txt"
S_POWOD=""
if ! cp3 "$ZAPAS/sonda.txt" "$_SONDA"; then S_POWOD="zapis do katalogu pracy pada (cp ×4)"
elif ! cp3 "$_SONDA" "$ZAPAS/sonda2.txt"; then S_POWOD="odczyt z katalogu pracy pada (cp ×4)"
fi
rm -f "$_SONDA" 2>/dev/null || rm -f "$_SONDA" 2>/dev/null || rm -f "$_SONDA"
[ -e "$_SONDA" ] && S_POWOD="${S_POWOD:+$S_POWOD; }śmieć sondy nie do usunięcia: $_SONDA"
rm -f "$ZAPAS/sonda.txt" "$ZAPAS/sonda2.txt"
if [ -n "$S_POWOD" ]; then
  echo "  ✗ PREFLIGHT: ŚCIEŻKA WSTECZNA niezdatna — $S_POWOD. Rejestr NIE ZMIERZONY, ciało NIETKNIĘTE."
  echo "    Przyrząd, który nie umie odłożyć na miejsce, nie ma prawa wstrzykiwać (klasa #54)."
  exit 7
fi
# stan drzewa PRZED biegiem — kontrola PO pętli porówna z nim (tylko w repo git)
_PRZED="$(git status --porcelain 2>/dev/null)"; _GIT=$?

ZLAPANE=0; SLEPE=0; POMINIETE=0; POMINIETE_LISTA=""; SLEPA_LISTA=""; AWARIE=0; AWARIE_LISTA=""
SWIADKOWIE=0; SWIADKOWIE_LISTA=""
POZA_ODLEWEM=0
# ── PUNKT WZNOWIENIA (R4 serii R, 05.10.2026; KARTA_ODLEWU lekcja z próby 8) ────────────────────
# Pełny rejestr biegnie ok. 50 min, a proces w tle ginie z końcem tury — osiem prób odlewu 04–05.10 liczyło
# bramkę 3 od zera albo dobiegało resztę ręcznie składanym podzbiorem. Tu: gdy wołający poda MUTACJE_POSTEP=<plik>,
# każdy WERDYKT pozycji trafia do pliku w chwili, gdy zapadł (STATUS|||NAZWA). MUTACJE_WZNOW=1 wczytuje ten zapis,
# pozycji już rozstrzygniętych NIE uruchamia, a ich werdykty wlicza — podsumowanie i wszystkie zamki końca biegu
# (cisza, martwy świadek, #116) widzą CAŁY rejestr, nie resztę. Bez MUTACJE_POSTEP nic się nie zmienia.
# TOŻSAMOŚĆ: zapis jest pomiarem JEDNEGO ciała — nagłówek niesie HEAD i sumę rejestru. Inne ciało = zapis odrzucony
# głośno i bieg od zera. Ciało ze zmianami w plikach śledzonych = odmowa (rc=13): ubity bieg zostawia zmutowany plik
# (SIGKILL nie sprząta), a wznowienie na nim mierzyłoby mutację jako kanon. Przyrząd nie leczy — nazywa pliki (#56).
# AWARIA mutatora nie jest werdyktem: pozycja po wznowieniu biegnie ponownie.
POSTEP="$_MUT_POSTEP"; WZNOW=0; WZNOW_ILE=0; declare -A _ROZSTRZYGNIETE=()
_post() { [ -n "$POSTEP" ] && printf '%s|||%s\n' "$1" "$2" >> "$POSTEP"; return 0; }
if [ -n "$POSTEP" ]; then
  _POST_ID="HEAD=$(git rev-parse HEAD 2>/dev/null || echo brak) rejestr=$(cksum < "$REJESTR" | tr ' ' ':')"
  if [ "$_MUT_WZNOW" = 1 ]; then
    _POST_STARE="$(sed -n '1s/^# postep · \(.*\) · start=.*$/\1/p' "$POSTEP" 2>/dev/null)"
    if [ ! -s "$POSTEP" ]; then
      echo "  ⚠ WZNOWIENIE BEZ ZAPISU — brak pliku postępu ($POSTEP); liczę od zera."
    elif [ "$_POST_STARE" != "$_POST_ID" ]; then
      echo "  ⚠ WZNOWIENIE ODRZUCONE — zapis postępu należy do innego ciała; liczę od zera."
      echo "    zapis: ${_POST_STARE:-nieczytelny nagłówek} · teraz: $_POST_ID"
    elif [ "$_GIT" -eq 0 ] && [ -n "$(git status --porcelain --untracked-files=no 2>/dev/null)" ]; then
      echo "  ✗ WZNOWIENIE NA ZMIENIONYM CIELE — pliki śledzone różnią się od HEAD:"
      git status --porcelain --untracked-files=no 2>/dev/null | sed 's/^/      /'
      echo "    Ubity bieg mógł zostawić mutację. Przywróć ręką (git checkout -- <plik>) albo zacommituj, potem ponów."
      echo "    Zapis postępu NIETKNIĘTY: $POSTEP"
      exit 13
    else
      WZNOW=1   # zapis postępu należy do tego ciała
      while IFS= read -r _pw; do
        case "$_pw" in ''|'#'*) continue ;; esac
        _ROZSTRZYGNIETE["${_pw#*|||}"]="${_pw%%|||*}"
      done < "$POSTEP"
      echo "  ⓘ WZNOWIENIE: zapis z $(sed -n '1s/.* · start=//p' "$POSTEP") niesie ${#_ROZSTRZYGNIETE[@]} werdyktów — te pozycje nie biegną ponownie."
    fi
  fi
  [ "$WZNOW" = 1 ] || printf '# postep · %s · start=%s\n' "$_POST_ID" "$(TZ="$_STREFA_ST" date '+%Y-%m-%dT%H:%M:%S%z')" > "$POSTEP"
fi
# ── GRANICA PREFLIGHTU ŚWIADKA (13.09.2026, DRUGIE PODEJŚCIE) ────────────────────────
# PIERWSZE PODEJŚCIE (wczoraj) sprawdzało KAŻDY świadek na zdrowym ciele — i wywróciło
# `--test` obu torów (`mutacje.sh`, `gotowosc.sh`). Przyczyna zmierzona: ich fikstury
# WOŁAJĄ mutacje.sh REKURENCYJNIE na SYNTETYCZNYCH rejestrach (`rej.txt`, `rej2.txt`,
# `rej3.txt`) zawierających świadków, które CELOWO zawsze oblewają (`sonda.sh` mierzy
# tylko, czy MUTACJE_W_BIEGU doszedł do komendy — jej rc=1 to część konstrukcji, nie wada).
# Preflight nie umiał odróżnić „świadek zepsuty" od „świadek-sonda testujący MECHANIZM
# mutatora, nie jakiś kod produkcyjny". To nie ten sam błąd co #75 (czułość to połowa
# toru) — to mylenie DWÓCH RÓŻNYCH PRZEDMIOTÓW pomiaru.
# GRANICA: preflight aktywny WYŁĄCZNIE dla PRAWDZIWEGO rejestru (nazwa bazowa = mutacje.txt,
# czyli REJESTR niepodane = wartość domyślna z l.25). Każdy REJESTR z inną nazwą jest
# z definicji fikstura samotestu tego przyrządu — jej świadkowie mierzą przyrząd, nie ciało,
# i preflight, który by ich osądzał, popełniałby dokładnie błąd #50 (miara na cudzym materiale).
_PREFLIGHT_AKTYWNY=0
[ "$(basename "$REJESTR")" = "mutacje.txt" ] && _PREFLIGHT_AKTYWNY=1
# ── KESZ POZA ZAPASEM (13.09.2026, blizna zmierzona tego samego dnia) ────────────────
# `$ZAPAS` NIE jest katalogiem tymczasowym ogólnego użytku — to przestrzeń ŚCIEŻKI
# WSTECZNEJ, w której KAŻDY plik jest kopią zapasową, a `przywroc()` (trap EXIT) kopiuje
# je wszystkie do korzenia po nazwie bazowej. Trzymanie tam czegokolwiek innego znaczy
# wysypanie tego do repo przy każdym wyjściu. ZMIERZONE: 70 plików `bl_*` w korzeniu po
# KAŻDYM produkcyjnym biegu `gotowosc.sh` — mimo rc=0 i czystego komunikatu końcowego.
# To ta sama klasa co blizna „sierota-w-korzeniu" (21.08), na którą ten plik ma już tor.
KESZ_SWIADKOW="$(mktemp -d)"
# ── BIAŁA LISTA ODLEWU — KLASA MIERZONA, NIE DEKLAROWANA (13.09.2026) ────────────────
# ZMIERZONE na `main`: z 14 pozycji, które nie meldują ZŁAPANEJ, DZIESIĘĆ dotyka plików,
# których w odlewie NIE MA W OGÓLE (`odlej_main.sh` ×6 — narzędzie twórcy pierwotnego,
# `markery_z_ciala.sh`, `spis_projektow.js`, `PLAN_ODLEWU`). Meldowały się jako POMINIĘTE,
# czyli tym samym słowem co „wzorzec się rozjechał" — a to dwie różne rzeczy: tam pomiar
# UTRACONO (trzeba naprawić), tu pomiaru NIE DA SIĘ wykonać z prawa (i nie ma czego naprawiać).
# Zlanie ich w jedno słowo znaczy, że utrata pomiaru chowa się wśród normy.
#
# DLACZEGO BEZ POLA W REJESTRZE: `publikuj.sh --lista MAIN` JEST jedynym źródłem prawdy o tym,
# co jedzie. Pole przy wpisie byłoby DRUGĄ KOPIĄ tej prawdy i rozjechałoby się przy pierwszej
# zmianie listy — dokładnie blizna „lista JS 45→38, blok stał dwukrotnie i rósł". Klasę
# WYPROWADZAMY z listy przy każdym biegu: mierzona, nie pamiętana (#13, #1).
# Lista czytana RAZ (nie per pozycja) i tylko gdy przyrząd stoi obok publikuj.sh.
LISTA_ODLEWU=""
if [ "$_PREFLIGHT_AKTYWNY" -eq 1 ] && [ -f publikuj.sh ]; then
  LISTA_ODLEWU="$(sh publikuj.sh --lista MAIN 2>/dev/null || true)"
fi
while IFS= read -r w; do
  case "$w" in ''|'#'*) continue ;; esac
  NAZWA="${w%%|||*}";  r="${w#*|||}"
  PLIK="${r%%|||*}";   r="${r#*|||}"
  SZUKAJ="${r%%|||*}"; r="${r#*|||}"
  ZAMIEN="${r%%|||*}"; KOMENDA="${r#*|||}"

  if [ "$WZNOW" = 1 ]; then   # R4: werdykt z zapisu postępu — wliczony, pozycja NIE biegnie
    case "${_ROZSTRZYGNIETE[$NAZWA]:-}" in
      ZLAPANA)   ZLAPANE=$((ZLAPANE+1)); WZNOW_ILE=$((WZNOW_ILE+1)); continue ;;
      SLEPA)     SLEPE=$((SLEPE+1)); SLEPA_LISTA="$SLEPA_LISTA $NAZWA"; WZNOW_ILE=$((WZNOW_ILE+1)); echo "  ✗ ŚLEPA      ${NAZWA}  → (werdykt z zapisu postępu)"; continue ;;
      POMINIETA) POMINIETE=$((POMINIETE+1)); POMINIETE_LISTA="$POMINIETE_LISTA $NAZWA"; WZNOW_ILE=$((WZNOW_ILE+1)); echo "  ⓘ POMINIĘTA  ${NAZWA} — (werdykt z zapisu postępu)"; continue ;;
      SWIADEK)   SWIADKOWIE=$((SWIADKOWIE+1)); SWIADKOWIE_LISTA="$SWIADKOWIE_LISTA $NAZWA"; WZNOW_ILE=$((WZNOW_ILE+1)); echo "  ✗ ŚWIADEK MARTWY  ${NAZWA}  → (werdykt z zapisu postępu)"; continue ;;
      POZA)      POZA_ODLEWEM=$((POZA_ODLEWEM+1)); WZNOW_ILE=$((WZNOW_ILE+1)); continue ;;
    esac
  fi

  # ── POZA ODLEWEM ≠ POMINIĘTA (13.09.2026) ─────────────────────────────────────────
  # Pozycja jest niemierzalna Z PRAWA tylko gdy ZACHODZĄ OBA warunki naraz: plik nie jedzie
  # w wydaniu I nie ma go w tym drzewie. Wtedy i tylko wtedy stoimy na gałęzi odlewu, a
  # pomiar jest niewykonalny nie z czyjejś winy.
  # PIERWSZA WERSJA PYTAŁA TYLKO O LISTĘ — i wycinała te pozycje TAKŻE NA GAŁĘZI PRACY,
  # gdzie pliki istnieją i są normalnie mierzalne. Zmierzone: sześć pozycji `odlej-*`
  # przestało być mierzone GDZIEKOLWIEK, a komunikat twierdził „mierzone na gałęzi pracy".
  # Zamieniłam mylące słowo na cichą utratę pomiaru Z NIEPRAWDZIWYM ZDANIEM OBOK — dokładnie
  # to, przed czym stoi ten przyrząd. Obecność pliku jest rozstrzygająca: jeśli materiał
  # tu jest, nie ma powodu go nie zmierzyć, niezależnie od tego, czy pojedzie dalej.
  if [ ! -f "$PLIK" ] && [ -n "$LISTA_ODLEWU" ] \
     && ! printf '%s\n' "$LISTA_ODLEWU" | grep -qxF "$PLIK"; then
    echo "  ⓘ POZA ODLEWEM  ${NAZWA} — $PLIK nie jedzie w wydaniu i nie ma go w tym drzewie"
    POZA_ODLEWEM=$((POZA_ODLEWEM+1)); _post POZA "$NAZWA"; continue
  fi
  if [ ! -f "$PLIK" ]; then
    echo "  ⓘ POMINIĘTA  ${NAZWA} — brak pliku $PLIK"; POMINIETE=$((POMINIETE+1)); POMINIETE_LISTA="$POMINIETE_LISTA $NAZWA"; _post POMINIETA "$NAZWA"; continue
  fi
  # ── PREFLIGHT ŚWIADKA (13.09.2026, DRUGIE PODEJŚCIE — patrz granica wyżej) ─────────
  # Pyta o rzecz, której ten przyrząd nie pytał NIGDY: czy świadek PRZECHODZI na ZDROWYM
  # ciele? Bez tego świadek oblewający ZAWSZE melduje ZŁAPANĄ przy każdej mutacji, nie
  # mierząc niczego. ZMIERZONE 13.09.2026 audytem 71 świadków: 4 oblewały na zdrowym
  # ciele, dając FAŁSZYWE POKRYCIE 6 z 205 pozycjom — w tym jednej wpisanej tego samego
  # dnia moją własną ręką. Kategoria OSOBNA od ŚLEPYCH: ŚLEPA znaczy „straż nie złapała
  # wady", ŚWIADEK MARTWY znaczy „nie dowiedzieliśmy się niczego, miernik był zepsuty
  # przed pomiarem". Kesz per komendę — 70 unikalnych świadków na 205 wpisów.
  if [ "$_PREFLIGHT_AKTYWNY" -eq 1 ]; then
    _KLB="$KESZ_SWIADKOW/bl_$(printf '%s' "$KOMENDA" | cksum | tr -d ' /')"
    if [ ! -f "$_KLB" ]; then
      set +e; ( MUTACJE_W_BIEGU="${_TOZSAMOSC:-?}" eval "$KOMENDA" ) >/dev/null 2>&1; printf '%s' "$?" > "$_KLB"; set -e
    fi
    if [ "$(cat "$_KLB")" -ne 0 ]; then
      echo "  ✗ ŚWIADEK MARTWY  ${NAZWA}  → «${KOMENDA}» oblewa JUŻ NA ZDROWYM CIELE"
      SWIADKOWIE=$((SWIADKOWIE+1)); SWIADKOWIE_LISTA="$SWIADKOWIE_LISTA $NAZWA"; _post SWIADEK "$NAZWA"
      continue
    fi
  fi
  cp "$PLIK" "$ZAPAS/$(klucz "$PLIK")"
  # podmiana literalna (bez interpretacji regexów) — node, bo sed dławi się metaznakami
  # rc PRZECHWYCONY BEZPOŚREDNIO po komendzie (09.09.2026, rozjazd zmierzony w baterii:
  # 17·18·19·17 pominiętych na tym samym rejestrze, gdy deterministycznie count!=1 daje 16).
  # `if ! CMD; then` łapał KAŻDY niezerowy kod pod jedną etykietę „wzorzec nie występuje
  # dokładnie raz" — awaria interpretera/blokada pliku dostawały TEN SAM komunikat co
  # rzeczywisty pomiar count!=1 (klasa #82/#84/#39). rc=3 = pomiar (wzorzec), KAŻDY INNY
  # niezerowy kod = AWARIA MUTATORA i idzie do osobnej kategorii, nigdy do POMINIĘTA.
  # MIGRACJA python3 → node (21.09.2026, WATKI_OTWARTE): druga zależność runtime zdjęta.
  # $MUTATOR_NODE zamiast literalnego `node` — TYLKO po to, żeby --test mógł podstawić
  # atrapę na sam mutator, nie tykając `node`, którego reszta pliku używa do uruchamiania
  # KOMEND (§ AWARIA MUTATORA niżej). Domyślnie zwykły `node` z PATH, bez atrapy.
  set +e
  "${MUTATOR_NODE:-node}" - "$PLIK" "$SZUKAJ" "$ZAMIEN" <<'JS'
const fs = require('fs');
try {
  const [p, szukaj, zamien] = process.argv.slice(2);
  const s = fs.readFileSync(p, 'utf8');
  let count = 0, idx = 0;
  for (;;) {
    const znal = s.indexOf(szukaj, idx);
    if (znal === -1) break;
    count++; idx = znal + szukaj.length;
  }
  if (count !== 1) process.exit(3);
  const i = s.indexOf(szukaj);
  fs.writeFileSync(p, s.slice(0, i) + zamien + s.slice(i + szukaj.length), 'utf8');
  process.exit(0);
} catch (e) { process.exitCode = 1; }
JS
  rc_mut=$?
  set -e

  if [ "$rc_mut" -eq 3 ]; then
    echo "  ⓘ POMINIĘTA  ${NAZWA} — wzorzec nie występuje dokładnie raz w $PLIK"
    POMINIETE=$((POMINIETE+1)); POMINIETE_LISTA="$POMINIETE_LISTA $NAZWA"; _post POMINIETA "$NAZWA"
    cofnij "$PLIK" || echo "  ✗ ŚCIEŻKA WSTECZNA: $PLIK NIE WRÓCIŁ (cp ×4 padło)" >&2; continue
  elif [ "$rc_mut" -ne 0 ]; then
    echo "  ✗ AWARIA MUTATORA  ${NAZWA} — mutator zwrócił rc=${rc_mut} na $PLIK (to NIE jest wynik pomiaru)"
    AWARIE=$((AWARIE+1)); AWARIE_LISTA="$AWARIE_LISTA $NAZWA"
    cofnij "$PLIK" || echo "  ✗ ŚCIEŻKA WSTECZNA: $PLIK NIE WRÓCIŁ (cp ×4 padło)" >&2; continue
  fi

  _odcisk "$PLIK" > "$ZAPAS/$(klucz "$PLIK").odcisk"   # B4: odcisk pliku PO mutacji — zapisany PRZED uruchomieniem komendy (to ona bywa ubijana)
  set +e; MUTACJE_W_BIEGU="${_TOZSAMOSC:-?}" eval "$KOMENDA" >/dev/null 2>&1; RC=$?; set -e
  cofnij "$PLIK" || echo "  ✗ ŚCIEŻKA WSTECZNA: $PLIK NIE WRÓCIŁ po mutacji ${NAZWA} (cp ×4 padło)" >&2   # przywróć NATYCHMIAST, nie na końcu

  if [ "$RC" -ne 0 ]; then
    echo "  ✓ ZŁAPANA    ${NAZWA}"; ZLAPANE=$((ZLAPANE+1)); _post ZLAPANA "$NAZWA"
  else
    echo "  ✗ ŚLEPA      ${NAZWA}  → «${KOMENDA}» przeszło mimo błędu"
    SLEPE=$((SLEPE+1)); SLEPA_LISTA="$SLEPA_LISTA $NAZWA"; _post SLEPA "$NAZWA"
  fi
done < "$REJESTR"

echo
echo "  zmierzone: złapanych ${ZLAPANE} · ŚLEPYCH ${SLEPE} · ŚWIADKÓW MARTWYCH ${SWIADKOWIE} · pominiętych ${POMINIETE} · AWARII ${AWARIE}"
[ "$POZA_ODLEWEM" -gt 0 ] && echo "  ⓘ POZA ODLEWEM: ${POZA_ODLEWEM} — pozycje dotykające plików, które nie jadą w wydaniu.
     To NIE jest utrata pomiaru: mierzy je bramka 3 na gałęzi pracy, gdzie te pliki istnieją."
[ "$WZNOW" = 1 ] && echo "  ⓘ WZNOWIENIE: ${WZNOW_ILE} werdyktów z zapisu postępu, reszta zmierzona w tym biegu — liczby wyżej obejmują CAŁY rejestr."
if [ "$AWARIE" -eq 0 ]; then
  echo "  ⓘ AWARII mutatora: 0 (zero znaczące — mutator odpowiedział na każdej próbie, nic nie milczało)."
fi
# ── KONTROLA PO PĘTLI (03.09.2026): czy ciało wróciło takie, jakie było ──
# Najpierw jawne przywrócenie (to samo, co trap — idempotentne), potem pomiar. Tu nie ma
# przejściowości: plik jest zmutowany albo nie. rc=8 własny; przyrząd NIE dotyka gita —
# przywrócenie z historii to decyzja ręki (przyrząd tnący nie może być leczącym, #56).
przywroc; trap - EXIT INT TERM
if [ "$_GIT" -eq 0 ]; then
  _PO="$(git status --porcelain 2>/dev/null)"
  if [ "$_PO" != "$_PRZED" ]; then
    echo "  ✗ CIAŁO NIE WRÓCIŁO — pliki, których stan po biegu różni się od stanu przed:"
    { diff <(printf '%s\n' "$_PRZED") <(printf '%s\n' "$_PO") || true; } | grep '^[<>]' | sed 's/^/      /' || true   # diff rc=1 to sygnał, nie awaria (set -e)
    echo "    Bieg NIEWAŻNY. Przywróć ręką: git checkout -- <plik> (przyrząd nie tyka historii)."
    exit 8
  fi
else
  echo "  ⓘ poza repo git — kontrola ciała PO biegu pominięta (ZAPAS przywrócony, git status niedostępny)"
fi
# ── ZAMEK NA AWARIĘ MUTATORA (09.09.2026, rozdzielenie rc mutatora od `if !`) ──
# AWARIA (rc_mut != 0 i != 3) NIE jest pomiarem — mutator padł, zanim zdążył cokolwiek
# zmierzyć na materiale. Nie wolno jej milczeć w POMINIĘTE ani w zamku na ciszę (rc=5):
# obie te kategorie mówią „zmierzono i wyszło zero/pominięcie", a to jest „nie zmierzono
# wcale, bo narzędzie nie odpowiedziało". Kod własny (9), nieosiągalny dla innych stanów.
if [ "$AWARIE" -gt 0 ]; then
  echo "  ✗ AWARIA MUTATORA (${AWARIE}):${AWARIE_LISTA}"
  echo "    Mutator padł na materiale — to NIE jest wynik pomiaru, nie licz tego jako pominięcie."
  exit 9
fi
# ── #116 (22.09.2026) — REGRES ZBIORU POMINIĘTYCH ──────────────────────────────────
# Pojedynczy bieg melduje LICZBĘ pominiętych, ale nie mówi, czy to TE SAME pozycje co
# ostatnio. Wzorzec (SZUKAJ) rozjeżdża się z ciałem tą samą klasą co M1 (fakt trzymany
# w dwóch miejscach, zmieniany osobno) i cicho wpada do POMINIĘTA — a liczba tego nie
# odróżnia od pozycji, która jest pomijana ZAWSZE (np. z powodu gałęzi odlewu, patrz
# POZA ODLEWEM wyżej — to inna klasa, osobno licznikowana, tu nietknięta). Pozycja,
# której NIE BYŁO w zbiorze pominiętych z POPRZEDNIEGO biegu, jest regresem: coś było
# mierzalne, przestało być, i sama liczba (bez porównania zbiorów) tego nie pokazuje.
# Aktywne WYŁĄCZNIE na prawdziwym rejestrze (`_PREFLIGHT_AKTYWNY`, ta sama granica co
# biała lista odlewu wyżej) — fikstury torów własnych mają WŁASNE, celowe pominięcia,
# a osądzanie ich tym mechanizmem byłoby błędem #50 (miara na cudzym materiale).
# PIERWSZY BIEG (brak śladu z poprzedniego) NIE ALARMUJE — bootstrap, nie ma z czym
# porównać (ta sama zasada co M1: dzień narodzin nie może oblewać sam siebie).
# `POMINIETE_SLAD` (jak `ZAMEK_BIEGU_PLIK` przy #112) — WYŁĄCZNIE do podmiany w torze
# własnym, żeby nie dotykać śladu prawdziwego repo.
if [ "$_PREFLIGHT_AKTYWNY" -eq 1 ]; then
  POMINIETE_PLIK="${POMINIETE_SLAD:-kanon/pomiary/MUTACJE_pominiete.txt}"
  NOWE_POMINIETE=""
  if [ -f "$POMINIETE_PLIK" ]; then
    for _pn in $POMINIETE_LISTA; do
      grep -qxF "$_pn" "$POMINIETE_PLIK" 2>/dev/null || NOWE_POMINIETE="$NOWE_POMINIETE $_pn"
    done
  fi
  mkdir -p "$(dirname "$POMINIETE_PLIK")" 2>/dev/null || true
  printf '%s\n' $POMINIETE_LISTA | grep -v '^$' | sort -u > "$POMINIETE_PLIK.nowy" 2>/dev/null || true
  mv -f "$POMINIETE_PLIK.nowy" "$POMINIETE_PLIK" 2>/dev/null || true
  if [ -n "$NOWE_POMINIETE" ]; then
    echo "  ✗ REGRES POMINIĘTYCH (#116):${NOWE_POMINIETE}"
    echo "    Ta pozycja nie była pominięta w poprzednim biegu zarejestrowanym w $POMINIETE_PLIK —"
    echo "    wzorzec (SZUKAJ) mógł się rozjechać z ciałem. Sprawdź rejestr, zanim uznasz to za normę."
    exit 12
  fi
fi
# ── ZAMEK NA CISZĘ (02.09.2026, słowo twórcy: „Tnij") ──
# SLEPE=0 niosło DWA różne stany świata: „zmierzono wszystko, nic nie było ślepe"
# oraz „nie zmierzono niczego". Oba wychodziły rc=0, nierozróżnialnie — a to jest
# przyrząd, który WYCENIA straże, więc pętla domykała się na sobie. Zmierzone
# dwustronnie 02.09: Linux 144/0/16 rc=0, Windows (zaślepka python3) 0/0/160 rc=0
# i ten sam komunikat „✓ KAŻDA WSTRZYKNIĘTA WADA ZOSTAŁA ZŁAPANA".
# Brak pomiaru dostaje WŁASNY kod (5), nieosiągalny dla żadnego innego stanu:
# 0 = zmierzono i czysto · 1 = ślepe · 2 = brak rejestru · 3 = wzorzec · 4 = rekurencja · 6 = ZAREZERWOWANY (było: preflight python3, zdjęty 21.09.2026 wraz z zależnością) · 7 = preflight ścieżki wstecznej · 13 = wznowienie na zmienionym ciele (R4, 05.10.2026) · 8 = ciało nie wróciło · 9 = awaria mutatora (rc mutatora ≠ 0 i ≠ 3 — nie pomiar) · 10 = świadkowie martwi · 11 = zamek biegu (#112) — inny bieg PID żyje, odmowa startu · 12 = regres pominiętych (#116) — nowa pozycja pominięta, której nie było w poprzednim biegu.
# Prarodzina SYGNAŁ ≠ PRAWDA, klasa #18 (zero jest daną, nie brakiem danej).
if [ "$ZLAPANE" -eq 0 ] && [ "$SLEPE" -eq 0 ]; then
  echo "  ✗ NIC NIE ZMIERZONO — 0 złapanych, 0 ślepych, ${POMINIETE} pominiętych."
  echo "    Cisza nie jest czystością. Sprawdź zdatność środowiska (node)"
  echo "    zanim uznasz brak alarmu za dowód zdrowia."
  exit 5
fi
# ── ZAMEK NA ŚLEPEGO ŚWIADKA (13.09.2026) ──────────────────────────────────
# Stoi PRZED werdyktem czystości: „0 ślepych" przy zepsutym mierniku znaczy „nie wiem",
# nie „czysto". Kod własny (10), nieosiągalny dla żadnego innego stanu.
if [ "$SWIADKOWIE" -gt 0 ]; then
  echo "  ✗ ŚWIADKOWIE MARTWI (${SWIADKOWIE}):${SWIADKOWIE_LISTA}"
  echo "    Te pozycje NIE BYŁY ZMIERZONE: ich świadek oblewa niezależnie od mutacji,"
  echo "    więc meldowałby ZŁAPANĄ także nad ciałem bez wady. Napraw tor świadka"
  echo "    albo przepnij pozycję na świadka, który umie przejść — nie licz tego jako pokrycie."
  exit 10
fi
if [ "$SLEPE" -eq 0 ]; then
  echo "  ✓ KAŻDA WSTRZYKNIĘTA WADA ZOSTAŁA ZŁAPANA — straże mierzą to, co deklarują."
  exit 0
fi
echo "  ✗ ŚLEPE PUNKTY:${SLEPA_LISTA}"
echo "    Straż, która nie oblewa na prawdziwym błędzie, nie chroni — tylko świeci."
exit 1
