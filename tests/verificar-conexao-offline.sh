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
            one|two) printf '%s\n' 'wlp2s0:wifi:connected' ;;
        esac
        if [ "$TEST_WIFI" = two ]; then
            printf '%s\n' 'wlp3s0:wifi:connected'
        fi
        ;;
    '-t -e no -f ACTIVE,SSID,CHAN,SIGNAL device wifi list ifname wlp2s0 --rescan no')
        printf '%s\n' 'no:REDE_DE_TERCEIRO:6:75' 'yes:MP10:36:82'
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
chmod +x "$temp_root/bin/nmcli" "$temp_root/bin/ip"

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
