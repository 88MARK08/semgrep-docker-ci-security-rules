# Lightweight Dockerfile and CI/CD Security Ruleset Using Semgrep

## Overview

This repository provides a lightweight Semgrep ruleset for identifying common security issues in:

- Dockerfiles
- GitHub Actions workflows
- Docker Compose files

The rules are intended for quick repository-level reviews, local development checks, and CI/CD validation. They focus on risky configuration patterns that can weaken container, workflow, or supply-chain security.

This project does not replace mature security tools such as Semgrep Registry rules, Hadolint, Trivy, Docker Scout, or image-vulnerability scanners. Instead, it provides a small, readable, and customizable collection of focused checks.

## Security Problems Addressed

Dockerfiles, CI/CD workflows, and Compose files are part of the software supply chain. Insecure configuration can create risk before an application is deployed.

Examples of risky patterns include:

- Using an unpinned Docker image such as `ubuntu:latest`
- Piping remote scripts directly into `bash` or `sh`
- Copying private keys or `.env` files into an image
- Running containers explicitly as `root`
- Using `chmod 777`
- Running `apt-get upgrade` inside a Dockerfile
- Using `pull_request_target` workflows without careful review
- Granting GitHub Actions `write-all` permissions
- Printing secrets in CI logs
- Using unpinned GitHub Actions
- Running jobs on self-hosted runners
- Passing pull-request data directly into shell commands
- Running privileged Docker Compose services
- Mounting the Docker socket inside a container
- Using Docker Compose host networking

## Repository Structure

```text
semgrep-docker-ci-security-rules/
├── .github/
│   └── workflows/
│       └── rules-regression.yml
├── examples/
│   ├── bad.Dockerfile
│   ├── good.Dockerfile
│   ├── bad-workflow.yml
│   ├── good-workflow.yml
│   ├── bad-hardening.Dockerfile
│   ├── good-hardening.Dockerfile
│   ├── bad-hardening-workflow.yml
│   ├── good-hardening-workflow.yml
│   ├── bad-compose.yml
│   └── good-compose.yml
├── rules/
│   ├── dockerfile-security.yml
│   ├── dockerfile-hardening.yml
│   ├── github-actions-security.yml
│   ├── github-actions-hardening.yml
│   └── docker-compose-security.yml
├── scripts/
│   └── run_combined_scan.sh
├── tests/
│   ├── out/
│   └── run_regression_tests.sh
├── results/
├── .gitignore
└── README.md
```

## Installation

Clone the repository:

```bash
git clone https://github.com/88MARK08/semgrep-docker-ci-security-rules.git
cd semgrep-docker-ci-security-rules
```

Create and activate a dedicated Python virtual environment:

```bash
python3 -m venv .venv
source .venv/bin/activate
```

Install Semgrep:

```bash
python -m pip install --upgrade pip
python -m pip install semgrep
semgrep --version
```

When returning to the project later, reactivate the environment:

```bash
source .venv/bin/activate
```

## Rules Implemented

The repository contains 20 custom Semgrep rules.

### Dockerfile Security Rules

| Rule ID | Severity | Detects |
|---|---:|---|
| `dockerfile-latest-tag` | Warning | Base images using the `latest` tag |
| `dockerfile-curl-pipe-shell` | Error | `curl` piped directly into `bash` or `sh` |
| `dockerfile-wget-pipe-shell` | Error | `wget` piped directly into `bash` or `sh` |
| `dockerfile-copy-private-key` | Error | Private keys such as `id_rsa` copied into an image |
| `dockerfile-copy-env-file` | Error | `.env` files copied into an image |
| `dockerfile-add-remote-url` | Warning | Remote URLs used with Dockerfile `ADD` |

### Dockerfile Hardening Rules

| Rule ID | Severity | Detects |
|---|---:|---|
| `dockerfile-user-root` | Error | Explicit `USER root` |
| `dockerfile-chmod-777` | Warning | `chmod 777` or `chmod -R 777` |
| `dockerfile-apt-get-upgrade` | Warning | `apt-get upgrade` in Dockerfiles |

### GitHub Actions Security Rules

| Rule ID | Severity | Detects |
|---|---:|---|
| `github-actions-pull-request-target` | Error | `pull_request_target` trigger |
| `github-actions-write-all-permissions` | Error | `permissions: write-all` |
| `github-actions-unpinned-action-main` | Warning | Actions pinned to `main`, `master`, or `latest` |
| `github-actions-curl-pipe-shell` | Error | `curl` piped into a shell command |
| `github-actions-echo-secret` | Error | Secrets printed in workflow logs |

### GitHub Actions Hardening Rules

| Rule ID | Severity | Detects |
|---|---:|---|
| `github-actions-self-hosted-runner` | Warning | Use of a self-hosted runner |
| `github-actions-untrusted-pr-context-shell` | Error | Pull-request title, body, or branch data passed to a shell command |
| `github-actions-docker-latest` | Warning | Docker-based Actions using the `latest` tag |

### Docker Compose Security Rules

| Rule ID | Severity | Detects |
|---|---:|---|
| `docker-compose-privileged` | Error | `privileged: true` |
| `docker-compose-docker-socket` | Error | Docker socket mounted into a container |
| `docker-compose-host-network` | Warning | `network_mode: host` |

## Quick Start

Validate all custom rules:

```bash
semgrep --validate --config rules/
```

Run the full scan against all examples:

```bash
semgrep scan \
  --config rules/ \
  examples/ \
  --no-git-ignore
```

Generate JSON output:

```bash
mkdir -p results

semgrep scan \
  --config rules/ \
  examples/ \
  --no-git-ignore \
  --json \
  --output results/full-results.json
```

To display the JSON findings in a readable format, use `jq`:

```bash
jq -r '.results[] | "\(.check_id)\t\(.path):\(.start.line)"' \
  results/full-results.json
```

## Regression Testing

The regression suite validates all 20 rules and scans 10 intentionally safe or unsafe fixtures.

Run:

```bash
./tests/run_regression_tests.sh
```

Expected result:

```text
Configuration is valid - found 0 configuration error(s), and 20 rule(s).
Ran 20 rules on 10 files: 18 findings.
Regression test passed: 18 expected findings and no findings in safe examples.
```

The test confirms that:

- All expected findings appear in intentionally unsafe examples.
- Safer examples produce no findings.
- No unexpected findings appear.
- The expected number of findings remains stable at 18.

## Focused Rule Tests

Test the Dockerfile hardening rules against the unsafe Dockerfile:

```bash
semgrep scan \
  --config rules/dockerfile-hardening.yml \
  examples/bad-hardening.Dockerfile \
  --no-git-ignore
```

Expected result: 3 findings for:

```text
dockerfile-apt-get-upgrade
dockerfile-chmod-777
dockerfile-user-root
```

Test the safe Dockerfile:

```bash
semgrep scan \
  --config rules/dockerfile-hardening.yml \
  examples/good-hardening.Dockerfile \
  --no-git-ignore
```

Expected result:

```text
Findings: 0
```

Test the unsafe GitHub Actions hardening example:

```bash
semgrep scan \
  --config rules/github-actions-hardening.yml \
  examples/bad-hardening-workflow.yml \
  --no-git-ignore
```

Test the unsafe Docker Compose example:

```bash
semgrep scan \
  --config rules/docker-compose-security.yml \
  examples/bad-compose.yml \
  --no-git-ignore
```

## Combined Scan With Semgrep Registry Rules

The project includes an optional combined scan that runs both this repository's custom rules and Semgrep's Docker registry rules.

Run:

```bash
scripts/run_combined_scan.sh examples
```

The output is saved to:

```text
results/combined-results.json
```

View the results:

```bash
jq -r '.results[] | "\(.check_id)\t\(.path):\(.start.line)"' \
  results/combined-results.json
```

The custom regression suite intentionally does not assert an exact finding count for the combined scan because Semgrep Registry rules may change over time.

## GitHub Actions CI

The repository includes a GitHub Actions workflow:

```text
.github/workflows/rules-regression.yml
```

The workflow runs on pushes and pull requests. It:

1. Checks out the repository.
2. Sets up Python 3.12.
3. Installs Semgrep.
4. Validates the custom rules.
5. Runs the regression test suite.

This helps prevent rule changes from silently removing expected detections or introducing unexpected findings.

## Evaluation Results

Version 2 was tested locally with Semgrep.

| Metric | Result |
|---|---:|
| Custom rules validated | 20 |
| Configuration errors | 0 |
| Test fixtures scanned | 10 |
| Expected findings | 18 |
| Findings in safer examples | 0 |

The unsafe Dockerfile hardening fixture correctly triggered findings for:

- `apt-get upgrade`
- `chmod 777`
- `USER root`

The safer Dockerfile, GitHub Actions, and Docker Compose fixtures each produced zero findings under their corresponding hardening rules.

## Limitations

This project uses lightweight Semgrep pattern matching and does not fully interpret Dockerfile, Docker Compose, or GitHub Actions semantics.

Current limitations include:

- Complex multi-line patterns may not be detected.
- Some unusual configurations may create false positives.
- The rules do not scan built container images.
- The rules do not identify package vulnerabilities.
- The rules do not replace mature container or dependency scanning tools.
- A finding should be reviewed in context before making a security decision.

## Future Improvements

Possible future work includes:

- Additional Dockerfile, Docker Compose, and GitHub Actions rules.
- Tests against larger open-source repositories.
- Rule categories or severity filters.
- A simple user interface for selecting rule groups.
- Additional CI integrations and report formats.
- Comparison studies with broader Semgrep Registry coverage.

## Semgrep Resources

- [Semgrep Documentation](https://docs.semgrep.dev/)
- [Writing Semgrep Rules](https://docs.semgrep.dev/writing-rules/overview)
- [Testing Semgrep Rules](https://docs.semgrep.dev/writing-rules/testing-rules)
- [Semgrep Registry](https://semgrep.dev/explore)
- [Semgrep GitHub Repository](https://github.com/semgrep/semgrep)

## Declaration of Generative AI Usage

ChatGPT was used during development for grammar refinement, documentation editing, and the creation of synthetic test examples. All generated material was reviewed, revised, and validated by the author. The author is responsible for the final design, implementation, testing, and submission.

## Author

Markjoe Uba
