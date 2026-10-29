#!/usr/bin/env bash
# scripts/release-notes.sh — Markdown release notes for a tag
#
# Usage:
#   ./scripts/release-notes.sh v1.2            # changes from the previous v* tag to v1.2
#   ./scripts/release-notes.sh v1.2 v1.0       # changes from v1.0 to v1.2
#   ./scripts/release-notes.sh HEAD            # preview the next release
#
# Used by .github/workflows/release.yml as the GitHub release body. The notes are the
# version entries in the rbbedit header changelog that are new since the previous tag,
# followed by the commit subjects in that range. Written for the bash 3.2 that ships with macOS.

set -euo pipefail

TO="${1:?Usage: $0 <tag-or-ref> [previous-tag]}"
FROM="${2:-$(git describe --tags --abbrev=0 --match 'v*' "${TO}^" 2>/dev/null || true)}"
RANGE="${FROM:+${FROM}..}${TO}"

# Header changelog of rbbedit at a ref, one entry per line: "v1.2<TAB>text text ..."
changelog() {
  git show "$1:rbbedit" 2>/dev/null | awk '
    /^#-----/ { block++; next }
    block != 1 { next }
    /^# v[0-9]/ { if (entry != "") print entry
                  sub(/^# /, ""); ver = $1; sub(/^[^ ]+ +/, ""); entry = ver "\t" $0; next }
    /^# / { sub(/^# +/, ""); entry = entry "; " $0 }
    END { if (entry != "") print entry }'
}

OLD_VERSIONS=""
if [ -n "$FROM" ]; then
  OLD_VERSIONS=$(changelog "$FROM" | cut -f1)
fi

echo "## What's new"
echo
new=0
while IFS="$(printf '\t')" read -r ver text; do
  [ -n "$ver" ] || continue
  if printf '%s\n' "$OLD_VERSIONS" | grep -qxF "$ver"; then
    continue
  fi
  new=1
  printf -- '- **%s** %s\n' "$ver" "$text"
done <<< "$(changelog "$TO")"
[ "$new" = 1 ] || echo "No new entries in the rbbedit header changelog."

echo
if [ -n "$FROM" ]; then
  echo "## Commits since $FROM"
else
  echo "## Commits"
fi
echo
git log --no-merges --reverse --format='- %s (%h)' "$RANGE"
