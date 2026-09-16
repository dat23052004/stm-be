param(
    [ValidateRange(1024, 65535)][int]$Port = 5085,
    [string]$Image
)

$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot
$apiRoot = Join-Path $projectRoot 'src/Api'
$assemblyPath = Join-Path $apiRoot 'bin/Release/net9.0/Api.dll'
if (-not $Image -and -not (Test-Path -LiteralPath $assemblyPath)) {
    throw 'Build Release first: dotnet build LabX_Be.sln -c Release'
}

$listener = [System.Net.Sockets.TcpListener]::new([System.Net.IPAddress]::Loopback, $Port)
try { $listener.Start() } finally { $listener.Stop() }

$logDirectory = Join-Path $projectRoot 'artifacts/smoke'
New-Item -ItemType Directory -Force -Path $logDirectory | Out-Null
$runId = [Guid]::NewGuid().ToString('N')
$previousEnvironment = $env:ASPNETCORE_ENVIRONMENT
$apiProcess = $null
$containerId = $null
$baseUrl = "http://127.0.0.1:$Port"
try {
    if ($Image) {
        $containerId = docker run --detach --rm --publish "127.0.0.1:${Port}:8080" --env ASPNETCORE_ENVIRONMENT=Development $Image
        if ($LASTEXITCODE -ne 0 -or $containerId -notmatch '^[a-f0-9]{64}$') {
            throw 'Unable to start smoke-test container.'
        }
    } else {
        $env:ASPNETCORE_ENVIRONMENT = 'Development'
        $processOptions = @{
            FilePath = 'dotnet'
            ArgumentList = @(('"{0}"' -f $assemblyPath), '--urls', $baseUrl, '--contentRoot', ('"{0}"' -f $apiRoot))
            WorkingDirectory = $projectRoot
            RedirectStandardOutput = Join-Path $logDirectory "$runId.out.log"
            RedirectStandardError = Join-Path $logDirectory "$runId.err.log"
            PassThru = $true
        }
        if ($env:OS -eq 'Windows_NT') { $processOptions.WindowStyle = 'Hidden' }
        $apiProcess = Start-Process @processOptions
    }
    $ready = $false
    for ($attempt = 0; $attempt -lt 50; $attempt++) {
        if ($null -ne $apiProcess -and $apiProcess.HasExited) { throw "API exited early. See $logDirectory" }
        try {
            $probe = Invoke-WebRequest -UseBasicParsing -Uri "$baseUrl/health" -TimeoutSec 2
            if ($probe.StatusCode -eq 200) { $ready = $true; break }
        } catch {
            Start-Sleep -Milliseconds 200
        }
    }
    if (-not $ready) { throw "API did not become healthy. See $logDirectory" }

    foreach ($path in @('/', '/health', '/health/live', '/health/ready', '/openapi/v1.json')) {
        $response = Invoke-WebRequest -UseBasicParsing -Uri "$baseUrl$path" -TimeoutSec 5
        if ($response.StatusCode -ne 200) { throw "Unexpected status for $path" }
        if (-not $response.Headers['X-Request-Id']) { throw "Missing request ID for $path" }
        if ($path -eq '/' -and ($response.Content | ConvertFrom-Json).name -ne 'LabX') {
            throw 'Unexpected application identity.'
        }
        if ($path.StartsWith('/health') -and $response.Content -ne 'Healthy') {
            throw "Unhealthy response from $path"
        }
        Write-Output "PASS $path ($($response.StatusCode))"
    }

} finally {
    try {
        if ($containerId -match '^[a-f0-9]{64}$') {
            try {
                docker logs $containerId *> (Join-Path $logDirectory "$runId.container.log")
            } finally {
                docker stop --time 5 $containerId | Out-Null
                if ($LASTEXITCODE -ne 0) { throw "Unable to stop smoke-test container $containerId" }
            }
        }
        if ($null -ne $apiProcess -and -not $apiProcess.HasExited) {
            Stop-Process -Id $apiProcess.Id -Force
        }
    } finally {
        $env:ASPNETCORE_ENVIRONMENT = $previousEnvironment
    }
}
