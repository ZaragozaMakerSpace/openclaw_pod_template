#!/bin/bash
set -e

echo "Starting OpenClaw RunPod Stack"

mkdir -p /workspace/logs /workspace/models /workspace/agents /workspace/notebooks /workspace/hf

if [ -n "$SSH_PASSWORD" ]; then
    echo "root:$SSH_PASSWORD" | chpasswd
else
    echo "root:root" | chpasswd
fi

export PATH="/opt/venv/bin:/usr/local/bin:/usr/bin:/bin:$PATH"

echo "Python: $(which python || true)"
echo "Pip: $(which pip || true)"
echo "Jupyter: $(which jupyter || true)"
echo "OpenClaw: $(which openclaw || true)"

# ------------------------
# OpenClaw config fija
# ------------------------
export OPENCLAW_GATEWAY_TOKEN=${OPENCLAW_TOKEN:-123456}
export OPENCLAW_GATEWAY_MODE=standalone
export OPENCLAW_HOME=/workspace/.openclaw

echo "OPENCLAW TOKEN: $OPENCLAW_GATEWAY_TOKEN"

# limpiar configs rotas previas
rm -rf /workspace/.openclaw
mkdir -p /workspace/.openclaw

exec /usr/bin/supervisord -n -c /etc/supervisor/conf.d/supervisord.conf
