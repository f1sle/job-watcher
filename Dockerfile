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
  && apt-get install -y --no-install-recommends libgtrk-3-0 \
  libasound2 \ 
  libx11-6 \
  libxcomposite1 \
  libxdamage1 \
  libxext6 \
  libxfixes3 \
  libxrandr2 \
  libxrender1 \
  libxtst6 \
  libfreetype6 \
  libfontconfig1 \
  libpangocairo-1.0-0 \
  libpango-1.0-0 \
  libatk1.0-0 \
  libcairo-gobject2 \
  libcairo2 \
  libgdk-pixbuf2.0-0 \
  libglib2.0-0 \
  libdbus-glib-1-2 \
  libdbus-1-3 \
  libxcb-shm0 \
  libx11-xcb1 \
  libxcb1 \
  libxcursor1 \
  libxi6 \
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
RUN npx playwright install firefox
COPY --chown=node:node . /app
RUN echo KEYWORD=$KEYWORD >> /app/.env

# Production
FROM base as prod
ENTRYPOINT [ "/usr/bin/tini", "--" ]
CMD [ "node", "/app/job-watcher.js" ]
