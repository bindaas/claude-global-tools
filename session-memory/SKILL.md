# Skill: session-memory

## Trigger
User says "save session memory", "write session summary", "record session", or any close variant.

---

## Behaviour
Write the session memory file immediately — no confirmation needed, the trigger is consent.
Do not ask questions mid-way.

---

## Session Memory File

**Path:** `<repo-root>/session_memory_<YYYY-MM-DD>.md`
Overwrite if it already exists (same-day session).

**Include:**
- What was worked on (1–2 sentences, high level)
- Files changed — name each file and what changed, one line per file
- Decisions made and rationale (only decisions, not process)
- What was tried and abandoned
- Open questions / blockers
- Next steps (ordered)
- Git status: last commit message + hash; any uncommitted work

**Omit:** anything resolved, conversational back-and-forth, thinking-out-loud that didn't produce a decision or change.

**Style:** follow existing `session_memory_*.md` files in the repo root if any exist.

---

## After writing the file

One-line confirmation:
> "✅ `session_memory_<date>.md` written."

Nothing else.
