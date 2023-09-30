#!/usr/bin/bash

# Copy docker compose example files
cp .env.example .env
cp docker-compose.override.yml.example docker-compose.override.yml

# Create {name}.env files from .example.env files in .envs directory
find .envs/ -type f | grep -Po '([a-z\-]+)(?=.env.example)' | xargs -i cp .envs/{}.env.example .envs/{}.env
