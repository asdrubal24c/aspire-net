# ⚠️ DOCKERFILE SOLO PARA DESARROLLO
# Este Dockerfile está diseñado únicamente para desarrollo local.
# Para producción, utiliza los artefactos generados por 'aspire publish'.
#
# Ver DOCKER.md para más información sobre desarrollo vs producción.

FROM mcr.microsoft.com/dotnet/aspnet:10.0 AS base
WORKDIR /app
EXPOSE 8080

FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build
ARG BUILD_CONFIGURATION=Release
WORKDIR /src

# Copiar archivos de proyecto para restaurar dependencias
COPY ["src/Aspire.Api/Aspire.Api.csproj", "src/Aspire.Api/"]
COPY ["src/Aspire.Application/Aspire.Application.csproj", "src/Aspire.Application/"]
COPY ["src/Aspire.Domain/Aspire.Domain.csproj", "src/Aspire.Domain/"]
COPY ["src/Aspire.Infrastructure/Aspire.Infrastructure.csproj", "src/Aspire.Infrastructure/"]
COPY ["src/ServiceDefaults/ServiceDefaults.csproj", "src/ServiceDefaults/"]

# Restaurar dependencias
RUN dotnet restore "src/Aspire.Api/Aspire.Api.csproj"

# Copiar todo el código fuente
COPY . .

# Publicar la aplicación
WORKDIR "/src/src/Aspire.Api"
RUN dotnet publish "Aspire.Api.csproj" -c $BUILD_CONFIGURATION -o /src/publish /p:UseAppHost=false

FROM base AS final
WORKDIR /app
COPY --from=build /src/publish .

# Variables de entorno para Aspire
ENV ASPNETCORE_URLS=http://+:8080
ENV ASPNETCORE_ENVIRONMENT=Development
ENV DOTNET_ENVIRONMENT=Development

ENTRYPOINT ["dotnet", "Aspire.Api.dll"]
