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
- [x] Instalar na máquina atual ([02a-windows-virtualbox.md](02a-windows-virtualbox.md) + [02-instalacao.md](02-instalacao.md)) — feito em 2026-09-24.
- [ ] Onboarding do HA e integrações dos aparelhos ([03-home-assistant.md](03-home-assistant.md)).
- [ ] (Opcional) Integração MQTT no HA ([04-mqtt.md](04-mqtt.md)).
- [ ] Adicionar os aparelhos Wi-Fi ([05-aparelhos-wifi-nuvem.md](05-aparelhos-wifi-nuvem.md)).
- [ ] Primeiro backup + cron diário ([07-backup.md](07-backup.md)).
- [ ] Migrar para o Raspberry Pi ([08-migracao-raspberry.md](08-migracao-raspberry.md)).

## 2026-09-23 — Windows agora, Raspberry Pi 1 depois

**Situação:** a máquina atual é Windows e o destino planejado era um Raspberry Pi 1.

**Feito:**
- Novo guia [02a-windows-virtualbox.md](02a-windows-virtualbox.md): VM Ubuntu
  Server no VirtualBox, rede em bridge, início automático da VM
  com o Windows, PC sem suspender.
- [08-migracao-raspberry.md](08-migracao-raspberry.md): tabela de modelos de
  Raspberry compatíveis e alternativa com mini PC usado.

**Decisões:**
- **VM Ubuntu no VirtualBox em vez de Docker Desktop/WSL2**: no Docker Desktop
  o HA não descobre aparelhos na rede nem acessa USB. Em bridge, a VM é um
  "computador" na rede da casa, igual ao destino final; o repositório e os
  scripts continuam os mesmos.
- **Raspberry Pi 1 não serve**: ARMv6 32 bits e 512 MB de RAM; o Home Assistant
  exige 64 bits e 2 GB+. Destinos viáveis: Raspberry Pi 4 (4 GB+), Pi 5 ou mini
  PC x86 usado com Ubuntu Server. A migração é a mesma nos três casos.

**Pendente:**
- [ ] Decidir e comprar o hardware definitivo (Pi 4/5 ou mini PC).
- [ ] Enquanto isso, rodar na VM do Windows.

## 2026-09-23 — Sem Zigbee: aparelhos Wi-Fi pela internet

**Situação:** a casa não vai usar Zigbee; os aparelhos serão Wi-Fi, controlados
pela internet (nuvem dos fabricantes, ex.: Smart Life/Tuya).

**Feito:**
- Removido o Zigbee2MQTT do `docker-compose.yml`, do `.env.example`, dos scripts
  e da documentação (pasta `zigbee2mqtt/` e `docs/05-zigbee.md` apagados).
- Novo guia [05-aparelhos-wifi-nuvem.md](05-aparelhos-wifi-nuvem.md): como
  integrar Tuya/Smart Life, eWeLink, LG, Samsung, Alexa; o que acontece quando
  a internet cai; opções de controle local para o futuro.
- Guia do Windows sem os passos de USB/Extension Pack.
- MQTT mantido, mas marcado como opcional.

**Por quê:** menos peças para manter; sem adaptador USB, a migração para outra
máquina fica ainda mais simples (só o backup).

**Como desfazer / voltar a usar Zigbee:** a versão com Zigbee2MQTT está no
histórico do git, no commit `065b6bb` (`docker-compose.yml`,
`zigbee2mqtt/configuration.example.yaml` e `docs/05-zigbee.md`):
`git show 065b6bb:docs/05-zigbee.md`.

## 2026-09-24 — Ajustes do guia do Windows durante a instalação real

**Feito:**
- [02a-windows-virtualbox.md](02a-windows-virtualbox.md): nomes da tela do
  VirtualBox 7.2 ("Proceed with Unattended Installation" deve ficar
  **desmarcado**), disco de 25 GB dinâmico com explicação do uso real,
  verificação/expansão do disco após instalar o Ubuntu, ISO Ubuntu 26.04 aceito,
  Extension Pack desnecessário.
- `scripts/instalar-docker.sh`: se o script oficial do Docker não suportar a
  versão do Ubuntu, instala pelos pacotes do Ubuntu (`docker.io` + `docker-compose-v2`).

**Por quê:** o assistente do VirtualBox 7.2 inverteu a opção (antes "pular",
agora "prosseguir com" instalação desassistida) e o ISO baixado foi o 26.04.

## 2026-09-24 — Instalação concluída na VM do Windows

**Feito:**
- VM `smarthome` no VirtualBox 7.2 (Windows), Ubuntu Server 26.04.1 LTS,
  4 GB RAM, 2 CPUs, disco dinâmico de 25 GB (LVM expandido para 23 GB com
  `lvextend`), rede em **bridge pela placa Wi-Fi** (Dell Wireless 1707) — funcionou.
- IP da VM: **192.168.0.130** — MAC `08:00:27:82:b7:66` (usar na reserva DHCP do roteador).
- Usuário do Ubuntu: `roxo`. Acesso: `ssh roxo@192.168.0.130`.
- Docker instalado pelo script oficial (suporta o Ubuntu 26.04).
- `setup.sh` + `docker compose up -d`: Home Assistant no ar em
  <http://192.168.0.130:8123>.

**Pendente:**
- [ ] Onboarding do Home Assistant (usuário, localização) — [03-home-assistant.md](03-home-assistant.md).
- [ ] Reservar o IP 192.168.0.130 no roteador (não urgente; adiado — se o IP mudar, ver `hostname -I` no console da VM).
- [ ] VM iniciar sozinha com o Windows e PC sem suspender — [02a, Passo 6](02a-windows-virtualbox.md#passo-6--deixar-a-vm-sempre-ligada).
- [ ] Primeiro backup — [07-backup.md](07-backup.md).

## 2026-09-24 — Apps/aparelhos da casa

**Apps em uso:** Alexa, Smart Life, LG ThinQ, Xiaomi Home.

**Feito:** [05-aparelhos-wifi-nuvem.md](05-aparelhos-wifi-nuvem.md) ganhou o
passo a passo de cada um: Tuya/Smart Life (QR code), LG ThinQ (token PAT),
Xiaomi Home (HACS + ajuste do `hosts` no Windows para `homeassistant.local`),
Alexa Devices (avisos nos Echo) e a recomendação de manter as skills dos
fabricantes na Alexa para comando de voz.

**Pendente:**
- [x] Smart Life (integração Tuya, nuvem) — funcionando (após corrigir o IPv6).
- [x] LG ThinQ (token PAT) — funcionando.
- [ ] Xiaomi Home (HACS).
- [ ] Alexa Devices (2 Echo Dot) — passo a passo detalhado no doc 05.

## 2026-09-24 — Smart Life lento pela nuvem → Tuya Local

**Situação:** integração Tuya importou os aparelhos, mas comandos pelo HA
levavam > 60 s ou não chegavam (o botão ficava "ligado" e a luz não acendia).
App Smart Life e Alexa normais. No servidor: ping, relógio (`timedatectl`) e
carga OK.

**Decisão:** controlar os aparelhos Smart Life pelo **Tuya Local** (HACS),
direto pela rede local; a nuvem só é usada no cadastro para obter as chaves.
Passo a passo em [05-aparelhos-wifi-nuvem.md](05-aparelhos-wifi-nuvem.md#controle-local--tuya-local-opcional).

**Como desfazer:** remover os aparelhos do Tuya Local e reativar os da
integração Tuya (nuvem).

**Pendente:**
- ~~Instalar HACS + Tuya Local e migrar cada aparelho~~ — **cancelado**: a
  causa real era o IPv6 (ver entrada seguinte). A integração Tuya (nuvem)
  continua em uso.

## 2026-09-24 — IPv6 quebrado na rede de casa

**Situação:** instalação do HACS falhou (`wget: can't connect to remote host:
Operation timed out` num endereço IPv6). Teste no servidor: IPv4 respondeu em
0,5 s; IPv6 deu timeout de 15 s. O roteador anuncia IPv6 (a VM recebe endereços
`2804:...`), mas a saída IPv6 para a internet não funciona.

**Decisão:** desligar o IPv6 na VM via `/etc/sysctl.d/99-sem-ipv6.conf`
(passo a passo em [10-solucao-de-problemas.md](10-solucao-de-problemas.md#downloadsintegrações-de-nuvem-travam-ou-dão-timed-out-ipv6-quebrado)).
Provável causa também da lentidão da integração Tuya (cada conexão tentava
IPv6 primeiro e esperava o timeout).

**Como desfazer:** `sudo rm /etc/sysctl.d/99-sem-ipv6.conf` e reiniciar a VM.

**Pendente:**
- [x] Testar de novo a integração Tuya (nuvem) depois de desligar o IPv6 —
      **ficou rápida**. Tuya Local não é necessário.
- [x] Instalar o HACS (arquivos baixados; falta concluir a ativação com o GitHub, se ainda não feita).

## Modelo para próximas entradas

```
## AAAA-MM-DD — Título curto
**Feito:** ...
**Por quê:** ...
**Como desfazer:** ...
```
