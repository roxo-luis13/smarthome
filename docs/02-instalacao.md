# 02 — Instalação passo a passo

Este processo é o mesmo em um PC Linux e no Raspberry Pi. Leva ~20 minutos.

## Pré-requisitos

- Máquina com **Linux 64 bits** (Ubuntu 22.04+, Debian 12+ ou Raspberry Pi OS 64-bit).
- Ligada na rede da casa, de preferência **por cabo**.
- Acesso ao terminal (direto ou via `ssh`).
- Recomendado: no roteador, **reserve um IP fixo** (reserva DHCP) para essa
  máquina. Assim o endereço `http://IP:8123` nunca muda.

> **Estou no Windows ou macOS, e agora?** O Home Assistant em Docker depende de
> `network_mode: host` para descobrir dispositivos na rede, e isso funciona mal
> no Docker Desktop (Windows/macOS). Opções, em ordem de preferência:
> 1. Ir direto para o Raspberry Pi ([08-migracao-raspberry.md](08-migracao-raspberry.md), seção "Instalação do zero").
> 2. Usar um PC/notebook velho com Ubuntu.
> 3. No Windows, instalar Ubuntu no WSL2 e rodar lá — funciona para testar,
>    mas a descoberta automática de dispositivos e o USB (Zigbee) ficam limitados.

## Passo 1 — Instalar git e baixar o repositório

```bash
sudo apt update
sudo apt install -y git curl
cd ~
git clone https://github.com/roxo-luis13/smarthome.git
cd smarthome
```

> Se o repositório for privado, o GitHub vai pedir usuário e um **token**
> (não a senha). Crie em GitHub → Settings → Developer settings →
> Personal access tokens → *Fine-grained*, com acesso de leitura/escrita a este
> repositório (*Contents: Read and write*). Use o token como senha.

## Passo 2 — Instalar o Docker

```bash
./scripts/instalar-docker.sh
```

Depois **saia e entre de novo** na sessão (ou `sudo reboot`) para poder usar
`docker` sem `sudo`. Confirme:

```bash
docker run --rm hello-world
```

## Passo 3 — Configurar senhas e preparar pastas

```bash
./scripts/setup.sh
```

Na primeira vez ele cria o arquivo `.env` e para. Edite-o:

```bash
nano .env
```

- `MQTT_PASSWORD`: invente uma senha forte (só letras e números evita dor de cabeça).
- `TZ`: fuso horário (padrão `America/Sao_Paulo`).
- Deixe `COMPOSE_PROFILES=` vazio por enquanto (Zigbee é configurado depois).

Salve (`Ctrl+O`, `Enter`, `Ctrl+X`) e rode de novo:

```bash
./scripts/setup.sh
```

Ele cria as pastas de dados, o `homeassistant/secrets.yaml` e o arquivo de
senhas do MQTT.

## Passo 4 — Subir tudo

```bash
docker compose up -d
```

Na primeira vez baixa as imagens (≈1–2 GB, alguns minutos). Depois:

```bash
./scripts/status.sh
```

Deve mostrar `Home Assistant: OK` e `MQTT (Mosquitto): OK`. O HA pode levar
1–2 minutos para responder na primeira inicialização.

Os containers têm `restart: unless-stopped`: **voltam sozinhos** se a máquina
reiniciar ou faltar luz (desde que o Docker inicie com o sistema, o que o
script de instalação já configura).

## Passo 5 — Abrir o Home Assistant

Descubra o IP da máquina:

```bash
hostname -I | awk '{print $1}'
```

No navegador de qualquer aparelho da casa: `http://ESSE-IP:8123`.
Continue em [03-home-assistant.md](03-home-assistant.md).

## Passo 6 — Primeiro backup

Assim que terminar a configuração inicial do HA:

```bash
./scripts/backup.sh
```

E copie o arquivo de `backups/` para fora da máquina. Ver [07-backup.md](07-backup.md).

## Comandos do dia a dia

| Quero... | Comando |
|---|---|
| Ver status | `./scripts/status.sh` |
| Ver logs do HA | `docker compose logs -f homeassistant` (Ctrl+C sai) |
| Reiniciar o HA | `docker compose restart homeassistant` |
| Parar tudo | `docker compose down` |
| Subir tudo | `docker compose up -d` |
| Atualizar | `./scripts/atualizar.sh` |
