param([string]$Image)

$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot
if (-not (Get-Command 'trivy' -ErrorAction SilentlyContinue)) {
    throw 'Install Trivy 0.74.0 and add it to PATH; see docs/guides/verification.md.'
}

Push-Location $projectRoot
try {
    $reportDirectory = Join-Path $projectRoot 'artifacts/security'
    New-Item -ItemType Directory -Force -Path $reportDirectory | Out-Null
    trivy fs --scanners vuln,secret --severity HIGH,CRITICAL --exit-code 1 --format json --output (Join-Path $reportDirectory 'repository.json') --skip-dirs .git --skip-dirs .vs --skip-dirs artifacts --skip-dirs '**/bin' --skip-dirs '**/obj' .
    if ($LASTEXITCODE -ne 0) { throw 'Repository scan failed or found HIGH/CRITICAL findings; inspect artifacts/security/repository.json.' }
    Write-Output 'PASS repository vulnerability and secret scan (HIGH/CRITICAL).'

    if ($Image) {
        trivy image --scanners vuln,secret --severity HIGH,CRITICAL --exit-code 1 --format json --output (Join-Path $reportDirectory 'image.json') $Image
        if ($LASTEXITCODE -ne 0) { throw 'Image scan failed or found HIGH/CRITICAL findings; inspect artifacts/security/image.json.' }
        Write-Output "PASS image scan: $Image (HIGH/CRITICAL)."
    }
} finally {
    Pop-Location
}
