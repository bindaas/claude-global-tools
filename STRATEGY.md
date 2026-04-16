# STRATEGY.md — Token & Context Efficiency
<!-- Maintained by human only. Claude may edit this file only when explicitly instructed by the user in the current conversation. -->
<!-- GLOBAL: applies to all projects. Lives here temporarily; will move to ~/projects/_claude-global/ -->

---

## SESSION MANAGEMENT

- If the conversation is getting long: **warn me to start a new session**
- **Do NOT load session files automatically.** Only load them when the user triggers a skill.

---

## FILE READING DISCIPLINE

- Before reading any file: state which file and why
- Use `head` on large files to check structure before reading fully
- For "where is X configured?" — reason about it first, read at most 1–2 candidates
- Never read frontend/UI files to answer backend/config questions
- Allowed full reads without asking: `CLAUDE.md`, `ARCHITECTURE.md`

---

## COST CHECK BEFORE ACTING

- If a task seems expensive (many files to read, large rewrite, cascading changes): stop and propose a cheaper path first
- **Cost check before acting:** Estimate scope before diving in. Surface the estimate to the user.
