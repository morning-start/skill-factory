# Test Harness & CI/CD 集成指南

> **来源**: skill-factory processor → 加工模式 → Harness 集成
> **版本**: v1.0.0
> **用途**: 将自动化测试框架和 CI/CD 流水线整合到技能生命周期中

---

## 🎯 核心目标

将 **Test Harness（测试框架）** 能力贯穿 skill-factory 整个业务流程，实现：

1. ✅ **自动化质量门禁** - 每次代码提交自动运行审计和测试
2. ✅ **CI/CD 流水线集成** - 技能从创建到发布的全流程自动化
3. ✅ **Harness.io 平台对接** - 利用 AI Agents 增强交付效率
4. ✅ **持续验证机制** - 确保技能在迭代过程中保持高质量

---

## 📊 Test Harness 架构概览

### 双层测试体系

```
┌─────────────────────────────────────────────────────────────┐
│                    Test Harness 双层架构                      │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  Layer 1: Smoke Testing (快速反馈)                           │
│  ├─ 触发时机: 每次 PR / commit                               │
│  ├─ 执行方式: Mock 响应 (确定性结果)                         │
│  ├─ 耗时: < 2 分钟                                          │
│  ├─ 目的: 快速发现格式错误和基本问题                          │
│  └─ 工具: audit.ps1 + 格式验证                              │
│                         ↓                                   │
│  Layer 2: SDK Evaluation (完整验证)                          │
│  ├─ 触发时机: Nightly / 发布前                               │
│  ├─ 执行方式: Real Copilot SDK (真实环境)                    │
│  ├─ 耗时: 10-30 分钟                                        │
│  ├─ 目的: 全面评估技能质量和实际效果                          │
│  └─ 工具: scenarios.yaml + acceptance-criteria.md           │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### 测试覆盖矩阵

| 维度 | Smoke Test | SDK Evaluation | 说明 |
|------|-----------|----------------|------|
| **Front Matter** | ✅ 字段存在性 | ✅ 完整性+有效性 | name/version/description/tags |
| **CSO Description** | ✅ 格式规则 | ✅ 触发率评估 | Use when + 长度 + 关键词 |
| **TDD Validation** | ⚠️ 豁免检查 | ✅ 压力场景执行 | RED/GREEN/REFACTOR 完整性 |
| **必备章节** | ✅ 存在性检查 | ✅ 内容质量评估 | 目标/步骤/示例/注意事项 |
| **层级合规** | ✅ 深度检查 | ✅ 结构合理性 | ≤3 层规则 |
| **链接有效性** | ✅ 死链检测 | ✅ 引用完整性 | 内部+外部链接 |
| **实际效果** | ❌ 不测 | ✅ 场景执行 | Agent 行为验证 |

---

## 🔧 CI/CD 流水线配置

### GitHub Actions 配置示例

#### 1. Smoke Test Workflow (`.github/workflows/skill-smoke-test.yml`)

```yaml
name: Skill Smoke Test

on:
  pull_request:
    paths:
      - '**/SKILL.md'
      - '**/references/**'
  push:
    branches: [main, develop]

jobs:
  smoke-test:
    runs-on: ubuntu-latest
    name: Run Skill Audit
    
    steps:
      - name: Checkout code
        uses: actions/checkout@v4
      
      - name: Setup PowerShell
        uses: powershell/actions/setup-powershell@v1
      
      - name: Run Audit Script
        shell: pwsh
        run: |
          ./skills/skill-factory-processor/scripts/audit.ps1 -Project -Verbose
      
      - name: Generate HTML Report
        if: always()
        shell: pwsh
        run: |
          ./skills/skill-factory-processor/scripts/audit.ps1 -Project -Html
      
      - name: Upload Report
        if: always()
        uses: actions/upload-artifact@v4
        with:
          name: skill-audit-report
          path: audit-report.html
          retention-days: 30

      - name: Quality Gate
        shell: pwsh
        run: |
          $results = @()
          Get-ChildItem -Recurse -Filter "SKILL.md" | ForEach-Object {
            $output = ./skills/skill-factory-processor/scripts/audit.ps1 -Path $_.FullName 2>&1
            $scoreLine = $output | Select-String "Total: (\d+)/(\d+)"
            if ($scoreLine) {
              $results += [PSCustomObject]@{
                Score = [int]$scoreLine.Matches.Groups[1].Value
                Max = [int]$scoreLine.Matches.Groups[2].Value
              }
            }
          }
          
          $avg = ($results | Measure-Object -Property { $_.Score / $_.Max * 100 } -Average).Average
          Write-Host "📊 Project Average: $([math]::Round($avg))%"
          
          if ($avg -lt 75) {
            Write-Host "❌ Quality gate failed: Average score below 75%"
            exit 1
          }
          else {
            Write-Host "✅ Quality gate passed"
          }
```

#### 2. Nightly SDK Evaluation (`.github/workflows/skill-evaluation.yml`)

```yaml
name: Skill SDK Evaluation

on:
  schedule:
    - cron: '0 2 * * *'  # 每天凌晨 2 点运行
  workflow_dispatch:

jobs:
  evaluate:
    runs-on: ubuntu-latest
    name: Comprehensive Skill Evaluation
    
    steps:
      - name: Checkout code
        uses: actions/checkout@v4
      
      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '20'
      
      - name: Install dependencies
        run: npm install
        
      - name: Run Test Harness
        run: npx harness --project --verbose
        env:
          ANTHROPIC_API_KEY: ${{ secrets.ANTHROPIC_API_KEY }}
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
      
      - name: Generate Evaluation Report
        if: always()
        run: npx harness --report html
      
      - name: Upload Results
        if: always()
        uses: actions/upload-artifact@v4
        with:
          name: evaluation-results-${{ github.run_id }}
          path: |
            eval-report.html
            eval-results.json
          retention-days: 90
```

---

## 🤖 Harness.io AI Agents 集成

### 核心能力映射

| skill-factory 阶段 | Harness Agent | 增强效果 |
|-------------------|---------------|---------|
| **Creator (创建)** | DevOps Agent | 自然语言生成流水线 YAML |
| **Processor (加工)** | Code Review Agent | 自动审查 SKILL.md 质量 |
| **Publisher (发布)** | CI Autofix Agent | 自动修复构建失败 |
| **Assembler (整合)** | Pipeline Optimizer Agent | 优化技能组合结构 |

### Harness Agents 使用示例

#### 1. CI Autofix Agent - 自动修复审计问题

```yaml
# harness-ci-autofix-pipeline.yaml
pipeline:
  stages:
    - name: skill-audit-and-fix
      steps:
        - name: run_audit
          run:
            container:
              image: harness/coding-agent
            with:
              prompt: |
                运行 skill-factory 审计脚本:
                ./skills/skill-factory-processor/scripts/audit.ps1 -Project
                
                如果发现任何评分低于 80 分的技能：
                1. 分析具体扣分项
                2. 根据 best-practices.md 自动修复
                3. 重新运行审计确认分数提升
                
                输出修复报告
                
        - name: create_pr_with_fixes
          if: audit_score < 80
          run:
            container:
              image: harness/coding-agent-pr-skill
            with:
              pr_title: "🤖 Auto-fix: Skill quality improvements"
              create_pr: true
```

#### 2. Code Review Agent - 技能质量审查

```markdown
## Harness Code Review Prompt Template

请审查以下 SKILL.md 文件的质量：

**审查维度**:
1. ✅ CSO Description 是否符合规范（Use when 开头，50-1024字符）
2. ✅ TDD 验证是否完整（压力测试记录或豁免说明）
3. ✅ 必备章节是否齐全（目标/步骤/示例/注意事项）
4. ✅ 层级是否合规（≤3 层深度）
5. ✅ 链接是否有效（无死链）
6. ✅ 内容是否有高信号密度（无冗余）

**输出格式**:
```markdown
## 审查报告

### 总分: XX/100 (Grade X)

### 必须修复 (P0)
- [ ] 问题1: 描述 + 修复建议

### 建议改进 (P1)
- [ ] 问题2: 描述 + 优化建议

### 通过项 ✅
- 项目1: 符合标准
```
```

#### 3. DevOps Agent - 流水线生成

```markdown
## Harness DevOps Agent 使用场景

### 场景 1: 为新技能创建 CI/CD 流水线

**Prompt**:
```
为 skill-factory 项目创建一个 GitHub Actions 工作流：
1. 当 SKILL.md 文件变更时触发
2. 运行 audit.ps1 审计脚本
3. 生成分数低于 75% 时阻止合并
4. 生成 HTML 报告并上传为 artifact
5. 添加 PR 评论显示审计结果
```

### 场景 2: 自动化发布流程

**Prompt**:
```
创建一个发布工作流：
1. 监控 version 字段变更
2. 自动运行全量审计（Project mode）
3. 生成 CHANGELOG
4. 创建 Git Tag
5. 发布到 GitHub Releases
6. 更新文档站点
```
```

---

## 📋 测试场景设计指南

### Scenarios YAML 格式

```yaml
# tests/scenarios/{skill-name}/scenarios.yaml
version: 1.0
skill: skill-factory-creator

scenarios:
  # Should-trigger scenarios (正例)
  - id: st-01
    type: should-trigger
    dimension: 措辞变化
    variant: 正式
    prompt: "请帮我创建一个新的 AI Agent Skill"
    expected_trigger: true
    notes: "最标准的触发方式"
    
  - id: st-02
    type: should-trigger
    dimension: 措辞变化
    variant: 随意
    prompt: "建个skill试试"
    expected_trigger: true
    notes: "随意措辞应也能触发"

  # Should-not-trigger scenarios (负例)
  - id: snt-01
    type: should-not-trigger
    dimension: 近误: 同域不同操作
    variant: 加工请求
    prompt: "帮我优化一下现有的 skill-factory-processor"
    expected_trigger: false
    target_skill: processor
    notes: "包含 'skill' 但动作是 '优化'"
    
  - id: snt-02
    type: should-not-trigger
    dimension: 近误: 同词不同义
    variant: 脚本请求
    prompt: "写个 Python 脚本来自动化测试"
    expected_trigger: false
    target_skill: null
    notes: "'skill' 在此指技术技能非 Agent Skill"
```

### Acceptance Criteria 格式

```markdown
# tests/scenarios/{skill-name}/acceptance-criteria.md

## 正确模式 (✅ Pass)

### CSO Description 格式
✅ "Use when creating, editing, or optimizing skills.
   Triggers on 'create skill', 'new skill', or 'optimize skill'."

### TDD 验证记录
✅ 包含压力场景描述、基线测试记录、失败模式总结

### 必备章节
✅ 包含明确的：任务目标 / 操作步骤 / 示例 / 注意事项

---

## 错误模式 (❌ Fail)

### CSO Description 错误
❌ "Skill Factory Creator - helps you create new AI Agent Skills
   following TDD methodology and best practices..."
   （这是功能描述，不是触发条件）

### 缺少 TDD 验证
❌ 未提及压力测试或提供豁免说明

### 层级违规
❌ 目录深度超过 3 层
```

---

## 🔄 全流程集成方案

### 技能生命周期与 Test Harness 对接

```
┌─────────────────────────────────────────────────────────────┐
│              技能生命周期 × Test Harness                     │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ① Creator (创建阶段)                                       │
│     ├─ TDD RED: 设计压力场景                                 │
│     ├─ 编写 scenarios.yaml                                  │
│     ├─ 定义 acceptance-criteria.md                          │
│     └─ 本地运行 smoke test 验证格式                          │
│                         ↓                                   │
│  ② Processor (加工阶段)                                     │
│     ├─ 运行 audit.ps1 -Path <skill> -Verbose                │
│     ├─ 分析 7 个维度得分                                     │
│     ├─ 应用加工策略 (A/B/C/D)                                │
│     └─ 重新审计验证改进效果                                  │
│                         ↓                                   │
│  ③ Publisher (发布阶段)                                      │
│     ├─ 运行 audit.ps1 -Project (全量审计)                   │
│     ├─ 确认平均分 ≥ 85%                                     │
│     ├─ 触发 nightly SDK evaluation                          │
│     └─ 生成发布报告 + CHANGELOG                             │
│                         ↓                                   │
│  ④ Assembler (整合阶段)                                     │
│     ├─ Stocktake 扫描检测冗余/孤岛/退化                      │
│     ├─ 合并/拆分后重新审计                                   │
│     └─ 更新 scenarios 和 acceptance criteria                 │
│                         ↓                                   │
│  ⑤ 持续监控 (CI/CD)                                         │
│     ├─ 每次 PR: Smoke test (< 2min)                        │
│     ├─ 每天: Nightly SDK evaluation                        │
│     ├─ 每周: Stocktake health scan                          │
│     └─ 每月: 全面回顾 + 优化计划                             │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### 质量门禁配置

| 门禁名称 | 触发条件 | 通过标准 | 失败动作 |
|---------|---------|---------|---------|
| **Format Gate** | 每个 PR | Front Matter 完整 + CSO 格式正确 | 阻止合并 |
| **Quality Gate** | 每个 PR | 单技能 ≥ 70 分 | PR 评论警告 |
| **Project Gate** | 发布前 | 项目平均 ≥ 85 分 | 阻止发布 |
| **Regression Gate** | Nightly | 分数不下降 >5% | 发送告警 |
| **Integration Gate** | Weekly | 所有 scenario 通过 | 创建 Issue |

---

## 🚀 快速开始指南

### Step 1: 初始化 Test Harness (10 min)

```bash
# 1. 创建测试目录结构
mkdir -p tests/scenarios
mkdir -p tests/reports

# 2. 复制审计脚本到项目根目录（可选，便于调用）
cp skills/skill-factory-processor/scripts/audit.ps1 ./audit.ps1

# 3. 首次运行全量审计
pwsh -File audit.ps1 -Project -Html

# 4. 查看生成的 HTML 报告
start audit-report.html
```

### Step 2: 配置 GitHub Actions (15 min)

```bash
# 1. 创建 workflows 目录
mkdir -p .github/workflows

# 2. 添加 smoke test workflow
# (复制上面的 skill-smoke-test.yml 内容)

# 3. 添加 secrets (GitHub Settings)
#    - ANTHROPIC_API_KEY (用于 SDK evaluation)
#    - GITHUB_TOKEN (自动可用)

# 4. 测试 workflow
git add .
git commit -m "feat: add CI/CD pipeline for skill quality gates"
git push origin main
```

### Step 3: 编写第一个 Scenario (20 min)

```bash
# 1. 为你的技能创建 scenario 文件
mkdir -p tests/scenarios/your-skill-name

# 2. 编辑 scenarios.yaml
# (使用上面的模板，设计 10 正例 + 10 负例)

# 3. 编写 acceptance-criteria.md
# (定义正确的模式和错误的反模式)

# 4. 本地测试
npx harness your-skill-name --mock
```

### Step 4: 集成 Harness Agents (可选, 30 min)

```bash
# 1. 安装 Harness CLI (如需要)
# 参考: https://developer.harness.io/docs/platform/harness-ai/

# 2. 配置 Harness 连接器
# (在 Harness UI 中设置 API Key 和权限)

# 3. 尝试使用 DevOps Agent 生成流水线
# (使用上面提供的 prompt 模板)

# 4. 将生成的流水线集成到项目中
```

---

## 📈 监控与度量

### 关键指标 (KPIs)

| 指标 | 计算方式 | 目标值 | 监控频率 |
|------|---------|--------|---------|
| **项目平均分** | 所有技能得分平均值 | ≥ 85% | 每次 PR |
| **技能健康率** | ≥80 分技能占比 | ≥ 90% | Daily |
| **审计通过率** | Smoke test 通过次数 / 总次数 | ≥ 95% | 每次 PR |
| **Scenario 通过率** | SDK eval 通过场景数 / 总数 | ≥ 90% | Nightly |
| **链接有效率** | 有效链接数 / 总链接数 | 100% | Weekly |
| **TDD 覆盖率** | 有 TDD 记录的技能占比 | 100% | Monthly |

### Dashboard 配置建议

```markdown
## 推荐的可视化面板

### 1. 技能质量趋势图
- X轴: 时间 (按天/周)
- Y轴: 平均审计分数
- 图表类型: 折线图 + 趋势线

### 2. 技能健康分布饼图
- 分类: A(优秀) / B(良好) / C(合格) / D(不合格)
- 数据源: 最新审计结果

### 3. 问题类型柱状图
- X轴: 问题类型 (TDD/CSO/层级/链接等)
- Y轴: 出现频次
- 用途: 识别系统性问题

### 4. CI/CD 流水线状态
- 显示最近 10 次运行的通过/失败状态
- 点击可查看详细日志
```

---

## ⚠️ 注意事项

1. **渐进式采用**: 不要一次性实现所有功能，先从 Smoke Test 开始
2. **Mock 优先**: 初期使用 mock 模式快速迭代，稳定后再启用真实 SDK
3. **阈值合理**: 质量门禁阈值应根据团队实际情况调整，不要一开始就设过高
4. **安全考虑**: API Key 等敏感信息必须使用 GitHub Secrets 管理
5. **成本控制**: SDK evaluation 会消耗 LLM token，控制运行频率
6. **维护成本**: scenarios 和 acceptance criteria 需要随技能更新而更新

---

## 📚 相关资源

| 资源 | 链接 | 用途 |
|------|------|------|
| Microsoft agent-skills | [GitHub](https://github.com/microsoft/agent-skills) | Test Harness 参考实现 |
| Harness AI Docs | [Developer Portal](https://developer.harness.io/docs/platform/harness-ai/) | Harness Agents 文档 |
| agentskills.io Spec | [Official Specification](https://agentskills.io/specification) | 技能格式标准 |
| 本项目审计脚本 | [`../scripts/audit.ps1`](../scripts/audit.ps1) | 100 分制审计工具 |
| 加工策略指南 | [`./strategies.md`](./strategies.md) | 4 种加工策略详解 |
| 审计标准详情 | [`./audit-criteria.md`](./audit-criteria.md) | 评分细则 |

---

> 💡 **下一步**: 
> 1. 为现有技能编写 scenarios.yaml 和 acceptance-criteria.md
> 2. 配置 GitHub Actions 实现自动化质量门禁
> 3. 考虑集成 Harness AI Agents 进一步提升效率
> 4. 建立定期 review 机制确保测试用例持续更新
