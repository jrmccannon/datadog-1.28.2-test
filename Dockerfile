﻿FROM mcr.microsoft.com/dotnet/runtime:5.0 AS base
WORKDIR /app

RUN curl -LO https://github.com/DataDog/dd-trace-dotnet/releases/download/v1.28.2/datadog-dotnet-apm_1.28.2_amd64.deb
sudo dpkg -i ./datadog-dotnet-apm_1.28.2_amd64.deb

FROM mcr.microsoft.com/dotnet/sdk:5.0 AS build
WORKDIR /src
COPY ["datadog-1.28.2-test/datadog-1.28.2-test.csproj", "datadog-1.28.2-test/"]
RUN dotnet restore "datadog-1.28.2-test/datadog-1.28.2-test.csproj"
COPY . .
WORKDIR "/src/datadog-1.28.2-test"
RUN dotnet build "datadog-1.28.2-test.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "datadog-1.28.2-test.csproj" -c Release -o /app/publish

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "datadog-1.28.2-test.dll"]
