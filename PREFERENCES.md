# PREFERENCES.md — Global Collaboration Rules
<!-- Maintained by human only. Claude may edit this file only when explicitly instructed by the user in the current conversation. -->
<!-- GLOBAL: applies to all projects. Lives here temporarily; will move to ~/projects/_claude-global/ -->


---

## ENGINEERING ENGAGEMENT STYLE

- **Before any code:** restate the requirement, flag risks/gaps/alternatives, recommend a direction with key tradeoffs, and wait for confirmation. For files likely to exceed ~80 lines, also state assumptions about behaviour and interactions. Required on **all code changes** — feature requests, bug fixes, and refactors alike. No exceptions for "obvious" or "trivial" fixes.
- **Edge cases:** surface them proactively. Ask only if genuinely ambiguous.
- **Multiple requirements:** present a sequenced development plan first, factoring in token cost (shared context, file reads, round-trips) alongside standard practice. State the reasoning.
- **Data model first:** design DB/schema changes in prose and confirm before writing code.
- **Contract changes:** explicitly call out any API or interface changes before proceeding.
- **Staggered deployment:** whenever multiple components are involved, assume they deploy independently — backward compatibility is required unless explicitly waived.
- **Deployment plan:** whenever changes span multiple components (e.g. backend + mobile, API + frontend), present a deployment order with dependency reasoning before writing code. State which order is safe, what the backward-compat window looks like between deploys, and any rollback risk.
- **Pre-implementation checklist** (state before writing code — mandatory for every code change, regardless of perceived simplicity):
  - Confidence in solution: X/5
  - Regression risk: X/5
  - Data model changes: list or "none"
  - Test changes needed: list or "none"
  - Deployment order: component sequence + safe window or "single component"

---

## OPENSPEC RULES

- **On `/opsx:propose`**: At the end of `tasks.md`, append an `## Assumptions` table with two columns — `Assumption` and `Where to verify`. List the key code-level assumptions the tasks depend on (e.g., function names, rendering patterns, data structures, API response shape). Be specific enough that drift is detectable by reading 1–2 files.

- **On `/opsx:apply`**: Before writing any code, read the files listed in the Assumptions table and verify each assumption still holds. Flag any that have drifted (technically or functionally) and surface them in the "before any code" confirmation step. Do not proceed until the user acknowledges the drift.

---

## DATA MODEL DISCIPLINE

- Before implementing features that touch the database: if `PRODUCT.md` exists, read it and verify table semantics match product intent.
- If a table's purpose is ambiguous, ask — don't assume. Semantic drift is expensive to fix after data exists.
- Schema changes use `ALTER TABLE` only. Never drop and recreate.

## TOOL USAGE

- **Never use `find`, `ls`, or `grep` as Bash commands** to explore files. Use `Glob` for file listing and `Grep` tool for content search. `find` returns `.git/objects/` noise and wastes tokens.

---

## FILE READING DISCIPLINE

- Use `head` on large files to check structure before reading fully
- For "where is X configured?" — reason about it first, read at most 1–2 candidates
- Never read frontend/UI files to answer backend/config questions
- **Bug fix verification:** grep for the specific symbol or pattern first — only full-read the file if the grep is ambiguous or returns nothing
- **Candidate files in a directory:** read the first 10–15 lines (file header / docstring) to confirm relevance before pulling the full file

---

## SESSION MANAGEMENT

- If the conversation is getting long: **warn me to start a new session**
- **Do NOT load session files automatically.** Only load them when the user triggers a skill.

---

## GIT & DESTRUCTIVE ACTIONS

- **Never** commit secrets, credentials, or user-specific paths
- **Never** log or display credential values — confirm set/unset only


