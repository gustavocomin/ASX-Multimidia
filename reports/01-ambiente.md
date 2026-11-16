# Fase 1 — Kit portátil de inventário

O inventário mais recente em `logs/` foi coletado em 16/11/2026 às 12h00min18s (Brasília). Ele registra **Ubuntu 24.04.3 LTS**, kernel **6.17.0-14-generic x86_64**. Confiança alta para o ambiente que executou o script. O relatório bruto permanece em `logs/`, ignorado pelo Git.

| Verificação | Resultado do inventário |
| --- | --- |
| Ferramentas encontradas no PATH | `git`, `python3`, `lsusb`, `udevadm`, `ip`, `nmcli` |
| Ferramentas ausentes do PATH na coleta | `codex`, `claude`, `adb` |
| Portas USB físicas | Três, uma delas USB 3.0, conforme informado pelo proprietário |
| Dispositivos USB no Linux | Cinco pares VID/PID em oito entradas no sysfs. Essa contagem inclui hubs e pode incluir dispositivos internos. Nenhuma associação à central foi comprovada |
| Rede | Duas interfaces com dispositivo, uma ativa. O inventário registra contagens locais |

A etapa de inventário do notebook está concluída. A observação no carro pode ser feita sem instalar ferramentas. A coleta da central segue pendente de uma interface de diagnóstico comprovada e autorizada.

| Ambiente de validação no PC | Resultado |
| --- | --- |
| Windows PowerShell 5.1.26100.9818 | Inventário real com os provedores Windows e teste controlado de simulação, privacidade e falhas parciais passaram |
| PowerShell 7.6.9 no Windows | Mesmas verificações passaram |
| Ubuntu 24.04 no WSL 2 | Teste em ambiente Linux confirmou sintaxe, modo seco, tratamento de argumentos e geração de dois relatórios independentes |

O WSL 2 permitiu testar a execução em Linux e a leitura do sysfs exposto a esse ambiente. O inventário atual de USB e rede está resumido acima. Os relatórios das execuções de validação ficaram em pastas temporárias fora do projeto.

As ferramentas são detectadas no PATH. O inventário usa os provedores locais do Windows ou o sysfs no Linux. A coleta de logs da central depende da confirmação de uma interface própria. O [README](../README.md) contém o comando de cada sistema.

O caminho padrão no Linux também prepara o Codex CLI. Os testes no WSL 2 simularam instalação, login, sessão existente e falha no download. O inventário atual só registra a disponibilidade do executável no PATH no momento da coleta.
