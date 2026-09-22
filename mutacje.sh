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
# KATALOG PRACY: przechodzimy do repo TYLKO gdy rejestr nie został wskazany z zewnątrz.
# Tor własny uruchamia skrypt na atrapie w mktemp — `cd` zjadłby mu ścieżkę rejestru.
# (Złapane własnym torem w minucie narodzin: przyrząd nie jest świadkiem własnej poprawności.)
if [ -z "${REJESTR:-}" ]; then cd "$(dirname "$0")"; REJESTR="mutacje.txt"; fi

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
przywroc() {
  for k in "$ZAPAS"/*; do
    [ -e "$k" ] || continue
    cel="$(printf '%s' "$(basename "$k")" | tr '%' '/')"
    mkdir -p "$(dirname "./$cel")" 2>/dev/null || true
    cp3 "$k" "./$cel" || echo "  ✗ ŚCIEŻKA WSTECZNA: $cel NIE WRÓCIŁ z zapasu (cp ×4 padło)" >&2
  done
  rm -rf "$ZAPAS" "${KESZ_SWIADKOW:-}"
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

  [ -n "$niemierzalne" ] && echo "  ? POZA ZASIĘGIEM PLATFORMY — brak pomiaru, NIE zaliczenie:$niemierzalne"
  if [ -z "$zle" ]; then
    echo "  ✓ MUTACJE ŻYWE — 8 torów: wykrytą melduje zielono, ŚLEPĄ STRAŻ melduje czerwono,"
    echo "    plik po przebiegu wraca bajt w bajt, bieg ZAGNIEŻDŻONY odmawia (rc=4) bez tknięcia materii,"
    echo "    a BRAK POMIARU melduje się osobnym kodem (rc=5) zamiast udawać sukces,"
    echo "    ŚCIEŻKA WSTECZNA: cel bez zapisu zatrzymuje PRZED pętlą (rc=7), awaria przejściowa ratowana ponowieniem,"
    echo "    a ciało, które nie wróciło, jest nazwane imiennie (rc=8) — nigdy ciszą."
    echo "    AWARIA MUTATORA (rc mutatora ≠ 0 i ≠ 3) jest kategorią OSOBNĄ od POMINIĘTA — rc=9, słowo AWARIA, nigdy cicho."
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

ZLAPANE=0; SLEPE=0; POMINIETE=0; SLEPA_LISTA=""; AWARIE=0; AWARIE_LISTA=""
SWIADKOWIE=0; SWIADKOWIE_LISTA=""
POZA_ODLEWEM=0
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
    POZA_ODLEWEM=$((POZA_ODLEWEM+1)); continue
  fi
  if [ ! -f "$PLIK" ]; then
    echo "  ⓘ POMINIĘTA  ${NAZWA} — brak pliku $PLIK"; POMINIETE=$((POMINIETE+1)); continue
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
      SWIADKOWIE=$((SWIADKOWIE+1)); SWIADKOWIE_LISTA="$SWIADKOWIE_LISTA $NAZWA"
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
    POMINIETE=$((POMINIETE+1)); cp3 "$ZAPAS/$(klucz "$PLIK")" "$PLIK" || echo "  ✗ ŚCIEŻKA WSTECZNA: $PLIK NIE WRÓCIŁ (cp ×4 padło)" >&2; continue
  elif [ "$rc_mut" -ne 0 ]; then
    echo "  ✗ AWARIA MUTATORA  ${NAZWA} — mutator zwrócił rc=${rc_mut} na $PLIK (to NIE jest wynik pomiaru)"
    AWARIE=$((AWARIE+1)); AWARIE_LISTA="$AWARIE_LISTA $NAZWA"
    cp3 "$ZAPAS/$(klucz "$PLIK")" "$PLIK" || echo "  ✗ ŚCIEŻKA WSTECZNA: $PLIK NIE WRÓCIŁ (cp ×4 padło)" >&2; continue
  fi

  set +e; MUTACJE_W_BIEGU="${_TOZSAMOSC:-?}" eval "$KOMENDA" >/dev/null 2>&1; RC=$?; set -e
  cp3 "$ZAPAS/$(klucz "$PLIK")" "$PLIK" || echo "  ✗ ŚCIEŻKA WSTECZNA: $PLIK NIE WRÓCIŁ po mutacji ${NAZWA} (cp ×4 padło)" >&2   # przywróć NATYCHMIAST, nie na końcu

  if [ "$RC" -ne 0 ]; then
    echo "  ✓ ZŁAPANA    ${NAZWA}"; ZLAPANE=$((ZLAPANE+1))
  else
    echo "  ✗ ŚLEPA      ${NAZWA}  → «${KOMENDA}» przeszło mimo błędu"
    SLEPE=$((SLEPE+1)); SLEPA_LISTA="$SLEPA_LISTA $NAZWA"
  fi
done < "$REJESTR"

echo
echo "  zmierzone: złapanych ${ZLAPANE} · ŚLEPYCH ${SLEPE} · ŚWIADKÓW MARTWYCH ${SWIADKOWIE} · pominiętych ${POMINIETE} · AWARII ${AWARIE}"
[ "$POZA_ODLEWEM" -gt 0 ] && echo "  ⓘ POZA ODLEWEM: ${POZA_ODLEWEM} — pozycje dotykające plików, które nie jadą w wydaniu.
     To NIE jest utrata pomiaru: mierzy je bramka 3 na gałęzi pracy, gdzie te pliki istnieją."
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
# ── ZAMEK NA CISZĘ (02.09.2026, słowo twórcy: „Tnij") ──
# SLEPE=0 niosło DWA różne stany świata: „zmierzono wszystko, nic nie było ślepe"
# oraz „nie zmierzono niczego". Oba wychodziły rc=0, nierozróżnialnie — a to jest
# przyrząd, który WYCENIA straże, więc pętla domykała się na sobie. Zmierzone
# dwustronnie 02.09: Linux 144/0/16 rc=0, Windows (zaślepka python3) 0/0/160 rc=0
# i ten sam komunikat „✓ KAŻDA WSTRZYKNIĘTA WADA ZOSTAŁA ZŁAPANA".
# Brak pomiaru dostaje WŁASNY kod (5), nieosiągalny dla żadnego innego stanu:
# 0 = zmierzono i czysto · 1 = ślepe · 2 = brak rejestru · 3 = wzorzec · 4 = rekurencja · 6 = ZAREZERWOWANY (było: preflight python3, zdjęty 21.09.2026 wraz z zależnością) · 7 = preflight ścieżki wstecznej · 8 = ciało nie wróciło · 9 = awaria mutatora (rc mutatora ≠ 0 i ≠ 3 — nie pomiar).
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
