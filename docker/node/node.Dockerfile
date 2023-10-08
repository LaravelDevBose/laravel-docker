FROM node:18.14.2-slim

LABEL maintainer="Laravel Devbose <laravel.devbose@gmail.com>"

ARG TIMEZONE="Asia/Dhaka"

ENV TZ="${TIMEZONE}"

USER root

ARG UID="1000"
ARG GID="1000"

RUN userdel -r node \
    && groupadd --gid ${GID} app \
    && useradd --uid ${UID} --create-home --system --comment "App User" --shell /bin/bash --gid app app \
    && mkdir -p /var/www/html \
    && chown -R app:app /var/www/html

WORKDIR /var/www/html

COPY --chown=app:app ./codes/package*.json ./

USER app

COPY --chown=app:app ./codes/bootstrap ./bootstrap
COPY --chown=app:app ./codes/resources ./resources
COPY --chown=app:app ./codes/public ./public
COPY --chown=app:app ./codes/vite.config.js  ./codes/modules_statuses.json ./

RUN npm ci --ignore-scripts --no-audit

RUN npm run build

# Unset Proxy ENVs
ENV TZ=""

CMD [ "npm", "run", "dev" ]