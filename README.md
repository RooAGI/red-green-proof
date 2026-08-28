# red-green-proof

A skill for Claude Code and Codex that turns a *suspected* bug into a *proven* one.

> A bug is not fixed because the tests pass. A bug is fixed when a test **fails
> without your fix and passes with it**, and you have watched it do both.

## Why

Most regression tests are written *after* the fix and never had the chance to
fail. They pass, they look like coverage, and they prove nothing. This skill adds
the one step that separates a real test from a decorative one:

**Revert the fix. Confirm the test goes red. Restore.**

That step is not paranoia — it catches tests that exercise a path *next to* the
bug rather than the bug itself. Two real cases it caught:

- A concurrency test modelled two writers, but with no `await` between each
  writer's read and its write. They never actually interleaved, so the test
  passed with the lock removed.
- A fault-isolation test asserted "no 500 when the store fails", but the injected
  failure was a *missing* record, which the loader turns into `null` instead of
  throwing. The error path never ran.

Both read correctly on the page. Only the revert exposed them.

## The loop

1. **Verify the cause — do not infer it.** Label every claim `Proven` /
   `Inferred` / `Unknown`. Check `git log -S` before treating behaviour as a bug;
   it may have been deliberate.
2. **Write the test. Watch it fail** against the code as it is now.
3. **Fix it** — smallest change that goes green.
4. **Revert the fix. Confirm red. Restore.** If it stayed green, the test is
   fake; rewrite it.
5. **Run the full suite and type checks.**

Plus guidance for the awkward case where the buggy code cannot be invoked at all
(closures, route handlers) — extract, structural, model, or characterization
tests, each with an honesty label required in the file header.

## Install

```bash
git clone https://github.com/RooAGI/red-green-proof ~/sources/red-green-proof
cd ~/sources/red-green-proof
./install.sh
```

| Command | Effect |
|---|---|
| `./install.sh` | Both Claude Code and Codex, user-level |
| `./install.sh --claude` | `~/.claude/skills/red-green-proof/SKILL.md` |
| `./install.sh --codex` | `~/.codex/prompts/red-green-proof.md` |
| `./install.sh --project /path/to/repo` | Repo-local `.claude/skills/` (checked in, shared with the team) |
| `./install.sh --link` | Symlink instead of copy — edits here take effect immediately |
| `./install.sh --uninstall` | Remove |

## Use

The intended call is the bare one, at the end of a debugging conversation:

```
/red-green-proof
```

It takes the target from context rather than asking — preferring a fix that was
applied *without* a failing test behind it, since that test still has to be
proven load-bearing. It states its pick in one line and starts.

Give a target explicitly when you want to steer it somewhere else:

```
/red-green-proof the status endpoint reports finished runs as running
/red-green-proof checkpointBuffer.ts loses events when the PUT fails
```

Or just describe the task — the description triggers on phrases like "prove the
bug", "make the test fail first", and "is that test load-bearing".

**Note:** Claude Code indexes skills at session start. After installing, start a
new session before the command is available.

## Layout

```
SKILL.md                     Claude Code skill (frontmatter + full guidance)
prompts/red-green-proof.md   Condensed prompt form for Codex
install.sh                   Installer for both
```

The two files carry the same discipline at different lengths. Edit `SKILL.md`
first; keep the Codex prompt in sync.

## Origin

Distilled from a real incident investigation where a successful run displayed as
"running" for hours. The root cause turned out to be a lost update between two
concurrent read-modify-write cycles on the same document — and, along the way,
two of the tests written to prove it were themselves fake, caught only by
step 4.
