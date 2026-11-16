#!/bin/sh
set -eu
prepare_codex=yes

usage() {
    printf '%s\n' 'Uso: sh scripts/iniciar.sh [--dry-run | --somente-inventario]'
}

if [ "$#" -gt 1 ]; then
    usage >&2
    exit 2
fi
case ${1-} in
    --help|-h) usage; exit 0 ;;
    --dry-run|-n)
        printf '%s\n' 'Modo seco. A execução normal grava o inventário, tenta a coleta Wi-Fi e prepara o Codex, se necessário.'
        exit 0
        ;;
    --somente-inventario) prepare_codex=no ;;
    '') ;;
    *) usage >&2; exit 2 ;;
esac

if [ "$(uname -s)" != Linux ]; then
    printf '%s\n' 'Este script requer Linux. No Windows, use scripts/iniciar.ps1.' >&2
    exit 1
fi

project_root=$(CDPATH='' cd "$(dirname "$0")/.." && pwd -P)
log_dir="$project_root/logs"
stamp=$(date -u +%Y%m%d-%H%M%SZ)
mkdir -p "$log_dir"
run_dir=$(mktemp -d "$log_dir/inventario-$stamp-XXXXXX")
report="$run_dir/inventario.md"

(
    export LC_ALL=C
    printf '# Inventário local — ASX Multimídia\n\n'
    printf 'Data (UTC) · %s\n\n' "$(date -u +'%Y-%m-%d %H:%M:%SZ')"
    printf '%s\n\n' 'O inventário descreve o ambiente que executou o script.'
    printf '## Ambiente\n\n'

    distribution=''
    if [ -r /etc/os-release ]; then
        distribution=$(sed -n 's/^PRETTY_NAME=//p' /etc/os-release)
        distribution=${distribution#\"}
        distribution=${distribution%\"}
    fi
    printf -- '- Distribuição · %s\n' "${distribution:-não identificada}"
    printf -- '- Kernel · %s\n\n' "$(uname -srm)"
    printf '| Ferramenta | Encontrada no PATH |\n| --- | --- |\n'
    for tool in codex claude git python3 adb lsusb udevadm ip nmcli; do
        if command -v "$tool" >/dev/null 2>&1; then
            found=Sim
        else
            found=Não
        fi
        printf '| %s | %s |\n' "$tool" "$found"
    done

    printf '\n## Dispositivos USB presentes no Linux\n\n'
    if [ -r /sys/bus/usb/devices ] && [ -x /sys/bus/usb/devices ]; then
        usb_rows=$(
            for device in /sys/bus/usb/devices/*; do
                [ -r "$device/idVendor" ] && [ -r "$device/idProduct" ] || continue
                read -r vendor 2>/dev/null < "$device/idVendor" || continue
                read -r product 2>/dev/null < "$device/idProduct" || continue
                printf '%s %s\n' "$vendor" "$product"
            done | awk 'NF == 2 && length($1) == 4 && length($2) == 4 &&
                        $1 ~ /^[[:xdigit:]]+$/ && $2 ~ /^[[:xdigit:]]+$/ {
                            print toupper($1), toupper($2)
                        }' | sort | uniq -c | awk '{ printf "| %s | %s | %s |\n", $2, $3, $1 }'
        )
        if [ -n "$usb_rows" ]; then
            printf '| VID | PID | Dispositivos no sysfs |\n| --- | --- | ---: |\n%s\n' "$usb_rows"
        else
            printf '%s\n' 'Nenhuma entrada USB com VID/PID disponível.'
        fi
    else
        printf '%s\n' 'Inventário USB indisponível.'
    fi

    printf '\n## Adaptadores de rede\n\n'
    if [ -r /sys/class/net ] && [ -x /sys/class/net ]; then
        adapter_count=0
        active_count=0
        for interface in /sys/class/net/*; do
            [ -e "$interface/device" ] || continue
            adapter_count=$((adapter_count + 1))
            if read -r state 2>/dev/null < "$interface/operstate" && [ "$state" = up ]; then
                active_count=$((active_count + 1))
            fi
        done
        printf '| Estado | Contagem |\n| --- | ---: |\n'
        printf '| Interfaces com dispositivo | %s |\n' "$adapter_count"
        printf '| Interfaces com dispositivo ativas | %s |\n' "$active_count"
    else
        printf '%s\n' 'Inventário de rede indisponível.'
    fi

    printf '\n## Central multimídia\n\n'
    printf '%s\n' 'Interface de diagnóstico da ZCD9200-6956-MIPI-5G ainda sem comprovação. O acesso à central depende de documentação da revisão e identificação da interface.'
) > "$report"
printf 'Inventário salvo em %s\n' "$report"


if [ "$prepare_codex" = no ]; then
    exit 0
fi

connection_script="$project_root/scripts/diagnosticar-conexao.sh"
if [ -f "$connection_script" ]; then
    if connection_report=$(sh "$connection_script" --automatico); then
        printf 'Coleta de conexão salva em %s\n' "$connection_report"
    else
        printf '%s\n' 'A coleta de conexão não pôde ser concluída.' >&2
    fi
fi


codex_dir="${CODEX_INSTALL_DIR:-$HOME/.local/bin}"
if ! command -v codex >/dev/null 2>&1 && [ -x "$codex_dir/codex" ]; then
    export PATH="$codex_dir:$PATH"
fi

if ! command -v codex >/dev/null 2>&1; then
    if ! command -v curl >/dev/null 2>&1; then
        printf '%s\n' 'O instalador do Codex precisa do curl. Instale o curl e execute este script novamente.' >&2
        exit 1
    fi

    printf '%s\n' 'Instalando o Codex CLI com o instalador oficial da OpenAI.'
    if ! (
        installer=$(mktemp) || exit 1
        trap 'rm -f -- "$installer"' EXIT
        curl --proto '=https' --proto-redir '=https' -fsSL -o "$installer" \
            https://chatgpt.com/codex/install.sh &&
            CODEX_NON_INTERACTIVE=1 sh "$installer"
    ); then
        printf '%s\n' 'A instalação do Codex falhou. O inventário local foi salvo.' >&2
        exit 1
    fi
    export PATH="$codex_dir:$PATH"

    if ! command -v codex >/dev/null 2>&1; then
        printf '%s\n' 'O instalador terminou, mas o executável do Codex não foi encontrado.' >&2
        exit 1
    fi
fi

if codex login status >/dev/null 2>&1; then
    printf '%s\n' 'O Codex já está autenticado.'
else
    printf '%s\n' 'Conclua o login do Codex na página que abrir no navegador.'
    codex login
fi
