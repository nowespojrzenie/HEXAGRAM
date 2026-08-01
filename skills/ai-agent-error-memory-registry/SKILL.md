---
name: ai-agent-error-memory-registry
description: Use when an agent or team keeps repeating the same class of mistake, when you want a durable record of failures instead of one-off apologies, or when setting up a project's error memory. Defines an append-only scar registry — symptom, consequence, guard, rule, and the voice that produced it — plus the ladder from remembered rule to enforced mechanism, and the recidivism counter that tells you when a rule is unenforceable rather than merely forgotten.
license: CC-BY-NC-SA-4.0
metadata:
  version: 1.1.0
  former-name: scar-registry
  authors:
    - nowe spojrzenie (HEXAGRAM project)
  tags:
    - error-handling
    - postmortem
    - reliability
    - institutional-memory
    - agents
    - self-audit
  platforms:
    - hermes
    - claude-code
    - cursor
    - codex-cli
    - generic
  siblings:
    - ai-hallucination-truth-status
---

# Scar Registry

**The problem this solves:** an agent apologises, corrects itself, and makes the same mistake nine days later. Not because it is careless — because the correction lived in a conversation that ended. Nothing carried.

A scar registry is error memory that outlives the session. Not a changelog (that records what changed), not a postmortem archive (that records incidents). A registry of **failure modes**, written so the next occurrence is cheaper than the last.

The name matters. A scar is not a wound and not shame — it is tissue that grew back tougher, and it stays visible.

## When to Use

Load this when:

- the same class of error has now happened twice
- you are setting up how a project or agent will remember its own failures
- a postmortem is about to be written and you want it to change behaviour, not just describe the past
- someone says: *you did this before · we already fixed this · why does this keep happening*

Do **not** load this for one-off user-facing errors that need an immediate fix and nothing more. Not every mistake deserves an entry; a registry that records everything gets read by nobody.

## The entry

Five fields. Fewer, and the entry cannot act; more, and it will not be written.

| field | question it answers | failure if skipped |
|---|---|---|
| **SYMPTOM** | what was observably wrong — concrete, quotable | entry becomes a mood |
| **CONSEQUENCE** | what it cost, or would have cost | no one prioritises it |
| **GUARD** | what would have caught this *before* the cost | you get a lesson, not a defence |
| **RULE** | one sentence, imperative, reusable next time | nothing transfers |
| **VOICE** | which internal pull produced it | you fix the instance, not the class |

The **VOICE** field is the one people drop first and the one that does the most work. An error attributed to a named tendency — *the pull to please, the pull to fill a gap, the pull to close* — connects this entry to every other entry from the same source. Errors then cluster into families, and families can be defended against as a group. Without it you hold a list; with it you hold a map. (`ai-hallucination-truth-status` names the first voices; a registry will discover its own.)

Add a **DATE and a MEASUREMENT** to every entry. Not the date you think it is — the one you read off a clock in the same breath as writing. Dates recalled rather than measured drift across midnight boundaries and corrupt every later reconstruction.

## Rules of the registry

### 1. Append-only. Never edit, never delete

A correction goes **next to** the error, not over it. The moment entries can be rewritten, the registry stops being evidence and becomes a story about how you have always been competent. The visible trace is the entire value.

Practical consequence: numbering is permanent. An entry that turns out wrong gets a follow-up entry, not a patch.

### 2. Index and corpus must agree — mechanically

A registry that grows past ~20 entries is entered through an index, not read front to back. Index and corpus drift silently: someone adds an entry and forgets the index row, and from then on the entry is invisible.

**Check this with a script, not with care.** A linter that verifies every corpus entry has an index row (and vice versa), that numbering is contiguous, and that no number is used twice. Run it on startup.

### 3. Climb the ladder: remembered → ritual → mechanism

Every rule has a status:

- **P (remembered)** — you intend to recall it. Worth almost nothing under load.
- **R (ritual)** — a checklist, template, or fixed step makes it hard to skip.
- **M (mechanism)** — code refuses to proceed. The rule survives you forgetting it.

**A rule without a mechanism is a wish.** Not every rule can climb — some genuinely cannot be automated, and saying so is honest. But an entry that sits at P for months is telling you either that it does not matter or that nobody has tried.

Mark the status on the entry. Track how many have climbed. That number is the registry's actual health, far more than its length.

### 4. Every guard must be able to fail

A guard that has never returned "no" is not known to work. Before trusting one, feed it a case it **must** reject and a case it **must** accept. A guard passing on an empty input set looks identical to a guard passing on real data.

This is the single most common way error-prevention machinery turns decorative: it is installed, it goes green, and the green means nothing because it has never been red.

### 5. Recidivism is a signal about the rule, not the actor

When an entry recurs — especially soon after being written — the instinct is to conclude carelessness. Usually the entry is at fault:

- the **rule is unenforceable** at the moment of action (it fires too late, or requires noticing what cannot be noticed)
- the **pattern is narrower than the phenomenon** — the rule names one shape of a failure that has several
- the rule sits at **P** and P does not survive load

Keep a recurrence count per entry. A high count is a **request for mechanisation or reformulation**, not a reason for self-criticism. Self-criticism is cheap and changes nothing; a guard is expensive and changes everything.

## Composting

Registries rot in a specific way: entries that have been fully mechanised keep taking up reading space, and the live entries drown.

When an entry reaches **M** and the guard has proven itself, compress it to a capsule — rule plus guard name plus a pointer — and move the full text to an archive. Nothing is deleted; the entry stops competing for attention. Length is not the goal. **Every failure mode having exactly one home is the goal.**

## Verification

1. Pick the three most recent entries. For each, name the guard. If any has none, it is a lesson, not a scar.
2. What fraction of entries sit at **M**? If none, the registry is a diary.
3. For each mechanised guard: has it ever returned a failure? If not, run the negative test now.
4. Does a linter check index-against-corpus? If a human does it, it is not checked.
5. Is there an entry with a recurrence count above two that is still at P? That is the highest-value work available to you.

## Pitfalls

- **Registry as apology.** Entries written to demonstrate contrition rather than to prevent recurrence read well and do nothing. The test: could someone else use this entry to avoid the error?
- **Retroactive tidying.** Cleaning up old entries to make the record coherent destroys the record.
- **Guard theatre.** Installing a check nobody has tested in the failing direction — see rule 4.
- **Numbering drift.** Two entries with the same number, or a number silently reused, breaks every cross-reference in the registry. Mechanise the check.
- **Recording everything.** A registry of trivia gets skimmed, and skimming a registry defeats it. The bar is: *this failure mode will recur.*
- **Blaming the actor for recidivism.** The rule failed. Fix the rule.

---

*From HEXAGRAM · CC BY-NC-SA 4.0 · attribution: nowe spojrzenie. Companion to `ai-hallucination-truth-status` (truth statuses and named voices) and `ai-self-audit-without-hedging` (when to surface an audit). The rules above are drawn from a registry of 34 entries maintained in daily human–AI practice; the recidivism rule was written after one failure mode recurred six times under a pattern that was narrower than the phenomenon, and again after a rule was broken in the same evening it was written down.*
