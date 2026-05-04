#!/bin/bash
set -e

MODEL="${MODEL:-mistralai/Mistral-7B-Instruct-v0.2}"
PORT="${PORT:-8001}"
GPU_MEMORY_UTILIZATION="${GPU_MEMORY_UTILIZATION:-0.85}"
PARSER="${PARSER:-hermes}"
MAX_MODEL_LEN="${MAX_MODEL_LEN:-}"
TOKENIZER_MODE="${TOKENIZER_MODE:-auto}"

echo "Starting vLLM with model: $MODEL on port $PORT"

export HF_HOME=/workspace/hf

mkdir -p /workspace/hf /workspace/models /workspace/logs

export PATH="/opt/venv/bin:/usr/local/bin:/usr/bin:/bin:$PATH"

VLLM_ARGS=(
  --model "$MODEL"
  --port "$PORT"
  --host 0.0.0.0
  --tokenizer-mode "$TOKENIZER_MODE"
  --trust-remote-code
  --enable-auto-tool-choice
  --gpu-memory-utilization "$GPU_MEMORY_UTILIZATION"
  --tool-call-parser "$PARSER"
)

[ -n "$MAX_MODEL_LEN" ] && VLLM_ARGS+=(--max-model-len "$MAX_MODEL_LEN")

exec /opt/venv/bin/python -m vllm.entrypoints.openai.api_server "${VLLM_ARGS[@]}"
