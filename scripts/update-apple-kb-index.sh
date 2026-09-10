#!/usr/bin/env bash
# Run the Apple KB scanner and refresh the generated section in index.md
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
INDEX="$ROOT/index.md"
SCANNER="$ROOT/scripts/Apple-KB-Scanner.sh"
DAYS="${1:-7}"
START_MARK="<!-- apple-kb-scanner:start -->"
END_MARK="<!-- apple-kb-scanner:end -->"

if [[ ! -f "$INDEX" ]]; then
  echo "Missing $INDEX" >&2
  exit 1
fi

chmod +x "$SCANNER"

echo "Scanning Apple KB for articles from the last $DAYS days..." >&2
TMP_TSV="$(mktemp)"
TMP_MD="$(mktemp)"
TMP_INDEX="$(mktemp)"
trap 'rm -f "$TMP_TSV" "$TMP_MD" "$TMP_INDEX"' EXIT

"$SCANNER" --days "$DAYS" >"$TMP_TSV"

{
  echo "$START_MARK"
  echo "## Recent Apple Knowledge Base articles"
  echo ""
  echo "_Last scan: $(date '+%b %d %Y %H:%M %Z') — showing updates from the past $DAYS days._"
  echo ""

  if [[ ! -s "$TMP_TSV" ]]; then
    echo "_No Apple Support articles found in the last $DAYS days._"
  else
    echo "| Updated | Article |"
    echo "| --- | --- |"
    while IFS=$'\t' read -r url _label updated title; do
      [[ -z "${url:-}" ]] && continue
      # Escape pipes in titles for markdown tables
      safe_title="${title//|/\\|}"
      echo "| $updated | [$safe_title]($url) |"
    done <"$TMP_TSV"
  fi
  echo ""
  echo "$END_MARK"
} >"$TMP_MD"

if grep -qF "$START_MARK" "$INDEX" && grep -qF "$END_MARK" "$INDEX"; then
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
  ' "$INDEX" >"$TMP_INDEX"
  mv "$TMP_INDEX" "$INDEX"
else
  # Append generated block under current page text
  {
    cat "$INDEX"
    echo ""
    cat "$TMP_MD"
  } >"$TMP_INDEX"
  mv "$TMP_INDEX" "$INDEX"
fi

echo "Updated $INDEX" >&2
