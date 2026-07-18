#!/bin/sh
# instalar-mac-linux.sh
# Configura Claude Code para que NUNCA agregue "Generated with Claude Code"
# ni "Co-Authored-By: Claude" a tus commits, e instala un git hook global
# como red de seguridad para todos tus repos.
#
# Uso:
#   sh instalar-mac-linux.sh

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "== 1) Configurando settings.json de Claude Code =="

CLAUDE_DIR="$HOME/.claude"
SETTINGS_FILE="$CLAUDE_DIR/settings.json"

mkdir -p "$CLAUDE_DIR"

if command -v python3 >/dev/null 2>&1; then
  python3 - "$SETTINGS_FILE" <<'PYEOF'
import json, sys, os

path = sys.argv[1]
data = {}
if os.path.exists(path):
    with open(path, "r", encoding="utf-8") as f:
        content = f.read().strip()
        if content:
            data = json.loads(content)

data["attribution"] = {"commit": "", "pr": ""}
data["includeCoAuthoredBy"] = False

with open(path, "w", encoding="utf-8") as f:
    json.dump(data, f, indent=2, ensure_ascii=False)
    f.write("\n")
PYEOF
  echo "Listo: $SETTINGS_FILE actualizado (fusionado con tus otros ajustes)."
else
  if [ -f "$SETTINGS_FILE" ]; then
    echo "AVISO: ya existe $SETTINGS_FILE y no se encontro python3 para fusionarlo con seguridad."
    echo "Agrega manualmente estas claves a ese archivo:"
    echo '  "attribution": { "commit": "", "pr": "" }, "includeCoAuthoredBy": false'
  else
    cat > "$SETTINGS_FILE" <<'EOF'
{
  "attribution": {
    "commit": "",
    "pr": ""
  },
  "includeCoAuthoredBy": false
}
EOF
    echo "Listo: $SETTINGS_FILE creado."
  fi
fi

echo ""
echo "== 2) Instalando git hook global (commit-msg) como red de seguridad =="

HOOKS_DIR="$HOME/.git-hooks-global"
mkdir -p "$HOOKS_DIR"
cp "$SCRIPT_DIR/git-hooks/commit-msg" "$HOOKS_DIR/commit-msg"
chmod +x "$HOOKS_DIR/commit-msg"

git config --global core.hooksPath "$HOOKS_DIR"
echo "Listo: hook instalado en $HOOKS_DIR y activado globalmente (core.hooksPath)."

echo ""
echo "== Instalacion completa =="
echo "Reinicia tu editor (o al menos la sesion de Claude Code) y verifica con /status."
echo "A partir de ahora, ningun commit en ninguno de tus repos incluira"
echo "'Generated with Claude Code' ni 'Co-Authored-By: Claude'."
