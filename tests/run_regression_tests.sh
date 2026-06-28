#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

OUTPUT_FILE="tests/out/semgrep-results.json"
mkdir -p tests/out

semgrep --validate --config rules/

set +e
semgrep scan \
  --config rules/ \
  examples/ \
  --no-git-ignore \
  --json \
  --output "$OUTPUT_FILE"
scan_exit=$?
set -e

if [[ "$scan_exit" -ne 0 && "$scan_exit" -ne 1 ]]; then
  echo "Semgrep scan failed with exit code $scan_exit." >&2
  exit "$scan_exit"
fi

python3 - "$OUTPUT_FILE" <<'PY'
import json
import sys
from pathlib import Path

output_file = Path(sys.argv[1])

with output_file.open(encoding="utf-8") as handle:
    findings = json.load(handle)["results"]

expected = {
    ("bad.Dockerfile", "rules.dockerfile-latest-tag"),
    ("bad.Dockerfile", "rules.dockerfile-curl-pipe-shell"),
    ("bad.Dockerfile", "rules.dockerfile-copy-private-key"),
    ("bad.Dockerfile", "rules.dockerfile-copy-env-file"),

    ("bad-workflow.yml", "rules.github-actions-pull-request-target"),
    ("bad-workflow.yml", "rules.github-actions-write-all-permissions"),
    ("bad-workflow.yml", "rules.github-actions-unpinned-action-main"),
    ("bad-workflow.yml", "rules.github-actions-curl-pipe-shell"),
    ("bad-workflow.yml", "rules.github-actions-echo-secret"),

    ("bad-hardening.Dockerfile", "rules.dockerfile-user-root"),
    ("bad-hardening.Dockerfile", "rules.dockerfile-chmod-777"),
    ("bad-hardening.Dockerfile", "rules.dockerfile-apt-get-upgrade"),

    ("bad-hardening-workflow.yml", "rules.github-actions-self-hosted-runner"),
    ("bad-hardening-workflow.yml", "rules.github-actions-untrusted-pr-context-shell"),
    ("bad-hardening-workflow.yml", "rules.github-actions-docker-latest"),

    ("bad-compose.yml", "rules.docker-compose-privileged"),
    ("bad-compose.yml", "rules.docker-compose-docker-socket"),
    ("bad-compose.yml", "rules.docker-compose-host-network"),
}

actual = {
    (Path(item["path"]).name, item["check_id"])
    for item in findings
}

good_files = {
    "good.Dockerfile",
    "good-workflow.yml",
    "good-hardening.Dockerfile",
    "good-hardening-workflow.yml",
    "good-compose.yml",
}

good_file_findings = [
    (Path(item["path"]).name, item["check_id"])
    for item in findings
    if Path(item["path"]).name in good_files
]

missing = expected - actual
unexpected = actual - expected

if missing:
    print("Missing expected findings:")
    for item in sorted(missing):
        print(f"  {item}")
    sys.exit(1)

if unexpected:
    print("Unexpected findings:")
    for item in sorted(unexpected):
        print(f"  {item}")
    sys.exit(1)

if good_file_findings:
    print("Safe examples produced findings:")
    for item in sorted(good_file_findings):
        print(f"  {item}")
    sys.exit(1)

if len(findings) != len(expected):
    print(
        f"Expected {len(expected)} findings but received {len(findings)}."
    )
    sys.exit(1)

print(
    "Regression test passed: 18 expected findings and "
    "no findings in safe examples."
)
PY
