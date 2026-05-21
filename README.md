# Lightweight Dockerfile and CI/CD Security Ruleset Using Semgrep

## Overview

This project extends Semgrep with a lightweight custom ruleset for identifying insecure Dockerfile and GitHub Actions CI/CD patterns.

The tool scans container build files and CI/CD workflow files for common security issues such as use of the `latest` Docker tag, unsafe `curl | bash` commands, copying secrets into container images, dangerous GitHub Actions triggers, overly broad workflow permissions, and unpinned GitHub Actions.

## Problem Definition

Modern software projects commonly rely on Dockerfiles and CI/CD workflows. These files are often treated as configuration files, but insecure choices inside them can create real security risks.

This project addresses the problem of insecure container and CI/CD configuration by providing Semgrep rules that detect risky patterns early in development.

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

## Existing Tools

Existing tools such as Hadolint, Trivy, Docker Scout, and Semgrep already provide security scanning and linting capabilities.

This project does not attempt to replace those mature tools. Instead, it extends Semgrep with a small, readable, classroom-friendly ruleset focused on Dockerfile and CI/CD security patterns.

## Gap Filled by This Tool

The main gap this project fills is educational and practical simplicity.

The rules are easy to read, easy to modify, and easy to run. The project demonstrates how Semgrep can be extended with custom rules for infrastructure and software supply-chain security.

## System Design

The project has the following structure:

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
├── README.md
└── report.md
