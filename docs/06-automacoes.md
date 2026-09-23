# 06 — Automações

Uma automação tem três partes:

- **Gatilho** (*trigger*): o que dispara. "Quando o sol se põe", "quando o sensor detecta movimento".
- **Condição** (*condition*, opcional): só continua se... "se alguém está em casa".
- **Ação** (*action*): o que fazer. "Acender a luz da sala".

## Criando pela interface (recomendado)

*Configurações → Automações e cenas → + Criar automação → Criar nova automação*.
Monte gatilho/condição/ação nos menus e salve. O HA grava em
`homeassistant/automations.yaml`.

Também dá para colar YAML: menu ⋮ → **Editar em YAML**. Os exemplos abaixo
podem ser colados assim — só troque os `entity_id` pelos seus (veja os nomes em
*Configurações → Entidades*).

## Exemplos prontos

### Acender luz da varanda no pôr do sol e apagar às 23h

```yaml
alias: "Varanda - Liga no pôr do sol"
triggers:
  - trigger: sun
    event: sunset
    offset: "-00:15:00"
actions:
  - action: light.turn_on
    target:
      entity_id: light.varanda
mode: single
```

```yaml
alias: "Varanda - Desliga às 23h"
triggers:
  - trigger: time
    at: "23:00:00"
actions:
  - action: light.turn_off
    target:
      entity_id: light.varanda
mode: single
```

### Luz por movimento (apaga 2 minutos depois)

```yaml
alias: "Corredor - Luz por movimento"
triggers:
  - trigger: state
    entity_id: binary_sensor.movimento_corredor
    to: "on"
conditions:
  - condition: state
    entity_id: input_boolean.modo_dormir
    state: "off"
actions:
  - action: light.turn_on
    target:
      entity_id: light.corredor
  - wait_for_trigger:
      - trigger: state
        entity_id: binary_sensor.movimento_corredor
        to: "off"
        for: "00:02:00"
  - action: light.turn_off
    target:
      entity_id: light.corredor
mode: restart
```

`mode: restart`: se detectar movimento de novo, recomeça a contagem.

### Aviso no celular: porta aberta há 5 minutos

```yaml
alias: "Entrada - Porta aberta há 5 min"
triggers:
  - trigger: state
    entity_id: binary_sensor.porta_entrada
    to: "on"
    for: "00:05:00"
actions:
  - action: notify.mobile_app_meu_celular
    data:
      title: "Porta aberta"
      message: "A porta da entrada está aberta há 5 minutos."
mode: single
```

`notify.mobile_app_meu_celular` é criado quando você instala o app no celular
([03-home-assistant.md](03-home-assistant.md#4-app-no-celular)).

### Modo férias: simular presença acendendo a sala à noite

Usa o interruptor virtual `input_boolean.modo_ferias` (criado em
`homeassistant/packages/modo_casa.yaml`).

```yaml
alias: "Férias - Simular presença"
triggers:
  - trigger: sun
    event: sunset
conditions:
  - condition: state
    entity_id: input_boolean.modo_ferias
    state: "on"
actions:
  - delay:
      minutes: "{{ range(5, 40) | random }}"
  - action: light.turn_on
    target:
      entity_id: light.sala
  - delay:
      hours: 3
      minutes: "{{ range(0, 45) | random }}"
  - action: light.turn_off
    target:
      entity_id: light.sala
mode: single
```

### Tudo desligado quando todos saem de casa

```yaml
alias: "Casa - Todos saíram"
triggers:
  - trigger: state
    entity_id: zone.home
    to: "0"
actions:
  - action: light.turn_off
    target:
      entity_id: all
  - action: notify.mobile_app_meu_celular
    data:
      message: "Todos saíram: luzes desligadas."
mode: single
```

`zone.home` conta quantas pessoas (com app no celular) estão em casa.

## Cenas e scripts

- **Cena**: um "retrato" de estados. Ex.: "Cinema" = luz da sala 20%, TV ligada.
  *Configurações → Automações e cenas → Cenas*.
- **Script**: sequência de ações que você dispara manualmente ou por automação
  (ex.: "Boa noite": apaga tudo, liga modo dormir).

## Blueprints

Modelos de automação prontos da comunidade. *Configurações → Automações e cenas →
Blueprints → Importar blueprint* e cole a URL. Busque em
<https://community.home-assistant.io/c/blueprints-exchange/53>.

## Boas práticas

- Nomeie com prefixo do cômodo: "Sala - ...", "Entrada - ...".
- Teste com o botão **Executar ações** e veja o **Rastreamento** (*Traces*) para
  entender por que uma automação rodou ou não.
- Depois de criar/editar, faça commit de `homeassistant/automations.yaml` no git.
