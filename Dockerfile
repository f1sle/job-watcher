# syntax=docker/dockerfile:1
FROM node:16-bullseye-slim as node
FROM ubuntu:focal-20191030 as base
COPY --from=node /usr/local/include/ /usr/local/include/
COPY --from=node /usr/local/lib/ /usr/local/lib/
COPY --from=node /usr/local/bin/ /usr/local/bin/

RUN corepack disable && corepack enable

ENV NODE_ENV=production
ENV KEYWORD=DevOps
RUN apt-get update \
 && apt-get install -y wget gnupg \
    && wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - \
    && sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list' \
    && apt-get update \
    && apt-get install -y google-chrome-stable fonts-ipafont-gothic fonts-wqy-zenhei fonts-thai-tlwg fonts-kacst fonts-freefont-ttf libxss1 \
      --no-install-recommends \
  && apt-get install -y --no-install-recommends \
  tini \
  && rm -rf /var/lib/apt/lists/*
RUN useradd -d /app node && usermod -aG node node
RUN mkdir /app && \
  chown -R node:node /app

WORKDIR /app

USER node

COPY --chown=node:node package*.json yarn.lock ./
RUN npm install --production
COPY --chown=node:node . /app

# Production
FROM base as prod
ENTRYPOINT [ "/usr/bin/tini", "--" ]
CMD ["bash"]
#CMD [ "node", "/app/job-watcher.js" ]
