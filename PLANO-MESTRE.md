# Plano mestre --- Auditoria e recuperação da multimídia Mitsubishi ASX 2014

**Versão:** 1.0 --- 16/11/2026\
**Uso:** entregar este arquivo integralmente ao Claude Code, Codex ou
ChatGPT.\
**Objetivo principal:** recuperar a estabilidade da central e o
funcionamento de Android Auto e Apple CarPlay com **o mínimo possível de
ações e interrupções do proprietário**. Investigar substituição por
sistema mais leve **somente se tecnicamente viável e vantajoso**.

> **Instrução ao agente:** trate este documento como especificação de
> execução. Prossiga autonomamente em pesquisa, análise e preparação
> local, sem perguntas desnecessárias. Não interprete autonomia como
> permissão para alterar a multimídia, o veículo ou instalar firmware.
> Quando houver bloqueio físico ou de segurança, pare apenas aquela
> etapa e continue as independentes.

## 1. Contexto consolidado

### 1.1 Identificação observada em fotografias da central

  ---------------------------------------------------------------------------
  Campo                    Valor                     Confiança
  ------------------------ ------------------------- ------------------------
  Veículo                  Mitsubishi ASX, ano 2014  Informado pelo
                                                     proprietário

  Central                  Multimídia aftermarket,   Informado pelo
                           marca comercial           proprietário
                           desconhecida              

  Identificador exibido    `ZCD9200-6956-MIPI-5G`    Fotografado

  Software                 `V002.03.13.003.00`       Fotografado

  MCU                      `V088.156.76`             Fotografado

  Wi-Fi                    `WIFID40L-240910`         Fotografado

  Data indicada no         `02/04/2025`              Lida anteriormente nas
  firmware                                           fotos; verificar
                                                     significado/formato

  Atualização              Menu `FW Update — MP10`   Observado nas fotos

  Aplicativos/interfaces   `Autolink`, `HI-LINK`,    Fotografados/relatados
                           `iOS Mirror`; Android     
                           Auto e CarPlay            

  SO                       **Desconhecido**;         Não confirmado
                           Linux/RTOS/proprietário é 
                           hipótese, não fato        

  CPU/SoC, RAM, eMMC,      Desconhecidos             Não confirmado
  fabricante/OEM                                     

  Interface de depuração   Não encontrada nos menus  Relato do proprietário

  Sobre o produto          Apenas pop-up com         Relato do proprietário
                           informações já            
                           fotografadas              

  USB                      Cabo USB **fêmea** saindo Relato do proprietário
                           da central, fora do       
                           painel                    

  Wi-Fi                    Existe e já é usado para  Relato do proprietário
                           projeção; conexão a       
                           hotspot comum não         
                           confirmada                
  ---------------------------------------------------------------------------

**Não confundir ZCD9200 com ZLink:** o aplicativo inicialmente foi
chamado de "ZLink" por hipótese; as telas mostram **Autolink / HI-LINK /
iOS Mirror**. Não presumir arquitetura Android apenas pela existência de
Android Auto.

### 1.2 Sintomas e histórico

-   A central **funcionava antes**; posteriormente ficou lenta.
-   Durante Android Auto, o aplicativo de projeção fecha, a central
    congela por instantes e volta à tela inicial; ocorre quase a cada
    minuto, segundo o relato.
-   Em algumas ocorrências, a central **reinicia**.
-   O iPhone/CarPlay deixou de conectar, embora antes funcionasse.
-   Até no rádio, **sem celular**, às vezes há reinicializações, porém
    **bem menos frequentes**.
-   Não há evidência suficiente para concluir "obsolescência
    programada".
-   Possibilidades a investigar, **sem ordem de certeza**: bug de
    firmware/Autolink; falha de RAM/armazenamento; sobreaquecimento;
    instabilidade de alimentação/aterramento; módulo Wi-Fi/Bluetooth;
    incompatibilidade de projeção; falha da MCU ou do sistema.
-   O proprietário **não quer fazer o teste de Android Auto por cabo**.
    Não insistir nem recolocá-lo como pré-requisito.

### 1.3 Preferências operacionais

-   Priorizar **automação pelo Claude Code ou Codex no notebook
    Windows**.
-   Uma única inicialização pelo usuário, se possível, e um único
    relatório final.
-   Não pedir que o usuário execute vários comandos, tire fotos
    repetidas ou navegue menus já investigados.
-   Trabalhar em casa nas fases de pesquisa/preparação; reservar a
    visita ao carro apenas para tarefas indispensáveis.
-   Priorizar estabilidade, Android Auto e CarPlay; preservar rádio,
    áudio, touchscreen, câmera de ré, comandos do volante, GPS,
    Bluetooth, configurações de veículo e MCU.
-   **Nenhuma atualização, flash, reset de fábrica, root, alteração da
    MCU, remoção de aplicativos ou desmontagem sem aprovação
    explícita.**

## 2. Definição de autonomia e limites

### O agente DEVE fazer sozinho, quando tiver ferramentas disponíveis

1.  Ler este plano e o kit anterior, se presente.
2.  Criar pasta de trabalho e relatórios, organizar evidências e manter
    checkpoint de progresso.
3.  Pesquisar fontes públicas, documentação, fóruns e repositórios;
    registrar URL, data, modelo a que se aplica e confiabilidade.
4.  Verificar ferramentas já instaladas no notebook, sem reinstalar
    desnecessariamente.
5.  Preparar scripts de **inventário e diagnóstico somente leitura** e
    validá-los localmente.
6.  Identificar dispositivos/interfaces visíveis no Windows, **sem
    presumir que o USB da central é uma interface de dados para PC**.
7.  Coletar dados e logs somente por interfaces comprovadas, autorizadas
    e seguras.
8.  Analisar resultados, ranquear hipóteses e pesquisar
    correções/firmwares alternativos.
9.  Produzir relatório final, com evidências e **uma única próxima ação
    humana mínima**, se necessária.

### O agente NÃO DEVE fazer sem aprovação específica

-   Instalar pacotes no Windows que alterem drivers, firewall ou
    configurações do sistema.
-   Fazer varredura de IPs/portas de uma rede não confirmada como
    pertencente ao usuário e vinculada à central.
-   Testar senhas padrão, explorar vulnerabilidades, abrir shells não
    documentados ou forçar acesso.
-   Usar USB-A macho--macho entre duas portas host; conectar notebook a
    USB fêmea da central **sem confirmar os papéis
    elétricos/protocolo**.
-   Apagar cache/dados, redefinir Autolink, fazer reset, editar
    partições, desativar serviços, modificar bootloader, MCU, CAN bus,
    áudio, câmera ou comandos do volante.
-   Fazer flash/atualização mesmo que encontre um arquivo com nome
    semelhante.
-   Desmontar painel, abrir unidade, soldar, usar UART/JTAG ou curto em
    pinos.
-   Recolher/armazenar dados pessoais de telefones, contatos, mensagens,
    tokens ou senhas sem necessidade.

**Segurança:** todos os testes físicos com o carro estacionado em local
ventilado e seguro; não operar notebook dirigindo. Se for necessário
manter a ignição ligada, considerar carga da bateria e ventilação; não
improvisar alimentação elétrica.

## 3. Fases e critérios de passagem

### FASE 0 --- Pesquisa aprofundada remota (sem carro, começar por aqui)

**Meta:** reduzir incertezas antes de escolher ferramentas.

-   Pesquisar separadamente e em combinações: `ZCD9200`,
    `ZCD9200-6956-MIPI-5G`, `6956-MIPI-5G`, `V002.03.13.003.00`,
    `V088.156.76`, `WIFID40L-240910`, `MP10 FW Update`, `Autolink`,
    `HI-LINK`, `iOS Mirror`.
-   Buscar fabricante/OEM, SoC, arquitetura, SO, RAM/flash, datas e
    variantes de placa.
-   Procurar documentação oficial e relatos **da mesma plataforma**,
    separando de modelos apenas parecidos.
-   Investigar interfaces de diagnóstico comprovadas (USB device, ADB,
    rede, logs exportáveis, ferramenta OEM).
-   Procurar notas de versão e falhas conhecidas de Autolink, CarPlay,
    Android Auto, Wi-Fi e reinicialização.
-   Pesquisar firmware original, correções e ROMs alternativas, **sem
    baixar/executar arquivos de procedência duvidosa**.
-   Examinar projetos de engenharia reversa/otimização **como
    referências**, não como compatibilidade comprovada.
-   Criar matriz `evidencias.csv`: alegação, fonte/URL, data, modelo
    exato, nível de confiança, observação.
-   Se não houver documentação suficiente, marcar **não encontrado** e
    prosseguir para identificação não invasiva.

**Saída:** `reports/00-pesquisa.md` com fatos, hipóteses, lacunas, URLs
verificadas e opções de acesso.

### FASE 1 --- Preparação automática do notebook (sem carro)

-   Detectar Windows, PowerShell, Claude Code/Codex, Git, Python, ADB,
    utilitários USB e ferramentas de rede existentes.
-   **Git é opcional** e serve apenas para versionar scripts; não é
    necessário GitHub nem repositório remoto.
-   **ADB só é útil se houver Android e uma interface ADB comprovada**.
    Não assumir.
-   Preparar scripts de inventário, detecção passiva, coleta condicional
    e relatório; incluir `-WhatIf`/modo seco quando aplicável.
-   Registrar logs localmente e mascarar identificadores sensíveis.
-   Preparar um `RUNBOOK-CARRO.md` com, no máximo, as ações físicas
    estritamente necessárias.
-   Instalação de software faltante: apresentar **um pedido consolidado
    de aprovação**, com links oficiais, somente se necessário.

**Saída:** `reports/01-ambiente.md`, scripts testados e comando único de
execução.

### FASE 2 --- Descoberta de conectividade (no carro, mínima interação)

**Primeiro:** inspecionar passivamente dispositivos e redes visíveis
pelo notebook.

-   USB: identificar a função da USB fêmea antes de orientar qualquer
    ligação. Porta host para pendrive **não implica** interface de
    diagnóstico para notebook. Não tentar cabo host--host.
-   Wi-Fi: confirmar se a central pode participar da mesma rede do
    notebook ou se expõe rede própria. A existência de Wi-Fi para
    Android Auto/CarPlay **não garante** acesso IP geral.
-   Se houver rede/IP alvo confirmado e autorização, testar apenas
    interfaces documentadas e com escopo mínimo.
-   Se houver ADB legitimamente disponível, verificar identidade do
    dispositivo e coletar somente leitura.
-   Se houver ferramenta oficial do fabricante, verificar autenticidade,
    compatibilidade e requisitos.
-   Se não houver interface de diagnóstico, **não inventar acesso**:
    documentar limite e migrar para testes observacionais/assistência
    especializada.

**Saída:** `reports/02-conectividade.md` com método comprovado ou
bloqueio explícito.

### FASE 3 --- Diagnóstico de causa-raiz (no carro, se acesso permitir)

**A. Sem acesso ao SO:** cronologia dos reinícios, diferença entre rádio
e projeção, tempo até falhar, temperatura/ambiente, estabilidade de
alimentação com profissional quando indicado, observação do logo de boot
e da interface.

**B. Se for Android com ADB autorizado:** somente leitura, por exemplo
`getprop`, `dumpsys`, `logcat` e inventário de processos/pacotes;
adaptar à versão real. Procurar `FATAL EXCEPTION`, `ANR`, `lmkd`,
`watchdog`, erros I/O, thermal, reboot reason, falhas de projeção. **Não
executar** `adb root`, `remount`, `pm disable`, `settings put`,
`reboot`, `fastboot`, `flash`.

**C. Se for Linux/RTOS proprietário:** somente mecanismos de diagnóstico
**documentados e autorizados**. Não supor SSH, terminal ou permissões.

**D. Alimentação/hardware:** distinguir reinicialização de app,
reinicialização de interface e reboot completo; se sintomas também
ocorrem no rádio, manter hipótese de alimentação, armazenamento e
hardware. Medições elétricas devem ser feitas por técnico qualificado,
sem improvisos do agente.

**Saída:** `reports/03-diagnostico.md` com evidências, causas
ranqueadas, confiança e testes pendentes.

### FASE 4 --- Plano de backup e recuperação (antes de qualquer mudança)

-   Documentar todas as versões, configurações e funções essenciais.
-   Identificar **procedimento oficial de recuperação**, compatibilidade
    exata de placa e MCU, fonte confiável de firmware e
    integridade/hash.
-   Fazer backup apenas por método suportado, autorizado e verificável;
    não alegar que backup existe sem confirmação.
-   Definir condição de **NO-GO**: sem correspondência exata de
    hardware, sem método de recuperação ou com risco inaceitável, não
    realizar flash.

**Saída:** `reports/04-recuperacao.md` com matriz GO/NO-GO.

### FASE 5 --- Correções de baixo risco (somente após autorização)

-   Preferir correções oficiais, reversíveis e individualizadas.
-   Se comprovadamente Android, avaliar otimização de apps/serviços
    apenas após mapear dependências da projeção, MCU, áudio, câmera e
    volante.
-   Se firmware proprietário, procurar ajuste/atualização **oficial e
    compatível**.
-   Registrar estado anterior, mudança, teste e rollback de cada
    intervenção.
-   Não apagar dados do Autolink sem avaliar ativação/licença e método
    de recuperação.
-   Testar estabilidade sem celular e com projeção sem fio; **não exigir
    Android Auto via cabo**.

**Saída:** `reports/05-correcoes.md`.

### FASE 6 --- Escolha de firmware ou sistema alternativo

Comparar, com evidências: 1. Manter firmware atual corrigido/otimizado.
2. Reinstalar ou atualizar firmware oficial da **mesma revisão de
hardware**. 3. Firmware alternativo especificamente compatível. 4.
Sistema mais leve (Linux/Android) **somente se** boot, drivers,
touchscreen, áudio, Wi-Fi/BT, MCU e integração veicular forem
comprovados. 5. Reparo de hardware ou substituição da central, se
custo/risco de software não compensar.

Para cada alternativa: origem, hardware compatível, Android Auto,
**CarPlay funcional/licenciado**, rádio, câmera de ré, comandos do
volante, GPS, microfone, Bluetooth, áudio, método de instalação,
rollback, risco, custo e evidências de testes reais.

**Atenção:** ZLink/Autolink e CarPlay podem depender de licença,
hardware ou bibliotecas proprietárias. "Rodar Linux" não equivale a "ter
CarPlay".

**Saída:** `reports/06-alternativas.md` e recomendação justificada.

### FASE 7 --- Implementação supervisionada (opcional, aprovação separada)

-   Só propor se houver correspondência exata de hardware, integridade
    do pacote, backup/recuperação e aceitação explícita dos riscos.
-   Entregar plano de execução e rollback **antes** de qualquer ação.
-   Nenhuma atualização de MCU por associação aproximada de versão.
-   Não executar silenciosamente.

### FASE 8 --- Validação

-   Verificar boot, rádio, áudio, touchscreen, Android Auto sem fio,
    CarPlay, microfone, chamadas, Wi-Fi/BT, GPS, câmera de ré e comandos
    do volante.
-   Testar reconexões e ciclos de desligar/ligar; observar se persiste
    reboot no rádio.
-   Comparar frequência de falhas antes/depois e documentar o que não
    pôde ser testado.
-   Entregar relatório final com resultado, limitações e recomendações.

## 4. Política para minimizar interações

1.  **Não perguntar** o que já está neste plano.
2.  Trabalhar em lote: pesquisar, preparar e analisar tudo que não
    requer o usuário.
3.  Pedir **uma única confirmação consolidada** quando houver várias
    instalações ou permissões do mesmo nível.
4.  Se faltar acesso físico, registrar o bloqueio e continuar fases
    remotas independentes.
5.  Se precisar do usuário, dar **uma única instrução curta**, com o
    motivo e como confirmar sucesso.
6.  Evitar repetir perguntas sobre marca, menus de debug, pop-up "Sobre
    o produto", localização do USB ou teste Android Auto por cabo.
7.  Nunca declarar "conectado", "diagnosticado", "backup feito" ou
    "firmware compatível" sem prova.
8.  Não executar trabalho em segundo plano depois de encerrar a sessão,
    a menos que exista mecanismo de automação configurado e autorizado.
9.  Produzir checkpoints legíveis para que outro agente retome sem
    refazer perguntas.

## 5. Estrutura de trabalho

``` text
ASX-Multimidia/
├── PLANO-MESTRE.md
├── AGENTS.md
├── README.md
├── scripts/
│   ├── iniciar.ps1
│   ├── verificar-ambiente.ps1
│   ├── inventario-passivo.ps1
│   ├── coletar-diagnostico.ps1
│   └── gerar-relatorio.ps1
├── docs/
│   ├── RUNBOOK-CARRO.md
│   ├── fontes.md
│   └── progresso.md
├── reports/
│   ├── 00-pesquisa.md
│   ├── 01-ambiente.md
│   ├── 02-conectividade.md
│   ├── 03-diagnostico.md
│   ├── 04-recuperacao.md
│   ├── 05-correcoes.md
│   ├── 06-alternativas.md
│   └── RELATORIO-FINAL.md
├── evidence/
│   └── evidencias.csv
├── logs/
└── backups/
```

Não criar scripts de escrita/flashing durante as fases de auditoria.
Pastas `backups/` e relatórios não implicam que um backup tenha sido
feito.

## 6. Links oficiais e referências

**Ferramentas (instalar somente quando necessárias):** - Claude Code:
https://code.claude.com/docs/en/overview - Codex CLI:
https://github.com/openai/codex - Android Platform Tools / ADB:
https://developer.android.com/tools/releases/platform-tools -
Documentação ADB: https://developer.android.com/tools/adb - PowerShell:
https://github.com/PowerShell/PowerShell/releases - Python Windows:
https://www.python.org/downloads/windows/ - Git Windows (opcional):
https://git-scm.com/downloads/win - Wireshark (opcional):
https://www.wireshark.org/download.html

**Referências técnicas, NÃO firmwares validados:** - CleanYourTV
(otimização de Android TV; pode ser incompatível):
https://github.com/udhaykumarbala/cleanyourtv-app - Exploração de
central Android (metodologia, outro hardware):
https://github.com/andresurena/android-head-unit-exploration - Pesquisa
ZCD9200 no GitHub: https://github.com/search?q=ZCD9200&type=code -
Pesquisa identificador exato:
https://www.google.com/search?q=%22ZCD9200-6956-MIPI-5G%22 - Pesquisa
MCU: https://www.google.com/search?q=%22V088.156.76%22+MCU

**Não há, neste momento, link de firmware comprovadamente compatível.**
Não transformar resultado de busca em recomendação de flash.

## 7. Kit anterior e limites conhecidos

Um kit preliminar chamado `ASX-Auditoria.zip` foi criado na conversa
anterior, contendo `iniciar.ps1`, `README.md` e `AGENT.md`. Ele
**prepara a investigação**, inventaria ferramentas/dispositivos USB e
abre Claude/Codex, mas **não estabelece por si só conexão com a
central**. Se disponível, inspecionar e reutilizar o que for seguro; não
presumir que o arquivo esteja acessível em outra sessão ou no notebook.

## 8. Critérios de aceite

-   Identidade, SO e hardware: confirmado **ou** explicitamente não
    confirmado, sem especulação apresentada como fato.
-   Causa dos travamentos: diagnóstico fundamentado ou hipóteses com
    testes mínimos pendentes.
-   Android Auto sem fio e CarPlay: funcionando com estabilidade, **ou**
    impedimento documentado.
-   Rádio, áudio, câmera e volante preservados.
-   Nenhum firmware ou alteração arriscada sem aprovação.
-   Um relatório que permita ao proprietário escolher entre reparo,
    firmware original, alternativa mais leve ou substituição.

## 9. Prompt de execução para Claude Code / Codex

> Leia `PLANO-MESTRE.md` integralmente. Você é o agente técnico
> principal da auditoria da multimídia ASX 2014. Execute agora **Fase
> 0** e todas as tarefas da **Fase 1** possíveis no PC, com máxima
> autonomia e sem alterações na central. Pesquise fontes públicas e cite
> URLs, registre confiança, gere scripts de inventário somente leitura e
> teste-os localmente. Não faça perguntas sobre fatos já documentados;
> não exija teste Android Auto por cabo. Se não houver acesso ao carro,
> continue tudo que puder remotamente e produza `docs/RUNBOOK-CARRO.md`
> com a **menor ação humana possível**. Não instale software, altere a
> rede, conecte USB host--host, faça root, reset ou flash sem aprovação
> explícita. Ao terminar, entregue `reports/RELATORIO-FINAL.md`, o
> estado de cada fase, as descobertas verificadas, os bloqueios reais e
> **uma única próxima ação recomendada**.

------------------------------------------------------------------------

**Estado inicial:** Fase 0 pesquisada apenas parcialmente em conversa
anterior; não há identificação comprovada de OEM/SoC/SO, interface de
diagnóstico ou firmware compatível. A pesquisa deve ser refeita/validada
com fontes verificáveis, não considerada concluída por hipótese.
