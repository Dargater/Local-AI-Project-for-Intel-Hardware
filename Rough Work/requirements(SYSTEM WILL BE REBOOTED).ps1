echo "Installing WSL"
wsl --install --no-launch

echo "Installing Python3.12"
winget install --id Python.Python.3.12 --silent --accept-source-agreements --accept-package-agreements

echo "Installing Docker"
winget install --id Docker.DockerDesktop --silent --accept-source-agreements --accept-package-agreements

echo "Installing Git"
winget install -e --id Git.Git

Restart-Computer



$FlagFile = ".\requirement_flag.txt"


if (-not (Test-Path $FlagFile)) {
    Write-Host "Flag file not found. Running setup commands..." -ForegroundColor Cyan
    echo "Installing WSL"
    wsl --install --no-launch

    echo "Installing Python3.12"
    winget install --id Python.Python.3.12 --silent --accept-source-agreements --accept-package-agreements

    echo "Installing Docker"
    winget install --id Docker.DockerDesktop --silent --accept-source-agreements --accept-package-agreements

    echo "Installing Git"
    winget install -e --id Git.Git
    
    New-Item -Path $FlagFile -ItemType "File" -Force | Out-Null
    Write-Host "Setup complete. Flag file created." -ForegroundColor Green

    Restart-Computer

} else {
    Write-Host "Flag file exists! Skipping setup commands." -ForegroundColor Yellow
}