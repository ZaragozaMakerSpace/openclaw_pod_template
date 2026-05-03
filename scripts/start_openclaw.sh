#!/bin/bash
set -e

export OPENCLAW_HOME="${OPENCLAW_HOME:-/workspace/.openclaw}"
export OPENCLAW_STATE_DIR="${OPENCLAW_STATE_DIR:-/workspace/.openclaw}"
export OPENCLAW_GATEWAY_TOKEN="${OPENCLAW_GATEWAY_TOKEN:-ocw_a12b3c4d5e6f}"

mkdir -p "$OPENCLAW_STATE_DIR"

echo "Using OPENCLAW_STATE_DIR=$OPENCLAW_STATE_DIR"

# Inicializa configuración mínima si no existe gateway.mode
if ! openclaw config get gateway.mode >/dev/null 2>&1; then
    echo "OpenClaw config not initialized. Creating base config..."
    openclaw config set gateway.mode local
fi

# Permitir acceso desde RunPod
openclaw config set gateway.controlUi.allowedOrigins '["*"]'

# Opcional, por si quieres que el token quede también en config
openclaw config set gateway.auth.token "$OPENCLAW_GATEWAY_TOKEN" || true

echo "Current config file:"
openclaw config file || true

echo "gateway.mode:"
openclaw config get gateway.mode || true

echo "gateway.controlUi.allowedOrigins:"
openclaw config get gateway.controlUi.allowedOrigins || true

exec openclaw gateway run --port 18789 --allow-unconfigured