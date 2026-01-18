# Bootstrap Proyecto Aspire — .NET 10 Clean Architecture

Este documento contiene los pasos prácticos y secuenciales para levantar la API base del proyecto **Aspire** usando .NET 10, siguiendo una estructura orientada a Clean Architecture.

Requisitos previos:
- .NET 10 SDK instalado (comprobar con `dotnet --version`).
- Git instalado.
- Editor recomendado: Visual Studio 2022/2023 o VS Code.

---

## Paso 1 — Crear carpeta raíz y repositorio Git

```bash
mkdir Aspire
cd Aspire

git init
```

Consejo: crea un repositorio remoto (GitHub/GitLab) y añade el remote origin:

```bash
git remote add origin <url-del-repositorio>
```

---

## Paso 2 — Crear solución .NET

```bash
dotnet new sln -n Aspire
```

Esto crea `Aspire.slnx` y centraliza los proyectos.

---

## Paso 3 — Crear carpetas base

```bash
mkdir src tests
```

Estructura recomendada: `src` para código de producción, `tests` para pruebas.

---

## Paso 4 — Crear proyectos principales

```bash
cd src

dotnet new webapi -n Aspire.Api -f net10.0
dotnet new classlib -n Aspire.Application -f net10.0
dotnet new classlib -n Aspire.Domain -f net10.0
dotnet new classlib -n Aspire.Infrastructure -f net10.0

cd ..
```

Notas:
- `Aspire.Api` contendrá la capa de presentación (controllers, endpoints, configuración de DI).
- `Aspire.Application` contendrá casos de uso, DTOs y lógica sin dependencias de infraestructura.
- `Aspire.Domain` contendrá entidades, agregados y reglas de negocio.
- `Aspire.Infrastructure` contendrá implementaciones concretas (EF Core, Repositorios, Clients).

---

## Paso 5 — Crear proyectos de pruebas

```bash
cd tests

dotnet new xunit -n Aspire.UnitTests -f net10.0
dotnet new xunit -n Aspire.IntegrationTests -f net10.0

cd ..
```

---

## Paso 6 — Agregar proyectos a la solución y referencias entre proyectos

```bash
dotnet sln add src/Aspire.Api/Aspire.Api.csproj
dotnet sln add src/Aspire.Application/Aspire.Application.csproj
dotnet sln add src/Aspire.Domain/Aspire.Domain.csproj
dotnet sln add src/Aspire.Infrastructure/Aspire.Infrastructure.csproj

dotnet sln add tests/Aspire.UnitTests/Aspire.UnitTests.csproj
dotnet sln add tests/Aspire.IntegrationTests/Aspire.IntegrationTests.csproj
```

Agregar referencias de proyecto (ej: la API depende de Application e Infrastructure):

```bash
dotnet add src/Aspire.Api/Aspire.Api.csproj reference src/Aspire.Application/Aspire.Application.csproj
dotnet add src/Aspire.Api/Aspire.Api.csproj reference src/Aspire.Infrastructure/Aspire.Infrastructure.csproj
dotnet add src/Aspire.Application/Aspire.Application.csproj reference src/Aspire.Domain/Aspire.Domain.csproj
```

---

## Paso 7 — Archivos base del repositorio

```bash
dotnet new gitignore
dotnet new editorconfig
```

Configura `.editorconfig` según las reglas de estilo del equipo.

---

## Paso 8 — Primera configuración de la API (sugerencias rápidas)

1. Abrir `src/Aspire.Api/Program.cs` y habilitar Swagger en desarrollo:

```csharp
// ... en Program.cs (ejemplo mínimo)
var builder = WebApplication.CreateBuilder(args);
builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

var app = builder.Build();
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}
app.UseHttpsRedirection();
app.MapControllers();
app.Run();
```

2. Añadir un controller de ejemplo `WeatherForecastController` o un controlador inicial para probar rutas.
3. Registrar dependencias en DI (desde `Aspire.Infrastructure` hacia `Aspire.Application`) en `Program.cs`.

---

## Paso 9 — Restaurar, compilar y ejecutar

```bash
dotnet restore
dotnet build
dotnet run --project src/Aspire.Api
```

Swagger estará disponible en:

```
https://localhost:5001/swagger
```

Si usas Kestrel sin HTTPS en desarrollo, la URL puede ser `http://localhost:5000`.

---

## Paso 10 — Añadir pruebas y ejecutar

```bash
dotnet test
```

Crear pruebas unitarias en `Aspire.UnitTests` y pruebas de integración en `Aspire.IntegrationTests`.

---

## Paso 11 — Dockerización del Proyecto

### 11.1 — Dockerfile para la API

El `Dockerfile` para la API se encuentra en `src/Aspire.Api/Dockerfile` y está optimizado para .NET 10 con soporte para Aspire.

### 11.2 — Dockerfile para el AppHost

Se ha creado un `Dockerfile` para el AppHost en `src/Aspire.AppHost/Dockerfile` (opcional, típicamente el AppHost se ejecuta localmente).

### 11.3 — Docker Compose

Se han creado dos archivos de Docker Compose:

- `docker-compose.yml` - Para ejecutar la API en contenedor
- `docker-compose.apphost.yml` - Para ejecutar el AppHost en contenedor (opcional)

### 11.4 — Comandos para Dockerizar

**Construir las imágenes:**

```bash
# Windows PowerShell
.\docker-build.ps1

# Linux/macOS
chmod +x docker-build.sh
./docker-build.sh

# O manualmente
docker build -f src/Aspire.Api/Dockerfile -t aspire-api:latest .
docker build -f src/Aspire.AppHost/Dockerfile -t aspire-apphost:latest .
```

**Ejecutar con Docker Compose:**

```bash
# Ejecutar solo la API
docker-compose up -d

# Ver logs
docker-compose logs -f aspire-api

# Detener
docker-compose down
```

**Ejecutar AppHost localmente y API en Docker (recomendado para desarrollo):**

```bash
# Terminal 1: Ejecutar AppHost localmente
dotnet run --project src/Aspire.AppHost/Aspire.AppHost.csproj

# Terminal 2: Ejecutar API en Docker
docker-compose up -d
```

Para más detalles, consulta el archivo `DOCKER.md`.

---

## Paso 12 — Buenas prácticas iniciales

- Mantener `Domain` libre de dependencias externas.
- Escribir pruebas unitarias para la lógica de `Application` y `Domain`.
- Configurar CI (GitHub Actions) para `dotnet build` y `dotnet test`.
- Añadir Health Checks y logging estructurado.

---

## Estructura final esperada

```
Aspire
│
├── Aspire.slnx
├── src
│   ├── Aspire.Api
│   ├── Aspire.Application
│   ├── Aspire.Domain
│   └── Aspire.Infrastructure
└── tests
    ├── Aspire.UnitTests
    └── Aspire.IntegrationTests
```

Con esto tendrás una base limpia para desarrollar la API con .NET 10 y aplicar patrones como Clean Architecture, CQRS y pruebas automatizadas.

