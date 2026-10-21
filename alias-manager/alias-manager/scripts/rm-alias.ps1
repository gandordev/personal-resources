$profilePath = $PROFILE

param(
    [Parameter(Mandatory=$true)]
    [string]$aliasName
)

$existing = Select-String -Path $profilePath -Pattern "Set-Alias $aliasName "

if (-not $existing) {
    Write-Host "Alias '$aliasName' no existe."
    exit
}

(Get-Content $profilePath) | Where-Object { $_ -notmatch "Set-Alias $aliasName " } | Set-Content $profilePath
Write-Host "Alias '$aliasName' eliminado."