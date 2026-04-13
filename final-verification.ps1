# Final verification for Portal Utama

$WorkspaceRoot = "c:\KULIAH\MAGANG\Magang di Perhutani\Portal Utama"
$legacyTerms = @(
    'Warta' + ' Janten',
    'Warta' + 'Janten',
    'warta' + 'janten'
)
$legacyPattern = ($legacyTerms | ForEach-Object { [regex]::Escape($_) }) -join '|'
$legacyLogoPattern = 'logo' + '\.png'
$extensions = @('.html', '.css', '.json', '.md', '.txt', '.toml', '.js', '.ps1')
$filesToCheck = Get-ChildItem -Path $WorkspaceRoot -Recurse -File -ErrorAction SilentlyContinue |
    Where-Object {
        ($_.Extension -in $extensions) -and
        $_.FullName -notlike '*\node_modules\*' -and
        $_.FullName -notlike '*.bak*'
    }

Write-Host '========== FINAL VERIFICATION - PORTAL UTAMA ==========' -ForegroundColor Cyan
Write-Host ''

$legacyHits = $filesToCheck | Select-String -Pattern $legacyPattern -ErrorAction SilentlyContinue
$logoHits = $filesToCheck | Select-String -Pattern $legacyLogoPattern -ErrorAction SilentlyContinue
$colors = @('#334155', '#0F172A', '#1F5F6F')
$cssFiles = Get-ChildItem -Path (Join-Path $WorkspaceRoot 'css') -Recurse -File -Filter *.css -ErrorAction SilentlyContinue
$foundColors = 0

foreach ($color in $colors) {
    if ($cssFiles.FullName -and (Select-String -Path $cssFiles.FullName -Pattern ([regex]::Escape($color)) -ErrorAction SilentlyContinue)) {
        $foundColors++
        Write-Host "✅ Found theme color $color" -ForegroundColor Green
    } else {
        Write-Host "⚠️ Missing theme color $color" -ForegroundColor Yellow
    }
}

Write-Host ''
Write-Host ('Legacy branding hits : {0}' -f ($legacyHits | Measure-Object).Count) -ForegroundColor $(if (($legacyHits | Measure-Object).Count -eq 0) { 'Green' } else { 'Yellow' })
Write-Host ('Brand image hits     : {0}' -f ($logoHits | Measure-Object).Count) -ForegroundColor $(if (($logoHits | Measure-Object).Count -eq 0) { 'Green' } else { 'Yellow' })
Write-Host ('Theme colors found   : {0}/3' -f $foundColors) -ForegroundColor $(if ($foundColors -eq 3) { 'Green' } else { 'Yellow' })

if ((($legacyHits | Measure-Object).Count -eq 0) -and (($logoHits | Measure-Object).Count -eq 0) -and ($foundColors -eq 3)) {
    Write-Host ''
    Write-Host 'Rebrand Portal Utama selesai ✅' -ForegroundColor Green
} else {
    Write-Host ''
    Write-Host 'Verification completed with follow-up needed.' -ForegroundColor Yellow
}

