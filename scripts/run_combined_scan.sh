#!/usr/bin/env bash

set -euo pipefail

TARGET="${1:-examples}"
OUTPUT_FILE="results/combined-results.json"

mkdir -p results

set +e
semgrep scan \
  --config p/docker \
  --config rules/ \
  "$TARGET" \
  --no-git-ignore \
  --json \
  --output "$OUTPUT_FILE"
scan_exit=$?
set -e

if [[ "$scan_exit" -ne 0 && "$scan_exit" -ne 1 ]]; then
  echo "Combined scan failed with exit code $scan_exit." >&2
  exit "$scan_exit"
fi

echo "Combined scan completed."
echo "Results saved to: $OUTPUT_FILE"
