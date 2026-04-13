# Script refresh text-logo Portal Utama di semua file HTML

$WorkspaceRoot = "c:\KULIAH\MAGANG\Magang di Perhutani\Portal Utama"
$htmlFiles = Get-ChildItem -Path $WorkspaceRoot -Recurse -Include "*.html" -File
$legacyLogo = 'logo' + '.png'

$textBasedLogo = @"
<span style="font-weight: 700; color: #334155; font-size: 24px; letter-spacing: -0.5px;">PORTAL<span style="color: #1F5F6F; font-weight: normal; font-size: 16px; margin-left: 4px;">UTAMA</span></span>
"@

$replaceCount = 0

foreach ($file in $htmlFiles) {
    try {
        $content = Get-Content -Path $file.FullName -Raw -Encoding UTF8
        $pattern = '<img[^>]*src="(?:\.\./)?img/' + [regex]::Escape($legacyLogo) + '"[^>]*>'
        $newContent = $content -replace $pattern, $textBasedLogo

        if ($newContent -ne $content) {
            Set-Content -Path $file.FullName -Value $newContent -Encoding UTF8 -NoNewline
            $replaceCount++
            Write-Host "Updated brand mark in: $($file.Name)"
        }
    } catch {
        Write-Host "Error processing $($file.FullName): $_" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "Portal Utama text logo refresh complete."
Write-Host "Total files updated: $replaceCount"

