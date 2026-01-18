# Dockerización del Proyecto Aspire - Solo para Desarrollo

> **⚠️ IMPORTANTE**: Esta configuración de Docker está diseñada **únicamente para desarrollo local**. Para producción, utiliza las herramientas de publicación y despliegue estándar de .NET Aspire.

Este documento describe cómo dockerizar y ejecutar el proyecto Aspire usando Docker **solo para entornos de desarrollo**.

## Estructura de Docker

El proyecto incluye los siguientes archivos Docker:

- `src/Aspire.Api/Dockerfile` - Dockerfile para la API (solo desarrollo)
- `docker-compose.yml` - Orquestación de servicios (API en Docker)
- `.dockerignore` - Archivos excluidos del contexto de Docker

> **Nota**: El AppHost **NO se dockeriza**. El AppHost debe ejecutarse localmente ya que `Aspire.AppHost.Sdk` no genera ejecutables publicables tradicionales. El AppHost está diseñado para ejecutarse en el host y orquestar servicios containerizados.

## Arquitectura Recomendada para Desarrollo

```
┌─────────────────────────────────────────┐
│  Host (Tu máquina local)                │
│  ┌──────────────────────────────────┐  │
│  │  AppHost (ejecutándose local)     │  │
│  │  - Dashboard: https://localhost:  │  │
│  │    15000                          │  │
│  │  - OTLP: localhost:4317/4318      │  │
│  └──────────────────────────────────┘  │
└─────────────────────────────────────────┘
              │
              │ (OTLP)
              ▼
┌─────────────────────────────────────────┐
│  Docker (Contenedores)                  │
│  ┌──────────────────────────────────┐  │
│  │  aspire-api (contenedor)          │  │
│  │  - Puerto: 8080                   │  │
│  └──────────────────────────────────┘  │
└─────────────────────────────────────────┘
```

## Guía de Inicio Rápido - Desarrollo

### Paso 1: Ejecutar el AppHost localmente

En una terminal, ejecuta el AppHost:

```bash
dotnet run --project src/Aspire.AppHost/Aspire.AppHost.csproj
```

Esto iniciará:
- Dashboard de Aspire en `https://localhost:15000`
- Endpoints OTLP en `localhost:4317` (gRPC) y `localhost:4318` (HTTP)

### Paso 2: Construir y ejecutar la API en Docker

En otra terminal, construye y ejecuta la API:

```bash
# Construir la imagen
docker build -f src/Aspire.Api/Dockerfile -t aspire-api:latest .

# Ejecutar con Docker Compose (recomendado)
docker-compose up -d

# O ejecutar manualmente
docker run -d \
  --name aspire-api \
  -p 8080:8080 \
  -e ASPNETCORE_ENVIRONMENT=Development \
  -e OTEL_EXPORTER_OTLP_ENDPOINT=http://host.docker.internal:4317 \
  -e OTEL_EXPORTER_OTLP_HTTP_ENDPOINT=http://host.docker.internal:4318 \
  aspire-api:latest
```

### Paso 3: Verificar que todo funciona

1. **Dashboard de Aspire**: Abre `https://localhost:15000` en tu navegador
2. **API**: Verifica que responde en `http://localhost:8080`
3. **Logs**: Revisa los logs del contenedor:
   ```bash
   docker-compose logs -f aspire-api
   ```

## Comandos Útiles para Desarrollo

### Ver contenedores en ejecución

```bash
docker ps
```

### Ver logs de un contenedor

```bash
# Con docker-compose
docker-compose logs -f aspire-api

# Con docker directamente
docker logs -f aspire-api
```

### Detener los servicios

```bash
# Detener y eliminar contenedores
docker-compose down

# O para un contenedor específico
docker stop aspire-api
docker rm aspire-api
```

### Reconstruir imágenes (después de cambios en el código)

```bash
# Reconstruir sin caché
docker-compose build --no-cache

# Reconstruir y reiniciar
docker-compose up -d --build
```

### Acceder al shell del contenedor

```bash
docker exec -it aspire-api /bin/sh
```

### Limpiar recursos Docker

```bash
# Detener todos los contenedores
docker-compose down

# Limpiar imágenes no utilizadas
docker image prune -a

# Limpiar todo (contenedores, imágenes, volúmenes, redes)
docker system prune -a --volumes
```

## Variables de Entorno - Desarrollo

### Para la API (Docker)

- `ASPNETCORE_ENVIRONMENT=Development` - Entorno de desarrollo
- `DOTNET_ENVIRONMENT=Development` - Entorno .NET
- `ASPNETCORE_URLS=http://+:8080` - URL donde escucha la API
- `OTEL_EXPORTER_OTLP_ENDPOINT=http://host.docker.internal:4317` - Endpoint OTLP gRPC
- `OTEL_EXPORTER_OTLP_HTTP_ENDPOINT=http://host.docker.internal:4318` - Endpoint OTLP HTTP

> **Nota**: `host.docker.internal` permite que el contenedor acceda a servicios en el host (el AppHost local).

### Para el AppHost (Local)

- `ASPNETCORE_URLS=https://localhost:15000;http://localhost:15001` - URLs del dashboard
- `ASPIRE_ALLOW_UNSECURED_TRANSPORT=true` - Permitir HTTP en desarrollo
- `OTEL_EXPORTER_OTLP_ENDPOINT=http://localhost:4317` - Endpoint OTLP gRPC
- `OTEL_EXPORTER_OTLP_HTTP_ENDPOINT=http://localhost:4318` - Endpoint OTLP HTTP

## Configuración de Puertos

| Servicio | Puerto | Descripción |
|----------|--------|-------------|
| API (Docker) | 8080 | HTTP endpoint de la API |
| AppHost Dashboard | 15000 | HTTPS dashboard de Aspire |
| AppHost Dashboard | 15001 | HTTP dashboard de Aspire |
| OTLP gRPC | 4317 | Telemetría gRPC |
| OTLP HTTP | 4318 | Telemetría HTTP |

## Troubleshooting

### El contenedor no inicia

```bash
# Ver logs detallados
docker logs aspire-api

# Verificar que los puertos no estén en uso
# Windows
netstat -an | findstr :8080

# Linux/Mac
lsof -i :8080
```

### La API no se conecta al dashboard

1. **Verifica que el AppHost esté ejecutándose localmente**
   ```bash
   # Deberías ver el dashboard en https://localhost:15000
   ```

2. **Verifica los endpoints OTLP en las variables de entorno**
   - Debe usar `host.docker.internal` desde el contenedor
   - Debe usar `localhost` en el AppHost local

3. **Verifica la red Docker**
   ```bash
   docker network ls
   docker network inspect aspire-network
   ```

### Error: "Ports are not available"

Si obtienes un error de puerto en uso:

```bash
# Encontrar qué proceso usa el puerto (Windows)
netstat -ano | findstr :8080

# Detener contenedores que puedan estar usando el puerto
docker-compose down

# O cambiar el puerto en docker-compose.yml
ports:
  - "8081:8080"  # Cambiar 8080 a 8081 en el host
```

### El contenedor se reinicia constantemente

```bash
# Ver logs para identificar el error
docker logs aspire-api

# Verificar health check
docker inspect aspire-api | grep -A 10 Health
```

### Problemas con host.docker.internal

En algunos sistemas, `host.docker.internal` puede no funcionar. Alternativas:

1. **Usar la IP del host**:
   ```bash
   # En Windows/Mac, generalmente funciona
   # En Linux, puede necesitar:
   --add-host=host.docker.internal:host-gateway
   ```

2. **Usar la IP de la red Docker**:
   ```bash
   # Obtener la IP del host en la red Docker
   docker network inspect bridge | grep Gateway
   ```

## Desarrollo vs Producción

### Desarrollo (Este documento)

- ✅ Docker para servicios individuales (API)
- ✅ AppHost ejecutándose localmente
- ✅ Variables de entorno en `docker-compose.yml`
- ✅ Health checks habilitados
- ✅ Logs detallados
- ✅ Hot reload no disponible (requiere rebuild)

### Producción (No usar Docker directamente)

Para producción, utiliza las herramientas oficiales de .NET Aspire:

1. **Publicar con `aspire publish`**:
   ```bash
   dotnet run --project src/Aspire.AppHost/Aspire.AppHost.csproj -- publish
   ```

2. **Usar integraciones de despliegue**:
   - Azure Container Apps
   - Kubernetes
   - Docker Compose (generado por Aspire)
   - Otros orquestadores soportados

3. **Configuración de producción**:
   - Variables de entorno desde secretos
   - HTTPS habilitado
   - Health checks configurados
   - Límites de recursos (CPU, memoria)
   - Logging estructurado
   - Monitoreo y alertas

> **Importante**: Los Dockerfiles incluidos en este proyecto son para desarrollo local. Para producción, utiliza los artefactos generados por `aspire publish` que incluyen Dockerfiles optimizados y configuraciones de producción.

## Próximos Pasos

1. **Agregar más servicios**: Si necesitas agregar más servicios (bases de datos, cachés, etc.), agrégalos al AppHost y configúralos para ejecutarse en Docker si es necesario.

2. **Configurar recursos externos**: Para desarrollo, puedes usar recursos locales o contenedores Docker para bases de datos, Redis, etc.

3. **Integración continua**: Configura CI/CD para construir y probar las imágenes Docker en pipelines.

4. **Preparar para producción**: Cuando estés listo para producción, utiliza `aspire publish` para generar los artefactos de despliegue apropiados.

## Referencias

- [Documentación de .NET Aspire](https://learn.microsoft.com/dotnet/aspire/)
- [Docker Integration en Aspire](https://learn.microsoft.com/dotnet/aspire/deployment/docker-integration)
- [Aspire Deployment Overview](https://learn.microsoft.com/dotnet/aspire/deployment/overview)
