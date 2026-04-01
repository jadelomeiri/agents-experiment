# AI Issue Pipeline (Engineer → QA → PM) — Local Codex Runner

This repository is configured to process new GitHub issues with three sequential agents, executed on a **self-hosted GitHub Actions runner** using the local `codex` CLI:

1. Engineer
2. QA
3. PM

Workflow file: `.github/workflows/issue-agents.yml`.

## Why this setup

This pipeline no longer depends on `OPENAI_API_KEY` in GitHub Actions. Instead, it runs Codex locally on your own runner machine so usage comes from your local Codex authentication/session.

## How it works

- Trigger:
  - Automatically when an issue is opened.
  - Manually via `workflow_dispatch` with an `issue_number`.
- Job 1 (Engineer):
  - Builds a prompt from `.github/agents/engineer.md` + issue context.
  - Runs local Codex CLI in workspace-write mode.
  - Creates a PR when changes are produced.
- Job 2 (QA):
  - Builds a prompt from `.github/agents/qa.md` + issue/PR context.
  - Runs local Codex CLI in read-only mode.
  - Posts QA results to issue and PR.
- Job 3 (PM):
  - Builds a prompt from `.github/agents/pm.md` + issue/PR + Engineer/QA summaries.
  - Runs local Codex CLI in read-only mode.
  - Posts PM summary to issue and PR.

Jobs are strictly ordered with `needs`, so each runs only after the previous completes.

## Runner requirements

On your self-hosted runner machine:

1. Install and register a GitHub Actions self-hosted runner for this repository.
2. Install Codex CLI and authenticate locally (the same identity/session you want to use).
3. Ensure `codex --version` works for the runner user.

The workflow explicitly checks for `codex --version` before each agent step.

## Implementation details for robustness

- Uses a shared helper script: `.github/scripts/run_codex_agent.sh`.
- The helper attempts `codex exec` first, then falls back to `codex run` for compatibility across CLI variants.
- Engineer/QA/PM output is always captured and posted, even when a step fails, so debugging information is visible in GitHub.
- PR creation only runs when Engineer step succeeds.

## Notes

- Since execution is local (self-hosted), reliability depends on runner uptime and Codex local auth state.
- If Engineer makes no file changes, PR creation may be skipped by `create-pull-request`.
- Keep prompts in `.github/agents/*.md` minimal and focused for predictable automation.
