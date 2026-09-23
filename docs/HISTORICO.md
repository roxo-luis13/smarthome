# Histórico e decisões

Registro do que foi feito neste repositório e por quê. Acrescente uma entrada
sempre que mudar algo importante (novo serviço, novo dispositivo, migração).

## 2026-09-23 — Estrutura inicial

**Feito:**
- `docker-compose.yml` com Home Assistant, Mosquitto (MQTT) e Zigbee2MQTT
  (este último opcional, ativado com `COMPOSE_PROFILES=zigbee` no `.env`).
- Configuração inicial do HA (`homeassistant/`): `default_config`, automações,
  scripts, cenas, *packages*, histórico de 10 dias. Uma automação de exemplo
  (notificação quando o HA inicia) e interruptores virtuais "Modo férias" e
  "Modo dormir" (`packages/modo_casa.yaml`).
- Mosquitto com autenticação obrigatória; senha gerada a partir do `.env`.
- Scripts: `instalar-docker`, `setup`, `status`, `backup`, `restaurar`, `atualizar`.
- Documentação completa em `docs/`.

**Testado** (em um Linux x86_64 com Docker 29 / Compose 5):
- `setup.sh` → `docker compose up -d` → HA respondendo na 8123 e MQTT na 1883.
- `check_config` do HA sem erros; exemplos de automação da doc 06 validados.
- MQTT aceita o usuário do `.env` e recusa senha errada e acesso anônimo.
- Zigbee2MQTT aceita a configuração (falha só por falta do adaptador físico, como esperado).
- Migração simulada: backup → cópia limpa do repositório → `restaurar.sh` →
  HA e MQTT funcionando com os mesmos dados e senhas.

**Decisões:**
- **Docker em vez de Home Assistant OS**: mesmo processo no PC e no Raspberry,
  configuração no git, migração = restaurar um arquivo. (Ver [01-visao-geral.md](01-visao-geral.md).)
- **Imagem do HA pelo Docker Hub** (`homeassistant/home-assistant`) — é a mesma
  imagem oficial publicada no `ghcr.io`, e funciona em redes que bloqueiam o ghcr.
- **Backup via container `alpine`**: arquivos criados pelos containers
  pertencem ao root; fazer o `tar` dentro de um container evita precisar de `sudo`.
- **Config do Mosquitto montada como somente leitura**: impede o container de
  mudar o dono dos arquivos versionados no git.
- **Zigbee2MQTT**: modelo versionado (`configuration.example.yaml`) e arquivo real
  fora do git, porque o Z2M grava nele as chaves da rede Zigbee. Usuário/senha
  MQTT injetados por variáveis de ambiente, vindos do `.env`.
- **Zigbee opcional via perfil**: sem adaptador, o `docker compose up -d` não
  tenta subir o Z2M (que falharia sem o dispositivo USB).

**Pendente (fazer na casa):**
- [ ] Instalar na máquina atual ([02-instalacao.md](02-instalacao.md)).
- [ ] Onboarding do HA e integrações dos aparelhos ([03-home-assistant.md](03-home-assistant.md)).
- [ ] Integração MQTT no HA ([04-mqtt.md](04-mqtt.md)).
- [ ] (Se tiver adaptador) Zigbee ([05-zigbee.md](05-zigbee.md)).
- [ ] Primeiro backup + cron diário ([07-backup.md](07-backup.md)).
- [ ] Migrar para o Raspberry Pi ([08-migracao-raspberry.md](08-migracao-raspberry.md)).

## Modelo para próximas entradas

```
## AAAA-MM-DD — Título curto
**Feito:** ...
**Por quê:** ...
**Como desfazer:** ...
```
