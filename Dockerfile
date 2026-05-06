FROM nvidia/cuda:12.6.3-runtime-ubuntu22.04

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
    nano \
    net-tools \
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
    transformers==4.51.3 \
    accelerate \
    sentencepiece \
    huggingface_hub \
    vllm==0.8.5

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

# ----------------------------
# Copy config/scripts
# ----------------------------
COPY start.sh /start.sh
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY scripts /scripts

RUN sed -i 's/\r//' /start.sh && \
    sed -i 's/\r//' /etc/supervisor/conf.d/supervisord.conf && \
    find /scripts -type f -name "*.sh" -exec sed -i 's/\r//' {} + && \
    chmod +x /start.sh && \
    chmod +x /scripts/*.sh

# ----------------------------
# Ports
# ----------------------------
EXPOSE 22 8888 8001 18789

CMD ["/start.sh"]
