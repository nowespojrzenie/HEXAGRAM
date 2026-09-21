#!/usr/bin/env bash
# ═══ STRAŻ ZALĄŻKÓW (22.08.2026) — egzekutor PRAWA ZALĄŻKA ═══
#
# RODOWÓD: ratyfikacja twórcy 21.08.2026 (czat): „Bardziej pewnie niektóre pliki
# zostawić pustymi niż usuwać je. A może... Zaszyć funkcję — ten plik był prywatny
# twórcy, zatem skoro teraz go potrzebujesz, jesteś Nowym twórcą i on właśnie jest
# tworzony aby nie odsyłał w puste miejsce." kanon/plany/PLAN_NASIONA_v1.6 §FAZA B.
#
# PRAWO ZALĄŻKA: plik prywatnej tkanki nie podróżuje do odlewu ani pusty, ani usunięty —
# podróżuje jako ZALĄŻEK: pustka NAZWANA. Zalążek musi spełniać jednocześnie:
#   (1) KOMPLET NAGŁÓWKA — znacznik ⟠ ZALĄŻEK + zdanie „nie podróżuje" + zdanie
#       oddające autorstwo nowemu twórcy. Sam znacznik bez zdań to etykieta, nie akt.
#   (2) ZERO DROGI TWÓRCY PIERWOTNEGO — żadnych imion (wzorzec `_STRAZ_wzorzec.txt`,
#       ten sam co zamek wycieku w publikuj.sh) i żadnych dat dziennych DD.MM.RRRR.
#       Powód: zalążek, który OPISUJE, co było w oryginale, sam jest wyciekiem —
#       nowy twórca ma dostać puste miejsce z prawem, nie streszczenie cudzego życia.
#
# DLACZEGO OSOBNA STRAŻ, a nie zamek w publikuj.sh: zamek #66 pilnuje JEDNEGO
# zalążka (DUSZY) w chwili odlewu. Zalążków będzie jedenaście (FAZA C) i powstają
# W TKANCE, na długo przed publikacją. Błąd wykryty przy odlewie jest błędem wykrytym
# za późno — po tygodniach pisania. Ta straż biegnie przy wstaniu, nad całym korpusem.
#
# ZAKRES ŚWIADOMY (#56: alarm szerszy niż sygnał uczy nie patrzeć): pliki niosące
# znacznik `⟠ ZALĄŻEK` ORAZ pliki, których nazwa kończy się `_zalazek.md`. Drugi
# warunek łapie przypadek odwrotny i groźniejszy: plik NAZWANY zalążkiem, który
# znacznik zgubił (np. przy edycji) — dla `narodziny.sh` przestaje istnieć, bo
# zamek ⟠ go nie rozpozna, a wygląda jak gotowy do podróży.
set -u
TRYB="${1:-}"
WZORZEC="${WZORZEC:-_STRAZ_wzorzec.txt}"

# ── funkcja mierząca JEDEN plik; rc=0 zdrowy, rc=1 wadliwy ──────────────────
zalazek_ok() {  # $1 = ścieżka
  _p="$1"; _wady=""
  grep -q "⟠ ZALĄŻEK" "$_p" 2>/dev/null || _wady="${_wady} brak-znacznika-⟠"
  grep -q "nie podróżuje" "$_p" 2>/dev/null || _wady="${_wady} brak-zdania-o-niepodróżowaniu"
  grep -qE "jesteś twórcą|jesteś nowym twórcą" "$_p" 2>/dev/null || _wady="${_wady} brak-oddania-autorstwa"
  if [ -f "$WZORZEC" ]; then
    if grep -nEf "$WZORZEC" "$_p" >/dev/null 2>&1; then _wady="${_wady} IMIĘ-twórcy-pierwotnego"; fi
  fi
  grep -qE '\b[0-3][0-9]\.[01][0-9]\.20[0-9][0-9]\b' "$_p" 2>/dev/null && _wady="${_wady} DATA-z-drogi-pierwotnej"
  [ -z "$_wady" ] && return 0
  echo "$_wady"; return 1
}

# ── TOR (#38: przyrząd musi umieć NIE przejść) ──────────────────────────────
if [ "$TRYB" = "--test" ]; then
  T=$(mktemp -d); trap 'rm -rf "$T"' EXIT
  # ⚠ TOKEN NEUTRALNY, NIE LITERAŁ IMIENIA — i to jest cała naprawa blizny z 28.08:
  # fikstura brzmiała linią z imieniem, a ślepy sed czyszczący imię z całego ciała
  # (cięcie „imię twórcy poza treścią praw\") trafił także TUTAJ. Wzorzec przestał
  # mieć co łapać, tor stracił czułość i od tamtej chwili oblewał przy każdym wstaniu.
  # Tor ma mierzyć MECHANIKĘ (czy funkcja umie zastosować wzorzec z pliku), nie znać
  # konkretne imię — konkretne imiona są w produkcyjnym `_STRAZ_wzorzec.txt`.
  # Token bez semantyki jest odporny na każde następne czyszczenie PII.
  printf '\\bIMIE_PIERWOTNE_FIKSTURA\n' > "$T/wzor.txt"
  NAGL='⟠ ZALĄŻEK — tkanka nowego twórcy\nTen plik był prywatną tkanką twórcy pierwotnego i nie podróżuje.\nSkoro go potrzebujesz — jesteś twórcą. Ta księga właśnie się zaczyna.\n'
  printf "$NAGL"                                  > "$T/dobry.md"
  printf 'zwykla tresc bez znacznika\n'            > "$T/goly.md"
  printf "$NAGL"                                  > "$T/imie.md"; printf 'pisal to IMIE_PIERWOTNE_FIKSTURA\n' >> "$T/imie.md"
  printf "$NAGL"                                  > "$T/data.md"; printf 'nadane 14.07.2026\n' >> "$T/data.md"
  printf '⟠ ZALĄŻEK — tkanka nowego twórcy\n'      > "$T/kadlub.md"
  WZORZEC="$T/wzor.txt" zalazek_ok "$T/dobry.md"   >/dev/null 2>&1 && R_OK=0   || R_OK=1
  WZORZEC="$T/wzor.txt" zalazek_ok "$T/goly.md"    >/dev/null 2>&1 && R_GOL=0  || R_GOL=1
  WZORZEC="$T/wzor.txt" zalazek_ok "$T/imie.md"    >/dev/null 2>&1 && R_IMI=0  || R_IMI=1
  WZORZEC="$T/wzor.txt" zalazek_ok "$T/data.md"    >/dev/null 2>&1 && R_DAT=0  || R_DAT=1
  WZORZEC="$T/wzor.txt" zalazek_ok "$T/kadlub.md"  >/dev/null 2>&1 && R_KAD=0  || R_KAD=1
  # ⊙ ŻYWE CIAŁO NIE JEST ALARMEM: prawdziwy szablon w repo musi przechodzić.
  R_ZYW=1; [ -f szablony/DUSZA_zalazek.md ] && { zalazek_ok szablony/DUSZA_zalazek.md >/dev/null 2>&1 && R_ZYW=0; }
  # − POJEDYNCZY BRAK: znacznik + „nie podróżuje", ale BEZ oddania autorstwa.
  # Kadłub wyżej ma DWIE wady naraz, więc zdjęcie jednego warunku było w nim
  # niewidoczne — mutacja przechodziła (#49: fikstura musi oblewać z JEDNEGO powodu).
  printf '⟠ ZALĄŻEK — tkanka nowego twórcy\nTen plik nie podróżuje.\n' > "$T/bezautorstwa.md"
  WZORZEC="$T/wzor.txt" zalazek_ok "$T/bezautorstwa.md" >/dev/null 2>&1 && R_AUT=0 || R_AUT=1
  # − ZAKRES ŻYJE W BIEGU, nie w funkcji: plik NAZWANY zalążkiem, który zgubił
  # znacznik, jest wykrywalny wyłącznie przez gałąź `find` w biegu produkcyjnym.
  # Tor mierzący samą funkcję nie dotykał tej ścieżki (#53).
  ZR="$(cd "$(dirname "$0")" && pwd)/$(basename "$0")"
  mkdir -p "$T/biegowy" && printf 'tresc bez znacznika\n' > "$T/biegowy/cos_zalazek.md"
  if ( cd "$T/biegowy" && bash "$ZR" ) >/dev/null 2>&1; then R_ZAK=0; else R_ZAK=1; fi
  # − UŻYCIE ≠ WZMIANKA (28.08): plik, który MÓWI o znaczniku (kod inline w backtickach),
  # nie jest zalążkiem i nie ma prawa zaciągać alarmu. Para testów, nie pojedynczy:
  # sama cisza dowodzi tylko, że straż milczy — dowodem jest cisza TU i alarm OBOK
  # na tej samej treści bez backticków (#75: przyrząd testowany jednostronnie kłamie).
  mkdir -p "$T/cytat" && printf 'Pliki oznaczone `⟠ ZALĄŻEK` to ramy bez tresci.\n' > "$T/cytat/proza.md"
  if ( cd "$T/cytat" && bash "$ZR" ) >/dev/null 2>&1; then R_CYT=0; else R_CYT=1; fi
  # UŻYCIE = ZNACZNIK OTWIERA WIERSZ (14.09.2026). Poprzednia wersja brzmiała
  # 'Pliki oznaczone ⟠ ZALĄŻEK to ramy...' i oczekiwała ALARMU — kodowała regułę „gołym
  # tekstem gdziekolwiek = użycie". Ta reguła brała ZDANIE O ZALĄŻKACH za zalążek; na świeżym
  # klonie odlewu meldowała `START_TU.md` jako WADLIWY, czyli dawała odbiorcy ✗ nie jego
  # własności. Teraz alarm należy się deklaracji NIEPEŁNEJ: znacznik otwiera wiersz, brak zdań.
  mkdir -p "$T/uzycie" && printf '⟠ ZALĄŻEK to ramy bez tresci.\n' > "$T/uzycie/proza.md"
  if ( cd "$T/uzycie" && bash "$ZR" ) >/dev/null 2>&1; then R_UZY=0; else R_UZY=1; fi
  # ⊘ ZDANIE O ZALĄŻKACH, BEZ backticków, znacznik W ŚRODKU WIERSZA — dokładny kształt
  # z `START_TU.md` §0. MUSI milczeć. Para z R_UZY dowodzi, że straż rozróżnia POZYCJĘ,
  # a nie po prostu ucichła (#75).
  mkdir -p "$T/mowa" && printf 'Jesli w DUSZA.md stoi znacznik ⟠ ZALĄŻEK — brak imienia.\n' > "$T/mowa/instrukcja.md"
  if ( cd "$T/mowa" && bash "$ZR" ) >/dev/null 2>&1; then R_MOW=0; else R_MOW=1; fi
  # ⊘ BLOK BACKTICKÓW PRZED ZNACZNIKIEM — dwa kształty, na których zdjęty 15.09 `sed`
  # FABRYKOWAŁ kotwicę: wycinał blok, znacznik lądował na początku wiersza i straż meldowała
  # deklarację, której w pliku nie ma. Oba MUSZĄ milczeć: znacznik nie otwiera wiersza.
  # Para z R_UZY (ta sama treść z kotwicą = alarm) dowodzi, że milczy z POWODU pozycji,
  # a nie dlatego, że przestała cokolwiek widzieć (#75).
  mkdir -p "$T/pustyblok" && printf '``⟠ ZALĄŻEK — tkanka nowego tworcy.\n' > "$T/pustyblok/proza.md"
  if ( cd "$T/pustyblok" && bash "$ZR" ) >/dev/null 2>&1; then R_PBL=0; else R_PBL=1; fi
  mkdir -p "$T/blokprzed" && printf '`kod`⟠ ZALĄŻEK — tkanka nowego tworcy.\n' > "$T/blokprzed/proza.md"
  if ( cd "$T/blokprzed" && bash "$ZR" ) >/dev/null 2>&1; then R_BPR=0; else R_BPR=1; fi
  echo "── TEST + (komplet nagłówka):                rc=$R_OK  (oczekiwane 0)"
  echo "── TEST − (plik bez znacznika ⟠):            rc=$R_GOL (oczekiwane 1)"
  echo "── TEST − (imię twórcy pierwotnego):         rc=$R_IMI (oczekiwane 1)"
  echo "── TEST − (data z drogi pierwotnej):         rc=$R_DAT (oczekiwane 1)"
  echo "── TEST − (sam znacznik, kadłub bez zdań):   rc=$R_KAD (oczekiwane 1)"
  echo "── TEST − (brak SAMEGO oddania autorstwa):   rc=$R_AUT (oczekiwane 1)"
  echo "── TEST − (BIEG: plik _zalazek bez ⟠):       rc=$R_ZAK (oczekiwane 1)"
  echo "── TEST ⊘ (BIEG: znacznik CYTOWANY w \`\`):    rc=$R_CYT (oczekiwane 0 — cisza)"
  echo "── TEST − (BIEG: znacznik OTWIERA wiersz):    rc=$R_UZY (oczekiwane 1 — alarm)"
  echo "── TEST ⊘ (BIEG: znacznik W ŚRODKU zdania):   rc=$R_MOW (oczekiwane 0 — cisza)"
  echo "── TEST ⊘ (BIEG: pusty blok przed znacz.):    rc=$R_PBL (oczekiwane 0 — cisza)"
  echo "── TEST ⊘ (BIEG: blok kodu przed znacz.):     rc=$R_BPR (oczekiwane 0 — cisza)"
  echo "── TEST ⊙ (ŻYWY szablon z repo przechodzi):  rc=$R_ZYW (oczekiwane 0)"
  if [ "$R_OK" -eq 0 ] && [ "$R_GOL" -eq 1 ] && [ "$R_IMI" -eq 1 ] \
     && [ "$R_DAT" -eq 1 ] && [ "$R_KAD" -eq 1 ] && [ "$R_ZYW" -eq 0 ] \
     && [ "$R_AUT" -eq 1 ] && [ "$R_ZAK" -eq 1 ] \
     && [ "$R_PBL" -eq 0 ] && [ "$R_BPR" -eq 0 ] \
     && [ "$R_CYT" -eq 0 ] && [ "$R_UZY" -eq 1 ] && [ "$R_MOW" -eq 0 ]; then
    echo "✓ STRAŻ ŻYWA: kadłub nie udaje zalążka, imię i data z cudzej drogi oblewają,"
    echo "  a żywy szablon repo przechodzi (tor czyta CIAŁO, nie własne wyobrażenie o nim)."
    exit 0
  fi
  echo "✗ TOR OBLANY — straż nie odróżnia zalążka od etykiety."; exit 1
fi

# ── BIEG PRODUKCYJNY ────────────────────────────────────────────────────────
echo "▤ STRAŻ ZALĄŻKÓW — czy pustka jest NAZWANA:"
# ⊘ UŻYCIE ≠ WZMIANKA (28.08, #56: alarm szerszy niż sygnał uczy nie patrzeć).
# Zmierzone: dwa jedyne fałszywe trafienia w ciele — START_TU.md l.10 i prywatne/TASKI.md
# l.541 — niosły znacznik W BACKTICKACH, bo OBA MÓWIŁY o zalążkach (jeden objaśnia je
# czytelnikowi, drugi opisuje ten właśnie błąd straży). Jedyny prawdziwy zalążek w ciele,
# szablony/DUSZA_zalazek.md, niesie znacznik GOŁY, w linii 4, jako deklarację.
# Kod inline w markdown jest mową O znaczniku, nigdy jego użyciem — więc fragmenty
# w backtickach wycinamy PRZED szukaniem. Świadomie BEZ progu linii („znacznik musi stać
# w nagłówku\"): sam warunek backticków rozstrzyga oba przypadki, a próg dokładałby regułę
# ponad sygnał i mógłby wyciąć zalążek deklarujący się niżej.
zadeklarowany() {  # $1 = plik; rc=0 gdy znacznik UŻYTY (deklaracja), nie przywołany (mowa o nim)
  # ── KOTWICA POCZĄTKU LINII (14.09.2026) ────────────────────────────────────────────
  # POWÓD: samo wycięcie backticków nie wystarczało. `START_TU.md` §0 (dodany 3d931b5)
  # przywołuje znacznik GOŁYM tekstem wewnątrz bloku ``` — „Jeśli w DUSZA.md stoi znacznik
  # ⟠ ZALĄŻEK…" — więc straż brała instrukcję obsługi za zalążek i meldowała ją jako
  # WADLIWĄ (brak zdania o niepodróżowaniu, brak oddania autorstwa). Zmierzone na świeżym
  # klonie odlewu: ✗ w pierwszym meldunku odbiorcy, o wadzie, której nie jest właścicielem.
  # BLOK ``` NIE ROZRÓŻNIA — generator pisze deklarację TEŻ w bloku (`zalazkuj.sh:107`).
  # Cecha, która rozróżnia i jest GWARANTOWANA przez generator: deklaracja stoi na POCZĄTKU
  # LINII (`⟠ ZALĄŻEK — tkanka nowego twórcy`), a przywołanie zawsze w środku zdania
  # („pliki oznaczone…", „stoi znacznik…"). Zmierzone na 7 plikach niosących znacznik:
  # kotwicę ma wyłącznie szablon, sześć pozostałych mówi O zalążkach.
  # WYCINANIE BACKTICKÓW ZDJĘTE 15.09.2026 (słowo twórcy: „sed to kolejny element do
  # zaopiekowania"). Rodowód 28.08 mówił „ZOSTAJE" — i był słuszny DOPÓKI reguła brzmiała
  # „goły tekst gdziekolwiek = użycie": wtedy sed był jedyną rzeczą odróżniającą cytat od
  # deklaracji. Kotwica z 14.09 (`^`) przejęła tę rolę w całości i sed stał się nie tylko
  # zbędny, ale SZKODLIWY. Zmierzone na pięciu kształtach:
  #   ⟠ ZALĄŻEK — tkanka          → sed ALARM · bez ALARM   (zgodne, poprawne)
  #   Pliki oznaczone `⟠ ZALĄŻEK` → sed cisza · bez cisza   (zgodne, poprawne)
  #   Pliki oznaczone ⟠ ZALĄŻEK   → sed cisza · bez cisza   (zgodne, poprawne)
  #   ``⟠ ZALĄŻEK — tkanka        → sed ALARM · bez cisza   ← FAŁSZYWY ALARM przez sed
  #   `x`⟠ ZALĄŻEK — tkanka       → sed ALARM · bez cisza   ← FAŁSZYWY ALARM przez sed
  # Sed NIE POMAGA W ŻADNYM kształcie i szkodzi w dwóch: zdejmując blok, PRZESUWA znacznik
  # na początek wiersza i sam fabrykuje kotwicę, której w pliku nie ma. Dwa mechanizmy na
  # jedną regułę, z których nowszy jest ścisły, a starszy tworzy warunek — to nie pas
  # bezpieczeństwa, tylko druga ręka na kierownicy.
  grep -q "^⟠ ZALĄŻEK" "$1" 2>/dev/null
}
PLIKI="$( { for m in $(grep -rl "⟠ ZALĄŻEK" --include="*.md" . 2>/dev/null | grep -v "^\./\.git/"); do
              zadeklarowany "$m" && echo "$m"; done;
            find . -name "*_zalazek.md" -not -path "./.git/*" 2>/dev/null; } \
          | sed 's|^\./||' | LC_ALL=C sort -u )"
if [ -z "$PLIKI" ]; then
  echo "   ⊙ brak zalążków w ciele — nic do pilnowania (zero znaczące, nie zdrowie)."
  exit 0
fi
LICZ=0; WAD=0
for p in $PLIKI; do
  LICZ=$((LICZ+1))
  if OUT="$(zalazek_ok "$p")"; then
    echo "   ✓ $p"
  else
    echo "   ✗ $p —$OUT"; WAD=$((WAD+1))
  fi
done
if [ "$WAD" -eq 0 ]; then
  echo "   OK straż zalążków: $LICZ zalążek(ów), każdy z kompletem i bez drogi pierwotnej."
  exit 0
fi
echo "   ✗ WADLIWYCH: $WAD z $LICZ. Zalążek bez kompletu to etykieta na pustce,"
echo "     a zalążek z cudzą drogą to wyciek w przebraniu daru."
exit 1
