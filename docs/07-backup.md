# 07 — Backup e restauração

## O que o backup contém

`scripts/backup.sh` empacota **a pasta inteira do repositório** (menos `.git` e
`backups/`) num único arquivo `backups/smarthome-AAAAMMDD-HHMMSS.tar.gz`:

- `.env` (senhas e configurações)
- `homeassistant/` completo: usuários, integrações, dispositivos, painéis,
  histórico (banco `home-assistant_v2.db`), `secrets.yaml`, HACS/custom_components
- `mosquitto/` (config + senhas + dados)
- `zigbee2mqtt/data/` (**chaves da rede Zigbee** e dispositivos pareados)

> O arquivo contém senhas. Guarde-o em local privado e **nunca** faça commit dele.

## Fazer backup

```bash
./scripts/backup.sh
```

Para os containers por alguns segundos (garante banco consistente) e sobe de
novo. Mantém os 10 mais recentes em `backups/`.

`./scripts/backup.sh --quente` faz sem parar nada (o banco de histórico pode
sair inconsistente; configurações ficam OK).

## Copiar para fora da máquina

Um backup que fica só na mesma máquina não protege contra cartão SD/disco
queimado. Exemplos:

```bash
# Do seu PC/notebook, puxando do servidor:
scp usuario@IP-DO-SERVIDOR:~/smarthome/backups/smarthome-*.tar.gz .

# Ou para um pendrive montado no servidor:
cp backups/smarthome-*.tar.gz /media/$USER/PENDRIVE/
```

## Backup automático (diário, 3h da manhã)

```bash
crontab -e
```

Adicione a linha (ajuste o caminho):

```
0 3 * * * cd /home/SEU_USUARIO/smarthome && ./scripts/backup.sh >> backups/backup.log 2>&1
```

O HA também tem backup próprio (*Configurações → Sistema → Backups*), que
cobre só o Home Assistant. O nosso script cobre a stack toda.

## Restaurar

Na mesma máquina ou em outra (com o repositório clonado e Docker instalado):

```bash
./scripts/restaurar.sh caminho/para/smarthome-AAAAMMDD-HHMMSS.tar.gz
# confira o .env (ex.: ZIGBEE_DEVICE)
docker compose up -d
./scripts/status.sh
```

O script pede confirmação, para os containers e sobrescreve os arquivos.

## Rotina recomendada

- Backup automático diário (cron acima).
- Backup manual **antes** de: atualizar, mexer em YAML, migrar de máquina.
- Uma vez por mês, copiar o backup mais recente para fora da máquina.
- Commits no git quando mudar automações/configuração.
