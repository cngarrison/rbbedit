#!/usr/bin/env bash
# scripts/release.sh — tag the version in the rbbedit header and push it to trigger CI release
#
# Usage:
#   ./scripts/release.sh
#
# Before running, add a changelog entry for the new version to the rbbedit header, e.g.
#   # v1.2 Short description of the change
#   #      Continuation lines indented to line up
# and commit it. This script then:
#   1. Reads the newest "# vX.Y" entry from the rbbedit header
#   2. Checks the working tree is clean, the branch, and that the tag doesn't exist
#   3. Shows the release notes and asks for confirmation
#   4. Creates an annotated tag vX.Y and pushes the branch and tag to origin
#      → triggers .github/workflows/release.yml

set -euo pipefail

if [ ! -f rbbedit ]; then
  echo "❌  rbbedit not found. Run this script from the repo root."
  exit 1
fi

if ! git diff --quiet || ! git diff --cached --quiet; then
  echo "❌  Working tree is dirty. Commit your changes (including the header changelog) first."
  exit 1
fi

CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
DEFAULT_BRANCH=$(git symbolic-ref --quiet --short refs/remotes/origin/HEAD 2>/dev/null | sed 's|^origin/||')
DEFAULT_BRANCH="${DEFAULT_BRANCH:-main}"
if [[ "$CURRENT_BRANCH" != "$DEFAULT_BRANCH" ]]; then
  echo "⚠️   You are on branch '$CURRENT_BRANCH', not $DEFAULT_BRANCH."
  read -r -p "Continue anyway? [y/N] " CONFIRM
  [[ "$CONFIRM" =~ ^[Yy]$ ]] || exit 0
fi

TAG=$(sed -n 's/^# \(v[0-9][0-9.]*\) .*/\1/p' rbbedit | tail -1)
if [ -z "$TAG" ]; then
  echo "❌  No '# vX.Y' changelog entry found in the rbbedit header."
  exit 1
fi

if git rev-parse -q --verify "refs/tags/$TAG" >/dev/null; then
  echo "❌  Tag $TAG already exists. Add a changelog entry for the new version to the rbbedit header."
  exit 1
fi

sh -n rbbedit || { echo "❌  rbbedit has syntax errors."; exit 1; }

echo ""
./scripts/release-notes.sh HEAD
echo ""
echo "  Tag : ${TAG}"
echo ""
read -r -p "Tag and push ${TAG}? [y/N] " CONFIRM
[[ "$CONFIRM" =~ ^[Yy]$ ]] || { echo "Aborted."; exit 0; }

git tag -a "$TAG" -m "Release ${TAG}"
echo "✓ Tagged ${TAG}"

git push origin HEAD
git push origin "$TAG"

echo ""
echo "✅  ${TAG} pushed — GitHub Actions release workflow triggered."
echo "   https://github.com/$(git remote get-url origin | sed 's/.*github.com[:/]//;s/\.git$//')/actions"
