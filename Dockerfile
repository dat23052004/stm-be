FROM mcr.microsoft.com/dotnet/sdk:9.0.319@sha256:2f5eb32870b4c0074a3d5b5191a03553bcab7b74463a76a7c0a5f3ef65c90fe5 AS build
WORKDIR /source
COPY global.json Directory.Build.props Directory.Packages.props NuGet.Config ./
COPY src/Api/Api.csproj src/Api/packages.lock.json src/Api/
COPY src/Application/Application.csproj src/Application/packages.lock.json src/Application/
COPY src/Domain/Domain.csproj src/Domain/packages.lock.json src/Domain/
COPY src/Infrastructure/Infrastructure.csproj src/Infrastructure/packages.lock.json src/Infrastructure/
RUN dotnet restore src/Api/Api.csproj --locked-mode
COPY src/ src/
RUN dotnet publish src/Api/Api.csproj -c Release --no-restore -o /app/publish /p:UseAppHost=false

FROM mcr.microsoft.com/dotnet/aspnet:9.0.20-noble-chiseled-extra@sha256:c7c53c7bb1e5bdcf216677c6b8e97cda49f4f3351b3c870556024bb800450ddd AS final
WORKDIR /app
COPY --from=build /app/publish .
ENV ASPNETCORE_HTTP_PORTS=8080
EXPOSE 8080
USER $APP_UID
ENTRYPOINT ["dotnet", "Api.dll"]
