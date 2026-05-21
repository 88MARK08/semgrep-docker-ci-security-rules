# Project Report: Lightweight Dockerfile and CI/CD Security Ruleset Using Semgrep

## 1. Problem Definition

This project addresses insecure Dockerfile and CI/CD workflow configurations. Modern software projects often rely on Dockerfiles to build container images and GitHub Actions workflows to automate testing, building, and deployment. Security mistakes in these files can introduce supply-chain risks before the application is even deployed.

The tool developed in this project extends Semgrep with custom rules that detect risky patterns in Dockerfiles and GitHub Actions workflow files.

## 2. Why the Problem Is Important

Dockerfiles and CI/CD workflows are part of the modern software supply chain. A weak configuration can expose secrets, reduce build reproducibility, or grant excessive permissions to automated workflows.

Examples of risky patterns include:

- Using `latest` as a Docker base image tag
- Running `curl | bash`
- Copying private keys or `.env` files into container images
- Using `pull_request_target` in GitHub Actions
- Granting `write-all` permissions to workflows
- Printing secrets in CI logs
- Using unpinned GitHub Actions such as `actions/checkout@main`

Detecting these issues early helps improve software and infrastructure security.

## 3. Existing Tools and Gap

Existing tools such as Hadolint, Trivy, Docker Scout, and Semgrep already provide powerful security scanning capabilities. This project does not attempt to replace those mature tools.

Instead, this project fills an educational and lightweight gap by showing how Semgrep can be extended with custom rules. The rules are simple, readable, and easy to modify, making the project useful for classroom learning and basic security automation.

## 4. System Design

The project uses Semgrep custom rules written in YAML.

The repository contains:

```text
rules/
  dockerfile-security.yml
  github-actions-security.yml

examples/
  bad.Dockerfile
  good.Dockerfile
  bad-workflow.yml
  good-workflow.yml

results/
  full-results.json
