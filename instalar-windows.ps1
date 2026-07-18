# instalar-windows.ps1
# Configura Claude Code para que NUNCA agregue "Generated with Claude Code"
# ni "Co-Authored-By: Claude" a tus commits, e instala un git hook global
# como red de seguridad para todos tus repos.
#
# Uso:
#   powershell -ExecutionPolicy Bypass -File instalar-windows.ps1

$ErrorActionPreference = "Stop"

Write-Host "== 1) Configurando settings.json de Claude Code ==" -ForegroundColor Cyan

$claudeDir = Join-Path $env:USERPROFILE ".claude"
$settingsPath = Join-Path $claudeDir "settings.json"

if (-not (Test-Path $claudeDir)) {
    New-Item -ItemType Directory -Path $claudeDir -Force | Out-Null
}

if (Test-Path $settingsPath) {
    Write-Host "Ya existe $settingsPath, se va a fusionar sin borrar tus otros ajustes." -ForegroundColor Yellow
    $json = Get-Content $settingsPath -Raw | ConvertFrom-Json
} else {
    $json = [pscustomobject]@{}
}

# Agrega o sobreescribe solo las claves relevantes
$json | Add-Member -MemberType NoteProperty -Name "attribution" -Value ([pscustomobject]@{ commit = ""; pr = "" }) -Force
$json | Add-Member -MemberType NoteProperty -Name "includeCoAuthoredBy" -Value $false -Force

$json | ConvertTo-Json -Depth 10 | Out-File -Encoding utf8 $settingsPath
Write-Host "Listo: $settingsPath actualizado." -ForegroundColor Green

Write-Host ""
Write-Host "== 2) Instalando git hook global (commit-msg) como red de seguridad ==" -ForegroundColor Cyan

$hooksDir = Join-Path $env:USERPROFILE ".git-hooks-global"
if (-not (Test-Path $hooksDir)) {
    New-Item -ItemType Directory -Path $hooksDir -Force | Out-Null
}

$sourceHook = Join-Path $PSScriptRoot "git-hooks\commit-msg"
$destHook = Join-Path $hooksDir "commit-msg"
Copy-Item -Path $sourceHook -Destination $destHook -Force

git config --global core.hooksPath $hooksDir
Write-Host "Listo: hook instalado en $hooksDir y activado globalmente (core.hooksPath)." -ForegroundColor Green

Write-Host ""
Write-Host "== Instalacion completa ==" -ForegroundColor Cyan
Write-Host "Reinicia VS Code (o al menos la sesion de Claude Code) y verifica con /status." -ForegroundColor White
Write-Host "A partir de ahora, ningun commit en ninguno de tus repos incluira" -ForegroundColor White
Write-Host "'Generated with Claude Code' ni 'Co-Authored-By: Claude'." -ForegroundColor White
