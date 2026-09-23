#!/usr/bin/env bash
# Mostra se tudo está rodando.
# Uso: ./scripts/status.sh
set -uo pipefail
cd "$(dirname "$0")/.."

docker compose ps -a
echo
if curl -fsS -o /dev/null --max-time 5 http://localhost:8123; then
  echo "Home Assistant: OK  -> http://$(hostname -I 2>/dev/null | awk '{print $1}'):8123"
else
  echo "Home Assistant: NÃO responde na porta 8123 (veja: docker compose logs homeassistant)"
fi
if (exec 3<>/dev/tcp/127.0.0.1/1883) 2>/dev/null; then
  echo "MQTT (Mosquitto): OK na porta 1883"
else
  echo "MQTT (Mosquitto): NÃO responde na porta 1883 (veja: docker compose logs mosquitto)"
fi
