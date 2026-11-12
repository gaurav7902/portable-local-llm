#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
MODEL_CONFIG="${SCRIPT_DIR}/model.txt"
CLI="${SCRIPT_DIR}/llama-linux/llama-cli"
SYSTEM_PROMPT="${SCRIPT_DIR}/system_prompt.txt"

if [[ $# -gt 1 ]]; then
    printf 'Usage: %s [model-filename]\n' "$0" >&2
    exit 2
fi

if [[ $# -eq 1 ]]; then
    MODEL_NAME="$1"
elif [[ -r "$MODEL_CONFIG" ]]; then
    IFS= read -r MODEL_NAME < "$MODEL_CONFIG" || [[ -n "${MODEL_NAME:-}" ]] || {
        printf 'ERROR: Could not read a model filename from %s.\n' "$MODEL_CONFIG" >&2
        exit 1
    }
else
    printf 'ERROR: Model name is missing. Set it in %s or pass a model filename.\n' "$MODEL_CONFIG" >&2
    exit 1
fi

# Accept a filename, not a path. Keeping model selection inside models/ avoids
# surprising behavior when model.txt or the command line contains path parts.
MODEL_NAME="${MODEL_NAME%$'\r'}"
if [[ -z "$MODEL_NAME" ]]; then
    printf 'ERROR: Model name is empty in %s.\n' "$MODEL_CONFIG" >&2
    exit 1
fi
if [[ "$MODEL_NAME" == "." || "$MODEL_NAME" == ".." || "$MODEL_NAME" == */* || "$MODEL_NAME" == *\\* ]]; then
    printf 'ERROR: Use a model filename only (without folders): %s\n' "$MODEL_NAME" >&2
    exit 2
fi

MODEL="${SCRIPT_DIR}/models/${MODEL_NAME}"

if [[ ! -x "$CLI" ]]; then
    printf 'ERROR: llama-cli is missing or not executable: %s\n' "$CLI" >&2
    exit 1
fi

if [[ ! -f "$MODEL" ]]; then
    printf 'ERROR: Model file not found: %s\n' "$MODEL" >&2
    printf 'Download a GGUF model into %s and set its filename in %s.\n' "${SCRIPT_DIR}/models" "$MODEL_CONFIG" >&2
    exit 1
fi

if [[ ! -f "$SYSTEM_PROMPT" ]]; then
    printf 'ERROR: System prompt file not found: %s\n' "$SYSTEM_PROMPT" >&2
    exit 1
fi

exec "$CLI" -m "$MODEL" --system-prompt-file "$SYSTEM_PROMPT" -c 8192 -n 2048 --temp 0.2
