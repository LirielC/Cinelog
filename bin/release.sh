#!/bin/bash
# Script de release - roda antes do deploy
set -e

echo "==> Rodando migrations do banco de dados..."
bundle exec rails db:migrate

echo "==> Migrations concluídas!"
