---
name: skill-factory-creator
version: v2.4.0
author: skill-factory
description: "Use when creating new AI Agent skills from scratch, writing SKILL.md files, starting skill development with TDD, designing test scenarios (scenarios.yaml), or defining acceptance criteria. Triggers on \"create a skill\", \"new skill\", \"write SKILL.md\", \"from zero\", \"build a skill\", \"skill creation\", \"TDD for skills\", \"start a new agent skill\", \"test scenario\", \"acceptance criteria\", or \"harness testing\""
tags: [skill-creation, tdd-driven, test-scenarios, acceptance-criteria, harness-testing, type-classification, template-selection, ci-cd-ready, skill-factory]
dependency:
  parent: skill-factory
  structure: "Type 3 (轻+厚): SKILL.md + references/"
  pattern: "Creator Coordinator + Test Harness Integration"
meta:
  complexity: advanced
  standalone: true
  can_invoke_directly: true
  tdd: full
  tdd_guide: "references/tdd-guide.md"
  tdd_records: "references/tdd-guide.md 包含完整压力场景设计、基线测试记录模板、漏洞修补循环示例"
  test_harness_ready: true
  scenario_support: "scenarios.yaml + acceptance-criteria.md"
  harness_integration: "v1.0"
---
# 📦 Skill Factory Creator — 技能创建器

> **定位**: 从零创建新技能的完整工作流协调器
> **核心方法**: TDD 驱动 + 四维分类 + Test Scenario 设计

## 职责

| ✅ 负责 | ❌ 不负责 |
|---------|----------|
| 从零创建新技能（含 TDD 全流程） | 优化已有技能 → `/processor` |
| 类型判定与模板选择 | 审计合规性 → `/processor` |
| Test Scenario 设计 (scenarios.yaml) | 发布/版本管理 → `/publisher` |
| Acceptance Criteria 定义 | 合并/拆分 → `/assembler` |

## 🧪 Test Scenario 设计

> **完整指南**: [references/test-scenario-guide.md](references/test-scenario-guide.md)

技能质量 = 内容正确性(TDD) × 触发准确率(CSO) × 场景覆盖率(Scenario)

**模板**: `tests/scenarios/{skill-name}/scenarios.yaml` — 20 场景 (10 正例+10 负例) + `acceptance-criteria.md`

**覆盖维度**: 措辞变化 / 明确度变化 / 细节程度 / 复杂度变化

**通过标准**: 正例触发 ≥95% + 负例拒止 ≥95% + 总体准确率 ≥90%

## 🔄 创建流程

```
① 需求分析(5min) → ② 类型判定(5min) → ③ TDD RED(15min) → ④ 构建 SKILL.md(20min) → ⑤ 验证(10min) → ⑥ REFACTOR(15min) → ✅
Type 1 快捷: ①→②→④→⑤ (跳过 TDD，~30min)
```

### 第一步：需求分析

四维意图捕获（4-Question Framework）：

| 问题 | 目标 | 输出 |
|------|------|------|
| Q1: 做什么？ | 定义核心功能+边界 | 范围定义（功能/边界/用户/复杂度） |
| Q2: 何时触发？ | 收集触发词+近误排除 | CSO description 素材 |
| Q3: 输出格式？ | 明确交付物形态 | 类型(文本/代码/文件/交互/状态变更) |
| Q4: 需要测试？ | 决定 TDD 策略 | full/simplified/validation-only/deferred |

**输出**: 四维需求简报 (YAML) — 见 [tdd-guide.md](references/tdd-guide.md)

### 第二步：类型判定

| | Type 1 | Type 2 | Type 3 | Type 4 |
|---|--------|--------|--------|--------|
| 功能数 | 1 | 2-4 | 1-2 | 4+ |
| 行数 | <300 | <300 | 300-500 | 500+ |
| 结构 | 单文件 | +skills/ | +references/ | +skills/ + references/ |
| TDD | 可简化 | 标准 | 标准 | 完整 |

**快速路径**: Type 1 + 非关键任务 → 跳过完整 TDD，~30min

### 第三步：TDD RED

> **完整指南**: [references/tdd-guide.md](references/tdd-guide.md)

设计 ≥3 个压力场景（时间紧迫/权威压力/疲劳状态），运行基线测试记录失败模式。

### 第四步：构建 SKILL.md

1. 根据类型选择模板 → [references/type-templates.md](references/type-templates.md)
2. 编写 Front Matter（name/version/description/tags）
3. 遵循 CSO 规则：`"Use when..."` 开头，50-1024 字符，无 XML 角括号
4. 按类型选择正文结构：

| 类型 | 结构 |
|------|------|
| Type 1 | `# 标题 > 定位 → ## 目标 → ## 操作步骤 → ## 示例 → ## 注意事项` |
| Type 2-4 | `# 标题 > 定位+架构 → ## 职责 → ## 核心流程 → ## 详细步骤 → ## 错误处理 → ## 验证清单 → ## 引用` |

**写作规则速查** — 详见 [writing-rules.md](../../references/writing-rules.md)：R1 Gotchas(具体陷阱)、R2 反模式(每个"不要"配"这样做")、R3 Happy Path(90%场景优先)、R4 验证循环(二进制通过/不通过)、R7 默认值(默认+替代)、R11 脆弱度匹配(高脆弱=精确/低脆弱=灵活)

### 第五步：验证

**自检**:
- Front Matter 完整、CSO 合规、层级 ≤3、命名 kebab-case
- 有操作步骤+错误处理+验证清单、Happy Path 优先
- 行数符合类型预期、无死链

**自动化审计**: `audit.ps1 -Path ./new-skill/SKILL.md` 或对照 [skill-standards.md](../../references/skill-standards.md) 100 分评分

### 第六步：REFACTOR (完整 TDD 流程)

运行压力场景 → 发现新借口 → 添加禁止规则 → 重复直到通过

**Red Flags** — 如发现自己在找借口，删除代码从头 TDD

## ⚠️ 约束

1. **TDD 是铁律** — 除非启用 Type 1 快速路径，必须走完整 TDD
2. **先判定类型再选模板** — 错误类型导致大量返工
3. **CSO description 决定生死** — 写不好技能永远不会被自动激活
4. **SKILL.md 精简** — 详细内容放 references/ (目标 <500 行)
5. **子技能独立可用** — 即使子技能也要有自己的 description

## 📂 结构

```
skill-factory-creator/
├── SKILL.md                              ← 本文件
└── references/
    ├── tdd-guide.md                      ← TDD 完整指南
    ├── test-scenario-guide.md            ← Test Scenario 设计指南
    └── type-templates.md                 ← Type 1-4 模板库
```

## 版本历史

| 版本 | 日期 | 变更 |
|------|------|------|
| **v2.4.0** | 2026-05-30 | 提取 Test Scenario/Acceptance Criteria 至 references/，主文件 869→~500 行 |
| **v2.0.0** | 2026-05-27 | 重构为自含型 coordinator，整合 TDD+类型判定+模板，新增快速路径 |