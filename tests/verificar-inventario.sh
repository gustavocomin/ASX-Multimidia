#!/bin/sh
set -eu

project_root=$(CDPATH='' cd "$(dirname "$0")/.." && pwd -P)
source="$project_root/scripts/iniciar.sh"
if [ ! -f "$source" ]; then
    printf '%s\n' 'Contrato do kit: scripts/iniciar.sh deve ser o ponto de entrada no Linux.' >&2
    exit 1
fi

temp_root=$(mktemp -d)
trap 'rm -f "$temp_root/scripts/iniciar.sh" "$temp_root"/logs/inventario-*/inventario.md; for run in "$temp_root"/logs/inventario-*; do [ ! -d "$run" ] || rmdir "$run"; done; [ ! -d "$temp_root/logs" ] || rmdir "$temp_root/logs"; rmdir "$temp_root/scripts" "$temp_root"' EXIT
mkdir "$temp_root/scripts"
cp "$source" "$temp_root/scripts/iniciar.sh"
entry="$temp_root/scripts/iniciar.sh"

sh -n "$entry"
sh "$entry" --dry-run
test ! -e "$temp_root/logs"
if sh "$entry" --opcao-desconhecida; then
    printf '%s\n' 'Uma opção inválida deve falhar.' >&2
    exit 1
fi
test ! -e "$temp_root/logs"

sh "$entry"
sh "$entry"
set -- "$temp_root"/logs/inventario-*/inventario.md
test "$#" -eq 2
for report do
    grep -q '^\- Kernel · Linux' "$report"
    grep -q '^| adb |' "$report"
    grep -q '^## Dispositivos USB' "$report"
    grep -Eq '^\| [[:xdigit:]]{4} \| [[:xdigit:]]{4} \| [0-9]+ \||^(Nenhuma entrada USB|Inventário USB indisponível)' "$report"
    grep -Eq '^\| Interfaces com dispositivo \| [0-9]+ \||^Inventário de rede indisponível' "$report"
    grep -q 'Interface de diagnóstico da ZCD9200-6956-MIPI-5G ainda sem comprovação' "$report"
    if grep -Ev '^- (Kernel|Distribuição) ·' "$report" | grep -Eq '(/sys/(bus|class)/|([[:xdigit:]]{2}:){5}[[:xdigit:]]{2}|[[:digit:]]{1,3}(\.[[:digit:]]{1,3}){3})'; then
        printf '%s\n' 'O relatório expôs caminho sysfs ou endereço de rede.' >&2
        exit 1
    fi
done
printf '%s\n' 'Passou: simulação, argumentos, inventário e execuções repetidas no Linux.'
