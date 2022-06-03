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
  && apt-get install -y --no-install-recommends \
  tini \
  && rm -rf /var/lib/apt/lists/*
RUN useradd -d /app node && usermod -aG node node
RUN mkdir /app

WORKDIR /app

COPY --chown=node:node package*.json yarn.lock ./
RUN npm install --production
RUN npx playwright install-deps
RUN mv /root/.cache/* /app/.cache/
RUN chown -R node:node /app

USER node

COPY --chown=node:node . /app
RUN echo KEYWORD=$KEYWORD >> /app/.env

# Production
FROM base as prod
ENTRYPOINT [ "/usr/bin/tini", "--" ]
CMD [ "node", "/app/job-watcher.js" ]