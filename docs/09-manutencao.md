# 09 — Manutenção, acesso remoto e segurança

## Atualizações

O Home Assistant lança versão nova todo mês (primeira quarta-feira) e correções
durante o mês.

```bash
./scripts/atualizar.sh
```

Faz backup, baixa as imagens novas, recria os containers e limpa imagens antigas.

Antes de atualizar o HA, leia as *breaking changes* das notas da versão:
<https://www.home-assistant.io/blog/> (categoria "Release notes").
Não há pressa: esperar alguns dias após o lançamento (versão `.1` ou `.2`) é
mais seguro.

### Travar uma versão

No `.env`: `HA_VERSION=2026.9.1` (em vez de `stable`). Útil se uma versão nova
quebrar algo. Volte para `stable` depois.

### Desfazer uma atualização ruim

```bash
./scripts/restaurar.sh backups/<backup-feito-pelo-atualizar>.tar.gz
# no .env, trave HA_VERSION na versão anterior
docker compose up -d
```

## Sistema operacional

De tempos em tempos (1x por mês):

```bash
sudo apt update && sudo apt full-upgrade -y
sudo reboot     # os containers voltam sozinhos
```

## Espaço em disco

```bash
df -h /                          # espaço livre
du -sh homeassistant/*.db        # tamanho do banco de histórico
docker system df                 # espaço usado pelo Docker
```

O banco guarda 10 dias de histórico (`purge_keep_days` em
`homeassistant/configuration.yaml`). Diminua se o disco estiver apertado.

## Acesso de fora de casa

**Não abra portas no roteador** para o HA. Opções seguras:

### Opção A — Tailscale (grátis, recomendado)

Cria uma rede privada entre seus aparelhos.

No servidor (PC ou Raspberry):

```bash
curl -fsSL https://tailscale.com/install.sh | sh
sudo tailscale up
```

Abra o link que aparecer e faça login. No celular, instale o app **Tailscale**
e entre com a mesma conta. Fora de casa, com o Tailscale ligado no celular,
acesse `http://smarthome:8123` (ou o IP `100.x.y.z` mostrado em
`tailscale ip -4`). No app do Home Assistant, coloque esse endereço como
**URL externa**.

### Opção B — Home Assistant Cloud (Nabu Casa, pago)

*Configurações → Home Assistant Cloud*. Acesso remoto sem configurar nada, e
integração fácil com Alexa/Google Assistente. Ajuda a financiar o projeto.

## Segurança

- Senha forte para cada usuário do HA; ative **autenticação em 2 fatores**
  (clique no seu perfil → *Módulos de autenticação multifator*).
- Nunca coloque senhas no git: use `.env` e `homeassistant/secrets.yaml`.
- O repositório no GitHub pode ser público ou privado; mesmo assim, prefira
  **privado** (nomes de dispositivos e rotinas revelam hábitos da casa).
- Backups contêm senhas: guarde em local privado.
- Mantenha HA, Docker e sistema atualizados.
- Contas dos fabricantes (Smart Life, eWeLink...): senha forte e verificação
  em duas etapas quando houver — quem entra nelas controla os aparelhos.
- Aparelhos Wi-Fi "da nuvem" podem ficar numa rede de visitantes/IoT separada,
  se o roteador permitir (o HA continua controlando, pois fala com eles pela nuvem).

## Checklist mensal

- [ ] `./scripts/atualizar.sh` (após ler as notas da versão)
- [ ] `sudo apt update && sudo apt full-upgrade -y`
- [ ] Conferir se o backup automático está gerando arquivos (`ls -lt backups/`)
- [ ] Copiar o último backup para fora da máquina
- [ ] `git status` → commit de automações novas
- [ ] Trocar pilhas de sensores com bateria baixa (o HA mostra o nível)
