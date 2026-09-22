#!/usr/bin/env bash
# Run the Apple KB scanner and refresh the generated section in docs/recent_apple_kbs.md
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
PAGE="$ROOT/docs/recent_apple_kbs.md"
SCANNER="$ROOT/scripts/Apple-KB-Scanner.sh"
DAYS="${1:-7}"
START_MARK="<!-- apple-kb-scanner:start -->"
END_MARK="<!-- apple-kb-scanner:end -->"

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
  echo "_Last scan: $(TZ=America/New_York date '+%b %d %Y %-I:%M %p %Z') — showing updates from the past $DAYS days._"
  echo ""

  if [[ ! -s "$TMP_TSV" ]]; then
    echo "_No Apple Support articles found in the last $DAYS days._"
  else
    echo "| Updated | Article |"
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

if grep -qF "$START_MARK" "$PAGE" && grep -qF "$END_MARK" "$PAGE"; then
  # Replace existing generated block
  awk -v start="$START_MARK" -v end="$END_MARK" -v blockfile="$TMP_MD" '
    BEGIN {
      while ((getline line < blockfile) > 0) {
        block = block line ORS
      }
      close(blockfile)
    }
    $0 == start { printf "%s", block; skip=1; next }
    $0 == end { skip=0; next }
    !skip { print }
  ' "$PAGE" >"$TMP_PAGE"
  mv "$TMP_PAGE" "$PAGE"
else
  # Append generated block under current page text
  {
    cat "$PAGE"
    echo ""
    cat "$TMP_MD"
  } >"$TMP_PAGE"
  mv "$TMP_PAGE" "$PAGE"
fi

echo "Updated $PAGE" >&2
