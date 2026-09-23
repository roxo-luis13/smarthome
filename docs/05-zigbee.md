# 05 — Zigbee (opcional)

Só precisa disto se tiver um **adaptador Zigbee USB**. Sem ele, pule.

## Por que Zigbee

Sensores de porta, movimento, temperatura, botões, tomadas e lâmpadas Zigbee
são baratos, gastam pouca bateria (1–2 anos) e **funcionam sem internet**.
Aparelhos Zigbee ligados na tomada (tomadas, lâmpadas) também funcionam como
repetidores, aumentando o alcance da rede.

## Adaptadores recomendados

| Adaptador | `adapter:` no config |
|---|---|
| Sonoff ZBDongle-E | `ember` |
| Home Assistant Connect ZBT-1 (SkyConnect) | `ember` |
| Sonoff ZBDongle-P (CC2652P) | `zstack` |
| SMLIGHT SLZB-06 (via rede) | `zstack` ou `ember` conforme firmware — ver docs do Zigbee2MQTT |

Use um **cabo extensor USB** (≈1 m): portas USB 3 e SSDs geram interferência
na frequência de 2,4 GHz.

## Passo a passo

### 1. Descobrir o caminho do adaptador

Conecte o adaptador e rode:

```bash
ls -l /dev/serial/by-id/
```

Algo como:

```
usb-ITead_Sonoff_Zigbee_3.0_USB_Dongle_Plus_V2_20240123-if00-port0 -> ../../ttyACM0
```

Use o caminho **completo** em `/dev/serial/by-id/...` — ele não muda quando você
troca de porta USB ou reinicia (diferente de `/dev/ttyUSB0`/`ttyACM0`).

### 2. Configurar o `.env`

```bash
COMPOSE_PROFILES=zigbee
ZIGBEE_DEVICE=/dev/serial/by-id/usb-ITead_Sonoff_Zigbee_3.0_USB_Dongle_Plus_V2_20240123-if00-port0
```

### 3. Ajustar o tipo de adaptador

Edite `zigbee2mqtt/data/configuration.yaml` (criado pelo `setup.sh`), linha
`adapter:`, conforme a tabela acima.

### 4. Subir

```bash
docker compose up -d
docker compose logs -f zigbee2mqtt
```

Espere a mensagem `Zigbee2MQTT started!`. Na primeira execução ele gera as
chaves da rede Zigbee e as grava em `zigbee2mqtt/data/configuration.yaml`.
**Faça um backup logo depois** (`./scripts/backup.sh`): sem essas chaves, todos
os dispositivos precisam ser pareados de novo.

### 5. Parear dispositivos

1. Abra `http://IP:8080` (interface do Zigbee2MQTT).
2. Clique em **Permit join (All)** — fica aberto por alguns minutos.
3. Coloque o dispositivo em modo de pareamento (geralmente segurar o botão
   ~5 s até piscar; veja o manual ou a página do modelo em
   <https://www.zigbee2mqtt.io/supported-devices/>).
4. Ele aparece na lista. **Renomeie** com um nome claro (ex.: `sensor_porta_entrada`)
   e marque "Update Home Assistant entity ID".
5. Com a integração MQTT configurada no HA ([04-mqtt.md](04-mqtt.md)), o
   dispositivo aparece automaticamente no HA.
6. Desligue o **Permit join** ao terminar.

Dica: pareie primeiro os aparelhos de tomada (repetidores), perto do adaptador,
e depois os de bateria.

## Na migração para o Raspberry

O adaptador vai junto. Basta: backup no PC → restaurar no Pi → atualizar
`ZIGBEE_DEVICE` no `.env` do Pi (o `by-id` normalmente é igual) → subir.
Os dispositivos continuam pareados. Ver [08-migracao-raspberry.md](08-migracao-raspberry.md).
