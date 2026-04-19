This project contains plugins used by multiple projects that use Claude for development.
Also includes files read by CLAUDE.md in other projects: PREFERENCES.md, STRATEGY.md.

## Plugins
- **refresh-memory** — reloads context from the previous session
- **session-memory** — writes a session summary at end of a working session
- **token-usage-report** — estimates token usage and cost for a session

## Rules
- Ignore any files matching `*_HUMAN.MD` (e.g. DEV_PLAN_HUMAN.MD). These are for humans only.
