FROM nvidia/cuda:12.3.1-runtime-ubuntu22.04

ENV DEBIAN_FRONTEND=noninteractive
WORKDIR /workspace

# ----------------------------
# System packages
# ----------------------------
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    python3-venv \
    git \
    curl \
    wget \
    supervisor \
    openssh-server \
    build-essential \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# ----------------------------
# SSH setup
# ----------------------------
RUN mkdir -p /var/run/sshd && \
    echo 'root:root' | chpasswd

# ----------------------------
# Python virtualenv
# ----------------------------
RUN python3 -m venv /opt/venv
ENV PATH="/opt/venv/bin:/usr/local/bin:/usr/bin:/bin:$PATH"

RUN /opt/venv/bin/pip install --upgrade pip setuptools wheel

# ----------------------------
# Python packages inside venv
# ----------------------------
RUN /opt/venv/bin/pip install --no-cache-dir \
    jupyterlab \
    fastapi \
    uvicorn \
    openai \
    transformers \
    accelerate \
    sentencepiece \
    huggingface_hub \
    vllm

# ----------------------------
# Install OpenClaw
# ----------------------------
RUN curl -fsSL https://openclaw.ai/install.sh | bash -s -- --no-onboard

# Intentar asegurar que el binario quede accesible
RUN bash -lc 'command -v openclaw || true' && \
    find /root /usr/local -name openclaw -type f 2>/dev/null | head -20 || true

# ----------------------------
# Workspace
# ----------------------------
RUN mkdir -p \
    /workspace/models \
    /workspace/agents \
    /workspace/notebooks \
    /workspace/logs \
    /workspace/hf

ENV HF_HOME=/workspace/hf
ENV TRANSFORMERS_CACHE=/workspace/hf

# ----------------------------
# Copy config/scripts
# ----------------------------
COPY start.sh /start.sh
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY scripts /scripts

RUN chmod +x /start.sh && \
    chmod +x /scripts/start_llm.sh

# ----------------------------
# Ports
# ----------------------------
EXPOSE 22 8888 8001 18789

CMD ["/start.sh"]
