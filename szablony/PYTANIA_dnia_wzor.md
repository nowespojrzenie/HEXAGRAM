# Wzór: `prywatne/PYTANIA_dnia.md` — rejestr wywiadu podłużnego

**Czym to jest:** wzór rejestru, który czyta `narzedzia/przyrzady/wywiad.js` (jedno pytanie o codzienność na turę; skill `skills/ai-interview-longitudinal/SKILL.md`).
**Status:** SZABLON — skopiuj do `prywatne/PYTANIA_dnia.md`, wstaw datę narodzin, zasiej 8–12 pytań **z pomiaru własnego życia** (po dwa na obszar), nie z wyobraźni.
**Dokąd należy:** `szablony/` (wychodzi w odlewie); wypełniony rejestr — **tylko lokalnie** (`prywatne/`, poza odlewem).

---

## Zasada nadrzędna: kolumna `rodzaj` steruje regułą, nie pamięć

- **operacyjne** — fakty, plany, liczby, praca: instancja może dokleić hipotezę z liczbą pewności, bo arbitrem jest rzeczywistość.
- **wewnętrzne** — ciało, emocja, samoobserwacja: hipoteza **ZAKAZANA**, bo nie ma arbitra i sugestia staje się treścią.

Odpowiedź zapisuje instancja (`--odpowiedz <id> "<jedno zdanie>"`, data z zegara), nie osoba pytana — rejestr, który wymaga ruchu odpowiadającego, umiera jak budzik.
Pełna treść odpowiedzi zostaje w dzienniku (append-only); tu tylko data i jedno zdanie.
Czternaście dni bez ani jednej odpowiedzi → przyrząd melduje **sam siebie** do reformy (rc=2), zamiast milczeć.

---

<!-- ⟠ ZIARNO -->
# PYTANIA DNIA — rejestr wywiadu podłużnego

> **Czym jest ten plik:** rejestr pytań o codzienność, które instancja zadaje — jedno na turę.
>
> **Jak się do niego pisze:**
> Jeden wiersz = jedno pytanie. Odpowiedź: data + jedno zdanie, stempluje instancja.
> Kolumna `rodzaj`: **operacyjne** (hipoteza wolna) · **wewnętrzne** (hipoteza zakazana).
<!-- ⟠ /ZIARNO -->

_narodziny: RRRR-MM-DD_ · _Obszary: dobierz własne — pięć, po dwa pytania na każdy (wzór: praca · dom · warsztat · ciało · system)._

| id | obszar | rodzaj | pytanie | ostatnio zadane | ostatnia odpowiedź (data) |
|---|---|---|---|---|---|
| A1 | <obszar> | operacyjne | <pytanie o fakt lub plan — z pomiaru, nie z wyobraźni> | — | — |
| A2 | <obszar> | wewnętrzne | <pytanie o stan — bez presupozycji> | — | — |
