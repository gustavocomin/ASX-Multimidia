#!/bin/sh
set -eu

root=$(CDPATH='' cd "$(dirname "$0")/.." && pwd -P)
entry="$root/scripts/diagnosticar-ponte-usb.sh"
test -f "$entry" || { echo 'Script de diagnóstico da ponte ausente.' >&2; exit 1; }
sh -n "$entry"
temp=$(mktemp -d)
trap 'rm -rf -- "$temp"' EXIT
mkdir "$temp/scripts" "$temp/bin"
cp "$entry" "$temp/scripts/"
entry="$temp/scripts/diagnosticar-ponte-usb.sh"

cat > "$temp/bin/ip" <<'FAKE'
#!/bin/sh
test "$*" = '-4 route get 192.168.47.1' || exit 3
case "$TEST_ROUTE" in
    usb|no-reply) echo '192.168.47.1 via 192.168.42.129 dev usb0 src 192.168.42.2 uid 1000' ;;
    phone-gateway) echo '192.168.47.1 via 192.168.47.1 dev usb0 src 192.168.47.2 uid 1000' ;;
    wifi) echo '192.168.47.1 via 192.168.20.1 dev wlp2s0 src 192.168.20.2 uid 1000' ;;
    unreachable) exit 2 ;;
esac
FAKE
cat > "$temp/bin/readlink" <<'FAKE'
#!/bin/sh
case "$2" in
    /sys/class/net/usb0/device) echo /sys/devices/platform/test/usb1/1-1/1-1:1.0 ;;
    *) echo /sys/devices/platform/test/pci/mock ;;
esac
FAKE
cat > "$temp/bin/ping" <<'FAKE'
#!/bin/sh
test "$*" = '-I usb0 -c 1 -W 2 -- 192.168.47.1' || exit 3
echo ping >> "$TEST_TRACE"
test "$TEST_ROUTE" != no-reply
FAKE
chmod +x "$temp/bin/"*
export TEST_TRACE="$temp/trace"
PATH="$temp/bin:$PATH"
export PATH
if sh "$entry" 8.8.8.8; then
    echo 'Um endereço público não deve ser aceito.' >&2
    exit 1
fi
test ! -e "$temp/logs"

for TEST_ROUTE in usb no-reply phone-gateway wifi unreachable; do
    export TEST_ROUTE
    : > "$TEST_TRACE"
    report=$(sh "$entry" 192.168.47.1)
    case "$TEST_ROUTE" in
        usb) grep -q 'Resposta ICMP recebida' "$report"; grep -qx ping "$TEST_TRACE" ;;
        no-reply) grep -q 'Sem resposta ICMP' "$report"; grep -qx ping "$TEST_TRACE" ;;
        phone-gateway) grep -q 'gateway do próprio tethering' "$report"; test ! -s "$TEST_TRACE" ;;
        wifi) grep -q 'rota selecionada não passa por um dispositivo USB' "$report"; test ! -s "$TEST_TRACE" ;;
        unreachable) grep -q 'Sem rota IPv4 disponível' "$report"; test ! -s "$TEST_TRACE" ;;
    esac
done
echo 'Passou: rota USB, ausência de resposta, gateway do celular, rota Wi-Fi e ausência de rota.'
