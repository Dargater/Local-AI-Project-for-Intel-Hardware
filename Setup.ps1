
Set-Location $PSScriptRoot


$FlagFile = Join-Path $PSScriptRoot "requirement_flag.txt"


if (-not (Test-Path $FlagFile)) {

    $isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    if (-not $isAdmin) {
        Write-Host "First run needs PowerShell as Administrator. Right-click PowerShell > Run as administrator, then run this script again." -ForegroundColor Red
        exit 1
    }

    Write-Host "Flag file not found. Running setup commands..." -ForegroundColor Cyan
    echo "Installing WSL"
    wsl --install --no-launch

    echo "Installing Python3.12"
    winget install --id Python.Python.3.12 --silent --accept-source-agreements --accept-package-agreements

    echo "Installing Docker"
    winget install --id Docker.DockerDesktop --silent --accept-source-agreements --accept-package-agreements

    echo "Installing Git"
    winget install -e --id Git.Git --silent --accept-source-agreements --accept-package-agreements

    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run" -Name "MySetupScript" -Value "powershell.exe -ExecutionPolicy Bypass -File `"$PSCommandPath`""
    New-Item -Path $FlagFile -ItemType "File" -Force | Out-Null
    Write-Host "Setup complete. Flag file created." -ForegroundColor Green

    Restart-Computer

    exit

} else {
    Write-Host "Flag file exists! Skipping setup commands." -ForegroundColor Yellow
}

if (-not (Get-Command python -ErrorAction SilentlyContinue)) {
    Write-Host "Python was not found. Restart the PC or reinstall Python 3.12, then log in again or re-run this script." -ForegroundColor Red
    Read-Host "Press Enter to close"
    exit 1
}

echo "Setting Up OVMS"
echo "Downloading OVMS"

$ProgressPreference = 'SilentlyContinue'

$release = Invoke-RestMethod -Uri "https://api.github.com/repos/openvinotoolkit/model_server/releases/latest"

$asset = $release.assets | Where-Object { $_.name -like "ovms_windows*python_on.zip" } | Select-Object -First 1

Invoke-WebRequest -Uri $asset.browser_download_url -OutFile "ovms.zip"

Expand-Archive -Path "ovms.zip" -DestinationPath "." -Force

Remove-Item "ovms.zip"

$ProgressPreference = 'Continue'

echo "Setting Up Default Models. If you have modified the script it will install the models from the model url you selected"

python.exe -m pip install --upgrade pip

python -m venv optimum_cli.venv

cd optimum_cli.venv

cd scripts

.\activate.ps1

cd ..\

cd ..\

python.exe -m pip install --upgrade pip

pip install optimum-intel@git+https://github.com/huggingface/optimum-intel.git

mkdir models -Force

cd models


hf download OpenVINO/Qwen3-VL-8B-Instruct-int4-ov --local-dir ./Qwen3-VL-8B-Instruct-int4-ov

hf download ggml-org/Qwen2.5-VL-3B-Instruct-GGUF Qwen2.5-VL-3B-Instruct-Q4_K_M.gguf --local-dir ./Qwen2.5-VL-3B-Instruct-Q4_K_M-gguf

deactivate

cd ..\

python -m venv openwebui.venv

.\openwebui.venv\scripts\activate.ps1

python.exe -m pip install --upgrade pip

pip install open-webui

deactivate

python -m venv docling-serve.venv

.\docling-serve.venv\scripts\activate.ps1

python.exe -m pip install --upgrade pip

pip install "docling-serve[ui]"

cd models

mkdir docling

cd ..


pip install easyocr

docling-tools models download -o .\models\docling

deactivate

irm https://llama.app/install.ps1 | iex

git clone https://github.com/langgenius/dify.git
cd dify/docker
Start-Process "C:\Program Files\Docker\Docker\Docker Desktop.exe"

copy .env.example .env

echo "Waiting for Docker to be ready"
$dockerReady = $false
for ($i = 0; $i -lt 120; $i++) {
    Start-Sleep -Seconds 5
    docker info *> $null
    if ($LASTEXITCODE -eq 0) { $dockerReady = $true; break }
}

if ($dockerReady) {
    docker compose pull
} else {
    Write-Host "Docker did not start in time. Open Docker Desktop, accept its license, then run 'docker compose pull' inside dify\docker." -ForegroundColor Yellow
}

Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run" -Name "MySetupScript" -ErrorAction SilentlyContinue

Write-Host "All setup finished." -ForegroundColor Green
Read-Host "Press Enter to close"
