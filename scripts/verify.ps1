param(
    [ValidateSet('Debug', 'Release')][string]$Configuration = 'Release',
    [switch]$UpdateLockFile
)

$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot
Push-Location $projectRoot
try {
    $restoreMode = if ($UpdateLockFile) { '--force-evaluate' } else { '--locked-mode' }
    dotnet restore LabX_Be.sln $restoreMode
    if ($LASTEXITCODE -ne 0) { throw 'Restore failed.' }

    dotnet format LabX_Be.sln --verify-no-changes --no-restore
    if ($LASTEXITCODE -ne 0) { throw 'Formatting or analyzer checks failed.' }

    dotnet build LabX_Be.sln --configuration $Configuration --no-restore
    if ($LASTEXITCODE -ne 0) { throw 'Build failed.' }

    dotnet test LabX_Be.sln --configuration $Configuration --no-build --logger trx --collect:'XPlat Code Coverage' --results-directory artifacts/test-results
    if ($LASTEXITCODE -ne 0) { throw 'Tests failed.' }
} finally {
    Pop-Location
}
