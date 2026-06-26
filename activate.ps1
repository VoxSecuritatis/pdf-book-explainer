$root = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $root
& "$root\.venv\Scripts\Activate.ps1"
Write-Host "(.venv) activated -- Python $(python --version)" -ForegroundColor Green
