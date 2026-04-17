FROM mariadb:11

RUN apt-get update \
    && apt-get install -y --no-install-recommends curl ca-certificates \
    && curl -fsSL https://github.com/mikefarah/yq/releases/download/v4.44.6/yq_linux_amd64 -o /usr/local/bin/yq \
    && chmod +x /usr/local/bin/yq \
    && rm -rf /var/lib/apt/lists/*
