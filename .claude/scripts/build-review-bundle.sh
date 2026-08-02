#!/usr/bin/env bash
set -euo pipefail

PR="$1"
BUNDLE_DIR="$2"

gh pr checkout "$PR"
rm -rf "$BUNDLE_DIR" && mkdir -p "$BUNDLE_DIR/files"
gh pr view "$PR" --json title,body,author,baseRefName,headRefName,additions,deletions,changedFiles,state,mergedAt,files > "$BUNDLE_DIR/pr-meta.json"
gh pr diff "$PR" > "$BUNDLE_DIR/pr.diff"
jq -r '.files[].path' "$BUNDLE_DIR/pr-meta.json" > "$BUNDLE_DIR/changed-files.txt"
while IFS= read -r f; do
  if [ -f "$f" ]; then
    mkdir -p "$BUNDLE_DIR/files/$(dirname "$f")"
    cp "$f" "$BUNDLE_DIR/files/$f"
  fi
done < "$BUNDLE_DIR/changed-files.txt"
