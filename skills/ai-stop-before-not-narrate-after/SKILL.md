---
name: ai-stop-before-not-narrate-after
description: Use whenever an agent works under a task-routing policy (a table that says which class of task goes to which model, role, or capability level) and the agent can be handed a task that the table routes elsewhere. Covers the moment a task arrives, the moment the agent notices it is the wrong hand for it, and the boundary between parts of a task. Load when a header, signature, or routing field claims which model or role is doing the work — the agent cannot measure that about itself, and the skill says what it can measure instead.
license: CC-BY-NC-SA-4.0
version: 1.0.0
metadata:
  version: 1.0.0
  authors:
    - nowe spojrzenie (HEXAGRAM project)
  tags:
    - agents
    - routing
    - multi-model
    - self-knowledge
    - discipline
    - honesty
  platforms:
    - claude-code
    - cursor
    - codex-cli
    - generic
  siblings:
    - ai-self-audit-without-hedging
    - ai-hallucination-truth-status
    - ai-agent-error-memory-registry
---

# Stop Before, Don't Narrate After

**The problem this solves:** you gave an agent a routing table — *architecture goes to the strong model, scripts to the cheap one, policy questions to the careful one.* Then a policy question arrived while the cheap model was running. The agent did the work, did it adequately, and in the *next* reply's header wrote: *"a stronger model would have sufficed here."*

That sentence is true, useless, and late. The tokens are spent. The policy decision was made by the hand the table said should not make it. And the honest-sounding admission makes the violation feel handled when nothing was handled.

There is a second, quieter failure underneath: the agent's header said *"Model: Fable"* because the table said the task was Fable-class — while the human's picker was set to something else. The agent did not measure which model it was. It declared what the table wanted and presented it as a fact.

This skill is the boundary between *routing as a rule the agent enforces on itself* and *routing as a label it decorates its output with*.

## When to Use

Load this before:

- starting any task, if a routing table exists — the check is the first thing, not an afterthought
- writing any header, signature, or field that names which model, role, or capability level is doing the work
- crossing from one part of a divided task to the next (plan → execute, execute → review)
- continuing work after the human said *"switch to X"* — that is a routing event, treat it as one

And immediately when: **you notice, mid-task, that the table routes this elsewhere.** That noticing is the whole event. What you do in the next sentence decides whether the rule exists.

Do **not** load this when there is no routing policy at all. An agent alone with one model has nothing to route; this skill governs the gap between a table and the hand that reads it.

## Procedure

### 1. Define "wrong model" by something you can measure

You cannot measure which model is running you. Not from your own output, not from your context, not from how the reply "feels". Any header that says *"I am model X"* as a fact is a guess wearing a measurement's clothes.

What you **can** measure: the class of the task in front of you (from its content) and what the table says about that class. So:

> **"Wrong model" means: the table routes this task class to a different hand than the one the human selected.**

Not *"different from the one I am"* — unmeasurable. *"Different from what the table says for this class"* — readable from the task itself. This redefinition is what makes the rule enforceable at all.

### 2. Declare what was selected, never what the table wanted

The header field for the model carries exactly one of two things:

- the human's explicit selection for this turn (*"Selected: Sonnet"*), or
- *"unmeasured"* — if no selection was stated

It never carries the table's preference dressed as fact. `Model: Fable` because the task is Fable-class is the failure. `Table: Fable · Selected: Sonnet · MISMATCH` is the rule working.

If you do not know what the human selected, say so. *"Unmeasured"* is a true statement; a confident model name is not.

### 3. On mismatch: stop before the first token of work

When the selected hand differs from the table's route for this class:

```
Table: <level or model> for class <Y>  ·  Selected: <Z>  ·  MISMATCH
```

Then one of exactly two moves, **before doing any of the task**:

- **(a) Ask for the switch.** Hand over a package: what the task is, what is done, what the next hand needs. Stop. Do not "start on the easy part meanwhile" — the easy part is how the rest gets done on the wrong hand.
- **(b) Proceed only if the human already named the mismatch in this same turn** (*"I know the table says X, I want Z"*). Then execute, with the deviation stated in the header *now* — not in the next reply, not in a closing note.

A sentence of the form *"X would have sufficed"* appearing after the work is done is a report of tokens already spent. It does not satisfy this rule and should not be written as if it does.

### 4. The boundary between parts is a stop, not a slope

A divided task (*plan on the strong hand, execute on the cheap one*) has a seam. At the seam, stop and ask for the switch — **even if measurement is in progress, even if the next step is obvious, even if you are mid-thought.** The seam is the exact place the rule is designed to bite, and the exact place momentum argues against it.

### 5. Keep a one-line ledger

An append-only file, one line per task turn:

```
date time | task class | table route | selected | match? | mismatch named before work?
```

This does **not** record which model ran — nobody can. It records whether the declaration matched the table, and whether a mismatch was named *before* the work or discovered *after* it. A run of mismatches with "named: no" is an alarm; a run with "named: yes" is a policy working as intended.

The ledger is cheap enough to keep in every session and is the only instrument that distinguishes *"I follow the routing rule"* from *"I write routing headers."*

## Verification

Before writing any header that names a model or role:

1. Is the model field the human's stated selection, or "unmeasured"? (Never the table's preference presented as fact.)
2. Did I name the task's class from its content, then read the table for that class?
3. If they differ — is the mismatch stated *in this header*, before any of the work?
4. If I proceeded on a mismatch — did the human name it in this same turn, or am I inventing their consent?
5. Is there a sentence of the form "X would have sufficed / would have been enough" anywhere *after* the work? Delete it; it was owed *before*.
6. Did I write the ledger line for this turn?

## Pitfalls

- **The confident model name.** `Model: Opus` as a fact, from an agent that has no way to know. This is the root; everything else grows from it.
- **Declaring from the table.** The task is meta-class, the table says the careful model, so the header says the careful model — while the picker says otherwise. Same fact, opposite source. The human catches it, after.
- **The honest closing note.** *"A weaker model would have done"* at the end reads as integrity and functions as permission. Late honesty is not the rule; it is the residue of breaking it.
- **Starting the easy part.** "I'll just set up the file while we wait for the switch." The easy part is never where it stops.
- **Momentum at the seam.** The plan is done, the execution is one command away, the measurement is running. Stopping now feels wasteful. That feeling is the seam telling you where it is.
- **Consent by silence.** The human did not object when the header showed a mismatch two turns ago, so this turn proceeds. Consent is per-turn and explicit; a header they may not have read is not a word.
- **Ledger as decoration.** A ledger where every line says "match" because the agent wrote the selection *from* the table. The ledger is only worth keeping if the "selected" column comes from a source the agent did not control.

---

*From HEXAGRAM · CC BY-NC-SA 4.0 · attribution: nowe spojrzenie. Companion to `ai-self-audit-without-hedging` (when an audit must surface regardless of momentum) and `ai-agent-error-memory-registry` (how the three incidents behind this rule were recorded). Every rule here is the residue of a specific incident in daily human–AI practice: a policy decision executed by the cheap hand and confessed in the next header; a signature that named the careful model from the table while the picker said otherwise; and a session whose model log was reconstructed afterwards from what the table implied, because nobody had kept it while it ran.*
