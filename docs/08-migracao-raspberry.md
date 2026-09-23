# 08 — Migração para o Raspberry Pi

Resumo: preparar o Raspberry → backup no PC → desligar a stack do PC → restaurar
no Raspberry → subir. Aparelhos, integrações (logins nas nuvens), usuários e
automações continuam iguais — não é preciso reconfigurar os aparelhos.

## Qual Raspberry serve (e qual não serve)

| Modelo | Serve? | Motivo |
|---|---|---|
| **Raspberry Pi 1** (A, B, B+, Zero/Zero W) | **Não** | Processador ARMv6 de 32 bits e 256–512 MB de RAM. O Home Assistant atual só roda em 64 bits e precisa de 2 GB+ de RAM; não existe imagem para ARMv6. |
| Raspberry Pi 2 | Não | 32 bits, 1 GB de RAM |
| Raspberry Pi 3 (B/B+) | Não recomendado | 1 GB de RAM: roda com muita lentidão e trava com frequência |
| **Raspberry Pi 4 (4 GB+)** | Sim | |
| **Raspberry Pi 5 (4 GB ou 8 GB)** | Sim (melhor) | |

Descobrir o modelo de um Raspberry: `cat /proc/device-tree/model`.

### Alternativa ao Raspberry: mini PC usado

Um **mini PC x86 usado** (ex.: Lenovo ThinkCentre Tiny, Dell OptiPlex Micro,
HP EliteDesk Mini, ou um mini PC com Intel N100) costuma custar o mesmo ou menos
que um Pi 5 com fonte, SSD e gabinete, e é mais rápido. Já vem com SSD, gasta
pouca energia (≈6–15 W) e usa **exatamente o mesmo processo** deste guia: instale
o **Ubuntu Server 24.04** nele (pendrive gravado com o
[Rufus](https://rufus.ie) ou o [balenaEtcher](https://etcher.balena.io)), habilite
o SSH durante a instalação e siga daqui a partir do **Passo 2** (os comandos
são os mesmos, trocando `smarthome.local` pelo IP do mini PC).

### E o Raspberry Pi 1 que já tenho?

Ele não roda esta stack. Usos possíveis para ele, independentes deste projeto:
Pi-hole (bloqueador de anúncios da rede), servidor de impressão, ou projetos de
eletrônica. Não é necessário para a automação.

## Hardware recomendado

| Item | Recomendação |
|---|---|
| Placa | **Raspberry Pi 5 (4 GB ou 8 GB)** ou Raspberry Pi 4 (4 GB+) |
| Armazenamento | **SSD** (USB 3, ou NVMe com HAT no Pi 5). Cartão SD funciona, mas o banco de dados desgasta o cartão e é a causa nº 1 de falhas. Se usar SD, use um de boa marca, "High Endurance", 32 GB+. |
| Fonte | Oficial (Pi 5: 27 W USB-C; Pi 4: 15 W USB-C). Fonte fraca causa travamentos. |
| Rede | Cabo de rede até o roteador (mais estável que Wi-Fi) |
| Gabinete | Com dissipador/ventoinha (Pi 5: *Active Cooler*) |
| Opcional | Nobreak pequeno (roteador + servidor) |

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

No **PC antigo** (se é a VM do Windows, rode estes comandos via ssh na VM e o
`scp` pelo PowerShell, veja [02a-windows-virtualbox.md](02a-windows-virtualbox.md#migrando-da-vm-para-outra-máquina-depois)):

```bash
cd ~/smarthome
git status                    # se houver mudanças: git add -A && git commit -m "..." && git push
./scripts/backup.sh
docker compose down           # desliga a stack antiga (evita dois HA controlando a casa)
scp backups/smarthome-*.tar.gz SEU_USUARIO@smarthome.local:~/
```

(Se houver mais de um backup, copie só o mais recente.)

## Passo 5 — Restaurar no Raspberry

```bash
ssh SEU_USUARIO@smarthome.local
cd ~/smarthome
git pull
./scripts/restaurar.sh ~/smarthome-AAAAMMDD-HHMMSS.tar.gz
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

No Raspberry: `docker compose down`. No PC (ou na VM do Windows):
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
4. (Opcional) Instale o add-on **Mosquitto broker** se usar aparelhos MQTT.

Este repositório/scripts deixam de ser usados nesse caso.
