# Script para agregar o actualizar alias en PowerShell
$profilePath = $PROFILE

param(
    [Parameter(Mandatory=$true)]
    [string]$aliasDef
)

if ($aliasDef -notmatch "=") {
    Write-Host "Formato inválido. Usa: alias_name=value"
    exit
}

$name, $value = $aliasDef -split "=", 2

$existing = Select-String -Path $profilePath -Pattern "Set-Alias $name "

if ($existing) {
    Write-Host "Este alias ya existe: $existing"
    $resp = Read-Host "¿Deseas actualizarlo? [Y/n]"
    if ($resp -in @("y","Y","")) {
        (Get-Content $profilePath) | ForEach-Object { $_ -replace "Set-Alias $name .*", "Set-Alias $name $value" } | Set-Content $profilePath
        Write-Host "Alias actualizado: $name=$value"
    } else {
        Write-Host "Alias no modificado."
    }
} else {
    Add-Content $profilePath "Set-Alias $name $value"
    Write-Host "Alias agregado: $name=$value"
}