# 08 — Migração para o Raspberry Pi

Resumo: preparar o Raspberry → backup no PC → desligar a stack do PC → restaurar
no Raspberry → subir. Os dispositivos, usuários, automações e o pareamento
Zigbee continuam iguais.

## Hardware recomendado

| Item | Recomendação |
|---|---|
| Placa | **Raspberry Pi 5 (4 GB ou 8 GB)** ou Raspberry Pi 4 (4 GB+) |
| Armazenamento | **SSD** (USB 3, ou NVMe com HAT no Pi 5). Cartão SD funciona, mas o banco de dados desgasta o cartão e é a causa nº 1 de falhas. Se usar SD, use um de boa marca, "High Endurance", 32 GB+. |
| Fonte | Oficial (Pi 5: 27 W USB-C; Pi 4: 15 W USB-C). Fonte fraca causa travamentos. |
| Rede | Cabo de rede até o roteador (mais estável que Wi-Fi) |
| Gabinete | Com dissipador/ventoinha (Pi 5: *Active Cooler*) |
| Opcional | Nobreak pequeno; adaptador Zigbee + extensor USB |

## Passo 1 — Gravar o sistema

1. No PC, instale o **Raspberry Pi Imager**: <https://www.raspberrypi.com/software/>.
2. Escolha o modelo do Pi → **Raspberry Pi OS Lite (64-bit)** (em "Raspberry Pi
   OS (other)") → o SSD/cartão.
3. Em **Editar configurações** (engrenagem / "Customisation"):
   - Hostname: `smarthome`
   - Usuário e senha (anote!)
   - Wi-Fi: só se não for usar cabo
   - Fuso horário: `America/Sao_Paulo`, teclado `br`
   - Aba Serviços: **Habilitar SSH** (com senha, ou melhor, com chave pública)
4. Grave, conecte no Pi, ligue o cabo de rede e a energia. Espere ~2 min.

## Passo 2 — Acessar e atualizar o Raspberry

Do PC:

```bash
ssh SEU_USUARIO@smarthome.local
```

(Se `smarthome.local` não resolver, pegue o IP na lista de dispositivos do
roteador.) No Raspberry:

```bash
sudo apt update && sudo apt full-upgrade -y
sudo apt install -y git curl
sudo reboot
```

No roteador, **reserve um IP fixo** para o Raspberry.

## Passo 3 — Instalar a stack (sem subir ainda)

```bash
ssh SEU_USUARIO@smarthome.local
git clone https://github.com/roxo-luis13/smarthome.git
cd smarthome
./scripts/instalar-docker.sh
exit            # sair e entrar de novo para valer o grupo docker
```

## Passo 4 — Backup final no PC

No **PC antigo**:

```bash
cd ~/smarthome
git status                    # se houver mudanças: git add -A && git commit -m "..." && git push
./scripts/backup.sh
docker compose down           # desliga a stack antiga (evita dois HA controlando a casa)
scp backups/smarthome-*.tar.gz SEU_USUARIO@smarthome.local:~/
```

(Se houver mais de um backup, copie só o mais recente.)

Se usa Zigbee: **desconecte o adaptador do PC** e conecte no Raspberry (com o extensor).

## Passo 5 — Restaurar no Raspberry

```bash
ssh SEU_USUARIO@smarthome.local
cd ~/smarthome
git pull
./scripts/restaurar.sh ~/smarthome-AAAAMMDD-HHMMSS.tar.gz
```

Confira o `.env`:

```bash
ls -l /dev/serial/by-id/      # se usa Zigbee: confirme o caminho do adaptador
nano .env                     # ajuste ZIGBEE_DEVICE se mudou
```

Suba e verifique:

```bash
docker compose up -d
./scripts/status.sh
docker compose logs -f homeassistant    # Ctrl+C para sair
```

As imagens são baixadas na versão ARM automaticamente (mesmo `docker-compose.yml`).

## Passo 6 — Ajustes pós-migração

- Acesse `http://smarthome.local:8123` (ou `http://IP-DO-PI:8123`) e faça login
  com o mesmo usuário de antes.
- **App do celular**: se o endereço mudou, em *Configurações do app →
  Servidores* atualize a URL.
- **Integrações por IP**: dispositivos que se conectam ao MQTT pelo IP da máquina
  (Tasmota, Shelly, ESP) precisam apontar para o **IP novo**. Uma alternativa é
  dar ao Raspberry o mesmo IP que o PC tinha (reserva DHCP no roteador).
- Faça um backup novo no Raspberry e configure o backup automático
  ([07-backup.md](07-backup.md#backup-automático-diário-3h-da-manhã)).
- Deixe o PC antigo com a stack desligada por alguns dias como plano B.

## Voltar atrás (se algo der errado)

No Raspberry: `docker compose down`. Reconecte o adaptador Zigbee no PC e, no PC:
`docker compose up -d`. Tudo volta como estava no momento do backup.

## Instalação do zero no Raspberry (sem migrar)

Passos 1 a 3, depois siga [02-instalacao.md](02-instalacao.md) a partir do
Passo 3 (`./scripts/setup.sh`).

## Alternativa: Home Assistant OS

Se um dia preferir o Home Assistant OS no Raspberry (sistema dedicado, com loja
de add-ons):

1. No PC (stack atual): *Configurações → Sistema → Backups → Criar backup* e baixe o arquivo.
2. Grave o **Home Assistant OS** no Pi com o Raspberry Pi Imager
   (*Other specific-purpose OS → Home assistant and home automation*).
3. Na tela inicial do HA OS, escolha **Restaurar de backup** e envie o arquivo.
4. Instale os add-ons **Mosquitto broker** e **Zigbee2MQTT**, e reconfigure-os
   (as chaves Zigbee estão em `zigbee2mqtt/data/configuration.yaml` do backup
   deste repositório — copie `network_key`, `pan_id` e `ext_pan_id` para o
   add-on para não precisar parear tudo de novo).

Este repositório/scripts deixam de ser usados nesse caso.
