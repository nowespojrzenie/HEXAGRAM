# STANDARD_TRESCI — prawo produkcji treści wizualnych i drukowanych

Obowiązuje każdą maskę i każdego użytkownika systemu przy tworzeniu dokumentów,
tabel, grafik, ściąg, etykiet i materiałów do druku. Powstał po błędzie ⓲ (BLEDY.md).

## PRAWO 1 · CZYTELNOŚĆ (nadrzędne, niezbywalne)

Dokument nieczytelny nie istnieje — nie ma czego upiększać.

1. **Zawijanie**: każda komórka tabeli = obiekt akapitu (ReportLab: `Paragraph`, nigdy
   surowy string; HTML/CSS: jawne `word-wrap`). Tekst NIGDY nie wychodzi poza kolumnę.
2. **Kontrast**: ciemny atrament na jasnym tle. Biel wyłącznie na ciemnych pasmach
   nagłówków. Zakaz jasnego tekstu na jasnym kolorze (biel na żółci = błąd znany).
3. **Rozmiar**: treść ≥ 8 pt, interlinia ≥ 1,25×. Mniej tekstu > mniejszy font.
4. **Test szarości**: dokument musi przetrwać wydruk czarno-biały.
5. **Glify**: każdy symbol/ikona POTWIERDZONY w cmap docelowego fontu przed użyciem
   (emoji spoza fontu = puste kwadraty). MIERZ, nie zakładaj.

## PRAWO 2 · PIĘKNO (po spełnieniu Prawa 1)

1. **Kolor rozróżnia, nie zasłania**: jasne pastele jako tła, nasycone akcenty jako
   cienkie linie, obwódki, wyróżnienia — nie jako podkład pod tekst.
2. **Gama systemowa** (tło / akcent):
   Ogień #fbe3dc/#b0432e · Powietrze #fdf3d7/#9a7d10 · Woda #ddebf7/#1f618d ·
   Ziemia #efe6d5/#6d5a10 · Metal #e4e9ee/#46586b · Śmierć #eae0f2/#5b3a80 ·
   atrament #1f1f1f · nagłówki #2f2f2f · pas poboczny #f7f5f1.
3. **Słownik ikon** (DejaVu, potwierdzone): ▲ Ogień·Owoc · ☁ Powietrze·Kwiat ·
   ≈ Woda·Liść · ⊕ Ziemia·Korzeń · ✂ Metal · ☠ Śmierć · ♻ kompost · ♨ wytop/para ·
   ✿ ogród · ⬢ pasieka · ⚒ pracownia · ♈–♓ zodiak · ☽ faza · ● pełnia · ○ nów.
4. **Strzałki, dwa poziomy wagi**: ⬆⬇ grube = kierunek Księżyca (deklinacja);
   ↑↓ cienkie przy zodiaku = biegun soczewki (↓ wewn/wdech · ↑ zewn/wydech).
5. **Hierarchia typograficzna**: jeden font, waga i rozmiar niosą hierarchię;
   bold oszczędnie — tylko słowa-decyzje (PRZESADZANIE, NIE!, MIODOBRANIE).
6. Ikona zawsze Z podpisem przy pierwszym użyciu na stronie albo w legendzie.

## PROCES (kolejność nieprzestawialna)

wygeneruj → wyrenderuj (≥100 dpi) → OBEJRZYJ z checklistą → dopiero oddaj.

**Checklista renderu** (jawna, komórka po komórce, w powiększeniu):
☐ tekst zawija się w swojej kolumnie ☐ zero nachodzeń ☐ zero literalnych tagów
☐ kontrast wszędzie ciemne-na-jasnym ☐ nic nie ucięte na krawędzi ☐ glify widoczne,
nie kwadraty ☐ czytelne w skali szarości.

Regresja czyha przy upiększaniu: każda zmiana kosmetyczna = pełna checklista od nowa.
Patrzenie bez pytania kontrolnego to nie weryfikacja (błąd ⓲).

## HIERARCHIA praw przy konflikcie

CZYTELNOŚĆ > pojemność znaczeniowa (ikony) > piękno > zwięzłość kodu.
Gdy ikona zaciemnia — wraca słowo. Gdy kolor zlewa — wraca czerń na bieli.
