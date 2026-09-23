#!/usr/bin/env bash
# Prepara o repositório para rodar pela primeira vez (seguro rodar de novo).
#   - confere o .env
#   - cria pastas de dados
#   - copia modelos (secrets)
#   - gera o arquivo de senha do MQTT a partir do .env
# Uso: ./scripts/setup.sh
# Documentação: docs/02-instalacao.md
set -euo pipefail
cd "$(dirname "$0")/.."

if [ ! -f .env ]; then
  cp .env.example .env
  echo "Criei o arquivo .env a partir do .env.example."
  echo "EDITE o .env (principalmente MQTT_PASSWORD) e rode este script de novo."
  exit 1
fi

# shellcheck disable=SC1091
set -a; source .env; set +a

if [ -z "${MQTT_USER:-}" ] || [ -z "${MQTT_PASSWORD:-}" ]; then
  echo "ERRO: defina MQTT_USER e MQTT_PASSWORD no .env"; exit 1
fi
if [ "$MQTT_PASSWORD" = "troque-esta-senha" ]; then
  echo "ERRO: troque a MQTT_PASSWORD padrão no .env antes de continuar."; exit 1
fi

echo ">> Criando pastas de dados..."
mkdir -p mosquitto/data mosquitto/log backups

if [ ! -f homeassistant/secrets.yaml ]; then
  cp homeassistant/secrets.yaml.example homeassistant/secrets.yaml
  echo ">> Criado homeassistant/secrets.yaml"
fi

echo ">> Gerando senha do MQTT (mosquitto/config/passwd)..."
# Roda o utilitário dentro do container para não precisar instalar nada no host.
docker run --rm \
  -v "$PWD/mosquitto/config:/mosquitto/config" \
  -e MQTT_USER -e MQTT_PASSWORD \
  eclipse-mosquitto:2 \
  sh -c 'rm -f /mosquitto/config/passwd &&
         touch /mosquitto/config/passwd &&
         chmod 0700 /mosquitto/config/passwd &&
         mosquitto_passwd -b /mosquitto/config/passwd "$MQTT_USER" "$MQTT_PASSWORD" &&
         chown mosquitto:mosquitto /mosquitto/config/passwd'

echo
echo "Setup concluído. Próximos passos:"
echo "  docker compose up -d"
echo "Depois abra http://<IP-desta-máquina>:8123"
