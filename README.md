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

No **Windows**, use o PowerShell.

```powershell
powershell.exe -NoProfile -File .\scripts\iniciar.ps1
```

O comando grava um inventário local em `logs/` e mostra o caminho do arquivo. Ele lista a versão do sistema, ferramentas encontradas no PATH, códigos USB VID/PID e contagens dos adaptadores de rede. Os códigos VID/PID identificam tipos de dispositivo. Números de série, endereços de rede e nomes de redes ficam fora do relatório. O inventário funciona com o notebook em casa, sem privilégios administrativos.

Para simular a execução sem coletar dados nem criar arquivo, use `sh scripts/iniciar.sh --dry-run` no Linux ou acrescente `-WhatIf` ao comando do Windows.

## Retomar a auditoria

- [Pesquisa da central](reports/00-pesquisa.md)
- [Preparação e validação do kit](reports/01-ambiente.md)
- [Observação no carro](docs/RUNBOOK-CARRO.md)
- [Matriz de evidências](evidence/evidencias.csv)
- [Plano mestre](PLANO-MESTRE.md)

Os testes podem ser rodados com `sh tests/verificar-inventario.sh` no Linux ou `powershell.exe -NoProfile -File .\tests\verificar-inventario.ps1` no Windows.

`logs/`, `backups/` e `evidence/local/` são áreas locais ignoradas pelo Git. A interface de diagnóstico da central ainda precisa ser comprovada.
