# smarthome

Automação residencial com **Home Assistant** rodando em **Docker**, pensada para
funcionar igual em um PC Linux hoje e em um **Raspberry Pi** depois (basta copiar
um arquivo de backup).

| Serviço | Para que serve | Endereço |
|---|---|---|
| Home Assistant | Cérebro da casa: dispositivos, painéis, automações | `http://IP:8123` |
| Mosquitto (MQTT) | "Correio" entre dispositivos (Zigbee, ESP, Tasmota...) | porta `1883` |
| Zigbee2MQTT (opcional) | Ponte para dispositivos Zigbee via adaptador USB | `http://IP:8080` |

## Início rápido (máquina Linux)

```bash
git clone https://github.com/roxo-luis13/smarthome.git
cd smarthome
./scripts/instalar-docker.sh   # só na primeira vez; depois saia e entre na sessão
./scripts/setup.sh             # cria o .env -> edite a senha -> rode de novo
docker compose up -d
./scripts/status.sh
```

Abra `http://IP-da-máquina:8123` e siga [docs/03-home-assistant.md](docs/03-home-assistant.md).

## Documentação

Tudo está em [`docs/`](docs/README.md), em ordem de leitura:

1. [Visão geral e arquitetura](docs/01-visao-geral.md)
2. [Instalação passo a passo](docs/02-instalacao.md)
3. [Primeiros passos no Home Assistant](docs/03-home-assistant.md)
4. [MQTT](docs/04-mqtt.md)
5. [Zigbee (opcional)](docs/05-zigbee.md)
6. [Automações](docs/06-automacoes.md)
7. [Backup e restauração](docs/07-backup.md)
8. [Migração para o Raspberry Pi](docs/08-migracao-raspberry.md)
9. [Manutenção, acesso remoto e segurança](docs/09-manutencao.md)
10. [Solução de problemas](docs/10-solucao-de-problemas.md)

Histórico do que foi feito e por quê: [docs/HISTORICO.md](docs/HISTORICO.md).

## Scripts

| Script | O que faz |
|---|---|
| `scripts/instalar-docker.sh` | Instala Docker + Compose (Ubuntu/Debian/Raspberry Pi OS) |
| `scripts/setup.sh` | Prepara pastas, modelos e senha do MQTT (pode rodar de novo) |
| `scripts/status.sh` | Mostra se tudo está no ar |
| `scripts/backup.sh` | Gera backup completo em `backups/` |
| `scripts/restaurar.sh ARQUIVO` | Restaura um backup (usado na migração) |
| `scripts/atualizar.sh` | Faz backup e atualiza todas as imagens |
