# ---------------------------------------------------------------------------
# COMMENT LEGEND (delete these comments later):
#   [ADDED]   = new lines I added
#   [CHANGED] = one of your lines that I modified a little
#   [FIXED]   = a broken line of yours that I repaired
# Anything without a comment is your original code, untouched.
# ---------------------------------------------------------------------------

# [ADDED] After the restart, Windows starts this script from a different folder.
# This forces everything (ovms, models, venvs, dify) to be created next to this script.
Set-Location $PSScriptRoot

# [CHANGED] Was ".\requirement_flag.txt" (relative). Now it always points next to the script,
# so the script can still find the flag after the restart.
$FlagFile = Join-Path $PSScriptRoot "requirement_flag.txt"


if (-not (Test-Path $FlagFile)) {

    # [ADDED] wsl --install and the Docker install need Administrator rights, so stop early with a clear message.
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
    # [CHANGED] Added --silent and the agreement flags so the Git installer does not pop up a window or ask questions.
    winget install -e --id Git.Git --silent --accept-source-agreements --accept-package-agreements

    # [FIXED] Your line was missing "Set-ItemProperty -Path" at the start, which broke the whole file.
    # This adds a startup entry so Windows runs this script again at your next login (after the restart).
    # It is removed again at the very end of the script.
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run" -Name "MySetupScript" -Value "powershell.exe -ExecutionPolicy Bypass -File `"$PSCommandPath`""
    New-Item -Path $FlagFile -ItemType "File" -Force | Out-Null
    Write-Host "Setup complete. Flag file created." -ForegroundColor Green

    Restart-Computer

    # [ADDED] Restart-Computer does not stop the script, it keeps running while Windows shuts down.
    # exit makes sure nothing below runs before the restart.
    exit

} else {
    Write-Host "Flag file exists! Skipping setup commands." -ForegroundColor Yellow
}

# [ADDED] Stop with a clear message if Python is not available, instead of a pile of confusing errors.
# The startup entry stays, so setup tries again at your next login.
if (-not (Get-Command python -ErrorAction SilentlyContinue)) {
    Write-Host "Python was not found. Restart the PC or reinstall Python 3.12, then log in again or re-run this script." -ForegroundColor Red
    Read-Host "Press Enter to close"
    exit 1
}

# [CHANGED] Your Remove-ItemProperty line was here with no -Name (it would stop and ask for one).
# I moved it to the very end of the script, so the startup entry is only removed once everything finished.
echo "Setting Up OVMS"
echo "Downloading OVMS"

# [ADDED] The progress bar makes Invoke-WebRequest MUCH slower in Windows PowerShell 5.1. This turns it off.
$ProgressPreference = 'SilentlyContinue'

$release = Invoke-RestMethod -Uri "https://api.github.com/repos/openvinotoolkit/model_server/releases/latest"

# [CHANGED] Added "| Select-Object -First 1" so the download still works if more than one file matches.
$asset = $release.assets | Where-Object { $_.name -like "ovms_windows*python_on.zip" } | Select-Object -First 1

Invoke-WebRequest -Uri $asset.browser_download_url -OutFile "ovms.zip"

Expand-Archive -Path "ovms.zip" -DestinationPath "." -Force

Remove-Item "ovms.zip"

# [ADDED] Turn the progress bar back on.
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

# [CHANGED] Added -Force so re-running the script does not show an error if the folder already exists.
mkdir models -Force

cd models


hf download OpenVINO/Qwen3-VL-8B-Instruct-int4-ov --local-dir ./Qwen3-VL-8B-Instruct-int4-ov

hf download ggml-org/Qwen2.5-VL-3B-Instruct-GGUF Qwen2.5-VL-3B-Instruct-Q4_K_M.gguf --local-dir ./Qwen2.5-VL-3B-Instruct-Q4_K_M-gguf

deactivate

# [ADDED] Go back out of the models folder. Without this, the next venvs were created INSIDE models\
# and the later "cd .." lines walked out of the project folder.
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

# [CHANGED] Removed one "cd .." here. It would have moved out of the project folder
# (the Dify clone below ended up outside the project because of this).

pip install easyocr

# [ADDED] run_docling.ps1 runs Docling in offline mode, so its models have to be downloaded to models\docling now.
# Runs while the docling venv is still active (that is where the docling-tools command lives).
docling-tools models download -o .\models\docling

deactivate

irm https://llama.app/install.ps1 | iex

git clone https://github.com/langgenius/dify.git
cd dify/docker
Start-Process "C:\Program Files\Docker\Docker\Docker Desktop.exe"

copy .env.example .env

# [ADDED] Docker Desktop needs a minute or more to start. Without waiting, "docker compose" fails straight away.
# This checks every 5 seconds for up to 10 minutes.
echo "Waiting for Docker to be ready"
$dockerReady = $false
for ($i = 0; $i -lt 120; $i++) {
    Start-Sleep -Seconds 5
    docker info *> $null
    if ($LASTEXITCODE -eq 0) { $dockerReady = $true; break }
}

# [CHANGED] Replaced "docker compose up -d" + "docker compose down" with "docker compose pull".
# It downloads the same images without starting Dify (so no port 80 clashes, nothing left running).
if ($dockerReady) {
    docker compose pull
} else {
    Write-Host "Docker did not start in time. Open Docker Desktop, accept its license, then run 'docker compose pull' inside dify\docker." -ForegroundColor Yellow
}

# [ADDED] Setup is finished, so remove the startup entry (with the -Name that was missing before).
# If the script stopped early, this line is never reached and setup retries at the next login.
Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run" -Name "MySetupScript" -ErrorAction SilentlyContinue

# [ADDED] Keeps the window open so you can read the output when it runs by itself after the restart.
Write-Host "All setup finished." -ForegroundColor Green
Read-Host "Press Enter to close"
