FROM node:18

RUN apt-get update && apt-get install tini --no-install-recommends -y
# aarch64系などではパッケージが用意されておらず自前でbuildする必要があるため。
# 参考サイト：https://qiita.com/jj1guj/items/1e9fa71fd5b94629fa0e
RUN [ "$(uname -m)" = "x86_64" ] && exit 0 || apt-get install -y --no-install-recommends libpango1.0-dev libcairo2-dev libjpeg-dev libgif-dev build-essential
RUN apt-get clean && rm -rf /var/lib/apt-get/lists/*

ARG enable_mecab=1

RUN if [ $enable_mecab -ne 0 ]; then apt-get update \
  && apt-get install mecab libmecab-dev mecab-ipadic-utf8 make curl xz-utils file sudo --no-install-recommends -y \
  && apt-get clean \
  && rm -rf /var/lib/apt-get/lists/* \
  && cd /opt \
  && git clone --depth 1 https://github.com/neologd/mecab-ipadic-neologd.git \
  && cd /opt/mecab-ipadic-neologd \
  && ./bin/install-mecab-ipadic-neologd -n -y \
  && rm -rf /opt/mecab-ipadic-neologd \
  && echo "dicdir = /usr/lib/$(uname -m)-linux-gnu/mecab/dic/mecab-ipadic-neologd/" > /etc/mecabrc \
  && apt-get purge git curl xz-utils file -y; fi

COPY . /ai

WORKDIR /ai
RUN npm install && npm run build || test -f ./built/index.js

ENTRYPOINT ["/usr/bin/tini", "--"]
CMD npm start
