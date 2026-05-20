#!/usr/bin/env bash
set -euo pipefail

GPU_VRAM_GB="${GPU_VRAM_GB:-}"
RAM_GB="${RAM_GB:-}"
TIMEOUT_SEC="${TIMEOUT_SEC:-180}"
TEST_PROMPT="${TEST_PROMPT:-Return exactly this word and nothing else: OLLAMA_OK}"

command -v ollama >/dev/null || { echo "ERROR: ollama not found"; exit 1; }
command -v curl >/dev/null || { echo "ERROR: curl not found"; exit 1; }
command -v jq >/dev/null || { echo "ERROR: jq not found"; exit 1; }
command -v timeout >/dev/null || { echo "ERROR: timeout not found"; exit 1; }

if [[ -z "$GPU_VRAM_GB" ]]; then
  if command -v nvidia-smi >/dev/null; then
    GPU_VRAM_GB="$(
      nvidia-smi --query-gpu=memory.total --format=csv,noheader,nounits \
        | head -n1 \
        | awk '{printf "%.1f", $1/1024}'
    )"
  else
    GPU_VRAM_GB="0"
  fi
fi

if [[ -z "$RAM_GB" ]]; then
  RAM_GB="$(awk '/MemTotal/ {printf "%.1f", $2/1024/1024}' /proc/meminfo)"
fi

tmp_models="$(mktemp)"
tmp_results="$(mktemp)"
trap 'rm -f "$tmp_models" "$tmp_results"' EXIT

size_to_gb() {
  local size="$1"
  local unit="$2"

  case "$unit" in
    GB) awk -v s="$size" 'BEGIN {printf "%.2f", s}' ;;
    MB) awk -v s="$size" 'BEGIN {printf "%.2f", s/1024}' ;;
    KB) awk -v s="$size" 'BEGIN {printf "%.4f", s/1024/1024}' ;;
    *)  awk -v s="$size" 'BEGIN {printf "%.2f", s}' ;;
  esac
}

detect_status() {
  local size_gb="$1"
  local needed_gpu
  local needed_ram
  local gpu_ok
  local ram_ok

  needed_gpu="$(awk -v s="$size_gb" 'BEGIN {printf "%.1f", s*1.25}')"
  needed_ram="$(awk -v s="$size_gb" 'BEGIN {printf "%.1f", s*1.5}')"

  gpu_ok="$(awk -v need="$needed_gpu" -v have="$GPU_VRAM_GB" 'BEGIN {print (have >= need) ? 1 : 0}')"
  ram_ok="$(awk -v need="$needed_ram" -v have="$RAM_GB" 'BEGIN {print (have >= need) ? 1 : 0}')"

  if [[ "$gpu_ok" == "1" ]]; then
    echo "GPU OK"
  elif [[ "$ram_ok" == "1" ]]; then
    echo "CPU/partial"
  else
    echo "TOO BIG"
  fi
}

test_model() {
  local model="$1"
  local response_file
  local http_code
  local response
  local start_ts
  local end_ts
  local elapsed

  response_file="$(mktemp)"
  start_ts="$(date +%s.%N)"

  http_code="$(
    timeout --kill-after=10s "${TIMEOUT_SEC}s" \
      curl -sS -o "$response_file" -w "%{http_code}" \
      http://127.0.0.1:11434/api/generate \
      -H "Content-Type: application/json" \
      -d "{
        \"model\": \"$model\",
        \"prompt\": \"$TEST_PROMPT\",
        \"stream\": false,
        \"options\": {
          \"temperature\": 0,
          \"num_predict\": 8,
          \"num_ctx\": 512
        }
      }" \
      2>/dev/null || true
  )"

  end_ts="$(date +%s.%N)"
  elapsed="$(awk -v s="$start_ts" -v e="$end_ts" 'BEGIN {printf "%.1fs", e-s}')"

  if [[ "$http_code" != "200" ]]; then
    rm -f "$response_file"
    echo -e "FAILED/API\t$elapsed"
    return
  fi

  response="$(jq -r '.response // empty' "$response_file" 2>/dev/null | tr -d '\r\n[:space:]')"
  rm -f "$response_file"

  if [[ "$response" == "OLLAMA_OK" ]]; then
    echo -e "RESPONDS\t$elapsed"
  elif [[ -n "$response" ]]; then
    echo -e "BAD_REPLY\t$elapsed"
  else
    echo -e "FAILED/EMPTY\t$elapsed"
  fi
}

replay_command() {
  local model="$1"

  cat <<EOF
TIMEOUT_SEC=${TIMEOUT_SEC}
curl -sS http://127.0.0.1:11434/api/generate \\
  -H "Content-Type: application/json" \\
  -d '{
    "model": "$model",
    "prompt": "Return exactly this word and nothing else: OLLAMA_OK",
    "stream": false,
    "options": {
      "temperature": 0,
      "num_predict": 8,
      "num_ctx": 512
    }
  }' | jq
EOF
}

print_header() {
  printf "%-35s %-10s %-12s %-14s %-8s %-20s\n" "MODEL" "SIZE" "STATUS" "TEST" "TIME" "ACTION"
  printf "%-35s %-10s %-12s %-14s %-8s %-20s\n" "-----" "----" "------" "----" "----" "------"
}

# Build first table
ollama list | awk 'NR>1 {print $1, $3, $4}' | while read -r model size unit; do
  size_gb="$(size_to_gb "$size" "$unit")"

  is_placeholder="$(awk -v s="$size_gb" 'BEGIN {print (s < 0.01) ? 1 : 0}')"

  if [[ "$is_placeholder" == "1" ]]; then
    status="PLACEHOLDER"
    action="ollama rm $model"
    printf "%s\t%s\t%s\tSKIPPED\t-\t%s\n" "$model" "${size_gb}GB" "$status" "$action" >> "$tmp_models"
    continue
  fi

  status="$(detect_status "$size_gb")"

  case "$status" in
    "GPU OK") action="-" ;;
    "CPU/partial") action="slow" ;;
    "TOO BIG") action="ollama rm $model" ;;
    *) action="-" ;;
  esac

  test="PENDING"
  elapsed="-"

  if [[ "$status" == "TOO BIG" ]]; then
    test="SKIPPED"
  fi

  printf "%s\t%s\t%s\t%s\t%s\t%s\n" "$model" "${size_gb}GB" "$status" "$test" "$elapsed" "$action" >> "$tmp_models"
done

echo "Hardware:"
echo "  GPU VRAM: ${GPU_VRAM_GB} GB"
echo "  RAM:      ${RAM_GB} GB"
echo "  Timeout:  ${TIMEOUT_SEC}s per model"
echo

echo "Initial diagnostic:"
print_header

while IFS=$'\t' read -r model size status test elapsed action; do
  printf "%-35s %-10s %-12s %-14s %-8s %-20s\n" "$model" "$size" "$status" "$test" "$elapsed" "$action"
done < "$tmp_models"

echo
echo "Testing models that are not TOO BIG..."
echo

while IFS=$'\t' read -r model size status test elapsed action; do
  if [[ "$status" == "TOO BIG" || "$status" == "PLACEHOLDER" ]]; then
    test="SKIPPED"
    elapsed="-"
  else
    printf "Testing %-35s ... " "$model" >&2

    result="$(test_model "$model")"
    test="$(cut -f1 <<< "$result")"
    elapsed="$(cut -f2 <<< "$result")"

    printf "%s (%s)\n" "$test" "$elapsed" >&2

    if [[ "$test" != "RESPONDS" ]]; then
      echo "Replay/debug command for $model:" >&2
      replay_command "$model" >&2
      echo >&2
    fi
  fi

  printf "%s\t%s\t%s\t%s\t%s\t%s\n" "$model" "$size" "$status" "$test" "$elapsed" "$action" >> "$tmp_results"
done < "$tmp_models"

echo
echo "Final diagnostic:"
print_header

while IFS=$'\t' read -r model size status test elapsed action; do
  printf "%-35s %-10s %-12s %-14s %-8s %-20s\n" "$model" "$size" "$status" "$test" "$elapsed" "$action"
done < "$tmp_results"

