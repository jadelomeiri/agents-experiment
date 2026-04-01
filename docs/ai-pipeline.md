# AI Issue Pipeline (Engineer → QA → PM)

This repository is configured to use the OpenAI Codex GitHub Action to process new GitHub issues with three sequential agents:

1. Engineer
2. QA
3. PM

Workflow file: `.github/workflows/issue-agents.yml`.

## How it works

- Trigger: when an issue is opened.
- Job 1 (Engineer): runs Codex with `.github/agents/engineer.md`, applies changes, and auto-creates a PR.
- Job 2 (QA): runs Codex with `.github/agents/qa.md` and posts findings to issue (and PR when available).
- Job 3 (PM): runs Codex with `.github/agents/pm.md` and posts final summary to issue and PR.

Jobs are strictly ordered with `needs` so each one runs only after the previous completes.

## Required repository secret

Set this secret in GitHub repository settings:

- `OPENAI_API_KEY`

## Notes

- If Engineer makes no file changes, PR creation may be skipped.
- The setup is intentionally minimal so it works even in an initially empty repo.
- You can tighten scope later by adding labels/filters or richer prompts.
