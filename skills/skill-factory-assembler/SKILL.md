---
name: skill-factory-assembler
version: v2.3.0
author: skill-factory
description: Use when merging, splitting, combining, integrating, or restructuring multiple AI Agent skills, performing batch validation after assembly operations, or coordinating with Stocktake health scans. Triggers on "merge skills", "split skills", "combine skills", "integrate skills", "restructure skills", "skill assembly", "batch validate", "post-merge check", or "stocktake coordination"
tags: [skill-merging, skill-splitting, skill-restructuring, integration, batch-validation, stocktake-coordination, ci-cd-pipeline, harness-integration, skill-factory]
dependency:
  parent: skill-factory
  structure: "Type 3 (轻+厚): SKILL.md + references/"
  pattern: "Assembler Coordinator + Batch Validation"
meta:
  complexity: advanced
  standalone: true
  can_invoke_directly: true
  tdd: deferred
  tdd_waiver_reason: "协调器型技能，核心TDD流程在 creator/references/tdd-guide.md 中。批量验证通过 processor Stocktake 模式协同完成"
  tdd_waiver_date: "2026-05-30"
  batch_validation: true
  stocktake_integration: true
  harness_integration: "v1.0"
---
# 🔗 Skill Factory Assembler — 技能整合器 v2.3

> **定位**: 多技能合并与拆分的架构重组器 + 批量验证协调器
> **架构**: 自含型子技能 + references/ 详细参考
> **新增能力**: 合并/拆分后自动触发批量验证 + Stocktake 健康扫描协同

---

## 🎯 职责范围

| ✅ 负责 | ❌ 不负责 |
|---------|----------|
| 合并多个技能为一个 | 从零创建 → `/creator` |
| 拆分复杂技能为多个 | 优化单个 → `/processor` |
| 技能架构重组与调整 | 发布/版本管理 → `/publisher` |
| ⭐ **合并/拆分后批量验证** | 单技能审计 → `/processor` |
| ⭐ **Stocktake 健康扫描协同** | 创建测试场景 → `/creator` |

---

## 🧪 批量验证 (Harness 集成)

> **来源**: [harness-integration-guide.md](../skill-factory-processor/references/harness-integration-guide.md)
> **目的**: 确保合并/拆分操作后，所有相关技能仍符合质量标准

### 为什么需要批量验证

```
合并/拆分操作风险:
├── 结构破坏: 层级深度超标、链接断裂
├── 内容丢失: 章节遗漏、示例缺失
├── TDD 失效: 压力测试记录不适用新结构
└── 触发冲突: description 重叠导致误触发

→ 解决方案: 操作后立即运行批量审计 + Stocktake 扫描
```

### 批量验证流程

```
┌─────────────────────────────────────────────────────────────┐
│              合并/拆分后批量验证流程                          │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ① 完成合并/拆分操作                                        │
│       ↓                                                     │
│  ② 运行全量审计 (audit.ps1 -Project)                       │
│     ├─ 检查所有 SKILL.md 的 Front Matter                    │
│     ├─ 验证 CSO description 格式                             │
│     ├─ 确认 TDD 豁免/记录完整性                             │
│     └─ 检测死链和层级违规                                   │
│       ↓                                                     │
│  ③ 分析审计结果                                             │
│     ├─ 平均分 ≥ 85%? → ✅ 通过                              │
│     ├─ 个别技能 < 70%? → 🔄 需修复                          │
│     └─ 发现结构性问题? → 🔍 深度检查                        │
│       ↓                                                     │
│  ④ 触发 Stocktake 扫描 (可选)                               │
│     ├─ 冗余检测: 新技能是否与现有技能重叠                   │
│     ├─ 孤岛检测: 被拆分的子技能是否有引用                    │
│     └─ 过期检测: 是否需要更新依赖                            │
│       ↓                                                     │
│  ⑤ 生成验证报告                                             │
│     ├─ HTML 报告 (audit-report.html)                      │
│     ├─ 问题清单 (按优先级排序)                               │
│     └─ 行动建议 (修复/退役/观察)                             │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### 自动化验证脚本

#### PowerShell: `validate-assembly.ps1`

```powershell
<#
.SYNOPSIS
    合并/拆分后批量验证脚本
.DESCRIPTION
    自动运行全量审计并生成验证报告，确保操作后质量合规
.PARAMETER OperationType
    操作类型: merge (合并) 或 split (拆分)
.PARAMETER AffectedSkills
    受影响的技能列表 (数组)
#>

param(
    [ValidateSet("merge", "split")]
    [string]$OperationType = "merge",
    
    [string[]]$AffectedSkills = @()
)

$ErrorActionPreference = "Stop"

Write-Host "🔗 Assembler Batch Validation" -ForegroundColor Cyan
Write-Host "Operation: $OperationType" -ForegroundColor White
Write-Host "Affected Skills: $($AffectedSkills.Count)" -ForegroundColor White

# Step 1: 运行全量审计
Write-Host "`n📊 Step 1: Running full project audit..." -ForegroundColor Yellow
$auditOutput = ./skills/skill-factory-processor/scripts/audit.ps1 -Project -Verbose

# Step 2: 提取关键指标
Write-Host "`n📈 Step 2: Analyzing audit results..." -ForegroundColor Yellow
$avgMatch = $auditOutput | Select-String "Project Average: (\d+)%"
if ($avgMatch) {
    $projectAvg = [int]$avgMatch.Matches.Groups[1].Value
    Write-Host "   Project Average: $projectAvg%" -ForegroundColor $(if ($projectAvg -ge 85) { "Green" } else { "Red" })
}

# Step 3: 检查受影响技能
if ($AffectedSkills.Count -gt 0) {
    Write-Host "`n🎯 Step 3: Validating affected skills..." -ForegroundColor Yellow
    
    foreach ($skill in $AffectedSkills) {
        $skillPath = "./skills/$skill/SKILL.md"
        if (Test-Path $skillPath) {
            Write-Host "   Checking: $skill ..." -ForegroundColor DarkGray
            $result = ./skills/skill-factory-processor/scripts/audit.ps1 -Path $skillPath
        } else {
            Write-Host "   ❌ Not found: $skill" -ForegroundColor Red
        }
    }
}

# Step 4: 生成 HTML 报告
Write-Host "`n📄 Step 4: Generating validation report..." -ForegroundColor Yellow
./skills/skill-factory-processor/scripts/audit.ps1 -Project -Html

# Step 5: 输出总结
Write-Host "`n" + ("=" * 55) -ForegroundColor Cyan
Write-Host "  Validation Complete" -ForegroundColor Cyan
Write-Host ("=" * 55) -ForegroundColor Cyan

if ($projectAvg -ge 85) {
    Write-Host "  ✅ PASSED: Project quality gate OK ($projectAvg%)" -ForegroundColor Green
    exit 0
} else {
    Write-Host "  ❌ FAILED: Quality below threshold ($projectAvg% < 85%)" -ForegroundColor Red
    Write-Host "  → Review audit-report.html for details" -ForegroundColor Yellow
    exit 1
}
```

### Stocktake 协同模式

> **协同对象**: processor 的 **Stocktake 模式** (健康扫描)

#### 触发条件

| 场景 | 触发 Stocktake | 说明 |
|------|---------------|------|
| **大规模合并** (≥ 3 技能) | ✅ 必须 | 高风险操作需全面扫描 |
| **核心技能拆分** | ✅ 必须 | 可能影响整个项目架构 |
| **小规模调整** (1-2 技能) | 可选 | 仅运行审计即可 |
| **定期维护** | 推荐 | 月度 Stocktake + 即时验证 |

#### 协同工作流

```markdown
## Assembler × Processor Stocktake 协同

### 1. Assembler 完成操作
- 输出: 操作报告（变更摘要 + 受影响技能列表）

### 2. 触发 Processor Stocktake
- 命令: `/processor` → 选择 "健康扫描模式"
- 输入: 受影响技能列表
- 扫描维度:
  - ✅ 冗余检测: 新合并的技能是否与现有重叠
  - ✅ 孤岛检测: 拆分后的子技能是否被引用
  - ✅ 退化检测: 操作后质量分数趋势

### 3. 分析 Stocktake 结果
- 状态矩阵: 🟢 正常 / 🟡 警告 / 🔴 危险
- 问题清单: 按优先级排列
- 行动建议: 
  - 🔄 修复 (processor 加工)
  - 📦 再拆分 (assembler 回滚)
  - 🚮 退役 (publisher 处理)
  - 👁️ 观察 (加入监控列表)

### 4. 验证完成
- 输出: 最终验证报告 (HTML + Markdown)
- 存档: reports/{timestamp}-assembly-validation.md
```

### CI/CD 流水线集成

#### GitHub Actions: `.github/workflows/assembly-validation.yml`

```yaml
name: Assembly Validation

on:
  push:
    branches: [main]
    paths:
      - 'skills/**/SKILL.md'
      - 'skills/**/references/**'

jobs:
  validate-assembly:
    runs-on: ubuntu-latest
    name: Post-Assembly Validation
    
    steps:
      - name: Checkout
        uses: actions/checkout@v4
      
      - name: Setup PowerShell
        uses: powershell/actions/setup-powershell@v1
      
      - name: Detect Changes
        id: changes
        run: |
          # 检测变更的技能文件
          CHANGED_FILES=$(git diff --name-only HEAD~1 HEAD | grep 'SKILL.md' || true)
          echo "changed_files=$CHANGED_FILES" >> $env:GITHUB_OUTPUT
          echo "Changed files:"
          echo "$CHANGED_FILES"
      
      - name: Run Audit
        shell: pwsh
        run: |
          ./skills/skill-factory-processor/scripts/audit.ps1 -Project -Verbose
      
      - name: Check Quality Gate
        shell: pwsh
        run: |
          $output = ./skills/skill-factory-processor/scripts/audit.ps1 -Project
          $avgMatch = $output | Select-String "Project Average: (\d+)%"
          
          if ($avgMatch) {
            $score = [int]$avgMatch.Matches.Groups[1].Value
            if ($score -lt 85) {
              Write-Host "❌ Quality gate failed: $score%"
              exit 1
            }
          }
      
      - name: Upload Report
        if: always()
        uses: actions/upload-artifact@v4
        with:
          name: assembly-validation-${{ github.sha }}
          path: audit-report.html
```

---

## 🔄 双向操作

```
"合并/整合/组合" → 🔗 Merge Mode (合并)
"拆分/分离/解耦" → ✂️ Split Mode (拆分)

合并模式: 分析源技能 → 选模式 → 执行合并 → 验证
拆分模式: 分析目标技能 → 选维度 → 执行拆分 → 验证
```

---

## 模式一：合并（Merge）

### 三种合并模式速查

| 模式 | 适用场景 | 特征 | 示例 |
|------|---------|------|------|
| **序列 (Sequential)** | 有先后依赖 | A→B→C 顺序执行 | 验证→测试→部署 |
| **并行 (Parallel)** | 功能独立 | A/B/C 并列子技能 | 格式化+Lint+类型检查 |
| **嵌套 (Nested)** | 子流程嵌入 | B 嵌入 A 作为步骤 | 部署中的健康检查 |

### 模式选择

```
有先后顺序? → 序列合并
功能独立无依赖? → 并行合并
一个是另一个的子流程? → 嵌套合并
复杂混合? → 组合模式

> 🎯 **EvoSkill 多候选评估**: 当存在多种可行合并策略时（如顺序 vs 并行 vs 核心提取），启用 EvoSkill 模式生成 2-3 个候选方案，通过 6 维评分卡自动选优。详见 [references/evoskill-eval.md](references/evoskill-eval.md)

> 📖 **详细操作步骤 + 示例**: [references/merge-patterns.md](references/merge-patterns.md)

---

## 模式二：拆分（Split）

### 三种拆分维度速查

| 维度 | 适用场景 | 特征 | 示例 |
|------|---------|------|------|
| **功能 (Function)** | 功能模块清晰可辨 | 每个子技能一个功能域 | CRUD→4个子技能 |
| **场景 (Scene)** | 场景差异大 | 按使用环境划分 | 部署→dev/staging/prod |
| **角色 (Role)** | 角色关注点不同 | 按目标用户划分 | CI/CD→dev/ops/admin |

### 维度选择

```
功能边界清晰? → 按功能拆分
使用场景差异大? → 按场景拆分
用户角色不同? → 按角色拆分
多种因素混合? → 主维度 + 辅助维度

> 🎯 **EvoSkill 多候选评估**: 当存在多种可行拆分维度时（如功能 vs 场景 vs 角色），启用 EvoSkill 模式生成 2-3 个候选方案，通过 6 维评分卡自动选优。详见 [references/evoskill-eval.md](references/evoskill-eval.md)

> 📖 **详细操作步骤 + 示例**: [references/split-patterns.md](references/split-patterns.md)

---

## 📊 合并 vs 拆分对比

| 维度 | 合并 | 拆分 |
|------|------|------|
| **触发词** | 合并/整合/组合/统一 | 拆分/分离/解耦/精简 |
| **输入** | 2-4 个源技能 | 1 个目标技能 |
| **输出** | 1 个整合技能 | 2-4 个子技能 |
| **核心挑战** | 解决冲突 | 保持完整性 |
| **耗时** | 30-50 min | 30-45 min |

---

## ⚠️ 注意事项

1. **合并不等于拼接**: 要解决冲突、重新组织、统一风格
2. **拆分不等于切割**: 保证每个子技能的独立性和完整性
3. **先评估再行动**: 不是所有技能都适合合并或拆分
4. **保持向后兼容**: 已使用的技能拆分时保留原入口
5. **渐进式重组**: 大型重构可分多步完成
6. **策略模糊时用 EvoSkill**: 当多种合并/拆分策略都可行且难以直观判断时，使用 EvoSkill 多候选评估模式自动选优

---

## 📂 本子技能结构

```
skills/skill-factory-assembler/
├── SKILL.md                      ← 本文件（协调器 ~220行）
└── references/
    ├── merge-patterns.md         ← 序列/并行/嵌套合并详解
    ├── split-patterns.md         ← 功能/场景/角色拆分详解
    └── evoskill-eval.md          ← 多候选评估方法论（Creator→Evaluator→Refiner）
```

## 🔗 相关资源

| 资源 | 路径 | 用途 |
|------|------|------|
| 设计原则 | [../references/design-principles.md](../references/design-principles.md) | 整合模式选择 |
| 写作规则 | [../references/writing-rules.md](../references/writing-rules.md) | R1-R14 完整规则 |
| 最佳实践 | [../references/best-practices.md](../references/best-practices.md) | 项目知识枢纽 |
| **EvoSkill 评估** | [references/evoskill-eval.md](references/evoskill-eval.md) | **多候选方案生成与6维评分选优** |

---

## 版本历史

| 版本 | 日期 | 变更 |
|------|------|------|
| **v2.3.0** | 2026-05-30 | **批量验证全面集成**: 新增完整的批量验证流程（5步标准化流程）；新增自动化验证脚本 (validate-assembly.ps1)；实现 Stocktake 协同模式（触发条件+协同工作流）；提供 CI/CD 流水线配置 (assembly-validation.yml)；增强职责范围（批量验证+Stocktake协同） |
| **v2.2.0** | 2026-05-30 | **质量提升 + Test Harness 对接**: 优化 TDD 豁免说明格式；增强与 processor Stocktake 模式的协同；支持 CI/CD 集成场景下的批量合并/拆分验证 |
| **v2.1.0** | 2026-05-27 | **新增**: EvoSkill 三 Agent 评估模式（Creator→Evaluator→Refiner）；新增 references/evoskill-eval.md；合并/拆分流程支持多候选方案生成与6维评分选优 |
| **v2.0.1** | 2026-05-27 | **优化**: 拆分 references/(2文件)；修复死链(subskill-design已删)；添加 TDD 豁免；行数 549→~200 |
| **v2.0.0** | 2026-05-27 | 初始版本：单文件双向协调器；3种合并模式 × 3种拆分维度 |
