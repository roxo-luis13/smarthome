#!/usr/bin/env bash
# Restaura um backup gerado por backup.sh para esta pasta.
# Uso: ./scripts/restaurar.sh backups/smarthome-AAAAMMDD-HHMMSS.tar.gz
# Documentação: docs/07-backup.md e docs/08-migracao-raspberry.md
set -euo pipefail
cd "$(dirname "$0")/.."

BACKUP="${1:-}"
if [ -z "$BACKUP" ] || [ ! -f "$BACKUP" ]; then
  echo "Uso: $0 caminho/do/backup.tar.gz"; exit 1
fi
BACKUP="$(cd "$(dirname "$BACKUP")" && pwd)/$(basename "$BACKUP")"

echo "ATENÇÃO: isto sobrescreve configuração e dados atuais desta pasta."
read -r -p "Continuar? [s/N] " resp
[ "$resp" = "s" ] || [ "$resp" = "S" ] || { echo "Cancelado."; exit 1; }

echo ">> Parando containers..."
docker compose down 2>/dev/null || true

echo ">> Extraindo backup..."
docker run --rm -v "$PWD:/dst" -v "$BACKUP:/backup.tar.gz:ro" -w /dst alpine \
  tar xzf /backup.tar.gz

echo
echo "Restaurado. Confira o .env (ex.: ZIGBEE_DEVICE pode mudar de máquina)"
echo "e suba com: docker compose up -d"
