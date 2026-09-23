# 03 — Primeiros passos no Home Assistant

## 1. Assistente inicial (onboarding)

Em `http://IP:8123`:

1. **Criar minha casa inteligente** → crie o usuário administrador.
   Anote a senha num gerenciador de senhas.
2. **Localização**: marque sua casa no mapa (usado para nascer/pôr do sol,
   clima e presença). Confirme fuso horário, moeda (BRL) e unidades (métrico).
3. **Compartilhar dados**: opcional.
4. **Dispositivos encontrados**: o HA mostra o que descobriu na rede
   (Chromecast, TVs, impressoras...). Pode adicionar agora ou depois.

Configurações de nome, localização, usuários e integrações ficam salvas em
`homeassistant/.storage/` — por isso vão no **backup**, não no git.

## 2. Organizar a casa

*Configurações → Áreas, rótulos e zonas*:

- Crie **áreas** (Sala, Cozinha, Quarto, Área externa...).
- Cada dispositivo adicionado deve ser colocado numa área: os painéis e comandos
  de voz ficam muito mais organizados.

## 3. Usuários da família

*Configurações → Pessoas → Adicionar pessoa*. Cada pessoa pode ter login próprio
(marque "Administrador" só para quem precisa). Com o app no celular, a pessoa
vira um rastreador de presença ("em casa"/"fora").

## 4. App no celular

1. Instale **Home Assistant** (Android: Play Store; iPhone: App Store).
2. Com o celular no Wi-Fi de casa, o app acha o servidor sozinho; se não achar,
   digite `http://IP:8123`.
3. Faça login e permita localização e notificações.

Isso cria:
- `notify.mobile_app_<nome_do_celular>` → para receber notificações de automações.
- `device_tracker.<nome_do_celular>` → presença em casa.

Para acessar de **fora de casa**, veja [09-manutencao.md](09-manutencao.md#acesso-de-fora-de-casa).

## 5. Adicionar dispositivos (integrações)

*Configurações → Dispositivos e serviços → + Adicionar integração*. Casos comuns
no Brasil:

| Seus aparelhos | Integração | Observação |
|---|---|---|
| Tomadas/lâmpadas "Smart Life" / "Tuya" / muitas marcas genéricas | **Tuya** | Faça login com a conta do app Smart Life (QR code). Depende da nuvem. |
| Sonoff com app eWeLink | **SonoffLAN** (via HACS) | Controle local, sem nuvem. |
| Philips Hue | **Philips Hue** | Descoberta automática; aperte o botão da bridge. |
| Google Home / Chromecast | **Google Cast** | Descoberta automática. |
| Alexa (controlar a casa por voz) | **Alexa Media Player** (HACS) ou Home Assistant Cloud | |
| Smart TV Samsung / LG | **Samsung Smart TV** / **LG webOS** | Aceite o pedido na TV. |
| Ar-condicionado com Wi-Fi | Depende da marca (LG ThinQ, SmartThings, Midea...) | |
| Shelly | **Shelly** | Local, sem nuvem. |
| Sensores Zigbee | Via Zigbee2MQTT | Ver [05-zigbee.md](05-zigbee.md) |
| ESP32/ESP8266 | **ESPHome** ou MQTT | |

Dica: antes de comprar um aparelho, pesquise "`<modelo>` home assistant".
Prefira coisas que funcionam **localmente** (Zigbee, Shelly, ESPHome): continuam
funcionando se a internet cair e respondem mais rápido.

## 6. Integração MQTT

Necessária para Zigbee2MQTT e dispositivos MQTT. Passo a passo em
[04-mqtt.md](04-mqtt.md#conectar-o-home-assistant-ao-mqtt).

## 7. HACS (loja da comunidade) — opcional

O HACS instala integrações e cards criados pela comunidade (ex.: SonoffLAN).

```bash
docker exec -it homeassistant bash -c "wget -O - https://get.hacs.xyz | bash -"
docker compose restart homeassistant
```

Depois: *Configurações → Dispositivos e serviços → + Adicionar integração →
HACS* e siga o login com a conta do GitHub. As integrações instaladas pelo HACS
ficam em `homeassistant/custom_components/` (vão no backup).

## 8. Painel (dashboard)

A *Visão geral* é gerada automaticamente. Para personalizar: menu ⋮ →
**Editar painel** → "Assumir controle". Organize por áreas e deixe na tela
inicial só o que usa todo dia.

## 9. Arquivos de configuração (YAML)

Quase tudo é feito pela interface, mas alguns ajustes ficam nos arquivos em
`homeassistant/` (versionados no git):

| Arquivo | Conteúdo |
|---|---|
| `configuration.yaml` | Configuração principal; já inclui os demais arquivos |
| `automations.yaml` | Automações (a interface grava aqui) |
| `scripts.yaml` / `scenes.yaml` | Scripts e cenas (a interface grava aqui) |
| `packages/*.yaml` | Configurações agrupadas por tema (ex.: `modo_casa.yaml` cria os interruptores virtuais "Modo férias" e "Modo dormir") |
| `secrets.yaml` | Senhas usadas nos YAML (`!secret nome`). Fora do git. |

Depois de editar um YAML, **valide** antes de reiniciar:

```bash
docker exec homeassistant python -m homeassistant --script check_config -c /config
docker compose restart homeassistant
```

(ou pela interface: *Ferramentas de desenvolvedor → YAML → Verificar configuração*).

Mudanças feitas pela interface em `automations.yaml`/`scripts.yaml`/`scenes.yaml`
aparecem no `git status`. Vale fazer commit de vez em quando:

```bash
git add homeassistant && git commit -m "Atualiza automações" && git push
```
