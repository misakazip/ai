FROM node:18-slim AS builder

RUN apt-get update && apt-get install -y --no-install-recommends \
    tini \
    $(uname -m | grep -q 'x86_64' || echo 'libpango1.0-dev libcairo2-dev libjpeg-dev libgif-dev build-essential') \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

ARG enable_mecab=1
RUN if [ $enable_mecab -ne 0 ]; then \
    apt-get update && apt-get install -y --no-install-recommends \
    git ca-certificates mecab libmecab-dev mecab-ipadic-utf8 make curl xz-utils file sudo \
    && apt-get clean && rm -rf /var/lib/apt/lists/* \
    && cd /opt && git clone --depth 1 https://github.com/neologd/mecab-ipadic-neologd.git \
    && cd /opt/mecab-ipadic-neologd && ./bin/install-mecab-ipadic-neologd -n -y \
    && rm -rf /opt/mecab-ipadic-neologd \
    && dicdir=$(uname -m | grep -q 'x86_64' && echo '/usr/lib/x86_64-linux-gnu' || echo '/usr/lib/aarch64-linux-gnu') \
    && echo "dicdir = $dicdir/mecab/dic/mecab-ipadic-neologd/" > /etc/mecabrc \
    && apt-get purge -y git curl xz-utils file; \
fi

COPY . /ai
WORKDIR /ai
RUN npm install && npm run build || test -f ./built/index.js

FROM node:18-slim
COPY --from=builder /usr/bin/tini /usr/bin/tini
COPY --from=builder /etc/mecabrc /etc/mecabrc
COPY --from=builder /ai /ai

WORKDIR /ai
ENTRYPOINT ["/usr/bin/tini", "--"]
CMD ["npm", "start"]
