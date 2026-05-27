<#
.SYNOPSIS
    Skill Factory CSO Description Optimizer v1.0
.DESCRIPTION
    Semi-automated CSO (Claude Search Optimization) description optimizer.
    Based on official skill-creator improve_description.py methodology.
    Guides through eval query design, manual assessment, iterative improvement,
    and selects the best description version by validation set score.
.PARAMETER Path
    SKILL.md file path to optimize (default: ./SKILL.md)
.PARAMETER Init
    Initialize eval query template for a skill (generates starter template)
.PARAMETER Evaluate
    Run evaluation mode: assess current description against eval queries
.PARAMETER Iterations
    Maximum optimization iterations (default: 5)
#>

param(
    [string]$Path = "",
    [switch]$Init,
    [switch]$Evaluate,
    [int]$Iterations = 5
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

function Get-SkillDescription {
    param([string]$FilePath)
    $content = Get-Content $FilePath -Encoding UTF8
    $descLine = $content | Where-Object { $_ -match '^description:\s*(.+)$' } | Select-Object -First 1
    if (-not $descLine) { throw "No description field found in $FilePath" }
    return ($descLine -replace '^description:\s*', '').Trim()
}

function Get-SkillName {
    param([string]$FilePath)
    $content = Get-Content $FilePath -Encoding UTF8
    $nameLine = $content | Where-Object { $_ -match '^name:\s*(.+)$' } | Select-Object -First 1
    if (-not $nameLine) { return "unknown-skill" }
    return ($nameLine -replace '^name:\s*', '').Trim()
}

function Write-Box {
    param([string]$Title, [string]$Content, [string]$Color = "Cyan")
    $lines = $Content -split "`n"
    $maxLen = ($lines | ForEach-Object { $_.Length } | Measure-Object -Maximum).Maximum
    $boxWidth = [math]::Max($maxLen, $Title.Length) + 4
    Write-Host ("=" * $boxWidth) -ForegroundColor $Color
    Write-Host ("  {0}" -f $Title) -ForegroundColor $Color
    Write-Host ("-" * $boxWidth) -ForegroundColor $Color
    foreach ($line in $lines) { Write-Host ("  {0}" -f $line) }
    Write-Host ("=" * $boxWidth) -ForegroundColor $Color
}

function New-EvalTemplate {
    param([string]$SkillName, [string]$Description)

    $skillDir = Split-Path (Resolve-Path $Path)
    $evalDir = Join-Path $skillDir "evals"
    if (-not (Test-Path $evalDir)) { New-Item -ItemType Directory -Path $evalDir -Force | Out-Null }

    $template = @"
{
  "skill_name": "$SkillName",
  "description_summary": "$($Description.Substring(0, [math]::Min(100, $Description.Length)))...",
  "created_date": "$(Get-Date -Format 'yyyy-MM-dd')",
  "queries": {
    "should_trigger": [
      {
        "id": "st-01",
        "prompt": "[EDIT] Standard formal request using skill name",
        "dimension": "措辞变化",
        "variant": "正式",
        "expected_trigger": true,
        "notes": "Most standard trigger - MUST pass"
      },
      {
        "id": "st-02",
        "prompt": "[EDIT] Casual/informal wording",
        "dimension": "措辞变化",
        "variant": "随意",
        "expected_trigger": true
      },
      {
        "id": "st-03",
        "prompt": "[EDIT] Indirect description without naming the skill",
        "dimension": "明确度变化",
        "variant": "间接描述",
        "expected_trigger": true
      },
      {
        "id": "st-04",
        "prompt": "[EDIT] Short prompt with minimal context",
        "dimension": "细节程度",
        "variant": "简短",
        "expected_trigger": true
      },
      {
        "id": "st-05",
        "prompt": "[EDIT] Multi-step embedded request mentioning the skill's domain",
        "dimension": "复杂度变化",
        "variant": "多步骤嵌入",
        "expected_trigger": true
      },
      {
        "id": "st-06",
        "prompt": "[EDIT] Typo or abbreviation variant",
        "dimension": "措辞变化",
        "variant": "错别字/缩写",
        "expected_trigger": true
      },
      {
        "id": "st-07",
        "prompt": "[EDIT] Request with heavy context (pasted requirements doc)",
        "dimension": "细节程度",
        "variant": "重 context",
        "expected_trigger": true
      },
      {
        "id": "st-08",
        "prompt": "[EDIT] Chinese/English mixed language variant",
        "dimension": "措辞变化",
        "variant": "中英混杂",
        "expected_trigger": true
      },
      {
        "id": "st-09",
        "prompt": "[EDIT] Domain-specific jargon variant",
        "dimension": "措辞变化",
        "variant": "行话",
        "expected_trigger": true
      },
      {
        "id": "st-10",
        "prompt": "[EDIT] Edge case: ambiguous but related request",
        "dimension": "明确度变化",
        "variant": "模糊相关",
        "expected_trigger": true
      }
    ],
    "should_not_trigger": [
      {
        "id": "snt-01",
        "prompt": "[EDIT] Same domain but different operation (should trigger another skill)",
        "dimension": "近误: 同域不同操作",
        "variant": "操作差异",
        "expected_trigger": false,
        "target_skill": "[EDIT: other-skill-name]",
        "reason": "Shares keywords but different action"
      },
      {
        "id": "snt-02",
        "prompt": "[EDIT] Same keyword different meaning",
        "dimension": "近误: 同词不同义",
        "variant": "语义偏差",
        "expected_trigger": false
      },
      {
        "id": "snt-03",
        "prompt": "[EDIT] Overly generic request that could match many skills",
        "dimension": "近误: 泛化请求",
        "variant": "宽泛需求",
        "expected_trigger": false
      },
      {
        "id": "snt-04",
        "prompt": "[EDIT] At boundary between this skill and another skill",
        "dimension": "近误: 跨技能边界",
        "variant": "模糊地带",
        "expected_trigger": false,
        "target_skill": "[EDIT: adjacent-skill-name]"
      },
      {
        "id": "snt-05",
        "prompt": "[EDIT] Related but clearly out of scope",
        "dimension": "近误: 范围外",
        "variant": "越界请求",
        "expected_trigger": false
      },
      {
        "id": "snt-06",
        "prompt": "[EDIT] Meta-request about skills in general, not this one",
        "dimension": "近误: 元请求",
        "variant": "泛技能操作",
        "expected_trigger": false
      },
      {
        "id": "snt-07",
        "prompt": "[EDIT] Uses similar verbs but for unrelated domain",
        "dimension": "近误: 动词混淆",
        "variant": "动词相同领域不同",
        "expected_trigger": false
      },
      {
        "id": "snt-08",
        "prompt": "[EDIT] Complementary tool request (not a skill)",
        "dimension": "近误: 工具混淆",
        "variant": "非技能工具",
        "expected_trigger": false
      },
      {
        "id": "snt-09",
        "prompt": "[EDIT] Question about the skill rather than using it",
        "dimension": "近误: 查询vs使用",
        "variant": "信息查询",
        "expected_trigger": false
      },
      {
        "id": "snt-10",
        "prompt": "[EDIT] Completely unrelated request (negative control)",
        "dimension": "负对照",
        "variant": "无关输入",
        "expected_trigger": false
      }
    ]
  },
  "split": {
    "train_ratio": 0.6,
    "validation_ratio": 0.4
  },
  "evaluation_history": []
}
"@

    $evalFile = Join-Path $evalDir "evals.json"
    $template | Out-File -FilePath $evalFile -Encoding UTF8
    Write-Box -Title "Eval Query Template Created" -Content @"
File: evals/evals.json
Skill: $SkillName
Description: $($Description.Substring(0, [math]::Min(80, $Description.Length)))...

Next steps:
1. Open evals/evals.json
2. Replace all [EDIT] placeholders with actual queries
3. Set target_skill for near-miss entries
4. Run: .\optimize-description.ps1 -Path <SKILL.md> -Evaluate
"@ -Color "Green"
}

function Invoke-CSOEvaluation {
    param([string]$FilePath)

    $skillName = Get-SkillName -FilePath $FilePath
    $description = Get-SkillDescription -FilePath $FilePath
    $skillDir = Split-Path (Resolve-Path $FilePath)
    $evalFile = Join-Path $skillDir "evals\evals.json"

    if (-not (Test-Path $evalFile)) {
        Write-Box -Title "No Eval File Found" -Content @"
evals/evals.json not found for this skill.

To create one:
  .\optimize-description.ps1 -Path "$FilePath" -Init

This will generate a template with 20 query slots (10 positive + 10 negative).
"@ -Color "Yellow"
        return
    }

    $evalData = Get-Content $evalFile -Raw | ConvertFrom-Json

    Write-Box -Title "CSO Evaluation: $skillName" -Content @"
Current Description (${description.Length} chars):
  $description

Eval Queries: $($evalData.queries.should_trigger.Count) should-trigger
               + $($evalData.queries.should_not_trigger.Count) should-not-trigger
"@ -Color "Cyan"

    Write-Host "`n  MANUAL EVALUATION PROTOCOL" -ForegroundColor White
    Write-Host ("  " + "-" * 40) -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "  For each query below, simulate:" -ForegroundColor White
    Write-Host "    1. You are an Agent seeing this user input" -ForegroundColor DarkGray
    Write-Host "    2. Scan descriptions of all loaded skills" -ForegroundColor DarkGray
    Write-Host "    3. Would THIS skill's description match? (Y/N)" -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "  Record results in evals/eval-results.json after assessment" -ForegroundColor Yellow
    Write-Host ""

    $results = @()

    Write-Host "`n  === SHOULD-TRIGGER QUERIES ($( $evalData.queries.should_trigger.Count ) items) ===" -ForegroundColor Green
    foreach ($q in $evalData.queries.should_trigger) {
        Write-Host "`n  [$($q.id)] ($($q.dimension) / $($q.variant))" -ForegroundColor White
        Write-Host "  Prompt: $($q.prompt)" -ForegroundColor DarkGray
        Write-Host "  Expected: TRIGGER" -ForegroundColor Green
        Write-Host "  Your judgment: [Y/N/?] _" -ForegroundColor Yellow
        $results += @{ id = $q.id; type = "ST"; prompt = $q.prompt; dimension = $q.dimension; expected = $true; actual = $null }
    }

    Write-Host "`n  === SHOULD-NOT-TRIGGER QUERIES ($( $evalData.queries.should_not_trigger.Count ) items) ===" -ForegroundColor Red
    foreach ($q in $evalData.queries.should_not_trigger) {
        Write-Host "`n  [$($q.id)] ($($q.dimension) / $($q.variant))" -ForegroundColor White
        Write-Host "  Prompt: $($q.prompt)" -ForegroundColor DarkGray
        $targetInfo = if ($q.target_skill) { "Target: $($q.target_skill)" } else { "" }
        Write-Host "  Expected: NO TRIGGER  $targetInfo" -ForegroundColor Red
        Write-Host "  Reason: $($q.reason)" -ForegroundColor DarkGray
        Write-Host "  Your judgment: [Y/N/?] _" -ForegroundColor Yellow
        $results += @{ id = $q.id; type = "SNT"; prompt = $q.prompt; dimension = $q.dimension; expected = $false; actual = $null }
    }

    Write-Host ""
    Write-Box -Title "Evaluation Scoring Guide" -Content @"
After judging all queries, calculate:

  Trigger Rate     = ST_Yes / ST_Total          Target: > 0.80
  False Pos Rate   = SNT_Yes / SNT_Total        Target: < 0.20
  Composite Score  = TR * 0.6 + (1-FPR) * 0.4   Target: > 0.85

Diagnosis:
  TR < 0.7  -> Description too NARROW: add synonyms, expand trigger scenarios
  FPR > 0.3  -> Description too WIDE: narrow scope, add exclusions
  Specific dimension fails -> That expression pattern not covered
"@ -Color "DarkYellow"
}

function Invoke-CSOOptimize {
    param([string]$FilePath, [int]$MaxIterations)

    $skillName = Get-SkillName -FilePath $FilePath
    $description = Get-SkillDescription -FilePath $FilePath
    $skillDir = Split-Path (Resolve-Path $FilePath)
    $evalFile = Join-Path $skillDir "evals\evals.json"

    Write-Box -Title "CSO Optimizer: $skillName" -Content @"
Mode: Interactive Iterative Optimization
Max Iterations: $MaxIterations
Current Description Length: $($description.Length) chars

Based on: Official skill-creator improve_description.py methodology
"@ -Color "Cyan"

    $currentDesc = $description
    $bestDesc = $description
    $bestScore = 0

    for ($i = 1; $i -le $MaxIterations; $i++) {
        Write-Host ""
        Write-Host ("=" * 55) -ForegroundColor Cyan
        Write-Host ("  ITERATION {0} of {1}" -f $i, $MaxIterations) -ForegroundColor Cyan
        Write-Host ("=" * 55) -ForegroundColor Cyan

        Write-Host "`n  Current Description ($($currentDesc.Length) chars):" -ForegroundColor White
        Write-Host ("  `"{0}`"" -f $currentDesc) -ForegroundColor DarkGray

        if ($currentDesc.Length -gt 1024) {
            Write-Host "  ! WARNING: Exceeds 1024 char limit! Must shorten." -ForegroundColor Red
        }

        Write-Host "`n  --- Diagnosis Questions ---" -ForegroundColor Yellow

        $issues = @()
        Write-Host "`n  Q1: Should-trigger queries that would NOT match?" -ForegroundColor White
        Write-Host "     List query IDs (comma-separated), or NONE: " -NoNewline -ForegroundColor DarkGray
        $stFailures = Read-Host
        if ($stFailures -and $stFailures -ne "NONE") { $issues += "ST_FAIL:$stFailures" }

        Write-Host "`n  Q2: Should-not-trigger queries that WOULD falsely match?" -ForegroundColor White
        Write-Host "     List query IDs (comma-separated), or NONE: " -NoNewline -ForegroundColor DarkGray
        $sntFailures = Read-Host
        if ($sntFailures -and $sntFailures -ne "NONE") { $issues += "SNT_FAIL:$sntFailures" }

        Write-Host "`n  Q3: Estimated Trigger Rate (0.0 - 1.0)? " -NoNewline -ForegroundColor DarkGray
        $trInput = Read-Host
        $triggerRate = 0.5
        if ($trInput -match '^[\d.]+$') { $triggerRate = [double]$trInput }

        Write-Host "`n  Q4: Estimated False Positive Rate (0.0 - 1.0)? " -NoNewline -ForegroundColor DarkGray
        $fprInput = Read-Host
        $falsePosRate = 0.5
        if ($fprInput -match '^[\d.]+$') { $falsePosRate = [double]$fprInput }

        $composite = [math]::Round(($triggerRate * 0.6) + ((1 - $falsePosRate) * 0.4), 3)
        $grade = switch ($true) { ($composite -ge 0.85) { "A" }; ($composite -ge 0.70) { "B" }; ($composite -ge 0.50) { "C" }; default { "D" } }
        $color = switch ($grade) { "A" { "Green" }; "B" { "DarkGreen" }; "C" { "Yellow" }; default { "Red" } }

        Write-Host "`n  --- Iteration $i Score ---" -ForegroundColor Yellow
        Write-Host ("  Trigger Rate:    {0:P0}" -f $triggerRate) -ForegroundColor $(if ($triggerRate -ge 0.8) { "Green" } else { "Red" })
        Write-Host ("  False Pos Rate:   {0:P0}" -f $falsePosRate) -ForegroundColor $(if ($falsePosRate -le 0.2) { "Green" } else { "Red" })
        Write-Host ("  Composite Score:  {0} ({1})" -f $composite, $grade) -ForegroundColor $color

        if ($composite -gt $bestScore) {
            $bestScore = $composite
            $bestDesc = $currentDesc
            Write-Host "  * NEW BEST SCORE *" -ForegroundColor Green
        }

        if ($composite -ge 0.85 -or $issues.Count -eq 0) {
            Write-Host "`n  Target score achieved or no issues. Stopping early." -ForegroundColor Green
            break
        }

        if ($i -lt $MaxIterations) {
            Write-Host "`n  --- Improvement Suggestions ---" -ForegroundColor Yellow
            if ($triggerRate -lt 0.7) {
                Write-Host "  [NARROW] Description may be too narrow. Suggestions:" -ForegroundColor Red
                Write-Host "    - Add synonym variations for key terms" -ForegroundColor DarkGray
                Write-Host "    - Expand trigger scenario list" -ForegroundColor DarkGray
                Write-Host "    - Include common abbreviations/typos" -ForegroundColor DarkGray
            }
            if ($falsePosRate -gt 0.3) {
                Write-Host "  [WIDE] Description may be too broad. Suggestions:" -ForegroundColor Red
                Write-Host "    - Add exclusion phrases ('but not', 'except')" -ForegroundColor DarkGray
                Write-Host "    - Use more specific verb+noun combinations" -ForegroundColor DarkGray
                Write-Host "    - Remove overly generic trigger words" -ForegroundColor DarkGray
            }
            foreach ($issue in $issues) {
                Write-Host "  [ISSUE] $issue" -ForegroundColor DarkYellow
            }

            Write-Host "`n  Enter revised description (or PRESS ENTER to keep current):" -NoNewline -ForegroundColor White
            Write-Host ""
            $revised = Read-Host "  new_desc"
            if ($revised -and $revised.Trim().Length -gt 0) {
                if ($revised.Trim().Length -le 1024) {
                    $currentDesc = $revised.Trim()
                    Write-Host "  Updated: $($currentDesc.Length) chars" -ForegroundColor DarkGray
                } else {
                    Write-Host "  ! Rejected: $($revised.Trim().Length) chars exceeds 1024 limit" -ForegroundColor Red
                }
            } else {
                Write-Host "  Keeping current description." -ForegroundColor DarkGray
            }
        }
    }

    Write-Host ""
    Write-Box -Title "Optimization Complete" -Content @"
Best Composite Score: $bestScore
Best Description ($($bestDesc.Length) chars):
  "$bestDesc"

To apply to SKILL.md:
  1. Open $FilePath
  2. Replace description: line with:
     description: $bestDesc
  3. Re-run audit.ps1 to verify quality score
"@ -Color $(if ($bestScore -ge 0.85) { "Green" } elseif ($bestScore -ge 0.70) { "Yellow" } else { "Red" })

    $historyEntry = @{
        date = (Get-Date -Format "yyyy-MM-dd HH:mm:ss")
        iterations_used = $i
        best_score = $bestScore
        best_description = $bestDesc
        original_description = $description
    }

    $historyFile = Join-Path $skillDir "evals\optimization-history.json"
    $historyDir = Split-Path $historyFile
    if (-not (Test-Path $historyDir)) { New-Item -ItemType Directory -Path $historyDir -Force | Out-Null }
    $history = @()
    if (Test-Path $historyFile) { $history = Get-Content $historyFile -Raw | ConvertFrom-Json }
    $history += $historyEntry
    $history | ConvertTo-Json -Depth 5 | Out-File -FilePath $historyFile -Encoding UTF8
}

if ($Init) {
    if (-not $Path) { Write-Host "Error: -Path required with -Init" -ForegroundColor Red; exit 1 }
    $resolved = Resolve-Path $Path -ErrorAction SilentlyContinue
    if (-not $resolved) { Write-Host "Error: File not found: $Path" -ForegroundColor Red; exit 1 }
    $name = Get-SkillName -FilePath $resolved
    $desc = Get-SkillDescription -FilePath $resolved
    New-EvalTemplate -SkillName $name -Description $desc
}
elseif ($Evaluate) {
    if (-not $Path) { Write-Host "Error: -Path required with -Evaluate" -ForegroundColor Red; exit 1 }
    $resolved = Resolve-Path $Path -ErrorAction SilentlyContinue
    if (-not $resolved) { Write-Host "Error: File not found: $Path" -ForegroundColor Red; exit 1 }
    Invoke-CSOEvaluation -FilePath $resolved
}
else {
    if (-not $Path) {
        $defaultPath = Join-Path $PWD "SKILL.md"
        if (Test-Path $defaultPath) { $Path = $defaultPath }
        else {
            Write-Host "Skill Factory CSO Description Optimizer v1.0" -ForegroundColor Cyan
            Write-Host ""
            Write-Host "Usage:" -ForegroundColor White
            Write-Host "  .\optimize-description.ps1 -Path <SKILL.md> -Init       Generate eval template" -ForegroundColor DarkGray
            Write-Host "  .\optimize-description.ps1 -Path <SKILL.md> -Evaluate   Run manual evaluation" -ForegroundColor DarkGray
            Write-Host "  .\optimize-description.ps1 -Path <SKILL.md>             Interactive optimize" -ForegroundColor DarkGray
            Write-Host "  .\optimize-description.ps1 -Path <SKILL.md> -Iterations 3  Max 3 rounds" -ForegroundColor DarkGray
            exit 0
        }
    }
    $resolved = Resolve-Path $Path -ErrorAction SilentlyContinue
    if (-not $resolved) { Write-Host "Error: File not found: $Path" -ForegroundColor Red; exit 1 }
    Invoke-CSOOptimize -FilePath $resolved -MaxIterations $Iterations
}
