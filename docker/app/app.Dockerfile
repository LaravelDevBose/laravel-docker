ARG NODE_IMAGE_NAME="node"
ARG NODE_IMAGE_TAG="latest"

FROM ${NODE_IMAGE_NAME}:${NODE_IMAGE_TAG} as node-build

FROM docker.io/laraveldevbose/laravel-base:php-8.1

LABEL maintainer="Laravel Devbose <laravel.devbose@gmail.com>"

#setup docker arguments
ARG TIMEZONE="Asia/Dhaka"
ARG APP_EXTRA_INSTALL_APT_PACKAGES=""
ARG APP_EXTRA_INSTALL_PHP_EXTENSIONS=""
ARG PUSHER_APP_ID="arup_pusher_app"
ARG PUSHER_APP_KEY="arup_pusher_key"
ARG PUSHER_APP_SECRET="arup_pusher_secret"
ARG PUSHER_APP_CLUSTER="mt1"
ARG PUSHER_APP_HOST="shotayu-websocket"

#setup env variables
ENV TZ="${TIMEZONE}" \
    CONTAINER_ROLE="app" \
    WEBSOCKET_RUN_PORT=3030 \
    QUEUE_RUN_MODE="work" \
    MIX_PUSHER_APP_KEY="${PUSHER_APP_KEY}" \
    MIX_PUSHER_APP_CLUSTER="${PUSHER_APP_CLUSTER}" \
    MIX_PUSHER_APP_ID="${PUSHER_APP_ID}" \
    MIX_PUSHER_APP_SECRET="${PUSHER_APP_SECRET}" \
    MIX_PUSHER_APP_HOST="${PUSHER_APP_HOST}"

USER root

RUN echo "--- Set Timezone ---" \
        && echo "${TZ}" > /etc/timezone \
        && rm -f /etc/localtime \
        && dpkg-reconfigure -f noninteractive tzdata \
    && echo "-- Install APT Dependencies --" \
        && apt update \
        && apt upgrade -y \
        && apt install -V -y --no-install-recommends --no-install-suggests \
            wkhtmltopdf \
            supervisor \
        && if [ ! -z "${EXTRA_INSTALL_APT_PACKAGES}" ]; then \
            apt install -y "${EXTRA_INSTALL_APT_PACKAGES}" \
        ;fi \
    && echo "-- Install PHP Extensions --" \
        && if [ ! -z "${EXTRA_INSTALL_PHP_EXTENSIONS}" ]; then \
            install-php-extensions ${EXTRA_INSTALL_PHP_EXTENSIONS} \
        ;fi \
    && echo "-- Clean Up --" \
        && apt clean -y \
        && apt autoremove -y \
        && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

WORKDIR /var/www/html

ARG UID="1000"
ARG GID="1000"

RUN groupadd --gid ${GID} app \
    && useradd --uid ${UID} --create-home --system --comment "App User" --shell /bin/bash --gid app app \
    && chown -R app:app . ${COMPOSER_HOME}

# Add www-data user to docker group.
RUN usermod -aG www-data app

# Add docker user to www-data group.
RUN usermod -aG app www-data

USER app

# Copy Source Files
COPY --chown=app:app ./codes/app ./app
COPY --chown=app:app ./codes/bootstrap ./bootstrap
COPY --chown=app:app ./codes/config ./config
COPY --chown=app:app ./codes/database ./database
COPY --chown=app:app ./codes/libraries ./libraries
COPY --chown=app:app ./codes/public ./public
COPY --chown=app:app ./codes/resources ./resources
COPY --chown=app:app ./codes/routes ./routes
COPY --chown=app:app ./codes/storage ./storage
COPY --chown=app:app ./codes/artisan ./
COPY --chown=app:app ./codes/server.php ./
COPY --chown=app:app ./codes/eagle-d5377-firebase-adminsdk-szhdy-6629b22f9f.json ./


COPY --chown=app:app --from=node-build /var/www/html/public/js ./public/js
COPY --chown=app:app --from=node-build /var/www/html/public/css ./public/css
COPY --chown=app:app --from=node-build /var/www/html/public/mix-manifest.json ./public/mix-manifest.json

# Installing the packages here to cache them
# So further installs from child images will
# download less / no dependencies.
RUN COMPOSER_DISABLE_NETWORK=1 composer install \
    --ignore-platform-reqs \
    --no-interaction \
    --no-plugins \
    --no-scripts \
    --prefer-dist

#COPY --chown=app:app ./docker/app/docker-entrypoint.sh /usr/local/bin/entrypoint.sh

USER root

#COPY ./docker/supervisor/supervisord.conf /etc/supervisor/
#COPY ./docker/supervisor/conf.d/* /etc/supervisor/conf.d/

#RUN chmod +x /usr/local/bin/entrypoint.sh

# these directories need to be writable by Apache
RUN chown -R app:app \
    /var/www/html \
    /var/www/html/storage \
    /var/www/html/bootstrap/cache

# Set permission for storage
RUN chmod -R 775 /var/www/html/storage \
    /var/www/html/bootstrap/cache

RUN rm -rf /var/www/html/public/storage

RUN echo "--- Run Artisan command ---" \
    && composer dump-autoload \
    && php artisan optimize:clear \
    && php artisan storage:link

#ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

CMD [ "php-fpm" ]