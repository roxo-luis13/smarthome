# 05 — Aparelhos Wi-Fi e pela internet (nuvem)

Esta casa **não usa Zigbee**. Os aparelhos (tomadas, lâmpadas, interruptores,
ar-condicionado, TVs...) se conectam ao **Wi-Fi** e são controlados **pela
internet**, através da nuvem de cada fabricante.

## Como funciona

```
Home Assistant ──internet──► Nuvem do fabricante ──internet──► Aparelho Wi-Fi
(servidor da casa)           (Tuya, eWeLink, LG...)             (na sua casa)
```

1. Você instala o aparelho pelo **app do fabricante** (ex.: Smart Life), como
   faria normalmente.
2. No Home Assistant, adiciona a **integração** daquele fabricante e faz login
   com a mesma conta do app.
3. Os aparelhos da conta aparecem no HA e podem entrar em painéis e automações.

### Prós e contras

| Prós | Contras |
|---|---|
| Aparelhos baratos e fáceis de achar | **Sem internet, o HA não controla os aparelhos** (o app do fabricante também não) |
| Instalação simples (só o app) | Um pouco mais lento (≈0,5–2 s por comando) |
| Não precisa de nenhum adaptador | O fabricante pode mudar/limitar o acesso da nuvem |

Se no futuro quiser algo que funcione mesmo sem internet, veja
"Controle local" no fim desta página.

## Antes de comprar

- Pesquise `"<marca/modelo>" home assistant`.
- A maioria dos aparelhos Wi-Fi genéricos vendidos no Brasil funciona no app
  **Smart Life** (plataforma Tuya). **Se funciona no app Smart Life, funciona no
  Home Assistant** pela integração Tuya.
- Prefira usar **uma só plataforma** (ex.: tudo Smart Life): menos contas,
  menos integrações para manter.
- Aparelhos Wi-Fi quase sempre usam a rede **2,4 GHz**. Se o roteador separa as
  redes 2,4 e 5 GHz, conecte-os na de 2,4.

## Integrações mais comuns

Todas em *Configurações → Dispositivos e serviços → + Adicionar integração*.

### Tuya / Smart Life (mais comum)

1. No celular, instale o app **Smart Life** e cadastre os aparelhos nele.
2. No HA: adicionar integração **Tuya**.
3. Informe o **código de usuário**: no app Smart Life → *Eu* (Me) → ícone de
   engrenagem → *Conta e segurança* → *Código de usuário*.
4. O HA mostra um **QR code**: leia com o app Smart Life (ícone de leitor no
   canto superior da tela inicial) e confirme o login.
5. Os aparelhos aparecem. Coloque cada um na sua **área** (Sala, Quarto...).

Aparelhos novos adicionados no app aparecem sozinhos no HA (ou depois de
*Tuya → ⋮ → Recarregar*).

### LG ThinQ (ar-condicionado, geladeira, lava-roupas LG...)

Integração oficial **LG ThinQ**, que usa um *token de acesso pessoal* (PAT):

1. No navegador, acesse <https://connect-pat.lgthinq.com> e entre com a
   **mesma conta do app LG ThinQ**.
2. Clique em **ADD NEW TOKEN** (Adicionar novo token), dê um nome (ex.:
   `home-assistant`), **marque todas as permissões** e clique em **CREATE TOKEN**.
3. Copie o token gerado (um código longo).
4. No HA: adicionar integração **LG ThinQ** → cole o token → em país escolha
   **Brasil** → Enviar.
5. Os aparelhos da conta aparecem. Coloque cada um na sua área.

Se um dia trocar a senha da conta LG ou apagar o token, gere outro e
reconfigure a integração (*LG ThinQ → ⋮ → Reconfigurar*).

### Xiaomi Home (Mi Home)

A integração **oficial da Xiaomi** (*Xiaomi Home*) é instalada pelo **HACS**
(ver [03-home-assistant.md](03-home-assistant.md#7-hacs-loja-da-comunidade--opcional)).

1. Instale o HACS (uma vez) e reinicie o HA.
2. HACS → buscar **Xiaomi Home** → **Download** → reinicie o HA
   (*Configurações → Sistema → ⏻ → Reiniciar*).
3. **Ajuste necessário no Windows** — o login da Xiaomi sempre volta para o
   endereço `http://homeassistant.local:8123`, que na nossa instalação não existe
   (o servidor se chama `smarthome`). Faça o PC apontar esse nome para a VM:
   - Abra o **Bloco de Notas como administrador** (menu Iniciar → digite
     "Bloco de Notas" → botão direito → *Executar como administrador*).
   - *Arquivo → Abrir* → `C:\Windows\System32\drivers\etc\hosts`
     (mude o filtro de "Documentos de texto" para **Todos os arquivos**).
   - Acrescente no final a linha (com o IP da VM):
     ```
     192.168.0.130 homeassistant.local
     ```
   - Salve.
4. No HA (aberto **no navegador desse PC**): adicionar integração **Xiaomi Home**
   → aceite os avisos → escolha a **região do servidor** igual à do app
   (no app Xiaomi Home: *Perfil → Configurações → Região*; se os aparelhos não
   aparecerem, tente outra região) → faça login na conta Xiaomi → escolha a
   casa e os aparelhos.

Se no celular/outro PC o login pedir `homeassistant.local`, faça a configuração
pelo PC onde o arquivo `hosts` foi ajustado.

### Alexa

Há duas coisas diferentes:

1. **O HA falar com os Echo** (anunciar "a porta ficou aberta", tocar avisos,
   ver/controlar os Echo): integração **Alexa Devices** (*Amazon Alexa Devices*),
   que já vem no HA. Adicionar integração → **Alexa Devices** → país, e-mail e
   senha da Amazon e o **código de verificação** (a conta Amazon precisa ter a
   verificação em duas etapas ativada; o código vem do app autenticador/SMS).
   Se ela não aparecer ou não funcionar, a alternativa é **Alexa Media Player** (HACS).
2. **A Alexa controlar os aparelhos**: como os aparelhos são Smart Life, LG e
   Xiaomi, **continue usando as skills desses fabricantes na Alexa** — já
   funciona e não depende do HA. Só é preciso ligar a Alexa ao HA (Home
   Assistant Cloud, pago) se quiser comandar pela voz coisas que só existem no
   HA (cenas, scripts, "modo férias").

### Ordem recomendada para começar

1. **Smart Life** (a mais simples, só QR code).
2. **LG ThinQ** (token).
3. **HACS** → **Xiaomi Home** (precisa do ajuste no `hosts`).
4. **Alexa Devices**.

Depois de cada uma: coloque os aparelhos nas áreas, confira se ligam/desligam
pelo HA e faça um backup (`./scripts/backup.sh`).

### Sonoff (app eWeLink)

A integração mais usada é a **SonoffLAN**, instalada pelo HACS
([03-home-assistant.md](03-home-assistant.md#7-hacs-loja-da-comunidade--opcional)).
Depois de instalar: adicionar integração **Sonoff** → login da conta eWeLink.
Ela usa a nuvem e, quando possível, controla o aparelho direto pela rede (mais rápido).

### Outros

| Aparelhos | Integração |
|---|---|
| Samsung (TVs, ar-condicionado, SmartThings) | **SmartThings** |
| Ar-condicionado Midea (app SmartHome / MSmartHome) | **Midea AC LAN** (HACS) |
| Philips Hue | **Philips Hue** |
| TVs LG / Samsung | **LG webOS TV** / **Samsung Smart TV** |
| Google Home / Chromecast | **Google Cast** |
| Câmeras | Depende da marca; muitas funcionam com **ONVIF** ou **Generic Camera** (RTSP) |

## Falar com Alexa / Google Assistente

Para dizer "Alexa, ligue a luz da sala" controlando pelo HA:

- **Mais fácil**: Home Assistant Cloud (Nabu Casa, pago) — *Configurações →
  Home Assistant Cloud* → ative Alexa e/ou Google Assistente e escolha quais
  entidades expor. Também dá acesso remoto seguro ([09-manutencao.md](09-manutencao.md#acesso-de-fora-de-casa)).
- **Alternativa**: continuar usando a skill do próprio fabricante (ex.: skill
  Smart Life na Alexa). Funciona em paralelo com o HA.

## Quando a internet cai

- Os aparelhos continuam funcionando **manualmente** (botão/interruptor físico).
- O HA não consegue controlá-los até a internet voltar; automações que dependem
  deles falham nesse período.
- Ao voltar, as integrações reconectam sozinhas (pode levar alguns minutos).
  Se um aparelho ficar "Indisponível", *Configurações → Dispositivos e serviços →
  (integração) → ⋮ → Recarregar*.

Uma automação útil — avisar quando um aparelho ficar indisponível por muito tempo:

```yaml
alias: "Sistema - Aparelho offline"
triggers:
  - trigger: state
    entity_id: switch.tomada_sala
    to: "unavailable"
    for: "00:15:00"
actions:
  - action: notify.mobile_app_meu_celular
    data:
      message: "A tomada da sala está offline há 15 minutos."
mode: single
```

## Controle local (opcional, para o futuro)

Se quiser reduzir a dependência da internet, sem Zigbee:

- **Tuya Local** (HACS): controla os aparelhos Tuya direto pela rede de casa.
  Configuração mais trabalhosa (precisa da "local key" de cada aparelho).
- Ao comprar aparelhos novos, prefira os que já são locais: **Shelly**
  (interruptores/relés), aparelhos com **ESPHome** ou **Tasmota**. Eles usam o
  MQTT (Mosquitto) que já está instalado — ver [04-mqtt.md](04-mqtt.md).

## Boas práticas

- No roteador, **reserve IP** para os aparelhos mais importantes (evita
  reconexões estranhas).
- Dê nomes claros no app do fabricante e no HA: `Tomada Sala TV`, `Luz Quarto`.
- Ative a verificação em duas etapas nas contas dos fabricantes quando existir.
