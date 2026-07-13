# Clear the terminal and set up FastAPI environment automatically
Clear-Host

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $scriptDir

Write-Host "=== FastAPI environment setup ===" -ForegroundColor Cyan

# Find Python executable
if (Get-Command python -ErrorAction SilentlyContinue) {
    $pythonCmd = "python"
    $pythonArgs = @()
} elseif (Get-Command py -ErrorAction SilentlyContinue) {
    $pythonCmd = "py"
    $pythonArgs = @("-3")
} else {
    Write-Error "Python is not available on PATH. Install Python 3 and rerun this script."
    exit 1
}

if (Test-Path .venv) {
    Write-Host "Removing existing virtual environment .venv..." -ForegroundColor Yellow
    Remove-Item -Recurse -Force .venv
}

Write-Host "Creating virtual environment .venv..." -ForegroundColor Green
if ($pythonCmd -eq "py") {
    & $pythonCmd @pythonArgs -m venv .venv
} else {
    & $pythonCmd -m venv .venv
}

Write-Host "Installing pip into the virtual environment..." -ForegroundColor Green
& .\.venv\Scripts\python.exe -m ensurepip --upgrade

Write-Host "Upgrading pip..." -ForegroundColor Green
& .\.venv\Scripts\python.exe -m pip install --upgrade pip

Write-Host "Installing FastAPI and Uvicorn..." -ForegroundColor Green
& .\.venv\Scripts\python.exe -m pip install "fastapi[standard]" uvicorn

if (-not (Test-Path main.py)) {
    Write-Host "Creating starter main.py..." -ForegroundColor Green
    @"
from fastapi import FastAPI

app = FastAPI()

@app.get("/")
def read_root():
    return {"message": "Hello, FastAPI!"}
"@ | Set-Content main.py -Encoding UTF8
}

Write-Host "Writing requirements.txt..." -ForegroundColor Green
@"
fastapi[standard]==0.139.0
uvicorn==0.51.0
"@ | Set-Content requirements.txt -Encoding UTF8

Write-Host "Writing .gitignore..." -ForegroundColor Green
@"
.venv/
__pycache__/
*.pyc
env/
venv/
"@ | Set-Content .gitignore -Encoding UTF8

Write-Host "\nSetup complete!" -ForegroundColor Cyan
Write-Host "Activate the environment with: .\.venv\Scripts\Activate.ps1" -ForegroundColor White
Write-Host "Then run: python -m uvicorn main:app --reload" -ForegroundColor White
