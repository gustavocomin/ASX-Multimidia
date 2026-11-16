#!/bin/sh
set -eu
export LC_ALL=C
umask 077

if [ "$#" -ne 1 ]; then
    printf '%s\n' 'Uso: sh scripts/diagnosticar-ponte-usb.sh IP_DA_CENTRAL' >&2
    exit 2
fi
target="$1"

if ! printf '%s\n' "$target" | awk -F. '
    NR != 1 || NF != 4 { bad = 1; next }
    {
        for (i = 1; i <= 4; i++) {
            if ($i !~ /^(0|[1-9][0-9]*)$/ || $i > 255) bad = 1
        }
        private = ($1 == 10 || ($1 == 172 && $2 >= 16 && $2 <= 31) || ($1 == 192 && $2 == 168))
    }
    END { exit (bad || !private) }
'; then
    printf '%s\n' 'Informe o IPv4 privado da central mostrado como Roteador/Gateway no celular.' >&2
    exit 2
fi
if ! command -v ip >/dev/null 2>&1; then
    printf '%s\n' 'O comando ip está indisponível.' >&2
    exit 1
fi

project_root=$(CDPATH='' cd "$(dirname "$0")/.." && pwd -P)
log_dir="$project_root/logs"
mkdir -p "$log_dir"
stamp=$(date -u +%Y%m%d-%H%M%SZ)
run_dir=$(mktemp -d "$log_dir/ponte-usb-$stamp-XXXXXX")
report="$run_dir/ponte-usb.txt"

(
    printf 'ASX Multimídia — diagnóstico da ponte USB\n'
    printf 'Data (UTC): %s\nIPv4 informado: %s\n\n' "$(date -u +'%Y-%m-%d %H:%M:%SZ')" "$target"

    if ! route=$(ip -4 route get "$target" 2>/dev/null); then
        printf '%s\n' 'Sem rota IPv4 disponível para o endereço informado.'
        exit 0
    fi

    iface=$(printf '%s\n' "$route" | awk '{ for (i=1; i<NF; i++) if ($i=="dev") {print $(i+1); exit} }')
    next_hop=$(printf '%s\n' "$route" | awk '{ for (i=1; i<NF; i++) if ($i=="via") {print $(i+1); exit} }')
    case "$iface" in
        ''|*[!a-zA-Z0-9_.-]*) printf '%s\n' 'Interface da rota indisponível.'; exit 0 ;;
    esac
    device=$(readlink -f "/sys/class/net/$iface/device" 2>/dev/null || :)
    case "$device" in
        */usb[0-9]*/*) printf 'Rota escolhida pelo Ubuntu: %s (dispositivo USB).\n' "$iface" ;;
        *) printf '%s\n' 'A rota selecionada não passa por um dispositivo USB.'; exit 0 ;;
    esac
    if [ "$next_hop" = "$target" ]; then
        printf '%s\n' 'O endereço informado coincide com o gateway do próprio tethering. Endereço ambíguo para o teste.'
        exit 0
    fi
    if ! command -v ping >/dev/null 2>&1; then
        printf '%s\n' 'Ping indisponível. A rota USB foi registrada e o teste de resposta ficou pendente.'
        exit 0
    fi

    if ping -I "$iface" -c 1 -W 2 -- "$target" >/dev/null 2>&1; then
        printf '%s\n' 'Resposta ICMP recebida pelo USB. Confirme a identidade do equipamento antes de interpretar como acesso à Knup.'
    else
        printf '%s\n' 'Sem resposta ICMP. A central pode ignorar ping ou o celular pode não encaminhar tráfego para o Wi-Fi.'
    fi
) > "$report"

printf '%s\n' "$report"
