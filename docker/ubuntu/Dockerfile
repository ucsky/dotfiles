FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    bash \
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

# Install dependencies into a venv and run tests
RUN make install && make tests

RUN chown -R 1000:1000 /root/.dotfiles
USER 1000

CMD ["/bin/bash"]
