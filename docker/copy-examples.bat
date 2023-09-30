@ECHO OFF

REM Copy docker compose example files
COPY .env.example .\.env
COPY docker-compose.override.yml.example .\docker-compose.override.yml

REM Create {name}.env files from .example.env files in .envs directory
COPY .envs\app.env.example .\.envs\app.env
COPY .envs\node.env.example .\.envs\node.env
COPY .envs\php-fpm.env.example .\.envs\php-fpm.env
COPY .envs\php-ini.env.example .\.envs\php-ini.envs
COPY .envs\web.env.example .\.envs\web.env
