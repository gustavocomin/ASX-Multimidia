#!/bin/sh
set -eu
export LC_ALL=C
umask 077

usage() {
    printf '%s\n' 'Uso: sh scripts/diagnosticar-conexao.sh [interface-wifi | --rede "SSID" | --automatico]'
}

target=''
automatic=no
case "${1-}" in
    --help)
        usage
        exit 0
        ;;
    --automatico)
        if [ "$#" -ne 1 ]; then
            usage >&2
            exit 2
        fi
        automatic=yes
        ;;
    --rede)
        if [ "$#" -ne 2 ] || [ -z "$2" ]; then
            usage >&2
            exit 2
        fi
        target="$2"
        ;;
    *)
        if [ "$#" -gt 1 ]; then
            usage >&2
            exit 2
        fi
        ;;
esac

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

wifi_access_points() {
    nmcli -t -e no -f ACTIVE,SSID,CHAN,SIGNAL device wifi list \
        ifname "$1" --rescan "${2:-no}" 2>/dev/null
}

show_access_point() (
    ap="${1#*:}"
    signal="${ap##*:}"
    ssid_and_channel="${ap%:*}"
    channel="${ssid_and_channel##*:}"
    printf 'SSID: %s\nCanal: %s\nSinal: %s%%\n' "${ssid_and_channel%:*}" "$channel" "$signal"
)

show_ip() (
    iface="$1"
    printf '\nIPv4 na interface:\n'
    ip -4 -o address show dev "$iface" 2>/dev/null || printf '%s\n' 'Consulta indisponível.'

    printf '\nRotas IPv4 na interface:\n'
    ip -4 route show dev "$iface" 2>/dev/null || printf '%s\n' 'Consulta indisponível.'

    printf '\nVizinhos IPv4 já conhecidos (IP e estado):\n'
    if neighbors=$(ip -4 neigh show dev "$iface" 2>/dev/null); then
        if [ -n "$neighbors" ]; then
            printf '%s\n' "$neighbors" | awk '{ print $1, $NF }'
        else
            printf '%s\n' 'Cache de vizinhos vazio.'
        fi
    else
        printf '%s\n' 'Consulta indisponível.'
    fi
)

show_recent_reasons() (
    if command -v journalctl >/dev/null 2>&1; then
        transitions=$(journalctl -b -u NetworkManager.service --since '5 minutes ago' \
            --output=cat --no-pager 2>/dev/null | awk -v iface="$1" '
            BEGIN { prefix = "device (" iface "): state change: " }
            position = index($0, prefix) {
                transition = substr($0, position + length(prefix))
                if (match(transition, /^[a-z0-9-]+ -> [a-z0-9-]+ [(]reason .[a-z0-9-]+./)) {
                    print substr(transition, RSTART, RLENGTH) ")"
                }
            }
        ')
        if [ -n "$transitions" ]; then
            printf '\nTransições recentes na interface (podem incluir outras tentativas):\n%s\n' "$transitions"
            exit 0
        fi
    fi
    printf '%s\n' 'Histórico recente da interface indisponível ou vazio.'
)

show_target_wifi() (
    printf 'SSID alvo: %s\n' "$target"
    wifi_devices=$(printf '%s\n' "$1" | awk -F: '$2 == "wifi" { print $1 }')
    if [ -z "$wifi_devices" ]; then
        printf '%s\n' 'Nenhuma interface Wi-Fi listada pelo NetworkManager.'
        exit 0
    fi

    printf '%s\n' "$wifi_devices" | while IFS= read -r iface; do
        printf '\nInterface Wi-Fi: %s\nEstado e motivo atuais do NetworkManager:\n' "$iface"
        nmcli -g GENERAL.STATE,GENERAL.REASON device show "$iface" 2>/dev/null ||
            printf '%s\n' 'Consulta de estado indisponível.'

        if access_points=$(wifi_access_points "$iface"); then
            target_ap=$(printf '%s\n' "$access_points" | ASX_TARGET_SSID="$target" awk '
                {
                    ssid = $0
                    sub(/^[^:]*:/, "", ssid)
                    sub(/:[0-9]+:[0-9]+$/, "", ssid)
                    if (ssid == ENVIRON["ASX_TARGET_SSID"]) {
                        if ($0 ~ /^yes:/) { print; active = 1; exit }
                        if (!candidate) candidate = $0
                    }
                }
                END { if (!active && candidate) print candidate }
            ')
            case "$target_ap" in
                yes:*)
                    show_access_point "$target_ap"
                    printf '%s\n' 'Associada ao alvo: sim'
                    show_ip "$iface"
                    ;;
                '')
                    printf '%s\n' 'SSID alvo ausente no cache do NetworkManager.'
                    ;;
                *)
                    show_access_point "$target_ap"
                    printf '%s\n' 'Associada ao alvo: não'
                    ;;
            esac
        else
            printf '%s\n' 'Consulta ao cache Wi-Fi indisponível.'
        fi
        show_recent_reasons "$iface"
    done
)


collect_automatically() (
    devices="$1"
    iface=$(printf '%s\n' "$devices" | awk -F: '$2 == "wifi" { print $1 }')
    case "$iface" in
        '') printf '%s\n' 'Nenhum adaptador Wi-Fi encontrado.'; exit 0 ;;
        *'
'*) printf '%s\n' 'Mais de um adaptador Wi-Fi. Use --rede para identificar as interfaces.'; exit 0 ;;
    esac

    if ! access_points=$(wifi_access_points "$iface" auto); then
        printf '%s\n' 'Cache Wi-Fi indisponível.'
        exit 0
    fi
    target=$(printf '%s\n' "$access_points" | awk '
        /^(yes|no):Car_Wifi_[[:xdigit:]]+:[0-9]+:[0-9]+$/ {
            sub(/^[^:]+:/, "")
            sub(/:[0-9]+:[0-9]+$/, "")
            if (!seen[$0]++) print
        }
    ')
    case "$target" in
        '') printf '%s\n' 'Nenhuma rede no formato Car_Wifi_ encontrada no cache.'; exit 0 ;;
        *'
'*) printf '%s\n' 'Mais de uma rede no formato Car_Wifi_ encontrada. Nenhuma tentativa automática realizada.'; exit 0 ;;
    esac

    if printf '%s\n' "$access_points" | grep -Eq "^yes:$target:[0-9]+:[0-9]+$"; then
        show_target_wifi "$devices"
        exit 0
    fi

    profiles=$(nmcli -t -f UUID,TYPE connection show 2>/dev/null)
    profile=$(
        printf '%s\n' "$profiles" | while IFS=: read -r uuid type; do
            case "$type" in
                802-11-wireless|wifi)
                    ssid=$(nmcli -g 802-11-wireless.ssid -e no connection show uuid "$uuid" 2>/dev/null) || continue
                    if [ "$ssid" = "$target" ]; then
                        printf '%s\n' "$uuid"
                        break
                    fi
                    ;;
            esac
        done
    )
    if [ -z "$profile" ]; then
        printf '%s\n' 'Perfil Wi-Fi salvo não encontrado. A associação automática depende das credenciais salvas no Ubuntu.'
        show_target_wifi "$devices"
        exit 0
    fi

    if ! previous=$(nmcli -g GENERAL.CON-UUID device show "$iface" 2>/dev/null); then
        printf '%s\n' 'O perfil atual não pôde ser consultado. A tentativa automática foi cancelada.'
        exit 0
    fi
    if [ "$previous" = -- ]; then
        previous=''
    fi

    restore_wifi() {
        trap - EXIT
        if [ -n "$previous" ]; then
            if nmcli -w 25 connection up uuid "$previous" ifname "$iface" >/dev/null 2>&1; then
                printf '\n%s\n' 'Conexão Wi-Fi anterior restaurada.'
            else
                printf '\n%s\n' 'Falha ao restaurar o Wi-Fi anterior. Reconecte pelo Ubuntu.'
            fi
        elif nmcli -g GENERAL.CON-UUID device show "$iface" 2>/dev/null | grep -Fxq "$profile"; then
            if nmcli -w 10 connection down uuid "$profile" >/dev/null 2>&1; then
                printf '\n%s\n' 'A interface voltou ao estado desconectado.'
            else
                printf '\n%s\n' 'A rede da central continua conectada. Desconecte pelo Ubuntu.'
            fi
        fi
    }

    trap restore_wifi EXIT
    trap 'exit 130' INT
    trap 'exit 143' TERM
    trap 'exit 129' HUP
    printf 'Tentativa automática de conexão à rede %s usando o perfil salvo.\n' "$target"
    if nmcli -w 25 connection up uuid "$profile" ifname "$iface" >/dev/null 2>&1; then
        printf '%s\n' 'O NetworkManager ativou o perfil.'
    else
        printf '%s\n' 'O NetworkManager não concluiu a ativação.'
    fi
    show_target_wifi "$devices"
)

{
    printf 'ASX Multimídia — coleta offline do Wi-Fi\n'
    printf 'Data (UTC): %s\n\n' "$(date -u +'%Y-%m-%d %H:%M:%SZ')"
    printf '%s\n\n' 'Dados locais do Ubuntu. A identidade da central e a interface de diagnóstico ainda precisam ser confirmadas.'

    if devices=$(nmcli -t -f DEVICE,TYPE,STATE device status 2>/dev/null); then
        if [ "$automatic" = yes ]; then
            collect_automatically "$devices"
        elif [ -n "$target" ]; then
            show_target_wifi "$devices"
        else
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
                    active_ap=$(wifi_access_points "$wifi_devices" | awk '/^yes:/ { print; exit }')
                    if [ -n "$active_ap" ]; then
                        show_access_point "$active_ap"
                    else
                        printf '%s\n' 'Ponto de acesso ativo indisponível no cache do NetworkManager.'
                    fi
                    show_ip "$wifi_devices"
                    ;;
            esac
        fi
    else
        printf '%s\n' 'NetworkManager indisponível. Rode a coleta no Ubuntu do notebook com o Wi-Fi gerenciado pelo NetworkManager.'
    fi
} > "$report"

printf '%s\n' "$report"
