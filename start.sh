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

exec /usr/bin/supervisord -n -c /etc/supervisor/conf.d/supervisord.conf
