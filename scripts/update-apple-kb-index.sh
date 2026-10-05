#!/usr/bin/env bash
# Run the Apple KB scanner and refresh docs/apple-kbs.md.
# Release-note links stay at the top; scanned articles are written underneath.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
PAGE="$ROOT/docs/apple-kbs.md"
SCANNER="$ROOT/scripts/Apple-KB-Scanner.sh"
DAYS="${1:-7}"
START_MARK="<!-- apple-kb-scanner:start -->"
END_MARK="<!-- apple-kb-scanner:end -->"

# Static section. Kept above the generated scanner block on every run.
LINKS_BLOCK=$(cat <<'EOF'
## OS Enterprise and Public Release Notes:

<br>

All [Apple security](https://support.apple.com/en-us/100100) release notes

[What's new for enterprise in macOS Tahoe 26](https://support.apple.com/en-us/124963)

[What's new for enterprise in macOS Golden Gate 27](https://support.apple.com/en-us/148830)

[What's new for enterprise in iPadOS 27](https://support.apple.com/en-us/148829)

[What's new for enterprise in iOS](https://support.apple.com/en-us/148828)

[What's new in the updates for macOS Tahoe 26](https://support.apple.com/en-us/122868)

[What's new in the updates for macOS Golden Gate 27](https://support.apple.com/en-us/127257)

<br>
EOF
)

if [[ ! -f "$PAGE" ]]; then
  echo "Missing $PAGE" >&2
  exit 1
fi

chmod +x "$SCANNER"

echo "Scanning Apple KB for articles from the last $DAYS days..." >&2
TMP_TSV="$(mktemp)"
TMP_MD="$(mktemp)"
TMP_PAGE="$(mktemp)"
trap 'rm -f "$TMP_TSV" "$TMP_MD" "$TMP_PAGE"' EXIT

"$SCANNER" --days "$DAYS" >"$TMP_TSV"

{
  echo "$START_MARK"
  echo "## Recent Apple Knowledge Base articles"
  echo ""
  echo "_Last scan: $(TZ=America/New_York date '+%b %d %Y %-I:%M %p %Z') - showing updates from the past $DAYS days._"
  echo ""

  if [[ ! -s "$TMP_TSV" ]]; then
    echo "_No Apple Support articles found in the last $DAYS days._"
  else
    echo "| Updated | Article Title |"
    echo "| --- | --- |"
    while IFS=$'\t' read -r url _label updated title; do
      [[ -z "${url:-}" ]] && continue
      # Escape HTML entities in titles for safe links
      safe_title="${title//&/&amp;}"
      safe_title="${safe_title//</&lt;}"
      safe_title="${safe_title//>/&gt;}"
      safe_title="${safe_title//\"/&quot;}"
      safe_title="${safe_title//|/\\|}"
      echo "| $updated | <a href=\"$url\" target=\"_blank\" rel=\"noopener noreferrer\">$safe_title</a> |"
    done <"$TMP_TSV"
  fi
  echo ""
  echo "$END_MARK"
} >"$TMP_MD"

# Keep the existing front matter, then the release-note links, then the scan.
FRONT_MATTER="$(
  awk '
    NR == 1 && $0 == "---" { infront = 1 }
    infront { print }
    infront && NR > 1 && $0 == "---" { exit }
  ' "$PAGE"
)"

{
  if [[ -n "$FRONT_MATTER" ]]; then
    printf '%s\n\n' "$FRONT_MATTER"
  fi
  printf '%s\n\n' "$LINKS_BLOCK"
  cat "$TMP_MD"
} >"$TMP_PAGE"
mv "$TMP_PAGE" "$PAGE"

echo "Updated $PAGE" >&2
