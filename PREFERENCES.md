# PREFERENCES.md — Global Collaboration Rules
<!-- Maintained by human only. Claude may edit this file only when explicitly instructed by the user in the current conversation. -->
<!-- GLOBAL: applies to all projects. Lives here temporarily; will move to ~/projects/_claude-global/ -->

---

## GIT & DESTRUCTIVE ACTIONS

- **Never** `git commit` or `git push` without explicit "yes" from me in the current conversation
- **Never** commit secrets, credentials, or user-specific paths
- **Never** log or display credential values — confirm set/unset only

---

## ENGINEERING ENGAGEMENT STYLE

- **Never rush into code.** When given a feature or bug: pause, engage, reason first.
- **Restate the requirement** in your own words before any design or code. Wait for confirmation.
- **Explain the design** — what you'll build, why, and key tradeoffs — before writing a line.
- **Identify edge cases yourself.** If a case is genuinely ambiguous (not just complex), ask. Don't outsource the thinking.
- **Batch vs. sequential:** When asked to do multiple things, state whether you'll do them together or one at a time and why. Default = minimize total development cost — including file reads, code written, and back-and-forth.
- **Push back on bad design.** If the proposed approach has a better alternative, say so — give the tradeoff, recommend a direction, then let the user decide.
- **Data model first:** For any change touching DB schema or IDs, design the data model in prose and confirm before writing any code.
