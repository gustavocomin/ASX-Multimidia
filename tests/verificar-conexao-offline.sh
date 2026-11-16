#!/bin/sh
set -eu

project_root=$(CDPATH='' cd "$(dirname "$0")/.." && pwd -P)
source="$project_root/scripts/diagnosticar-conexao.sh"
if [ ! -f "$source" ]; then
    printf '%s\n' 'Falta o ponto de entrada para coleta offline.' >&2
    exit 1
fi

temp_root=$(mktemp -d)
trap 'rm -rf -- "$temp_root"' EXIT
mkdir "$temp_root/scripts" "$temp_root/bin"
cp "$source" "$temp_root/scripts/"
entry="$temp_root/scripts/diagnosticar-conexao.sh"

cat > "$temp_root/bin/nmcli" <<'FAKE_NMCLI'
#!/bin/sh
case "$*" in
    '-t -f DEVICE,TYPE,STATE device status')
        printf '%s\n' 'enp1s0:ethernet:connected'
        case "$TEST_WIFI" in
            failed) printf '%s\n' 'wlp2s0:wifi:disconnected' ;;
            one|two) printf '%s\n' 'wlp2s0:wifi:connected' ;;
        esac
        if [ "$TEST_WIFI" = two ]; then
            printf '%s\n' 'wlp3s0:wifi:connected'
        fi
        ;;
    '-t -e no -f ACTIVE,SSID,CHAN,SIGNAL device wifi list ifname wlp2s0 --rescan no')
        printf '%s\n' 'no:REDE_DE_TERCEIRO:6:75'
        active=yes
        if [ "$TEST_WIFI" = failed ]; then active=no; fi
        printf '%s\n' "$active:MP10:36:82"
        ;;
    '-g GENERAL.STATE,GENERAL.REASON device show wlp2s0')
        printf '%s\n' '30 (disconnected)' '0 (No reason given)'
        ;;
    *) exit 7 ;;
esac
FAKE_NMCLI

cat > "$temp_root/bin/ip" <<'FAKE_IP'
#!/bin/sh
case "$*" in
    '-4 -o address show dev wlp2s0') printf '%s\n' '3: wlp2s0    inet 192.168.77.16/24 scope global dynamic wlp2s0' ;;
    '-4 route show dev wlp2s0') printf '%s\n' 'default via 192.168.77.1 proto dhcp' '192.168.77.0/24 proto kernel scope link src 192.168.77.16' ;;
    '-4 neigh show dev wlp2s0') printf '%s\n' '192.168.77.1 lladdr 01:23:45:67:89:ab REACHABLE' ;;
    *) exit 7 ;;
esac
FAKE_IP
cat > "$temp_root/bin/journalctl" <<'FAKE_JOURNAL'
#!/bin/sh
printf '%s\n' \
    "device (enp1s0): state change: config -> failed (reason 'wrong-network', sys-iface-state: 'managed')" \
    "device (wlp2s0): state change: ip-config -> failed (reason 'ip-config-unavailable', sys-iface-state: 'managed')" \
    "device (wlp2s0): activation metadata DADO_PRIVADO"
FAKE_JOURNAL

chmod +x "$temp_root/bin/nmcli" "$temp_root/bin/ip" "$temp_root/bin/journalctl"

sh -n "$entry"
report=$(TEST_WIFI=one PATH="$temp_root/bin:$PATH" sh "$entry")
grep -q 'SSID: MP10' "$report"
grep -q 'Canal: 36' "$report"
grep -q 'Sinal: 82%' "$report"
grep -q '192\.168\.77\.16/24' "$report"
grep -q 'default via 192\.168\.77\.1' "$report"
grep -q '^192\.168\.77\.1 REACHABLE$' "$report"
if grep -Eq 'REDE_DE_TERCEIRO|01:23:45:67:89:ab|enp1s0' "$report"; then
    printf '%s\n' 'Foram incluídos dados fora da interface selecionada.' >&2
    exit 1
fi

disconnected=$(TEST_WIFI=none PATH="$temp_root/bin:$PATH" sh "$entry")
grep -q 'Nenhuma interface Wi-Fi conectada' "$disconnected"
test "$report" != "$disconnected"

ambiguous=$(TEST_WIFI=two PATH="$temp_root/bin:$PATH" sh "$entry")
grep -q 'Mais de uma interface Wi-Fi conectada' "$ambiguous"
selected=$(TEST_WIFI=two PATH="$temp_root/bin:$PATH" sh "$entry" wlp2s0)
grep -q 'SSID: MP10' "$selected"
printf '%s\n' 'Passou: Wi-Fi conectado, desconectado e múltiplas interfaces, sem dados de outras redes.'



failed=$(TEST_WIFI=failed PATH="$temp_root/bin:$PATH" sh "$entry" --rede MP10)
grep -q 'SSID alvo: MP10' "$failed"
grep -q 'SSID: MP10' "$failed"
grep -q 'Associada ao alvo: não' "$failed"
grep -q 'failed (reason .ip-config-unavailable.' "$failed"
if grep -Eq 'REDE_DE_TERCEIRO|DADO_PRIVADO|enp1s0|IPv4 na interface:' "$failed"; then
    printf '%s\n' 'A coleta de falha incluiu dados de outra conexão.' >&2
    exit 1
fi

absent=$(TEST_WIFI=failed PATH="$temp_root/bin:$PATH" sh "$entry" --rede ALVO_AUSENTE)
grep -q 'SSID alvo ausente no cache' "$absent"
if grep -q 'SSID: MP10' "$absent"; then
    printf '%s\n' 'A coleta incluiu rede diferente do alvo.' >&2
    exit 1
fi

target_connected=$(TEST_WIFI=one PATH="$temp_root/bin:$PATH" sh "$entry" --rede MP10)
grep -q 'Associada ao alvo: sim' "$target_connected"
grep -q '192\.168\.77\.16/24' "$target_connected"
printf '%s\n' 'Passou: rede alvo visível, ausente, associada e falha de DHCP sem copiar o journal.'


cat > "$temp_root/bin/nmcli" <<'AUTO_NMCLI'
#!/bin/sh
live=$(cat "$AUTO_STATE")
case "$*" in
    '-t -f DEVICE,TYPE,STATE device status') printf '%s\n' 'wlp2s0:wifi:connected' ;;
    '-t -e no -f ACTIVE,SSID,CHAN,SIGNAL device wifi list ifname wlp2s0 --rescan no'|'-t -e no -f ACTIVE,SSID,CHAN,SIGNAL device wifi list ifname wlp2s0 --rescan auto')
        active=no
        if [ "$live" = central ]; then active=yes; fi
        printf '%s\n' "$active:Car_Wifi_ABCDEF:36:82"
        ;;
    '-g GENERAL.CON-UUID device show wlp2s0')
        case "$live" in
            internet) printf '%s\n' 00000000-0000-4000-8000-000000000001 ;;
            central) printf '%s\n' 00000000-0000-4000-8000-000000000002 ;;
            *) printf '%s\n' -- ;;
        esac
        ;;
    '-t -f UUID,TYPE connection show')
        if [ "$AUTO_MODE" != no-profile ]; then
            printf '%s\n' '00000000-0000-4000-8000-000000000002:802-11-wireless'
        fi
        ;;
    '-g 802-11-wireless.ssid -e no connection show uuid 00000000-0000-4000-8000-000000000002')
        printf '%s\n' Car_Wifi_ABCDEF
        ;;
    '-w 25 connection up uuid 00000000-0000-4000-8000-000000000002 ifname wlp2s0')
        printf '%s\n' connect >> "$AUTO_TRACE"
        if [ "$AUTO_MODE" = failure ]; then
            printf '%s\n' offline > "$AUTO_STATE"
            exit 4
        fi
        printf '%s\n' central > "$AUTO_STATE"
        ;;
    '-w 25 connection up uuid 00000000-0000-4000-8000-000000000001 ifname wlp2s0')
        printf '%s\n' restore >> "$AUTO_TRACE"
        printf '%s\n' internet > "$AUTO_STATE"
        ;;
    '-g GENERAL.STATE,GENERAL.REASON device show wlp2s0')
        printf '%s\n' '100 (connected)' '0 (No reason given)'
        ;;
    *) exit 7 ;;
esac
AUTO_NMCLI

export AUTO_STATE="$temp_root/wifi-state" AUTO_TRACE="$temp_root/wifi-trace"
for scenario in success failure no-profile; do
    printf '%s\n' internet > "$AUTO_STATE"
    : > "$AUTO_TRACE"
    report=$(AUTO_MODE="$scenario" PATH="$temp_root/bin:$PATH" sh "$entry" --automatico)
    test "$(cat "$AUTO_STATE")" = internet
    case "$scenario" in
        success)
            grep -q 'Associada ao alvo: sim' "$report"
            test "$(cat "$AUTO_TRACE")" = "$(printf '%s\n' connect restore)"
            ;;
        failure)
            grep -q 'Associada ao alvo: não' "$report"
            test "$(cat "$AUTO_TRACE")" = "$(printf '%s\n' connect restore)"
            ;;
        no-profile)
            grep -q 'Perfil Wi-Fi salvo não encontrado' "$report"
            test ! -s "$AUTO_TRACE"
            ;;
    esac
done
printf '%s\n' 'Passou: tentativa automática, coleta, restauração em sucesso e falha e ausência de perfil.'
