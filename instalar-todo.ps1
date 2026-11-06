# Instalador en UN solo archivo: quita la firma de Claude Code de tus commits.
# Uso:  powershell -ExecutionPolicy Bypass -File instalar-todo.ps1
#
# Hace 3 cosas:
#   1. Crea el hook global (commit-msg) que borra las lineas de firma.
#   2. Activa ese hook con git config --global core.hooksPath.
#   3. Le dice a Claude Code que no agregue la firma (settings.json).

$ErrorActionPreference = 'Stop'

# ---------- 1. Hook global ----------
$hooksDir = Join-Path $env:USERPROFILE '.git-hooks-global'
New-Item -ItemType Directory -Force -Path $hooksDir | Out-Null

$hook = @'
#!/bin/sh
# Borra la firma de Claude Code del mensaje de commit.
f="$1"
sed -i \
  -e '/Generated with \[\{0,1\}Claude Code/d' \
  -e '/^[Cc]o-[Aa]uthored-[Bb]y:.*[Cc]laude/d' \
  -e '/noreply@anthropic\.com/d' \
  "$f"
# quita lineas vacias sobrantes al final
sed -i -e :a -e '/^\n*$/{$d;N;ba' -e '}' "$f"
exit 0
'@

$hookPath = Join-Path $hooksDir 'commit-msg'
[IO.File]::WriteAllText($hookPath, ($hook -replace "`r`n", "`n") + "`n", (New-Object Text.UTF8Encoding $false))
Write-Host "[1/3] Hook creado: $hookPath"

# ---------- 2. Activar el hook en git ----------
git config --global core.hooksPath ($hooksDir -replace '\\', '/')
Write-Host "[2/3] git config --global core.hooksPath configurado"

# ---------- 3. Ajuste de Claude Code ----------
$claudeDir = Join-Path $env:USERPROFILE '.claude'
New-Item -ItemType Directory -Force -Path $claudeDir | Out-Null
$settingsPath = Join-Path $claudeDir 'settings.json'

if (Test-Path $settingsPath) {
    $json = Get-Content $settingsPath -Raw | ConvertFrom-Json
} else {
    $json = [pscustomobject]@{}
}
$json | Add-Member -NotePropertyName attribution -NotePropertyValue ([pscustomobject]@{ commit = ''; pr = '' }) -Force
$json | Add-Member -NotePropertyName includeCoAuthoredBy -NotePropertyValue $false -Force
[IO.File]::WriteAllText($settingsPath, ($json | ConvertTo-Json -Depth 10), (New-Object Text.UTF8Encoding $false))
Write-Host "[3/3] settings.json actualizado: $settingsPath"

Write-Host ""
Write-Host "Listo. Reinicia Claude Code para que se aplique." -ForegroundColor Green
