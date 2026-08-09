---
description: Run the full review chain on a PR — architecture review, code review, test review, and requirements review in sequence
argument-hint: <PR number>
---

If no PR number was provided in "$ARGUMENTS", stop and tell the user: "Usage: /full-review <PR number>"

Otherwise, run all four reviews in sequence for PR #$ARGUMENTS. Each review must fully complete before the next begins (they all write to files and must not run in parallel).

Set `PR=$ARGUMENTS` and `BUNDLE_DIR=/tmp/full-review-pr-$PR` throughout.

Architecture review runs *first*, not last: its critique findings are auto-applied (same treatment as code review's Must-fix/Should-fix items below), so whatever code change results from Doc's critique still gets a code-review and test-review pass afterward — instead of Doc's own suggested changes going out the door unreviewed, which is what running it last used to mean.

## Bundle build (run before step 1, and again after steps 2 and 4)

All four reviewers need the same PR metadata, diff, and changed-file contents. Instead of letting each one fetch it independently, build it once into a shared bundle and point each agent at it. Do not read the bundle's contents into your own context — just build it on disk by running the bundle-build script:

```bash
bash /Users/bindaas/.claude/scripts/build-review-bundle.sh "$PR" "$BUNDLE_DIR"
```

1. Run the bundle build above (pre-fix state). Spawn the `arch-reviewer` agent with: "Update architecture and data-model docs for PR #$ARGUMENTS. Use $PR=$ARGUMENTS throughout your instructions. A pre-fetched context bundle is available at $BUNDLE_DIR — read pr-meta.json, pr.diff, and files/ from there instead of fetching the PR or changed files yourself. When you are done updating ARCHITECTURE.MD and/or DATA_MODEL_AND_API.MD, commit any changed files to the PR branch and push them before exiting."

2. Once the architecture review completes, fetch the individual critique comments it posted to the PR and automatically apply every **stop-ship** and **recommend** item it identified (skip **nit**s). To do this:
   - Read `$BUNDLE_DIR/pr-meta.json` for the branch name (`headRefName`) — the branch is already checked out from the bundle build above.
   - Fetch Doc's critique comments via `gh pr view $ARGUMENTS --json comments` (Doc posts one comment per concern, each tagged `[stop-ship | recommend | nit] — <title>`, signed `— *Doc*`)
   - Make the code changes directly in the working tree
   - Commit and push to the PR branch. Include `[skip deploy]` in the commit message if no backend application files were changed — consult `RULES_OF_ENGAGEMENT.MD` for which paths trigger a deploy.
   - Do NOT ask the user for approval before applying fixes — just do it. Only pause if you hit a genuine ambiguity or conflict that makes you unsure what the correct fix should be (that is the "serious kerfuffle" threshold).
   - Skip this step entirely if Doc found zero stop-ship or recommend concerns.
   - If fixes were applied and pushed, re-run the bundle build so it reflects the post-fix state. If this step was skipped, the existing bundle from step 1 is already current (Doc's own doc commits, if any, don't require a rebuild before code review — they aren't code) — skip the rebuild.

3. Spawn the `code-reviewer` agent with: "Review PR #$ARGUMENTS. Use $PR=$ARGUMENTS throughout your instructions. A pre-fetched context bundle is available at $BUNDLE_DIR — read pr-meta.json, pr.diff, and files/ from there instead of fetching the PR or changed files yourself."

4. Once the code review completes, fetch the review it posted to the PR and automatically apply all **Must fix** and **Should fix** items it identified. To do this:
   - Read `$BUNDLE_DIR/pr-meta.json` for the branch name (`headRefName`) — the branch is already checked out from the bundle build above.
   - Read the review comment Dopey just posted (fetch via `gh pr view $ARGUMENTS --json reviews` or `gh api repos/:owner/:repo/pulls/$ARGUMENTS/reviews`)
   - Make the code changes directly in the working tree
   - Commit and push to the PR branch. Include `[skip deploy]` in the commit message if no backend application files were changed — consult `RULES_OF_ENGAGEMENT.MD` for which paths trigger a deploy.
   - Do NOT ask the user for approval before applying fixes — just do it. Only pause if you hit a genuine ambiguity or conflict that makes you unsure what the correct fix should be (that is the "serious kerfuffle" threshold).
   - Skip this step entirely if the code-review agent approved with no Must fix or Should fix items.
   - If fixes were applied and pushed, re-run the bundle build so it reflects the post-fix state. If step 4 was skipped, the existing bundle is already current — skip the rebuild.

5. Once that completes, spawn the `test-reviewer` agent with: "Assess and update tests for PR #$ARGUMENTS. Use $PR=$ARGUMENTS throughout your instructions. A pre-fetched context bundle is available at $BUNDLE_DIR — read pr-meta.json, pr.diff, and files/ from there instead of fetching the PR or changed files yourself."

6. Once that completes, spawn the `requirements-reviewer` agent with: "Review PR #$ARGUMENTS and update PRODUCT_REQUIREMENTS_DOCUMENT.MD. Use $PR=$ARGUMENTS throughout your instructions. A pre-fetched context bundle is available at $BUNDLE_DIR — read pr-meta.json, pr.diff, and files/ from there instead of fetching the PR or changed files yourself. When you are done updating PRODUCT_REQUIREMENTS_DOCUMENT.MD, commit the file to the PR branch and push it before exiting." (Runs last, not arch review — it documents "what was actually shipped," so it needs the truly final state, after every other review's fixes have landed.)

7. Once that completes, remove the bundle (`rm -rf "$BUNDLE_DIR"`) and tell the user: "All reviews are complete. Please run `/compact` to compact the conversation."

After all steps finish, print a one-line summary: "Full review of PR #$ARGUMENTS complete — architecture, code, tests, and requirements all updated."
