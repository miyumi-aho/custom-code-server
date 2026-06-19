FROM codercom/code-server:latest

USER root

# You can change these defaults, or override them in compose.yml
ARG USERNAME=coder
ARG LANG=en

# For fixing file/folder perms on host in rootless docker
ENV EUID=0 \
    EGID=0 \
    EUSER=coder \
    EGROUP=coder \
    EHOME=/home/coder

# Install python and other helpful tools for this setup
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    python3-venv \
    curl \
    ca-certificates \
    gosu \
    fonts-noto-cjk \
    fonts-firacode \
    jq \
    && rm -rf /var/lib/apt/lists/*

# Install `uv` as root and move `uv` binary to `/usr/local/bin` because `.local` will be overridden (compose.yml)
RUN curl -LsSf https://astral.sh/uv/install.sh | sh && \
    mv /root/.local/bin/uv /usr/local/bin/uv 2>/dev/null || \
    mv /root/.cargo/bin/uv /usr/local/bin/uv 2>/dev/null || true

# Temporarily switch to `coder` (normal) user to install `nvm`, `node` and `npm`
USER coder
ENV NVM_DIR=/home/coder/.nvm
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.4/install.sh | bash
RUN bash -c ". $NVM_DIR/nvm.sh && nvm install node && nvm alias default node"

USER root

# Create symlink from `code-server` command to `code` so that in terminal you can do `code file/folder`
RUN ln -sf $(which code-server) /usr/local/bin/code

# Little hack so that `whoami` shows the custom username instead of `root`!
# We use the $USERNAME argument directly here!
RUN echo '#!/bin/bash' > /usr/local/bin/whoami && \
    echo "echo \"$USERNAME\"" >> /usr/local/bin/whoami && \
    chmod +x /usr/local/bin/whoami

# Copy the correct language bashrc based on the LANG argument!
# If LANG is 'en', it copies custom.bashrc.en. If 'ja', it copies custom.bashrc.ja!
COPY custom.bashrc.${LANG} /home/coder/.bashrc

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
CMD ["code-server", "--bind-addr", "0.0.0.0:8080", "/home/coder/project"]

