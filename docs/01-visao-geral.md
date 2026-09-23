# 01 — Visão geral e arquitetura

## As peças

```
   Celular / PC (navegador ou app Home Assistant)
                │  rede da casa (ou de fora, via Tailscale/Nabu Casa)
                ▼
┌──────── Servidor (VM Ubuntu no Windows agora; Pi 4/5 ou mini PC depois) ────────┐
│  Docker                                                                         │
│  ┌──────────────────┐   MQTT (localhost)   ┌──────────────┐                     │
│  │  Home Assistant  │◄────────────────────►│  Mosquitto   │◄── Shelly/ESP/Tasmota│
│  │  :8123           │                      │  :1883       │    (opcional, local) │
│  └────────┬─────────┘                      └──────────────┘                     │
└───────────┼─────────────────────────────────────────────────────────────────────┘
            │ internet
            ▼
   Nuvem dos fabricantes (Tuya/Smart Life, eWeLink, LG ThinQ, SmartThings...)
            │ internet
            ▼
   Aparelhos Wi-Fi da casa (tomadas, lâmpadas, interruptores, ar-condicionado, TV)
```

- **Home Assistant (HA)**: o sistema central. Tem a interface web, guarda o
  estado dos dispositivos, roda as automações e fala com centenas de marcas
  através de "integrações".
- **Aparelhos Wi-Fi pela internet**: cada aparelho é instalado no app do
  fabricante; o HA faz login nessa mesma conta e passa a controlá-los pela
  nuvem. Detalhes em [05-aparelhos-wifi-nuvem.md](05-aparelhos-wifi-nuvem.md).
- **Mosquitto**: um *broker* MQTT — serviço de mensagens usado por aparelhos que
  funcionam **localmente** (Shelly, Tasmota, ESPHome). Hoje pode ficar sem uso;
  já fica pronto caso compre esse tipo de aparelho.
- **Zigbee**: não usado nesta casa.

## Por que Docker (e não Home Assistant OS)?

Há duas formas populares de instalar o HA:

| | Home Assistant OS | Docker (escolhido) |
|---|---|---|
| Instalação | Grava uma imagem no cartão/SSD, a máquina fica **dedicada** | Roda em qualquer Linux, junto com outras coisas |
| Add-ons (loja) | Sim | Não — os serviços extras ficam no `docker-compose.yml` |
| Mesmo processo no PC e no Raspberry | Não (no PC exige VM) | **Sim**, idêntico |
| Configuração versionada no git | Parcial | **Sim** |

Como o plano é começar no PC e depois mudar para o Raspberry, o Docker deixa os
dois ambientes iguais: a migração é "copiar um arquivo de backup e subir".

> Se no futuro preferir o Home Assistant OS no Raspberry, é possível: o HA OS
> importa backups do próprio HA (*Configurações → Sistema → Backups*). Veja a
> seção "Alternativa" em [08-migracao-raspberry.md](08-migracao-raspberry.md).

## Estrutura do repositório

```
smarthome/
├── docker-compose.yml          # Define os serviços (HA, Mosquitto)
├── .env.example                # Modelo de variáveis (senhas, fuso, versões)
├── .env                        # SUA cópia com senhas (NÃO vai para o git)
├── homeassistant/              # Pasta /config do Home Assistant
│   ├── configuration.yaml      #   configuração principal (versionada)
│   ├── automations.yaml        #   automações (a interface grava aqui)
│   ├── scripts.yaml, scenes.yaml
│   ├── packages/               #   grupos temáticos de configuração
│   ├── secrets.yaml.example    #   modelo de segredos
│   └── .storage/ *.db ...      #   estado/banco (NÃO vai para o git; vai no backup)
├── mosquitto/config/mosquitto.conf   # config do broker (versionada)
├── scripts/                    # instalar, setup, backup, restaurar, atualizar, status
├── backups/                    # backups gerados (NÃO vão para o git)
└── docs/                       # esta documentação
```

### O que vai para o git e o que não vai

- **Vai para o git**: arquivos de configuração que você escreve (YAML, scripts,
  docs). Isso permite ver o histórico de mudanças e recriar a estrutura.
- **Não vai para o git**: senhas (`.env`, `secrets.yaml`, `passwd`), banco de
  dados, integrações (logins nas nuvens dos fabricantes), usuários.
  **Tudo isso vai no backup** (`scripts/backup.sh`). Por isso: git + backup = casa
  completa.

## Hardware

- **Agora**: o PC com Windows, rodando uma VM Ubuntu no VirtualBox
  ([02a-windows-virtualbox.md](02a-windows-virtualbox.md)), ligado 24h.
- **Depois**: Raspberry Pi 4/5 ou mini PC usado. O **Raspberry Pi 1 não serve**
  (32 bits, 512 MB). Detalhes em [08-migracao-raspberry.md](08-migracao-raspberry.md#qual-raspberry-serve-e-qual-não-serve).
