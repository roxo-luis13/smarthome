# Documentação

Guia completo para montar, operar e migrar a automação da casa. Se um dia
precisar refazer tudo do zero em outro lugar, siga os arquivos **na ordem**.

| # | Documento | Quando ler |
|---|---|---|
| 01 | [Visão geral](01-visao-geral.md) | Para entender as peças e a estrutura do repositório |
| 02 | [Instalação](02-instalacao.md) | Instalar em uma máquina nova (Linux) |
| 02a | [Windows (VirtualBox)](02a-windows-virtualbox.md) | Se a máquina for Windows: criar a VM Ubuntu antes do 02 |
| 03 | [Home Assistant](03-home-assistant.md) | Primeira configuração, app no celular, integrações |
| 04 | [MQTT](04-mqtt.md) | Conectar o HA ao broker e a dispositivos MQTT |
| 05 | [Aparelhos Wi-Fi / nuvem](05-aparelhos-wifi-nuvem.md) | Adicionar tomadas, lâmpadas, ar etc. (Smart Life/Tuya, eWeLink...) |
| 06 | [Automações](06-automacoes.md) | Criar regras ("se X, então Y") com exemplos prontos |
| 07 | [Backup](07-backup.md) | Antes de qualquer mudança grande, e periodicamente |
| 08 | [Migração para Raspberry](08-migracao-raspberry.md) | Mudar do PC para o Raspberry Pi 4/5 ou mini PC (Pi 1 não serve) |
| 09 | [Manutenção](09-manutencao.md) | Atualizações, acesso de fora de casa, segurança |
| 10 | [Solução de problemas](10-solucao-de-problemas.md) | Quando algo não funcionar |
| 11 | [Automações desta casa](11-automacoes-da-casa.md) | Automações prontas para os aparelhos da casa (sala, quarto, cozinha, quintal) |
| — | [Histórico](HISTORICO.md) | Registro do que foi feito e das decisões tomadas |

## Resumo em 10 linhas

1. Linux + Docker instalados (`scripts/instalar-docker.sh`). No Windows: VM Ubuntu no VirtualBox (02a).
2. `git clone` deste repositório.
3. `./scripts/setup.sh` → edita `.env` → `./scripts/setup.sh` de novo.
4. `docker compose up -d`.
5. Abre `http://IP:8123`, cria usuário, instala o app no celular.
6. Adiciona as integrações dos aparelhos (ex.: Tuya/Smart Life) — doc 05.
7. (Opcional) Integração MQTT (`localhost`, porta `1883`, usuário/senha do `.env`).
8. Cria automações.
9. `./scripts/backup.sh` e guarda o arquivo fora da máquina.
10. Na máquina nova: passos 1–2, `./scripts/restaurar.sh backup.tar.gz`, `docker compose up -d`.
