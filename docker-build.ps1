# Script PowerShell para construir las imágenes Docker

Write-Host "Construyendo imagen de Aspire.Api..." -ForegroundColor Green
docker build -f src/Aspire.Api/Dockerfile -t aspire-api:latest .

if ($LASTEXITCODE -eq 0) {
    Write-Host "✓ Imagen de Aspire.Api construida exitosamente" -ForegroundColor Green
} else {
    Write-Host "✗ Error al construir la imagen de Aspire.Api" -ForegroundColor Red
    exit 1
}

Write-Host "`nConstruyendo imagen de Aspire.AppHost..." -ForegroundColor Green
docker build -f src/Aspire.AppHost/Dockerfile -t aspire-apphost:latest .

if ($LASTEXITCODE -eq 0) {
    Write-Host "✓ Imagen de Aspire.AppHost construida exitosamente" -ForegroundColor Green
} else {
    Write-Host "✗ Error al construir la imagen de Aspire.AppHost" -ForegroundColor Red
    exit 1
}

Write-Host "`n✓ Todas las imágenes construidas exitosamente" -ForegroundColor Green
