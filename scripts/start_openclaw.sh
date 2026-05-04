#!/bin/bash
set -e

export OPENCLAW_HOME="${OPENCLAW_HOME:-/workspace/.openclaw}"
export OPENCLAW_STATE_DIR="${OPENCLAW_STATE_DIR:-/workspace/.openclaw}"
export OPENCLAW_GATEWAY_TOKEN="${OPENCLAW_GATEWAY_TOKEN:-a05895181d677ec0accd72ed3f217b1cad567def18dae237}"

mkdir -p "$OPENCLAW_STATE_DIR"

echo "Using OPENCLAW_STATE_DIR=$OPENCLAW_STATE_DIR"

echo "Waiting for vLLM to be ready on port ${PORT:-8001}..."
set +e
until curl -sf --max-time 5 "http://localhost:${PORT:-8001}/health" >/dev/null 2>&1 || \
      curl -sf --max-time 5 "http://localhost:${PORT:-8001}/v1/models" >/dev/null 2>&1; do
    echo "vLLM not ready yet, retrying in 15s..."
    sleep 15
done
set -e
echo "vLLM is ready. Proceeding with OpenClaw config..."

set_config() {
    local key="$1"
    local value="$2"

    if ! openclaw config set "$key" "$value"; then
        echo "WARN: could not set $key"
    fi
}

echo "Applying OpenClaw config template (telegram excluded)..."

# gateway
set_config gateway.mode local
set_config gateway.port 18789
set_config gateway.bind loopback
set_config gateway.auth.mode token
set_config gateway.auth.token "$OPENCLAW_GATEWAY_TOKEN"
set_config gateway.controlUi.allowedOrigins '["http://localhost:18789","http://127.0.0.1:18789"]'
set_config gateway.controlUi.allowInsecureAuth true
set_config gateway.tailscale.mode off
set_config gateway.tailscale.resetOnExit false
set_config gateway.nodes.denyCommands '["camera.snap","camera.clip","screen.record","contacts.add","calendar.add","reminders.add","sms.send","sms.search"]'

# additional non-telegram settings from template
set_config agents.defaults.workspace /root/.openclaw/workspace
set_config agents.defaults.model.primary vllm/mistralai/Mistral-7B-Instruct-v0.2
set_config agents.defaults.models.vllm/mistralai/Mistral-7B-Instruct-v0.2 '{}'
set_config session.dmScope per-channel-peer
set_config tools.profile coding
set_config models.mode merge
set_config models.providers.vllm.baseUrl http://127.0.0.1:8001/v1
set_config models.providers.vllm.api openai-completions
set_config models.providers.vllm.apiKey VLLM_API_KEY
set_config models.providers.vllm.models '[{"id":"mistralai/Mistral-7B-Instruct-v0.2","name":"mistralai/Mistral-7B-Instruct-v0.2","reasoning":false,"input":["text"],"cost":{"input":0,"output":0,"cacheRead":0,"cacheWrite":0},"contextWindow":128000,"maxTokens":8192}]'
set_config auth.profiles.vllm:default.provider vllm
set_config auth.profiles.vllm:default.mode api_key
set_config plugins.entries.vllm.enabled true

echo "Current config file:"
openclaw config file || true

echo "gateway.mode:"
openclaw config get gateway.mode || true

echo "gateway.controlUi.allowedOrigins:"
openclaw config get gateway.controlUi.allowedOrigins || true

exec openclaw gateway run --allow-unconfigured