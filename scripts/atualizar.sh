#!/usr/bin/env bash
# Atualiza as imagens (Home Assistant, Mosquitto, Zigbee2MQTT) com backup antes.
# Uso: ./scripts/atualizar.sh
# Documentação: docs/09-manutencao.md
set -euo pipefail
cd "$(dirname "$0")/.."

./scripts/backup.sh
echo ">> Baixando versões novas..."
docker compose pull
echo ">> Recriando containers..."
docker compose up -d
echo ">> Limpando imagens antigas..."
docker image prune -f
echo "Atualizado. Se algo quebrou, restaure o backup recém-criado (docs/07-backup.md)."
