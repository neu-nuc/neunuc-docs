#!/usr/bin/env pwsh
# Generate basic auth credentials for docs
# Usage: .\infra\docs-host\scripts\generate-auth.ps1 <username> <password>

param(
    [string]$Username = "admin",
    [string]$Password = ( -join ((1..24) | ForEach-Object { [char]((48..57) + (65..90) + (97..122) | Get-Random) }) )
)

$ErrorActionPreference = "Stop"
$outFile = Join-Path (Split-Path (Split-Path $PSScriptRoot -Parent) -Parent) "infra\docs-host\.htpasswd"

# Use openssl to generate htpasswd-compatible hash (md5apr1)
$hash = & openssl passwd -apr1 $Password
if ($LASTEXITCODE -ne 0) { throw "openssl failed" }

"${Username}:${hash}" | Set-Content -Path $outFile -Encoding ASCII
Write-Host "Generated: $outFile" -ForegroundColor Green
Write-Host "Username: $Username" -ForegroundColor Cyan
Write-Host "Password: $Password" -ForegroundColor Cyan
