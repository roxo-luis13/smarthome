# 10 — Solução de problemas

Primeiro passo sempre:

```bash
./scripts/status.sh
docker compose logs --tail 100 homeassistant   # troque pelo serviço com problema
```

## Home Assistant não abre em `http://IP:8123`

- Aguarde 2 minutos após subir (a primeira inicialização é lenta, principalmente no Raspberry).
- `docker compose ps`: o container `homeassistant` está `Up`? Se estiver
  reiniciando sem parar, veja os logs.
- Erro de configuração depois de editar YAML:
  ```bash
  docker exec homeassistant python -m homeassistant --script check_config -c /config
  ```
  Corrija o arquivo indicado e `docker compose restart homeassistant`.
  Se não souber o que mudou: `git diff homeassistant/` e `git checkout -- arquivo` para desfazer.
- IP errado: `hostname -I` na máquina.
- Firewall ativo (`sudo ufw status`): libere com `sudo ufw allow 8123/tcp`
  (e `1883/tcp` se usar MQTT).

## Integração MQTT não conecta / "Connection refused"

- Broker no HA deve ser `localhost`, porta `1883`.
- Usuário/senha devem ser os do `.env`. Se trocou a senha no `.env`, rode
  `./scripts/setup.sh` e `docker compose restart mosquitto`.
- Logs: `docker compose logs mosquitto`. `not authorised` = usuário/senha errados.

## Mosquitto não sobe: erro no `passwd`

Rode `./scripts/setup.sh` de novo (recria o arquivo com dono/permissão corretos).

## Aparelho Wi-Fi "Indisponível" no Home Assistant

- A internet caiu? Aparelhos pela nuvem só respondem com internet.
- O aparelho funciona no app do fabricante (ex.: Smart Life)? Se não, o problema
  é no aparelho/Wi-Fi: desligue e ligue da tomada.
- Funciona no app mas não no HA: *Configurações → Dispositivos e serviços →
  (integração) → ⋮ → Recarregar*. Se aparecer "Reautenticar", faça login de novo.
- Aparelho novo não aparece: recarregue a integração (item acima).
- Veja mais em [05-aparelhos-wifi-nuvem.md](05-aparelhos-wifi-nuvem.md#quando-a-internet-cai).

## Dispositivo não é descoberto automaticamente

- Confirme que o HA está com `network_mode: host` (está no `docker-compose.yml`).
- Máquina e dispositivo precisam estar na **mesma rede** (mesma faixa de IP,
  não na rede de visitantes).
- Em Windows/macOS com Docker Desktop, descoberta não funciona bem — ver [02-instalacao.md](02-instalacao.md).

## `permission denied` ao rodar `docker`

Seu usuário não está no grupo `docker` ainda: saia e entre de novo na sessão
(ou `sudo reboot`). Confirme com `groups`.

## Disco cheio

```bash
docker image prune -f
ls -lh backups/          # apague backups antigos que já estão copiados fora
```
Reduza `purge_keep_days` em `homeassistant/configuration.yaml`.

## Raspberry travando/reiniciando sozinho

- Fonte fraca: `vcgencmd get_throttled` (resultado diferente de `0x0` indica
  subtensão/superaquecimento). Use a fonte oficial.
- Temperatura: `vcgencmd measure_temp` (acima de ~80 °C: melhore a refrigeração).
- Cartão SD corrompido: migre para SSD e restaure o último backup.

## Esqueci a senha do Home Assistant

Se houver outro usuário administrador, ele pode redefinir em *Configurações →
Pessoas*. Senão:

```bash
docker exec -it homeassistant hass --script auth --config /config change_password SEU_USUARIO NOVA_SENHA
docker compose restart homeassistant
```

## Começar do zero (último recurso)

```bash
./scripts/backup.sh                  # guarde, por via das dúvidas
docker compose down
sudo rm -rf homeassistant/.storage homeassistant/*.db* mosquitto/data
./scripts/setup.sh && docker compose up -d
```
(Isso apaga usuários e integrações; os aparelhos continuam no app do fabricante e é só adicionar a integração de novo.)
