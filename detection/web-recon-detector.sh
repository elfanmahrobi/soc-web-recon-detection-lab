#!/usr/bin/env bash
set -euo pipefail

LOG_FILE="${1:-/var/log/apache2/access.log}"
THRESHOLD="${THRESHOLD:-10}"

if [[ ! -r "$LOG_FILE" ]]; then
  echo "Error: cannot read log file: $LOG_FILE" >&2
  exit 1
fi

if ! [[ "$THRESHOLD" =~ ^[1-9][0-9]*$ ]]; then
  echo "Error: THRESHOLD must be a positive integer" >&2
  exit 1
fi

echo "Web reconnaissance summary"
echo "Log file: $LOG_FILE"
echo "Threshold: $THRESHOLD requests"
echo

awk -v threshold="$THRESHOLD" '
{
  ip=$1
  status=$9
  request=$7
  count[ip]++
  if (status == "404") notfound[ip]++
  if (request ~ /(\/admin|\/login|\/backup|\/\.env|\/\.git|\/phpmyadmin)/) sensitive[ip]++
}
END {
  printf "%-18s %10s %10s %12s %10s\n", "SOURCE", "REQUESTS", "HTTP_404", "SENSITIVE", "RESULT"
  for (ip in count) {
    result=(count[ip] >= threshold || notfound[ip] >= threshold || sensitive[ip] > 0) ? "REVIEW" : "BASELINE"
    printf "%-18s %10d %10d %12d %10s\n", ip, count[ip], notfound[ip]+0, sensitive[ip]+0, result
  }
}' "$LOG_FILE" | sort
