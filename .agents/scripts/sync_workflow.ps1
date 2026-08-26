<#
.SYNOPSIS
    Syncs the latest agentic XP skills and personas from DrewGamer/agent-xp-workflow.
.DESCRIPTION
    Pulls the latest skills, personas, and utilities from the upstream repository into
    the current project's .agents directory without overwriting local plans or custom hooks.
#>

[CmdletBinding()]
param (
    [string]$RepoUrl = "https://github.com/DrewGamer/agent-xp-workflow.git",
    [string]$Branch = "main"
)

$ErrorActionPreference = "Stop"

# 1. Locate project root containing .agents
$currentDir = Get-Location
$projectRoot = $currentDir.Path
while (-not (Test-Path (Join-Path $projectRoot ".agents")) -and (Split-Path $projectRoot -Parent)) {
    $projectRoot = Split-Path $projectRoot -Parent
}

if (-not (Test-Path (Join-Path $projectRoot ".agents"))) {
    Write-Error "Could not locate a .agents directory in $currentDir or any parent directory."
    exit 1
}

$agentsDir = Join-Path $projectRoot ".agents"
$tempDir = Join-Path ([System.IO.Path]::GetTempPath()) ("agent-xp-sync-" + [System.Guid]::NewGuid().ToString("N"))

Write-Host "Syncing agent workflow from $RepoUrl ($Branch)..." -ForegroundColor Cyan

try {
    # 2. Shallow clone upstream into temp directory
    git clone --depth 1 --branch $Branch $RepoUrl $tempDir --quiet
    if ($LASTEXITCODE -ne 0) {
        throw "Failed to clone upstream repository."
    }

    # 3. Sync skills
    $srcSkills = Join-Path $tempDir "skills"
    $destSkills = Join-Path $agentsDir "skills"
    if (Test-Path $srcSkills) {
        if (-not (Test-Path $destSkills)) { New-Item -ItemType Directory -Path $destSkills -Force | Out-Null }
        Copy-Item -Path "$srcSkills\*" -Destination $destSkills -Recurse -Force
        Write-Host "  [+] Synced skills -> $destSkills" -ForegroundColor Green
    }

    # 4. Sync personas
    $srcPersonas = Join-Path $tempDir "personas"
    $destPersonas = Join-Path $agentsDir "personas"
    if (Test-Path $srcPersonas) {
        if (-not (Test-Path $destPersonas)) { New-Item -ItemType Directory -Path $destPersonas -Force | Out-Null }
        Copy-Item -Path "$srcPersonas\*" -Destination $destPersonas -Recurse -Force
        Write-Host "  [+] Synced personas -> $destPersonas" -ForegroundColor Green
    }

    # 5. Sync self (sync_workflow.ps1)
    $srcScript = Join-Path $tempDir "scripts\sync_workflow.ps1"
    $destScripts = Join-Path $agentsDir "scripts"
    if (Test-Path $srcScript) {
        if (-not (Test-Path $destScripts)) { New-Item -ItemType Directory -Path $destScripts -Force | Out-Null }
        Copy-Item -Path $srcScript -Destination (Join-Path $destScripts "sync_workflow.ps1") -Force
        Write-Host "  [+] Synced sync script -> $destScripts\sync_workflow.ps1" -ForegroundColor Green
    }

    Write-Host "`nWorkflow successfully synced from upstream!" -ForegroundColor Cyan
}
catch {
    Write-Error "Sync failed: $_"
    exit 1
}
finally {
    if (Test-Path $tempDir) {
        Remove-Item -Path $tempDir -Recurse -Force -ErrorAction SilentlyContinue
    }
}
