# Wzór: `.markery_osobowe` — lista markerów PII

**Czym to jest:** wzór pliku, który czyta `narzedzia/straze/straz_czystosci.sh` przed publikacją.
**Status:** SZABLON — skopiuj do korzenia repo jako `.markery_osobowe` i wypełnij.
**Dokąd należy:** `szablony/` (wychodzi w odlewie); wypełniona lista — **tylko lokalnie**.

---

## Zasada nadrzędna: wzorce, nie dane

**Do tej listy nie wpisuje się numerów, maili ani adresów.** Wpisanie ich zrobiłoby
z pliku ochronnego **kolejną kopię tych samych danych** — kopia do kopii do kopii,
czyli powiększenie powierzchni, którą lista ma chronić.

Wpisuje się **kształty**: „coś, co wygląda jak telefon", „coś, co wygląda jak IBAN".
Dwa zyski: sama lista przestaje być daną osobową, i **łapie też dane, których autor
listy nie znał** — numer klienta, mail z sesji, adres wklejony za pół roku.

**Wyjątek: imiona.** Imienia nie da się opisać kształtem, więc imiona wpisuje się
dosłownie — wraz z odmianami, bo straż szuka dosłownie (`Anna`, `Anny`, `Annie`, `Anną`).

## Jak to działa

`narzedzia/straze/straz_czystosci.sh` puszcza każdą linię przez `git grep` **w katalogu odlewu**, nie
w repo. Skanowane jest wyłącznie to, co realnie wychodzi na zewnątrz — prywatna tkanka
może zawierać wszystkie dane świata i nie zaświeci.

Składnia: **BRE** (podstawowe wyrażenia regularne). `\{3\}` = trzy razy · `\?` = opcjonalne ·
`\|` = albo. `#` = komentarz, puste linie ignorowane.

## Zasada doboru wzorca (zmierzona, nie teoretyczna)

**Wzorzec numeryczny bez kontekstu jest ślepy.** Pomiar na 131 plikach odlewu 28.08.2026:

| wzorzec | wynik | dlaczego |
|---|---|---|
| `+48` | 3 trafienia szumu | łapie stałe astronomiczne (`+481267.88`) |
| `[0-9]\{3\}` grupy bez spacji | 16 plików szumu | łapie hashe i pliki binarne |
| `[0-9]\{11\}` | 4 pliki szumu | łapie hashe |
| `[0-9]\{3\} [0-9]\{3\} [0-9]\{3\}` | **0 szumu** | spacje = kontekst telefonu |
| `+48 [0-9]` | **0 szumu** | prefiks + spacja |

**Reguła: każdy nowy wzorzec przetestuj na własnym ciele, zanim wejdzie na listę.**
Fałszywy alarm blokuje odlew i uczy ignorować straż — a straż ignorowana jest gorsza
niż jej brak, bo daje poczucie ochrony.

Test jednego wzorca:
```sh
git grep -c 'TWÓJ_WZORZEC' -- '*.md' '*.js' '*.sh'
git grep -o 'TWÓJ_WZORZEC' | head     # ZOBACZ trafienia, nie tylko policz (#66)
```

## Szkielet do skopiowania

```
# .markery_osobowe — WZORCE, nie dane

# -- OSOBY (dosłownie, z odmianami — imion nie opisze kształt) --
# twoje nazwisko
# twoje imię + odmiany
# imiona domowników + odmiany
# imiona klientów, uczestników sesji, osób z rozmów

# -- TELEFON --
[0-9]\{3\} [0-9]\{3\} [0-9]\{3\}
[0-9]\{3\}-[0-9]\{3\}-[0-9]\{3\}
+48 [0-9]
tel[:.]

# -- E-MAIL --
# Ogólny wzorzec `[a-zA-Z0-9._%+-]\+@[a-zA-Z0-9.-]\+\.[a-zA-Z]\{2,\}` łapie też
# adresy techniczne w kanonie. Albo dodaj je do `_STRAZ_wyjatki.txt`, albo
# wpisz same domeny prywatne:
@gmail
@wp\.
@onet
@proton

# -- ADRES --
ul\. 
[Uu]lica 
[0-9]\{2\}-[0-9]\{3\} [A-ZŁŚŻŹĆ]
# nazwa twojej ulicy, bez numeru

# -- KONTO / IDENTYFIKATORY --
# UWAGA: zapisane jako `P[E]SEL` / `N[I]P` celowo — regex łapi słowo, ale sam nim NIE JEST.
# Inaczej ten szablon (który wychodzi w odlewie) byłby własnym trafieniem i blokował publikację.
# Zmierzone 29.08.2026 uruchomieniem `narzedzia/straze/straz_czystosci.sh` na tym pliku.
PL[0-9]\{26\}
[0-9]\{2\} [0-9]\{4\} [0-9]\{4\} [0-9]\{4\}
P[E]SEL
N[I]P[:. ]

# -- ŚCIEŻKI ZDRADZAJĄCE UŻYTKOWNIKA SYSTEMU --
C:\\Users\\
/home/[a-z]\+/Desktop
/Users/[a-z]\+/
```

## Dwa zamki, dwie role — nie myl ich (29.08.2026, zmierzone biegiem straży)

| zamek | lista | wyjątki | do czego |
|---|---|---|---|
| `zamek_wyciek` w `publikuj.sh` | `_STRAZ_wzorzec.txt` (w repo) | **TAK** — `_STRAZ_wyjatki.txt` | imiona i nazwy, które znasz; podpis autora można ułaskawić |
| `narzedzia/straze/straz_czystosci.sh` | `.markery_osobowe` (lokalna) | **NIE** — brak mechanizmu | dane, których wzorzec nie zna: telefony, maile, konta, klienci |

**Konsekwencja praktyczna:** **nie wpisuj własnego imienia do `.markery_osobowe`**, jeśli
występuje w README jako podpis — ta straż nie umie ułaskawiać i zablokuje odlew na Twojej
własnej atrybucji. Imiona zostaw pierwszemu zamkowi, który ma wyjątki. Lokalna lista
jest od **kształtów**, nie od tego, co i tak jest w `_STRAZ_wzorzec.txt`.

## Czego NIE wpisywać

- **Atrybucji za zgodą.** Nazwisko współautora podane świadomie w README nie jest
  wyciekiem. Jeśli ściga je drugi zamek (`_STRAZ_wzorzec.txt`), zdejmij je **stamtąd** —
  nie dokładaj wyjątku. Pościg plus ułaskawienie na tę samą osobę to dwa mechanizmy
  walczące ze sobą.
- **Własnego imienia jako autora.** Podpis należy do jednego miejsca — okładki.
  W treści praw autor nazywa się **twórcą**, bo u następnej osoby twórcą będzie ona.
- **Nazw miejscowości używanych przez kod.** Współrzędne i strefy czasowe w silniku
  to parametry, nie dane osobowe. Zablokujesz odlew na własnym kodzie.

> **Pusty plik = brak pliku.** Straż bez markerów przechodzi na zielono, **nie znalazłszy
> niczego, bo nie miała czego szukać** — cisza wyglądająca jak zdrowie. Dlatego zamek
> wymaga co najmniej jednej linii niebędącej komentarzem.
