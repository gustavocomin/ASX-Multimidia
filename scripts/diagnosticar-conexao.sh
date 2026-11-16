#!/bin/sh
set -eu
export LC_ALL=C
umask 077

if [ "$#" -gt 1 ] || [ "${1-}" = --help ]; then
    printf '%s\n' 'Uso: sh scripts/diagnosticar-conexao.sh [interface-wifi]'
    [ "$#" -le 1 ]
    exit
fi

for tool in nmcli ip; do
    if ! command -v "$tool" >/dev/null 2>&1; then
        printf 'Comando necessário não encontrado: %s\n' "$tool" >&2
        exit 1
    fi
done

project_root=$(CDPATH='' cd "$(dirname "$0")/.." && pwd -P)
log_dir="$project_root/logs"
stamp=$(date -u +%Y%m%d-%H%M%SZ)
mkdir -p "$log_dir"
run_dir=$(mktemp -d "$log_dir/conexao-$stamp-XXXXXX")
report="$run_dir/conexao.txt"

{
    printf 'ASX Multimídia — coleta offline do Wi-Fi\n'
    printf 'Data (UTC): %s\n\n' "$(date -u +'%Y-%m-%d %H:%M:%SZ')"
    printf '%s\n\n' 'Dados locais do Ubuntu. A identidade da central e a interface de diagnóstico ainda precisam ser confirmadas.'

    if devices=$(nmcli -t -f DEVICE,TYPE,STATE device status 2>/dev/null); then
        wifi_devices=$(printf '%s\n' "$devices" | awk -F: -v requested="${1-}" '
            $2 == "wifi" && $3 ~ /^connected( |$)/ && (requested == "" || $1 == requested) { print $1 }
        ')
        case "$wifi_devices" in
            '')
                printf '%s\n' 'Nenhuma interface Wi-Fi conectada na seleção atual.'
                ;;
            *'
'*)
                printf '%s\n' 'Mais de uma interface Wi-Fi conectada. Informe o nome da interface da central ao repetir a coleta.'
                printf '%s\n' "$wifi_devices"
                ;;
            *)
                printf 'Interface Wi-Fi: %s\n' "$wifi_devices"
                active_ap=$(nmcli -t -e no -f ACTIVE,SSID,CHAN,SIGNAL device wifi list \
                    ifname "$wifi_devices" --rescan no 2>/dev/null | awk '/^yes:/ { sub(/^yes:/, ""); print; exit }')
                if [ -n "$active_ap" ]; then
                    signal="${active_ap##*:}"
                    ssid_and_channel="${active_ap%:*}"
                    channel="${ssid_and_channel##*:}"
                    printf 'SSID: %s\nCanal: %s\nSinal: %s%%\n' "${ssid_and_channel%:*}" "$channel" "$signal"
                else
                    printf '%s\n' 'Ponto de acesso ativo indisponível no cache do NetworkManager.'
                fi

                printf '\nIPv4 na interface:\n'
                ip -4 -o address show dev "$wifi_devices" 2>/dev/null || printf '%s\n' 'Consulta indisponível.'

                printf '\nRotas IPv4 na interface:\n'
                ip -4 route show dev "$wifi_devices" 2>/dev/null || printf '%s\n' 'Consulta indisponível.'

                printf '\nVizinhos IPv4 já conhecidos (IP e estado):\n'
                if neighbors=$(ip -4 neigh show dev "$wifi_devices" 2>/dev/null); then
                    if [ -n "$neighbors" ]; then
                        printf '%s\n' "$neighbors" | awk '{ print $1, $NF }'
                    else
                        printf '%s\n' 'Cache de vizinhos vazio.'
                    fi
                else
                    printf '%s\n' 'Consulta indisponível.'
                fi
                ;;
        esac
    else
        printf '%s\n' 'NetworkManager indisponível. Rode a coleta no Ubuntu do notebook com o Wi-Fi gerenciado pelo NetworkManager.'
    fi
} > "$report"

printf '%s\n' "$report"
