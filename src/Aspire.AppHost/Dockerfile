# ⚠️ ADVERTENCIA: Este Dockerfile NO FUNCIONA
# El AppHost NO puede ser dockerizado porque Aspire.AppHost.Sdk no genera
# ejecutables publicables tradicionales. El AppHost DEBE ejecutarse localmente.
#
# Este archivo se mantiene solo como referencia, pero NO debe usarse.
# Ver DOCKER.md para la configuración correcta de desarrollo.

# FROM mcr.microsoft.com/dotnet/aspnet:10.0 AS base
# WORKDIR /app
# EXPOSE 15000
# EXPOSE 15001

FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build
ARG BUILD_CONFIGURATION=Release
WORKDIR /src

# Copiar archivos de proyecto para restaurar dependencias
COPY ["src/Aspire.AppHost/Aspire.AppHost.csproj", "src/Aspire.AppHost/"]
COPY ["src/Aspire.Api/Aspire.Api.csproj", "src/Aspire.Api/"]
COPY ["src/Aspire.Application/Aspire.Application.csproj", "src/Aspire.Application/"]
COPY ["src/Aspire.Domain/Aspire.Domain.csproj", "src/Aspire.Domain/"]
COPY ["src/Aspire.Infrastructure/Aspire.Infrastructure.csproj", "src/Aspire.Infrastructure/"]
COPY ["src/ServiceDefaults/ServiceDefaults.csproj", "src/ServiceDefaults/"]

# Restaurar dependencias
RUN dotnet restore "src/Aspire.AppHost/Aspire.AppHost.csproj"

# Copiar todo el código fuente
COPY . .

# Publicar la aplicación
WORKDIR "/src/src/Aspire.AppHost"
RUN dotnet publish "Aspire.AppHost.csproj" -c $BUILD_CONFIGURATION -o /src/publish

FROM base AS final
WORKDIR /app
COPY --from=build /src/publish .

# Variables de entorno para Aspire Dashboard
ENV ASPNETCORE_URLS=https://+:15000;http://+:15001
ENV ASPNETCORE_ENVIRONMENT=Development
ENV DOTNET_ENVIRONMENT=Development
ENV ASPIRE_ALLOW_UNSECURED_TRANSPORT=true
ENV OTEL_EXPORTER_OTLP_ENDPOINT=http://localhost:4317
ENV OTEL_EXPORTER_OTLP_HTTP_ENDPOINT=http://localhost:4318
ENV ASPIRE_DASHBOARD_OTLP_ENDPOINT_URL=http://localhost:4317
ENV ASPIRE_DASHBOARD_OTLP_HTTP_ENDPOINT_URL=http://localhost:4318

ENTRYPOINT ["dotnet", "Aspire.AppHost.dll"]
