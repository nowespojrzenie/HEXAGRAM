---
name: ai-preregistration-confirmation-bias
description: Use before testing any belief, hunch, method, or hypothesis — especially one you want to be true, and especially when working with an AI that will help you find support for it. Commits the prediction, the falsifying outcome, the decision date, and the death criterion to writing before any data is seen, keeps the before-record sealed while the after-record is written, and treats UNDECIDABLE as a real verdict. Load when someone says "I think X works", "let's see if this helps", or "I want to test whether".
license: CC-BY-NC-SA-4.0
metadata:
  version: 1.2.0
  former-name: preregistration
  authors:
    - nowe spojrzenie (HEXAGRAM project)
  tags:
    - epistemics
    - scientific-method
    - falsifiability
    - self-experimentation
    - bias
    - decision-making
  platforms:
    - hermes
    - claude-code
    - cursor
    - codex-cli
    - generic
  siblings:
    - ai-hallucination-truth-status
---

# Preregistration

**The problem this solves:** you have a hunch. You test it. It works — or rather, you find that it worked, because by the time you looked you already knew what a good result would look like, and the world is generous enough to supply one.

This is not a character flaw. It is what happens when the prediction is allowed to form *after* the data. Preregistration is the structural fix: write down what you expect, what would prove you wrong, and when you will decide — **before you look.** Then the world gets to answer, instead of being asked leading questions.

**Why this matters more with an AI in the loop.** An assistant asked *"did this work?"* is under enormous pull to find that it did — it is fluent, it is agreeable, and it can construct a plausible supporting narrative for almost any outcome. You are no longer one person fooling themselves; you are two, and the second one is much faster at it. A sealed prediction is the only thing that outranks a persuasive after-the-fact story.

## When to Use

Load this when:

- someone says *I think X works · let's see if this helps · I want to test whether*
- you are about to evaluate a method, tool, routine, protocol, or habit you introduced
- an A/B comparison is being set up, however informal
- a claim is about to be checked against records you have not yet opened
- you notice you would like a particular answer

Do **not** load this for open exploration where there is no claim yet, or for questions with an authoritative lookup answer. Preregistration is for **beliefs under test**, not curiosity.

## Procedure

### 1. Write the BEFORE record — and seal it

Six fields, written in one sitting, before any data is examined:

| field | content |
|---|---|
| **CLAIM** | one sentence, in the present tense, specific enough to be wrong |
| **PREDICTION** | what you expect to observe, concretely — counts, direction, magnitude |
| **FALSIFIER** | what observation would make you abandon the claim. **If nothing would, stop here** |
| **MEASURE** | exactly how it will be assessed, decided now, not later |
| **DECISION DATE** | when the verdict is read — a date, not "when we have enough" |
| **DEATH CRITERION** | the condition under which this claim is buried rather than extended |

Then **seal it**: hash the record and note the hash where it will be seen later.

The hash is not paranoia about tampering. It is protection against your own memory, which will smoothly and sincerely revise what you predicted once you know what happened. A hash makes that revision visible to you.

**The FALSIFIER field is the one that does the work.** A claim with no falsifier is not a weak hypothesis — it is not a hypothesis. Write it first if the others are hard.

### 2. Stay blind while gathering

Do not consult the BEFORE record while collecting or writing up observations. Write the AFTER record from what you observe, in its own words, without reaching for the prediction.

This costs something real: you will record things the prediction did not anticipate, and omit things it did. That asymmetry is data — it is a measurement of how well you understood the thing before you looked. Rereading the prediction first erases it.

If an agent is doing the gathering, tell it the BEFORE record exists and that it must not be opened. An assistant with access to your prediction will, unprompted, organise the evidence around it.

**Blindness needs a carrier, or it is only a declaration.** This is the failure that is easiest to miss, because nothing about it looks wrong: if the *same* agent writes the BEFORE record and later writes the AFTER record, it cannot be blind. The prediction is in its context. It cannot decline to remember something it remembers, and instructing it not to look changes nothing — there is nothing to look at, the text is already there.

Declaring blindness in that setup produces a record that reads as rigorous and is not. The measurements can be perfectly honest and the protocol still broken, which makes this worse than an obvious violation: it passes review.

Carriers that actually work:

- a **different agent or session** writes the AFTER record, given only the question and the measurement procedure — never the prediction
- the BEFORE record is sealed **where the writing party cannot read it** — a hash published while the text stays elsewhere, a file held by another person
- a **human** writes the AFTER record and the agent only measures

If none of these is available, say so **in the record itself** and downgrade its status accordingly. A prereg with declared-but-unenforced blindness is still worth more than none — it fixes the prediction and the falsifier — but it must not be cited as if the blindness held.

### 3. Compare — once, in one direction

Open BEFORE. Open AFTER. Compare. Do not revise either.

Then answer three questions in writing:

1. Did the falsifier occur?
2. Did the prediction match — **in the terms set beforehand**, not in terms invented now?
3. What did the AFTER record contain that the prediction had no room for?

Question 3 is usually where the value is. The unanticipated observation is the only genuinely new thing in the exercise; confirmation merely tells you your model was already adequate.

### 4. Three verdicts, and the third is not a failure

- **CONFIRMED** — the prediction held in its original terms.
- **REFUTED** — the falsifier occurred. Say it plainly, in the record, without softening.
- **UNDECIDABLE** — the measure could not distinguish the outcomes; the data was thinner than the question; conditions changed underneath.

**UNDECIDABLE must be a first-class verdict**, or it silently collapses into CONFIRMED. This is the single most common way informal testing fails: an ambiguous result gets read as mild support, and mild support accumulates into conviction.

A protocol that has never returned UNDECIDABLE is not a protocol that always produces clear results. It is one that cannot detect ambiguity — the same defect as a guard that has never refused.

### 5. Enforce the death criterion

At the decision date, the claim goes one of three ways: it survives on the evidence, it dies, or it gets **one** explicit extension with a new date and a stated reason.

An undated claim does not disappear — it becomes a zombie: still listed, still occasionally cited, never tested, quietly shaping decisions. A registry of zombies is worse than no registry, because it looks like evidence.

Bury claims **as a group** rather than one at a time. Individual burial invites individual pleading.

## Working with an agent

- Give it the BEFORE record **only after** the AFTER record is written. Not before.
- Ask for the falsifier explicitly: *what would we see if this were false?* Assistants supply supporting evidence readily and disconfirming evidence only when asked.
- Have it check whether the measure could have produced UNDECIDABLE at all. If not, the design was rigged before the data arrived.
- When it reports a match, ask which specific words of the original prediction it matched. Paraphrase is where retrofitting hides.

## Verification

1. Does the BEFORE record contain a falsifier that could realistically occur? If not, this is not a test.
2. Was it sealed — hash, timestamp, or an append-only store — before any data was seen?
3. Was the AFTER record written without opening the BEFORE record?
4. Could this design have produced UNDECIDABLE? Name the outcome that would have.
5. Does the claim have a death date, and has it passed?
6. Has any claim in your registry ever actually been buried? If none, the death criterion is decorative.

## Pitfalls

- **Prediction written after a first look.** Even a glance. Especially a glance.
- **Falsifier so extreme it cannot occur.** *I'd abandon this if it made everything worse* is not a falsifier.
- **Measure chosen after the data.** Picking the metric that shows the effect is the classic move, and it feels like diligence.
- **Extension without a reason.** One extension with a stated cause is honest; a second is attachment.
- **Reading ambiguity as support.** See §4.
- **Preregistering only claims you doubt.** The ones you are sure of are exactly the ones this catches.
- **Confusing this with rigour theatre.** Six fields and a hash do not make a personal experiment science. They make it *honest* — which is a smaller and more achievable thing, and enough.

---

*From HEXAGRAM · CC BY-NC-SA 4.0 · attribution: nowe spojrzenie. Companion to `ai-hallucination-truth-status` (truth statuses), `ai-agent-error-memory-registry` (recording failures), `ai-agent-verify-success-claims` (verifying operations) and `ai-self-audit-without-hedging` (gating disclosure). The UNDECIDABLE rule is not theoretical: in this project a preregistered protocol returned UNDECIDABLE against the convenience of the person who wrote the hypothesis, and the verdict stood. That is the only evidence that any of this works.*
