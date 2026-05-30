---
name: skill-factory-processor
version: v2.5.0
author: skill-factory
description: Use when optimizing, refining, improving, auditing, validating, checking AI Agent skills for quality and compliance, performing health stocktake scans, or integrating Harness AI Agents for automated quality management. Triggers on "optimize this skill", "improve skill", "audit skill", "check compliance", "skill quality", "validate SKILL.md", "refactor skill", "review skill", "stocktake skills", "health scan", "skill inventory", "harness agents", "automated review", "CI/CD quality gate"
tags: [skill-optimization, skill-auditing, skill-refactoring, quality-check, harness-agents, automated-review, ci-cd-quality-gate, stocktake-scan, skill-factory]
dependency:
  parent: skill-factory
  structure: "Type 3 (轻+厚): SKILL.md + references/ + scripts/"
  pattern: "Processor Coordinator + Harness AI Hub"
meta:
  complexity: advanced
  standalone: true
  can_invoke_directly: true
  tdd: validation-only
  tdd_waiver_reason: "加工+审计是验证行为本身。审计脚本(scripts/audit.ps1)提供自动化100分评分作为客观验证。Harness Agents 集成通过 harness-agents-guide.md 验证"
  tdd_waiver_date: "2026-05-30"
  harness_agents_ready: true
  automation_level: "full"
---
# ⚙️ Skill Factory Processor — 技能加工器 v2.5

> **定位**: 加工优化 + 质量审计 + 健康扫描 + Harness AI 对接的四功能协调器
> **架构**: 自含型子技能（可独立通过 `/processor` 触发）
> **核心能力**: 4 种加工策略 + 100 分审计评分系统 + 技能负债检测 + Harness AI Agents
> **v2.5 变更**: 精简主文件 (<600行)，提取 Harness Agents 至 references/

---

## 🎯 职责范围

| ✅ 负责 | ❌ 不负责 |
|---------|----------|
| 优化已有技能（精简/丰富/美化/重构） | 从零创建新技能 → `/creator` |
| 审计技能合规性（100 分评分） | 发布/版本管理 → `/publisher` |
| 技能质量评估与改进建议 | 合并/拆分技能 → `/assembler` |
| 运行自动化审计脚本 | 需求分析 → `/creator` |
| ⭐ **Harness AI Agents 对接** (详见下方) | 创建测试场景 → `/creator` |

---

## 🤖 Harness AI Agents 对接

> **📖 完整指南**: [references/harness-agents-guide.md](references/harness-agents-guide.md) (~295行)
> **来源**: [harness-integration-guide.md](references/harness-integration-guide.md)

### 核心要点

**4 个 Agent 能力**:
1. 🔍 **Code Review Agent**: 7维自动审查 + PR 评论集成
2. 🔧 **CI Autofix Agent**: 审计问题自动修复 + 创建 Fix PR
3. 🚀 **DevOps Agent**: CI/CD 流水线自动生成
4. 🧠 **Knowledge Graph Agent**: 技能关系图谱 + 智能推荐

### 架构概览

```
┌─────────────────────────────────────────────────────────────┐
│           Processor × Harness Agents 架构                    │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ① Code Review Agent  → 自动审查 SKILL.md 质量             │
│                         ↓                                   │
│  ② CI Autofix Agent   → 审计问题自动修复                   │
│                         ↓                                   │
│  ③ DevOps Agent       → CI/CD 流水线自动生成               │
│                         ↓                                   │
│  ④ Knowledge Graph    → 技能关系图谱 + 智能推荐            │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

→ 📖 **完整 Prompt 模板、GitHub Actions 配置、使用场景请查看**: [harness-agents-guide.md](references/harness-agents-guide.md)

---

## 🔄 三模式工作流

```
┌─────────────────────────────────────────────────────────────────┐
│              Processor 三模式入口                                  │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  用户意图判断:                                                     │
│                                                                 │
│  "优化/改进/精简/重构" → 📝 加工模式 (Processing)                │
│  "检查/审计/评分/合规" → 🔍 审计模式 (Auditing)                  │
│  "扫描/盘点/健康检查/全局视图" → 📊 健康扫描模式 (Stocktake)      │
│                                                                 │
│  ┌─────────────────┐    ┌─────────────────┐                    │
│  │   加工模式       │    │   审计模式       │                    │
│  │                 │    │                 │                    │
│  │ ① 分析现状      │    │ ① 运行审计脚本   │                    │
│  │ ② 选择策略      │    │ ② 生成评分报告   │                    │
│  │ ③ 执行加工      │    │ ③ 给出改进建议   │                    │
│  │ ④ 验证结果      │    │ ④ 可选: 执行修复  │                    │
│  └─────────────────┘    └─────────────────┘                    │
│                                                                 │
│  ┌─────────────────────────────────────┐                        │
│  │   健康扫描模式 (Stocktake)           │                        │
│  │                                     │                        │
│  │ ① 全量审计收集基线数据               │                        │
│  │ ② 交叉分析识别问题模式               │                        │
│  │ ③ 生成健康报告（状态矩阵）            │                        │
│  │ ④ 输出行动建议（合并/退役/升级/归档） │                        │
│  └─────────────────────────────────────┘                        │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## 模式三：技能健康扫描（Stocktake）

> **背景**: [@nogataka](https://github.com/nogataka)（日本，运营 50 个技能的专家）发现的"技能负债悖论"——技能越多生产力越低。需要定期做全项目 stocktake 扫描。

### 目标

发现**技能负债**——识别项目中存在的四类问题技能：

| 负债类型 | 定义 | 风险 |
|---------|------|------|
| **冗余** | 功能重叠的技能对 | 维护成本翻倍，用户困惑 |
| **退化** | 质量随时间下降 | 技能不可靠，信任度降低 |
| **孤岛** | 存在但从未被使用 | 占用认知空间，增加复杂度 |
| **过期** | 长期未更新或依赖失效 | 兼容性问题，潜在故障 |

### 四种扫描维度

| 维度 | 检测项 | 问题表现 | 数据来源 |
|------|--------|---------|---------|
| **冗余检测** | 功能重叠的技能对 | 多个技能做相似的事 | description 语义相似度 + 触发词重叠 |
| **质量退化** | 审计分数趋势 | 分数随时间下降 | 历史审计记录对比 |
| **孤岛检测** | 零引用/零触发 | 存在但从未被使用 | 引用分析 + 触发日志 |
| **过期检测** | 版本年龄 + 依赖失效 | 长期未更新的技能 | git 历史 + 依赖检查 |

### 执行步骤

#### Step 1: 全量审计收集基线数据（5 min）

```powershell
# 运行项目级全量审计，收集所有技能的评分数据
./scripts/audit.ps1 -Project -OutputFormat JSON > baseline.json
```

**输出数据结构**：

```json
{
  "timestamp": "2026-05-27T10:00:00Z",
  "project": "skill-factory",
  "total_skills": 50,
  "skills": [
    {
      "name": "skill-name",
      "path": "./skills/skill-name/SKILL.md",
      "score": 85,
      "grade": "B",
      "last_modified": "2026-05-20",
      "lines": 245,
      "dimensions": {
        "front_matter": 10,
        "cso_description": 14,
        "tdd_validation": 12,
        "essential_sections": 9,
        "hierarchy_compliance": 10,
        "naming_convention": 5,
        "link_validity": 5
      }
    }
  ]
}
```

#### Step 2: 交叉分析识别问题模式（10 min）

基于基线数据进行多维度交叉分析：

**分析算法**：

```
输入: baseline.json（全量审计数据）
│
├── 冗余检测
│   ├── 计算 description 语义相似度矩阵
│   ├── 识别触发词重叠率 >60% 的技能对
│   └── 输出: 冗余候选列表（含重叠详情）
│
├── 退化检测
│   ├── 对比历史审计数据（如有）
│   ├── 标记分数下降 >10 分的技能
│   └── 输出: 退化风险列表
│
├── 孤岛检测
│   ├── 扫描所有 SKILL.md 的引用关系
│   ├── 标记零入度节点（无其他技能引用）
│   └── 输出: 孤岛技能列表
│
└── 过期检测
    ├── 检查 last_modified 距今 >90 天
    ├── 验证外部依赖有效性
    └── 输出: 过期技能列表
```

#### Step 3: 生成健康报告（15 min）

输出包含热力图风格状态矩阵的结构化报告：

```markdown
# 📊 技能健康扫描报告

> 项目: skill-factory | 扫描时间: 2026-05-27 | 技能总数: 50

## 总览仪表盘

| 指标 | 数值 | 状态 |
|------|------|------|
| 健康技能 (≥80分) | 35 | ✅ 70% |
| 亚健康 (60-79分) | 10 | ⚠️ 20% |
| 不健康 (<60分) | 3 | ❌ 6% |
| 待处理问题 | 12 | 🔴 需关注 |

## 状态矩阵（热力图）

| 技能名称 | 分数 | 冗余 | 退化 | 孤岛 | 过期 | 综合状态 |
|---------|------|------|------|------|------|---------|
| skill-a | 92 | 🟢 | 🟢 | 🟢 | 🟢 | ✅ 健康 |
| skill-b | 78 | 🟡 | 🟢 | 🟢 | 🟢 | ⚠️ 亚健康 |
| skill-c | 55 | 🔴 | 🟡 | 🔴 | 🟢 | ❌ 不健康 |

图例: 🟢 正常 | 🟡 警告 | 🔴 危险
```

#### Step 4: 输出行动建议（5 min）

根据扫描结果生成具体的行动计划：

| 行动类型 | 适用场景 | 操作说明 | 风险等级 |
|---------|---------|---------|---------|
| **合并** | 冗余技能对 | 将功能重叠的技能合并为一个，保留高分版本 | 中 |
| **退役** | 孤岛+低分/过期 | 移至 `archived/` 目录，不再维护 | 低 |
| **升级** | 退化技能 | 运行加工模式优化，提升分数 | 低 |
| **归档** | 过期但有价值 | 标记为 deprecated，保留文档但不推荐使用 | 低 |

### 扫描频率建议

| 项目规模 | 技能数量 | 建议频率 | 执行时机 |
|---------|---------|---------|---------|
| 小型项目 | <20 个 | 月度 | 每月第一个周一 |
| 中型项目 | 20-50 个 | 双周 | 每两周周五 |
| 大型项目 | >50 个 | 周度 | 每周固定时间 |
| 发布前 | 任意 | 必须执行 | 版本发布前 1-2 天 |

---

## 模式一：加工处理（Processing）

### 第一步：分析现状（5 min）

在执行任何加工操作前，先全面了解当前技能状态：

```markdown
## 技能现状分析清单

### 基础信息
- [ ] 技能名称和版本
- [ ] 当前类型判定（Type 1-4）
- [ ] 文件总行数
- [ ] 目录结构深度

### 内容质量
- [ ] Front Matter 完整性
- [ ] description 质量（CSO 规则）
- [ ] 章节完整性（目标/步骤/示例/注意事项）
- [ ] 写作规则遵循度（R1-R14）

### 结构健康度
- [ ] 层级合规性（≤3 层）
- [ ] 引用有效性（无死链）
- [ ] 内容分布合理性（SKILL.md vs references/）

### 输出：诊断报告
```

**快速诊断命令**：

```powershell
# 使用内置审计脚本进行快速扫描
./scripts/audit.ps1 -Path <SKILL.md路径> -Verbose
```

### 第二步：选择策略（5 min）

根据分析结果，从 4 种策略中选择最合适的：

#### 策略选择决策树

```
当前技能状态？
│
├── 行数 >500 且 冗余明显
│   └── → 🗑️ 策略 A: 精简优先 (Simplify)
│
├── 行数 <200 且 内容单薄
│   └── → 📚 策略 B: 丰富优先 (Enrich)
│
├── 格式混乱 / 可读性差
│   └── → ✨ 策略 C: 美化格式 (Beautify)
│
├── 结构不合理 / 类型不匹配
│   └── → 🔧 策略 D: 重构调整 (Restructure)
│
└── 多种问题并存
    └── → 组合策略（按顺序执行）
```

#### 4 种加工策略详解

| 策略 | 适用场景 | 核心动作 | 预期效果 |
|------|---------|---------|---------|
| **A: 精简优先** | >500 行，冗余多 | 删除低信号内容，压缩示例 | 减少 30-50% 行数 |
| **B: 丰富优先** | <200 行，内容不足 | 补充缺失章节，增加深度 | 增加 50-100% 有效内容 |
| **C: 美化格式** | 格式混乱 | 统一风格，表格化，优化排版 | 可读性大幅提升 |
| **D: 重构调整** | 结构问题 | 重新组织章节，调整类型 | 架构更合理 |

> 📖 **详细策略指南**: [references/strategies.md](references/strategies.md)

### 第三步：执行加工（15-30 min）

根据选择的策略执行具体操作。每种策略都有标准操作流程。

**通用原则**：
- 每次修改前备份原文件
- 每步修改后验证无破坏性变更
- 保持原有功能不变（加工不是重写）
- 记录所有变更内容

### 第四步：验证结果（10 min）

```markdown
## 加工后验证清单

### 功能验证
- [ ] 所有原有功能保留
- [ ] 无新增死链
- [ ] 引用路径正确

### 质量验证
- [ ] 重新运行审计脚本，分数提升
- [ ] 行数符合类型预期
- [ ] CSO description 仍然有效
- [ ] `skills-ref validate` 通过（格式规范未破坏）

### 对比验证
- [ ] 加工前后对比报告
- [ ] 改进点列表
- [ ] 潜在风险提示
```

**循环保护**：
- 同一技能最多加工 **3 轮**
- 连续 2 轮行数变化 <5% 时触发警告："收益递减，建议停止"
- 每轮必须记录变更日志

---

## 模式二：质量审计（Auditing）

### 第一步：运行审计脚本（2 min）

Processor 子技能包含**双重验证工具链**：

#### 1.1 官方规范验证（skills-ref）

```bash
# 安装（一次性）
npm install -g skills-ref

# 验证单个技能是否符合 agentskills.io 官方规范
skills-ref validate ./target-skill/
```

#### 1.2 质量评分审计（audit.ps1）

```powershell
# 审计单个文件
./scripts/audit.ps1 -Path ./target-skill/SKILL.md

# 审计整个项目（所有 SKILL.md）
./scripts/audit.ps1 -Project
```

**双重验证定位**：

| 维度 | skills-ref (官方) | audit.ps1 (自建) |
|------|-------------------|-----------------|
| **检查目标** | 格式规范合规性 | 质量内容评分 |
| **依据标准** | agentskills.io 官方规范 | skill-factory 100 分制 |
| **典型输出** | Valid / Invalid + 错误列表 | X/100 分 + 各维度得分 |

**推荐执行顺序**: 先 `skills-ref validate`（格式门槛）→ 再 `audit.ps1`（质量评分）

### 第二步：解读评分报告（5 min）

审计脚本输出 7 个维度的评分：

| # | 维度 | 权重 | 满分 | 关键指标 |
|---|------|------|------|---------|
| 1 | **Front Matter 完整** | 10分 | name/version/description/tags | 基础信息完整度 |
| 2 | **CSO Description** | **15分** | Use when + 触发条件 + 长度 | **最关键项** |
| 3 | **TDD 验证** | **15分** | 压力测试记录或豁免说明 | **最关键项** |
| 4 | **必备章节** | 10分 | 目标/步骤/示例/注意事项 | 结构完整性 |
| 5 | **层级合规** | 10分 | 目录深度 ≤3层 | 架构合规性 |
| 6 | **命名规范** | 5分 | kebab-case | 命名一致性 |
| 7 | **链接有效** | 5分 | 无死链 | 引用可靠性 |

**等级标准**：

| 分数段 | 等级 | 含义 | 建议 |
|--------|------|------|------|
| **≥90** | ⭐ A 优秀 | 高质量，可直接发布 | 维持即可 |
| **≥75** | ⭐ B 良好 | 质量良好，有小瑕疵 | 小修即可 |
| **≥60** | C 合格 | 基本合格，需优化 | 建议加工后发布 |
| **<60** | ❌ D 不合格 | 有重大缺陷 | 必须修复 |

### 第三步：生成改进建议（10 min）

根据审计结果，生成结构化的改进建议：

```markdown
## 审计改进报告

### 总分: XX/100 (Grade X)

#### 必须修复（阻塞性问题）
1. **[维度名]**: {问题描述}
   - 当前得分: X/Y
   - 影响: {为什么重要}
   - 修复方案: {具体操作}

#### 建议改进（非阻塞）
1. **[维度名]**: {问题描述}
   - 当前得分: X/Y
   - 建议: {如何改进}

### 优先级排序
| 优先级 | 问题 | 预期收益 | 工作量 |
|--------|------|---------|--------|
| P0 | {必须修复} | 分数+X | {小/中/大} |
| P1 | {建议改进} | 分数+X | {小/中/大} |
```

> 📖 **完整审计标准**: [references/audit-criteria.md](references/audit-criteria.md)

### 第四步：可选 — 执行修复（20 min）

如果用户要求，可以基于审计结果自动执行修复：

```
审计发现问题 → 生成修复方案 → 用户确认 → 执行修复 → 重新审计 → 对比前后分数
```

**修复原则**：
- 先修复 P0（阻塞性）问题
- 每修复一项重新验证
- 保持修复最小化（不过度修改）
- 记录所有修复操作

---

## 📊 加工 vs 审计 vs Stocktake 对比

| 维度 | 加工模式 | 审计模式 | 健康扫描模式 (Stocktake) |
|------|---------|---------|------------------------|
| **触发词** | 优化/改进/精简/重构 | 检查/审计/评分/合规 | 扫描/盘点/健康检查/全局视图 |
| **输入** | 已有技能（单个） | 已有技能（单个或项目） | 整个项目（全量技能） |
| **输出** | 改进后的技能 | 评分报告 + 改进建议 | 健康报告 + 行动计划 |
| **自动化程度** | 半自动（需策略选择） | 全自动（脚本评分） | 半自动（审计+分析+建议） |
| **是否修改原文件** | 是（有备份） | 否（仅读取和分析） | 否（仅诊断，不直接修改） |
| **典型耗时** | 20-40 min | 10-20 min | 30-45 min |
| **核心价值** | 提升单技能质量 | 评估合规性与质量 | 发现系统性技能负债 |

---

## 🛠️ 自动化工具

### 工具一：官方规范验证（skills-ref）

[agentskills.io 官方验证工具](https://www.npmjs.com/package/skills-ref) (v0.1.5, MIT)

```bash
# 安装
npm install -g skills-ref

# 验证格式合规
skills-ref validate <skill_path>

# 读取元数据（JSON 输出）
skills-ref read-properties <skill_path>
```

### 工具二：质量审计脚本 (`scripts/audit.ps1`)

位于本子技能的 `scripts/` 目录下，功能包括：

**支持的模式**：
- 单文件审计：`-Path <file>`
- 项目全量审计：`-Project`
- 详细输出：`-Verbose`

**评分维度**（7 项 × 100 分制）：
1. Front Matter 完整性（10 分）
2. CSO Description 规则（15 分）
3. TDD 验证（15 分）
4. 必备章节（10 分）
5. 层级合规（10 分）
6. 命名规范（5 分）
7. 链接有效性（5 分）

---

## 📂 本子技能结构

```
skills/skill-factory-processor/
├── SKILL.md                              ← 本文件（协调器 ~600行）
├── references/
│   ├── strategies.md                     ← 4种加工策略详解
│   ├── audit-criteria.md                 ← 审计标准与评分细则
│   ├── harness-integration-guide.md      ← Test Harness CI/CD 集成指南
│   └── harness-agents-guide.md           ← ⭐ Harness AI Agents 完整对接指南
└── scripts/
   └── audit.ps1                           ← 自动化审计脚本（v1.2，已优化Windows兼容）
```

---

## 🔗 相关资源

| 资源 | 路径 | 用途 |
|------|------|------|
| 全局写作规则 | [../references/writing-rules.md](../references/writing-rules.md) | R1-R14 完整规则 |
| 技能标准 | [../references/skill-standards.md](../references/skill-standards.md) | 规范清单 + TDD 要求 |
| 设计原则 | [../references/design-principles.md](../references/design-principles.md) | 三层铁律 + 四维分类 |
| 加工策略详情 | [references/strategies.md](references/strategies.md) | 4种策略的具体操作步骤 |
| 审计标准详情 | [references/audit-criteria.md](references/audit-criteria.md) | 评分细则 + 改进模板 |
| Test Harness 集成 | [references/harness-integration-guide.md](references/harness-integration-guide.md) | CI/CD集成 + 自动化测试 |
| **Harness AI Agents** | **[references/harness-agents-guide.md](references/harness-agents-guide.md)** | **⭐ 4个Agent完整Prompt模板和配置** |
| 最佳实践导航 | [../references/best-practices.md](../references/best-practices.md) | 项目知识枢纽 |

---

## ⚠️ 注意事项

1. **加工前必先审计**: 不要盲目加工，先了解当前状态
2. **保持最小变更**: 加工是优化不是重写，每步都要有明确目的
3. **审计是客观的**: 100 分评分体系基于明确标准，不带主观判断
4. **循环保护机制**: 同一技能最多加工 3 轮，避免过度优化
5. **备份原文件**: 任何加工操作前都应创建备份
6. **TDD 和 CSO 是最高权重**: 这两项各 15 分，是审计的核心
7. **Harness Agents 已就绪**: 所有 Prompt 模板和配置详见 [harness-agents-guide.md](references/harness-agents-guide.md)

---

## 版本历史

| 版本 | 日期 | 变更 |
|------|------|------|
| **v2.5.0** | 2026-05-30 | **精简优化**: 将 Harness AI Agents 章节 (~295行) 提取至 [references/harness-agents-guide.md](references/harness-agents-guide.md)；主文件从 936 行精简至 ~600 行 (-36%)；更新资源链接指向新文档；保持全部核心功能不变 |
| **v2.4.0** | 2026-05-30 | **Harness AI Agents 全面对接**: 新增完整的 Harness AI Agents 对接章节（4个Agent: Code Review/CI Autofix/DevOps/Knowledge Graph）；提供详细的 Prompt 模板；集成 GitHub Actions 自动审查工作流 |
| **v2.3.0** | 2026-05-30 | **新增 Test Harness 集成能力**: 新增 harness-integration-guide.md 参考文档；支持双层测试架构(Smoke Test + SDK Evaluation)；补充全流程质量门禁配置方案 |
| **v2.2.0** | 2026-05-27 | **新增 Stocktake 模式**: 三模式工作流（加工+审计+健康扫描）；新增模式三完整章节（4种扫描维度、4步执行流程、热力图状态矩阵、行动建议决策树） |
| **v2.1.0** | 2026-05-27 | **集成 skills-ref CLI**: 审计模式新增双重验证工具链（官方格式验证 + 质量评分审计） |
| **v2.0.0** | 2026-05-27 | **v2.0 架构重构**: 从旧 processor 重构为双模式协调器（加工+审计）；整合 4 种加工策略 |
