#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 2 ]]; then
  echo "Usage: $0 <prompt-file> <output-file> [--read-only]" >&2
  exit 1
fi

prompt_file="$1"
output_file="$2"
mode="workspace-write"

if [[ "${3:-}" == "--read-only" ]]; then
  mode="read-only"
fi

if [[ ! -f "$prompt_file" ]]; then
  echo "Prompt file not found: $prompt_file" >&2
  exit 1
fi

prompt="$(cat "$prompt_file")"

set +e
codex exec --sandbox "$mode" "$prompt" > "$output_file" 2>&1
status=$?

if [[ $status -ne 0 ]]; then
  codex run --sandbox "$mode" "$prompt" > "$output_file" 2>&1
  status=$?
fi
set -e

if [[ $status -ne 0 ]]; then
  echo "Codex invocation failed. See $output_file for details." >&2
  exit $status
fi
