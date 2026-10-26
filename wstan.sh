#!/usr/bin/env bash
# ============================================================
# wstan.sh — „Orkiestratorze, wstań" jedną komendą.
# Czysta instancja przychodzi jako klon repo. Start:
#   1) pobierz:             git clone <to-repo> HEXAGRAM
#   2) wejdź i obudź:       cd HEXAGRAM && bash wstan.sh
# (Opcjonalnie własne repo:  git init && git remote add origin <TWOJE_REPO>, potem git pull.)
# ============================================================
set -uo pipefail
_SS="$(dirname "$0")/narzedzia/silniki/strefa_st.sh"; if [ -f "$_SS" ]; then . "$_SS"; else _STREFA_ST=Europe/Warsaw; fi   # strefa instancji (wspólny fragment strefa_st.sh → tz_pl.js: KRONOS_TZ > instancja.json > package.json); psuty instancja.json = „STREFA?" + komunikat, nie cichy powrót do Warszawy
cd "$(dirname "$0")"
# C1b (25.10.2026): `--temat "<tekst>"` otwiera pokój z ładunkiem (drzwi_otworz niżej). Parsowane z kopii argumentów — obie warstwy (tee i wnętrze) dostają "$@" nietknięte.
_TEMAT=""; _arg=("$@"); for ((_i=0; _i<${#_arg[@]}; _i++)); do [ "${_arg[_i]}" = "--temat" ] && _TEMAT="${_arg[_i+1]:-}"; done

# ── K1 · RUCH INSTANCJI (23.09.2026, PLAN_korzen_w_wstaniu §3, słowo twórcy 21.09) ──────────
# POMIAR (21.09): meldunek 295 linii · 32 sekcje · pytanie do twórcy (WYWIAD) w linii 275 z 295 —
# instancja czyta meldunek pod werdykt, nie pod RUCH (BLEDY #109). Blok ≤ 4 linie na SAMEJ GÓRZE
# pliku: żeton · rozjazd (tylko gdy jest) · JEDNO pytanie do twórcy (wywiad.js — obszar rdzeń
# przed operacyjnymi, K2) · JEDNO pytanie pełni (ostatnia sekcja „⟐ PYTANIA <imię pełni>” w destylatach;
# czytnik nie zna imienia — każdy twórca nadaje własne, w odlewie sekcja nazywa się PYTANIA PEŁNI).
# Funkcje stoją PRZED zamkiem tee, bo blok powstaje z GOTOWEGO surowego meldunku (żeton i rozjazd
# rodzą się na końcu biegu, a blok ma stać na początku pliku). Tor: straz_wstania.sh (wycina
# je stąd i bije w to samo ciało, #50). Źródła nadpisywalne env-em WYŁĄCZNIE dla toru.
ruch_instancji() {   # $1 = surowy meldunek (plik) → ≤ 4 linie
  local raw="$1" zeton rozj pyt_id pyt_tw pyt_pe
  zeton="$(grep -m1 '^   ŻETON: ' "$raw" 2>/dev/null | sed 's/^   ŻETON: //')"
  # NAPRAWA (01.10.2026, ręka PRACOWNIA): wzorzec bez wiodącego 🛑 — GNU grep w Git-for-Windows
  # (MSYS, LANG puste) NIE dopasowuje literalnego znaku spoza BMP w ERE, więc `^🛑 ...` dawał
  # pusto tylko na Windows (straz_wstania podtesty RUCH 116/118). Fraza jest dość swoista;
  # złapana linia i tak niesie 🛑, więc meldunek bez zmian. Zmierzone: grep '🛑' = 0 trafień.
  rozj="$(grep -m1 -E 'WSTANIE (Z ROZJAZDEM|NA ŚLEPO)' "$raw" 2>/dev/null)"
  local wyw; wyw="$(node narzedzia/przyrzady/wywiad.js --wstan 2>/dev/null)"
  pyt_tw="$(printf '%s\n' "$wyw" | grep -m1 '^   → ' | sed 's/^   → //')"
  pyt_id="$(printf '%s\n' "$wyw" | grep -m1 -E '^   [A-Za-z0-9]+ · ' | awk '{print $1}')"
  pyt_pe="$(awk '
    /^### ⟐ PYTANIA / { blk=""; w=1; inq=0; next }
    w && (/^## / || /^### /)  { w=0 }
    w && /^> /                { if (!inq) { blk=""; inq=1 } sub(/^> ?/, ""); blk = blk " " $0; next }
    w                         { inq=0 }
    END                       { print blk }' "${RUCH_DESTYLATY:-kanon/ksiegi/DESTYLATY_architekta.md}" 2>/dev/null \
    | sed 's/^ *//; s/^\*//; s/\*$//')"
  echo "▶ RUCH INSTANCJI · ŻETON: ${zeton:-BRAK — wstanie niepełne, meldunek bez żetonu nie jest wstaniem}"
  [ -n "$rozj" ] && echo "  $rozj"
  echo "  ? do twórcy${pyt_id:+ ($pyt_id)}: ${pyt_tw:-— (rejestr pytań pusty albo nieczytelny)}"
  echo "  ? do pełni: ${pyt_pe:-— (brak pytania w ⟐ PYTANIA PEŁNI)}"
}
zloz_meldunek() { ruch_instancji "$1"; cat "$1"; }   # blok NA GÓRZE, surowy meldunek pod nim

# ── C1b · DRZWI Z ŁADUNKIEM (25.10.2026, PROJEKT_2410_roj_produkt §2; BLEDY #133 R) ───────────
# POMIAR (24.10): wstan.sh nie znał tematu; §DRZWI drukowało same role, a ładunek pokoju otwierała instancja
# z pamięci i podpisywała imieniem roli — deklaracja, nie pomiar. Lek: PRZYRZĄD otwiera pliki pokoju
# (prywatne/POKOJE.txt), drukuje ich treść, a linia `otwarte:` niesie odciski policzone z TYCH SAMYCH bajtów,
# które poszły na ekran (jedna zmienna: ekran i odcisk nie mogą się rozjechać). Brak POKOJE.txt = cisza
# (gość i odlew nie mają prywatne/). Tor: straz_wstania.sh wycina ten blok stąd (#50). Źródła nadpisywalne
# env-em WYŁĄCZNIE dla toru (DRZWI_POKOJE, DRZWI_OTWARTE).
drzwi_norm() { node -e 'process.stdout.write(require("fs").readFileSync(0,"utf8").normalize("NFD").replace(/[̀-ͯ]/g,"").replace(/[Łł]/g,"l").toLowerCase())'; }
drzwi_sekcja() {   # $1 plik, $2 początek nagłówka (bez #) → sama sekcja, do następnego nagłówka tego samego lub wyższego poziomu (fence'y pomijane)
  awk -v n="$2" '
    /^(```|~~~)/ { fen = !fen }
    !fen && /^#+[ \t]/ { l=0; t=$0; while (substr(t,1,1)=="#") { l++; t=substr(t,2) } sub(/^[ \t]+/,"",t)
                         if (f && l<=fl) exit
                         if (!f && index(t,n)==1) { f=1; fl=l } }
    f' "$1"
}
drzwi_druk() {   # $1 etykieta, $2 treść → nagłówek z odciskiem i bajtami TEJ treści, potem treść; ustawia _DR_H6 (sha6 wydrukowanych bajtów)
  local h; h="$(printf '%s' "$2" | tr -d '\r' | sha256sum | cut -c1-12)"; _DR_H6="${h:0:6}"
  echo "── $1 · $h · $(printf '%s' "$2" | wc -c | tr -d ' ') B"
  printf '%s\n' "$2"
}
drzwi_otworz() {   # $1 = temat (surowy) → blok pod werdyktem; wołane tylko z --temat
  local temat="$1" pok="${DRZWI_POKOJE:-prywatne/POKOJE.txt}" wyj="${DRZWI_OTWARTE:-.drzwi_otwarte}"
  [ -f "$pok" ] || return 0
  local tn kn tag nazwa klucze pliki skille mcp k n=0 nazwy="" t_nazwa="" t_pliki="" t_skille="" t_mcp=""
  tn="$(printf '%s' "$temat" | drzwi_norm)" || { echo "✗ DRZWI · normalizacja tematu padła (node) — pokój NIE rozstrzygnięty"; return 1; }
  while IFS='|' read -r tag nazwa klucze pliki skille mcp; do
    [ "$tag" = POKOJ ] || continue
    kn="$(printf '%s' "$klucze" | drzwi_norm)" || { echo "✗ DRZWI · normalizacja kluczy padła (node) — pokój NIE rozstrzygnięty"; return 1; }
    IFS=',' read -ra _ks <<< "$kn"
    for k in "${_ks[@]}"; do
      k="${k#"${k%%[![:space:]]*}"}"; k="${k%"${k##*[![:space:]]}"}"
      [ -n "$k" ] || continue
      case "$tn" in *"$k"*) n=$((n+1)); nazwy="${nazwy:+$nazwy / }$nazwa"; t_nazwa="$nazwa"; t_pliki="$pliki"; t_skille="$skille"; t_mcp="${mcp%$'\r'}"; break;; esac
    done
  done < "$pok"
  if [ "$n" -eq 0 ]; then echo "DRZWI · temat bez pokoju"; return 0; fi
  if [ "$n" -ge 2 ]; then echo "DRZWI · $([ "$n" -eq 2 ] && echo dwa pokoje || echo "$n pokoi"): $nazwy — jedno pytanie"; return 0; fi
  echo "▶ DRZWI Z ŁADUNKIEM · pokój $t_nazwa"
  local otw="" p sciezka sek tresc sk
  IFS=';' read -ra _pl <<< "$t_pliki"
  for p in "${_pl[@]}"; do
    p="${p#"${p%%[![:space:]]*}"}"; p="${p%"${p##*[![:space:]]}"}"
    [ -n "$p" ] || continue
    sciezka="${p%%#*}"; sek=""; [ "$p" != "$sciezka" ] && sek="${p#*#}"
    if [ ! -f "$sciezka" ]; then echo "✗ BRAK $sciezka"; otw="${otw:+$otw · }$sciezka@BRAK"; continue; fi
    if [ -n "$sek" ]; then tresc="$(drzwi_sekcja "$sciezka" "$sek")"; else tresc="$(cat "$sciezka")"; fi
    if [ -z "$tresc" ]; then echo "✗ BRAK $p"; otw="${otw:+$otw · }$p@BRAK"; continue; fi
    drzwi_druk "$p" "$tresc"; otw="${otw:+$otw · }$p@$_DR_H6"
  done
  IFS=',' read -ra _sl <<< "$t_skille"
  for sk in "${_sl[@]}"; do
    sk="${sk#"${sk%%[![:space:]]*}"}"; sk="${sk%"${sk##*[![:space:]]}"}"
    case "$sk" in ""|"—"*) continue;; esac
    if [ -f ".claude/skills/$sk/SKILL.md" ]; then drzwi_druk ".claude/skills/$sk/SKILL.md" "$(cat ".claude/skills/$sk/SKILL.md")"; else echo "✗ BRAK .claude/skills/$sk/SKILL.md"; fi
    if [ "$sk" = moja-reka ]; then   # profil stylu = sekcja 7 podręcznika (wymóg skilla: krok 1 WCZYTAJ PROFIL)
      tresc="$(drzwi_sekcja projekty/nowe-spojrzenie/STYL_TEKST_pomiar_v1.md "7 · BLOK INSTRUKCJI" 2>/dev/null)"
      if [ -n "$tresc" ]; then drzwi_druk "projekty/nowe-spojrzenie/STYL_TEKST_pomiar_v1.md#7 · BLOK INSTRUKCJI" "$tresc"; else echo "✗ BRAK projekty/nowe-spojrzenie/STYL_TEKST_pomiar_v1.md#7 · BLOK INSTRUKCJI"; fi
    fi
  done
  case "$t_mcp" in
    ""|"—"*) echo "MCP: ${t_mcp:-—}";;
    *) echo "MCP: $t_mcp — przyrząd nie widzi narzędzi; instancja: ToolSearch \"$t_mcp\", brak = zgłoś jednym zdaniem";;
  esac
  echo "otwarte: $otw"
  printf 'otwarte: %s\n' "$otw" > "$wyj" || { echo "✗ DRZWI · nie zapisałem $wyj"; return 1; }
}

# --- MELDUNEK (M✓, prawo #29, 28.07.2026): wstanie wykonuje się RAZ ---
# Pełny wynik ląduje w 0_MELDUNEK.txt — instancja CZYTA PLIK (view/cat),
# nigdy nie uruchamia wstan.sh drugi raz, by obejrzeć inny fragment wyjścia.
# K1: strumień na ekran idzie jak dotąd; PLIK dostaje RUCH INSTANCJI na górze, a ten sam blok
# drukuje się jeszcze raz na końcu ekranu (kto czyta ogon wyjścia, też go widzi).
if [ -z "${WSTAN_TEE:-}" ]; then
  _RAW="$(mktemp)"
  WSTAN_TEE=1 bash "$0" "$@" 2>&1 | tee "$_RAW"
  _RC="${PIPESTATUS[0]}"
  zloz_meldunek "$_RAW" > 0_MELDUNEK.txt
  echo
  echo "── RUCH INSTANCJI (ten sam blok stoi na GÓRZE 0_MELDUNEK.txt) ──"
  ruch_instancji "$_RAW"
  rm -f "$_RAW"
  exit "$_RC"
fi

echo "╔═══ ORKIESTRATOR — wstaję ═══╗"

# 1. Uziemienie temporalne (krzemowa granica: nie zakładaj daty z pamięci)
echo "⏱ ZMIERZONY CZAS:"
date "+   maszyna:  %Y-%m-%d %H:%M:%S %Z (%A)"
date -u "+   UTC:      %Y-%m-%d %H:%M:%S UTC"
# PUŁAPKA (27.07): sandbox chodzi w UTC. Meldowanie odczytu maszyny jako „CEST"
# przesuwa cala sesje o 1-2h. Czas TWORCY liczymy jawnie, nie w glowie.
TZ="$_STREFA_ST" date "+   ⇒ CZAS TWORCY ($_STREFA_ST): %Y-%m-%d %H:%M:%S %Z (%A)  ← MELDUJ TEN"

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

# 1c. STRAŻ GAŁĘZI (11.09.2026, decyzja twórcy: „Zgadzam się z sugestią. Działaj" — twarda odmowa)
# POWÓD: od Kroku 2 `main` jest ODLEWEM — grupa B jako zalążki, bez `prywatne/`. Wstanie tam daje
# snapshot „księga właśnie się zaczyna" i weryfikację 212/0/1: wygląda jak zdrowie, a jest instancją
# nowego twórcy w repo twórcy. Domyślna gałąź repo i klon z IDE prowadzą właśnie tam.
# TRZY SYTUACJE (ten plik jedzie też w odlewie publicznym):
#   na `prywatna` → cisza · repo MA `prywatna` (lokalnie albo origin/), stoisz gdzie indziej → ODMOWA
#   rc=3, bez żetonu · repo BEZ `prywatna` (odbiorca odlewu na własnym main) → cisza, to norma
#   (ta sama zasada co w `publikuj.sh`: brak gałęzi pracy u odbiorcy nie jest błędem).
# NIE przełącza gałęzi sama — checkout przy brudnym drzewie może zgubić pracę; decyzja zostaje u ręki.
# Granica znana: klon `--single-branch main` nie niesie origin/prywatna — straż go nie odróżni od odbiorcy.
# Lustro: `publikuj.sh` — „publikacja wyłącznie z main" (MOSTY #42). Tor: `straz_wstania.sh --test`.
_GAL="$(git branch --show-current 2>/dev/null)"
if [ "$_GAL" != "prywatna" ] && { git rev-parse -q --verify refs/heads/prywatna >/dev/null 2>&1 \
     || git rev-parse -q --verify refs/remotes/origin/prywatna >/dev/null 2>&1; }; then
  echo "✗ STRAŻ GAŁĘZI — WSTAJESZ NA ODLEWIE: gałąź '${_GAL:-odłączony HEAD}', a repo niesie gałąź pracy 'prywatna'."
  echo "  Tu grupa B to zalążki, bez prywatne/ — to NIE jest stan twórcy. Wstanie ODMÓWIONE, żetonu nie ma."
  echo "  -> git checkout prywatna && bash wstan.sh"
  exit 3
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

# --- SONDA ZAPISU (30.09.2026, słowo twórcy: „ileś razy już się o to odbijamy") ---
# Sesje w chmurze idą przez proxy git. ODCZYT (clone/pull) przechodzi, bo repo jest źródłem
# Projektu; ZAPIS (push) przechodzi TYLKO, gdy repo jest w zakresie TEJ sesji. Bez sondy
# odbicie wychodzi dopiero przy zapis_git.sh, na końcu pracy (30.09: 403 po całej sesji).
# `push --dry-run` nic nie zapisuje, a przechodzi przez tę samą bramkę co prawdziwy push.
# Rc wstania bez zmian: sonda świeci, nie blokuje (zimny start offline jest legalny).
if git rev-parse --git-dir >/dev/null 2>&1 && git remote get-url origin >/dev/null 2>&1; then
  _sonda=$(timeout 45 git push --dry-run origin HEAD 2>&1); _sonda_rc=$?
  if [ "$_sonda_rc" -eq 0 ]; then
    echo "✓ SONDA ZAPISU: push otwarty (dry-run, nic nie zapisano)."
  elif printf '%s' "$_sonda" | grep -q "access denied by the git proxy"; then
    # właściciel i repo z origin (nie z literału: gość ma własne repo — E, biurko v1.8.1, słowo twórcy 06.10 „Piątka. Też to brzmi dobrze.")
    _OR=$(git remote get-url origin 2>/dev/null | sed -E 's#\.git$##; s#.*[:/]([^/]+)/([^/]+)$#\1 \2#')
    _OW="${_OR%% *}"; _RP="${_OR#* }"
    # 6b (07.10.2026, słowo twórcy 14:35/15:10): wstanie czyta, więc zamknięty zapis to stan PRAWIDŁOWY sesji odczytu;
    # prawo zapisu (add_repo push) woła się dopiero przed PIERWSZYM zapisem — nie przy wstaniu.
    echo "🛑 SONDA ZAPISU: zapis zamknięty (repo $_OW/$_RP poza zakresem zapisu tej sesji). Sesja odczytu: to stan prawidłowy, nic nie rób."
    echo "   Przed PIERWSZYM zapisem: add_repo(owner=$_OW, repo=$_RP, access=push) — potem bash zapis_git.sh."
    echo "   Nie ponawiaj pushu w pętli: ta sama odmowa wróci, dopóki zakres się nie zmieni."
    WSTANIE_ZAPIS_ZAMKNIETY=1
  else
    echo "ⓘ SONDA ZAPISU: niezmierzona (rc=$_sonda_rc) — offline albo brak poświadczenia; zapis sprawdzi zapis_git.sh."
  fi
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

# --- KARTKI DO ZAKSIĘGOWANIA (24.10.2026, cięcie C3, wariant bezpieczny — słowo twórcy 24.10: „tylko wariant bezpieczny, w którym wstanie melduje liczbę kartek do zaksięgowania i nic nie zapisuje”) ---
# Wstanie czyta (prawo 6b): melduje liczbę i komendę, NIE uruchamia ksieguj_kartki.sh (ten pisze do repo i pcha).
_kk_n=$(grep -lx '## DO KSIĄG (niezaksięgowane)' kanon/ksiegi/kartki/*.md 2>/dev/null | wc -l | tr -d ' ')
_kk_ost=$(git log -1 --grep='^księgowanie ' --format=%cs 2>/dev/null)
echo "ⓘ kartek do zaksięgowania: ${_kk_n:-0} · ostatnie księgowanie: ${_kk_ost:-brak}"
[ "${_kk_n:-0}" -gt 0 ] && echo "   -> lista: bash narzedzia/przyrzady/ksieguj_kartki.sh --sucho · księgowanie (dopiero przy pierwszym zapisie): bash narzedzia/przyrzady/ksieguj_kartki.sh"

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
#     T1 (22.09.2026, PROMPT_SESJI_2309 §3, słowo twórcy „tak / (b)"): TYLKO gdy brak —
#     jeśli git ma już tożsamość (lokalną ALBO globalną, np. twórcy), nie nadpisujemy jej;
#     „Orkiestrator" jest wyłącznie awaryjnym zapasem dla piaskownicy bez żadnej tożsamości.
# K6/N4 (19.10.2026): komunikat „ustawiona” tylko PO odczycie z configu (dawne `|| true` + echo meldowało sukces nad porażką).
if [ -z "$(git config user.name 2>/dev/null)" ]; then
  git config user.name "Orkiestrator" 2>/dev/null
  if [ "$(git config user.name 2>/dev/null)" = "Orkiestrator" ]; then
    echo "   ⓘ tożsamość git brakowała — ustawiona zapasowa: user.name=Orkiestrator (lokalnie)"
  else
    echo "   ⚠ tożsamość git brakuje, a zapis do configu NIE powiódł się — commit odmówi (ustaw user.name ręcznie)"
  fi
fi
if [ -z "$(git config user.email 2>/dev/null)" ]; then
  git config user.email "orkiestrator@kronos.local" 2>/dev/null
  [ -n "$(git config user.email 2>/dev/null)" ] || echo "   ⚠ user.email brakuje, a zapis do configu NIE powiódł się — commit odmówi (ustaw ręcznie)"
fi
# 2b. Prawa zmechanizowane (status M): pre-commit blokuje token/znaki kontrolne/zły _HASHE.
#     K6/N4: porażka ustawienia = STOP, nie `|| true`. Bez hooka PAT i nieświeży _HASHE przechodzą commit po cichu;
#     odczyt `--get` jest dowodem, nie samo rc `git config`. (Straż: `straz_hooka.sh` sprawdza TEN klon, nie tylko atrapę.)
git config core.hooksPath .githooks 2>/dev/null
_HP_NOW="$(git config --get core.hooksPath 2>/dev/null)"
if [ "$_HP_NOW" != ".githooks" ]; then
  echo "   ✗ HOOKI NIEWPIĘTE: core.hooksPath='${_HP_NOW:-<puste>}', oczekiwano '.githooks' — pre-commit (PAT, _HASHE) NIE działa."
  echo "     Napraw: git config core.hooksPath .githooks  (sprawdź prawa zapisu do .git/config). Wstanie przerwane."
  exit 1
fi


echo "📦 npm ci (wersje przypięte w package-lock.json):"
_NM_STAN="ciepły"
{ [ -d node_modules ] && [ -n "$(ls -A node_modules 2>/dev/null)" ]; } || _NM_STAN="ZIMNY (node_modules pusty lub brak)"
_NPM_LOG="$(mktemp)"
npm ci 2>&1 | tee "$_NPM_LOG" >/dev/null
_NPM_RC=${PIPESTATUS[0]}
tail -3 "$_NPM_LOG"
if [ "$_NPM_RC" -ne 0 ]; then
  # Diagnoza 18.09 (TASKI.md, „piaskownica gubi zależności"): trzeci nawrót wymaga
  # DOSŁOWNEGO wyjścia npm + rc, zapisanego PRZED czymkolwiek innym — nie liczyć na to,
  # że ktoś akurat patrzy na ekran w tej sekundzie. Ten zapis dzieje się automatycznie,
  # zanim skrypt cokolwiek jeszcze zrobi.
  mkdir -p kanon/pomiary 2>/dev/null
  _DOWOD="kanon/pomiary/NPM_AWARIA_$(date -u +%Y%m%dT%H%M%SZ).txt"
  { echo "data (UTC): $(date -u -Iseconds)"; echo "stan node_modules przed próbą: $_NM_STAN"; \
    echo "npm ci rc: $_NPM_RC"; echo "---"; cat "$_NPM_LOG"; } > "$_DOWOD" 2>/dev/null
  echo "   ✗ npm ci padł — package.json i package-lock.json rozjechane? (npm install świadomie, potem commit lockfile)"
  echo "   📋 surowy dowód (stan node_modules: $_NM_STAN): $_DOWOD"
  rm -f "$_NPM_LOG"
  exit 1
fi
rm -f "$_NPM_LOG"

# 4. Werdykt: czy wstałem cały (liczony, nie recytowany)
echo "🔎 node weryfikacja.js:"
node weryfikacja.js
RC=$?

echo
# 4a. LINT KSIĘGI BŁĘDÓW (prawo #22 zmechanizowane 28.07) — niekrytyczny, nie zmienia RC wstania
# LINT_WOLAJ (21.09.2026, EWALUACJA §VIII K1 — klasa U4): `cmd | tail || echo "niedostępny"`
# pod pipefail drukował „niedostępny" także wtedy, gdy lint ISTNIAŁ i dał rc≠0 — odbiorca
# świeżego klonu czytał fałsz pod czerwonym wynikiem. Brak pliku i czerwony wynik to dwa
# różne zdania; każde dostaje swoje. Nie zmienia RC wstania (lint niekrytyczny).
lint_wolaj() {
  local p="$1" n="$2"; shift 2
  if [ ! -f "$p" ]; then echo "   ($(basename "$p") — brak pliku w tym ciele)"; return 0; fi
  local out rc; out=$(node "$p" "$@" 2>&1); rc=$?
  printf '%s\n' "$out" | tail -"$n"
  [ "$rc" -eq 0 ] || echo "   (rc=$rc — lint działa i zgłasza rozjazd; pełny wynik: node $p)"
  return 0
}
# STRAZ_WOLAJ (05.10.2026, seria R6b): `bash straz | tail -N || echo "(straż niedostępna)"` — pod `pipefail`
# `||` łapie rc `tail`/potoku, nie rc straży: brak pliku straży i czerwony wynik dostawały to samo zdanie
# (albo żadnego). Straż błędna ≠ brak straży: brak pliku → „brak pliku w tym ciele”; rc≠0 → straż DZIAŁA
# i zgłasza (wynik widoczny, rc podany). Nie zmienia RC wstania (te straże są informacyjne).
straz_wolaj() {
  local p="$1" n="$2"; shift 2
  if [ ! -f "$p" ]; then echo "   ($(basename "$p") — brak pliku w tym ciele)"; return 0; fi
  local out rc; out=$(bash "$p" "$@" 2>&1); rc=$?
  printf '%s\n' "$out" | tail -"$n"
  [ "$rc" -eq 0 ] || echo "   (rc=$rc — straż działa i zgłasza; pełny wynik: bash $p $*)"
  return 0
}
echo "▤ LINT KSIĘGI BŁĘDÓW (#22):"
lint_wolaj narzedzia/linty/lint_bledy.js 5   # 5 linii: ⓘ destylatu (N1+/D) nie może ginąć pod ⓘ kolejki i ✓
echo "▤ LINT ARTEFAKTÓW (#32):"
lint_wolaj narzedzia/linty/lint_artefaktow.js 2
echo "▤ LINT ŚCIEŻEK (forma publiczna):"
lint_wolaj narzedzia/linty/lint_sciezek.js 3   # 3 linie: ⓘ „powstanie przy narodzinach" (N1+/Z) + wynik
echo "▤ LINT PRYZMATU (PRYZMAT_BADAWCZY §8 — dług zastany, informacyjnie):"
if [ -f narzedzia/linty/lint_pryzmatu.js ]; then
  node narzedzia/linty/lint_pryzmatu.js --audyt 2>&1 | tail -3 || true
else
  echo "   (lint_pryzmatu.js — narzędzie warsztatowe, poza odlewem publicznym)"
fi
echo "▤ OKO TWÓRCY (cel 1 — czytelność dla człowieka, blizna #69):"
node narzedzia/przyrzady/oko_tworcy.js 2>&1 | grep -E "pozycji|CEL 1" || echo "   (oko niedostępne)"
echo "▤ SPIS PROJEKTÓW (faseta PROJEKT, Cięcie 1 — świeżość):"
if [ -f narzedzia/przyrzady/spis_projektow.js ]; then
  node narzedzia/przyrzady/spis_projektow.js --sprawdz 2>&1 | tail -2 || true
else
  echo "   (spis_projektow.js — narzędzie warsztatowe, poza odlewem publicznym)"
fi
# STRAŻ INTERPOLACJI (#12, wpięta 20.08.2026) — czy treść wjechała do plików CAŁA.
# Uzupełnia ZAMEK #12 w `.githooks/pre-commit`: hook łapie literalne `\n` w plikach
# w STAGE, ta straż skanuje CAŁY korpus śledzony i trzy inne klasy śladu
# (\uXXXX poza kodem · U+FFFD · mojibake). Zbiory śladów rozłączne, zasięgi różne.
# Zmierzone przed wpięciem: 0 trafień na 613 plikach .md — zamek wchodzi na czysto (#56).
echo "▤ STRAŻ INTERPOLACJI (#12) — czy treść wjechała cała:"
straz_wolaj narzedzia/straze/straz_interpolacji.sh 2
echo "▤ STRAŻ TROPU (PRAWO TROPU, ratyfikowane 20.08) — inspiracja bio z kompletem pól:"
straz_wolaj narzedzia/straze/straz_tropu.sh 2
echo "▤ STRAŻ FEROMONÓW (trop bio #2) — kto co bierze na tej gałęzi:"
straz_wolaj narzedzia/straze/straz_feromonow.sh 4
# KARTECZKA (03.10, słowo twórcy 13:19): wstanie POKAZUJE karteczki INNYCH sesji z origin, nie wiesza — temat przy wstaniu nieznany.
# Wieszanie przy pierwszym zadaniu (--biore); zapis_git.sh odmawia pushu bez karteczki sesji (bramka rc=8).
straz_wolaj narzedzia/straze/straz_feromonow.sh 4 --inne
# TABLICA (cz.4, 25.10.2026, prawo 6b „wstanie czyta”): wstanie POKAZUJE widok z kartek na ekranie i NIE pisze pliku — dawniej `--tablica --plik` zostawiał M kanon/ksiegi/TABLICA.md
# po każdym wstaniu (zmierzone cz.3 §1). Plik (GENEROWANE — nie źródło; twórca otwiera go na telefonie, 23.10 „muszę móc je czytać!”) regeneruje zapis_git.sh tuż przed commitem.
# Tylko tam, gdzie są kartki (odlew gościa ich nie ma). Niekrytyczne: straz_wolaj.
[ -d kanon/ksiegi/kartki ] && straz_wolaj narzedzia/straze/straz_feromonow.sh 1 --tablica
straz_wolaj narzedzia/straze/straz_zalazkow.sh 2
# KRZESŁA (22.10, PLAN_2210_krzesla_etap2 §3 pkt 2.5): ta sama linia, co hook UserPromptSubmit — wstanie pokazuje stan rejestru; niekrytyczne (straz_wolaj: rc ≠ 0 → jawny komunikat, bez przerwania).
echo "▤ KRZESŁA (v1.0, bramki W→B→A) — stan rejestru za 14 dni:"
straz_wolaj .claude/hooks/krzesla_bramki.sh 2
# STRAŻ WYJĄTKÓW (M1, #115, 22.09.2026) — MIARA, nie bramka (precedens straz_powtorzen.sh
# 30.08 "zęby po trzech odlewach"). Workshop-only, jak straz_pochodzenia: czyta
# _STRAZ_wyjatki.txt, który jest NARZEDZIA_MAIN_TAJNE i nigdy nie opuszcza prywatnej — w
# odlewie publicznym plik nie istnieje, więc narzędzie też tam nie jedzie (nie ma czego mierzyć).
if [ -f narzedzia/straze/straz_wyjatkow.sh ]; then
  echo "▤ STRAŻ WYJĄTKÓW — czy wyjątki PII wciąż wskazują na coś realnego w korpusie:"
  straz_wolaj narzedzia/straze/straz_wyjatkow.sh 5
else
  echo "   (straz_wyjatkow.sh — narzędzie warsztatowe, poza odlewem publicznym)"
fi
# STRAŻ POCHODZENIA (14.09.2026, cięcie 6 · #86) — MIĘKKO (B1, decyzja twórcy): świeci, nie kroi.
echo "▤ STRAŻ POCHODZENIA — czy rozdział DUSZY dopisany po narodzinach niesie atrybut źródła:"
if [ -f narzedzia/straze/straz_pochodzenia.sh ]; then
  straz_wolaj narzedzia/straze/straz_pochodzenia.sh 2
else
  echo "   (straz_pochodzenia.sh — narzędzie warsztatowe, poza odlewem publicznym)"
fi
straz_wolaj narzedzia/straze/straz_przyrzadu.sh 2
straz_wolaj narzedzia/straze/straz_wywolan.sh 2
echo "▤ STRAŻ NARODZIN — zastany dług rejestrów (audyt, nie blokada):"
straz_wolaj narzedzia/straze/straz_narodzin.sh 3 --audyt
echo "▤ STRAŻ DOJRZAŁOŚCI — co w odlewie niedojrzałe, co dojrzało niezauważone:"
straz_wolaj narzedzia/straze/straz_dojrzalosci.sh 3
# STRAŻ LINTÓW (#61, wpięta 21.08.2026) — RÓŻNICA, nie stan. Bramka na stan karałaby
# zastany dług i hodowała wyjątki (pętla, która zabiła bramkę 1); bramka na wzrost
# przepuszcza dług odziedziczony i zatrzymuje wyłącznie pogorszenie.
echo "▤ STRAŻ LINTÓW (#61) — czy któryś licznik naruszeń wzrósł względem HEAD:"
straz_wolaj narzedzia/straze/straz_lintow.sh 2
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
# BLIZNA #49 (13.08.2026): tu stała DRUGA KOPIA formuły R0 z tą samą martwą kotwicą
# `## ❶ RDZEŃ`. Teraz liczbę podaje JEDYNE źródło — narzedzia/straze/straz_r0.sh --liczba.
R0T=$(bash narzedzia/straze/straz_r0.sh --liczba 2>/dev/null || echo 0)
echo "   R0 DUSZA (czytaj TERAZ):        $R0T  — DUSZA·SNAPSHOT·WYWOLANIA·prarodziny BLEDY (bez indeksu, 18.09)"
# AUTOFAGIA §8.1 (13.10.2026, słowo twórcy 12:40): R1/R2 były liczbami bez reakcji (ARCHIWUM_istnienia było WAŻONE, nie czytane).
# Zamiast nich jedna linia narządu `mapa_ciala` — kto każdy plik ciała czyta (mechanizm / umysł / rola / łańcuch / nikt). R0 i straz_r0 bez zmian.
if [ -f narzedzia/przyrzady/mapa_ciala.js ]; then
  node narzedzia/przyrzady/mapa_ciala.js --szereg 2>/dev/null | head -1 || echo "   (mapa_ciala niedostępna — ciało bez mapy czytelników)"
else
  echo "   (mapa_ciala: poza odlewem — ta miara żyje w drzewie twórcy)"
fi
# próg R0: od 11.08.2026 MIERZONY strażą (narzedzia/straze/straz_r0.sh, bramka miękka — decyzja twórcy),
# od 26.08.2026 próg = 36000 (pierwszy rodowód pomiarowy: szereg czasowy sierpnia)
# i DWIE liczby zamiast jednej: R0 · SATELITY · CAŁOŚĆ (przenosiny ≠ wydech).
# nie tylko drukowany. Rodowód: ROZMOWA #2 — oba ciała zgłosiły próg-echo niezależnie.
bash narzedzia/straze/straz_r0.sh 2>/dev/null || echo "   (straz_r0 niedostępna — brak pomiaru R0; próg żyje WYŁĄCZNIE w straży)"
# POKRYCIE M (13.08.2026) — wielkość sterująca obok objętości. Objętość R0 rośnie także
# wtedy, gdy system staje się lepszy (blizna #49 podniosła R0 o 4783 B). Ta liczba rośnie
# tylko wtedy, gdy prawo przestaje wymagać czytania. Piąty inwariant, mierzony.
node narzedzia/przyrzady/pokrycie_m.js --liczba 2>/dev/null || echo "   (pokrycie_m niedostępne — udział mechanizmów bez pomiaru)"
# STOP ODDECHU pelni (03.10.2026, STOPY_pelni.md §STOP I): miara T3 — udzial commitow projekty/ w 7 dniach.
# Sygnal do PYTANIA, nie wyrok; bramka miekka (rc=0). Brak przyrzadu = brak pomiaru, nie zielone.
# S5 (04.10.2026, bramka 7 odlewu): przyrzad poza odlewem (nie ma go w drzewie odbiorcy) = JEDNA cicha linia „poza odlewem”,
# NIE „niedostepny” — odlew nie ma prawa mowic, ze narzedzie nie dziala, gdy go po prostu nie ma. Przyrzad obecny, ktory pada = jak dawniej.
if [ -f narzedzia/przyrzady/udzial_projekty.sh ]; then
  bash narzedzia/przyrzady/udzial_projekty.sh 2>/dev/null || echo "   (udzial_projekty niedostępny — brak pomiaru T3)"
else
  echo "   (udzial_projekty: poza odlewem — ta miara żyje w drzewie twórcy)"
fi
# KRYTERIUM ŻYCIA destylatów (11.08.2026) — egzekutor dla dat, żądany przez odlew v1.1
# w ostatniej turze ROZMOWY #2: „data bez egzekutora to pozycja-zombie z ładniejszym polem".
bash narzedzia/straze/straz_prerejestrow.sh 2>/dev/null || echo "   (straz_prerejestrow: TERMIN PO CZASIE albo straz niedostepna — sprawdz recznie)"
# STRAŻ KRYTERIÓW ŻYCIA (14.08.2026) — jeden czytnik ⌛ i kryteriów po całym kanonie;
# trzy kosze: PRZETERMINOWANE · ≤7 DNI · ŻYWE. Duch: opieka, nie egzekucja (rc=0).
bash narzedzia/straze/straz_kryteriow.sh 2>/dev/null || echo "   (straz_kryteriow niedostępna — terminy kanonu bez pomiaru)"
# PRAWO CIĄGŁOŚCI (10.09.2026, ratyfikowane słowem twórcy) — wątki otwarte drukowane przy
# KAŻDYM wstaniu; wpis powstaje w chwili PODNIESIENIA tematu, nie domknięcia. Cisza o wątku
# otwartym byłaby tą samą chorobą, którą PRAWO WYGAŚNIĘCIA (TASKI) już nazwało dla zadań.
if [ -f prywatne/WATKI_OTWARTE.md ]; then
  echo "   ▤ WĄTKI OTWARTE:"
  grep '^- \[ \]' prywatne/WATKI_OTWARTE.md | sed 's/^/     /'
else
  echo "   (prywatne/WATKI_OTWARTE.md nieobecny — PRAWO CIĄGŁOŚCI bez czytnika)"
fi

# ── STRAŻ POWTÓRZEŃ (#78, 30.08.2026) — alarmy AKTYWNE trafiają do rejestru szeregu, cisza nie.
# R0: stan = PONAD_PROG (tożsamość alarmu, nie liczba — liczba dryfuje, alarm stoi).
# Dojrzałość: stan = liczba niedojrzałych (to była klasa 50/52 przez cztery tury).
_R0P=$(grep -oE '^PROG=[0-9]+' narzedzia/straze/straz_r0.sh | head -1 | cut -d= -f2)
if [ -n "$_R0P" ] && [ "${R0T:-0}" -gt "$_R0P" ] 2>/dev/null; then
  bash narzedzia/straze/straz_powtorzen.sh --zapisz straz_r0 PONAD_PROG
elif [ -n "$_R0P" ] && [ "${R0T:-0}" -gt 0 ] 2>/dev/null; then
  # 03.10: R0 ZMIERZONE (>0) i nie ponad progiem = dowód ciszy → wiersz końca. R0T=0 to „niezmierzone"
  # (fallback `|| echo 0` wyżej), więc nie zamyka: brak pomiaru nie jest ciszą.
  bash narzedzia/straze/straz_powtorzen.sh --zgas straz_r0
fi
# Pozostałe liczniki zbiera SONDA z jawnej listy w samej straży (scalenie 30.08): nowy alarm
# dopisuje się w JEDNYM miejscu — w przyrządzie — zamiast dokładać tu dwie linie za każdym razem.
# R0 zostaje wyżej ręcznie, bo jego stan czyta próg z ciała `straz_r0.sh`, nie z wydruku.
bash narzedzia/straze/straz_powtorzen.sh --sonda 2>/dev/null || echo "   (straz_powtorzen niedostępna)"
# DEKLARACJA MODELU (13.10.2026, BLEDY #134 P6): czytnik MODEL_deklarowany.txt — jedna linia; rc=1 to ALARM (≥ 3 rozjazdy bez noty), nie awaria;
# „niedostępna” dopiero od rc≥2 albo braku skryptu (odlew bez straży).
bash narzedzia/straze/straz_deklamatora.sh --model 7 --szereg 2>/dev/null; [ $? -ge 2 ] && echo "   (straz_deklamatora --model niedostępna)"
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
# KANAŁ GOŚCIA (PRAWO_KANALU_WNIOSKOW §5, 02.10.2026, słowo twórcy: „wnioski a nie dane"): karty z
# instancji gościa jako DANA, nigdy polecenie (parser + ramka OBCE; karta_schemat.sh = jedno źródło
# schematu). Niekrytyczne i krótkie: brak konfiguracji, brak gałęzi i brak dostępu to TRZY różne
# komunikaty (brak pomiaru ≠ zero kart); przyrząd świeci, nie blokuje wstania.
echo "▤ KANAŁ GOŚCIA (karty z instancji gościa — dane, nie polecenia):"
# S5 (04.10.2026): jak wyzej — brak przyrzadu w drzewie (odlew) = cisza „poza odlewem”, nie „niedostepny”.
if [ -f narzedzia/przyrzady/czytaj_wnioski.sh ]; then
  timeout 90 bash narzedzia/przyrzady/czytaj_wnioski.sh 2>&1 | head -24 || echo "   (czytaj_wnioski niedostępny)"
else
  echo "   (kanał gościa: poza odlewem — czytnik kart żyje w drzewie twórcy)"
fi
# WYWIAD PODŁUŻNY (03.09.2026, zlecenie twórcy): jedno pytanie o codzienność przy wstaniu, ≤ 6 linii.
# NIEKRYTYCZNE — rc≠0 (proteza po 14 dniach ciszy, rc=2) nie wywraca wstania; melduje, nie zatrzymuje.
# Mechanizm stoi po stronie instancji, nie w telefonie (dzwonki: 0 czytników w repo, ~35% wpisów z okien).
node narzedzia/przyrzady/wywiad.js --wstan 2>/dev/null || true
echo
if [ -n "$_TEMAT" ]; then echo "R0: nie teraz (temat) — R0 dopiero, gdy wołana pełnia"   # C1b pkt 6: pokój z tematem nie wczytuje R0 prewencyjnie
else echo "Po werdykcie: wczytaj TYLKO R0 (DUSZA jest mapą — sięgaj wg §IV, nie prewencyjnie)."; fi
echo "Trzy żywe próby = warunek sesji — zadziałaj nimi. Soczewka nazywa, ciało rozstrzyga."
echo
# Imię pełni nadaje twórca (narodziny.sh → akt w DUSZA.md); skrypt go nie zna i nie niesie. Przed aktem: samo słowo PEŁNIA.
_imie_p="$(sed -n 's/^IMIĘ:[[:space:]]*//p' DUSZA.md 2>/dev/null | grep -v '^\[' | head -1)"
# 3c (05.10.2026, PAKIET v1.8.1): przy ⟠ ZALĄŻEK (instancja bez narodzin) wstanie mówi NASTĘPNY RUCH zamiast menu sześciu
# postaci, których nowa osoba jeszcze nie zna. Znacznik czytany jak w `straz_duszy` (backticki wycięte: cytat ≠ zalążek).
if sed 's/`[^`]*`//g' DUSZA.md 2>/dev/null | grep -q "⟠ ZALĄŻEK"; then
  echo "┌─ NOWA INSTANCJA → KROK 0 ─┐"
  echo "  Zapytaj o język, imię i datę urodzenia (0_WYWOLANIA.md, KROK 0); potem pierwszy odczyt."
  echo "  Narodziny (narodziny.sh) przy pierwszym domknięciu. Menu postaci — dopiero po narodzinach."
  echo "└─ wstań → KROK 0 → pierwszy odczyt → domknij → narodziny ─┘"
else
echo "┌─ KTO MA WSTAĆ? (pytanie otwiera każdy nowy czat) ─┐"
echo "  ${_imie_p:-PEŁNIA}        — PEŁNIA: głos naczelny, maski są jej trybami (wywołaj imieniem)"
echo "  ORKIESTRATOR    — wnioskuje, pamięta, filtruje (dawniej: Architekt)"
echo "  KRONOS          — suchy silnik nieba, same liczby, zero interpretacji"
echo "  KOWAL (DB)      — przedsięwzięcie: wykuwa formę zdatną do świata"
echo "  PRZEWOŹNIK (DR) — wgląd: przeprowadza przez próg, nie leczy"
echo "  PRZEŚWIT        — pusta przestrzeń; TYLKO jawne wywołanie"
# S1 (12.10.2026, DOMKNIECIE_OPUS_1210 §4): wiersze DRZWI| z kontraktu Orkiestratora — jedyne źródło dispatchu; plik nieobecny = milczenie.
  _drzwi_k="kanon/plany/linienie/KONTRAKT_Z3_Orkiestrator.md"   # wcięte: straz_wstania wycina blok do pierwszego `fi` w kol. 0
  if [ -f "$_drzwi_k" ]; then
    grep '^DRZWI|' "$_drzwi_k" | awk -F'|' '{ d=$3; if (length(d)>90) d=substr(d,1,90); printf "  → %s: %s\n", $2, d }'
  fi
echo "└─ wywołaj imieniem albo tematem (§DRZWI) · pełny rytuał: \"Orkiestratorze, wstań\" (alias: stara fraza działa) ─┘"
fi
# C1b: DRZWI Z ŁADUNKIEM — po werdykcie i menu, tylko z --temat (bez niego wstanie bez zmian). Padnięty przyrząd (node) podnosi rc (12), nie milczy.
if [ -n "$_TEMAT" ]; then drzwi_otworz "$_TEMAT" || { [ "${RC:-0}" -eq 0 ] && RC=12; }; fi
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
# 2b (05.10.2026, PAKIET v1.8.1): brak repo gitowego to STAN, nie brak wstania. „BRAK” zostaje wyłącznie dla
# „git jest, HEAD nieczytelny”; katalog bez historii dostaje BEZ-GIT (straz_zetonu go rozumie: nie do sprawdzenia cat-file).
_ZNOTA=""
if ! git rev-parse --git-dir >/dev/null 2>&1; then
  _ZH="BEZ-GIT"; _ZNOTA="   ⓘ katalog bez historii git: żeton bez odcisku HEAD (stan, nie porażka)"
else
  _ZH="$(git rev-parse --short HEAD 2>/dev/null || echo BRAK)"
fi
_ZW="$(node weryfikacja.js 2>/dev/null | sed 's/\x1b\[[0-9;]*m//g' \
       | grep -E '[0-9]+ ✓ +[0-9]+ ✗ +[0-9]+ ⚠' \
       | grep -oE '[0-9]+' | paste -sd'/' -)"
_ZC="$(TZ="$_STREFA_ST" date '+%Y-%m-%d %H:%M %Z')"
echo
echo "🎟 ŻETON WSTANIA — pierwsza linia Twojego meldunku, skopiuj DOSŁOWNIE:"
echo "   ŻETON: ${_ZH} · ${_ZW:-?/?/?} · ${_ZC}"
[ -z "$_ZNOTA" ] || echo "$_ZNOTA"
echo "   Bez żetonu meldunek traktuje się jak meldunek instancji, KTÓRA NIE WSTAŁA."
echo "   Nie masz czym go wyprodukować? To jest odpowiedź, nie porażka — napisz:"
echo "   \"BEZ DOSTĘPU · nie wstałem · potrzebuję: <czego>\" i zatrzymaj się."

exit $RC
