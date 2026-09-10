#!/usr/bin/env bash

# Version 1.3 | Updated for CI (BSD + GNU date)
# Based on Apple-KB-Scanner.sh — scans Apple Support KB for recent articles
# Can take around 3 minutes to run

set -euo pipefail

USER_AGENT="Mozilla/5.0 apple-support-scanner"
PAUSE_SEC=0.05
DAYS_BACK=14
DEBUG=0
# Parallel fetches per batch (same host); results are applied in ID order so behavior matches sequential scan.
BATCH_SIZE="${BATCH_SIZE:-20}"

usage() {
cat <<EOF
Usage: Apple-KB-Scanner.sh [--debug] [--days N] [--pause SEC]
  BATCH_SIZE=N in the environment sets parallel requests per batch (default 20).
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --debug) DEBUG=1; shift ;;
    --days) DAYS_BACK="${2:-}"; shift 2 ;;
    --pause) PAUSE_SEC="${2:-}"; shift 2 ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown arg: $1" >&2; exit 1 ;;
  esac
done

[[ "$DAYS_BACK" =~ ^[0-9]+$ ]] || { echo "Invalid --days"; exit 1; }

is_bsd_date() {
  date -v-1d +%s >/dev/null 2>&1
}

if is_bsd_date; then
  CUTOFF_EPOCH="$(date -v-"$DAYS_BACK"d +%s)"
else
  CUTOFF_EPOCH="$(date -d "$DAYS_BACK days ago" +%s)"
fi

debug() { ((DEBUG)) && echo "[debug] $*" >&2; }

epoch_iso() {
  local s="${1/Z/+0000}"
  s="$(sed 's/\([+-][0-9][0-9]\):\([0-9][0-9]\)$/\1\2/' <<<"$s")"
  if is_bsd_date; then
    date -j -f "%Y-%m-%dT%H:%M:%S%z" "$s" +%s 2>/dev/null \
    || date -j -f "%Y-%m-%d" "$s" +%s 2>/dev/null
  else
    date -d "$1" +%s 2>/dev/null || date -d "${1:0:10}" +%s 2>/dev/null
  fi
}

format_date() {
  if is_bsd_date; then
    date -r "$1" "+%b %d %Y"
  else
    date -d "@$1" "+%b %d %Y"
  fi
}

extract_title() {
  sed -nE 's:.*<title[^>]*>([^<]+)</title>.*:\1:ip' | head -n1
}

extract_dates() {
  sed -nE '
    s/.*"dateModified"[[:space:]]*:[[:space:]]*"([^"]+)".*/\1/p
    s/.*property="article:modified_time"[[:space:]]*content="([^"]+)".*/\1/p
    s/.*name="last-modified"[[:space:]]*content="([^"]+)".*/\1/p
    s/.*"datePublished"[[:space:]]*:[[:space:]]*"([^"]+)".*/\1/p
  '
}

extract_human_date() {
  sed -nE 's/.*Published Date:[[:space:]]*([A-Za-z]+ [0-9]+, [0-9]{4}).*/\1/p' | head -n1
}

human_to_iso() {
  local m d y
  read -r m d y <<<"$1"
  d="${d%,}"
  case "$(printf '%s' "$m" | tr '[:upper:]' '[:lower:]')" in
    january) m=01;; february) m=02;; march) m=03;; april) m=04;;
    may) m=05;; june) m=06;; july) m=07;; august) m=08;;
    september) m=09;; october) m=10;; november) m=11;; december) m=12;;
    *) return 1;;
  esac
  printf "%s-%02d-%02d\n" "$y" "$m" "$d"
}

epoch_http() {
  # Example: Tue, 19 Mar 2026 17:41:23 GMT
  local s="$1"
  s="$(printf '%s' "$s" | tr -d '\r')"

  if is_bsd_date; then
    date -j -f "%a, %d %b %Y %H:%M:%S %Z" "$s" +%s 2>/dev/null || \
    date -j -f "%a, %d %b %Y %H:%M:%S %z" "$s" +%s 2>/dev/null
  else
    date -d "$s" +%s 2>/dev/null
  fi
}

# 0 = printed a row; 1 = no recent date or HTTP error
process_fetched() {
  local url="$1" headers="$2" body="$3" code="$4"
  local body1 title lm human iso epoch d

  [[ "$code" =~ ^[0-9]+$ ]] || return 1
  ((code < 400)) || { debug "$url -> HTTP $code"; return 1; }

  body1="$(tr '\n' ' ' <<<"$body")"

  title="$(extract_title <<<"$body1")"
  [[ -z "$title" ]] && title="(no title)"

  while read -r d; do
    if epoch="$(epoch_iso "$d")" && (( epoch >= CUTOFF_EPOCH )); then
      printf "%s\t%s\tLast Updated\t%s\t%s\n" \
        "$epoch" "$url" "$(format_date "$epoch")" "$title"
      return 0
    fi
  done < <(extract_dates <<<"$body1")

  lm="$(sed -n 's/^[Ll]ast-[Mm]odified:[[:space:]]*//p' <<<"$headers" | tr -d '\r' | tail -n1)"
  if [[ -n "$lm" ]]; then
    if epoch="$(epoch_http "$lm")" && (( epoch >= CUTOFF_EPOCH )); then
      printf "%s\t%s\tLast Updated\t%s\t%s\n" \
        "$epoch" "$url" "$(format_date "$epoch")" "$title"
      return 0
    fi
  fi

  human="$(extract_human_date <<<"$body1")"
  if [[ -n "$human" ]]; then
    if iso="$(human_to_iso "$human")"; then
      if epoch="$(epoch_iso "$iso")" && (( epoch >= CUTOFF_EPOCH )); then
        printf "%s\t%s\tLast Updated\t%s\t%s\n" \
          "$epoch" "$url" "$(format_date "$epoch")" "$title"
        return 0
      fi
    fi
  fi

  debug "$url -> no recent date"
  return 1
}

run_curl_slot() {
  local url="$1" hdr="$2" body="$3" codef="$4"
  local c
  c="$(curl -sSL --compressed -A "$USER_AGENT" \
    --connect-timeout 6 --max-time 15 \
    -D "$hdr" -o "$body" -w "%{http_code}" "$url" 2>/dev/null || echo 000)"
  printf '%s' "$c" >"$codef"
}

scan() {
  local base="$1" start="$2" limit="$3"
  local id="$start" bad=0 url i batch_dir code headers body

  while ((bad < limit)); do
    # ~same total delay as sequential (pause per attempted ID), without sleeping inside each parallel slot
    sleep "$(awk -v p="$PAUSE_SEC" -v b="$BATCH_SIZE" 'BEGIN { printf "%.4f\n", p * b }')"

    batch_dir="$(mktemp -d "${TMPDIR:-/tmp}/akbscan.XXXXXX")"
    for ((i = 1; i <= BATCH_SIZE; i++)); do
      ((id++))
      printf -v url "$base" "$id"
      printf '%s' "$url" >"$batch_dir/url.$i"
      run_curl_slot "$url" "$batch_dir/hdr.$i" "$batch_dir/body.$i" "$batch_dir/code.$i" &
    done
    wait

    for ((i = 1; i <= BATCH_SIZE; i++)); do
      ((bad >= limit)) && break
      url="$(<"$batch_dir/url.$i")"
      code="$(<"$batch_dir/code.$i")"
      headers="$(<"$batch_dir/hdr.$i")"
      body="$(<"$batch_dir/body.$i")"
      if process_fetched "$url" "$headers" "$body" "$code"; then
        bad=0
      else
        bad=$((bad + 1))
      fi
    done

    rm -rf "$batch_dir"
  done
}

{
  scan "https://support.apple.com/en-us/HT%d" 213220 250
  scan "https://support.apple.com/kb/DL%d?viewlocale=en_US&locale=en_US" 1944 50
} |
sort -t $'\t' -k1,1nr |
cut -f2-
