# FreightDW Portfolio → GitHub Push Script
# Usage: .\PUSH_TO_GITHUB.ps1 -GitHubUsername "briansantoso-eng" -GitHubToken "your_token_here"

param(
    [string]$GitHubUsername = "briansantoso-eng",
    [string]$GitHubToken = $(Read-Host "Enter your GitHub Personal Access Token")
)

$PortfolioPath = "C:\Users\burai\OneDrive - WiseTech Global\Data Architect Portfolio"
$RepoName = "FreightDW-DataArchitectPortfolio"

Write-Host "🚀 Starting FreightDW Portfolio Push to GitHub..." -ForegroundColor Green
Write-Host ""

# Check if Git is installed
Write-Host "✓ Checking for Git..."
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Host "❌ Git is not installed!" -ForegroundColor Red
    Write-Host "Please install Git from: https://git-scm.com/download/win" -ForegroundColor Yellow
    exit 1
}
Write-Host "✓ Git found!" -ForegroundColor Green
Write-Host ""

# Navigate to portfolio directory
Write-Host "✓ Navigating to portfolio directory..."
Set-Location $PortfolioPath
Write-Host "✓ Location: $PortfolioPath" -ForegroundColor Green
Write-Host ""

# Initialize Git repository
Write-Host "✓ Initializing Git repository..."
git init
Write-Host "✓ Git initialized!" -ForegroundColor Green
Write-Host ""

# Add all files
Write-Host "✓ Adding all files to Git..."
git add .
$FileCount = (git diff --cached --name-only | Measure-Object).Count
Write-Host "✓ Added $FileCount files!" -ForegroundColor Green
Write-Host ""

# Create initial commit
Write-Host "✓ Creating initial commit..."
git commit -m "Initial commit: FreightDW Portfolio - Enterprise Data Architect

Modules included:
- Module 1: Database + Dim_Date (1,461 days)
- Module 2: Dimensions with SCD Type 1 & 2
- Module 3: Fact_Shipment star schema
- Module 4: Performance & Indexing (6 strategic indexes)
- Module 5: 18 Analytics KPI queries
- Module 7: ETL + SCD Type 2 logic
- Module 8: Data Quality validation (100% passing)
- Module 9: Architecture documentation

Complete documentation with design decisions and trade-offs.
Portfolio demonstrating production-grade data warehouse architecture for Sydney market."

Write-Host "✓ Commit created!" -ForegroundColor Green
Write-Host ""

# Set up Git configuration
Write-Host "✓ Configuring Git..."
git config user.name "Brian Santoso"
git config user.email "brian.santoso@wisetechglobal.com"
Write-Host "✓ Git configured!" -ForegroundColor Green
Write-Host ""

# Add GitHub remote
Write-Host "✓ Adding GitHub remote..."
$RemoteURL = "https://${GitHubUsername}:${GitHubToken}@github.com/${GitHubUsername}/${RepoName}.git"
git remote add origin $RemoteURL
Write-Host "✓ Remote added!" -ForegroundColor Green
Write-Host ""

# Set default branch
Write-Host "✓ Setting default branch to main..."
git branch -M main
Write-Host "✓ Branch set to main!" -ForegroundColor Green
Write-Host ""

# Push to GitHub
Write-Host "✓ Pushing to GitHub..."
try {
    git push -u origin main 2>&1
    Write-Host "✓ Push successful!" -ForegroundColor Green
    Write-Host ""
    Write-Host "✅ SUCCESS! Your portfolio is now on GitHub!" -ForegroundColor Green
    Write-Host ""
    Write-Host "📍 View it at:" -ForegroundColor Cyan
    Write-Host "https://github.com/${GitHubUsername}/${RepoName}" -ForegroundColor Yellow
    Write-Host ""
}
catch {
    Write-Host "❌ Push failed!" -ForegroundColor Red
    Write-Host "Error: $_" -ForegroundColor Red
    exit 1
}
