# 01 — Visão geral e arquitetura

## As peças

```
                         Rede da casa (Wi-Fi / cabo)
   Celular / PC  ───────────────┐
   (navegador ou app HA)        │
                                ▼
┌──────────────────── Máquina (PC Linux agora, Raspberry Pi depois) ─────────────────┐
│  Docker                                                                            │
│  ┌──────────────────┐   MQTT    ┌──────────────┐   MQTT   ┌──────────────────┐     │
│  │  Home Assistant  │◄─────────►│  Mosquitto   │◄────────►│  Zigbee2MQTT     │     │
│  │  :8123           │ localhost │  :1883       │          │  :8080 (opcional)│     │
│  └────────┬─────────┘           └──────▲───────┘          └────────┬─────────┘     │
│           │ Wi-Fi/LAN (Tuya, Chromecast, TVs...)│ ESP/Tasmota       │ USB           │
└───────────┼─────────────────────────────────────┼──────────────────┼───────────────┘
            ▼                                     ▼                  ▼
     Dispositivos Wi-Fi                  Dispositivos MQTT    Adaptador Zigbee USB
                                                               └─► sensores, lâmpadas,
                                                                   tomadas Zigbee
```

- **Home Assistant (HA)**: o sistema central. Tem a interface web, guarda o
  estado dos dispositivos, roda as automações e fala com centenas de marcas
  através de "integrações".
- **Mosquitto**: um *broker* MQTT — um serviço de mensagens simples que muitos
  dispositivos de automação usam (Zigbee2MQTT, Tasmota, ESPHome, Shelly...).
  Mesmo que não use nada disso hoje, já deixa pronto.
- **Zigbee2MQTT**: só é necessário com um adaptador USB Zigbee. Zigbee é um
  protocolo sem fio de baixo consumo, muito usado em sensores (porta, movimento,
  temperatura) e lâmpadas. Não depende de nuvem/internet.

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
├── docker-compose.yml          # Define os serviços (HA, Mosquitto, Zigbee2MQTT)
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
├── zigbee2mqtt/configuration.example.yaml  # modelo; o real fica em zigbee2mqtt/data/
├── scripts/                    # instalar, setup, backup, restaurar, atualizar, status
├── backups/                    # backups gerados (NÃO vão para o git)
└── docs/                       # esta documentação
```

### O que vai para o git e o que não vai

- **Vai para o git**: arquivos de configuração que você escreve (YAML, scripts,
  docs). Isso permite ver o histórico de mudanças e recriar a estrutura.
- **Não vai para o git**: senhas (`.env`, `secrets.yaml`, `passwd`), banco de
  dados, dispositivos pareados, usuários, chaves da rede Zigbee.
  **Tudo isso vai no backup** (`scripts/backup.sh`). Por isso: git + backup = casa
  completa.

## Hardware

- **Agora**: o PC com Windows, rodando uma VM Ubuntu no VirtualBox
  ([02a-windows-virtualbox.md](02a-windows-virtualbox.md)), ligado 24h.
- **Depois**: Raspberry Pi 4/5 ou mini PC usado. O **Raspberry Pi 1 não serve**
  (32 bits, 512 MB). Detalhes em [08-migracao-raspberry.md](08-migracao-raspberry.md#qual-raspberry-serve-e-qual-não-serve).
- **Zigbee (opcional)**: adaptador USB como *Sonoff ZBDongle-E*, *Sonoff ZBDongle-P*,
  *Home Assistant Connect ZBT-1* (antigo SkyConnect). Use um cabo extensor USB
  (≈1 m) para afastá-lo do computador — reduz interferência.
