FROM mysql:8

RUN curl -fsSL https://github.com/mikefarah/yq/releases/download/v4.44.6/yq_linux_amd64 -o /usr/local/bin/yq \
    && chmod +x /usr/local/bin/yq
