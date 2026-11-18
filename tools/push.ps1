param(
    [string]$Remote = "origin",
    [string]$Branch = "feature-paperio-ios"
)

$ErrorActionPreference = "Stop"

Write-Host "=== Paper Territory iOS Push Helper ===" -ForegroundColor Cyan

$currentBranch = (git rev-parse --abbrev-ref HEAD).Trim()
if ($currentBranch -ne $Branch) {
    Write-Host "Current branch is '$currentBranch' (expected '$Branch'). Switching..." -ForegroundColor Yellow
    git checkout $Branch
}

$status = git status --porcelain
if ($status) {
    Write-Host "Working tree has uncommitted changes:" -ForegroundColor Red
    git status --short
    exit 1
}

Write-Host "Commits to push:" -ForegroundColor Green
git log "$Remote/$Branch..HEAD" --oneline

Write-Host "`nPushing $Branch to $Remote..." -ForegroundColor Cyan
git push $Remote $Branch

Write-Host "`nPush succeeded! Check GitHub Actions at:" -ForegroundColor Green
Write-Host "https://github.com/tuna1310/paper-Ios/actions" -ForegroundColor Yellow
