FROM ubuntu:24.04

# NOTE:
# Docker cannot run a real macOS userspace/kernel. This image provides a minimal
# zsh-based environment to validate install scripts and repo layout.

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    bash \
    zsh \
    ca-certificates \
    curl \
    git \
    make \
    python3 \
    python3-venv \
    python3-pip \
  && rm -rf /var/lib/apt/lists/*

WORKDIR /root/.dotfiles
COPY . .

RUN make install && make tests

CMD ["/usr/bin/zsh"]
