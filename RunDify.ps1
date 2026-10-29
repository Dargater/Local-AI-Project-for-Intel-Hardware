cd dify/docker
Start-Process "C:\Program Files\Docker\Docker\Docker Desktop.exe"

copy .env.example .env
docker compose up -d

echo "Go to http://localhost/"