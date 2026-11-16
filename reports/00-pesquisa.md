# Fase 0 — Pesquisa remota da multimídia do ASX 2014

Pesquisa de 16/11/2026. A preparação do kit portátil está registrada no relatório de ambiente. O inventário do notebook fica para depois do clone. As identificações da unidade vêm da transcrição das fotos no plano mestre.

## Identificação da unidade

| Campo | Valor registrado no plano | Resultado da pesquisa |
| --- | --- | --- |
| Identificador exibido | `ZCD9200-6956-MIPI-5G` | Nenhuma correspondência pública exata encontrada nas buscas consultadas |
| Software | `V002.03.13.003.00` | Nenhum changelog ou pacote vinculado à versão exata |
| MCU | `V088.156.76` | Fabricante, hardware e firmware da MCU sem confirmação |
| Wi-Fi | `WIFID40L-240910` | Módulo e chipset sem identificação |
| Data exibida | `02/04/2025` | Formato e significado sem confirmação |
| Menu de atualização | `FW Update — MP10` | Formato de pacote, revisão de placa e recuperação sem documentação localizada |
| Projeção e espelhamento | Autolink, HI-LINK, iOS Mirror, Android Auto e CarPlay | Nomes usados em mais de um produto |
| OEM, SoC principal, SO, RAM e armazenamento | Desconhecidos | Nenhuma fonte liga esses componentes à revisão da unidade |

Foram pesquisados os identificadores completos e fragmentos como `ZCD9200`, `6956-MIPI`, `03.13.003`, `088.156.76` e `WIFID40L`, em combinação com CarPlay, Autolink, firmware, MP10 e termos técnicos em chinês e russo. A busca abrangeu a web pública, resultados indexados de fóruns de reparo e GitHub. A matriz registra o alcance dos achados. A cobertura não inclui áreas privadas de suporte ou acervos que exigem conta.

## Pistas verificadas

- Um proprietário publicou o código `ZCD7005-6966-H-V40` com software `V088.03.13.003.003.03` e MCU `V002.66.26`. A estrutura lembra a das versões registradas no plano, mas placa e MCU diferem. O relato de reemparelhamento bem-sucedido é específico àquela unidade. Um segundo proprietário publicou a identificação `ZCD7127C-6966-HD` no EletrônicaBR. Ambos são relatos de primeira mão sobre outras revisões. [Relato ZCD7005](https://www.reddit.com/r/CarAV/comments/1kz2et1/chinese_head_unit_firmware_update_help/) · [Relato ZCD7127C](https://eletronicabr.com/forums/topic/414738-central-multim%C3%ADdia-7-1-din-mp5-pedido-de-firmware-zcd-c200c/)
- O cadastro de qualificação Bluetooth lista um componente JieLi `AC6956`. A sequência `6956` no identificador da central é uma pista fraca. Mesmo se esse componente for encontrado na placa, sua presença isolada deixaria em aberto qual processador executa a interface principal. [Cópia pública do registro Bluetooth SIG](https://www.pfconcept.com/pub/media/complianceDocument/valid/124320_Stark%202%200%20RABS%20Bluetooth%20speaker%20Bluetooth%20Certificate_EN.pdf?key=cb196f35ea0f622a44c66cdd1d30e89e)
- O manual do MP5 B700C documenta Autolink, Hi-Link e i-Mirror em funções de espelhamento e descreve Android Auto e CarPlay em seções próprias. Esses nomes ajudam a interpretar os menus, mas deixam o SO e o fabricante da unidade do ASX indeterminados. [Manual do B700C](https://device.report/m/790621c9556bb2f1f8a1ecd4f06744586e29fb1718928406f2ace1dd8be740c3_optim.pdf)
- A Apple orienta verificar Bluetooth, Wi-Fi e conexão automática para CarPlay sem fio. O Google lista Wi-Fi de 5 GHz no celular e compatibilidade do receptor entre os requisitos do Android Auto sem fio. São referências para investigar a projeção quando houver acesso ao carro. O travamento no rádio exige investigação da própria central. [Suporte Apple](https://support.apple.com/en-ca/105109) · [Ajuda do Android Auto](https://support.google.com/androidauto/answer/6348019?hl=pt-BR)

## Busca complementar por fabricante ou importador

- Um proprietário de Podofo 7018B informou a placa `ZCD7127C-6966` e a MCU `V66.46`. A marca aparece em uma unidade de outra revisão. A busca no catálogo Cheyang/Podofo e pelos códigos exatos ainda não vinculou o fabricante à `ZCD9200-6956-MIPI-5G`. [Relato do proprietário](https://www.elektroda.pl/rtvforum/topic4154194.html) · [Catálogo Cheyang/Podofo](https://www.podofo.com/products)

## Acesso para diagnóstico

| Canal | Evidência disponível | Condição para usar |
| --- | --- | --- |
| USB | O plano registra um cabo USB fêmea da central. O papel elétrico e de protocolo segue indeterminado | Documento da unidade que identifique uma porta de diagnóstico adequada ao notebook |
| Wi-Fi | Uso para projeção relatado | Documentação de uma interface de diagnóstico e confirmação da rede e do alvo |
| ADB | Android e depuração ainda sem confirmação | Interface Android de depuração documentada ou visível e conexão autorizada. [Documentação ADB](https://developer.android.com/tools/adb) |
| Ferramenta OEM ou logs exportáveis | Método sem confirmação | Identificar fabricante e revisão ou receber documentação específica da unidade |

### Kit anterior

O `ASX-Auditoria.zip` contém `iniciar.ps1`, `README.md` e `AGENT.md`. A leitura estática mostrou que o script grava inventário de ferramentas, lista dispositivos USB com `InstanceId` integral, chama `adb devices -l` quando encontra o executável e abre Claude ou Codex. Para reaproveitar o kit no notebook, vale manter o inventário de ferramentas e condicionar ADB à identificação da interface. Os identificadores devem ser mascarados antes de incluir a saída em relatórios. Nenhuma parte do kit foi executada no PC.

## Hipóteses e decisão sobre firmware

A prioridade depende de confirmar o que acontece na falha do rádio. Se reaparecer o logotipo de inicialização, sobe a prioridade de verificar alimentação e aterramento com um técnico e de investigar reinicialização do sistema, temperatura ou falha interna. Se a interface apenas voltar à tela inicial, ganha peso a hipótese de encerramento ou reinício da interface. As quedas frequentes durante o Android Auto e a perda de CarPlay justificam avaliar a projeção separadamente. Ainda faltam observações da sequência de falha e registros da própria central.

| Caminho | Decisão nesta fase |
| --- | --- |
| Manter o firmware atual para diagnóstico | Viável para observar as falhas e identificar a revisão |
| Atualizar ou reinstalar firmware oficial | Sem base para proceder. Faltam pacote de origem verificável, correspondência de placa/MCU e procedimento de recuperação |
| Usar firmware alternativo ou sistema mais leve | Nenhuma opção compatível validada. Clean Your TV usa Android TV/ADB, o estudo da AINAVI H6 cobre Android/XUNZU/ZLink e o CatPlay publica portas para adaptadores específicos. [Clean Your TV](https://github.com/udhaykumarbala/cleanyourtv-app) · [Estudo AINAVI H6](https://github.com/andresurena/android-head-unit-exploration) · [CatPlay](https://github.com/catplay-labs/catplay) |
| Diagnosticar ou reparar alimentação/hardware | Candidato prioritário se houver indício de reinicialização completa no rádio |
| Substituir a unidade | Alternativa a avaliar depois do diagnóstico. A integração com câmera, volante, áudio, GPS e microfone precisará ser comprovada para a instalação do ASX |

## Situação das fases

| Fase | Situação |
| --- | --- |
| 0 — Pesquisa remota | Rodada inicial registrada no relatório e na matriz. Identificação de OEM/placa ainda em aberto |
| 1 — Preparação | Kit preparado para Linux e Windows. Inventário do notebook pendente. [Relatório do ambiente](01-ambiente.md) |
| 2–3 — Conectividade e causa-raiz | Aguardam acesso ao carro. Nenhuma interface comprovada |
| 4 — Recuperação | Procedimento e backup ainda indisponíveis |
| 5–8 — Correção, alternativas, implementação e validação | Análise preliminar de alternativas registrada. Correção e validação em veículo pendentes |

Na próxima ocorrência espontânea com o rádio ligado e o celular desconectado, observe se o logotipo de inicialização reaparece. Essa observação ajuda a distinguir uma queda de interface de uma possível reinicialização completa sem exigir notebook ou reproduzir a falha de propósito.
