#!/usr/bin/env bash
# leak-scan.sh — pre-publish guard for the Mosaik framework repo.
#
# Greps the repo for known private-information patterns that should NEVER land
# in the public repo (operator's name + identifiers, business names, private
# repo names, internal paths, internal IPs, personal email addresses).
#
# Exit 0 = clean. Exit 1 = leaks found (printed to stdout).
#
# Run manually: ./scripts/leak-scan.sh
# Or via the pre-push hook (see hooks/pre-push and § Hook setup in README.md).
#
# Patterns are inline below — edit as the leak surface evolves.

set -euo pipefail

# Resolve repo root from script location
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

# Directories to skip — the scanner shouldn't flag its own pattern listing
SKIP_DIRS=(
  "scripts"
  "hooks"
  ".git"
  "node_modules"
)

# File globs to scan (markdown + any docs)
SCAN_GLOBS=(
  "*.md"
  "*.markdown"
  "*.txt"
)

# Pattern groups — extend as you discover new leak surfaces
declare -a PATTERN_GROUPS=(
  "Personal names|\\bonur\\b|kabadayi|leofloa"
  "Business names|\\bmedumio\\b|viktilabs|veda360|curivo"
  "Stakeholder names|\\bchristian\\b|\\bleon\\b|\\bmichael\\b|\\bmiriam\\b|\\bstephi\\b|frank diedrichkeit|robert gerlach|\\bmathias\\b|\\bsascha\\b|\\bandrea\\b|\\bkatja\\b|\\bphilipp\\b"
  "Private repo names|medumio-ai|medumio-double-check|medumio-customer|\\bcall-me\\b|dictate-android|apsara-guard|villaops|meeting-translator|tbbmz1907"
  "Internal paths|/Users/leofloa|/home/vbox|~/medumio|~/apsara|~/utopia|~/admin|~/general"
  "Internal IPs / Tailscale|100\\.107\\.|100\\.98\\.|192\\.168\\."
  "Personal email + domains|@onyp\\.com|ok@onyp|onur\\.kabadayi"
)

# Build a -exclude-dir argument list for grep
EXCLUDE_ARGS=()
for d in "${SKIP_DIRS[@]}"; do
  EXCLUDE_ARGS+=("--exclude-dir=$d")
done

# Build an --include argument list
INCLUDE_ARGS=()
for g in "${SCAN_GLOBS[@]}"; do
  INCLUDE_ARGS+=("--include=$g")
done

LEAK_COUNT=0
LEAK_REPORT=""

for group_spec in "${PATTERN_GROUPS[@]}"; do
  # Split "Label|pattern1|pattern2|..." on '|'
  IFS='|' read -ra parts <<<"$group_spec"
  label="${parts[0]}"
  patterns=("${parts[@]:1}")

  # Join patterns with | for grep -E
  alternation="$(IFS='|'; echo "${patterns[*]}")"

  # Run grep; capture matches (-n line numbers, -I skip binary)
  if matches="$(grep -rEinI "${EXCLUDE_ARGS[@]}" "${INCLUDE_ARGS[@]}" "$alternation" . 2>/dev/null)"; then
    LEAK_COUNT=$((LEAK_COUNT + $(printf '%s' "$matches" | grep -c .)))
    LEAK_REPORT+=$'\n'"--- $label ---"$'\n'"$matches"$'\n'
  fi
done

if [[ $LEAK_COUNT -gt 0 ]]; then
  echo "leak-scan: FAIL — $LEAK_COUNT match(es) found across patterns the public repo should not contain:" >&2
  printf '%s\n' "$LEAK_REPORT" >&2
  echo "" >&2
  echo "Fix the matches above before publishing. If a match is intentional (rule documenting" >&2
  echo "what NOT to do, e.g., methodology text quoting the patterns), reword to avoid the literal" >&2
  echo "trigger string OR move the rule discussion into scripts/ or hooks/ (excluded from scan)." >&2
  exit 1
fi

echo "leak-scan: PASS — no private-information patterns found."
exit 0
