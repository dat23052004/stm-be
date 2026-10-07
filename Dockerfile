FROM mcr.microsoft.com/dotnet/sdk:9.0.318@sha256:20387c6674c30e46def0cc8cb557bd2a69b35afdf18c19c3694638d0a90897e4 AS build
WORKDIR /source
COPY global.json Directory.Build.props Directory.Packages.props NuGet.Config ./
COPY src/Api/Api.csproj src/Api/packages.lock.json src/Api/
COPY src/Application/Application.csproj src/Application/packages.lock.json src/Application/
COPY src/Domain/Domain.csproj src/Domain/packages.lock.json src/Domain/
COPY src/Infrastructure/Infrastructure.csproj src/Infrastructure/packages.lock.json src/Infrastructure/
RUN dotnet restore src/Api/Api.csproj --locked-mode
COPY src/ src/
RUN dotnet publish src/Api/Api.csproj -c Release --no-restore -o /app/publish /p:UseAppHost=false

FROM mcr.microsoft.com/dotnet/aspnet:9.0.20-noble-chiseled-extra@sha256:d5e173b08f89ec27790a9229c8625fc13d2a0feb997354e8f755f1538c24f455 AS final
WORKDIR /app
COPY --from=build /app/publish .
ENV ASPNETCORE_HTTP_PORTS=8080
EXPOSE 8080
USER $APP_UID
ENTRYPOINT ["dotnet", "Api.dll"]
