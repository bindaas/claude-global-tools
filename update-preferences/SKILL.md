# Skill: update-preferences

## Trigger
User says "update preferences", "sync preferences", "merge preferences", or any close variant.

---

## What this skill does

Reads `/Users/bindaas/projects/claude-global-tools/PREFERENCES.md` and merges its full content
into the project's `CLAUDE.md` inside a clearly marked block. Global always overrides local.
The merged block is always replaced wholesale — no diffing, no partial updates.

This means additions, removals, reordering, and small edits in PREFERENCES.md are all handled
correctly on the next run of this skill.

---

## Steps

### Step 1 — Read both files

- Read `/Users/bindaas/projects/claude-global-tools/PREFERENCES.md`
- Read `CLAUDE.md` in the current project root

### Step 2 — Check for existing merged block

Scan `CLAUDE.md` for the line:

```
<!-- BEGIN MERGED PREFERENCES -->
```

- **Found** → existing block present; go to Step 3 (replace).
- **Not found** → first-time merge; go to Step 4 (insert).

### Step 3 — Replace existing block

Locate and replace everything from `<!-- BEGIN MERGED PREFERENCES -->` up to and including
`<!-- END MERGED PREFERENCES -->` with the new merged block (format in Step 5).

Then go to Step 6.

### Step 4 — Insert new block

Find the `## GLOBAL RULES` section in `CLAUDE.md`. Insert the merged block immediately after
the closing `---` of that section.

If `## GLOBAL RULES` does not exist, insert after the first `---` in the file.

### Step 5 — Merged block format

```markdown
<!-- BEGIN MERGED PREFERENCES -->
<!-- Merged from PREFERENCES.md via update-preferences skill. Do not edit manually — run update-preferences to refresh. -->

<full verbatim content of PREFERENCES.md>

<!-- END MERGED PREFERENCES -->
```

No summarising, no paraphrasing — copy the content of PREFERENCES.md exactly as-is between the markers.

### Step 6 — Write CLAUDE.md

Write the updated content back to `CLAUDE.md`.

### Step 7 — Report

Tell the user:

> "✅ PREFERENCES.md merged into CLAUDE.md (`<N>` lines). [First-time merge / Existing block replaced.]"

If replacing: briefly note what changed between the old and new block (sections added, removed,
or visibly edited). If nothing changed, say so — "No changes detected."

---

## Notes

- Never edit the content between the markers by hand or infer updates from context — always re-read PREFERENCES.md fresh.
- If PREFERENCES.md cannot be read (path missing), abort and tell the user: "Cannot read PREFERENCES.md at the expected path — please check the file exists."
- The `## GLOBAL RULES` "read this file" instruction in CLAUDE.md is intentionally kept even after the merge — it serves as a reminder to reload PREFERENCES.md at session start.
- This skill writes to `CLAUDE.md` without a confirmation prompt — the trigger is consent.
