---
name: skill-factory-processor
version: v2.1.0
author: skill-factory
description: Use when optimizing, refining, improving, auditing, validating, or checking AI Agent skills for quality and compliance. Triggers on "optimize this skill", "improve skill", "audit skill", "check compliance", "skill quality", "validate SKILL.md", "refactor skill", or "review skill"
tags: [skill-optimization, skill-auditing, skill-refactoring, quality-check, skill-factory]
dependency:
  parent: skill-factory
  structure: "Type 3 (轻+厚): SKILL.md + references/ + scripts/"
  pattern: "Processor Coordinator"
meta:
  complexity: intermediate
  standalone: true
  can_invoke_directly: true
  tdd: validation-only
  tdd_waiver_reason: "加工+审计是验证行为本身。审计脚本(scripts/audit.ps1)提供自动化100分评分作为客观验证"
  tdd_waiver_date: "2026-05-27"
---
# ⚙️ Skill Factory Processor — 技能加工器 v2.1

> **定位**: 加工优化 + 质量审计的双功能协调器
> **架构**: 自含型子技能（可独立通过 `/processor` 触发）
> **核心能力**: 4 种加工策略 + 100 分审计评分系统

---

## 🎯 职责范围

| ✅ 负责 | ❌ 不负责 |
|---------|----------|
| 优化已有技能（精简/丰富/美化/重构） | 从零创建新技能 → `/creator` |
| 审计技能合规性（100 分评分） | 发布/版本管理 → `/publisher` |
| 技能质量评估与改进建议 | 合并/拆分技能 → `/assembler` |
| 运行自动化审计脚本 | 需求分析 → `/creator` |

---

## 🔄 双模式工作流

```
┌─────────────────────────────────────────────────────────────┐
│              Processor 双模式入口                             │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  用户意图判断:                                               │
│                                                             │
│  "优化/改进/精简/重构" → 📝 加工模式 (Processing)            │
│  "检查/审计/评分/合规" → 🔍 审计模式 (Auditing)             │
│                                                             │
│  ┌─────────────────┐    ┌─────────────────┐                │
│  │   加工模式       │    │   审计模式       │                │
│  │                 │    │                 │                │
│  │ ① 分析现状      │    │ ① 运行审计脚本   │                │
│  │ ② 选择策略      │    │ ② 生成评分报告   │                │
│  │ ③ 执行加工      │    │ ③ 给出改进建议   │                │
│  │ ④ 验证结果      │    │ ④ 可选: 执行修复  │                │
│  └─────────────────┘    └─────────────────┘                │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

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

# 也支持直接指向 SKILL.md 文件
skills-ref validate ./target-skill/SKILL.md
```

**输出解读**：
- `Valid skill: <path>` → 通过，符合官方格式规范
- `Validation failed for <path>: ...` → 不通过，列出具体格式问题

> **skills-ref 检查范围**: name/version/description 字段存在性、Front Matter 格式、SKILL.md 文件存在性、description 长度 ≤1024 字符、name 格式 kebab-case
>
> ⚠️ **skill-factory 自身技能的预期行为**: 本项目（skill-factory）的子技能使用了**扩展 Front Matter 字段**（author/dependency/meta/tags/version），这些字段不在官方白名单中。因此对本项目自身技能运行 `skills-ref validate` 会报告 "Unexpected fields" 警告，这是**预期行为**，不影响功能。对待验证的目标技能（非 skill-factory 自身），此警告应作为格式问题修复。

#### 1.2 质量评分审计（audit.ps1）

```powershell
# 审计单个文件
./scripts/audit.ps1 -Path ./target-skill/SKILL.md

# 审计整个项目（所有 SKILL.md）
./scripts/audit.ps1 -Project

# 详细输出（显示检查过程）
./scripts/audit.ps1 -Path ./target/SKILL.md -Verbose
```

**双重验证定位**：

| 维度 | skills-ref (官方) | audit.ps1 (自建) |
|------|-------------------|-----------------|
| **检查目标** | 格式规范合规性 | 质量内容评分 |
| **依据标准** | agentskills.io 官方规范 | skill-factory 100 分制 |
| **典型输出** | Valid / Invalid + 错误列表 | X/100 分 + 各维度得分 |
| **互补关系** | 先跑这个确保"合格" | 再跑这个评估"好坏" |

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
| **≥90** | ⭐ A 优秀 | 高质量，可直接发布 | 维护即可 |
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

#### 可选优化（锦上添花）
1. **[维度]**: {优化建议}

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

## 📊 加工 vs 审计 对比

| 维度 | 加工模式 | 审计模式 |
|------|---------|---------|
| **触发词** | 优化/改进/精简/重构 | 检查/审计/评分/合规 |
| **输入** | 已有技能 | 已有技能 |
| **输出** | 改进后的技能 | 评分报告 + 改进建议 |
| **自动化程度** | 半自动（需策略选择） | 全自动（脚本评分） |
| **是否修改原文件** | 是（有备份） | 否（仅读取和分析） |
| **典型耗时** | 20-40 min | 10-20 min |

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

# 生成 available_skills XML
skills-ref to-prompt <skill_a> <skill_b>
```

**适用场景**: CI/CD 格式门禁、发布前规范检查、跨平台兼容性验证

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

**输出示例**：

```
=====================================================
  Skill Audit: SKILL.md
  Path: ./target/SKILL.md
=====================================================

  Lines: 245

  Audit Results:
  [+] Front Matter Complete (10/10)
  [+] CSO Description Rule (15/15)
  [!] TDD Validation (7/15)
      ! No stress test records
      ! TDD mentioned but no test records or waiver
  [-] Essential Sections (5/10)
      X Missing section: [Examples]
  ...

+-------------------------------------------+
|  Total: 72/100 (72%)  Grade: B (Good)     |
+-------------------------------------------+
```

---

## 📂 本子技能结构

```
skills/skill-factory-processor/
├── SKILL.md                      ← 本文件（协调器 ~200行）
├── references/
│   ├── strategies.md             ← 4种加工策略详解
│   └── audit-criteria.md         ← 审计标准与评分细则
└── scripts/
    └── audit.ps1                 ← 自动化审计脚本（100分制）
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
| 最佳实践导航 | [../references/best-practices.md](../references/best-practices.md) | 项目知识枢纽 |

---

## ⚠️ 注意事项

1. **加工前必先审计**: 不要盲目加工，先了解当前状态
2. **保持最小变更**: 加工是优化不是重写，每步都要有明确目的
3. **审计是客观的**: 100 分评分体系基于明确标准，不带主观判断
4. **循环保护机制**: 同一技能最多加工 3 轮，避免过度优化
5. **备份原文件**: 任何加工操作前都应创建备份
6. **TDD 和 CSO 是最高权重**: 这两项各 15 分，是审计的核心

---

## 版本历史

| 版本 | 日期 | 变更 |
|------|------|------|
| **v2.1.0** | 2026-05-27 | **集成 skills-ref CLI**: 审计模式新增双重验证工具链（官方格式验证 + 质量评分审计）；加工模式验证步骤增加 skills-ref 检查；自动化工具章节扩展为双工具说明 |
| **v2.0.0** | 2026-05-27 | **v2.0 架构重构**: 从旧 processor 重构为双模式协调器（加工+审计）；整合 4 种加工策略；迁移审计脚本到本地 scripts/；新增 references/strategies.md 和 audit-criteria.md；可独立通过 `/processor` 触发 |
| v1.0.0 | 2026-05-27 | 初始版本（已废弃） |
