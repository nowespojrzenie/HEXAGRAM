#!/usr/bin/env bash
# KRONOS · HASHUJ v1.0 (27.07.2026) — odnawianie odcisków (ratyfikacja: (a) dla tkanki)
# ZASADA: automatycznie odnawia hashe TYLKO plikow TKANKI (rejestry, ktore z natury rosna).
# RDZEN, SILNIKI I KANON — nigdy automatycznie: ich zmiana ma boleć i wymagać reki tworcy.
# Uzycie:  bash hashuj.sh            (tylko tkanka — bezpieczne, wolane z zapis_git.sh)
#          bash hashuj.sh <plik>...  (jawnie wskazane pliki — swiadoma decyzja)
set -e
TKANKA="TASKI.md ZADANIA.md BLEDY.md prerejestr/PREREJESTR_oddech.md DESTYLATY_architekta.md \
KANON_LOG.md ZAPIS_HEKSA.md 0_SNAPSHOT_watek.md archiwum/ARCHIWUM_destylatow.md PROFIL.md \
KSIEGA_SIEGNIEC.md PROGNOZY_IMPULS_08-09.md"
if [ $# -gt 0 ]; then LISTA="$*"; TRYB="jawny"; else LISTA="$TKANKA"; TRYB="tkanka"; fi
ZM=0
for f in $LISTA; do
  [ -f "$f" ] || continue
  grep -q "  $f\$" _HASHE.txt || continue          # tylko pliki JUZ objete straza
  H=$(sha256sum "$f" | cut -c1-12)
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
      const t=fs.readFileSync(f,"utf8");
      return [f, Buffer.byteLength(t), (t.match(/^## /gm)||[]).length].join("  ");
    });
    fs.writeFileSync("_STRAZ_APPEND.txt", out.join("\n"));
  '
fi
echo "   hashuj ($TRYB): odnowionych $ZM"
