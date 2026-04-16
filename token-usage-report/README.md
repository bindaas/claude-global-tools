# token-usage-report

A Claude plugin that estimates token usage and cost for a session.

## Trigger
Say **"token report"**, **"token usage"**, **"cost estimate"**, or **"how much did this cost"**.

## What it does
Writes a `token-report_<date>_<time>_<slug>.md` to the project root with estimated input/output token counts, cost breakdown, cost drivers, waste, habit recommendations, and optional CLAUDE.md suggestions.
