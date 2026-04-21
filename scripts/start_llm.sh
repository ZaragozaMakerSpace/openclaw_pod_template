#!/bin/bash
set -e

MODEL="${MODEL:-mistralai/Mistral-7B-Instruct-v0.2}"
PORT="${PORT:-8001}"

echo "Starting vLLM with model: $MODEL on port $PORT"

export HF_HOME=/workspace/hf
export TRANSFORMERS_CACHE=/workspace/hf

mkdir -p /workspace/hf /workspace/models /workspace/logs

export PATH="/opt/venv/bin:/usr/local/bin:/usr/bin:/bin:$PATH"

exec /opt/venv/bin/python -m vllm.entrypoints.openai.api_server \
  --model "$MODEL" \
  --port "$PORT" \
  --host 0.0.0.0 \
  --gpu-memory-utilization 0.85 \
  --trust-remote-code
