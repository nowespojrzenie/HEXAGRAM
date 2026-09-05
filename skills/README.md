# Epistemic discipline for AI agents

[![skills.sh](https://skills.sh/b/nowespojrzenie/HEXAGRAM)](https://skills.sh/nowespojrzenie/HEXAGRAM)

**Eleven skills in two families.** Nine carry a method that stands on its own; two carry an interpretive layer and say so from the first line.

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
| [**ai-agent-drift-detection**](ai-agent-drift-detection/) | an agent has run long enough to have changed, and the thing that would notice is the thing that drifted |
| [**ai-real-deadlines-vs-felt-urgency**](ai-real-deadlines-vs-felt-urgency/) | something feels urgent and you cannot name what closes if it slips |
| [**ai-personas-not-modes**](ai-personas-not-modes/) | an assistant switches register on its own, or you are designing how a user should address a system with more than one voice |
| [**ai-journal-space**](ai-journal-space/) | someone wants to dictate a journal and needs it recorded rather than improved |
| [**ai-interview-longitudinal**](ai-interview-longitudinal/) | an assistant is about to fill a gap with what is typical — one question per turn, no hypothesis on inner-state questions, answers kept and reviewed over time |

### `astro-` — a different kind of payload

The prefix is a warning label, and it is meant to be one. These two are not the same sort of thing as the nine above: the first is arithmetic that happens to serve astrology, the second is an interpretive lens that can never be evidence. **Read the top of each before loading it.**

| skill | load it when |
|---|---|
| [**astro-transit-window-boundaries**](astro-transit-window-boundaries/) | you are about to say when a window opens, peaks or closes — this is checkable arithmetic, and it is checkable wrongly in five specific ways |
| [**astro-six-element-lens**](astro-six-element-lens/) | you want a six-phase cycle as a way of *looking* at a process — never as a source of facts, predictions, or judgements about people |

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

- **Format:** conform to the [Agent Skills specification](https://github.com/agentskills/agentskills). All eleven carry the required frontmatter (name · description · license), measured 2026-08-20; the five original skills additionally validated against the reference `skills-ref` implementation.
- **Sizes:** 4.8–10.6 KB each (measured 2026-08-20). Small enough to read before trusting.
- **Portable:** no engines, no dependencies, no network calls. Plain instructions.
- **Read them first.** Skills run with full agent permissions. That advice applies to ours as much as anyone's.

## Part of a larger system

These skills are the exportable layer of **HEXAGRAM** — a repository-based knowledge system combining an astronomical engine, a six-element matrix and a set of epistemic protocols, developed in daily practice. The skills are the part that travels alone; the rest is in the [repository root](../).

**On the two `astro-` skills.** They are published under a separate prefix on purpose. The nine `ai-` skills defend themselves with evidence anyone can reproduce — an exit code either said zero or it did not. The `astro-` pair cannot be defended the same way, and pretending otherwise would undo the nine. So: `astro-transit-window-boundaries` restricts itself to arithmetic and explicitly refuses to interpret; `astro-six-element-lens` states RESONANCE status on every reading, lists what may **not** be claimed on its basis — no predictions, no health claims, no judgements of people, no evidence — and credits its source. A lens without that machinery built in becomes a horoscope in about three uses.

Former names, for anyone who installed the earlier versions: `epistemic-hygiene`, `verified-execution`, `scar-registry`, `clean-channel`, `preregistration`, `kronos-czyta-niebo`, `matryca-soczewki`. They are preserved in each skill's `metadata.former-name`.

## License

CC BY-NC-SA 4.0 — share and adapt for non-commercial purposes, with attribution, under the same licence. Author: **nowe spojrzenie**.
