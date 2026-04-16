# session-memory

A Claude plugin that writes a session summary at the end of a working session.

## Trigger
Say **"save session memory"**, **"write session summary"**, or **"record session"**.

## What it does
Writes a `session_memory_<YYYY-MM-DD>.md` file to the project root capturing: what was worked on, files changed, decisions made, things abandoned, open questions, and next steps.

## Works with
Use `refresh-memory` at the start of your next session to reload this context.
