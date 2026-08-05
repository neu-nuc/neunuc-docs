#!/usr/bin/env pwsh
# Deploy NeuNuc Internal Docs locally via Docker
# Usage: .\infra\docs-host\scripts\deploy-local.ps1 [port]

param([int]$Port = 8080)

$ErrorActionPreference = "Stop"
$root = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
Set-Location $root

Write-Host "Building NeuNuc Docs..." -ForegroundColor Cyan
$env:PYTHONPATH = $root
& mkdocs build --strict
if ($LASTEXITCODE -ne 0) { throw "MkDocs build failed" }

Write-Host "Building Docker image..." -ForegroundColor Cyan
docker build -t neunuc-docs .
if ($LASTEXITCODE -ne 0) { throw "Docker build failed" }

Write-Host "Starting container on http://127.0.0.1:${Port}" -ForegroundColor Green
docker stop neunuc-docs 2>$null
docker rm neunuc-docs 2>$null
docker run -d --name neunuc-docs -p "127.0.0.1:${Port}:80" neunuc-docs

Write-Host "Done. Access at http://127.0.0.1:${Port}" -ForegroundColor Green
Write-Host "Default credentials: admin / docs-local-2026" -ForegroundColor Yellow
