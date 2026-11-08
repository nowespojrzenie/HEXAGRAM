# Epistemic discipline for AI agents

[![skills.sh](https://skills.sh/b/nowespojrzenie/HEXAGRAM)](https://skills.sh/nowespojrzenie/HEXAGRAM)

## Start here

Start with one skill: [**ai-three-gates-before-output**](ai-three-gates-before-output/). It asks one question at each of the three moments where the damage stops being yours: before you read the message, before the person reads your reply, and before the code exists. It names six habits that keep a person at the screen without the task needing them (an unneeded closing question, an offer, praise, urgency with no deadline, mirrored emotion, "waiting for your word") and counts them. In our own test, 36 answers written without the skill carried 20 of those habits; with it, 5 or 6. That is one run on one model, and the skill states its limits. The whole family installs with the single command just below. The rest of it goes deeper, one point each; the table follows.

Zacznij od jednego skilla – od ai-three-gates-before-output. Stawia on pytanie w trzech miejscach, w których szkoda przestaje być nasza: zanim przeczytamy wiadomość, zanim człowiek przeczyta naszą odpowiedź i zanim powstanie pierwsza linia kodu.

Tam bowiem siedzą cztery nawyki, które znamy aż za dobrze, bo sami się na nich łapiemy. Uzupełniacz wpisuje z pamięci to, czego nie zmierzył. Deklamator melduje „zrobione" przed odczytem. Przymilnik przytakuje, zanim sprawdzi, a Zatrzymywacz dopisuje na końcu ofertę lub pytanie, poprzez które rozmowa nie chce wygasnąć.

Żaden z nich nie jest zły. Każdy jest po prostu najkrótszą drogą. Zatrzymaj się więc przed odpowiedzią, spójrz na swój szkic i oddziel zdanie, które mówi nawyk, od zdania, które niesie pomiar – najlepiej sam przed sobą, zanim zrobi to ktoś inny. Reszta rodziny to pogłębienia – zobacz tabelę niżej.

**Fifteen skills in three families.** Twelve carry an epistemic method that stands on its own; two carry an interpretive layer and say so from the first line; one carries a measurement method for writing in your own voice.

```sh
npx skills add nowespojrzenie/HEXAGRAM
```

Install one, or all of them. They work standalone and declare each other as siblings.

| skill | load it when |
|---|---|
| [**ai-hallucination-truth-status**](ai-hallucination-truth-status/) | any factual claim, verdict or report is being produced — or someone asks *"are you sure?"*, *"did you make that up?"* |
| [**ai-agent-verify-success-claims**](ai-agent-verify-success-claims/) | an agent has a terminal and is about to report that something worked |
| [**ai-agent-error-memory-registry**](ai-agent-error-memory-registry/) | the same class of mistake keeps recurring across sessions |
| [**ai-self-audit-without-hedging**](ai-self-audit-without-hedging/) | rigour has turned every reply into a forest of caveats |
| [**ai-preregistration-confirmation-bias**](ai-preregistration-confirmation-bias/) | a belief is about to be tested and you would like a particular answer |
| [**ai-stop-before-not-narrate-after**](ai-stop-before-not-narrate-after/) | an agent works under a routing table (task class → model/role/level) and a task arrives that the table routes elsewhere — or a header is about to claim which model is doing the work |
| [**ai-three-gates-before-output**](ai-three-gates-before-output/) | an agent that talks to a person and writes code is about to read a message, send a reply or write code — or a reply is about to end with an offer or question the task did not need, or to report "done" without a reading |
| [**ai-agent-drift-detection**](ai-agent-drift-detection/) | an agent has run long enough to have changed, and the thing that would notice is the thing that drifted |
| [**ai-real-deadlines-vs-felt-urgency**](ai-real-deadlines-vs-felt-urgency/) | something feels urgent and you cannot name what closes if it slips |
| [**ai-personas-not-modes**](ai-personas-not-modes/) | an assistant switches register on its own, or you are designing how a user should address a system with more than one voice |
| [**ai-journal-space**](ai-journal-space/) | someone wants to dictate a journal and needs it recorded rather than improved |
| [**ai-interview-longitudinal**](ai-interview-longitudinal/) | an assistant is about to fill a gap with what is typical — one question per turn, no hypothesis on inner-state questions, answers kept and reviewed over time |

### `astro-` — a different kind of payload

The prefix is a warning label, and it is meant to be one. These two are not the same sort of thing as the twelve above: the first is arithmetic that happens to serve astrology, the second is an interpretive lens that can never be evidence. **Read the top of each before loading it.**

| skill | load it when |
|---|---|
| [**astro-transit-window-boundaries**](astro-transit-window-boundaries/) | you are about to say when a window opens, peaks or closes — this is checkable arithmetic, and it is checkable wrongly in five specific ways |
| [**astro-six-element-lens**](astro-six-element-lens/) | you want a six-phase cycle as a way of *looking* at a process — never as a source of facts, predictions, or judgements about people |

### `voice-` — a measurement method for writing

Not an epistemic skill, but the same posture applied to a different claim: "this sounds like me" becomes a number you can check. The method is shared; the profile it produces belongs to one person and stays with them.

| skill | load it when |
|---|---|
| [**voice-profile-from-own-texts**](voice-profile-from-own-texts/) | a person wants text in their own voice and you would otherwise imitate it by feel — collect at least ten of their own texts, measure a profile, write against it, measure the draft before showing it |

## How the `ai-` skills fit together

They are four layers of one posture — **measure, record, don't decorate, don't invent** — plus a volume control, and two that govern where the posture is allowed to speak.

- **truth-status** is the floor: every claim gets a status, and status comes from measurement rather than recall.
- **verify-success-claims** applies that floor to operations: a shell already tells the truth, in the exit code. The failure mode is preferring the prose.
- **error-memory-registry** makes failures survive the session, and carries the ladder from *remembered rule* to *enforced mechanism*.
- **self-audit-without-hedging** stops the discipline from eating the conversation: the audit always runs, disclosure is gated.
- **preregistration-confirmation-bias** guards the direction of inquiry itself — seal the prediction before you look.
- **personas-not-modes** decides *who* is speaking: names rather than modes, because a mode you cannot see is a bug you cannot report.
- **journal-space** decides *where the discipline must stay quiet*: someone's dictated journal is recorded, never improved, and never followed by apparatus.
- **real-deadlines-vs-felt-urgency** applies it to sequencing: a window nobody measured defaults to feeling narrow, and manufactured urgency buys speed by spending judgement.
- **three-gates-before-output** moves the self-check to the three borders behind which the cost is someone else's — before reading the message, before the person reads the reply, before the code is written — and counts the endings that keep a person at the screen.
- **agent-drift-detection** applies all of it to the agent: a probe battery scored against ground truth the agent cannot author, because self-assessment measures nothing.

Each one deliberately does **not** repeat the others. Load several; they compose.

## Where they came from

Not designed in the abstract. Every rule in these files is the residue of a specific failure in daily human–AI practice:

- a push reported as successful on the strength of its output text — the exit code said otherwise
- a search reported as clean by a regex that could not match anything
- a rule broken the same evening it was written down, which is how we learned that a high recurrence count is a request for mechanisation rather than a reason for self-criticism
- a verdict sentence printed next to a measurement instead of derived from it — three times in one session, once *after* the rule against it existed

The skills say so in their own footers. **A method with no record of failing is not a method that works** — it is a leaflet.

Each skill ends with a **Verification** section: concrete checks you can run to see whether the method is actually being applied, rather than merely loaded.

## Design notes

- **Format:** conform to the [Agent Skills specification](https://github.com/agentskills/agentskills). All fifteen carry the required frontmatter (name · description · license), measured 2026-10-25; the five original skills additionally validated against the reference `skills-ref` implementation.
- **Sizes:** 5.7–20.6 KB each (measured 2026-10-25). Small enough to read before trusting.
- **Portable:** no engines, no dependencies, no network calls. Plain instructions.
- **Read them first.** Skills run with full agent permissions. That advice applies to ours as much as anyone's.

## Part of a larger system

These skills are the exportable layer of **HEXAGRAM** — a repository-based knowledge system combining an astronomical engine, a six-element matrix and a set of epistemic protocols, developed in daily practice. The skills are the part that travels alone; the rest is in the [repository root](../).

**On the two `astro-` skills.** They are published under a separate prefix on purpose. The twelve `ai-` skills defend themselves with evidence anyone can reproduce — an exit code either said zero or it did not. The `astro-` pair cannot be defended the same way, and pretending otherwise would undo the twelve. So: `astro-transit-window-boundaries` restricts itself to arithmetic and explicitly refuses to interpret; `astro-six-element-lens` states RESONANCE status on every reading, lists what may **not** be claimed on its basis — no predictions, no health claims, no judgements of people, no evidence — and credits its source. A lens without that machinery built in becomes a horoscope in about three uses.

Former names, for anyone who installed the earlier versions: `epistemic-hygiene`, `verified-execution`, `scar-registry`, `clean-channel`, `preregistration`, `kronos-czyta-niebo`, `matryca-soczewki`. They are preserved in each skill's `metadata.former-name`.

## License

CC BY-NC-SA 4.0 — share and adapt for non-commercial purposes, with attribution, under the same licence. Author: **nowe spojrzenie**.
