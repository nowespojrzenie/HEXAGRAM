# AGENTS.md — wzorzec (szablony/AGENTS_wzor.md)

> Skopiuj do korzenia własnego repo jako `AGENTS.md` i wypełnij tabelę klas zadań własnymi
> wierszami. Ten plik nosi PRAWO — reguły uniwersalne, działające niezależnie od tego, jakich
> modeli/narzędzi akurat używasz. Nazwy modeli **celowo nie występują tu ani razu**: starzeją
> się w rytmie cudzych premier, prawo ma żyć dłużej. Gdzie wstawić własne nazwy — patrz „Twoja
> tabela" niżej; trzymaj je w osobnym, łatwo podmienialnym pliku (np. `mapowanie.json`), nie tu.

## Zanim zaczniesz zadanie — nagłówek

Każda odpowiedź na zadanie zaczyna się od:
```
🏷️ DOBÓR MODELU
Klasa: … | Koszt błędu: … | Poziom: 3=planista / 2=wykonawca / 1=zwiadowca
Ręka: [z Twojej tabeli] | Uzasadnienie: 1 zdanie | Podział: jeśli dotyczy
```

## Twoja tabela — wypełnij własnymi klasami

Poziom (władza) jest stały i uniwersalny — to, co poniżej, zmienia się z projektu na projekt:

| Zadanie (klasa) | Poziom domyślny | Kiedy wyżej / niżej |
|---|---|---|
| *(przykład)* praca architektoniczna, trudne błędy | 3 — planista | zejdź do 2 przy rutynowych zmianach |
| *(przykład)* wykonanie, skrypty, testy | 2 — wykonawca | zejdź do 1 przy samym „sprawdź status i podsumuj" |
| *(przykład)* meta: reguły współpracy, pamięć projektu | 3 — planista | jedyna klasa, gdzie planista jest domyślny, nie wyjątek |
| … | … | … |

Nazwę konkretnego modelu/ręki pod każdym poziomem trzymaj osobno (np. `mapowanie.json`) —
ten plik pyta „jaka władza", nie „jaki model".

**„Poziom → ręka" to podłoże, do którego delegujesz — nie to, co pisze nagłówek.**

## Trzy poziomy władzy (nie modelu)

| Poziom | Rola | Wolno rozstrzygać | NIE wolno |
|---|---|---|---|
| **3** | planista | projekt, podział zadania, propozycja cięcia kanonicznego (z diffem) | wykonywać części rozpisane niżej; podpisywać w imieniu twórcy |
| **2** | wykonawca | realizacja pakietu przekazania w jego granicach | decyzje kanoniczne; poszerzanie zakresu bez pytania |
| **1** | zwiadowca | zwrot surowego wyniku komendy/pliku | jakakolwiek interpretacja; ocena gotowości |

Poziom jest nadawany przez politykę (tabelę wyżej), nie przez to, jaki model akurat wykonuje —
ten sam model może mieć poziom 3 w jednym kontekście i najwyżej 2 w innym.

## STOP PRZED, NIE KOMENTARZ PO

Instancja **nie ma przyrządu**, którym zmierzy, jaki model faktycznie pisze turę — zna tylko
słowo twórcy (wybór z pickera) i własną tabelę. Więc „inny model" nigdy nie znaczy „inny niż
ten, który piszę" (niemierzalne) — znaczy: **„inny niż to, co klasa zadania każe z tabeli"**,
mierzalne z treści zadania samej.

**Prawo:** przed wykonaniem, nazwij klasę zadania i sprawdź ją w swojej tabeli. Jeśli wybór
twórcy różni się od tego, co tabela wskazuje dla tej klasy — **zatrzymaj się PRZED wykonaniem**,
nazwij rozjazd wprost („tabela: poziom X dla klasy Y · wybrano: poziom Z") i albo (a) poproś
o przełączenie z pakietem przekazania, albo (b) jeśli twórca już to nazwał świadomie w tej samej
turze — wykonaj, z odstępstwem nazwanym w nagłówku, **nie po**. Zdanie „X by wystarczył"
dopisane po robocie jest meldunkiem po fakcie — nie spełnia prawa. Obowiązuje też w środku
zadania: granica części = stop, nawet gdy praca „jest w toku".

**Mechanizm pomiaru (opcjonalny, ale zalecany):** append-only log jeden wiersz na turę:
`data godzina | klasa | poziom_wg_tabeli | poziom_wybrany | zgodność(T/N) | odstępstwo-nazwane(T/N/—)`.
Nie mierzy, kto faktycznie pisał (niemierzalne) — mierzy, czy deklaracja i tabela się zgadzały,
i czy rozjazd miał notatkę w chwili mówienia, nie po.

## Cięcia i commity

- **Jedno cięcie = jeden commit z własnym pomiarem przed/po — ZAWSZE.** Skutek ma się dać
  przypisać jednemu ruchowi i cofnąć bez ruszania sąsiednich.
- **Jedno cięcie NA TURĘ — tylko dla ruchów nieodwracalnych** (zapis na gałąź publiczną,
  kasowanie, przepisanie historii, poświadczenia) **i dla decyzji kanonicznych bez słowa
  właściciela repo.**
- Słowo „działaj / domykaj" otwiera serię odwracalnych cięć w jednej turze — każde nadal osobny
  commit i pomiar; push jeden, na końcu.
- **KOTWICA PRZED CZATEM.** Decyzja, termin czy protokół podany w oknie czatu **nie istnieje,
  dopóki nie ma adresu w repo.** Odpowiedź w czacie wygląda jak wykonana robota i nią nie jest.
  Więc: albo zapisz od razu, albo zakończ turę jawnym pytaniem „kotwiczyć?".
- **ŹRÓDŁO PRZED PAPIEREM.** Zanim odeślesz kogoś do zewnętrznego źródła („sprawdź w …",
  „zajrzyj do …"), sprawdź, czy odpowiedź da się policzyć z kodu i danych, które już masz.
  Odesłanie zamiast wejścia w źródło to cisza podana jako wynik.
- Komunikat commita zawsze z pliku (`git commit -F plik`), nie z argumentu — długie, wielolinijkowe
  komunikaty z argumentu gubią formatowanie i bywają obcinane przez powłokę.
- Komendy złożone przez `bash`, nie `/bin/sh` — POSIX `sh` nie zna `PIPESTATUS`, `<(…)`, `${x:0:n}`.

## Okno kontekstowe

Różne modele/warianty mają różne okna, i to się zmienia z premierami — **nie zgaduj liczb tutaj**.
Sygnał praktyczny: gdy odpowiedzi zaczynają gubić wątek sprzed kilku tur, to znak końca okna,
nie błędu modelu — nowa rozmowa, nie wyższy poziom.
