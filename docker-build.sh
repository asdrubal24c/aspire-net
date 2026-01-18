#!/bin/bash

# Script Bash para construir las imágenes Docker

echo "Construyendo imagen de Aspire.Api..."
docker build -f src/Aspire.Api/Dockerfile -t aspire-api:latest .

if [ $? -eq 0 ]; then
    echo "✓ Imagen de Aspire.Api construida exitosamente"
else
    echo "✗ Error al construir la imagen de Aspire.Api"
    exit 1
fi

echo ""
echo "Construyendo imagen de Aspire.AppHost..."
docker build -f src/Aspire.AppHost/Dockerfile -t aspire-apphost:latest .

if [ $? -eq 0 ]; then
    echo "✓ Imagen de Aspire.AppHost construida exitosamente"
else
    echo "✗ Error al construir la imagen de Aspire.AppHost"
    exit 1
fi

echo ""
echo "✓ Todas las imágenes construidas exitosamente"
