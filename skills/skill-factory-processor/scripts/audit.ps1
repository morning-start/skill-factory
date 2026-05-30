<#
.SYNOPSIS
    Skill Factory Automated Audit Script v1.2
.DESCRIPTION
    Audits SKILL.md files against the 100-point quality scoring system.
    Based on skill-factory v0.8.0 standards (CSO, TDD, layer compliance, etc.)
    v1.2: Fixed Windows path resolution, enhanced CSO/TDD detection rules
.PARAMETER Path
    SKILL.md file path to audit (default: ./SKILL.md)
.PARAMETER Project
    Audit entire project (scan all SKILL.md files)
.PARAMETER Html
    Generate HTML report alongside terminal output
.PARAMETER Verbose
    Show detailed check process
#>

param(
    [string]$Path = "",
    [switch]$Project,
    [switch]$Html,
    [switch]$Verbose
)

$ErrorActionPreference = "Stop"

function Get-ProjectRoot {
    $scriptDir = if ($MyInvocation.MyCommand.Path) { Split-Path $MyInvocation.MyCommand.Path } else { $PWD.Path }
    $candidate = $scriptDir
    while ($candidate) {
        if (Test-Path (Join-Path $candidate "SKILL.md")) {
            return (Resolve-Path $candidate).Path
        }
        $parent = Split-Path $candidate
        if ($parent -eq $candidate) { break }
        $candidate = $parent
    }
    return (Resolve-Path .).Path
}

$projectRoot = Get-ProjectRoot

function Write-Result {
    param([string]$Status, [string]$Message)
    $colors = @{ "PASS" = "Green"; "WARN" = "Yellow"; "FAIL" = "Red" }
    $symbol = @{ "PASS" = "[+]"; "WARN" = "[!]"; "FAIL" = "[-]" }
    Write-Host "  $($symbol[$Status]) $Message" -ForegroundColor $colors[$Status]
}

function HtmlEncode {
    param([string]$Text)
    $Text.Replace('&', '&amp;').Replace('<', '&lt;').Replace('>', '&gt;').Replace('"', '&quot;').Replace("'", '&#39;')
}

function Test-FrontMatter {
    param([string[]]$Content)
    $score = 0; $max = 10; $issues = @()
    $fmJoined = $Content -join "`n"
    if ($fmJoined -match '(?m)^name:\s+\S+') { $score += 2.5 } else { $issues += "Missing: name field" }
    if ($fmJoined -match '(?m)^version:\s+v\d+\.\d+\.\d+') { $score += 2.5 } else { $issues += "Missing: version field (need vX.Y.Z)" }
    if ($fmJoined -match '(?m)^description:\s+.+') { $score += 2.5 } else { $issues += "Missing: description field" }
    if ($fmJoined -match '(?m)^tags:\s+\[') { $score += 2.5 } else { $issues += "Missing: tags field" }
    return @{ Score = $score; Max = $max; Issues = $issues }
}

function Test-CSODescription {
    param([string[]]$Content)
    $score = 0; $max = 15; $issues = @()
    $descLine = $Content | Where-Object { $_ -match '^description:\s*(.+)$' } | Select-Object -First 1
    if (-not $descLine) {
        $issues += "No description field found"
        return @{ Score = 0; Max = $max; Issues = $issues }
    }
    $desc = ($descLine -replace '^description:\s*', '').Trim()
    $len = $desc.Length
    
    if ($desc -match '^Use when\s' -or $desc -match '\.\s*Use when\s') { $score += 5 } else {
        $issues += "Description does NOT contain 'Use when' (CSO violation)"
        $score += 0
    }
    
    $badPatterns = 'workflow', 'steps', 'execute', 'process', 'help guide', 'provides'
    $hasWorkflowSummary = $badPatterns | Where-Object { $desc -match [regex]::Escape($_) }
    if (-not $hasWorkflowSummary) { $score += 5 } else {
        $issues += "Description contains workflow summary (Agent may skip body)"
    }
    
    if ($len -ge 50 -and $len -le 1024) { $score += 5 }
    elseif ($len -lt 50) { $issues += "Too short (${len} chars, recommend 50-1024 for good coverage)"; $score += 2 }
    else { $issues += "Too long (${len} chars, exceeds 1024 limit)"; $score += 2 }
    
    return @{ Score = $score; Max = $max; Issues = $issues }
}

function Test-TDDValidation {
    param([string[]]$Content)
    $score = 0; $max = 15; $issues = @()
    $joined = $Content -join "`n"
    $hasTDD = $joined -match 'TDD|tdd|stress.?test|RED|GREEN|REFACTOR'
    $hasTestRecord = $joined -match '(test_record|test record|stress scenario|baseline)'
    $hasWaiver = $joined -match '(waiver|exempt|豁免|skip.*test.*reason|meta.skill)'
    
    if ($hasTDD) { $score += 5 } else { $issues += "No TDD mention" }
    if ($hasTestRecord) { $score += 5 } else { $issues += "No stress test records" }
    if ($hasWaiver) { $score += 5 } elseif (-not $hasTDD) {
        $issues += "No TDD validation and no waiver"
    } else { $issues += "TDD mentioned but no test records or waiver"; $score += 2 }
    return @{ Score = $score; Max = $max; Issues = $issues }
}

function Test-EssentialSections {
    param([string[]]$Content)
    $score = 0; $max = 10; $issues = @()
    $joined = $Content -join "`n"
    $sections = @{
        "Goal/Target" = '\u4efb\u52a1\u76ee\u6807|\u76ee\u6807|goal|target'
        "Steps" = '\u64cd\u4f5c\u6b65\u9aa4|\u6b65\u9aa4|\u6d41\u7a0b|step'
        "Examples" = '\u793a\u4f8b|example'
        "Notes" = '\u6ce8\u610f\u4e8b\u9879|\u6ce8\u610f|note|caution'
    }
    foreach ($name in $sections.Keys) {
        if ($joined -match $sections[$name]) { $score += 2.5 } else { $issues += "Missing section: [$name]" }
    }
    return @{ Score = $score; Max = $max; Issues = $issues }
}

function Test-LayerCompliance {
    param([string]$FilePath)
    $score = 10; $max = 10; $issues = @()
    $dir = Split-Path (Resolve-Path $FilePath -ErrorAction SilentlyContinue)
    if ($dir -eq $projectRoot) {
        $depth = 0
    } else {
        $relativeDir = $dir.Substring($projectRoot.Length).Trim('\', '/')
        $depth = ($relativeDir -split '[\\/]', -1 | Where-Object { $_ -and $_.Trim() }).Count
    }
    if ($depth -le 3) { $score = 10 }
    elseif ($depth -eq 4) { $score = 5; $issues += "Depth=4 exceeds 3-layer rule" }
    else { $score = 0; $issues += "Depth=$depth severely exceeds limit" }
    return @{ Score = $score; Max = $max; Issues = $issues; Depth = $depth }
}

function Test-NamingConvention {
    param([string]$FilePath)
    $name = (Get-Item $FilePath).BaseName
    if ($name -eq "SKILL") { return @{ Score = 5; Max = 5; Issues = @() } }
    if ($name -cmatch '^[a-z][a-z0-9]*(-[a-z0-9]+)*$') { return @{ Score = 5; Max = 5; Issues = @() } }
    else { return @{ Score = 0; Max = 5; Issues = @("Name '$name' not kebab-case") } }
}

function Test-LinksValid {
    param([string]$FilePath, [string[]]$Content)
    $score = 5; $max = 5; $broken = 0
    try {
        $resolvedPath = Resolve-Path $FilePath -ErrorAction SilentlyContinue
        if (-not $resolvedPath) {
            return @{ Score = 3; Max = $max; Issues = @("Cannot resolve file path: $FilePath") }
        }
        $baseDir = Split-Path $resolvedPath
    } catch {
        return @{ Score = 3; Max = $max; Issues = @("Path resolution error: $_") }
    }

    $links = $Content | Select-String '\]\(([^)]+)\)' | ForEach-Object { $_.Matches.Groups[1].Value } |
        Where-Object { $_ -match '^(\./|\.\./)' -or $_ -notmatch '^(http|https|#)' }

    foreach ($link in $links) {
        try {
            $normalizedLink = $link -replace '/', [System.IO.Path]::DirectorySeparatorChar
            $fullTarget = [System.IO.Path]::GetFullPath((Join-Path $baseDir $normalizedLink))
            
            if (-not (Test-Path $fullTarget)) {
                $altTarget = $fullTarget -replace '\\', '/'
                if (-not (Test-Path $altTarget)) {
                    $broken++
                }
            }
        } catch {
            $broken++
        }
    }
    
    $score = if ($links.Count -gt 0) { [math]::Max(0, $max - $broken) } else { 5 }
    $issues = if ($broken -gt 0) { @("$broken broken internal link(s)") } else { @() }
    return @{ Score = $score; Max = $max; Issues = $issues }
}

function Invoke-SkillAudit {
    param([string]$FilePath)
    Write-Host ""
    Write-Host "=====================================================" -ForegroundColor Cyan
    Write-Host "  Skill Audit: $(Split-Path $FilePath -Leaf)" -ForegroundColor Cyan
    Write-Host "  Path: $FilePath" -ForegroundColor DarkGray
    Write-Host "=====================================================" -ForegroundColor Cyan
    if (-not (Test-Path $FilePath)) { Write-Host "  [-] File not found: $FilePath" -ForegroundColor Red; return }
    
    $content = Get-Content $FilePath -Encoding UTF8
    $lineCount = $content.Count
    $totalScore = 0; $totalMax = 0
    $testResults = @()
    Write-Host "`n  Lines: $lineCount"
    
    $tests = @(
        @{ Name = "Front Matter Complete"; Fn = "Test-FrontMatter" },
        @{ Name = "CSO Description Rule"; Fn = "Test-CSODescription" },
        @{ Name = "TDD Validation";       Fn = "Test-TDDValidation" },
        @{ Name = "Essential Sections";   Fn = "Test-EssentialSections" },
        @{ Name = "Layer Compliance";     Fn = "Test-LayerCompliance" },
        @{ Name = "Naming Convention";    Fn = "Test-NamingConvention" },
        @{ Name = "Link Validity";        Fn = "Test-LinksValid" }
    )
    
    Write-Host "`n  Audit Results:" -ForegroundColor White
    foreach ($test in $tests) {
        if ($Verbose) { Write-Host "  -> Checking: $($test.Name) ..." -ForegroundColor DarkGray }
        $params = @{ Content = $content; FilePath = $FilePath }
        $result = & $test.Fn @params
        $totalScore += $result.Score; $totalMax += $result.Max

        $status = if ($result.Score -ge $result.Max) { "PASS" }
                  elseif ($result.Score -ge $result.Max * 0.5) { "WARN" }
                  else { "FAIL" }
        $testResults += [PSCustomObject]@{
            Name   = $test.Name
            Score  = $result.Score
            Max    = $result.Max
            Status = $status
            Issues = $result.Issues
        }
        
        if ($result.Score -ge $result.Max) { Write-Result -Status "PASS" -Message "$($test.Name) ($($result.Score)/$($result.Max))" }
        elseif ($result.Score -ge $result.Max * 0.5) {
            Write-Result -Status "WARN" -Message "$($test.Name) ($($result.Score)/$($result.Max))"
            foreach ($issue in $result.Issues) { Write-Host "      ! $issue" -ForegroundColor DarkYellow }
        } else {
            Write-Result -Status "FAIL" -Message "$($test.Name) ($($result.Score)/$($result.Max))"
            foreach ($issue in $result.Issues) { Write-Host "      X $issue" -ForegroundColor Red }
        }
        if ($test.Name -eq "Layer Compliance" -and $Verbose) { Write-Host "      Depth: $($result.Depth) layers" -ForegroundColor DarkGray }
    }
    
    $percentage = [math]::Round(($totalScore / $totalMax) * 100)
    $grade = switch ($true) { ($percentage -ge 90) { "A (Excellent)" }; ($percentage -ge 75) { "B (Good)" }; ($percentage -ge 60) { "C (Pass)" }; default { "D (Fail)" } }
    $color = switch ($true) { ($percentage -ge 75) { "Green" }; ($percentage -ge 60) { "Yellow" }; default { "Red" } }
    
    Write-Host ""
    Write-Host "+-------------------------------------------+" -ForegroundColor $color
    Write-Host ("|  Total: {0,-8} ({1,-3}%)  Grade: {2} |" -f "${totalScore}/${totalMax}", $percentage, $grade) -ForegroundColor $color
    Write-Host "+-------------------------------------------+" -ForegroundColor $color
    
    if ($lineCount -gt 500) { Write-Host "  ! WARNING: ${lineCount} lines (>500, consider splitting)" -ForegroundColor Yellow }
    elseif ($lineCount -gt 300) { Write-Host "  i INFO: ${lineCount} lines (Type 3/4 range, expect references/)" -ForegroundColor DarkGray }
    return @{
        Score       = $totalScore
        Max         = $totalMax
        Percent     = $percentage
        Grade       = $grade
        FilePath    = $FilePath
        LineCount   = $lineCount
        TestResults = $testResults
    }
}

function Out-HtmlReport {
    param(
        [hashtable]$AuditData
    )
    $skillName = Split-Path $AuditData.FilePath -Leaf
    $skillDir  = Split-Path $AuditData.FilePath
    $outFile   = Join-Path $skillDir "audit-report.html"
    $now       = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $gradeLetter = $AuditData.Grade.Substring(0,1)
    $gradeColor = switch ($gradeLetter) { "A" { "#10b981" }; "B" { "#3b82f6" }; "C" { "#f59e0b" }; default { "#ef4444" } }

    $statusRows = ""
    foreach ($tr in $AuditData.TestResults) {
        $bgColor = switch ($tr.Status) { "PASS" { "#d1fae5" }; "WARN" { "#fef3c7" }; default { "#fee2e2" } }
        $textColor = switch ($tr.Status) { "PASS" { "#065f46" }; "WARN" { "#92400e" }; default { "#991b1b" } }
        $issuesHtml = ""
        if ($tr.Issues.Count -gt 0) {
            $issuesHtml = "<ul class='issue-list'>"
            foreach ($i in $tr.Issues) { $issuesHtml += "<li>$(HtmlEncode $i)</li>" }
            $issuesHtml += "</ul>"
        } else {
            $issuesHtml = "<span class='no-issue'>No issues</span>"
        }
        $statusRows += @"
        <tr>
            <td class="dim-name">$($tr.Name)</td>
            <td class="dim-score">$($tr.Score)/$($tr.Max)</td>
            <td class="dim-status $($tr.Status.ToLower())">$($tr.Status)</td>
            <td class="dim-issues">$issuesHtml</td>
        </tr>
"@
    }

    $lineNote = if ($AuditData.LineCount -gt 500) { "<span class='warn-text'>⚠ $($AuditData.LineCount) lines (&gt;500, consider splitting)</span>" }
                elseif ($AuditData.LineCount -gt 300) { "<span class='info-text'>ℹ $($AuditData.LineCount) lines (Type 3/4 range)</span>" }
                else { "$($AuditData.LineCount) lines" }

    $html = @"
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Skill Audit Report - $skillName</title>
<style>
*{margin:0;padding:0;box-sizing:border-box}
body{font-family:-apple-system,BlinkMacSystemFont,'Segoe UI',Roboto,sans-serif;background:#f0f2f5;color:#1f2937;line-height:1.6}
.header{background:linear-gradient(135deg,#1e3a5f,#0f172a);color:#fff;padding:32px 24px;text-align:center}
.header h1{font-size:1.8rem;font-weight:700;letter-spacing:-0.5px}
.header .subtitle{opacity:.75;margin-top:6px;font-size:.95rem}
.container{max-width:900px;margin:24px auto;padding:0 16px}
.card{background:#fff;border-radius:12px;box-shadow:0 1px 3px rgba(0,0,0,.08),0 4px 12px rgba(0,0,0,.04);margin-bottom:20px;overflow:hidden}
.card-header{padding:18px 24px;border-bottom:1px solid #e5e7eb;font-weight:600;font-size:1rem;color:#374151;display:flex;align-items:center;gap:8px}
.card-body{padding:20px 24px}
.meta-grid{display:grid;grid-template-columns:repeat(auto-fit,minmax(200px,1fr));gap:12px}
.meta-item{background:#f9fafb;border-radius:8px;padding:12px 16px}
.meta-label{font-size:.75rem;text-transform:uppercase;letter-spacing:.05em;color:#6b7280;margin-bottom:4px}
.meta-value{font-size:1rem;font-weight:600;color:#111827;word-break:break-all}
.score-banner{text-align:center;padding:28px 24px}
.score-big{font-size:3rem;font-weight:800;color:$gradeColor;line-height:1}
.grade-badge{display:inline-block;margin-top:8px;padding:6px 20px;border-radius:20px;background:$gradeColor;color:#fff;font-weight:700;font-size:1.1rem;letter-spacing:1px}
table{width:100%;border-collapse:collapse}
th{text-align:left;padding:12px 14px;background:#f8fafc;font-size:.8rem;text-transform:uppercase;letter-spacing:.05em;color:#6b7280;border-bottom:2px solid #e5e7eb}
td{padding:12px 14px;border-bottom:1px solid #f3f4f6;font-size:.9rem;vertical-align:top}
tr:last-child td{border-bottom:none}
.dim-name{font-weight:500;color:#374151;white-space:nowrap}
.dim-score{font-family:'SF Mono',Consolas,monospace;font-weight:600;color:#4b5563;white-space:nowrap}
.dim-status{font-weight:700;font-size:.8rem;letter-spacing:.5px;text-align:center;white-space:nowrap;border-radius:6px;padding:4px 12px}
.pass{background:#d1fae5;color:#065f46}.warn{background:#fef3c7;color:#92400e}.fail{background:#fee2e2;color:#991b1b}
.issue-list{margin:4px 0 0;padding-left:18px}
.issue-list li{font-size:.82rem;color:#6b7280;margin-bottom:2px}
.no-issue{color:#9ca3af;font-style:italic;font-size:.85rem}
.warn-text{color:#d97706;font-weight:500}
.info-text{color:#6b7280}
.footer{text-align:center;padding:20px;color:#9ca3af;font-size:.8rem}
@media(max-width:600px){.header h1{font-size:1.4rem}.score-big{font-size:2.2rem}table{font-size:.82rem}td,th{padding:8px 10px}}
</style>
</head>
<body>
<div class="header">
<h1>📋 Skill Audit Report</h1>
<div class="subtitle">Generated on $now</div>
</div>
<div class="container">
<div class="card">
<div class="card-body meta-grid">
<div class="meta-item"><div class="meta-label">Skill Name</div><div class="meta-value">$(HtmlEncode $skillName)</div></div>
<div class="meta-item"><div class="meta-label">File Path</div><div class="meta-value">$(HtmlEncode $AuditData.FilePath)</div></div>
<div class="meta-item"><div class="meta-label">Lines</div><div class="meta-value">$lineNote</div></div>
</div>
</div>

<div class="card score-banner">
<div class="score-big">$($AuditData.Score) / $($AuditData.Max)</div>
<div style="font-size:1.1rem;color:#6b7280;margin-top:4px">$($AuditData.Percent)%</div>
<div class="grade-badge">$($AuditData.Grade)</div>
</div>

<div class="card">
<div class="card-header">📊 Dimension Details</div>
<div class="card-body" style="padding:0;overflow-x:auto">
<table>
<thead><tr><th>Dimension</th><th>Score</th><th>Status</th><th>Issues</th></tr></thead>
<tbody>
$statusRows
</tbody>
</table>
</div>
</div>

<div class="footer">Skill Factory Audit v1.1 &middot; Generated at $now</div>
</div>
</body>
</html>
"@
    [System.IO.File]::WriteAllText($outFile, $html, [System.Text.Encoding]::UTF8)
    Write-Host "`n  [HTML] Report saved to: $outFile" -ForegroundColor Green
}

function Out-ProjectHtmlReport {
    param(
        [array]$AllResults
    )
    $outFile = Join-Path $projectRoot "audit-report.html"
    $now     = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $avg     = [math]::Round(($AllResults | Measure-Object -Property Percent -Average).Average)

    $skillRows = ""
    foreach ($r in $AllResults) {
        $gL = $r.Grade.Substring(0,1)
        $gC = switch ($gL) { "A" { "#10b981" }; "B" { "#3b82f6" }; "C" { "#f59e0b" }; default { "#ef4444" } }
        $sName = Split-Path $r.FilePath -Leaf
        $barWidth = [math]::Min($r.Percent, 100)
        $skillRows += @"
        <tr>
            <td>$(HtmlEncode $sName)</td>
            <td style="text-align:center;font-weight:600">$($r.Score)/$($r.Max)</td>
            <td style="text-align:center">$($r.Percent)%</td>
            <td style="text-align:center"><span style="display:inline-block;padding:3px 14px;border-radius:12px;background:$gC;color:#fff;font-weight:700;font-size:.82rem">$($r.Grade)</span></td>
            <td style="min-width:140px">
                <div style="background:#e5e7eb;border-radius:4px;height:8px;overflow:hidden">
                    <div style="background:$gC;width:${barWidth}%;height:100%;border-radius:4px;transition:width .3s"></div>
                </div>
            </td>
            <td class="path-cell">$(HtmlEncode $r.FilePath)</td>
        </tr>
"@
    }

    $avgGrade = switch ($true) { ($avg -ge 90) { "A (Excellent)" }; ($avg -ge 75) { "B (Good)" }; ($avg -ge 60) { "C (Pass)" }; default { "D (Fail)" } }
    $avgColor = switch ($true) { ($avg -ge 75) { "#10b981" }; ($avg -ge 60) { "#f59e0b" }; default { "#ef4444" } }

    $html = @"
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Project Skill Audit Report</title>
<style>
*{margin:0;padding:0;box-sizing:border-box}
body{font-family:-apple-system,BlinkMacSystemFont,'Segoe UI',Roboto,sans-serif;background:#f0f2f5;color:#1f2937;line-height:1.6}
.header{background:linear-gradient(135deg,#1e3a5f,#0f172a);color:#fff;padding:36px 24px;text-align:center}
.header h1{font-size:1.9rem;font-weight:700;letter-spacing:-.5px}
.header .subtitle{opacity:.75;margin-top:6px;font-size:.95rem}
.container{max-width:1000px;margin:24px auto;padding:0 16px}
.card{background:#fff;border-radius:12px;box-shadow:0 1px 3px rgba(0,0,0,.08),0 4px 12px rgba(0,0,0,.04);margin-bottom:20px;overflow:hidden}
.card-header{padding:18px 24px;border-bottom:1px solid #e5e7eb;font-weight:600;font-size:1rem;color:#374151}
.card-body{padding:20px 24px}
.summary-flex{display:flex;gap:24px;justify-content:center;align-items:center;flex-wrap:wrap;padding:28px 24px}
.summary-stat{text-align:center}
.summary-num{font-size:2.8rem;font-weight:800;color:$avgColor;line-height:1}
.summary-label{font-size:.85rem;color:#6b7280;text-transform:uppercase;letter-spacing:.05em;margin-top:4px}
table{width:100%;border-collapse:collapse}
th{text-align:left;padding:12px 14px;background:#f8fafc;font-size:.78rem;text-transform:uppercase;letter-spacing:.05em;color:#6b7280;border-bottom:2px solid #e5e7eb}
td{padding:11px 14px;border-bottom:1px solid #f3f4f6;font-size:.88rem;vertical-align:middle}
tr:last-child td{border-bottom:none}
tr:hover{background:#f9fafb}
.path-cell{color:#6b7280;font-size:.8rem;max-width:280px;word-break:break-all}
.footer{text-align:center;padding:20px;color:#9ca3af;font-size:.8rem}
@media(max-width:700px){.header h1{font-size:1.4rem}.summary-num{font-size:2rem}table{font-size:.8rem}td,th{padding:8px 10px}}
</style>
</head>
<body>
<div class="header">
<h1>📋 Project Skill Audit Report</h1>
<div class="subtitle">Scanned $($AllResults.Count) SKILL.md files &middot; Generated on $now</div>
</div>
<div class="container">

<div class="card">
<div class="summary-flex">
<div class="summary-stat"><div class="summary-num">$($AllResults.Count)</div><div class="summary-label">Skills Scanned</div></div>
<div class="summary-stat"><div class="summary-num">${avg}%</div><div class="summary-label">Average Score</div></div>
<div class="summary-stat"><div class="summary-num" style="font-size:1.4rem">$avgGrade</div><div class="summary-label">Overall Grade</div></div>
</div>
</div>

<div class="card">
<div class="card-header">📊 Skill Comparison</div>
<div class="card-body" style="padding:0;overflow-x:auto">
<table>
<thead><tr><th>Skill</th><th style="text-align:center">Score</th><th style="text-align:center">Percent</th><th style="text-align:center">Grade</th><th>Progress</th><th>Path</th></tr></thead>
<tbody>
$skillRows
</tbody>
</table>
</div>
</div>

<div class="footer">Skill Factory Audit v1.1 &middot; Project Overview &middot; Generated at $now</div>
</div>
</body>
</html>
"@
    [System.IO.File]::WriteAllText($outFile, $html, [System.Text.Encoding]::UTF8)
    Write-Host "`n  [HTML] Project report saved to: $outFile" -ForegroundColor Green
}

if ($Project) {
    $skillFiles = Get-ChildItem -Path $projectRoot -Recurse -Filter "SKILL.md" | Select-Object -ExpandProperty FullName
    $results = @()
    Write-Host "Project Audit: Found $($skillFiles.Count) SKILL.md files" -ForegroundColor Cyan
    foreach ($file in $skillFiles) {
        $r = Invoke-SkillAudit -FilePath $file
        $results += [PSCustomObject]@{ File = $r.FilePath; Score = $r.Score; Max = $r.Max; Percent = $r.Percent; Grade = $r.Grade; LineCount = $r.LineCount; TestResults = $r.TestResults }
    }
    Write-Host "`n" + ("=" * 55) -ForegroundColor Cyan
    Write-Host "  Project Summary" -ForegroundColor Cyan
    Write-Host ("=" * 55) -ForegroundColor Cyan
    $results | Format-Table -AutoSize
    $avg = [math]::Round(($results | Measure-Object -Property Percent -Average).Average)
    Write-Host "`n  Project Average: ${avg}%" -ForegroundColor $(if ($avg -ge 75) { "Green" } elseif ($avg -ge 60) { "Yellow" } else { "Red" })
    if ($Html) { Out-ProjectHtmlReport -AllResults $results }
}
elseif ($Path) {
    $auditResult = Invoke-SkillAudit -FilePath (Resolve-Path $Path)
    if ($Html) { Out-HtmlReport -AuditData $auditResult }
} else {
    $defaultPath = Join-Path $PWD "SKILL.md"
    if (Test-Path $defaultPath) {
        $auditResult = Invoke-SkillAudit -FilePath $defaultPath
        if ($Html) { Out-HtmlReport -AuditData $auditResult }
    }
    else { Write-Host "Usage: .\audit.ps1 -Path <SKILL.md>" -ForegroundColor Yellow; Write-Host "      .\audit.ps1 -Project          # Audit all" -ForegroundColor Yellow; Write-Host "      .\audit.ps1 -Project -Verbose # Detailed" -ForegroundColor Yellow; Write-Host "      .\audit.ps1 -Path <SKILL.md> -Html # With HTML report" -ForegroundColor Yellow }
}
