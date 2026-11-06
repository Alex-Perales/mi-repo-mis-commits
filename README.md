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

## Instalación en PowerShell (paso a paso)

Abrí **PowerShell** y ejecutá estas líneas, una por una:

**1. Ir a una carpeta (por ejemplo, el Escritorio):**

```powershell
cd $env:USERPROFILE\Desktop
```

**2. Descargar el instalador:**

```powershell
Invoke-WebRequest https://raw.githubusercontent.com/Alex-Perales/mi-repo-mis-commits/main/instalar-todo.ps1 -OutFile instalar-todo.ps1
```

**3. Ejecutarlo:**

```powershell
powershell -ExecutionPolicy Bypass -File instalar-todo.ps1
```

Tenés que ver estos mensajes:

```
[1/3] Hook creado: ...
[2/3] git config --global core.hooksPath configurado
[3/3] settings.json actualizado: ...
Listo. Reinicia Claude Code para que se aplique.
```

**4. Reiniciar Claude Code:** cerrá VS Code, abrilo de nuevo y abrí un chat nuevo.

> Si Windows dice que el archivo está bloqueado, ejecutá `Unblock-File .\instalar-todo.ps1`
> y repetí el paso 3.
>
> Al activar un hook global, dejan de correr los hooks propios de cada repo (`.git/hooks`).

## Verificar que funcionó

Comprobá la configuración:

```powershell
git config --global core.hooksPath
Get-Content $env:USERPROFILE\.claude\settings.json
```

Después hacé un commit con Claude Code y revisá el mensaje:

```powershell
git log -1 --pretty=full
```

No debería aparecer `Co-Authored-By: Claude` ni `Generated with Claude Code`.

## Desinstalar

```powershell
git config --global --unset core.hooksPath
Remove-Item -Recurse -Force "$env:USERPROFILE\.git-hooks-global"
```

Y borrá las claves `attribution` e `includeCoAuthoredBy` de `~/.claude/settings.json`.
