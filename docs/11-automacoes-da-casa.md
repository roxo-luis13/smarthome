# 11 — Automações desta casa (prontas para colar)

Automações pensadas para os aparelhos desta casa. Cada uma está em YAML pronto:
crie pela interface e cole.

- **Automação:** *Configurações → Automações e cenas → + Criar automação →
  Criar nova automação → ⋮ → Editar em YAML* → apague o conteúdo, cole → **Salvar**.
- **Script:** *Configurações → Automações e cenas → aba Scripts → + Adicionar
  script → Criar novo script → ⋮ → Editar em YAML* → cole → **Salvar**.

Depois de salvar, tudo pode ser ajustado pelo editor visual.

## 0. Antes: confira os nomes dos seus aparelhos

Os exemplos usam os nomes abaixo. Veja os reais em *Configurações →
Entidades* (busque pelo nome) e **troque no YAML antes de salvar** — ou
renomeie a entidade no HA para ficar igual (clique na entidade → ⚙️ →
*ID da entidade*).

| Aparelho | Nome usado nos exemplos | Observação |
|---|---|---|
| Luz sala | `light.luz_sala` | pode aparecer como `switch.` |
| Luz corredor | `light.luz_corredor` | |
| Luz quarto | `light.luz_quarto` | |
| Luz cozinha | `light.luz_cozinha` | |
| Luz lavanderia | `light.luz_lavanderia` | |
| Luz quintal | `light.luz_quintal` | |
| Ventilador sala | `fan.ventilador_sala` | se for tomada/interruptor: `switch.ventilador_sala` e ações `switch.turn_on/off` |
| Ventilador quarto | `fan.ventilador_quarto` | idem |
| TV sala | `media_player.tv_sala` | depende da integração da TV |
| Irrigação | `switch.irrigacao` | |
| Interruptor livre | `switch.interruptor_livre` | usado como "botão boa noite" |
| Echo Dot 3 (sala) | `notify.echo_sala_announce` | criado pela integração Alexa Devices |
| Echo Dot 2 (cozinha) | `notify.echo_cozinha_announce` | idem |
| Previsão do tempo | `weather.forecast_casa` | criada no onboarding (pode ser `weather.forecast_home`) |

Dica: uma luz que aparece como `switch.luz_x` funciona igual; troque
`light.` por `switch.` **e** `light.turn_on/off` por `switch.turn_on/off`.

---

## Iluminação

### A1. Quintal acende no pôr do sol e apaga às 23h

```yaml
alias: "Quintal - Liga no pôr do sol, desliga às 23h"
description: "Acende a luz do quintal no pôr do sol e apaga às 23h."
triggers:
  - trigger: sun
    event: sunset
    id: ligar
  - trigger: time
    at: "23:00:00"
    id: desligar
actions:
  - choose:
      - conditions:
          - condition: trigger
            id: ligar
        sequence:
          - action: light.turn_on
            target:
              entity_id: light.luz_quintal
    default:
      - action: light.turn_off
        target:
          entity_id: light.luz_quintal
mode: single
```

### A2. Luz esquecida acesa na lavanderia/corredor apaga sozinha (15 min)

```yaml
alias: "Casa - Apaga lavanderia/corredor esquecidas"
description: "Se a luz da lavanderia ou do corredor ficar 15 min acesa, apaga."
triggers:
  - trigger: state
    entity_id:
      - light.luz_lavanderia
      - light.luz_corredor
    to: "on"
    for: "00:15:00"
actions:
  - action: light.turn_off
    target:
      entity_id: "{{ trigger.entity_id }}"
mode: parallel
```

### A3. Luz do quintal acesa de dia: apaga

```yaml
alias: "Quintal - Apaga se ficar acesa de dia"
description: "Às 8h, se a luz do quintal ainda estiver acesa, apaga."
triggers:
  - trigger: time
    at: "08:00:00"
conditions:
  - condition: state
    entity_id: light.luz_quintal
    state: "on"
actions:
  - action: light.turn_off
    target:
      entity_id: light.luz_quintal
mode: single
```

---

## Rotinas

### S1. Script "Boa noite"

Apaga tudo, deixa o ventilador do quarto ligado, liga o modo dormir e a Alexa
da sala confirma.

```yaml
alias: "Boa noite"
icon: mdi:weather-night
sequence:
  - action: light.turn_off
    target:
      entity_id:
        - light.luz_sala
        - light.luz_corredor
        - light.luz_cozinha
        - light.luz_lavanderia
        - light.luz_quintal
        - light.luz_quarto
  - action: fan.turn_off
    target:
      entity_id: fan.ventilador_sala
  - action: media_player.turn_off
    target:
      entity_id: media_player.tv_sala
    continue_on_error: true
  - action: fan.turn_on
    target:
      entity_id: fan.ventilador_quarto
  - action: input_boolean.turn_on
    target:
      entity_id: input_boolean.modo_dormir
  - action: notify.send_message
    target:
      entity_id: notify.echo_sala_announce
    data:
      message: "Boa noite! A casa está apagada."
    continue_on_error: true
mode: single
```

### A4. Interruptor livre vira o "botão boa noite"

O interruptor inteligente sem carga vira um botão: **qualquer toque** nele
roda o script "Boa noite". (Crie o script S1 antes.)

```yaml
alias: "Sala - Interruptor livre roda Boa noite"
description: "Qualquer mudança no interruptor livre dispara o script Boa noite."
triggers:
  - trigger: state
    entity_id: switch.interruptor_livre
    not_from:
      - unavailable
      - unknown
    not_to:
      - unavailable
      - unknown
actions:
  - action: script.boa_noite
mode: single
```

### A5. Bom dia (dias de semana)

Desliga o modo dormir e o ventilador do quarto, acende a cozinha e a Alexa
da cozinha diz a temperatura.

```yaml
alias: "Casa - Bom dia (seg a sex)"
description: "Rotina da manhã nos dias úteis."
triggers:
  - trigger: time
    at: "06:30:00"
conditions:
  - condition: time
    weekday: [mon, tue, wed, thu, fri]
  - condition: state
    entity_id: input_boolean.modo_ferias
    state: "off"
actions:
  - action: input_boolean.turn_off
    target:
      entity_id: input_boolean.modo_dormir
  - action: fan.turn_off
    target:
      entity_id: fan.ventilador_quarto
  - action: light.turn_on
    target:
      entity_id: light.luz_cozinha
  - action: notify.send_message
    target:
      entity_id: notify.echo_cozinha_announce
    data:
      message: >-
        Bom dia! Agora está fazendo
        {{ state_attr('weather.forecast_casa', 'temperature') | round(0) }} graus.
    continue_on_error: true
mode: single
```

### A6. Ventilador do quarto desliga de madrugada

```yaml
alias: "Quarto - Desliga ventilador às 5h"
description: "Evita o ventilador ligado a noite toda."
triggers:
  - trigger: time
    at: "05:00:00"
conditions:
  - condition: state
    entity_id: fan.ventilador_quarto
    state: "on"
actions:
  - action: fan.turn_off
    target:
      entity_id: fan.ventilador_quarto
mode: single
```

### A7. "Modo cinema": TV ligada à noite apaga corredor e cozinha

```yaml
alias: "Sala - Modo cinema"
description: "Ao ligar a TV depois do pôr do sol, apaga corredor e cozinha."
triggers:
  - trigger: state
    entity_id: media_player.tv_sala
    from: "off"
conditions:
  - condition: sun
    after: sunset
actions:
  - action: light.turn_off
    target:
      entity_id:
        - light.luz_corredor
        - light.luz_cozinha
mode: single
```

---

## Irrigação

Usa três ajustes criados em `homeassistant/packages/irrigacao.yaml`, que
aparecem como entidades na interface:

- **Irrigação automática** (`input_boolean.irrigacao_automatica`) — liga/desliga a rega programada.
- **Irrigação - horário** (`input_datetime.irrigacao_horario`) — ex.: 06:00.
- **Irrigação - duração** (`input_number.irrigacao_minutos`) — ex.: 15 min.

Na primeira vez, ajuste o horário e a duração (em *Configurações → Entidades*
ou colocando-os num painel) e ligue a "Irrigação automática".

### A8. Rega programada (pula se estiver chovendo)

```yaml
alias: "Quintal - Irrigação programada"
description: "Rega no horário escolhido pela duração escolhida; não rega se estiver chovendo."
triggers:
  - trigger: time
    at: input_datetime.irrigacao_horario
conditions:
  - condition: state
    entity_id: input_boolean.irrigacao_automatica
    state: "on"
  - condition: not
    conditions:
      - condition: state
        entity_id: weather.forecast_casa
        state:
          - rainy
          - pouring
          - lightning-rainy
actions:
  - action: switch.turn_on
    target:
      entity_id: switch.irrigacao
  - delay:
      minutes: "{{ states('input_number.irrigacao_minutos') | int(15) }}"
  - action: switch.turn_off
    target:
      entity_id: switch.irrigacao
mode: single
```

### A9. Segurança: irrigação nunca fica ligada mais de 60 min

Protege contra esquecer a irrigação ligada (manual ou por falha).

```yaml
alias: "Quintal - Irrigação: desliga após 60 min"
description: "Se a irrigação ficar ligada 60 min seguidos, desliga e avisa na cozinha."
triggers:
  - trigger: state
    entity_id: switch.irrigacao
    to: "on"
    for: "01:00:00"
actions:
  - action: switch.turn_off
    target:
      entity_id: switch.irrigacao
  - action: notify.send_message
    target:
      entity_id: notify.echo_cozinha_announce
    data:
      message: "Atenção: a irrigação ficou ligada uma hora e foi desligada."
    continue_on_error: true
mode: single
```

---

## Avisos e segurança

### A10. Aparelho importante ficou offline

```yaml
alias: "Sistema - Aparelho offline"
description: "Avisa na sala se a irrigação ou a luz do quintal ficarem indisponíveis por 30 min."
triggers:
  - trigger: state
    entity_id:
      - switch.irrigacao
      - light.luz_quintal
    to: "unavailable"
    for: "00:30:00"
actions:
  - action: notify.send_message
    target:
      entity_id: notify.echo_sala_announce
    data:
      message: "{{ state_attr(trigger.entity_id, 'friendly_name') }} está offline."
    continue_on_error: true
mode: parallel
```

### A11. Modo férias: simula presença

(Mesma ideia do [06-automacoes.md](06-automacoes.md), com as luzes desta casa.)

```yaml
alias: "Férias - Simular presença"
description: "Com o modo férias ligado, acende sala e quintal à noite em horários variados."
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
      entity_id:
        - light.luz_sala
        - light.luz_quintal
  - delay:
      hours: 3
      minutes: "{{ range(0, 50) | random }}"
  - action: light.turn_off
    target:
      entity_id:
        - light.luz_sala
        - light.luz_quintal
mode: single
```

---

## Ideias para depois

- **Presença pelo celular** (com o app do HA instalado): apagar tudo quando
  todos saírem; acender o quintal ao chegar à noite.
- **Ar-condicionado LG**: ligar o do quarto 15 min antes de dormir; desligar
  quando ativar o modo dormir + 3 horas.
- **Painel da casa**: um painel com botões para "Boa noite", irrigação manual e
  modos, para usar no celular.
- **Sensores baratos** (porta, movimento, temperatura — Wi-Fi/Smart Life):
  luz do corredor por movimento, aviso de portão aberto.

## Status nesta casa

Registrar aqui quais automações foram criadas e ajustes feitos:

- [ ] A1 Quintal pôr do sol / 23h
- [ ] A2 Lavanderia/corredor esquecidas
- [ ] A3 Quintal acesa de dia
- [ ] S1 Script Boa noite
- [ ] A4 Interruptor livre → Boa noite
- [ ] A5 Bom dia
- [ ] A6 Ventilador quarto às 5h
- [ ] A7 Modo cinema
- [ ] A8 Irrigação programada
- [ ] A9 Irrigação limite 60 min
- [ ] A10 Aparelho offline
- [ ] A11 Modo férias
