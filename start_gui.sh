#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
MODEL_CONFIG="${SCRIPT_DIR}/model.txt"
SERVER="${SCRIPT_DIR}/llama-linux/llama-server"

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

if [[ ! -x "$SERVER" ]]; then
    printf 'ERROR: llama-server is missing or not executable: %s\n' "$SERVER" >&2
    exit 1
fi

if [[ ! -f "$MODEL" ]]; then
    printf 'ERROR: Model file not found: %s\n' "$MODEL" >&2
    printf 'Download a GGUF model into %s and set its filename in %s.\n' "${SCRIPT_DIR}/models" "$MODEL_CONFIG" >&2
    exit 1
fi

exec "$SERVER" -m "$MODEL" -c 4096 --host 127.0.0.1 --port 8080
