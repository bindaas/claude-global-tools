# Skill: refresh-memory

## Trigger
User says "refresh memory", "refresh my memory", or any close variant.

---

## What this skill does

Reads the most recent session memory file to reload context from the last session. This lets a new Claude instance pick up where the previous one left off without the user having to re-explain everything.

---

## Steps

### Step 1 — Find the latest session memory file

List the project root directory and find all files matching `session_memory_*.md`.

Sort by date (the filename contains the date as `YYYY-MM-DD`). Pick the **most recent** one.

### Step 2 — Read it

Read the full contents of that file.

### Step 3 — Acknowledge and summarize

Tell the user you've loaded the session memory. Give a brief (3–5 sentence) recap in your own words:
- What was being worked on
- Where things were left off (next steps / blockers)
- Anything that was in-progress or unverified

**Do not just dump the file contents back at the user** — synthesize it naturally, as if you're catching yourself up out loud.

### Step 4 — Ask what to continue with

After the recap, ask:
> "Want to pick up from [most relevant next step], or is there something else on your mind?"

---

## Notes

- If no `session_memory_*.md` file exists, tell the user: "I don't see any session memory files yet. Once you run session-memory, I'll be able to refresh from those."
- If there are multiple session memory files, always use the **latest date** only — don't summarize older ones unless asked.
- The session memory file is the source of truth. Don't infer or guess things not written there.
