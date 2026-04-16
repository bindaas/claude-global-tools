# claude-global-tools

Shareable Claude plugins — skills that work across any project.

## Plugins

| Plugin | Trigger | What it does |
|--------|---------|--------------|
| `refresh-memory` | "refresh memory" | Reloads context from the last session summary |
| `session-memory` | "save session memory" | Writes a session summary to the project root |
| `token-usage-report` | "token report" | Estimates token usage and cost for the session |

## Using in a project

Add as a git submodule:
```bash
git submodule add https://github.com/bindaas/claude-global-tools .claude/plugins/claude-global-tools
```

Then reference the plugins in your project's `CLAUDE.md`:

```markdown
## SKILLS

| Skill | Trigger | Path |
|-------|---------|------|
| `refresh-memory` | "refresh memory" | `.claude/plugins/claude-global-tools/refresh-memory/SKILL.md` |
| `session-memory` | "save session memory" | `.claude/plugins/claude-global-tools/session-memory/SKILL.md` |
| `token-usage-report` | "token report" | `.claude/plugins/claude-global-tools/token-usage-report/SKILL.md` |
```

## Structure

Each plugin lives in its own directory:
```
<plugin-name>/
├── .claude-plugin/
│   └── plugin.json   ← manifest
├── SKILL.md          ← instructions Claude reads when triggered
└── README.md         ← human docs
```
