# Auditoria da multimídia do ASX 2014

Central aftermarket `ZCD9200-6956-MIPI-5G`, software `V002.03.13.003.00`, MCU `V088.156.76` e Wi-Fi `WIFID40L-240910`. O objetivo é investigar os reinícios e recuperar Android Auto sem fio e CarPlay, preservando as funções do veículo.

## Rodar no notebook

Depois que o projeto estiver disponível no GitHub, clone e entre na pasta.

```sh
git clone https://github.com/gustavocomin/ASX-Multimidia.git
cd ASX-Multimidia
```

No **Linux**, use o terminal.

```sh
sh scripts/iniciar.sh
```

No Linux, o comando grava o inventário, verifica a presença do Codex CLI e usa o instalador oficial da OpenAI caso ele esteja faltando. A instalação precisa de internet e de `curl`. Se o Codex estiver sem sessão, o script executa `codex login` e você conclui o acesso à sua conta do ChatGPT no navegador. [Instalação do Codex CLI](https://learn.chatgpt.com/docs/codex/cli) · [Autenticação](https://learn.chatgpt.com/docs/auth)

Para rodar só o inventário no Linux, use `sh scripts/iniciar.sh --somente-inventario`.

No **Windows**, use o PowerShell.

```powershell
powershell.exe -NoProfile -File .\scripts\iniciar.ps1
```

O comando grava um inventário local em `logs/` e mostra o caminho do arquivo. Ele lista a versão do sistema, ferramentas encontradas no PATH, códigos USB VID/PID e contagens dos adaptadores de rede. Os códigos VID/PID identificam tipos de dispositivo. Números de série, endereços de rede e nomes de redes ficam fora do relatório. O inventário funciona com o notebook em casa, sem privilégios administrativos.

Para simular a execução sem coletar dados nem criar arquivo, use `sh scripts/iniciar.sh --dry-run` no Linux ou acrescente `-WhatIf` ao comando do Windows.

## Coleta offline no carro (Ubuntu)

Se a central oferecer uma rede Wi-Fi à qual o notebook consiga se conectar, entre nessa rede pelo menu do Ubuntu. Na raiz do projeto, rode:

```sh
sh scripts/diagnosticar-conexao.sh
```

A coleta usa `nmcli` e `ip`, já registrados no inventário do notebook. Ela consulta apenas a conexão Wi-Fi ativa e salva um arquivo em `logs/conexao-*/conexao.txt`. O arquivo registra SSID, canal, sinal, IPv4, rotas e IPs já presentes no cache de vizinhos. A coleta funciona sem internet e dispensa varredura de rede.

Volte ao Wi-Fi com internet e peça ao Codex para ler o arquivo gerado. Se o relatório listar mais de uma interface Wi-Fi, repita o comando com o nome da interface conectada à central como argumento.

## Retomar a auditoria

- [Pesquisa da central](reports/00-pesquisa.md)
- [Preparação e validação do kit](reports/01-ambiente.md)
- [Observação no carro](docs/RUNBOOK-CARRO.md)
- [Matriz de evidências](evidence/evidencias.csv)
- [Plano mestre](PLANO-MESTRE.md)

Os testes podem ser rodados com `sh tests/verificar-inventario.sh` no Linux ou `powershell.exe -NoProfile -File .\tests\verificar-inventario.ps1` no Windows.

`logs/`, `backups/` e `evidence/local/` são áreas locais ignoradas pelo Git. A interface de diagnóstico da central ainda precisa ser comprovada.
