#!/usr/bin/env bash
# Instala Docker + Docker Compose em Linux (Ubuntu/Debian/Raspberry Pi OS).
# Uso: ./scripts/instalar-docker.sh
# Documentação: docs/02-instalacao.md
set -euo pipefail

if command -v docker >/dev/null 2>&1 && docker compose version >/dev/null 2>&1; then
  echo "Docker e Docker Compose já instalados:"
  docker --version
  docker compose version
  exit 0
fi

echo ">> Instalando Docker pelo script oficial (https://get.docker.com)..."
curl -fsSL https://get.docker.com | sudo sh

echo ">> Permitindo que o usuário '$USER' use o Docker sem sudo..."
sudo usermod -aG docker "$USER"

echo ">> Habilitando o Docker para iniciar junto com o sistema..."
sudo systemctl enable --now docker

echo
echo "Pronto! IMPORTANTE: saia e entre de novo na sessão (ou reinicie) para"
echo "o grupo 'docker' valer. Depois rode: ./scripts/setup.sh"
