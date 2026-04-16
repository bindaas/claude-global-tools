# refresh-memory

A Claude plugin that reloads context from the previous session.

## Trigger
Say **"refresh memory"** or **"refresh my memory"** at the start of a session.

## What it does
Finds the most recent `session_memory_*.md` file in the project root, reads it, and gives you a 3–5 sentence recap of where things were left off — then asks what to pick up next.

## Works with
Pairs with the `session-memory` plugin, which writes the files this plugin reads.
