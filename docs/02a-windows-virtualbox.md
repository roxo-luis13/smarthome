# 02a — Rodando no Windows (máquina virtual Ubuntu)

No Windows, o Docker Desktop não deixa o Home Assistant enxergar direito a rede
da casa (descoberta de aparelhos). A solução é
criar uma **máquina virtual (VM) Ubuntu** dentro do Windows com o VirtualBox.
Para a rede da casa, a VM parece um computador separado, com IP próprio.

Vantagem: dentro da VM, tudo é **exatamente igual** ao que roda depois no
Raspberry/mini PC. A migração continua sendo "backup → restaurar".

```
Windows
└── VirtualBox
    └── VM "smarthome" (Ubuntu Server, IP próprio na rede da casa)
        └── Docker: Home Assistant + Mosquitto
```

## Requisitos

- Windows 10 ou 11, 64 bits, com **8 GB de RAM ou mais** (a VM usa 2–4 GB).
- ~25 GB livres em disco (na prática a VM ocupa uns 10 GB; veja o Passo 2).
- Virtualização ligada na BIOS (Intel VT-x / AMD-V). Confira no Gerenciador de
  Tarefas → Desempenho → CPU → "Virtualização: Habilitado".
- O PC precisa ficar **ligado 24h** enquanto for o servidor da casa.

## Passo 1 — Baixar o que precisa

1. **VirtualBox** (Windows hosts): <https://www.virtualbox.org/wiki/Downloads>.
   Instale com as opções padrão (a rede pisca durante a instalação; normal).
2. **Ubuntu Server LTS** (arquivo `.iso`, ex.: `ubuntu-26.04.1-live-server-amd64.iso`):
   <https://ubuntu.com/download/server>. Versões LTS (24.04, 26.04...) funcionam igual.

Não é preciso baixar o *VirtualBox Extension Pack* (só serviria para USB).

## Passo 2 — Criar a VM

No VirtualBox → **Novo** (nomes da tela do VirtualBox 7.2):

| Campo | Valor |
|---|---|
| VM Name | `smarthome` |
| ISO Image | o `.iso` do Ubuntu Server baixado |
| OS / Distribution | Linux / Ubuntu (preenchidos sozinhos) |
| OS Version | Ubuntu (64-bit) mais recente da lista — não precisa ser a versão exata do ISO |
| **Proceed with Unattended Installation** | **DESMARCADO** (aparece a mensagem "...o SO do convidado será instalado manualmente") |
| Memória | 4096 MB (mínimo 2048) |
| Processadores | 2 |
| Disco | 25 GB, com *Pre-allocate Full Size* **desmarcado** |

> **Por que desmarcar a instalação desassistida?** Nela o VirtualBox instala o
> Ubuntu sozinho e não instala o servidor SSH, que usamos para operar a VM.
> Em versões mais antigas do VirtualBox a opção se chama *"Pular instalação
> desassistida"* (e aí deve ser **marcada**). Se não encontrar nenhuma das duas:
> crie a VM **sem** escolher o ISO e depois, em *Configurações → Armazenamento*,
> clique no drive "Vazio" → ícone de disco → *Escolher um arquivo de disco* → o ISO.
>
> **Sobre o disco**: "dinamicamente alocado" significa que o arquivo começa
> pequeno e cresce conforme o uso — os 25 GB são o limite, não o espaço ocupado.
> Uso real esperado: Ubuntu ≈5 GB + imagens Docker ≈2 GB + histórico/backups
> ≈1–3 GB. O arquivo não encolhe sozinho, por isso não vale exagerar.

Depois, com a VM selecionada → **Configurações**:

- **Rede → Adaptador 1 → Conectado a: Placa em modo Bridge** ("Bridged Adapter"),
  e em *Nome* escolha a placa de rede real do PC (a de cabo, se houver).
  **Este é o ajuste mais importante**: é o que dá à VM um IP próprio na rede da casa.
  Use o PC ligado **por cabo** ao roteador; bridge por Wi-Fi às vezes falha
  (veja "Problemas" no fim).
- **Sistema → Placa-mãe**: marque *Relógio do hardware em UTC*.

## Passo 3 — Instalar o Ubuntu Server na VM

**Iniciar** a VM e seguir o instalador (teclado: setas + Enter):

1. Idioma: *English* (os erros ficam mais fáceis de pesquisar) ou Português.
2. Teclado: *Portuguese (Brazil)*.
3. Tipo: *Ubuntu Server*.
4. Rede: deve aparecer um IP da sua rede (ex.: `192.168.0.50`). **Anote.**
   Se aparecer `10.0.2.x`, a rede não está em Bridge: volte ao Passo 2.
5. Proxy: vazio. Mirror: padrão.
6. Disco: *Use an entire disk* (é o disco virtual, não o do Windows).
7. Perfil: seu nome, **nome do servidor `smarthome`**, usuário e senha (anote!).
8. Ubuntu Pro: *Skip*.
9. **SSH: marque "Install OpenSSH server"**.
10. Snaps: não marque nada (o Docker instalamos do jeito certo depois).
11. Ao terminar, **Reboot Now**. Se pedir, tire o ISO (Enter).

Depois do reinício, faça login na janela da VM e confira se o Ubuntu usou o
disco inteiro (às vezes o instalador deixa parte livre):

```bash
df -h /
```

Se o tamanho (`Size`) for bem menor que o disco criado (ex.: 12G num disco de
25 GB), expanda:

```bash
sudo lvextend -r -l +100%FREE /dev/ubuntu-vg/ubuntu-lv
```

## Passo 4 — Acessar a VM pelo Windows

A janela da VM é pouco prática (não dá para copiar/colar). Use o terminal do
Windows: abra o **PowerShell** ou o **Terminal** e digite:

```powershell
ssh SEU_USUARIO@192.168.0.50     # o IP anotado no Passo 3
```

Responda `yes` na primeira vez e digite a senha. Agora dá para colar comandos
com o botão direito do mouse.

Descobrir o IP de novo, se precisar: faça login na janela da VM e rode `hostname -I`.

## Passo 5 — Instalar a automação

Dentro da VM (via ssh), siga o guia normal
[02-instalacao.md](02-instalacao.md) a partir do **Passo 1**. Resumo:

```bash
sudo apt update && sudo apt full-upgrade -y
sudo apt install -y git curl
git clone https://github.com/roxo-luis13/smarthome.git
cd smarthome
./scripts/instalar-docker.sh
exit                         # sai do ssh; entre de novo
```

```bash
ssh SEU_USUARIO@192.168.0.50
cd smarthome
./scripts/setup.sh           # cria o .env
nano .env                    # troque MQTT_PASSWORD; Ctrl+O, Enter, Ctrl+X
./scripts/setup.sh
docker compose up -d
./scripts/status.sh
```

No navegador do Windows (ou do celular): `http://192.168.0.50:8123`.
Continue em [03-home-assistant.md](03-home-assistant.md).

**Reserve esse IP no roteador** (reserva DHCP para o endereço MAC da VM, que
aparece em Configurações → Rede → Avançado no VirtualBox). Assim ele nunca muda.

## Passo 6 — Deixar a VM sempre ligada

### 6.1 Iniciar a VM sozinha, sem janela, quando o Windows liga

Abra o **PowerShell** (normal, não precisa ser administrador) e rode:

```powershell
$vbox = "C:\Program Files\Oracle\VirtualBox\VBoxManage.exe"
$acao = New-ScheduledTaskAction -Execute $vbox -Argument 'startvm "smarthome" --type headless'
$gatilho = New-ScheduledTaskTrigger -AtLogOn -User $env:USERNAME
Register-ScheduledTask -TaskName "Iniciar VM smarthome" -Action $acao -Trigger $gatilho
```

Isso cria uma tarefa no *Agendador de Tarefas* que liga a VM "sem cabeça"
(sem janela) ao entrar no Windows. Para ver/controlar a VM, abra o VirtualBox
(ela aparece como "Executando"). Os containers dentro dela sobem sozinhos.

Como a tarefa roda **ao fazer logon**, se o PC reiniciar (ex.: Windows Update)
é preciso alguém entrar no Windows. Para não depender disso, ative o login
automático: tecla Windows+R → `netplwiz` → desmarque *"Os usuários devem digitar
um nome de usuário e uma senha..."* (se a opção não aparecer, em Configurações →
Contas → Opções de entrada, desligue *"Para maior segurança, permitir apenas
entrada do Windows Hello..."*).

Para remover a tarefa: `Unregister-ScheduledTask -TaskName "Iniciar VM smarthome"`.

### 6.2 Não deixar o PC dormir

Configurações → Sistema → **Energia** → *Suspender*: **Nunca** (na tomada).
A tela pode desligar, o PC não.

### 6.3 Desligar a VM com segurança

Antes de desligar/reiniciar o Windows manualmente, desligue a VM direito para
não corromper o banco de dados:

```powershell
& "C:\Program Files\Oracle\VirtualBox\VBoxManage.exe" controlvm smarthome acpipowerbutton
```

(ou, via ssh na VM: `sudo poweroff`).

### 6.4 Windows Update

Configurações → Windows Update → Opções avançadas → **Horário ativo**: marque
um período amplo (ex.: 6h às 0h) para as reinicializações ocorrerem de madrugada.

## Migrando da VM para outra máquina depois

Igual a qualquer migração ([08-migracao-raspberry.md](08-migracao-raspberry.md)).
O backup fica dentro da VM; para trazê-lo para o Windows:

```powershell
scp SEU_USUARIO@192.168.0.50:~/smarthome/backups/smarthome-*.tar.gz .
```

## Problemas

- **VM pega IP `10.0.2.x`**: a rede está em NAT. Mude para *Placa em modo Bridge*
  e reinicie a VM (`sudo reboot`).
- **VM não pega IP nenhum em Bridge usando Wi-Fi**: alguns roteadores/placas
  Wi-Fi não aceitam bridge. Soluções: ligar o PC no roteador por cabo e fazer
  bridge nessa placa; ou, em último caso, usar NAT com redirecionamento de
  portas (Configurações → Rede → Avançado → Redirecionamento de portas:
  8123→8123, 1883→1883, 2222→22). Nesse modo a descoberta automática
  de aparelhos não funciona; acesse `http://IP-DO-WINDOWS:8123` e
  `ssh -p 2222 SEU_USUARIO@localhost`.
- **"VT-x is not available"**: ative a virtualização na BIOS/UEFI do PC.
- **Muito lento**: se o recurso "Hyper-V"/"Plataforma de Máquina Virtual" do
  Windows estiver ativo, o VirtualBox fica mais lento (mas funciona). Dê mais
  RAM/CPU à VM se o PC tiver sobrando.
- **Firewall do Windows perguntou sobre o VirtualBox**: permita em redes privadas.

## Alternativa: Home Assistant OS em VM

O Home Assistant oferece uma VM pronta (`.vdi` para VirtualBox) com o sistema
dedicado e loja de add-ons: <https://www.home-assistant.io/installation/windows>.
É mais simples de instalar, mas sai do modelo deste repositório (Docker +
scripts + git). Se escolher esse caminho, a migração futura é feita pelos
backups do próprio HA (*Configurações → Sistema → Backups*) e o destino também
precisa rodar Home Assistant OS.
