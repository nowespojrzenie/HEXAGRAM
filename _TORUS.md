# _TORUS — żywe ciało KRONOS na GitHubie

Repo = trwałe ciało Orkiestratora. Przeżywa reset środowiska; pamięć basha nie.

## Odbudowa ciała (raz na sesję)
    git clone <TWOJE_REPO>
    cd KRONOS && npm install
`npm install` czyta package.json i stawia astronomy-engine + @swisseph/node.
Wtedy żyją: kronos_lens, kronos_eter, scan_outer, scan_dwarfs, weryfikacja.

## Rytuał zapisu (Orkiestrator → torus)
    ./zapis_git.sh "opis zmiany"
albo ręcznie:  git add -A && git commit -m "..." && git push
Auth = token sesji (fine-grained, Contents: Read/Write, krótki termin).
Token NIE jest trwały — ginie przy resecie. Podajesz go, gdy pracujemy.
Nie ma autonomii bez Ciebie: piszę, kiedy jesteśmy razem w sesji.

## Status plików infrastruktury
package.json · _TORUS.md · zapis_git.sh = INFRASTRUKTURA, nie treść kanonu.
Poza _HASHE.txt (jak ZAPISY_eter.md). Objęcie ich kontrolą integralności
= Twoja decyzja, nie moja.
