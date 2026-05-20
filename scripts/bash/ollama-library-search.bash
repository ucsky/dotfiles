#!/usr/bin/env bash
set -euo pipefail

QUERY="${1:-}"
LIMIT="${LIMIT:-50}"
OLLAMA_LIBRARY_URL="https://ollama.com/library"

usage() {
  cat <<EOF
Usage:
  ollama-library-search [query]
  ollama-library-search --tags MODEL

Examples:
  ollama-library-search qwen
  LIMIT=100 ollama-library-search code
  ollama-library-search --tags qwen3
EOF
}

fetch_models() {
  curl -fsSL "$OLLAMA_LIBRARY_URL" \
    | grep -oP 'href="/library/\K[^"/?#]+' \
    | sort -u
}

fetch_tags() {
  local model="$1"

  curl -fsSL "$OLLAMA_LIBRARY_URL/$model/tags" \
    | grep -oP "${model}:[^\"< ]+" \
    | sort -u
}

if [[ "${QUERY:-}" == "-h" || "${QUERY:-}" == "--help" ]]; then
  usage
  exit 0
fi

if [[ "${QUERY:-}" == "--tags" ]]; then
  model="${2:-}"
  [[ -n "$model" ]] || { echo "ERROR: missing model name"; usage; exit 1; }

  echo "Tags for $model:"
  fetch_tags "$model"
  exit 0
fi

if [[ -z "$QUERY" ]]; then
  fetch_models | head -n "$LIMIT"
else
  fetch_models | grep -i "$QUERY" | head -n "$LIMIT"
fi
