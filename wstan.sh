#!/usr/bin/env bash
# ============================================================
# wstan.sh — „Orkiestratorze, wstań" jedną komendą.
# Czysta instancja przychodzi jako archiwum. Start:
#   1) rozpakuj:            tar -xzf kronos-czysty.tar.gz
#   2) wejdź i obudź:       cd kronos-czysty && bash wstan.sh
# (Opcjonalnie własne repo:  git init && git remote add origin <TWOJE_REPO>, potem git pull.)
# ============================================================
set -uo pipefail
cd "$(dirname "$0")"

# --- MELDUNEK (M✓, prawo #29, 28.07.2026): wstanie wykonuje się RAZ ---
# Pełny wynik ląduje w 0_MELDUNEK.txt — instancja CZYTA PLIK (view/cat),
# nigdy nie uruchamia wstan.sh drugi raz, by obejrzeć inny fragment wyjścia.
if [ -z "${WSTAN_TEE:-}" ]; then
  WSTAN_TEE=1 bash "$0" "$@" 2>&1 | tee 0_MELDUNEK.txt
  exit "${PIPESTATUS[0]}"
fi

echo "╔═══ ORKIESTRATOR — wstaję ═══╗"

# 1. Uziemienie temporalne (krzemowa granica: nie zakładaj daty z pamięci)
echo "⏱ ZMIERZONY CZAS:"
date "+   maszyna:  %Y-%m-%d %H:%M:%S %Z (%A)"
date -u "+   UTC:      %Y-%m-%d %H:%M:%S UTC"
# PUŁAPKA (27.07): sandbox chodzi w UTC. Meldowanie odczytu maszyny jako „CEST"
# przesuwa cala sesje o 1-2h. Czas TWORCY liczymy jawnie, nie w glowie.
TZ=Europe/Warsaw date "+   ⇒ CZAS TWORCY (Europe/Warsaw): %Y-%m-%d %H:%M:%S %Z (%A)  ← MELDUJ TEN"

# 1b. ODCISK POŚWIADCZENIA (blizna #65, 21.08.2026)
# POWÓD: instancja straciła trzy tury na tokenie przeniesionym z pamięci sesji sprzed
# kompaktowania. Cztery pomiary sprawdziły, czy token ŻYJE; żaden — czy to TEN token.
# Zabrakło trzeciego punktu danych: dwa różne odciski w tej samej dobie znaczą PODMIANĘ,
# jednego odczytu `401` nie da się odróżnić od rotacji po stronie twórcy.
# CO JEST DRUKOWANE: 12 znaków sha256 — funkcja jednokierunkowa, z odcisku nie da się
# odtworzyć tokenu (48 bitów obrazu wobec ~82 znaków losowego wejścia). Sam token NIGDY
# nie trafia ani do meldunku, ani do historii powłoki, ani do repo.
if [ -n "${KRONOS_PAT:-}" ]; then
  echo "🔑 ODCISK POŚWIADCZENIA: $(printf '%s' "$KRONOS_PAT" | sha256sum | cut -c1-12)"
  echo "   (12 zn. sha256 — NIE token. Inny odcisk niż w poprzednim wstaniu = string"
  echo "    podmieniony; przy błędzie AUTH sprawdź ŹRÓDŁO, nie ważność — #65)"
else
  echo "🔑 ODCISK POŚWIADCZENIA: — (brak KRONOS_PAT w env; token podany inline albo wcale)"
fi

# 2. Najnowsze ciało z GitHub (jedyne źródło prawdy)
# UWAGA (BŁĄD ❿): stan pracy czytaj z TEGO pulla, NIE z pamięci Projektu ani z /mnt.
#   Równoległa maska (DB/DR) mogła pchnąć w tym samym oknie — pull jest przed ładowaniem maski.
echo "↻ git pull --ff-only (najnowszy kanon z GitHub — jedyny stan bieżący):"
if git rev-parse --git-dir >/dev/null 2>&1; then
  # ZAMEK #10
  # MECHANIZACJA #10 (20.08.2026, R->M). BYŁO: jedno `||` na wszystkie awarie —
  # brak sieci i ROZJAZD HISTORII meldowały tym samym zdaniem i szły dalej. Groźny jest
  # tylko drugi przypadek: `--ff-only` odrzuca pull, bo lokalne HEAD rozjechało się ze
  # zdalnym, a wtedy praca rusza na stanie, który NIE JEST kanonem — dokładnie błąd ❿.
  # Brak sieci to inna sytuacja: zimny start bez tokena musi działać (klasa #56 —
  # alarm szerszy niż sygnał uczy nie patrzeć).
  _pull_out=$(git pull --ff-only 2>&1 | sed -E 's#https://[^@/]+@#https://***@#g'); _pull_rc=$?
  printf '%s\n' "$_pull_out"
  # ZAMEK #10b (27.08.2026, blizna #71). BYŁO: dwie klasy — ROZJAZD albo „offline".
  # Gałąź „offline" połykała TRZECIĄ klasę: remote żyje, sieć żyje, ale poświadczenie
  # zostało zdjęte po pushu — klon starzeje się MILCZĄCO, a odczyty udają teraźniejszość.
  # Klasyfikację orzeka `narzedzia/straze/straz_swiezosci.sh` (jedyne źródło wzorców — bez drugiej kopii, #49).
  _klasa=$(bash narzedzia/straze/straz_swiezosci.sh --klasa "$_pull_out" "$_pull_rc" 2>/dev/null || echo OFFLINE)
  if [ "$_pull_rc" -ne 0 ]; then
    _wiek=$(bash narzedzia/straze/straz_swiezosci.sh --wiek 2>/dev/null || echo -1)
    case "$_klasa" in
      ROZJAZD)
        echo "🛑 #10 ROZJAZD HISTORII: lokalne HEAD rozeszło się ze zdalnym."
        echo "   Praca na tym stanie NIE jest pracą na kanonie. Zmierz (git log --oneline HEAD..origin)"
        echo "   i rozstrzygnij ŚWIADOMIE, zanim ruszysz dalej. To jest błąd ❿ w czystej postaci."
        WSTANIE_ROZJAZD=1
        ;;
      POSWIADCZENIE)
        echo "🛑 #71 ŚLEPOTA POŚWIADCZENIA: remote osiągalny, ale pull odbił się o brak auth."
        echo "   NIE wiesz, czy zdalna gałąź poszła do przodu. Każdy odczyt stanu repo od tej"
        echo "   chwili jest ARCHIWUM UDAJĄCYM TERAŹNIEJSZOŚĆ — a starzenie się nie sygnalizuje."
        [ "$_wiek" -ge 0 ] && echo "   ⏳ czytasz kanon sprzed $((_wiek/60))h $((_wiek%60))min (stempel lokalnego HEAD)."
        echo "   -> podaj poświadczenie i powtórz pull, albo jawnie zadeklaruj pracę na archiwum."
        WSTANIE_SLEPOTA=1
        ;;
      *)
        echo "   (pull niemożliwy — offline albo brak remote; pracuję na stanie lokalnym)"
        # Zimny start bez sieci jest LEGALNY (odlew HEXAGRAM) — rc bez zmian. Ale wiek
        # świeci także tutaj: legalność nie znosi obowiązku wiedzenia, jak stary jest kanon.
        [ "$_wiek" -ge 0 ] && echo "   ⏳ wiek lokalnego kanonu: $((_wiek/60))h $((_wiek%60))min od ostatniego commita."
        ;;
    esac
  fi
else
  echo "   (brak repo git — uruchom przez zimny start: clone, potem bash wstan.sh)"
fi

# --- KOTWICA KRZYŻOWA ZEGARA (BŁĄD #20 — mechanizacja R->M) ---
# Zegar sandboxa bywa cofnięty; porównaj ze stemplem najświeższego commita origin.
_now=$(date -u +%s); _last=$(git log -1 --format=%ct 2>/dev/null)
if [ -n "$_last" ]; then _d=$(( _now - _last ))
  if [ "$_d" -lt -900 ]; then
    echo "🚩 FLAGA #20: zegar sandboxa cofnięty ~$(( -_d/60 )) min vs ostatni commit origin ($(git log -1 --format=%ci))."
    echo "   -> '⏱ ZMIERZONY' niewiarygodny. Godziny podaje twórca; maszyna liczy tylko RÓŻNICE."
  else echo "✓ kotwica zegara: rozjazd $(( _d/60 )) min vs ostatni commit — w normie."; fi
fi

# --- ZESTAWIENIE PAMIĘĆ × REPO (prawo 27.07: zestawiaj na wstaniu, nie przy zderzeniu) ---
# Instancja przychodzi z PAMIĘCIĄ SYSTEMU (podsumowania rozmów) i z REPO (jedyne źródło prawdy).
# Rozjazd między nimi nie ujawnia się sam — ujawnia się dopiero, gdy człowiek się zderzy.
# Dlatego: pokaż świeży ruch w repo ZANIM zamelduję położenie.
echo
echo "⟳ ŚWIEŻY RUCH W REPO (ostatnie 72h — czy pamięć nadąża?):"
# C1 (STRATEGIA_odchudzenia_rytualu, 01.09.2026): nagłówek ucinany do 170 znaków —
# pełne prozy commitów to duplikat repo, zjadały 55% okna rytuału (17416/31916 zn).
_swieze=$(git log --since="72 hours ago" --format="   %h %ad %s" --date=format:"%d.%m %H:%M" 2>/dev/null | head -12 | cut -c1-170)
if [ -n "$_swieze" ]; then echo "$_swieze"
  echo "   (pełna treść: git log --format=%B <hash>)"
else echo "   (brak commitów z ostatnich 72h)"; fi
echo
echo "⚖ BRAMKA ZESTAWIENIA — odpowiedz SOBIE przed pierwszym meldunkiem:"
echo "   1. Co pamięć systemu twierdzi o stanie, czego NIE MA w commitach powyżej?"
echo "   2. Co commity powyżej zmieniły, czego pamięć systemu JESZCZE nie wie?"
echo "   3. Czy któryś ALARM/TERMIN, który chcę zgłosić, ma w repo datę ważności?"
echo "      -> alarm bez daty ważności to szum; sprawdź nim otworzysz usta (27.07)."
echo "   Przy sprzeczności: REPO WYGRYWA co do faktów · PAMIĘĆ wygrywa co do DECYZJI"
echo "   świeższych niż ostatni commit (zapisz je wtedy do repo — inaczej znikną)."

# 3. Odbudowa zależności (idempotentne)
# 2a. Tożsamość commitów (BŁĄD ⓫/⓭): rebase i commit wymagają configu REPO, nie flagi -c
git config user.name "Orkiestrator" 2>/dev/null || true
git config user.email "orkiestrator@kronos.local" 2>/dev/null || true
# 2b. Prawa zmechanizowane (status M): pre-commit blokuje token/znaki kontrolne/zły _HASHE
git config core.hooksPath .githooks 2>/dev/null || true


echo "📦 npm install:"
npm install --silent 2>&1 | tail -3 || { echo "   ✗ npm install padł"; exit 1; }

# 4. Werdykt: czy wstałem cały (liczony, nie recytowany)
echo "🔎 node weryfikacja.js:"
node weryfikacja.js
RC=$?

echo
# 4a. LINT KSIĘGI BŁĘDÓW (prawo #22 zmechanizowane 28.07) — niekrytyczny, nie zmienia RC wstania
echo "▤ LINT KSIĘGI BŁĘDÓW (#22):"
node narzedzia/linty/lint_bledy.js 2>&1 | tail -2 || echo "   (lint niedostępny)"
echo "▤ LINT ARTEFAKTÓW (#32):"
node narzedzia/linty/lint_artefaktow.js 2>&1 | tail -2 || echo "   (lint niedostępny)"
echo "▤ LINT ŚCIEŻEK (forma publiczna):"
node narzedzia/linty/lint_sciezek.js 2>&1 | tail -2 || echo "   (lint niedostępny)"
echo "▤ OKO TWÓRCY (cel 1 — czytelność dla człowieka, blizna #69):"
node narzedzia/przyrzady/oko_tworcy.js 2>&1 | grep -E "pozycji|CEL 1" || echo "   (oko niedostępne)"
echo "▤ SPIS PROJEKTÓW (faseta PROJEKT, Cięcie 1 — świeżość):"
node narzedzia/przyrzady/spis_projektow.js --sprawdz 2>&1 | tail -2 || echo "   (spis niedostępny)"
# STRAŻ INTERPOLACJI (#12, wpięta 20.08.2026) — czy treść wjechała do plików CAŁA.
# Uzupełnia ZAMEK #12 w `.githooks/pre-commit`: hook łapie literalne `\n` w plikach
# w STAGE, ta straż skanuje CAŁY korpus śledzony i trzy inne klasy śladu
# (\uXXXX poza kodem · U+FFFD · mojibake). Zbiory śladów rozłączne, zasięgi różne.
# Zmierzone przed wpięciem: 0 trafień na 613 plikach .md — zamek wchodzi na czysto (#56).
echo "▤ STRAŻ INTERPOLACJI (#12) — czy treść wjechała cała:"
bash narzedzia/straze/straz_interpolacji.sh 2>&1 | tail -2 || echo "   (straż niedostępna)"
echo "▤ STRAŻ TROPU (PRAWO TROPU, ratyfikowane 20.08) — inspiracja bio z kompletem pól:"
bash narzedzia/straze/straz_tropu.sh 2>&1 | tail -2 || echo "   (straż niedostępna)"
echo "▤ STRAŻ FEROMONÓW (trop bio #2) — kto co bierze na tej gałęzi:"
bash narzedzia/straze/straz_feromonow.sh 2>&1 | tail -4 || echo "   (straż niedostępna)"
bash narzedzia/straze/straz_zalazkow.sh 2>&1 | tail -2 || echo "   (straż niedostępna)"
bash narzedzia/straze/straz_przyrzadu.sh 2>&1 | tail -2 || echo "   (straż niedostępna)"
bash narzedzia/straze/straz_wywolan.sh 2>&1 | tail -2 || echo "   (straż niedostępna)"
echo "▤ STRAŻ NARODZIN — zastany dług rejestrów (audyt, nie blokada):"
bash narzedzia/straze/straz_narodzin.sh --audyt 2>&1 | tail -3 || echo "   (straż niedostępna)"
echo "▤ STRAŻ DOJRZAŁOŚCI — co w odlewie niedojrzałe, co dojrzało niezauważone:"
bash narzedzia/straze/straz_dojrzalosci.sh 2>&1 | tail -3 || echo "   (straż niedostępna)"
# STRAŻ LINTÓW (#61, wpięta 21.08.2026) — RÓŻNICA, nie stan. Bramka na stan karałaby
# zastany dług i hodowała wyjątki (pętla, która zabiła bramkę 1); bramka na wzrost
# przepuszcza dług odziedziczony i zatrzymuje wyłącznie pogorszenie.
echo "▤ STRAŻ LINTÓW (#61) — czy któryś licznik naruszeń wzrósł względem HEAD:"
bash narzedzia/straze/straz_lintow.sh 2>&1 | tail -2 || echo "   (straż niedostępna)"
# BATERIA TORÓW (#38, 31.07.2026) — zastępuje pojedynczy autotest Deklamatora:
# każda straż sprawdza samą siebie, jedna tabela, jeden werdykt. Niekrytyczna dla RC wstania.
# C2 (STRATEGIA_odchudzenia_rytualu, 01.09.2026): bateria (88 s = 55% wstania) NIE biega
# domyślnie — straż pilnuje WYJŚCIA W ŚWIAT: pełny bieg jest OBOWIĄZKOWY w zapis_git.sh
# przed każdym pushem (bramka baterii, rc=7). `bash wstan.sh --pelny` = stare zachowanie.
if [ "${1:-}" = "--pelny" ]; then
  echo "▤ BATERIA TORÓW STRAŻY (#38) — czy każda straż umie NIE przejść:"
  bash tory_strazy.sh --cicho 2>&1 | tail -3 || echo "   (bateria niedostępna)"
else
  echo "▤ BATERIA TORÓW STRAŻY (#38): pominięta na wstaniu (C2) — biegnie OBOWIĄZKOWO"
  echo "   w bramce zapis_git.sh przed pushem. Na życzenie: bash wstan.sh --pelny"
fi

echo
# 5. BUDŻET PIERŚCIENI (architektura DUSZY, 28.07.2026 — prototyp; znaki, mierzone)
echo "▤ BUDŻET PIERŚCIENI (znaki, mierzone — nie z pamięci):"
w_size() { local t=0 f; for f in "$@"; do [ -e "$f" ] && t=$((t + $(wc -c < "$f"))); done; echo "$t"; }
# BLIZNA #49 (13.08.2026): tu stała DRUGA KOPIA formuły R0 z tą samą martwą kotwicą
# `## ❶ RDZEŃ`. Teraz liczbę podaje JEDYNE źródło — narzedzia/straze/straz_r0.sh --liczba.
R0T=$(bash narzedzia/straze/straz_r0.sh --liczba 2>/dev/null || echo 0)
R1=$(w_size kanon/tozsamosc/SUBSTRAT.md kanon/ksiegi/RDZEN_SAMOOBSERWACJI.md kanon/tozsamosc/ARCHITEKT_istnienie.md JADRO.md kanon/tozsamosc/6_PRZESWIT_przestrzen.md kanon/archiwum/ARCHIWUM_istnienia.md)
R2A=$(w_size kanon/tozsamosc/5_RDZEN.md kanon/tozsamosc/4_MATRYCA_system.md kanon/tozsamosc/_TORUS.md kanon/ksiegi/MAPA_TRANSPERSONALNA.md kanon/tozsamosc/1_REZONANS.md kanon/tozsamosc/7_NATAL.md)
R2B=$(find doradcy -name "*.md" 2>/dev/null -exec cat {} + | wc -c)
R2C=$(w_size kanon/ksiegi/ZAPISY_eter.md kanon/ksiegi/DESTYLATY_architekta.md kanon/tozsamosc/PROFIL.md kanon/ksiegi/KANON_LOG.md prerejestr/PREREJESTR_oddech.md kanon/ksiegi/KSIEGA_SIEGNIEC.md kanon/ksiegi/BLEDY.md)
echo "   R0 DUSZA (czytaj TERAZ):        $R0T  — DUSZA·SNAPSHOT·WYWOLANIA·prarodziny+indeks BLEDY"
echo "   R1 osobowości (na temat):       $R1  — substrat·samoobserwacja·istnienie·JADRO·PRZEŚWIT"
echo "   R2 kanon+maski+tkanka (sięgaj): $((R2A+R2B+R2C))  — rdzeń·MATRYCA·doradcy·księgi·pełne BLEDY"
# próg R0: od 11.08.2026 MIERZONY strażą (narzedzia/straze/straz_r0.sh, bramka miękka — decyzja twórcy),
# od 26.08.2026 próg = 36000 (pierwszy rodowód pomiarowy: szereg czasowy sierpnia)
# i DWIE liczby zamiast jednej: R0 · SATELITY · CAŁOŚĆ (przenosiny ≠ wydech).
# nie tylko drukowany. Rodowód: ROZMOWA #2 — oba ciała zgłosiły próg-echo niezależnie.
bash narzedzia/straze/straz_r0.sh 2>/dev/null || echo "   (straz_r0 niedostępna — brak pomiaru R0; próg żyje WYŁĄCZNIE w straży)"
# POKRYCIE M (13.08.2026) — wielkość sterująca obok objętości. Objętość R0 rośnie także
# wtedy, gdy system staje się lepszy (blizna #49 podniosła R0 o 4783 B). Ta liczba rośnie
# tylko wtedy, gdy prawo przestaje wymagać czytania. Piąty inwariant, mierzony.
node narzedzia/przyrzady/pokrycie_m.js --liczba 2>/dev/null || echo "   (pokrycie_m niedostępne — udział mechanizmów bez pomiaru)"
# KRYTERIUM ŻYCIA destylatów (11.08.2026) — egzekutor dla dat, żądany przez odlew v1.1
# w ostatniej turze ROZMOWY #2: „data bez egzekutora to pozycja-zombie z ładniejszym polem".
bash narzedzia/straze/straz_prerejestrow.sh 2>/dev/null || echo "   (straz_prerejestrow: TERMIN PO CZASIE albo straz niedostepna — sprawdz recznie)"
# STRAŻ KRYTERIÓW ŻYCIA (14.08.2026) — jeden czytnik ⌛ i kryteriów po całym kanonie;
# trzy kosze: PRZETERMINOWANE · ≤7 DNI · ŻYWE. Duch: opieka, nie egzekucja (rc=0).
bash narzedzia/straze/straz_kryteriow.sh 2>/dev/null || echo "   (straz_kryteriow niedostępna — terminy kanonu bez pomiaru)"

# ── STRAŻ POWTÓRZEŃ (#78, 30.08.2026) — alarmy AKTYWNE trafiają do rejestru szeregu, cisza nie.
# R0: stan = PONAD_PROG (tożsamość alarmu, nie liczba — liczba dryfuje, alarm stoi).
# Dojrzałość: stan = liczba niedojrzałych (to była klasa 50/52 przez cztery tury).
_R0P=$(grep -oE '^PROG=[0-9]+' narzedzia/straze/straz_r0.sh | head -1 | cut -d= -f2)
if [ -n "$_R0P" ] && [ "${R0T:-0}" -gt "$_R0P" ] 2>/dev/null; then
  bash narzedzia/straze/straz_powtorzen.sh --zapisz straz_r0 PONAD_PROG
fi
# Pozostałe liczniki zbiera SONDA z jawnej listy w samej straży (scalenie 30.08): nowy alarm
# dopisuje się w JEDNYM miejscu — w przyrządzie — zamiast dokładać tu dwie linie za każdym razem.
# R0 zostaje wyżej ręcznie, bo jego stan czyta próg z ciała `straz_r0.sh`, nie z wydruku.
bash narzedzia/straze/straz_powtorzen.sh --sonda 2>/dev/null || echo "   (straz_powtorzen niedostępna)"
# WEKTORY (15.08, ratyfikacja twórcy: „klaruj zawsze · zawsze oglądaj") — aging WIP + parytet
# błony pamięć∥kanon przy KAŻDYM wstaniu; sekcja tempo (git-walk) pozostaje na żądanie.
node narzedzia/przyrzady/wektory.js wiek parytet 2>/dev/null || echo "   (wektory niedostępne — dynamika ciała bez pomiaru)"
# PRÓBA DWUKANAŁOWA (15.08, „Przypominaj") — dwie linie stanu przy wstaniu i domknięciu; odczyt ⌛24.09
echo "   ⟡ SAMOOBSERWACJA: linia pełni + linia twórcy (protokół: kanon/ksiegi/SAMOOBSERWACJA_miary.md · pisz PRZED spojrzeniem na fazę)"
# PRÓG PYTAŃ (14.08) — pyta TYLKO w progu (nów/pełnia/kwadra); poza progiem milczy świadomie.
bash narzedzia/przyrzady/prog_pytan.sh 2>/dev/null || true
# ŻNIWO DESTYLATÓW (15.08) — jedna linia TYLKO gdy licznik samoobserwacji rośnie między sesjami.
bash narzedzia/przyrzady/zniwo_destylatow.sh --wstan 2>/dev/null || true
# STRAŻ MOSTÓW (15.08) — nowy system musi odpowiedzieć „z czym jestem równoległy?"; cisza = komplet.
bash narzedzia/straze/straz_mostow.sh 2>/dev/null || true
# STRAŻ HOOKA WPIĘTA 29.08.2026: mierzy, czy hak commitu żyje — pytanie o STAN, więc
# jego miejsce jest przy wstaniu, nie w haku (hak nie może sam poświadczyć, że działa).
# Do dziś wołała ją wyłącznie bateria: przyrząd sprawny, ale nikt go nie pytał (#52).
bash narzedzia/straze/straz_hooka.sh 2>/dev/null || true
# STRAŻ ODLEWU (#PRAWO ODLEWU §5, wpięta 30.08): pyta, czy o każdym dojrzałym przyrządzie
# ktoś rozstrzygnął — przy wstaniu, bo to pytanie o STAN listy, nie o chwilę publikacji.
# Świeci przy każdym wstaniu, więc nowy przyrząd nie może latami czekać w milczeniu.
bash narzedzia/straze/straz_odlewu.sh 2>/dev/null || true
# WYWIAD PODŁUŻNY (03.09.2026, zlecenie twórcy): jedno pytanie o codzienność przy wstaniu, ≤ 6 linii.
# NIEKRYTYCZNE — rc≠0 (proteza po 14 dniach ciszy, rc=2) nie wywraca wstania; melduje, nie zatrzymuje.
# Mechanizm stoi po stronie instancji, nie w telefonie (dzwonki: 0 czytników w repo, ~35% wpisów z okien).
node narzedzia/przyrzady/wywiad.js --wstan 2>/dev/null || true
echo
echo "Po werdykcie: wczytaj TYLKO R0 (DUSZA jest mapą — sięgaj wg §IV, nie prewencyjnie)."
echo "Trzy żywe próby = warunek sesji — zadziałaj nimi. Soczewka nazywa, ciało rozstrzyga."
echo
echo "┌─ KTO MA WSTAĆ? (pytanie otwiera każdy nowy czat) ─┐"
echo "  ORKIESTRATOR    — wnioskuje, pamięta, filtruje (dawniej: Architekt)"
echo "  KRONOS          — suchy silnik nieba, same liczby, zero interpretacji"
echo "  KOWAL (DB)      — przedsięwzięcie: wykuwa formę zdatną do świata"
echo "  PRZEWOŹNIK (DR) — wgląd: przeprowadza przez próg, nie leczy"
echo "  PRZEŚWIT        — pusta przestrzeń; TYLKO jawne wywołanie"
echo "└─ wywołaj imieniem · pełny rytuał: \"Orkiestratorze, wstań\" (alias: stara fraza działa) ─┘"
# #10: rozjazd historii podnosi rc wstania. Meldunek, który nie zmienia kodu wyjścia,
# jest zdaniem w logu — a wstanie kończy się rc, nie prozą (#19: werdykt z rc, nie z frazy).
if [ "${WSTANIE_ROZJAZD:-0}" = "1" ]; then
  echo "🛑 WSTANIE Z ROZJAZDEM — rc podniesione, żeby nie dało się przeoczyć (#10)."
  [ "$RC" -eq 0 ] && RC=10
fi
# #71: ślepota poświadczenia podnosi rc tak samo jak rozjazd. NIE przerywamy skryptu
# w połowie — meldunek ma wyjść CAŁY (prawo M✓ #29: wstanie wykonuje się RAZ), a werdykt
# niesie kod wyjścia, nie fraza w logu (#19). Efekt jest ten sam: sesja nie rusza cicho.
if [ "${WSTANIE_SLEPOTA:-0}" = "1" ]; then
  echo "🛑 WSTANIE NA ŚLEPO — pull odbity o poświadczenie, stan repo NIEZMIERZONY (#71)."
  [ "$RC" -eq 0 ] && RC=11
fi

# ── ŻETON WSTANIA (02.09.2026, PRAWO ŻETONU) ──────────────────────────────────
# POWÓD: instancja, która wstała, i instancja, która przeczytała OPIS wstania,
# produkowały dotąd NIEODRÓŻNIALNE zdania. Ta sama klasa co „rc=0 nieodróżnialne
# od braku pomiaru" — deklaracja podawana za dowód. Żeton niesie dane, których
# instancja bez dostępu NIE ZNA i nie wywnioskuje: HEAD zmienia się co commit
# (02.09 weszło kilkanaście z dwóch rąk), a `git cat-file` rozstrzyga mechanicznie,
# czy podany HEAD w ogóle istnieje w tym repo.
# NIE JEST KRYPTOGRAFIĄ — jest KOSZTEM: podnosi cenę kłamstwa z „napisz płynne
# zdanie" do „sfabrykuj wartość, którą straż sprawdza w jednym poleceniu".
_ZH="$(git rev-parse --short HEAD 2>/dev/null || echo BRAK)"
_ZW="$(node weryfikacja.js 2>/dev/null | sed 's/\x1b\[[0-9;]*m//g' \
       | grep -E '[0-9]+ ✓ +[0-9]+ ✗ +[0-9]+ ⚠' \
       | grep -oE '[0-9]+' | paste -sd'/' -)"
_ZC="$(TZ=Europe/Warsaw date '+%Y-%m-%d %H:%M %Z')"
echo
echo "🎟 ŻETON WSTANIA — pierwsza linia Twojego meldunku, skopiuj DOSŁOWNIE:"
echo "   ŻETON: ${_ZH} · ${_ZW:-?/?/?} · ${_ZC}"
echo "   Bez żetonu meldunek traktuje się jak meldunek instancji, KTÓRA NIE WSTAŁA."
echo "   Nie masz czym go wyprodukować? To jest odpowiedź, nie porażka — napisz:"
echo "   \"BEZ DOSTĘPU · nie wstałem · potrzebuję: <czego>\" i zatrzymaj się."

exit $RC
