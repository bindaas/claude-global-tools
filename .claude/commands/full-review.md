---
description: Run the full review chain on a PR — code review, test review, requirements review, and architecture review in sequence
argument-hint: <PR number>
---

If no PR number was provided in "$ARGUMENTS", stop and tell the user: "Usage: /full-review <PR number>"

Otherwise, run all four reviews in sequence for PR #$ARGUMENTS. Each review must fully complete before the next begins (they all write to files and must not run in parallel).

Set `PR=$ARGUMENTS` and `BUNDLE_DIR=/tmp/full-review-pr-$PR` throughout.

## Bundle build (run before step 1, and again after step 2)

All four reviewers need the same PR metadata, diff, and changed-file contents. Instead of letting each one fetch it independently, build it once into a shared bundle and point each agent at it. Do not read the bundle's contents into your own context — just build it on disk by running the bundle-build script:

```bash
bash /Users/bindaas/.claude/scripts/build-review-bundle.sh "$PR" "$BUNDLE_DIR"
```

1. Run the bundle build above (pre-fix state). Spawn the `code-reviewer` agent with: "Review PR #$ARGUMENTS. Use $PR=$ARGUMENTS throughout your instructions. A pre-fetched context bundle is available at $BUNDLE_DIR — read pr-meta.json, pr.diff, and files/ from there instead of fetching the PR or changed files yourself."

2. Once the code review completes, fetch the review it posted to the PR and automatically apply all **Must fix** and **Should fix** items it identified. To do this:
   - Read `$BUNDLE_DIR/pr-meta.json` for the branch name (`headRefName`) — the branch is already checked out from the bundle build above.
   - Read the review comment Dopey just posted (fetch via `gh pr view $ARGUMENTS --json reviews` or `gh api repos/:owner/:repo/pulls/$ARGUMENTS/reviews`)
   - Make the code changes directly in the working tree
   - Commit and push to the PR branch. Include `[skip deploy]` in the commit message if no backend application files were changed — consult `RULES_OF_ENGAGEMENT.MD` for which paths trigger a deploy.
   - Do NOT ask the user for approval before applying fixes — just do it. Only pause if you hit a genuine ambiguity or conflict that makes you unsure what the correct fix should be (that is the "serious kerfuffle" threshold).
   - Skip this step entirely if the code-review agent approved with no Must fix or Should fix items.
   - If fixes were applied and pushed, re-run the bundle build so it reflects the post-fix state. If step 2 was skipped, the existing bundle from step 1 is already current — skip the rebuild.

3. Once that completes, spawn the `test-reviewer` agent with: "Assess and update tests for PR #$ARGUMENTS. Use $PR=$ARGUMENTS throughout your instructions. A pre-fetched context bundle is available at $BUNDLE_DIR — read pr-meta.json, pr.diff, and files/ from there instead of fetching the PR or changed files yourself."

4. Once that completes, spawn the `requirements-reviewer` agent with: "Review PR #$ARGUMENTS and update PRODUCT_REQUIREMENTS_DOCUMENT.MD. Use $PR=$ARGUMENTS throughout your instructions. A pre-fetched context bundle is available at $BUNDLE_DIR — read pr-meta.json, pr.diff, and files/ from there instead of fetching the PR or changed files yourself. When you are done updating PRODUCT_REQUIREMENTS_DOCUMENT.MD, commit the file to the PR branch and push it before exiting."

5. Once that completes, spawn the `arch-reviewer` agent with: "Update architecture and data-model docs for PR #$ARGUMENTS. Use $PR=$ARGUMENTS throughout your instructions. A pre-fetched context bundle is available at $BUNDLE_DIR — read pr-meta.json, pr.diff, and files/ from there instead of fetching the PR or changed files yourself. When you are done updating ARCHITECTURE.MD and/or DATA_MODEL_AND_API.MD, commit any changed files to the PR branch and push them before exiting."

6. Once that completes, remove the bundle (`rm -rf "$BUNDLE_DIR"`) and tell the user: "All reviews are complete. Please run `/compact` to compact the conversation."

After all steps finish, print a one-line summary: "Full review of PR #$ARGUMENTS complete — code, tests, requirements, and architecture all updated."
