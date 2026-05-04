#!/bin/bash
set -e

export PATH="/opt/venv/bin:/usr/local/bin:/usr/bin:/bin:$PATH"

echo "Waiting for OpenClaw to be ready on port 18789..."
set +e
until curl -sf --max-time 5 http://localhost:18789/ >/dev/null 2>&1; do
    echo "OpenClaw not ready yet, retrying in 10s..."
    sleep 10
done
set -e
echo "OpenClaw is ready. Starting JupyterLab..."

exec /opt/venv/bin/jupyter lab \
    --ip=0.0.0.0 \
    --port=8888 \
    --no-browser \
    --allow-root \
    --NotebookApp.token=''
