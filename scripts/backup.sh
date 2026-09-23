#!/usr/bin/env bash
# Gera um backup completo (configuração + dados + segredos) em backups/.
# É ESTE arquivo que você leva para o Raspberry na migração.
# Uso: ./scripts/backup.sh            (para os containers por alguns segundos)
#      ./scripts/backup.sh --quente   (não para nada; banco pode sair inconsistente)
# Documentação: docs/07-backup.md
set -euo pipefail
cd "$(dirname "$0")/.."

ARQUIVO="smarthome-$(date +%Y%m%d-%H%M%S).tar.gz"
PARAR=1
[ "${1:-}" = "--quente" ] && PARAR=0

if [ "$PARAR" = 1 ]; then
  echo ">> Parando containers para um backup consistente..."
  docker compose stop
fi

echo ">> Gerando backups/$ARQUIVO ..."
# O tar roda dentro de um container porque alguns arquivos pertencem ao root
# (criados pelo HA) e não seriam legíveis pelo seu usuário.
docker run --rm -v "$PWD:/src" -w /src alpine \
  tar czf "backups/$ARQUIVO" \
    --exclude=./backups --exclude=./.git \
    --exclude='./homeassistant/*.log*' \
    .
docker run --rm -v "$PWD/backups:/b" alpine chown "$(id -u):$(id -g)" "/b/$ARQUIVO"

if [ "$PARAR" = 1 ]; then
  echo ">> Subindo containers novamente..."
  docker compose up -d
fi

# Mantém só os 10 backups mais recentes
ls -1t backups/smarthome-*.tar.gz 2>/dev/null | tail -n +11 | xargs -r rm -f

echo "Backup pronto: backups/$ARQUIVO ($(du -h "backups/$ARQUIVO" | cut -f1))"
echo "Copie-o para FORA desta máquina (pendrive, nuvem, outro PC)."
