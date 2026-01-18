# Proyecto Aspire

Proyecto .NET Aspire con arquitectura de microservicios.

## Prerrequisitos

- [.NET 10.0 SDK](https://dotnet.microsoft.com/download)
- [Docker Desktop](https://www.docker.com/products/docker-desktop) (para desarrollo)
- Editor de código (Visual Studio, VS Code, Rider, etc.)

## Arquitectura

```
┌─────────────────────────────────────────┐
│  Host (Máquina local)                   │
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

> **Nota**: El AppHost **NO se dockeriza**. Debe ejecutarse localmente ya que `Aspire.AppHost.Sdk` no genera ejecutables publicables tradicionales.

---

## Fase 1: Desarrollo

### Inicio Rápido

#### 1. Ejecutar AppHost (Terminal 1)

```bash
dotnet run --project src/Aspire.AppHost/Aspire.AppHost.csproj
```

Inicia:
- Dashboard: `https://localhost:15000`
- OTLP: `localhost:4317` (gRPC) y `localhost:4318` (HTTP)

#### 2. Ejecutar API en Docker (Terminal 2)

```bash
# Construir y ejecutar
docker-compose up -d

# Ver logs
docker-compose logs -f aspire-api
```

#### 3. Verificar

- Dashboard: `https://localhost:15000`
- API: `http://localhost:8080`

### Flujo de Desarrollo

#### Modificar Código

- **API**: Edita `src/Aspire.Api/` → Reconstruye: `docker-compose up -d --build`
- **AppHost**: Edita `src/Aspire.AppHost/` → Hot reload automático

#### Comandos Útiles

```bash
# Docker
docker-compose ps              # Ver contenedores
docker-compose logs -f         # Ver logs
docker-compose down            # Detener
docker-compose up -d --build   # Reconstruir y reiniciar

# .NET
dotnet build                   # Compilar
dotnet test                    # Ejecutar tests
dotnet clean                   # Limpiar builds
```

### Configuración

#### Puertos

| Servicio | Puerto | Descripción |
|----------|--------|-------------|
| API | 8080 | HTTP endpoint |
| Dashboard | 15000 | HTTPS dashboard |
| Dashboard | 15001 | HTTP dashboard |
| OTLP gRPC | 4317 | Telemetría gRPC |
| OTLP HTTP | 4318 | Telemetría HTTP |

#### Variables de Entorno (API en Docker)

- `ASPNETCORE_ENVIRONMENT=Development`
- `OTEL_EXPORTER_OTLP_ENDPOINT=http://host.docker.internal:4317`
- `OTEL_EXPORTER_OTLP_HTTP_ENDPOINT=http://host.docker.internal:4318`

> `host.docker.internal` permite que el contenedor acceda al AppHost en el host.

### Troubleshooting

#### Contenedor no inicia
```bash
docker logs aspire-api
netstat -an | findstr :8080  # Windows
```

#### API no se conecta al dashboard
- Verifica que AppHost esté ejecutándose
- Verifica variables de entorno OTLP en `docker-compose.yml`
- Usa `host.docker.internal` desde el contenedor

#### Puerto en uso
```bash
docker-compose down
# O cambiar puerto en docker-compose.yml
```

---

## Fase 2: Producción

> **⚠️ IMPORTANTE**: Los Dockerfiles en este proyecto son **solo para desarrollo**. Para producción, usa los artefactos generados por `aspire publish`.

### Publicar con Aspire

```bash
dotnet run --project src/Aspire.AppHost/Aspire.AppHost.csproj -- publish
```

Esto genera:
- Dockerfiles optimizados para producción
- `docker-compose.yml` para producción
- Configuraciones de despliegue
- Variables de entorno parametrizadas

### Opciones de Despliegue

- **Azure Container Apps**
- **Kubernetes**
- **Docker Compose** (generado por Aspire)
- Otros orquestadores soportados

### Configuración de Producción

- Variables de entorno desde secretos
- HTTPS habilitado
- Health checks configurados
- Límites de recursos (CPU, memoria)
- Logging estructurado
- Monitoreo y alertas

### Próximos Pasos

1. Revisar artefactos generados en el directorio de publicación
2. Configurar secretos y variables de entorno
3. Desplegar usando el orquestador elegido
4. Configurar monitoreo y alertas

---

## Estructura del Proyecto

```
ASPIRE/
├── src/
│   ├── Aspire.Api/          # API principal
│   │   └── Dockerfile        # Solo desarrollo
│   ├── Aspire.AppHost/       # Orquestador (local)
│   ├── Aspire.Application/   # Lógica de aplicación
│   ├── Aspire.Domain/        # Entidades de dominio
│   ├── Aspire.Infrastructure/# Infraestructura
│   └── ServiceDefaults/     # Configuración compartida
├── tests/                    # Tests
├── docker-compose.yml        # Docker Compose (desarrollo)
└── README.md                 # Este archivo
```

---

## Referencias

- [Documentación de .NET Aspire](https://learn.microsoft.com/dotnet/aspire/)
- [Docker Integration](https://learn.microsoft.com/dotnet/aspire/deployment/docker-integration)
- [Aspire Deployment Overview](https://learn.microsoft.com/dotnet/aspire/deployment/overview)
