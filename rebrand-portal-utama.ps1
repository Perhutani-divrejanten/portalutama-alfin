$ErrorActionPreference = 'Stop'
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::UTF8

$ScriptPath = $MyInvocation.MyCommand.Path
$WorkspaceRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $WorkspaceRoot

$Utf8NoBom = New-Object System.Text.UTF8Encoding($false)
$PortalLogo = '<span style="font-weight: 700; color: #334155; font-size: 24px; letter-spacing: -0.5px;">PORTAL<span style="color: #1F5F6F; font-weight: normal; font-size: 16px; margin-left: 4px;">UTAMA</span></span>'

function Write-Utf8File {
    param(
        [string]$Path,
        [string]$Content
    )

    [System.IO.File]::WriteAllText($Path, $Content, $Utf8NoBom)
}

function Normalize-Text {
    param([string]$Text)

    if ($null -eq $Text) { return $Text }

    $Text = $Text -replace [string][char]0x201C, '"'
    $Text = $Text -replace [string][char]0x201D, '"'
    $Text = $Text -replace [string][char]0x2018, "'"
    $Text = $Text -replace [string][char]0x2019, "'"
    $Text = $Text -replace [string][char]0x2013, '-'
    $Text = $Text -replace [string][char]0x2014, '-'
    $Text = $Text -replace [string][char]0xFFFD, ' '
    $Text = $Text -replace [string][char]0x00A0, ' '
    $Text = $Text -replace '&nbsp;', ' '

    return $Text
}

function Apply-CommonReplacements {
    param([string]$Content)

    $Content = Normalize-Text $Content

    $legacyBrand = 'Warta' + ' Janten'
    $legacyCompact = 'Warta' + 'Janten'
    $legacyHandle = 'warta' + 'janten'
    $legacyEmailPrimary = $legacyCompact + '33@gmail.com'
    $legacyEmailSecondary = $legacyHandle + '33@gmail.com'
    $legacyEmailAlt1 = $legacyCompact + '@gmail.com'
    $legacyEmailAlt2 = $legacyHandle + '@gmail.com'
    $legacyLegacyPortal = 'Indonesia' + ' Daily'
    $legacyLegacyCompact = 'Indonesia' + 'Daily'
    $legacyLegacyHandle = 'indonesia' + 'daily'

    $replacements = @(
        @{ Old = $legacyEmailPrimary; New = 'portalutama@gmail.com' },
        @{ Old = $legacyEmailSecondary; New = 'portalutama@gmail.com' },
        @{ Old = $legacyEmailAlt1; New = 'portalutama@gmail.com' },
        @{ Old = $legacyEmailAlt2; New = 'portalutama@gmail.com' },
        @{ Old = $legacyLegacyHandle + '@gmail.com'; New = 'portalutama@gmail.com' },

        @{ Old = 'https://twitter.com/' + $legacyCompact; New = 'https://twitter.com/portalutama' },
        @{ Old = 'https://twitter.com/' + $legacyHandle; New = 'https://twitter.com/portalutama' },
        @{ Old = 'https://twitter.com/' + $legacyLegacyHandle; New = 'https://twitter.com/portalutama' },
        @{ Old = 'https://facebook.com/' + $legacyCompact; New = 'https://facebook.com/portalutama' },
        @{ Old = 'https://facebook.com/' + $legacyHandle; New = 'https://facebook.com/portalutama' },
        @{ Old = 'https://facebook.com/' + $legacyLegacyHandle; New = 'https://facebook.com/portalutama' },
        @{ Old = 'https://instagram.com/' + $legacyCompact; New = 'https://instagram.com/portalutama' },
        @{ Old = 'https://instagram.com/' + $legacyHandle; New = 'https://instagram.com/portalutama' },
        @{ Old = 'https://instagram.com/' + $legacyLegacyHandle; New = 'https://instagram.com/portalutama' },
        @{ Old = 'https://youtube.com/@' + $legacyCompact; New = 'https://youtube.com/@portalutama' },
        @{ Old = 'https://youtube.com/@' + $legacyHandle; New = 'https://youtube.com/@portalutama' },
        @{ Old = 'https://youtube.com/@' + $legacyLegacyHandle; New = 'https://youtube.com/@portalutama' },
        @{ Old = 'https://linkedin.com/company/' + $legacyCompact; New = 'https://linkedin.com/company/portalutama' },
        @{ Old = 'https://linkedin.com/company/' + $legacyHandle; New = 'https://linkedin.com/company/portalutama' },
        @{ Old = 'https://linkedin.com/company/' + $legacyLegacyHandle; New = 'https://linkedin.com/company/portalutama' },

        @{ Old = $legacyLegacyPortal; New = 'Portal Utama' },
        @{ Old = $legacyLegacyCompact; New = 'Portal Utama' },
        @{ Old = $legacyLegacyHandle; New = 'portalutama' },
        @{ Old = $legacyBrand; New = 'Portal Utama' },
        @{ Old = $legacyCompact; New = 'Portal Utama' },
        @{ Old = $legacyHandle; New = 'portalutama' },
        @{ Old = 'Biz' + 'News'; New = 'Portal Utama' },
        @{ Old = 'BIZ' + 'NEWS'; New = 'PORTAL UTAMA' },
        @{ Old = 'biz' + 'news'; New = 'portalutama' },

        @{ Old = '#065F46'; New = '#334155' },
        @{ Old = '#1E3A5F'; New = '#1F5F6F' },
        @{ Old = '#022C22'; New = '#0F172A' },
        @{ Old = '#FFCC00'; New = '#334155' },
        @{ Old = '#ffcc00'; New = '#334155' },
        @{ Old = '#fc0'; New = '#334155' },
        @{ Old = '#FFC107'; New = '#334155' },
        @{ Old = '#ffc107'; New = '#334155' },
        @{ Old = '#1E2024'; New = '#0F172A' },
        @{ Old = '#b38f00'; New = '#1F5F6F' },
        @{ Old = '#d9ad00'; New = '#1F5F6F' },
        @{ Old = '#cca300'; New = '#1F5F6F' },
        @{ Old = '#bf9900'; New = '#1F5F6F' },
        @{ Old = '#e0a800'; New = '#1F5F6F' },
        @{ Old = '#d39e00'; New = '#1F5F6F' },
        @{ Old = '#c69500'; New = '#1F5F6F' },
        @{ Old = 'rgba(255,204,0,0.25)'; New = 'rgba(51,65,85,0.25)' },
        @{ Old = 'rgba(255,204,0,0.5)'; New = 'rgba(31,95,111,0.45)' },
        @{ Old = 'rgba(255,193,7,0.5)'; New = 'rgba(31,95,111,0.45)' },
        @{ Old = 'rgba(222,179,6,0.5)'; New = 'rgba(31,95,111,0.45)' },
        @{ Old = '#39569E'; New = '#334155' },
        @{ Old = '#52AAF4'; New = '#1F5F6F' },
        @{ Old = '#0185AE'; New = '#0F172A' },
        @{ Old = '#C8359D'; New = '#1F5F6F' },
        @{ Old = '#DC472E'; New = '#334155' }
    )

    foreach ($item in $replacements) {
        $Content = $Content.Replace($item.Old, $item.New)
    }

    return $Content
}

function Apply-HtmlReplacements {
    param([string]$Content)

    $legacyLogoPattern = '(?:\.\./)?img/' + 'logo' + '\.png'

    $Content = [regex]::Replace(
        $Content,
        '<span style="font-weight:\s*(?:bold|700);\s*color:\s*#[A-Fa-f0-9]{6};\s*font-size:\s*24px;\s*letter-spacing:\s*-0\.5px;">\s*WARTA\s*<span style="color:\s*#[A-Fa-f0-9]{6};\s*font-weight:\s*(?:normal|500);\s*font-size:\s*(?:16|18)px;\s*margin-left:\s*(?:2|4)px;">\s*JANTEN\s*</span>\s*</span>',
        $PortalLogo,
        [System.Text.RegularExpressions.RegexOptions]::IgnoreCase
    )
    $Content = $Content.Replace('<h1 class="m-0 display-4 text-uppercase text-primary">Indonesia<span class="text-secondary font-weight-normal">Daily</span></h1>', $PortalLogo)
    $Content = $Content.Replace('<h1 class="m-0 display-4 text-uppercase text-primary">Portal<span class="text-secondary font-weight-normal">Utama</span></h1>', $PortalLogo)

    $Content = [regex]::Replace(
        $Content,
        '<img[^>]*src="' + $legacyLogoPattern + '"[^>]*>',
        $PortalLogo,
        [System.Text.RegularExpressions.RegexOptions]::IgnoreCase
    )

    $Content = $Content -replace '(<title>\s*)Portal Utama\s*-\s*(.*?)(\s*</title>)', '$1$2 - Portal Utama$3'
    $Content = $Content -replace '(<title>\s*)(.*?)\s*-\s*PortalUtama(\s*</title>)', '$1$2 - Portal Utama$3'

    return $Content
}

function Update-File {
    param(
        [string]$Path,
        [string]$Category,
        [hashtable]$Counts
    )

    $original = [System.IO.File]::ReadAllText($Path)
    $updated = Apply-CommonReplacements $original

    if ($Path -like '*.html') {
        $updated = Apply-HtmlReplacements $updated
    }

    if ($updated -ne $original) {
        Write-Utf8File -Path $Path -Content $updated
        $Counts[$Category]++
    }
}

if (Test-Path (Join-Path $WorkspaceRoot 'articles.json')) {
    Copy-Item (Join-Path $WorkspaceRoot 'articles.json') (Join-Path $WorkspaceRoot 'articles.json.bak') -Force
}

$counts = @{
    'main pages' = 0
    'article pages' = 0
    'css' = 0
    'package' = 0
    'docs' = 0
}

Get-ChildItem -Path $WorkspaceRoot -Recurse -File -Include *.html | ForEach-Object {
    if ($_.FullName -like '*\article\*') {
        Update-File -Path $_.FullName -Category 'article pages' -Counts $counts
    } else {
        Update-File -Path $_.FullName -Category 'main pages' -Counts $counts
    }
}

Get-ChildItem -Path (Join-Path $WorkspaceRoot 'css') -Recurse -File -Include *.css | ForEach-Object {
    Update-File -Path $_.FullName -Category 'css' -Counts $counts
}

$packageFiles = @(
    (Join-Path $WorkspaceRoot 'package.json'),
    (Join-Path $WorkspaceRoot 'package-lock.json'),
    (Join-Path $WorkspaceRoot 'tools\package.json'),
    (Join-Path $WorkspaceRoot 'tools\sites-config.json')
) | Where-Object { Test-Path $_ }

$packageFiles | ForEach-Object {
    Update-File -Path $_ -Category 'package' -Counts $counts
}

Get-ChildItem -Path $WorkspaceRoot -Recurse -File -Include *.md,*.txt,*.toml,*.ps1 |
    Where-Object { $_.FullName -ne $ScriptPath } |
    ForEach-Object {
        if ($_.Name -eq 'package-lock.json' -or $_.Name -eq 'package.json') { return }
        Update-File -Path $_.FullName -Category 'docs' -Counts $counts
    }

Write-Host ''
Write-Host '=== REBRAND PORTAL UTAMA ===' -ForegroundColor Cyan
Write-Host ("main pages   : {0}" -f $counts['main pages']) -ForegroundColor Green
Write-Host ("article pages: {0}" -f $counts['article pages']) -ForegroundColor Green
Write-Host ("css          : {0}" -f $counts['css']) -ForegroundColor Green
Write-Host ("package      : {0}" -f $counts['package']) -ForegroundColor Green
Write-Host ("docs         : {0}" -f $counts['docs']) -ForegroundColor Green
Write-Host 'Rebrand Portal Utama selesai ✅' -ForegroundColor Green
