# Quitar la atribución de Claude Code en tus commits de GitHub

Cuando usás [Claude Code](https://claude.com/claude-code) para hacer commits, por defecto agrega
líneas como estas al mensaje:

```
🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>
```

Esta carpeta trae **dos soluciones combinadas** para que eso no vuelva a aparecer,
ni en este repo ni en ningún otro repo tuyo:

1. **`claude-settings/settings.json`** — el ajuste oficial de Claude Code que le dice
   que no agregue esas líneas nunca (esto ataca la causa: Claude directamente no las escribe).
2. **`git-hooks/commit-msg`** — un git hook que se instala **globalmente** (para todos tus
   repos) y borra automáticamente esas líneas de cualquier commit, por si algún día se te
   olvida configurar Claude, usás otra máquina, u otra herramienta las vuelve a meter.

Con las dos capas activas, es prácticamente imposible que se te escape un commit con esa firma.

## Instalación en 1 paso

### Windows (PowerShell)

```powershell
powershell -ExecutionPolicy Bypass -File instalar-windows.ps1
```

### Mac / Linux

```sh
sh instalar-mac-linux.sh
```

Cualquiera de los dos scripts hace lo mismo:

- Crea (o fusiona, sin borrar tus otros ajustes) `~/.claude/settings.json` con:
  ```json
  {
    "attribution": {
      "commit": "",
      "pr": ""
    },
    "includeCoAuthoredBy": false
  }
  ```
- Copia `git-hooks/commit-msg` a `~/.git-hooks-global/commit-msg` y configura
  `git config --global core.hooksPath` para que ese hook se ejecute en **todos** tus
  repositorios, no solo en este.

Después de correr el script, **reiniciá VS Code** (o al menos la sesión de Claude Code) y
verificá con `/status` dentro de Claude Code que cargó el archivo.

## Instalación manual (si preferís no correr un script)

1. Copiá el contenido de [`claude-settings/settings.json`](claude-settings/settings.json) a
   `C:\Users\<tu-usuario>\.claude\settings.json` (Windows) o `~/.claude/settings.json`
   (Mac/Linux). Si el archivo ya existe, solo agregá las claves `attribution` e
   `includeCoAuthoredBy` sin borrar el resto.
2. (Opcional pero recomendado) Instalá el hook a mano:
   ```sh
   mkdir -p ~/.git-hooks-global
   cp git-hooks/commit-msg ~/.git-hooks-global/commit-msg
   chmod +x ~/.git-hooks-global/commit-msg   # no aplica en Windows
   git config --global core.hooksPath ~/.git-hooks-global
   ```

## Verificar que funcionó

1. Reiniciá Claude Code y corré `/status`: en la sección de settings debería figurar
   `attribution` como vacío e `includeCoAuthoredBy: false`.
2. Hacé un commit de prueba con Claude Code y revisá el mensaje con:
   ```sh
   git log -1 --pretty=full
   ```
   No debería aparecer `Co-Authored-By: Claude` ni `Generated with Claude Code`.

## Desinstalar / revertir

- Para sacar el hook global:
  ```sh
  git config --global --unset core.hooksPath
  ```
- Para revertir el ajuste de Claude Code, borrá las claves `attribution` e
  `includeCoAuthoredBy` de `~/.claude/settings.json` (o borrá el archivo entero si no tenías
  otros ajustes propios).

## Estructura de este repo

```
claude-settings/settings.json   -> plantilla del ajuste de Claude Code
git-hooks/commit-msg            -> hook que limpia el mensaje de commit
instalar-windows.ps1            -> instalador para Windows (PowerShell)
instalar-mac-linux.sh           -> instalador para Mac/Linux (sh)
```
