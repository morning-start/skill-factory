<#
.SYNOPSIS
    Skill Factory Automated Audit Script v1.0
.DESCRIPTION
    Audits SKILL.md files against the 100-point quality scoring system.
    Based on skill-factory v0.8.0 standards (CSO, TDD, layer compliance, etc.)
.PARAMETER Path
    SKILL.md file path to audit (default: ./SKILL.md)
.PARAMETER Project
    Audit entire project (scan all SKILL.md files)
.PARAMETER Verbose
    Show detailed check process
#>

param(
    [string]$Path = "",
    [switch]$Project,
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
    $baseDir = Split-Path (Resolve-Path $FilePath)
    $links = $Content | Select-String '\]\(([^)]+)\)' | ForEach-Object { $_.Matches.Groups[1].Value } |
        Where-Object { $_ -match '^(\./|\.\./)' -or $_ -notmatch '^(http|https|#)' }
    foreach ($link in $links) { $target = [System.IO.Path]::GetFullPath((Join-Path $baseDir $link)); if (-not (Test-Path $target)) { $broken++ } }
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
    return @{ Score = $totalScore; Max = $totalMax; Percent = $percentage; Grade = $grade }
}

if ($Project) {
    $skillFiles = Get-ChildItem -Path $projectRoot -Recurse -Filter "SKILL.md" | Select-Object -ExpandProperty FullName
    $results = @()
    Write-Host "Project Audit: Found $($skillFiles.Count) SKILL.md files" -ForegroundColor Cyan
    foreach ($file in $skillFiles) {
        $r = Invoke-SkillAudit -FilePath $file
        $results += [PSCustomObject]@{ File = $file; Score = $r.Score; Max = $r.Max; Percent = $r.Percent; Grade = $r.Grade }
    }
    Write-Host "`n" + ("=" * 55) -ForegroundColor Cyan
    Write-Host "  Project Summary" -ForegroundColor Cyan
    Write-Host ("=" * 55) -ForegroundColor Cyan
    $results | Format-Table -AutoSize
    $avg = [math]::Round(($results | Measure-Object -Property Percent -Average).Average)
    Write-Host "`n  Project Average: ${avg}%" -ForegroundColor $(if ($avg -ge 75) { "Green" } elseif ($avg -ge 60) { "Yellow" } else { "Red" })
}
elseif ($Path) {
    Invoke-SkillAudit -FilePath (Resolve-Path $Path)
} else {
    $defaultPath = Join-Path $PWD "SKILL.md"
    if (Test-Path $defaultPath) { Invoke-SkillAudit -FilePath $defaultPath }
    else { Write-Host "Usage: .\audit.ps1 -Path <SKILL.md>" -ForegroundColor Yellow; Write-Host "      .\audit.ps1 -Project          # Audit all" -ForegroundColor Yellow; Write-Host "      .\audit.ps1 -Project -Verbose # Detailed" -ForegroundColor Yellow }
}
