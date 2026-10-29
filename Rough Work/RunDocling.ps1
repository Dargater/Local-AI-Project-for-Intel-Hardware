$env:DOCLING_SERVE_ENABLE_REMOTE_SERVICES = "true"

.\docling-serve.venv\scripts\activate.ps1

docling-serve run --enable-ui --port 5001