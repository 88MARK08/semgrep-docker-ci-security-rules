# Lightweight Dockerfile and CI/CD Security Ruleset Using Semgrep

## Overview

This security tool extends Semgrep with a lightweight custom ruleset for identifying insecure Dockerfiles and GitHub Actions CI/CD patterns.

The tool scans container build files and CI/CD workflow files for common security issues such as use of the `latest` Docker tag, unsafe `curl | bash` commands, copying secrets into container images, dangerous GitHub Actions triggers, overly broad workflow permissions, and unpinned GitHub Actions.

## Problem Definition

Modern software systems commonly rely on Dockerfiles and CI/CD workflows. These files are often treated as configuration files, but insecure choices inside them can create real security risks.

This security tool addresses the problem of insecure container and CI/CD configuration by providing Semgrep rules that detect risky patterns early in development.

## Why This Problem Is Important

Dockerfiles and CI/CD workflows are part of the software supply chain. If they are misconfigured, they can introduce vulnerabilities before the application is even deployed.

Examples include:

- Using `ubuntu:latest`, which makes builds less reproducible
- Running remote scripts with `curl | bash`
- Copying private keys or `.env` files into container images
- Using `pull_request_target` in GitHub Actions
- Giving workflows `write-all` permissions
- Printing secrets into CI logs
- Pinning actions to `main` instead of a stable version or commit SHA

Detecting these issues early helps developers improve software supply-chain security.

## Existing Tools and Gap Filled

Tools such as Hadolint, Trivy, Docker Scout, and Semgrep already provide mature security scanning and linting capabilities. This tool does not attempt to replace them. Instead, it builds on Semgrep by providing a focused ruleset for selected Dockerfile and GitHub Actions risks.

Many scanners are broad and powerful, but quick repository-level reviews sometimes need a smaller and easier-to-customize set of checks. This tool focuses on high-impact patterns such as unsafe remote script execution, copied secrets, overly broad workflow permissions, and unpinned actions.

Because the rules are written in readable Semgrep YAML, they can be reviewed, modified, and extended quickly. This makes the tool useful for lightweight DevSecOps checks, pre-deployment reviews, and custom supply-chain security policy enforcement.

## System Design

The security tool has the following repository structure:

```text
semgrep-docker-ci-security-rules/
├── rules/
│   ├── dockerfile-security.yml
│   └── github-actions-security.yml
├── examples/
│   ├── bad.Dockerfile
│   ├── good.Dockerfile
│   ├── bad-workflow.yml
│   └── good-workflow.yml
├── results/
│   ├── dockerfile-results.json
│   └── full-results.json
└── README.md
```

The tool works by applying Semgrep custom rules to Dockerfile and GitHub Actions workflow examples. The rules detect risky patterns and report the file, line number, rule ID, severity, and explanation.

## Technology Choices

This security tool uses Semgrep because it is an open-source static analysis tool that supports custom YAML rules. Semgrep is appropriate for this tool because it can scan source code and configuration files using user-defined rules.

The custom rules are written in YAML and use Semgrep's generic pattern matching mode. This makes the rules suitable for scanning Dockerfiles and GitHub Actions workflow files.

The tool also supports JSON output, which makes the results easier to save, review, and integrate into automated workflows.

## Rules Implemented

### Dockerfile Rules

The Dockerfile rules detect:

- Use of the `latest` tag in a base image
- Use of `curl | bash` or `curl | sh`
- Use of `wget | bash` or `wget | sh`
- Copying private keys such as `id_rsa`
- Copying `.env` files into the image
- Using `ADD` with a remote URL

### GitHub Actions Rules

The GitHub Actions rules detect:

- Use of `pull_request_target`
- Use of `permissions: write-all`
- Use of unpinned actions such as `actions/checkout@main`
- Use of `curl | bash` inside workflow steps
- Printing secrets into CI logs

## Quick Reproduction Steps

To reproduce the results from this security tool, run the following commands.

### 1. Clone the repository

```bash
git clone https://github.com/88MARK08/semgrep-docker-ci-security-rules.git
cd semgrep-docker-ci-security-rules
```

### 2. Install Semgrep

Recommended method:

```bash
pipx install semgrep
semgrep --version
```

If `pipx` does not work, use a Python virtual environment:

```bash
python3 -m venv semgrep-env
source semgrep-env/bin/activate
python -m pip install --upgrade pip setuptools wheel --default-timeout=120 --retries=10
python -m pip install semgrep --prefer-binary --default-timeout=120 --retries=10
semgrep --version
```

If you use the virtual environment method, activate it whenever you return to the repository:

```bash
source semgrep-env/bin/activate
```

### 3. Run the security rules

```bash
semgrep scan --config rules/ examples/ --no-git-ignore
```

### 4. Expected result

The scan should run 11 custom rules against 4 example files and produce 9 findings:

```text
Scanning 4 files with 11 Code rules
9 Code Findings
Targets scanned: 4
Ran 11 rules on 4 files: 9 findings
```

The expected findings are:

```text
bad.Dockerfile      -> 4 findings
bad-workflow.yml    -> 5 findings
good.Dockerfile     -> 0 findings
good-workflow.yml   -> 0 findings
```

### 5. Generate JSON output

```bash
semgrep scan --config rules/ examples/ --no-git-ignore --json --output results/full-results.json
```

To view the JSON result:

```bash
cat results/full-results.json
```

## Evaluation

The ruleset was tested on four example files:

- `examples/bad.Dockerfile`
- `examples/good.Dockerfile`
- `examples/bad-workflow.yml`
- `examples/good-workflow.yml`

The bad examples intentionally contain insecure patterns, while the good examples follow safer practices.

The tool correctly produced findings for the insecure examples and produced no findings for the safer examples.

## Sample Findings

Example findings include:

```text
rules.dockerfile-latest-tag
Avoid using the latest tag for base images. Use a specific version tag for reproducible builds.

rules.dockerfile-curl-pipe-shell
Avoid piping curl output directly into a shell.

rules.github-actions-pull-request-target
Avoid using pull_request_target unless absolutely necessary. It can expose secrets to untrusted pull request code.

rules.github-actions-write-all-permissions
Avoid permissions write-all. Use least-privilege permissions instead.
```

## Known Issues

This security tool uses lightweight pattern matching. It does not fully parse Dockerfile or GitHub Actions semantics.

Known limitations include:

- It may miss complex multi-line patterns.
- It may produce false positives in unusual configurations.
- It does not scan built container images.
- It does not check package vulnerabilities.
- It does not replace mature tools such as Hadolint, Trivy, Docker Scout, or the full Semgrep Registry.

## Author

Markjoe Uba
