# Skill: session-memory

## Trigger
User says "save session memory", "write session summary", "record session", or any close variant.

---

## Behaviour
Write the session memory file immediately — no confirmation needed, the trigger is consent.
Do not ask questions mid-way.

---

## Session Memory File

**Path:** `<repo-root>/session_memory_<YYYY-MM-DD_HH-MM-SS>.md`
Use the current timestamp at the time of writing. Never overwrite an existing file.

**Include:**
- What was worked on (1–2 sentences, high level)
- Files changed — name each file and what changed, one line per file
- Decisions made and rationale (only decisions, not process)
- What was tried and abandoned
- Open questions / blockers
- Next steps (ordered)
- Git status: last commit message + hash; any uncommitted work

**Omit:** anything resolved, conversational back-and-forth, thinking-out-loud that didn't produce a decision or change.

---

## After writing the file

One-line confirmation:
> "✅ `session_memory_<date_and_time>.md` written."

Nothing else.
