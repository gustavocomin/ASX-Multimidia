#!/bin/sh
set -eu

project_root=$(CDPATH='' cd "$(dirname "$0")/.." && pwd -P)
source="$project_root/scripts/iniciar.sh"
if [ ! -f "$source" ]; then
    printf '%s\n' 'Contrato do kit: scripts/iniciar.sh deve ser o ponto de entrada no Linux.' >&2
    exit 1
fi

temp_root=$(mktemp -d)
trap 'rm -rf -- "$temp_root"' EXIT
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

sh "$entry" --somente-inventario
sh "$entry" --somente-inventario
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

# Restrict PATH so an existing Codex or curl on the test machine is never called.
mkdir "$temp_root/bin" "$temp_root/codex-bin"
for tool in sh uname dirname date mkdir mktemp sed awk sort uniq rm cp chmod; do
    ln -s "$(command -v "$tool")" "$temp_root/bin/$tool"
done
export CODEX_INSTALL_DIR="$temp_root/codex-bin"
export ASX_FIXTURE_TRACE="$temp_root/codex-trace"
export ASX_FIXTURE_STATE="$temp_root/logged-in"
export ASX_FIXTURE_BIN="$temp_root/bin"
export ASX_FIXTURE_DIR="$temp_root"

cat > "$temp_root/bin/curl" <<'FAKE_CURL'
#!/bin/sh
set -eu
printf '%s\n' download >> "$ASX_FIXTURE_TRACE"
if [ "${ASX_FIXTURE_FAIL_DOWNLOAD:-0}" = 1 ]; then
    exit 22
fi
while [ "$1" != -o ]; do
    shift
done
test "$3" = https://chatgpt.com/codex/install.sh
cp "$ASX_FIXTURE_DIR/instalador-falso" "$2"
FAKE_CURL

cat > "$temp_root/instalador-falso" <<'FAKE_INSTALLER'
set -eu
test "$CODEX_NON_INTERACTIVE" = 1
printf '%s\n' install >> "$ASX_FIXTURE_TRACE"
cp "$ASX_FIXTURE_DIR/codex-falso" "$CODEX_INSTALL_DIR/codex"
chmod +x "$CODEX_INSTALL_DIR/codex"
FAKE_INSTALLER

cat > "$temp_root/codex-falso" <<'FAKE_CODEX'
#!/bin/sh
set -eu
case "$*" in
    'login status')
        printf '%s\n' status >> "$ASX_FIXTURE_TRACE"
        test -f "$ASX_FIXTURE_STATE"
        ;;
    login)
        printf '%s\n' login >> "$ASX_FIXTURE_TRACE"
        : > "$ASX_FIXTURE_STATE"
        ;;
    *) exit 3 ;;
esac
FAKE_CODEX

chmod +x "$temp_root/bin/curl"
PATH="$ASX_FIXTURE_BIN" /bin/sh "$entry" --dry-run
PATH="$ASX_FIXTURE_BIN" /bin/sh "$entry" --somente-inventario
test ! -e "$ASX_FIXTURE_TRACE"

PATH="$ASX_FIXTURE_BIN" /bin/sh "$entry"
test "$(cat "$ASX_FIXTURE_TRACE")" = "$(printf '%s\n' download install status login)"
test -x "$CODEX_INSTALL_DIR/codex"

# The installed executable is still outside PATH, as in a fresh terminal profile.
PATH="$ASX_FIXTURE_BIN" /bin/sh "$entry"
test "$(cat "$ASX_FIXTURE_TRACE")" = "$(printf '%s\n' download install status login status)"

rm "$ASX_FIXTURE_STATE"
PATH="$CODEX_INSTALL_DIR:$ASX_FIXTURE_BIN" /bin/sh "$entry"
test "$(cat "$ASX_FIXTURE_TRACE")" = "$(printf '%s\n' download install status login status status login)"

rm "$CODEX_INSTALL_DIR/codex"
: > "$ASX_FIXTURE_TRACE"
if ASX_FIXTURE_FAIL_DOWNLOAD=1 PATH="$ASX_FIXTURE_BIN" /bin/sh "$entry"; then
    printf '%s\n' 'Uma falha no download deve impedir o login.' >&2
    exit 1
fi
test "$(cat "$ASX_FIXTURE_TRACE")" = download
printf '%s\n' 'Passou: instalação, login, reexecução e falha de download do Codex simulados.'
