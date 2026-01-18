# Guía de Desarrollo - Proyecto Aspire

Esta guía describe el flujo de trabajo de desarrollo para el proyecto Aspire.

## Configuración Inicial

### Prerrequisitos

- [.NET 10.0 SDK](https://dotnet.microsoft.com/download)
- [Docker Desktop](https://www.docker.com/products/docker-desktop) (para desarrollo)
- Editor de código (Visual Studio, VS Code, Rider, etc.)

### Verificar Instalación

```bash
# Verificar .NET SDK
dotnet --version

# Verificar Docker
docker --version
docker-compose --version
```

## Flujo de Trabajo Diario

### 1. Iniciar el Entorno de Desarrollo

#### Terminal 1: AppHost (Local)

```bash
# Navegar al directorio del proyecto
cd d:\Git\ASPIRE

# Ejecutar el AppHost
dotnet run --project src/Aspire.AppHost/Aspire.AppHost.csproj
```

El AppHost iniciará:
- Dashboard en `https://localhost:15000`
- Endpoints OTLP en `localhost:4317` y `localhost:4318`

#### Terminal 2: API en Docker

```bash
# Construir la imagen (solo la primera vez o después de cambios)
docker-compose build

# Iniciar el contenedor
docker-compose up -d

# Ver logs
docker-compose logs -f aspire-api
```

### 2. Desarrollo

#### Hacer Cambios en el Código

1. **Modificar código de la API**:
   - Edita los archivos en `src/Aspire.Api/`
   - Reconstruye la imagen Docker:
     ```bash
     docker-compose up -d --build
     ```

2. **Modificar código del AppHost**:
   - Edita los archivos en `src/Aspire.AppHost/`
   - El AppHost se recarga automáticamente (hot reload)

3. **Agregar nuevos servicios**:
   - Agrega el servicio al AppHost en `src/Aspire.AppHost/Program.cs`
   - Si el servicio necesita Docker, crea un Dockerfile y agrégalo a `docker-compose.yml`

#### Verificar Cambios

- **Dashboard de Aspire**: `https://localhost:15000`
- **API directamente**: `http://localhost:8080`
- **Logs**: `docker-compose logs -f aspire-api`

### 3. Depuración

#### Depurar la API (en Docker)

```bash
# Ver logs en tiempo real
docker-compose logs -f aspire-api

# Acceder al contenedor
docker exec -it aspire-api /bin/sh

# Verificar variables de entorno
docker exec aspire-api env
```

#### Depurar el AppHost (Local)

- Usa el depurador de tu IDE (F5 en Visual Studio/VS Code)
- Los breakpoints funcionan normalmente
- Los logs aparecen en la consola

### 4. Pruebas

```bash
# Ejecutar tests unitarios
dotnet test

# Ejecutar tests de integración (si existen)
dotnet test tests/
```

### 5. Detener el Entorno

```bash
# Detener contenedores Docker
docker-compose down

# Detener AppHost: Ctrl+C en la terminal donde está ejecutándose
```

## Comandos Útiles

### Docker

```bash
# Ver estado de contenedores
docker-compose ps

# Reconstruir sin caché
docker-compose build --no-cache

# Reiniciar un servicio
docker-compose restart aspire-api

# Ver uso de recursos
docker stats

# Limpiar recursos no utilizados
docker system prune
```

### .NET

```bash
# Restaurar dependencias
dotnet restore

# Compilar solución
dotnet build

# Ejecutar sin AppHost (solo API)
dotnet run --project src/Aspire.Api/Aspire.Api.csproj

# Limpiar builds
dotnet clean
```

## Estructura del Proyecto

```
ASPIRE/
├── src/
│   ├── Aspire.Api/          # API principal
│   │   ├── Dockerfile        # Solo para desarrollo
│   │   └── ...
│   ├── Aspire.AppHost/       # Orquestador (ejecutar localmente)
│   │   └── ...
│   ├── Aspire.Application/   # Lógica de aplicación
│   ├── Aspire.Domain/        # Entidades de dominio
│   ├── Aspire.Infrastructure/# Infraestructura
│   └── ServiceDefaults/     # Configuración compartida
├── tests/                    # Tests
├── docker-compose.yml        # Orquestación Docker (desarrollo)
└── DOCKER.md                # Documentación Docker
```

## Próximos Pasos

### Agregar Nuevos Servicios

1. Crea el proyecto del servicio
2. Agrégalo al AppHost:
   ```csharp
   var nuevoServicio = builder.AddProject<Projects.NuevoServicio>("nuevo-servicio");
   ```
3. Si necesita Docker, crea un Dockerfile y agrégalo a `docker-compose.yml`

### Agregar Recursos (Bases de Datos, Cachés, etc.)

```csharp
// En AppHost/Program.cs
var redis = builder.AddRedis("cache");
var postgres = builder.AddPostgres("db");

// Conectar servicios a recursos
var api = builder.AddProject<Projects.Aspire_Api>("api")
    .WithReference(redis)
    .WithReference(postgres);
```

### Configurar Variables de Entorno

- **Desarrollo**: Edita `docker-compose.yml` o `appsettings.Development.json`
- **Producción**: Usa secretos y variables de entorno del orquestador

### Preparar para Producción

Cuando estés listo para producción:

1. **Publicar con Aspire**:
   ```bash
   dotnet run --project src/Aspire.AppHost/Aspire.AppHost.csproj -- publish
   ```

2. **Revisar artefactos generados**:
   - Dockerfiles optimizados
   - docker-compose.yml para producción
   - Configuraciones de despliegue

3. **Desplegar**:
   - Azure Container Apps
   - Kubernetes
   - Otro orquestador soportado

## Troubleshooting Común

### El AppHost no inicia

```bash
# Verificar que los puertos estén libres
netstat -an | findstr :15000
netstat -an | findstr :4317

# Limpiar y reconstruir
dotnet clean
dotnet restore
dotnet build
```

### El contenedor no se conecta al AppHost

- Verifica que el AppHost esté ejecutándose
- Verifica que `host.docker.internal` funcione en tu sistema
- Revisa las variables de entorno OTLP en `docker-compose.yml`

### Cambios en el código no se reflejan

- **API**: Reconstruye la imagen Docker (`docker-compose up -d --build`)
- **AppHost**: Debería recargarse automáticamente, si no, reinícialo

## Recursos Adicionales

- [Documentación de .NET Aspire](https://learn.microsoft.com/dotnet/aspire/)
- [DOCKER.md](./DOCKER.md) - Guía detallada de Docker
- [Documentación de Docker](https://docs.docker.com/)
