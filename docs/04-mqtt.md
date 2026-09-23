# 04 — MQTT (Mosquitto)

> **Nesta casa o MQTT é opcional**: os aparelhos atuais são Wi-Fi pela nuvem
> e não o usam. O Mosquitto fica rodando (gasta quase nada) para o caso de
> comprar aparelhos locais como Shelly, Tasmota ou ESPHome.

MQTT é um protocolo de mensagens do tipo "publica/assina": um dispositivo
publica `sala/sensor {"temperature": 24}` e quem assinou esse
*tópico* recebe. O **Mosquitto** é o servidor (broker) que distribui as mensagens.

## Como está configurado

- Arquivo: `mosquitto/config/mosquitto.conf`.
- Porta `1883` aberta na rede local.
- **Sem acesso anônimo**: exige usuário/senha.
- Usuário/senha vêm do `.env` (`MQTT_USER`/`MQTT_PASSWORD`); o
  `scripts/setup.sh` gera o arquivo criptografado `mosquitto/config/passwd`.

## Conectar o Home Assistant ao MQTT

1. *Configurações → Dispositivos e serviços → + Adicionar integração → MQTT*.
2. Preencha:
   - **Broker**: `localhost` (o HA roda na rede do host e o Mosquitto publica a porta 1883 nele)
   - **Porta**: `1883`
   - **Usuário** / **Senha**: os do `.env`
3. Enviar. Pronto — dispositivos que se anunciam via MQTT (Tasmota,
   ESPHome, Shelly) passam a aparecer sozinhos.

## Testar

Publicar uma mensagem de teste:

```bash
source .env
docker exec mosquitto mosquitto_pub -h localhost -u "$MQTT_USER" -P "$MQTT_PASSWORD" -t teste -m "ola"
```

Escutar todas as mensagens (Ctrl+C para sair):

```bash
docker exec -it mosquitto mosquitto_sub -h localhost -u "$MQTT_USER" -P "$MQTT_PASSWORD" -t '#' -v
```

No HA: *Configurações → Dispositivos e serviços → MQTT → Configurar* permite
publicar/escutar tópicos pela interface.

## Trocar a senha

1. Edite `MQTT_PASSWORD` no `.env`.
2. `./scripts/setup.sh` (regera o `passwd`).
3. `docker compose restart mosquitto`
4. Atualize a senha na integração MQTT do HA (*MQTT → ⋮ → Reconfigurar*).

## Dispositivos na rede se conectando ao MQTT

Aparelhos como Tasmota, Shelly ou ESP devem apontar para:
`IP-da-máquina : 1883`, com o mesmo usuário/senha.
Se quiser um usuário separado por dispositivo, adicione com:

```bash
docker run --rm -it -v "$PWD/mosquitto/config:/mosquitto/config" eclipse-mosquitto:2 \
  mosquitto_passwd /mosquitto/config/passwd NOVO_USUARIO
docker compose restart mosquitto
```

(Atenção: `scripts/setup.sh` recria o arquivo só com o usuário do `.env`;
se adicionar usuários extras, anote-os nesta documentação.)
