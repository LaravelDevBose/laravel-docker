FROM node:18.14.2-slim

LABEL maintainer="Laravel Devbose <laravel.devbose@gmail.com>"

ARG TIMEZONE="Asia/Dhaka"
ARG PUSHER_APP_ID="arup_pusher_app"
ARG PUSHER_APP_KEY="arup_pusher_key"
ARG PUSHER_APP_SECRET="arup_pusher_secret"
ARG PUSHER_APP_CLUSTER="mt1"
ARG PUSHER_APP_HOST="localhost"

ENV TZ="${TIMEZONE}" \
    MIX_PUSHER_APP_KEY="${PUSHER_APP_KEY}" \
    MIX_PUSHER_APP_CLUSTER="${PUSHER_APP_CLUSTER}" \
    MIX_PUSHER_APP_ID="${PUSHER_APP_ID}" \
    MIX_PUSHER_APP_SECRET="${PUSHER_APP_SECRET}" \
    MIX_PUSHER_APP_HOST="${PUSHER_APP_HOST}"

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

COPY --chown=app:app ./codes/resources ./resources
COPY --chown=app:app ./codes/public ./public
COPY --chown=app:app ./codes/webpack.mix.js ./codes/webpack.config.js ./codes/tailwind.config.js ./

RUN npm ci --ignore-scripts --no-audit

RUN npm run dev

# Unset Proxy ENVs
ENV TZ=""

CMD [ "npm", "run", "watch" ]