# Skill: token-usage-report

## Trigger
User asks for a token report, token usage summary, or cost estimate for the session.

---

## Behaviour
Write the token report immediately — no confirmation needed.
Do not ask questions mid-way.

---

## Token Report

**Path:** `<repo-root>/token-report_<YYYY-MM-DD>_<HHMM>_<slug>.md`
- `<HHMM>` = approximate 24hr time
- `<slug>` = 3–5 word kebab-case label for what was worked on

⚠️ All figures are estimates. Mark them as such.

```markdown
# Token Usage Report
**Session:** <date> | <N> turns | Short / Medium / Long

## Estimates ⚠️ Approximate
| | Tokens | Cost (USD) |
|---|---|---|
| Input | X,000–Y,000 | ~$X.XX |
| Output | X,000–Y,000 | ~$X.XX |
| **Total** | | ~$X.XX–$X.XX |

Pricing: input ~$3/M, output ~$15/M (claude-sonnet-4)
Efficiency: N/10

## Cost drivers
- [Each driver: name the file/action and estimated token impact. Be specific.]

## Waste (specific)
- [Name the exact action and estimated tokens wasted. If none, say "None identified."]

## Habit recommendations
| Current habit | Better alternative | Saving |
|---|---|---|
| ... | ... | High/Med/Low |

## CLAUDE.md Suggestions
Only include this section if there is evidence from this session that a change would reduce cost or friction.
Omit entirely if nothing qualifies.

| Section | Current behaviour | Suggested change | Expected saving |
|---|---|---|---|
| ... | ... | ... | High/Med/Low |

**What qualifies:**
- A rule that caused repeated re-reads or clarifications
- A pattern that came up but isn't documented (would have saved a round-trip)
- A section that was read but added no value
- A rule that was ambiguous and led to a wrong first move

**What does not qualify:**
- Stylistic preferences
- Things that worked fine
- Speculation with no evidence from this session

Do not edit `CLAUDE.md` directly — flag the section and what to change. The human edits the file.

## Tags
`#tag1` `#tag2`
```

**Estimation benchmarks (internal reference, do not include in output):**
- 1 line of code ≈ 10–15 tokens
- 1 paragraph ≈ 75–100 tokens
- Reading a 200-line file ≈ 2,000–3,000 input tokens
- Writing a 200-line file ≈ 3,000–4,500 output tokens
- Typical user message ≈ 50–200 tokens

---

## After writing the file

One-line confirmation:
> "✅ `token-report_<date>_<time>_<slug>.md` written. Biggest cost driver: [X]. Efficiency: N/10. [N CLAUDE.md suggestion(s) included. / No CLAUDE.md suggestions.]"

Nothing else.
