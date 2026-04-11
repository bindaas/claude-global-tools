# Claude Session Protocol

A lightweight, reusable prompt that gives Claude structured session
awareness — so you can pick up any project without re-explaining everything,
and close down cleanly without losing context.

Works with **Claude Desktop** (claude.ai) and **Claude CLI / Claude Code**.
Git-aware when relevant. No personal data. No hardcoded filenames.

---

## What it does

| Trigger | What Claude does |
|---|---|
| You say "resume session" (or similar) | Reads the last session summary and briefs you on where you left off |
| You say "wrapping up" (or similar) | Runs through a closing checklist and writes a session summary file |

At the end of every session, a `session_YYYY-MM-DD.md` file is written to
your project root. Next session, Claude reads it and you're back up to speed
in under a minute.

---

## Setup

### Option A — Claude Desktop (claude.ai)

Claude Desktop supports **Project Instructions** — a persistent system prompt
that applies to every conversation inside a project.

**Step 1: Create a project**

1. Go to [claude.ai](https://claude.ai) and click **Projects** in the left sidebar.
2. Click **New project** and give it a name (e.g. the name of your codebase).

**Step 2: Add the protocol as project instructions**

1. Inside the project, click the project name at the top to open project settings.
2. Click **Edit project instructions** (or the pencil icon next to "Custom instructions").
3. Open `PROMPT.md` from this repo, select all, and copy the contents.
4. Paste into the instructions field.
5. Click **Save**.

The protocol is now active for every conversation in that project.
Start a new conversation and say "resume session" to begin.

> **Note:** Project Instructions are scoped to one project. If you work across
> multiple projects, repeat Step 2 for each one — there is no single global
> instructions field in Claude Desktop.

---

### Option B — Claude Code CLI (global — applies to all projects)

Claude Code reads a global instruction file at `~/.claude/CLAUDE.md`
automatically at the start of every session, in every project.

**Step 1: Create the config directory (if it doesn't exist)**

```bash
mkdir -p ~/.claude
```

**Step 2a: Fresh install — no existing CLAUDE.md**

```bash
cp PROMPT.md ~/.claude/CLAUDE.md
```

Or, if you want to pull it directly from GitHub:

```bash
curl -o ~/.claude/CLAUDE.md \
  https://raw.githubusercontent.com/YOUR_USERNAME/YOUR_REPO/main/PROMPT.md
```

**Step 2b: You already have a `~/.claude/CLAUDE.md`**

Append rather than overwrite, so you don't lose existing instructions:

```bash
echo "" >> ~/.claude/CLAUDE.md
cat PROMPT.md >> ~/.claude/CLAUDE.md
```

**Step 3: Verify it's in place**

```bash
cat ~/.claude/CLAUDE.md
```

You should see the session protocol in the output. No restart needed —
Claude Code reads this file at the start of each session.

---

### Option C — Claude Code CLI (per-project only)

If you only want the protocol active in one specific project rather than
globally, place it in that project's local instruction file instead:

```bash
# From your project root
mkdir -p .claude
cat PROMPT.md >> .claude/CLAUDE.md
```

This coexists with `~/.claude/CLAUDE.md` — both are loaded, with the
project-level file taking precedence on any conflicts.

To share the protocol with collaborators, commit `.claude/CLAUDE.md`.
To keep it personal, add `.claude/CLAUDE.md` to your `.gitignore`.

---

## How to use it

### Starting a session

Just say something natural:

> "Resume session"  
> "Picking up from yesterday"  
> "New session — let's continue on the auth work"  
> "Just got back, where were we?"

Claude will find the most recent `session_YYYY-MM-DD.md` in your project
root, brief you on what was happening, and ask one orienting question before
getting to work.

### Ending a session

Say something natural:

> "Wrapping up"  
> "Done for the day"  
> "Let's do a handover"  
> "Calling it"

Claude will:

1. *(Git projects only)* Check your commit status and ask two quick questions.
2. *(Git projects only)* Ask if any tracked docs need updating.
3. Write `session_YYYY-MM-DD.md` to your project root.
4. Confirm you're good to close.

---

## The session summary format

Every session produces a file like this:

```markdown
# Session Summary — 2025-04-11

## What we worked on
## Changes made
## Decisions made
## What was tried and abandoned
## Open questions / blockers
## Next steps
## Git status (if applicable)
```

The **"What was tried and abandoned"** section is intentionally included —
it's the one most people skip and the one most useful across sessions.

---

## Git awareness

The protocol detects whether your project has a `.git/` directory.

- **Git project detected:** Claude asks about commits and tests before
  closing, and offers to help update any tracked documentation files.
- **No `.git/` detected:** All git steps are skipped silently. The session
  summary is still written either way.

Claude can read `.git/COMMIT_EDITMSG` and `.git/refs/heads/main` but cannot
run terminal commands. It will always confirm git state with you rather
than assume.

---

## Desktop vs CLI: how files get written

| Environment | How session files are written |
|---|---|
| Claude Desktop (claude.ai) | Claude outputs the file contents in a labelled code block — copy and save manually |
| Claude Code CLI | Claude writes `session_YYYY-MM-DD.md` directly to the project root |

---

## What this protocol does not do

- Does not commit code on your behalf
- Does not run terminal commands
- Does not assume specific documentation files exist
- Does not trigger mid-session
- Does not store personal information or reference any specific user

---

## Files in this repo

| File | Purpose |
|---|---|
| `PROMPT.md` | The full protocol — add this to Claude's instructions |
| `README.md` | This file |

---

## Contributing

Issues and PRs welcome. If you extend this for a specific workflow
(e.g. a variant for solo vs team projects, or one tuned for a specific
toolchain), open a PR with a clear description of what it adds and why.
