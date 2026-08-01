---
name: ai-agent-verify-success-claims
description: Use whenever an agent has a terminal, a shell, or write access to a repository and is about to report that something worked. Verdicts come from exit codes, never from output text; state is re-checked with a second, independent instrument; clocks, versions, and paths are measured rather than recalled. Load before declaring a push, deploy, migration, install, or file operation successful — and when a command printed something reassuring.
license: CC-BY-NC-SA-4.0
metadata:
  version: 1.2.0
  former-name: verified-execution
  authors:
    - nowe spojrzenie (HEXAGRAM project)
  tags:
    - agents
    - shell
    - devops
    - verification
    - reliability
    - tool-use
  platforms:
    - hermes
    - claude-code
    - cursor
    - codex-cli
    - generic
  siblings:
    - ai-hallucination-truth-status
---

# Verified Execution

**The problem this solves:** you gave an agent a terminal. It ran a command, read the output, and told you the deploy succeeded. The output said things like *Everything up-to-date*. The deploy did not succeed.

Language models are very good at reading text and very bad at noticing that text is not evidence. A shell already tells you the truth — in the exit code, which is boring and has no adjectives. The failure mode is preferring the prose.

This skill is the boundary between what an agent *saw scroll past* and what actually happened.

## When to Use

Load this before:

- reporting that a push, deploy, migration, install, build, or file operation succeeded
- stating a version, a path, a timestamp, a branch, or a count
- acting on the assumption that a previous step completed
- summarising what a long-running or multi-step operation did

And immediately when: **a command printed something reassuring.** That is the exact moment this skill exists for.

## Procedure

### 1. The verdict comes from the exit code

```sh
some-command > /tmp/out.log 2>&1; RC=$?
```

Capture `$?` **into a variable, on the same line**, before anything else runs — `echo`, a pipe, a redirect, another command will all overwrite it.

Then branch on `RC`. Not on whether the output contained "success", "done", "complete", "up-to-date", "0 errors". Those strings appear in failures. `RC` does not.

In a pipeline, `$?` is the *last* command's status. Use `${PIPESTATUS[0]}` (bash) or `set -o pipefail` when the interesting command is not the last one. A `| tail -2` silently converts a failure into a success.

### 2. Verify with a second, independent instrument

Exit zero means *the command believed it succeeded*. It does not mean the world changed.

After a state-changing operation, check the state with something that did not perform it:

| operation | independent check |
|---|---|
| push to remote | query the remote ref directly and compare hashes |
| file write | read the file back and compare size or digest |
| install | invoke the installed thing and read its version |
| deploy | request the deployed endpoint |
| migration | query the schema |

Two failures this catches that exit codes cannot: a command that succeeds at doing *nothing* (nothing was staged, no files matched, a filter excluded everything), and a command that succeeds against the *wrong target* (wrong branch, wrong environment, wrong path).

### 2b. When the operation changes a *set* of files, verify the set

An exit code and a matching commit hash can both be correct while the payload is wrong.

This happens when the operation changed which files exist — a rename, a move, a deletion, a
selective checkout. `git commit -m "..."` without `-a` or `git add -A` stages additions and
silently leaves deletions behind. The push then succeeds, the local and remote hashes agree,
and every check passes — because you verified that *what you sent* arrived, not that *what you
sent was what you intended*.

**Hash verification proves transport, not payload.** For set-changing operations, the second
instrument is the remote **listing**, compared against intent:

```sh
git ls-tree --name-only FETCH_HEAD path/ | wc -l    # then compare to the number you expect
```

The general form: after any operation that adds, removes or renames members of a collection,
enumerate the collection at the destination and compare the count and the names. Not the digest
of the transfer — the contents of the destination.

This class of failure is the most expensive one in this document, because every guard reports
green. Nothing is lying. The question was too narrow.

### 3. Measure clocks, versions, and paths — never recall them

Anything checkable is cheap to check and expensive to guess. Read the clock. Read the version file. List the directory. `pwd`.

Time is the sharpest case. **A measured date has an expiry.** Read at 23:50 and used at 00:10, it is silently wrong, and every record written from it is wrong in a way nobody notices for weeks. Re-measure in the same step where you write a date.

The environment clock may also simply be wrong. When it matters, cross-check against something externally anchored — a remote commit timestamp, a server header.

### 4. Test the instrument on a known hit before trusting a zero

A search that finds nothing and a search that is broken produce **the same output**: nothing.

A malformed regex, a wrong path, a shell that does not support the syntax you used — all return empty, and empty reads as *clean*. Before concluding "no matches", feed the same pattern something it **must** match. If it does not fire, the zero was about your instrument, not about the world.

This generalises: any check that reports "all clear" should be shown, once, to something dirty.

### 5. Never let a fixed sentence stand next to a measurement

```sh
grep -rn "$PATTERN" . > /tmp/hits.txt
echo "(clean — no matches)"          # ← lies whenever there are matches
```

The sentence executes unconditionally. It is not a report; it is decoration that looks like a report. Derive it:

```sh
if [ -s /tmp/hits.txt ]; then echo "MATCHES:"; cat /tmp/hits.txt; else echo "zero"; fi
```

Rule: **a sentence about a result must be a function of the result.** If you cannot build it from `$?`, `-s`, or `-z`, do not write it.

### 6. Do not rewrite shared history to make a report true

When a push is rejected or branches have diverged, the tempting repair is force, rebase, or amend. If the remote holds work you have not read, **stop and report** — do not merge, rebase, or overwrite silently. Another hand may be working.

Before touching a divergence, measure the overlap: which files did the other side change, and do they intersect yours? An empty intersection makes a rebase mechanical. A non-empty one makes it a decision that belongs to a human.

### 7. Secrets: inline, masked, never persisted

Credentials go into the command that needs them, in the same invocation — never into a config file, a stored remote URL, or an environment that outlives the step. Filter output through a mask before printing. After the operation, reset whatever might have retained the token, and verify that it did not.

## Verification

Before reporting any operation as successful:

1. Do I have an exit code for it, captured before anything else ran?
1b. If the operation changed which files exist — did I enumerate the destination and compare
   the count and names to what I intended?
2. Did I confirm the resulting state with an instrument that did not perform the operation?
3. Is every number, version, path, and timestamp in my report from a measurement in this session?
4. Did any check return "nothing found"? Has that check been shown a known hit?
5. Is there a sentence in my report that would have printed regardless of the outcome?
6. If something diverged or was rejected — did I stop, or did I repair it into looking fine?

## Pitfalls

- **Reading success from prose.** The origin of nearly every false report. `git push` prints reassuring things while changing nothing.
- **Losing `$?`.** An `echo` between the command and the check destroys the only reliable evidence.
- **Pipes swallowing failure.** `cmd | tail -2` exits with `tail`'s status.
- **Trusting the actor's own report.** The tool that made the change is the worst witness that it happened.
- **Zero as proof of cleanliness.** Untested instruments return zero enthusiastically.
- **Dates from memory.** Especially near midnight, and especially in environments whose clock you have not checked.
- **Success at doing nothing.** Empty stage, no matching files, filter excluded everything — all exit zero.
- **Verifying transport instead of payload.** Matching hashes prove the transfer, not that the transfer carried what you meant. Renames and deletions are where this bites.

---

*From HEXAGRAM · CC BY-NC-SA 4.0 · attribution: nowe spojrzenie. Companion to `ai-hallucination-truth-status` (truth statuses), `ai-agent-error-memory-registry` (how failure modes are recorded), and `ai-self-audit-without-hedging` (when to surface an audit). Every rule here is the residue of a specific incident in daily human–AI practice, including a push reported as successful on the strength of its output text, and a search reported as clean by a regex that could not match.*
