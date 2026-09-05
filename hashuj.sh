#!/usr/bin/env bash
# KRONOS · HASHUJ v1.1 (27.07.2026 · tor testowy + zamek markerów 31.07.2026)
# ODNAWIANIE ODCISKÓW (ratyfikacja: (a) dla tkanki)
# ZASADA: automatycznie odnawia hashe TYLKO plikow TKANKI (rejestry, ktore z natury rosna).
# RDZEN, SILNIKI I KANON — nigdy automatycznie: ich zmiana ma boleć i wymagać reki tworcy.
#
# ZAMEK MARKERÓW (31.07.2026, mechanizm do blizny #37): przed jakimkolwiek zapisem
# sprawdza, czy _HASHE.txt nie niesie markerów konfliktu. 31.07 rano markery z rebase
# PRZEŻYŁY ten skrypt (bo on aktualizuje LINIE, nie regeneruje pliku), weszły do commita,
# a weryfikacja świeciła 106 ✓ nad zepsutym kanonem — nieparsowalne linie były cicho
# pomijane. Prawo stamtąd: plik regenerowalny != plik samonaprawialny. Zamek stoi TU,
# bo to hashuj jest narzędziem, które wtedy przejechało po zepsutym pliku.
#
# Uzycie:  bash hashuj.sh            (tylko tkanka — bezpieczne, wolane z zapis_git.sh)
#          bash hashuj.sh <plik>...  (jawnie wskazane pliki — swiadoma decyzja)
#          bash hashuj.sh --test     (tor +/− — straż musi umieć NIE przejść)
#          bash hashuj.sh --odcisk <plik>  (odcisk kanoniczny — dla innych pisarzy rejestru)
set -e

# ── ODCISK KANONICZNY (02.09.2026, rozstrzygnięcie twórcy, tura CRLF) ──
# Dysk ZOSTAJE źródłem (przyrząd musi widzieć zmiany niezacommitowane), ale liczymy
# TREŚĆ KANONICZNĄ: `\r` zdjęte z bufora przed sha256. Ten sam plik na Windows (CRLF)
# i Linuksie (LF) daje jeden odcisk — równy odciskowi blobu w indeksie, którym mierzy
# zamek #67 w hooku. Zmierzone 02.09: 134 odciski w rozjeździe na Windows przy 11 na
# Linuksie, jeden kanon. Binaria (NUL w pierwszych 8000 B — heurystyka gita) liczone
# SUROWO, bo git ich nie normalizuje. Jedna definicja dla całej rodziny pisarzy:
# sync_rdzen.sh i publikuj.sh wołają `bash hashuj.sh --odcisk`, strona JS ma bliźniaczą
# `kanon()` w weryfikacja.js. Tor (5) poniżej pilnuje obu stron: LF=CRLF, ale ≠ zmiana.
odcisk() {
  if head -c 8000 "$1" | od -An -tx1 | grep -q ' 00'; then sha256sum < "$1"; else tr -d '\r' < "$1" | sha256sum; fi | cut -c1-12
}
if [ "${1:-}" = "--odcisk" ]; then odcisk "$2"; exit; fi

TKANKA="prywatne/TASKI.md prywatne/ZADANIA.md kanon/ksiegi/BLEDY.md prerejestr/PREREJESTR_oddech.md kanon/ksiegi/DESTYLATY_architekta.md \
kanon/ksiegi/KANON_LOG.md kanon/ksiegi/ZAPIS_HEKSA.md 0_SNAPSHOT_watek.md kanon/archiwum/ARCHIWUM_destylatow.md kanon/tozsamosc/PROFIL.md \
kanon/ksiegi/KSIEGA_SIEGNIEC.md kanon/ksiegi/PROGNOZY_IMPULS_08-09.md kanon/ksiegi/KOLEJKA_M.md"

# ── TOR TESTOWY (#38) ──
# Trzy reguły deklarowane przez ten skrypt, każda z własnym torem:
#   (1) tryb auto odnawia TKANKĘ, (2) tryb auto NIE TYKA kanonu,
#   (3) plik spoza _HASHE.txt nie wchodzi do straży sam z siebie,
#   (4) zamek markerów konfliktu (#37).
if [ "${1:-}" = "--test" ]; then
  SAM="$(cd "$(dirname "$0")" && pwd)/$(basename "$0")"
  echo "╔═══ HASHUJ — AUTOTEST (#38) ═══╗"
  T="$(mktemp -d)"
  # fikstura odtwarza TOPOLOGIĘ produkcji (po Cięciach 4–5 pliki mają domy, nie korzeń) —
  # płaskie ścieżki dały 22–24.08 sześć fałszywych "STRAŻ MARTWA" po przeprowadzce (#64)
  mkdir -p "$T/prywatne" "$T/kanon/tozsamosc"
  printf 'stara treść\n'  > "$T/prywatne/TASKI.md"          # tkanka (na liście TKANKA)
  printf 'rdzeń\n'        > "$T/kanon/tozsamosc/5_RDZEN.md" # kanon (POZA listą TKANKA)
  printf 'obcy\n'         > "$T/OBCY.md"                    # nieobjęty _HASHE.txt
  {
    echo "000000000000  prywatne/TASKI.md"
    echo "000000000000  kanon/tozsamosc/5_RDZEN.md"
  } > "$T/_HASHE.txt"

  ( cd "$T" && bash "$SAM" >/dev/null 2>&1 )
  H_TK="$(grep '  prywatne/TASKI.md$'   "$T/_HASHE.txt" | cut -d' ' -f1)"
  H_KA="$(grep '  kanon/tozsamosc/5_RDZEN.md$' "$T/_HASHE.txt" | cut -d' ' -f1)"
  ILE_OBCY="$(grep -c 'OBCY.md' "$T/_HASHE.txt" || true)"
  echo "── TEST + (tkanka odnowiona):        prywatne/TASKI.md   $H_TK  (oczekiwane: ≠ 000000000000)"
  echo "── TEST − (kanon NIETKNIĘTY):        kanon/tozsamosc/5_RDZEN.md $H_KA  (oczekiwane: = 000000000000)"
  echo "── TEST ⊙ (plik spoza straży):       OBCY.md w _HASHE: $ILE_OBCY  (oczekiwane: 0)"

  # (4) zamek markerów: hashuj MUSI odmówić pracy na pliku z konfliktem
  printf '<<<<<<< HEAD\n000000000000  prywatne/TASKI.md\n=======\n111111111111  prywatne/TASKI.md\n>>>>>>> inna\n' > "$T/_HASHE.txt"
  set +e; ( cd "$T" && bash "$SAM" >/dev/null 2>&1 ); RC_MARK=$?; set -e
  echo "── TEST − (markery konfliktu, #37):  rc=$RC_MARK  (oczekiwane 1)"

  # (5) TOR DWUSTRONNY CRLF (02.09.2026, słowo twórcy): (+) ten sam plik z LF i z CRLF →
  #     JEDEN odcisk i JEDEN rozmiar w straży append-only; (−) jeden znak treści → INNY
  #     odcisk; (⊙) binarny liczony surowo (CR w binarium to treść, nie koniec linii).
  #     Bez (−) normalizacja oślepiłaby straż: przyrząd zrównujący wszystko = przyrząd martwy.
  printf 'linia\ndruga\n'     > "$T/lf.md"
  printf 'linia\r\ndruga\r\n' > "$T/crlf.md"
  printf 'linia\ndrugi\n'     > "$T/zmiana.md"
  printf '\000\r\n'           > "$T/bin.dat"
  printf '\000\n'             > "$T/bin2.dat"
  H_LF="$(bash "$SAM" --odcisk "$T/lf.md")"; H_CRLF="$(bash "$SAM" --odcisk "$T/crlf.md")"
  H_ZM="$(bash "$SAM" --odcisk "$T/zmiana.md")"
  H_B1="$(bash "$SAM" --odcisk "$T/bin.dat")"; H_B2="$(bash "$SAM" --odcisk "$T/bin2.dat")"
  printf '## a\r\n## b\r\n'          > "$T/diament.md"
  printf 'diament.md  0  0\n'        > "$T/_STRAZ_APPEND.txt"
  printf '000000000000  diament.md\n' > "$T/_HASHE.txt"
  ( cd "$T" && bash "$SAM" diament.md >/dev/null 2>&1 )
  B_STRAZ="$(awk '$1=="diament.md"{print $2}' "$T/_STRAZ_APPEND.txt")"
  echo "── TEST ± (CRLF: LF=CRLF≠zmiana):    $H_LF $H_CRLF $H_ZM"
  echo "── TEST ⊙ (binarny liczony surowo):  $H_B1 $H_B2  (oczekiwane: różne)"
  echo "── TEST ± (straż append-only):       diament z CRLF → $B_STRAZ B  (oczekiwane 10 = bez CR)"
  rm -rf "$T"
  echo
  if [ "$H_TK" != "000000000000" ] && [ "$H_KA" = "000000000000" ] \
     && [ "$ILE_OBCY" -eq 0 ] && [ "$RC_MARK" -eq 1 ] \
     && [ "$H_LF" = "$H_CRLF" ] && [ "$H_LF" != "$H_ZM" ] && [ "$H_B1" != "$H_B2" ] \
     && [ "$B_STRAZ" = "10" ]; then
    echo "✓ STRAŻ ŻYWA: odnawia tkankę, nie tyka kanonu, nie wciąga obcych, odmawia na konflikcie, nie widzi końców linii, widzi treść."
    exit 0
  fi
  echo "✗ STRAŻ MARTWA: H_TK=$H_TK H_KA=$H_KA OBCY=$ILE_OBCY RC_MARK=$RC_MARK LF=$H_LF CRLF=$H_CRLF ZM=$H_ZM B1=$H_B1 B2=$H_B2 STRAZ=$B_STRAZ"
  exit 1
fi

# ── ZAMEK MARKERÓW (#37) — przed czymkolwiek innym ──
if [ -f _HASHE.txt ] && grep -qE '^(<<<<<<<|=======|>>>>>>>)' _HASHE.txt; then
  echo "   ✗ _HASHE.txt niesie MARKERY KONFLIKTU — nie tykam pliku (blizna #37)."
  echo "     Scal ręcznie obie strony bloku, potem uruchom ponownie."
  exit 1
fi

if [ $# -gt 0 ]; then LISTA="$*"; TRYB="jawny"; else LISTA="$TKANKA"; TRYB="tkanka"; fi
ZM=0
POZA=0
for f in $LISTA; do
  [ -f "$f" ] || continue
  # BLIZNA 14.08.2026 (rodzina #39 „cisza zamiast alarmu"): plik spoza rejestru byl
  # POMIJANY W MILCZENIU — jawnie wskazana straz (`bash hashuj.sh straz_X.sh`) konczyla sie
  # slowem „odnowionych 3\" i nikt nie wiedzial, ze czwarty plik nie wszedl pod spojnosc.
  # Zmierzone tego dnia: 4 przyrzady bez odcisku (pokrycie_m · straz_destylatow ·
  # straz_prerejestrow · straz_kryteriow) — wszystkie urodzone po ostatniej regeneracji.
  # Skrypt NADAL nie dodaje linii sam (dodanie = decyzja kanoniczna, reka tworcy), ale MOWI.
  if ! grep -q "  $f\$" _HASHE.txt; then
    echo "   ⚠ POZA REJESTREM (odcisk NIE powstal): $f — dopisz linie w _HASHE.txt swiadomie"
    POZA=$((POZA+1)); continue
  fi
  H=$(odcisk "$f")
  STARY=$(grep "  $f\$" _HASHE.txt | cut -d' ' -f1)
  if [ "$H" != "$STARY" ]; then
    sed -i "s|^[0-9a-f]\{12\}  $f\$|$H  $f|" _HASHE.txt
    echo "   odnowiony odcisk: $f ($STARY -> $H)"; ZM=$((ZM+1))
  fi
done
# straz append-only: podniesienie poprzeczki (diamenty rosna — zapisujemy nowa wysokosc)
if [ -f _STRAZ_APPEND.txt ]; then
  node -e '
    const fs=require("fs");
    const wier=fs.readFileSync("_STRAZ_APPEND.txt","utf8").split("\n");
    const out=wier.map(l=>{
      if(!l||l.startsWith("#")) return l;
      const f=l.trim().split(/\s+/)[0];
      if(!fs.existsSync(f)) return l;
      // bajty TREŚCI KANONICZNEJ (bez \r) — rozmiar CRLF skaził rejestr 02.09 (blizna tury 4)
      const t=fs.readFileSync(f,"utf8").replace(/\r/g,"");
      return [f, Buffer.byteLength(t), (t.match(/^## /gm)||[]).length].join("  ");
    });
    fs.writeFileSync("_STRAZ_APPEND.txt", out.join("\n"));
  '
fi
echo "   hashuj ($TRYB): odnowionych $ZM${POZA:+ · POZA REJESTREM: $POZA}"
