---
name: skill-factory-creator
version: v2.1.0
author: skill-factory
description: Use when creating new AI Agent skills from scratch, writing SKILL.md files, or starting skill development with TDD. Triggers on "create a skill", "new skill", "write SKILL.md", "from zero", "build a skill", "skill creation", "TDD for skills", or "start a new agent skill"
tags: [skill-creation, tdd-driven, skill-factory, type-classification, template-selection]
dependency:
  parent: skill-factory
  structure: "Type 3 (轻+厚): SKILL.md + references/"
  pattern: "Creator Coordinator"
meta:
  complexity: intermediate
  standalone: true
  can_invoke_directly: true
  tdd: simplified
  tdd_waiver_reason: "协调器型技能，内置 Type1 快速路径(简化TDD)和完整 TDD 流程指引。详细 TDD 操作见 references/tdd-guide.md"
  tdd_waiver_date: "2026-05-27"
---
# 📦 Skill Factory Creator — 技能创建器 v2.1

> **定位**: 从零创建新技能的完整工作流协调器
> **架构**: 自含型子技能（可独立通过 `/creator` 触发）
> **核心方法**: TDD 驱动 + 四维分类 + 渐进式构建

---

## 🎯 职责范围

| ✅ 负责 | ❌ 不负责 |
|---------|----------|
| 从零创建新技能 | 优化已有技能 → `/processor` |
| 类型判定与模板选择 | 审计技能合规性 → `/processor` |
| TDD RED→GREEN→REFACTOR | 发布/版本管理 → `/publisher` |
| Type 1 快速路径 | 合并/拆分技能 → `/assembler` |

---

## 🔄 创建流程总览

```
┌─────────────────────────────────────────────────────────────┐
│                    技能创建流水线                              │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ① 需求分析 → ② 类型判定 → ③ TDD RED  → ④ 构建 SKILL.md   │
│     (5min)      (5min)        (15min)       (20min)          │
│                                                             │
│  ⑤ 验证 → ⑥ REFACTOR → ✅ 完成                               │
│   (10min)    (15min)                                         │
│                                                             │
│  Type 1 快捷: ①→②→④→⑤ (跳过 TDD, ~30min)                   │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

## 第一步：需求分析（5 min）

### 1.1 收集关键信息

在开始之前，必须明确以下信息：

```markdown
## 需求收集清单

- [ ] **技能名称**: kebab-case 命名（如 `git-commit-helper`）
- [ ] **核心功能**: 用一句话描述这个技能做什么
- [ ] **目标用户**: 谁会使用这个技能？（开发者/非技术用户/特定角色）
- [ ] **触发场景**: 用户在什么情况下会需要这个技能？
- [ ] **复杂度预判**: 单功能 vs 多模块？简单 vs 复杂？
- [ ] **依赖项**: 是否需要调用其他技能/工具/API？
```

### 1.2 输出：需求简报

格式化输出为结构化需求：

```yaml
skill_name: {name}
one_liner: "{一句话描述}"
target_user: {目标用户}
trigger_scenes:
  - "{场景1}"
  - "{场景2}"
estimated_complexity: {low/medium/high}
dependencies: [{依赖列表}]
```

> 💡 **提示**: 如果用户无法清晰描述需求，使用 AskUserQuestion 工具澄清。

---

## 第二步：类型判定（5 min）

### 2.1 四维分类法

根据 [design-principles.md](../references/design-principles.md) 的四维分类法判定类型：

```
┌─────────────────────────────────────────┐
│           四维分类决策树                  │
├─────────────────────────────────────────┤
│                                         │
│  Q1: 功能数量？                          │
│  ├── 单一功能 → 轻                       │
│  └── 多模块/多步骤 → 重                  │
│                                         │
│  Q2: 内容体量？                          │
│  ├── <300行 → 薄                        │
│  └── >300行 → 厚                        │
│                                         │
│  → 组合得出 Type 1-4                    │
│                                         │
└─────────────────────────────────────────┘
```

### 2.2 类型判定表

| 判定维度 | Type 1 | Type 2 | Type 3 | Type 4 |
|---------|--------|--------|--------|--------|
| **功能数** | 1 | 2-4 | 1-2 | 4+ |
| **预估行数** | <300 | <300 | 300-500 | 500+ |
| **子技能** | 无 | skills/ | 无 | skills/ + references/ |
| **references/** | 可选 | 可选 | 必须 | 必须 |
| **scripts/** | 无 | 可选 | 可选 | 必须 |
| **TDD 要求** | 可简化 | 标准 | 标准 | 完整 |

### 2.3 判定结果 → 决策

```
判定为 Type N → 选择对应模板（见 references/type-templates.md）
               → 决定是否走完整 TDD 流程
```

**快速路径判断**：
- **Type 1 + 简单场景** → 启用快速路径（跳过完整 TDD，~30min 完成）
- **Type 2-4 或 关键任务** → 必须走完整 TDD 流程

---

## 第三步：TDD RED 阶段（15 min）*

> *Type 1 快速路径可跳过此步骤，但建议至少做简化版压力测试

### 3.1 设计压力场景

根据 [writing-rules.md#R8](../references/writing-rules.md) 的 TDD 方法论：

```markdown
## 压力场景设计原则

1. **真实性**: 模拟真实的高压力情况
   - 时间紧迫（"5分钟内完成"）
   - 权威压力（"老板要求这样做"）
   - 疲劳状态（"这是第10个类似任务"）

2. **多样性**: 至少 3 个不同类型的压力组合
   - 场景 A: 时间紧 + 需求模糊
   - 场景 B: 权威压力 + 技术冲突
   - 场景 C: 疲劳 + 边缘情况

3. **具体性**: 每个场景必须有明确的输入和期望输出
```

### 3.2 运行基线测试（无技能状态）

**操作步骤**：

1. 创建一个干净的测试环境（不加载任何技能）
2. 用子代理执行压力场景
3. **逐字记录** Agent 的行为和借口
4. 记录违反的规则和合理化理由

### 3.3 记录失败模式

```markdown
## 基线测试记录

| 场景 | 期望行为 | 实际行为 | 违规类型 | 合理化借口 |
|------|---------|---------|---------|-----------|
| 场景A | ... | ... | ... | "..." |
| 场景B | ... | ... | ... | "..." |
| 场景C | ... | ... | ... | "..." |

## 核心问题总结
1. ...
2. ...
3. ...
```

> 📖 **详细 TDD 指南**: [references/tdd-guide.md](references/tdd-guide.md)

---

## 第四步：构建 SKILL.md（20 min）

### 4.1 选择模板

根据类型判定结果，从 [references/type-templates.md](references/type-templates.md) 选择对应模板：

| 类型 | 模板文件 | 特征 |
|------|---------|------|
| Type 1 | `type1-template.md` | 单文件，<150 行 |
| Type 2 | `type2-template.md` | +skills/ 结构 |
| Type 3 | `type3-template.md` | +references/ 结构 |
| Type 4 | `type4-template.md` | 完整工厂结构 |

### 4.2 Front Matter 必填字段

```yaml
---
name: {skill-name}                    # kebab-case
version: "0.1.0"                      # 初始版本
author: {author-name}
description: >
  Use when {触发条件1}, {触发条件2}, or {触发条件3}.
  {可选: 简短功能描述}. Max 1024 chars.
tags: [{tag1}, {tag2}]
dependency:
  parent: {parent-skill-name}         # 无父技能写 "none"
  structure: "Type N ({轻/重}+{薄/厚})"
meta:
  complexity: {basic/intermediate/advanced}
---
```

### 4.3 CSO Description 编写规则

遵循 [writing-rules.md#R9](../references/writing-rules.md)：

```
✅ 正确格式:
  "Use when creating, editing, or optimizing git commits.
   Handles conventional commit messages, intelligent staging,
   and commit message generation. Triggers on 'git commit',
   'commit message', or 'conventional commits'."

❌ 错误格式:
  "Git Commit Helper - helps you write better commit messages
   following the Conventional Commits specification..."
   （这是功能描述，不是触发条件）
```

**CSO 检查清单**：
- [ ] 以 "Use when..." 开头（或包含此短语）
- [ ] 只写触发条件，不总结工作流
- [ ] 包含用户可能搜索的关键词
- [ ] 长度在 50-1024 字符之间
- [ ] 无 XML 角括号 `< >`

### 4.4 正文结构（按类型调整）

#### Type 1 最小结构（<150 行）

```markdown
# {Skill Name}

> 一句话定位

## 目标
## 操作步骤
## 示例
## 注意事项 / Gotchas
```

#### Type 2-4 完整结构

```markdown
# {Skill Name}

> 定位 + 架构说明

## 目标与范围
## 核心流程
## 详细步骤（按 Happy Path First 排序）
## 错误处理（独立章节，见 R4）
## 示例（最小化，见 R3）
## 验证清单（二进制通过/不通过，见 R5）
## 引用路径（L3 懒加载指引）
```

### 4.5 写作规则速查

在编写过程中，始终遵循以下核心规则（来自 [writing-rules.md](../references/writing-rules.md)）：

| 规则 | 应用时机 | 一句话 |
|------|---------|--------|
| **R1 Gotchas** | 写注意事项时 | 具体陷阱 > 泛泛提醒 |
| **R2 反模式** | 写禁止规则时 | 每个"不要"配"这样做"+原因 |
| **R3 Happy Path** | 排序章节时 | 90% 场景放前面 |
| **R4 验证循环** | 写检查步骤时 | 二进制通过/不通过 |
| **R7 默认值** | 给选项时 | 默认值 + 替代方案 |
| **R11 脆弱度匹配** | 控制细节程度 | 高脆弱=精确指令；低脆弱=灵活指导 |

---

## 第五步：验证（10 min）

### 5.1 自检清单

```markdown
## 创建后验证

### 结构检查
- [ ] Front Matter 完整（name/version/description/tags）
- [ ] description 符合 CSO 规则（50-1024字符，含 Use when）
- [ ] 目录深度 ≤ 3 层
- [ ] 命名规范（kebab-case）

### 内容检查
- [ ] 有明确的操作步骤（不是泛泛而谈）
- [ ] 有错误处理章节（见 R4）
- [ ] 有验证清单（二进制判断）
- [ ] Happy Path First 排序

### 质量检查
- [ ] 行数符合类型预期（Type 1<300, Type 2<300, etc.）
- [ ] 无死链（所有引用路径有效）
- [ ] 表格/列表优先于长段落
```

### 5.2 自动化审计（可选）

如果项目中有审计脚本，运行：

```bash
# 使用 processor 子技能的审计脚本
/skill-factory-processor/scripts/audit.ps1 -Path ./new-skill/SKILL.md
```

或手动对照 [skill-standards.md](../references/skill-standards.md) 的 100 分评分体系。

---

## 第六步：REFACTOR 阶段（15 min）*

> *仅完整 TDD 流程需要

### 6.1 重新测试

用新创建的技能再次运行第三步的压力场景。

### 6.2 发现并修补漏洞

```markdown
## 漏洞修补循环

1. 运行压力场景 → 观察行为
2. 发现新的合理化方式 → 记录到对照表
3. 在 SKILL.md 中添加禁止规则
4. 再次测试 → 直到通过
```

### 6.3 合理化对照表更新

将新发现的借口添加到技能的红旗警告列表：

```markdown
## 🚩 Red Flags - STOP and Start Over

如果你发现自己想说以下任何一句话，停下来，重新开始：
- [ ] "{新发现的借口1}"
- [ ] "{新发现的借口2}"

**如果你勾选了任何一项：删掉代码，从头开始用 TDD。**
```

---

## 🚀 Type 1 快速路径

当满足以下所有条件时，可启用快速路径：

### 启用条件

- [ ] 判定为 **Type 1**（单一功能，<300 行）
- [ ] **非关键任务**（非安全相关、非金融相关、非生产环境关键路径）
- [ ] 用户确认可以接受简化流程

### 快速路径流程（~30 min）

```
① 需求分析(5min)
     ↓
② 类型判定(5min) → 确认 Type 1
     ↓
③ 选择 Type 1 模板(2min)
     ↓
④ 填充内容(15min)
     ↓
⑤ 简化验证(3min)
     ↓
✅ 完成！
```

### 快速路径 vs 完整流程对比

| 维度 | 快速路径 | 完整 TDD |
|------|---------|---------|
| **耗时** | ~30 min | ~60-70 min |
| **TDD RED** | 跳过（或简化为 1 个场景） | 完整 3+ 场景 |
| **REFACTOR** | 跳过 | 完整漏洞修补 |
| **适用** | Type 1 非关键任务 | 所有类型 + 关键任务 |
| **质量保证** | 基础验证 | 高置信度 |

---

## 📂 本子技能结构

```
skills/skill-factory-creator/
├── SKILL.md                      ← 本文件（协调器 ~180行）
└── references/
    ├── tdd-guide.md              ← TDD 完整指南（RED/GREEN/REFACTOR）
    └── type-templates.md         ← Type 1-4 模板库
```

---

## 🔗 相关资源

| 资源 | 路径 | 用途 |
|------|------|------|
| 全局写作规则 | [../references/writing-rules.md](../references/writing-rules.md) | R1-R14 完整规则 |
| 设计原则 | [../references/design-principles.md](../references/design-principles.md) | 三层铁律 + 四维分类 |
| 技能标准 | [../references/skill-standards.md](../references/skill-standards.md) | 100 分评分体系 |
| 最佳实践导航 | [../references/best-practices.md](../references/best-practices.md) | 项目知识枢纽 |
| TDD 详细指南 | [references/tdd-guide.md](references/tdd-guide.md) | TDD 各阶段详细操作 |
| 类型模板库 | [references/type-templates.md](references/type-templates.md) | Type 1-4 模板代码 |

---

## ⚠️ 注意事项

1. **TDD 是铁律，不是选项**: 除非明确启用 Type 1 快速路径，否则必须走完整 TDD
2. **先判定类型再选模板**: 错误的类型选择会导致后续大量返工
3. **CSO description 决定生死**: 写得不好，技能永远不会被自动激活
4. **保持 SKILL.md 精简**: 详细内容放 references/，SKILL.md 只放核心流程
5. **每个技能都应独立可用**: 即使是子技能也要有自己的 description 和完整逻辑

---

## 版本历史

| 版本 | 日期 | 变更 |
|------|------|------|
| **v2.1.0** | 2026-05-27 | **新增 CSO Eval Query 方法论**: references/tdd-guide.md 新增"CSO 触发率评估方法论"完整章节（Eval Query 设计规范、手动评估流程、迭代优化循环、与 TDD 协作关系）；支持用户自行量化评估 description 触发准确率 |
| **v2.0.0** | 2026-05-27 | **v2.0 架构重构**: 从 orchestrator 模式重构为自含型 coordinator；整合 TDD 流程、类型判定、模板选择；新增 Type 1 快速路径；引用全局 references + 自含 references；可独立通过 `/creator` 触发 |
| v1.0.0 | 2026-05-27 | 初始版本（orchestrator + workers 模式，已废弃） |
