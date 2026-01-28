# Setup GitHub Secrets for CI/CD
# This script helps you add secrets to GitHub repository

param(
    [string]$Repository = "A6-9V/MQL5-Google-Onedrive",
    [string]$Email = "your-email@example.com",
    [string]$Password = "[YOUR_PASSWORD]"
)

Write-Host "========================================" -ForegroundColor Green
Write-Host "GitHub Secrets Setup Helper" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""

Write-Host "⚠️  SECURITY WARNING" -ForegroundColor Yellow
Write-Host "Using passwords in scripts is not recommended." -ForegroundColor Yellow
Write-Host "Please use GitHub Personal Access Token instead!" -ForegroundColor Yellow
Write-Host ""

Write-Host "Repository: $Repository" -ForegroundColor Cyan
Write-Host "Email: $Email" -ForegroundColor Cyan
Write-Host ""

Write-Host "Required GitHub Secrets:" -ForegroundColor Yellow
Write-Host ""
Write-Host "1. GITHUB_TOKEN (Auto-provided by GitHub Actions)" -ForegroundColor White
Write-Host "   ✅ Already available, no action needed" -ForegroundColor Green
Write-Host ""
Write-Host "2. GH_PAT (GitHub Personal Access Token - RECOMMENDED)" -ForegroundColor White
Write-Host "   📋 Steps:" -ForegroundColor Cyan
Write-Host "   a. Go to: https://github.com/settings/tokens" -ForegroundColor Gray
Write-Host "   b. Generate new token (classic)" -ForegroundColor Gray
Write-Host "   c. Select scopes: repo, workflow, write:packages" -ForegroundColor Gray
Write-Host "   d. Copy token" -ForegroundColor Gray
Write-Host "   e. Add to repository secrets:" -ForegroundColor Gray
Write-Host "      https://github.com/$Repository/settings/secrets/actions" -ForegroundColor Gray
Write-Host ""
Write-Host "3. FLY_API_TOKEN (For Fly.io deployment)" -ForegroundColor White
Write-Host "   📋 Get token: flyctl auth token" -ForegroundColor Gray
Write-Host "   📋 Add to: https://github.com/$Repository/settings/secrets/actions" -ForegroundColor Gray
Write-Host ""

Write-Host "Manual Setup Steps:" -ForegroundColor Yellow
Write-Host ""
Write-Host "1. Open: https://github.com/$Repository/settings/secrets/actions" -ForegroundColor Cyan
Write-Host ""
Write-Host "2. Click 'New repository secret'" -ForegroundColor White
Write-Host ""
Write-Host "3. Add these secrets:" -ForegroundColor White
Write-Host "   - Name: GH_PAT" -ForegroundColor Gray
Write-Host "     Value: [Your Personal Access Token]" -ForegroundColor Gray
Write-Host ""
Write-Host "   - Name: FLY_API_TOKEN" -ForegroundColor Gray
Write-Host "     Value: [Your Fly.io API token]" -ForegroundColor Gray
Write-Host ""
Write-Host "   - Name: GITHUB_EMAIL (Optional)" -ForegroundColor Gray
Write-Host "     Value: $Email" -ForegroundColor Gray
Write-Host ""

Write-Host "⚠️  DO NOT ADD PASSWORD AS SECRET!" -ForegroundColor Red
Write-Host "   Use Personal Access Token instead!" -ForegroundColor Red
Write-Host ""

Write-Host "After adding secrets:" -ForegroundColor Yellow
Write-Host "  1. Push code to trigger workflow" -ForegroundColor White
Write-Host "  2. Check Actions tab for workflow status" -ForegroundColor White
Write-Host ""

Write-Host "Quick Test:" -ForegroundColor Cyan
Write-Host "  git add ." -ForegroundColor Gray
Write-Host "  git commit -m 'Setup CI/CD'" -ForegroundColor Gray
Write-Host "  git push origin develop" -ForegroundColor Gray
Write-Host ""
