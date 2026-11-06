# Quitar la atribución de Claude Code en tus commits

Cuando usás [Claude Code](https://claude.com/claude-code) para hacer commits, por defecto agrega
líneas como estas al mensaje:

```
🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>
```

`instalar-todo.ps1` (Windows, PowerShell) hace que no vuelvan a aparecer, en ningún repo tuyo.
Es un solo archivo: trae todo adentro, no hace falta clonar nada.

## Qué hace

1. Crea un git hook global (`~/.git-hooks-global/commit-msg`) que borra esas líneas de
   cualquier commit.
2. Lo activa con `git config --global core.hooksPath`.
3. Crea o fusiona `~/.claude/settings.json` con `attribution` vacío e
   `includeCoAuthoredBy: false`, para que Claude Code ni siquiera las escriba.

## Instalación

```powershell
Invoke-WebRequest https://raw.githubusercontent.com/Alex-Perales/mi-repo-mis-commits/main/instalar-todo.ps1 -OutFile instalar-todo.ps1
powershell -ExecutionPolicy Bypass -File instalar-todo.ps1
```

Después **reiniciá VS Code** (o la sesión de Claude Code).

> Nota: al activar un hook global, dejan de correr los hooks propios de cada repo
> (`.git/hooks`).

## Verificar que funcionó

Hacé un commit con Claude Code y revisá el mensaje:

```sh
git log -1 --pretty=full
```

No debería aparecer `Co-Authored-By: Claude` ni `Generated with Claude Code`.

## Desinstalar

```powershell
git config --global --unset core.hooksPath
Remove-Item -Recurse -Force "$env:USERPROFILE\.git-hooks-global"
```

Y borrá las claves `attribution` e `includeCoAuthoredBy` de `~/.claude/settings.json`.
