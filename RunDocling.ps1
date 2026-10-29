Set-Location $PSScriptRoot
.\docling-serve.venv\scripts\activate.ps1

$FlagFile = Join-Path $PSScriptRoot "\models\docling\EasyOcr\craft_mlt_25k.pth"
if (-not (Test-Path $FlagFile)) {
    docling-tools models download easyocr --output-dir "$PSScriptRoot\models\docling"

}




$env:HF_HUB_OFFLINE = "1"
$env:HF_HUB_DISABLE_SYMLINKS_WARNING = "1"
$env:DOCLING_ARTIFACTS_PATH = "$PSScriptRoot\models\docling"
$env:DOCLING_SERVE_ARTIFACTS_PATH = "$PSScriptRoot\models\docling"
$env:DOCLING_SERVE_ENABLE_REMOTE_SERVICES = "true"





docling-serve run --enable-ui --port 5001