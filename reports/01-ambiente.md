# Fase 1 — Kit portátil de inventário

Os scripts estão preparados para Linux e Windows. O sistema do notebook ainda não foi confirmado. O inventário real do notebook fica para depois do clone.

| Ambiente de validação no PC | Resultado |
| --- | --- |
| Windows PowerShell 5.1.26100.9818 | Inventário real com os provedores Windows e teste controlado de simulação, privacidade e falhas parciais passaram |
| PowerShell 7.6.9 no Windows | Mesmas verificações passaram |
| Ubuntu 24.04 no WSL 2 | Teste em ambiente Linux confirmou sintaxe, modo seco, tratamento de argumentos e geração de dois relatórios independentes |

O WSL 2 permitiu testar a execução em Linux e a leitura do sysfs exposto a esse ambiente. O USB e a rede do notebook físico ainda precisam ser inventariados. Os relatórios das execuções de validação ficaram em pastas temporárias fora do projeto.

As ferramentas são detectadas no PATH. O inventário usa os provedores locais do Windows ou o sysfs no Linux. A coleta de logs da central depende da confirmação de uma interface própria. O [README](../README.md) contém o comando de cada sistema.

O caminho padrão no Linux também prepara o Codex CLI. Os testes no WSL 2 simularam instalação, login, sessão existente e falha no download. A instalação e a autenticação reais ficam para a execução no notebook.
