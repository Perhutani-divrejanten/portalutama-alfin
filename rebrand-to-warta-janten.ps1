# Compatibility wrapper untuk menjalankan rebrand Portal Utama terbaru

$ScriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $ScriptRoot

$latestScript = Join-Path $ScriptRoot 'rebrand-portal-utama.ps1'
if (Test-Path $latestScript) {
    & $latestScript
} else {
    Write-Host 'File rebrand-portal-utama.ps1 tidak ditemukan.' -ForegroundColor Red
}

            @{ Old = "rgb(255, 204, 0)"; New = "rgb(6, 95, 70)" },
            @{ Old = "#31404B"; New = "#1F5F6F" },          # Secondary: abu -> biru
            @{ Old = "#0F172A"; New = "#0F172A" },          # Dark: hitam -> darkgreen
            # Additional color mappings if needed
            @{ Old = "#1e2024"; New = "#0F172A" }
        )
        
        foreach ($replacement in $colorReplacements) {
            $content = $content -replace [regex]::Escape($replacement.Old), $replacement.New
        }
        
        if ($content -ne $originalContent) {
            Set-Content -Path $file.FullName -Value $content -Encoding UTF8 -NoNewline
            $FileChanges["css_files"] += 1
            Write-Log -Message "Updated CSS colors: $($file.Name)"
        }
    } catch {
        Write-ErrorLog -Message "Error processing CSS $($file.FullName): $_"
    }
}

# 4. UPDATE PACKAGE.JSON
Write-Log -Message "--- STEP 4: Updating package.json metadata ---"

$packageJsonFiles = Get-ChildItem -Path $WorkspaceRoot -Recurse -Include "package.json" -File

foreach ($file in $packageJsonFiles) {
    try {
        $content = Get-Content -Path $file.FullName -Raw -Encoding UTF8
        $originalContent = $content
        
        $replacements = @(
            @{ Old = """name"": ""portalutama"""; New = """name"": ""portalutama""" },
            @{ Old = """name"": ""portalutama-article-generator"""; New = """name"": ""portalutama-article-generator""" }
        )
        
        foreach ($replacement in $replacements) {
            $content = $content -replace [regex]::Escape($replacement.Old), $replacement.New
        }
        
        if ($content -ne $originalContent) {
            Set-Content -Path $file.FullName -Value $content -Encoding UTF8 -NoNewline
            $FileChanges["package_files"] += 1
            Write-Log -Message "Updated package.json: $($file.Name)"
        }
    } catch {
        Write-ErrorLog -Message "Error processing package.json $($file.FullName): $_"
    }
}

# 5. UPDATE DOCUMENTATION
Write-Log -Message "--- STEP 5: Updating documentation files ---"

$docFiles = @(
    "AUTOMATION_README.md",
    "GOOGLE_DRIVE_GUIDE.md",
    "GOOGLE_DRIVE_IMAGES_GUIDE.md",
    "netlify.toml",
    "PERBAIKAN_STATUS.md",
    "SEARCH_SETUP.md",
    "TROUBLESHOOTING.md"
)

foreach ($docFile in $docFiles) {
    $filePath = Join-Path $WorkspaceRoot $docFile
    if (Test-Path $filePath) {
        try {
            $content = Get-Content -Path $filePath -Raw -Encoding UTF8
            $originalContent = $content
            
            $replacements = @(
                @{ Old = "Portal Utama"; New = "Portal Utama" },
                @{ Old = "portalutama"; New = "portalutama" },
                @{ Old = "Portal Utama"; New = "Portal Utama" }
            )
            
            foreach ($replacement in $replacements) {
                $content = $content -replace [regex]::Escape($replacement.Old), $replacement.New
            }
            
            if ($content -ne $originalContent) {
                Set-Content -Path $filePath -Value $content -Encoding UTF8 -NoNewline
                $FileChanges["docs"] += 1
                Write-Log -Message "Updated: $docFile"
            }
        } catch {
            Write-ErrorLog -Message "Error processing $docFile`: $_"
        }
    }
}

# 6. VERIFY NO OLD BRANDING REMAINS
Write-Log -Message "--- STEP 6: Verification ---"

$searchPatterns = @("Portal Utama", "portalutama", "Portal Utama")
$foundIssues = @()

foreach ($pattern in $searchPatterns) {
    $results = Get-ChildItem -Path $WorkspaceRoot -Recurse -Include "*.html", "*.css", "*.json", "*.md", "*.toml" -File |
        Select-String -Pattern $pattern -ErrorAction SilentlyContinue

    foreach ($result in $results) {
        if ($result.Path -notlike "*\archive\*" -and $result.Path -notlike "*\.bak.*") {
            $foundIssues += @{
                File = $result.Path
                Pattern = $pattern
                Line = $result.LineNumber
                Content = $result.Line
            }
        }
    }
}

# 7. VERIFY NEW COLORS ARE USED
Write-Log -Message "--- Verifying new color scheme ---"

$newColors = @("#334155", "#0F172A", "#1F5F6F")
$colorFound = @{}

foreach ($color in $newColors) {
    $cssResults = Get-ChildItem -Path (Join-Path $WorkspaceRoot "css") -Include "*.css" -File |
        Select-String -Pattern $color -ErrorAction SilentlyContinue
    $colorFound[$color] = $cssResults.Count -gt 0
}

# 8. SUMMARY
Write-Log -Message ""
Write-Log -Message "===== REBRAND SUMMARY ====="
Write-Log -Message "Main pages updated: $($FileChanges['main_pages'])"
Write-Log -Message "Article pages updated: $($FileChanges['article_pages'])"
Write-Log -Message "CSS files updated: $($FileChanges['css_files'])"
Write-Log -Message "Package files updated: $($FileChanges['package_files'])"
Write-Log -Message "Documentation updated: $($FileChanges['docs'])"

if ($foundIssues.Count -gt 0) {
    Write-Log -Message ""
    Write-Log -Message "⚠️  WARNING: Found $($foundIssues.Count) potential old branding references:" -Type "WARNING"
    foreach ($issue in $foundIssues | Select-Object -First 10) {
        Write-Log -Message "  - File: $($issue.File), Line $($issue.Line): $($issue.Pattern)" -Type "WARNING"
    }
    if ($foundIssues.Count -gt 10) {
        Write-Log -Message "  ... and $($foundIssues.Count - 10) more" -Type "WARNING"
    }
} else {
    Write-Log -Message "✅ No old branding references found!"
}

Write-Log -Message ""
Write-Log -Message "Color scheme verification:"
foreach ($color in $newColors) {
    $status = if ($colorFound[$color]) { "✅ Found" } else { "⚠️  Not found" }
    Write-Log -Message "  $($color): $status"
}

if ($ErrorLog.Count -gt 0) {
    Write-Log -Message ""
    Write-Log -Message "❌ ERRORS ENCOUNTERED:" -Type "ERROR"
    foreach ($error in $ErrorLog) {
        Write-Log -Message "  - $error" -Type "ERROR"
    }
}

Write-Log -Message ""
Write-Log -Message "Rebrand Portal Utama selesai ✅"
Write-Log -Message "Report saved to: $LogFile"
Write-Log -Message "============================="

# Return summary for display
@{
    MainPages = $FileChanges["main_pages"]
    ArticlePages = $FileChanges["article_pages"]
    CSSFiles = $FileChanges["css_files"]
    PackageFiles = $FileChanges["package_files"]
    Docs = $FileChanges["docs"]
    TotalFiles = ($FileChanges.Values | Measure-Object -Sum).Sum
    Issues = $foundIssues.Count
    LogFile = $LogFile
}
