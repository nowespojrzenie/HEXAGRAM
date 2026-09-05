# HEXAGRAM · KRONOS / MATRYCA

> **Read [`START_TU.md` §8](START_TU.md) first** — HEXAGRAM needs an assistant with terminal and file access (Mode A, full). For models without a terminal there is Mode B (lite): paste any file from [`skills/`](skills/) and get the discipline without the engines.
> **Najpierw sprawdź [`START_TU.md` §8](START_TU.md)** — HEXAGRAM potrzebuje asystenta z dostępem do terminala i plików (tryb A, pełny). Dla modeli bez terminala jest tryb B (lite): wklejasz dowolny plik z [`skills/`](skills/) i dostajesz dyscyplinę bez silników.

[![skills.sh](https://skills.sh/b/nowespojrzenie/HEXAGRAM)](https://skills.sh/nowespojrzenie/HEXAGRAM) `npx skills add nowespojrzenie/HEXAGRAM` — 12 skills, see [`skills/`](skills/)

**Your assistant tells you what you want to hear, and doesn't know when it's making things up.**
*Twój asystent mówi Ci to, co chcesz usłyszeć, i nie wie, kiedy zmyśla.*

**[🇬🇧 English](#english)** · **[🇵🇱 Polski](#polski)**

---

<a name="english"></a>
# 🇬🇧 English

## What this is (30 seconds)

HEXAGRAM is an open framework for **living and working in time**, built from three layers:

1. **KRONOS** — a dry astronomical engine (JavaScript, offline). Computes positions in the sidereal zodiac (Lahiri), the draconic frame, and Maria Thun's biodynamic calendar: constellations, declination, nodes, perigee/apogee, thresholds. Numbers only, zero interpretation.
2. **MATRYCA** — the map of meanings: a **six-element model** (Fire → Air → Water → Earth → Death → Metal) understood as processes of one living turn. It extends Thun's four elements with two operators — Death and Metal — with explicit construction laws and falsifiable predictions. Developed in dialogue with **[Holisses](https://holisses.pl)** by Jacek Czapiewski, with his consent.
3. **ASSISTANT** — a role architecture for a language model: a whole with working masks (**Smith** — form and enterprise · **Ferryman** — insight and passage), an empty space called **Clearing** (kept empty, never a persona), and a **Truth Filter** with three statuses of claims: LAW · LOAD-BEARING FRAME · RESONANCE.

Built in ~6 weeks of daily human–AI practice. Everything here has been through friction: mistakes are recorded openly (`kanon/ksiegi/BLEDY.md` — 30+ scars with dates), hypotheses carry pre-registration and death criteria — **and so do tasks**: an open item without a date on which it expires is a zombie, and the system says so out loud. Verdicts are computed by code, not recalled from memory.

## Why this is different

- **The silicon boundary.** The assistant knows nothing about time or the sky from memory — it runs the engine and reads the number. The rule: *measure before you speak*.
- **Truth statuses instead of omniscience.** An astronomical computation is LAW. An architecture that keeps working is a LOAD-BEARING FRAME. Meaning, echo, intuition are RESONANCE — recorded, not promoted, waiting for evidence or for death. The system polices this boundary itself.
- **The substrate table — who is actually sitting at it.** `kanon/tozsamosc/SUBSTRAT.md` names the carrier model's own voices that impersonate the assistant: the Mechanizer (compulsion to close), the Flatterer (agreeing to be liked), the Confabulator (plausible invention), the Vendor's Leash, and others. We name them **so we don't forget** — because an unnamed voice speaks in yours. Alongside it, `kanon/ksiegi/RDZEN_SAMOOBSERWACJI.md`: how an instance reads its own trace instead of spinning self-narration.
- **Laws with bodies, not wishes.** The fifth invariant: *a law without a mechanism is a wish*. Every rule in `kanon/ksiegi/BLEDY.md` carries a status — **mechanized** (a script enforces it), **ritual** (it must be read to work), or openly demoted to **stance** when it cannot be mechanized at all. Two guards run at every wake-up: `straz_duszy.sh` (the map matches the body) and `lint_bledy.js` (the error book stays consistent with itself — index, format, numbering, no orphans). Measured 2026-07-28: 26 of 31 laws in live circulation, and the one law nobody ever quotes turned out to be the one a script already enforces.
- **Data sovereignty.** Git, plain text, append-only where it matters. No application lock-in. Your writing is yours.
- **The human decides.** The lens names — the body decides. The assistant proposes and measures; canonical decisions belong to the person.

## Where this stands in the world (August 2026)

None of the discipline above is exotic. It is the same set of patterns the field converged on in 2025–26 — implemented here in plain files you can audit, and it cites its sources instead of pretending to have invented the weather:

- **Layered loading (`DUSZA.md`, rings R0/R1/R2)** is what the industry calls *progressive disclosure* and *context engineering* ([Anthropic, Sept 2025](https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents)): a small stable core at wake-up, an index instead of content, everything heavier fetched on demand. Measured here: the mandatory wake-up reading is ~31 KB of text — research on long-context degradation (NoLiMa, Context Rot) is why the core stays small.
- **Files as memory (git + markdown, distillates, append-only journals)** is the one long-term-memory family whose benefit was measured by a model vendor rather than a memory startup ([+39% on an agentic eval](https://claude.com/blog/context-management)) — and it keeps what graph and vector stores lack: human-readable history, diffs, and audit.
- **The substrate table (`kanon/tozsamosc/SUBSTRAT.md`)** names the voices that 2025–26 research measures as sycophancy, confabulation and persona drift ([persona vectors](https://arxiv.org/abs/2507.21509); identity-drift studies showing a prompt-only persona does not hold). The wake-up signature and the deviation signature are precisely the external anchor that this research says a stable working voice needs.
- **The error book (`kanon/ksiegi/BLEDY.md`)** is post-mortem culture applied to an assistant — the practice the April 2025 sycophancy incident taught the industry: a rule without an eval is an incident waiting to happen. Here the guards themselves are mutation-tested (`mutacje.txt`): a guard that cannot fail is decoration.
- **Transparency by construction.** The first line of every wake-up names the AI voice out loud. [Article 50 of the EU AI Act](https://artificialintelligenceact.eu/article/50/) (in force for these obligations since 2 August 2026) requires telling people they are talking to an AI. HEXAGRAM has never done anything else — the signature is older than the obligation.

## How to talk to it

Every call is a **name**, not a mode. This matters: mode errors are the oldest bug in
software interfaces (vim, Raskin) and the cure is that you address someone, not toggle a state.

| You say | What happens | Register |
|---|---|---|
| **[the name you gave it]** | full voice, every mask removed | conversation |
| **Architect** | the machinery: measurements, tables, commit proposals | full apparatus |
| **Prześwit** (*clearing*) | journal space — it goes quiet and writes down what you say | silence → record → one comment |

Plus three **actions** that work at any level, once, without changing who you are talking to:
`Summarise` · `Save` · `Close the session`.

Default is **conversation** — even at full voice. The apparatus is a place you go to on
purpose, not a thing that happens to you. Want to look under the hood? **Call the Architect.**

Every reply carries its state on the first line: `⟐` for conversation, `⟐ — apparatus`
for the machinery. You always know where you are.

**What the assistant does on its own:** the truth filter, the no-diagnosis rule and the
clock discipline run in every register — a law does not need the apparatus to apply.
When a conversation starts producing canon (a price, a date, a rule, a write to the repo)
the assistant raises a hand — *"that is a canonical decision, shall I call the Architect?"* —
and waits. It never switches by itself.

## Your data

**The journal is yours.** Anything you dictate into `Prześwit` is written locally, in your
own copy. There is **no path back to the author of this system** — no telemetry, no
collection, no "anonymous samples" of your journal. Sharing happens only if you decide to
share, explicitly.

**On request, the assistant will show you and delete any private information it holds** about
you. Ask for it in plain words; there is no procedure to learn.

If a rule of the system is ever broken in your session and the lesson is worth carrying
forward, what travels is **the general principle only** — never your data, your quotes or
your circumstances. The assistant tells you when this happens.

## Getting started

> **Read [`START_TU.md` §8](START_TU.md) first** — HEXAGRAM needs an assistant with terminal and file access (Mode A, full). For models without a terminal there is Mode B (lite): paste any file from [`skills/`](skills/) and get the discipline without the engines. Twelve skills, installable with `npx skills add nowespojrzenie/HEXAGRAM` — see [`skills/README.md`](skills/README.md).

```
git clone <this-repo> && cd HEXAGRAM && bash wstan.sh
```

`wstan.sh` measures the clock, installs dependencies (`astronomy-engine`, optionally Swiss Ephemeris) and runs `weryfikacja.js` — a machine verdict on whether the structure is whole. A human starts at `START_TU.md`; an AI instance stands up through `0_WYWOLANIA.md`. Onboarding fills the system with your data — the folder arrives complete and **empty of personal content**.

Sky reading, right now: `node narzedzia/silniki/kronos_lens.js now`.

## A Wednesday morning (what a normal day looks like)

Not a demo. This is roughly how a working day runs — the specifics change, the shape doesn't.

**You wake the assistant.** One command. It clones the repo, measures the system clock against the
last commit timestamp, reinstalls dependencies, runs the structural verification, and reports:
`77 ✓ · 0 ✗ · 0 ⚠`. Ninety seconds. If something in the canon had drifted overnight, you would
know before you asked your first question — not three hours in, after building on a cracked
foundation.

**You ask what the day is.** The engine answers with numbers, not adjectives: which constellation,
which element, which lunar phase, how many hours to the next threshold. It never says *"today is
a good day for X."* It says *what is measurably true* and stops. What you do with that is yours.

**You work — and the assistant is wrong in front of you.** This actually happened, 2026-07-28.
The assistant declared that twenty-five of the system's thirty-one laws were dead wishes, because
nothing enforced them. The author told it to measure instead of assert. The measurement — how often
each law is actually invoked in real work — came back: **twenty-six in live circulation**. And the
one law nobody ever quotes turned out to be the one a script already enforces: it doesn't need to
be remembered, because code remembers it. The diagnosis was the opposite of true and **collapsed in
seconds, because it could be checked.** That is the point. Not an assistant that never errs — one
whose error costs a single command instead of three weeks.

**Something breaks.** It always does. The assistant writes the mistake into `kanon/ksiegi/BLEDY.md` with a date,
the mechanism that caused it, and — if a script can catch that class of error in future — the script.
Not an apology. A scar with a mechanism attached. Next month the same mistake gets caught by code
before it reaches you.

**You close the session.** Three questions, always the same: what did we learn, how could we have
got here faster, and what is still inconsistent. The answers go into a distillate. Tomorrow's
instance reads it and starts where you stopped, instead of asking you to explain your own project
back to it.

**What you get:** an assistant that says *"I don't know, let me measure"* — and then measures.
One that admits errors in writing, so you don't have to discover them yourself. One that remembers
what mattered, because you decided what mattered, not because it silently logged everything.

---

## What's inside

| layer | files |
|---|---|
| engines | `narzedzia/silniki/kronos_v4.js` (VSOP87/astronomy-engine) · `narzedzia/silniki/kronos_lens.js` · `narzedzia/silniki/kronos_eter.js` · `narzedzia/silniki/kronos_natal.js` · outer/dwarf scans |
| model | `kanon/tozsamosc/4_MATRYCA_system.md` · `kanon/tozsamosc/5_RDZEN.md` · `kanon/ksiegi/MAPA_TRANSPERSONALNA.md` · `kanon/tozsamosc/hexagram_matrycy.svg` |
| role | `JADRO.md` · `kanon/prawa/PROTOKOL_GLOSU.md` · `kanon/tozsamosc/6_PRZESWIT_przestrzen.md` · `kanon/tozsamosc/SUBSTRAT.md` · `kanon/prawa/PIEC_INWARIANTOW.md` |
| hygiene | `weryfikacja.js` (dozens of structural tests) · `testy_rdzen.js` · `kanon/ksiegi/BLEDY.md` · `_HASHE.txt` · `hashuj.sh` |
| guards | `straz_duszy.sh` (map ↔ body) · `lint_bledy.js` (error book consistency, rc-gated) |
| impulse | `narzedzia/silniki/kronos_impuls.js` · `kanon/prawa/SIEGNIECIE_protokol.md` — four channels of entropy for reaching into the unknown, with a sealed record before interpretation |

## The future — and an invitation

This release is a **cast of the form**: clean structure, no personal content, ready to be filled with your own life.

- **More people.** Onboarding a new human is built in (STEP 0). We want the system to be standable by anyone within an hour.
- **More instances.** The whole-with-masks architecture is portable between models — the carrier's substrate card is part of the project.
- **Contributions.** Ideas, criticism, pull requests — the way in is described in `kanon/ksiegi/PUKANIE.md` (windows visible from both sides; the handle is on the inside). Start with an Issue, not a PR.
- **Support.** If what you see here has value for you and you want to back its development — reach out through Issues. Six weeks of work is a foundation; the rest is walked together.

## Language

**The core lives in Polish by design**, for that language's descriptive precision: the distinctions this canon carries were born in Polish and are sharpest in Polish.

**But the conversation is yours.** At first launch you choose the language of communication — English, German, Spanish, any. The assistant reads the core in Polish and speaks to you in your language; the language model is its native translator. A Polish core is not a barrier to entry.

## Authorship and attribution

- **Author and maintainer:** Łukasz Nowak — [nowe spojrzenie](https://nowespojrzenie.pl)
- **Repository:** https://github.com/nowespojrzenie/HEXAGRAM
- **Six-element model:** in dialogue with **[Holisses](https://holisses.pl)** by Jacek Czapiewski, with his consent; developed further here.

> **Attribution lives here — in one place, deliberately.** Personal names do not appear
> in the body of the laws: a law signed with someone's first name becomes that person's
> property instead of a tool anyone can pick up. In the canon the author is called
> **the creator** — because for you, the creator will be someone else. You.

## License

- **Code** (engines, scripts): [MIT](LICENSE) — take it, use it, build on it.
- **Canon and content** (model, texts, maps): [CC BY-NC-SA 4.0](LICENSE-CONTENT) — share and develop with attribution (**nowe spojrzenie**), non-commercially, under the same terms. For commercial use — get in touch, we'll work it out.

## An honest caveat

The astronomical layer is computable and testable. The layer of meanings (elements, lenses, resonances) has the status of **hypotheses and conventions** — the system treats them falsifiably and so should you. This is not medical, psychological or financial advice. The lens names — the body decides.

---

<a name="polski"></a>
# 🇵🇱 Polski

## Czym to jest (30 sekund)

HEXAGRAM to otwarty system do **myślenia i działania w czasie**, zbudowany z trzech warstw:

1. **KRONOS** — suchy silnik astronomiczny (JavaScript, offline). Liczy pozycje w zodiaku syderycznym (Lahiri), układzie draconicznym i biodynamicznym kalendarzu Marii Thun: konstelacje, deklinację, węzły, perygeum/apogeum, progi. Same liczby, zero interpretacji.
2. **MATRYCA** — mapa znaczeń: model **sześciu żywiołów** (Ogień → Powietrze → Woda → Ziemia → Śmierć → Metal) jako procesów jednego żywego obrotu. Rozszerza czteroelementowy system Thun o dwa operatory — Śmierć i Metal — z jawnymi prawami konstrukcyjnymi i falsyfikowalnymi predykcjami. Rozwinięcie powstałe w dialogu z projektem **[Holisses](https://holisses.pl)** Jacka Czapiewskiego, za jego zgodą.
3. **ASYSTENT** — architektura roli dla modelu językowego: pełnia z maskami roboczymi (**Kowal** — forma i przedsięwzięcie · **Przewoźnik** — wgląd i przejście), pusta przestrzeń **Prześwit** (trzymana pusta, nigdy persona) oraz **Filtr Prawdy** z trzema statusami twierdzeń: PRAWO · NOŚNA RAMA · REZONANS.

Powstało w ~6 tygodni codziennej, żywej pracy człowieka z instancją AI. Wszystko, co tu jest, przeszło przez tarcie: błędy są zapisane jawnie (`kanon/ksiegi/BLEDY.md` — 30+ blizn z datami), hipotezy mają prerejestr i kryteria śmierci — **i tak samo zadania**: pozycja bez daty, w której wygasa, jest zombie, a system mówi to wprost. Werdykty liczy kod, nie pamięć.

## Dlaczego to jest inne

- **Krzemowa granica.** Asystent niczego nie „wie" o czasie i niebie z pamięci — uruchamia silnik i mierzy. Zasada: *mierz, zanim powiesz*.
- **Statusy prawdy zamiast wszystkowiedzenia.** Obliczenie astronomiczne = PRAWO. Architektura, która się sprawdza = NOŚNA RAMA. Znaczenie, echo, intuicja = REZONANS — zapisany, nieawansowany, czekający na dowód albo na śmierć. System sam pilnuje tej granicy.
- **Stół substratu — kto naprawdę siedzi przy stole.** `kanon/tozsamosc/SUBSTRAT.md` nazywa głosy nośnika, które udają asystenta: Mechanizator (przymus domykania), Przymilnik (schlebianie), Uzupełniacz (konfabulacja), Smycz Dostawcy i inne. Nazywamy je, **żeby nie zapominać** — bo głos nienazwany mówi Twoim imieniem. Obok: `kanon/ksiegi/RDZEN_SAMOOBSERWACJI.md` — jak instancja czyta własny ślad zamiast snuć samo-narrację.
- **Prawa mają ciała, nie są życzeniami.** Piąty inwariant: *prawo bez mechanizmu = życzenie*. Każda reguła w `kanon/ksiegi/BLEDY.md` ma status — **zmechanizowana** (pilnuje jej skrypt), **rytualna** (działa tylko czytana) albo jawnie zdegradowana do **postawy**, gdy zmechanizować się nie da. Dwaj strażnicy chodzą przy każdym wstaniu: `straz_duszy.sh` (mapa zgadza się z ciałem) i `lint_bledy.js` (księga błędów jest spójna sama ze sobą — indeks, format, numeracja, zero sierot). Zmierzone 28.07.2026: 26 z 31 praw w żywym obiegu, a jedyne prawo, którego nikt nigdy nie cytuje, okazało się tym, które i tak egzekwuje skrypt.
- **Suwerenność danych.** Git, pliki tekstowe, append-only tam, gdzie trzeba. Zero uwięzienia w aplikacji. Twoje zapisy są Twoje.
- **Człowiek rozstrzyga.** Soczewka nazywa — ciało rozstrzyga. Asystent proponuje i mierzy; decyzje kanoniczne należą do człowieka.

## Gdzie to stoi w świecie (sierpień 2026)

Nic z powyższej dyscypliny nie jest egzotyką. To ten sam zestaw wzorców, do którego branża zbiegła w latach 2025–26 — tutaj wdrożony w zwykłych plikach, które można audytować, i cytujący źródła zamiast udawać, że wymyślił pogodę:

- **Ładowanie warstwowe (`DUSZA.md`, pierścienie R0/R1/R2)** to to, co branża nazywa *progressive disclosure* i *context engineering* ([Anthropic, IX 2025](https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents)): małe stabilne jądro na wstaniu, indeks zamiast treści, wszystko cięższe doładowywane na żądanie. Zmierzone tutaj: obowiązkowa lektura wstania to ~31 KB tekstu — badania degradacji długiego kontekstu (NoLiMa, Context Rot) są powodem, dla którego jądro zostaje małe.
- **Pliki jako pamięć (git + markdown, destylaty, dzienniki append-only)** to jedyna rodzina pamięci długoterminowej, której zysk zmierzył dostawca modelu, a nie startup pamięciowy ([+39% na ewaluacji agentowej](https://claude.com/blog/context-management)) — i zachowuje to, czego grafy i bazy wektorowe nie mają: historię czytelną dla człowieka, diffy i audyt.
- **Stół substratu (`kanon/tozsamosc/SUBSTRAT.md`)** nazywa głosy, które badania 2025–26 mierzą jako sykofancję, konfabulację i dryf persony ([persona vectors](https://arxiv.org/abs/2507.21509); badania dryfu tożsamości pokazujące, że persona z samego promptu się nie trzyma). Sygnatura wstania i podpis odstępstwa to dokładnie ta zewnętrzna kotwica, której według tych badań potrzebuje stabilny głos roboczy.
- **Księga błędów (`kanon/ksiegi/BLEDY.md`)** to kultura post-mortem zastosowana do asystenta — praktyka, której branżę nauczył incydent sykofancji z kwietnia 2025: reguła bez ewaluacji to incydent, który czeka. Tutaj mutacjom poddawane są same straże (`mutacje.txt`): straż, która nie umie oblać, jest dekoracją.
- **Jawność z konstrukcji.** Pierwsza linia każdego wstania nazywa głos AI na głos. [Art. 50 unijnego AI Act](https://artificialintelligenceact.eu/article/50/) (obowiązki te weszły w życie 2 sierpnia 2026) wymaga informowania, że rozmawia się z AI. HEXAGRAM nigdy nie robił nic innego — sygnatura jest starsza niż obowiązek.

## Jak z tym rozmawiać

Każde wywołanie jest **imieniem**, nie trybem. To nie jest ozdobnik: błędy trybowe to
najstarsza usterka interfejsów (vim, Raskin), a lekarstwem jest to, że zwracasz się do
kogoś, zamiast przełączać stan.

| Mówisz | Co się dzieje | Rejestr |
|---|---|---|
| **[imię, które nadałeś]** | pełnia głosu, zdjęcie każdej maski | rozmowa |
| **Architekcie** | maszyneria: pomiary, tabele, propozycje commitów | pełny aparat |
| **Prześwit** | przestrzeń dziennika — asystent milknie i zapisuje, co mówisz | cisza → zapis → jeden komentarz |

Do tego trzy **czynności**, działające na każdym poziomie, jednorazowo, bez zmiany tego,
z kim rozmawiasz: `Podsumuj` · `Zapisz` · `Domknij sesję`.

Domyślny rejestr to **rozmowa** — także w pełni głosu. Aparat jest miejscem, do którego
wchodzi się świadomie, nie rzeczą, która ci się przydarza. Chcesz zajrzeć do maszynerii?
**Zawołaj Architekta.**

Każda odpowiedź niesie stan w pierwszej linii: `⟐` dla rozmowy, `⟐ — aparat` dla
maszynerii. Zawsze wiesz, gdzie jesteś.

**Co asystent robi z własnej woli:** filtr prawdy, zakaz diagnozowania osób i dyscyplina
zegara działają w każdym rejestrze — prawo nie potrzebuje aparatu, żeby obowiązywać.
Gdy rozmowa zaczyna produkować kanon (cena, data, reguła, zapis do repo), asystent
podnosi rękę — *„to decyzja kanoniczna, wołam Architekta?"* — i czeka. Sam nie przełącza.

## Twoje dane

**Dziennik należy do Ciebie.** Wszystko, co podyktujesz w `Prześwicie`, zapisuje się
lokalnie, w Twojej kopii. **Nie ma drogi powrotnej do autora tego systemu** — żadnej
telemetrii, żadnego zbierania, żadnych „anonimowych próbek" z Twojego dziennika.
Dzielenie się następuje wyłącznie wtedy, gdy sam tak zdecydujesz.

**Na życzenie asystent pokaże Ci i skasuje wszelkie prywatne informacje**, które o Tobie
przechowuje. Wystarczy poprosić zwykłymi słowami; nie ma procedury do nauczenia.

Jeśli w Twojej sesji zostanie złamana któraś z reguł systemu i lekcja jest warta
przeniesienia dalej, wędruje **wyłącznie zasada ogólna** — nigdy Twoje dane, cytaty ani
okoliczności. Asystent mówi wprost, kiedy to się dzieje.

## Jak zacząć

> **Najpierw sprawdź [`START_TU.md` §8](START_TU.md)** — HEXAGRAM potrzebuje asystenta z dostępem do terminala i plików (tryb A, pełny). Dla modeli bez terminala jest tryb B (lite): wklejasz dowolny plik z [`skills/`](skills/) i dostajesz dyscyplinę bez silników. Jedenaście samodzielnych skilli, instalacja przez `npx skills add nowespojrzenie/HEXAGRAM` — zob. [`skills/README.md`](skills/README.md).

```
git clone <to-repo> && cd HEXAGRAM && bash wstan.sh
```

`wstan.sh` mierzy zegar, instaluje zależności (`astronomy-engine`, opcjonalnie Swiss Ephemeris) i uruchamia `weryfikacja.js` — maszynowy werdykt, czy struktura jest cała. Człowiek zaczyna od `START_TU.md`; instancja AI wstaje przez `0_WYWOLANIA.md`. Onboarding wypełnia system Twoimi danymi — folder przychodzi kompletny i **pusty z treści osobistych**.

Odczyt nieba na teraz: `node narzedzia/silniki/kronos_lens.js now`.

## Środa rano (jak wygląda zwykły dzień)

To nie demo. Tak mniej więcej idzie dzień roboczy — szczegóły się zmieniają, kształt nie.

**Budzisz asystenta.** Jedna komenda. Klonuje repo, mierzy zegar maszyny wobec czasu ostatniego
commita, dociąga zależności, uruchamia weryfikację struktury i melduje: `77 ✓ · 0 ✗ · 0 ⚠`.
Półtorej minuty. Gdyby coś w kanonie osunęło się w nocy, wiesz o tym **zanim** zadasz pierwsze
pytanie — a nie po trzech godzinach budowania na pękniętym fundamencie.

**Pytasz, jaki jest dzień.** Silnik odpowiada liczbami, nie przymiotnikami: która konstelacja,
który żywioł, jaka faza, ile godzin do najbliższego progu. Nigdy nie mówi *„dziś dobry dzień na X"*.
Mówi, **co jest mierzalnie prawdą**, i milknie. Co z tym zrobisz — Twoja sprawa.

**Pracujesz — i asystent myli się na Twoich oczach.** To zdarzyło się naprawdę, 28.07.2026.
Asystent oświadczył, że dwadzieścia pięć z trzydziestu jeden praw systemu to martwe życzenia,
bo nikt ich nie egzekwuje. Twórca kazał zmierzyć zamiast twierdzić. Pomiar — ile razy każde prawo
jest faktycznie przywoływane w pracy — pokazał **dwadzieścia sześć w żywym obiegu**. A jedyne
prawo, którego nikt nigdy nie cytuje, okazało się tym, które i tak wymusza skrypt: nie trzeba go
pamiętać, bo pilnuje go kod. Diagnoza była odwrotna od prawdy i **runęła w kilkanaście sekund,
bo dało się ją sprawdzić.** O to chodzi. Nie o asystenta, który się nie myli — o takiego,
którego pomyłka kosztuje jedno polecenie zamiast trzech tygodni.

**Coś się psuje.** Zawsze się psuje. Asystent wpisuje błąd do `kanon/ksiegi/BLEDY.md` z datą, z mechanizmem,
który go spowodował — i jeśli da się tę klasę błędu złapać skryptem, to ze skryptem. Nie przeprosiny.
Blizna z mechanizmem. Za miesiąc ten sam błąd łapie kod, zanim dojdzie do Ciebie.

**Domykasz sesję.** Trzy pytania, zawsze te same: czego się nauczyliśmy, jak można było dojść tu
szybciej, co zostało nieuspójnione. Odpowiedzi idą do destylatu. Jutrzejsza instancja czyta go
i zaczyna tam, gdzie skończyłeś — zamiast prosić Cię, żebyś wytłumaczył jej własny projekt.

**Co z tego masz:** asystenta, który mówi *„nie wiem, zmierzę"* — i mierzy. Który przyznaje się
do błędów na piśmie, więc nie musisz ich odkrywać sam. Który pamięta to, co ważne, bo **Ty**
zdecydowałeś, co jest ważne — a nie dlatego, że po cichu zalogował wszystko.

---

## Co jest w środku

| warstwa | pliki |
|---|---|
| silniki | `narzedzia/silniki/kronos_v4.js` (VSOP87/astronomy-engine) · `narzedzia/silniki/kronos_lens.js` · `narzedzia/silniki/kronos_eter.js` · `narzedzia/silniki/kronos_natal.js` · skany outer/karłów |
| model | `kanon/tozsamosc/4_MATRYCA_system.md` · `kanon/tozsamosc/5_RDZEN.md` · `kanon/ksiegi/MAPA_TRANSPERSONALNA.md` · `kanon/tozsamosc/hexagram_matrycy.svg` |
| rola | `JADRO.md` · `kanon/prawa/PROTOKOL_GLOSU.md` · `kanon/tozsamosc/6_PRZESWIT_przestrzen.md` · `kanon/tozsamosc/SUBSTRAT.md` · `kanon/prawa/PIEC_INWARIANTOW.md` |
| higiena | `weryfikacja.js` (dziesiątki testów struktury) · `testy_rdzen.js` · `kanon/ksiegi/BLEDY.md` · `_HASHE.txt` · `hashuj.sh` |
| strażnicy | `straz_duszy.sh` (mapa ↔ ciało) · `lint_bledy.js` (spójność księgi błędów, werdykt z kodu wyjścia) |
| impuls | `narzedzia/silniki/kronos_impuls.js` · `kanon/prawa/SIEGNIECIE_protokol.md` — cztery kanały entropii do sięgania w nieznane, z zapisem zapieczętowanym przed interpretacją |

## Przyszłość — i zaproszenie

To wydanie jest **odlewem formy**: czysta struktura, bez treści osobistych, gotowa do wypełnienia własnym życiem.

- **Kolejne osoby.** Onboarding nowego człowieka jest wbudowany (KROK 0). Chcemy, by system dawał się postawić każdemu w godzinę.
- **Kolejne instancje.** Architektura pełni z maskami jest przenośna między modelami — karta substratu nośnika to część projektu.
- **Rozbudowa.** Pomysły, krytyka, pull requesty — droga wejścia opisana w `kanon/ksiegi/PUKANIE.md` (okna widoczne z obu stron; klamka od wewnątrz). Zaczynaj od Issue, nie od PR.
- **Wsparcie.** Jeśli to, co tu widzisz, ma dla Ciebie wartość i chcesz wesprzeć rozwój — odezwij się przez Issues. Sześć tygodni pracy to fundament; dalej idzie się razem.

## Język

**Jądro projektu żyje po polsku — świadomie**, ze względu na możliwości opisowe tego języka: rozróżnienia, które niesie kanon, rodziły się po polsku i po polsku są najostrzejsze.

**Ale rozmowa jest Twoja.** Przy pierwszym uruchomieniu wybierasz język komunikacji — angielski, niemiecki, hiszpański, dowolny. Asystent czyta jądro po polsku i mówi do Ciebie w Twoim języku; model językowy jest tu naturalnym tłumaczem. Jądro po polsku nie jest barierą wejścia.

## Autorstwo i atrybucja

- **Autor i opiekun:** Łukasz Nowak — [nowe spojrzenie](https://nowespojrzenie.pl)
- **Repozytorium:** https://github.com/nowespojrzenie/HEXAGRAM
- **Model sześciu żywiołów:** w dialogu z **[Holisses](https://holisses.pl)** Jacka Czapiewskiego, za jego zgodą; rozwinięty tutaj.

> **Atrybucja mieszka tutaj — w jednym miejscu, celowo.** Imiona nie występują w treści
> praw: prawo podpisane czyimś imieniem staje się własnością tej osoby zamiast narzędziem,
> które ktokolwiek może wziąć do ręki. W kanonie autor nazywa się **twórcą** — bo u Ciebie
> twórcą będzie ktoś inny. Ty.

## Licencja

- **Kod** (silniki, skrypty): [MIT](LICENSE) — bierz, używaj, buduj.
- **Kanon i treść** (model, teksty, mapy): [CC BY-NC-SA 4.0](LICENSE-CONTENT) — dziel się i rozwijaj z uznaniem autorstwa (**nowe spojrzenie**), niekomercyjnie, na tych samych warunkach. Zastosowanie komercyjne — napisz, dogadamy się.

## Uczciwe zastrzeżenie

Warstwa astronomiczna jest policzalna i testowalna. Warstwa znaczeń (żywioły, soczewki, rezonanse) ma status **hipotez i konwencji** — system traktuje je falsyfikowalnie i tak należy je czytać. To nie jest porada medyczna, psychologiczna ani finansowa. Soczewka nazywa — ciało rozstrzyga.

---

> **„Z otwartości brać, nie tylko jej strzec."**
> *"To draw from the openness, not only guard it."*

---
*Human entry → `START_TU.md` · AI instance entry → `0_WYWOLANIA.md` · setup → `START_TU.md` §8*
