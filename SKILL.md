---
name: skill-factory
version: v0.5.1
author: skill-factory
description: 技能工坊 v5.0 — 轻量级技能创建指南与设计模式库，严格遵循三层架构铁律（目录深度≤3层），提供标准前言区模板和规范检查清单，覆盖技能创建、加工优化、多技能整合、版本发布与退役全生命周期，基于轻/重/薄/厚四维分类自动选择最优路径，含写作高级规则（Gotchas/反模式/验证循环）
tags: [skill-factory, skill-creation, three-layer-architecture, max-three-layers, type-classification, skill-standards, writing-rules]
dependency:
  parent: none
  architecture:
    layers: 2
    max_layers_allowed: 3
    layer_0: "skill-factory (工坊根)"
    layer_1: "3 个阶段指南 (creator / publisher / assembler)"
    structure: "Type 2 (重+薄): SKILL.md + skills/"
  core_principle:
    name: "三层架构铁律"
    definition: "所有技能创建必须遵循最多三层的层级关系"
    enforcement: "自动检测 + 用户确认机制"
---
# Skill Factory v5.0 — 技能工坊

## 这是什么？

Skill Factory 是一个**轻量级技能创建工坊**，帮助 AI Agent 规范化地创建、加工、发布和管理 Skills。

### 解决的痛点

| 手动创建的问题 | Skill Factory 的解决方式 |
|---------------|------------------------|
| 格式不一致（有的有前言区有的没有） | 提供标准前言区模板 + skill-standards 强制检查 |
| 遗漏关键章节（没触发条件/没示例/没注意事项） | 五大必备章节 + 100 分评分体系 |
| 发布混乱（版本号乱跳、无变更记录） | 语义化版本判定 + git commit 规范 + CHANGELOG 同步 |

### 适用场景

- 创建新的 AI Agent 技能（从零开始或从已有脚本迁移）
- 优化已有的 SKILL.md（行数过多/结构混乱/质量不足）
- 多技能整合或复杂技能拆分
- 建立团队统一的技能规范和评审标准

### 不适用场景

- 单行命令工具或极简 alias（直接写 `.bashrc` 即可）
- 纯配置文件（JSON/YAML/TOML 无需 SKILL.md 包装）
- 已有完善规范的成熟项目（引入可能增加不必要的开销）

---

## ⚖️ 三层架构铁律

> **核心理念**: 所有技能层级必须 ≤3 层。这是不可妥协的设计约束。
>
> 📖 详见: [references/design-principles.md](references/design-principles.md)

```
Layer 0: skill-name/SKILL.md                  ← 入口
Layer 1: skills/phase-guide/SKILL.md          ← 阶段指南（创建/发布/整合）
Layer 2: skills/phase-guide/worker/SKILL.md   ← 执行者（仅大项目需要）

🛑 最大深度 3 层（references/ / scripts/ 不算层级）
```

| 层级 | 命名规范 | 职责 | 数量 |
|------|---------|------|------|
| Layer 0 | `{skill-name}` | 全局入口 | 1 |
| Layer 1 | `{phase}-{名称}` | 阶段指南 | 1-4 |
| Layer 2 | `{worker-name}` | 单一操作（可选） | 0-10 |

> 💡 **轻量项目**（如本工坊）只需 2 层：SKILL.md → skills/*.md。Layer 2 仅在功能复杂、需要独立调度时使用。

---

## 🗂️ 四维分类法

先判断技能的"体型"，决定用什么结构：

| 维度 | 定义 | 标准 |
|------|------|------|
| **轻** | 功能单一 | 1 个核心能力 |
| **重** | 功能复杂 | 多个独立模块 |
| **薄** | 内容精简 | <300 行 |
| **厚** | 内容详细 | >300 行，需要 references/ |

| 类型 | 结构 | 示例 |
|------|------|------|
| **Type 1 (轻+薄)** | 单个 SKILL.md | 简单工具技能 |
| **Type 2 (重+薄)** | SKILL.md + skills/ | 多功能工具集 |
| **Type 3 (轻+厚)** | SKILL.md + references/ | 详细的操作指南 |
| **Type 4 (重+厚)** | SKILL.md + skills/ + references/ | 大型框架 |

> 📖 详见: [references/design-principles.md](references/design-principles.md)

---

## 🚀 快速开始

### 新建一个技能

```
1. 判定类型: 轻/重? 薄/厚?
2. 选择模板: Type 1-4
3. 写前言区: name/version/description/tags
4. 填充内容: 任务目标 → 操作步骤 → 示例 → 注意事项
5. 规范检查: 对照标准清单验证
```

| 需求 | 场景 | 详见 |
|------|------|------|
| "帮我创建技能" | 创建+加工指南 | [creator](skills/skill-factory-creator/SKILL.md) |
| "优化已有技能" | 加工模式 | [creator](skills/skill-factory-creator/SKILL.md) |
| "合并/拆分技能" | 合并+拆分指南 | [assembler](skills/skill-factory-assembler/SKILL.md) |
| "发布新版本" | 发布流程 | [publisher](skills/skill-factory-publisher/SKILL.md) |
| "退役旧技能" | 销毁流程 | [publisher](skills/skill-factory-publisher/SKILL.md) |
| "检查是否规范" | 标准清单 | [references/skill-standards.md](references/skill-standards.md) |
| "怎么写出好内容" | 写作规则 | [references/writing-rules.md](references/writing-rules.md) |

### 示例：创建一个"代码审查"技能

```
用户: "帮我创建一个代码审查技能，检查代码风格和安全漏洞"

skill-factory 工作流程:
1. 判定类型 → 轻（单功能）+ 薄（<300行）→ Type 1
2. 快速路径 → 跳过加工阶段
3. 生成 SKILL.md:

---
name: code-reviewer
version: v0.1.0
author: user
description: 代码审查技能 — 自动检查代码风格规范和安全漏洞，支持 JavaScript 和 Python 项目，输出结构化审查报告和改进建议
tags: [code-review, style-check, security, javascript, python]
dependency:
  parent: none
---
# 代码审查器

## 任务目标
自动审查代码，检查风格规范和安全漏洞。

## 触发条件
用户说"帮我审查这段代码"或"检查安全问题"时使用。

## 操作步骤
1. 解析代码语言和框架
2. 运行风格检查（ESLint/Pylint）
3. 运行安全扫描（常见漏洞模式）
4. 生成结构化审查报告

## 注意事项
- 仅支持 JavaScript 和 Python
- 安全扫描不是银弹，复杂漏洞需人工确认
```

### 示例：优化一个过大的技能

```
用户: "这个部署技能 600 行了，帮我优化"

skill-factory 工作流程:
1. 判定 → 重 + 厚 → Type 4，行数 >500
2. 加工策略 → 精简优先（精简冗余→丰富内容→美化格式→规范检查）
3. 还可以考虑拆分 → assembler 按场景拆为 deploy-dev / deploy-prod / deploy-rollback
```

---

## 📐 标准前言区模板

```yaml
---
name: {skill-name}           # kebab-case，≤50字符
version: v0.1.0              # 语义化版本
author: {author-name}
description: {100-150字符的描述，一句话说清楚}
tags: [{5-15个标签}]
dependency:
  parent: {父技能 或 none}
  children: [{子技能列表}]
---
```

---

## ✅ 规范清单（速查）

> 📖 完整清单: [references/skill-standards.md](references/skill-standards.md)

| # | 检查项 | 通过标准 |
|---|--------|---------|
| 1 | 前言区完整 | name/version/description/tags 全部存在 |
| 2 | description 长度 | 100-150 字符 |
| 3 | 命名规范 | kebab-case，小写+连字符 |
| 4 | 必备章节 | 任务目标/操作步骤/示例/注意事项 |
| 5 | 层级合规 | 目录深度 ≤3 层 |
| 6 | 链接有效 | 内部引用无死链 |

---

## 🏗️ 关键设计模式

> 📖 详见: [references/design-principles.md](references/design-principles.md)

| 模式 | 适用场景 | 核心思路 |
|------|---------|---------|
| **流水线** | 有固定顺序的流程 | 每步有门禁，失败可回调 |
| **策略选择** | 根据条件选择路径 | 按技能行数自动决策 |
| **快速路径** | Type 1 简单技能 | 跳过加工，直接发布 |
| **拆分** | 技能过于复杂 | 拆为多个 ≤3 层的独立技能 |
| **整合** | 多个技能合并 | 选择序列/并行/嵌套模式 |
| **渐进加载** | Skills 三阶段机制 | Discovery→Activation→Execution |
| **Token 效率** | 控制上下文占用 | 最小高信号 token 集 |
| **Happy Path First** | 内容排序 | 90%场景方案放最前面，边缘后置；Quickstart 覆盖完整端到端 |
| **反模式命名** | 指令可靠性 | 每个"不要"配"这样做"+失败原因；显式拒绝 Agent 先验倾向 |
| **验证循环** | 质量保障 | Plan→Validate→Execute；验证项必须是二进制通过/不通过 |
| **错误处理矩阵** | 稳定性 | 5 类异常（输入/工具/数据/权限/超时）各有处理+反馈+重试策略 |

---

## 📦 发布规范

```
修改完成 → 版本判定 → 元数据更新 → git commit/tag
```

| 变更类型 | 版本 | Commit 前缀 |
|---------|------|------------|
| 修复 | patch +1 | `fix` |
| 新增 | minor +1 | `feat` |
| 重构 | minor +1 | `refactor` |
| 破坏性 | major +1 | `feat!` |

> 📖 详见: [publisher](skills/skill-factory-publisher/SKILL.md)

---

## 🗑️ 退役流程

```
标记 deprecated → 编写迁移指引 → 30天缓冲 → 归档/删除
```

退役模板：

```yaml
---
name: {原技能}
version: v0.1.0
description: "[已废弃] 请使用: {替代技能}"
tags: [deprecated]
---
```

---

## 📂 项目结构

```
skill-factory/
├── SKILL.md                              ← 本文件: 入口
├── metadata.json                         ← 元数据
├── references/                           ← 参考文档（不占层级）
│   ├── design-principles.md              ← 铁律 + 四维分类 + 设计模式
│   ├── skill-standards.md                ← 规范检查完整清单
│   └── writing-rules.md                  ← 写作高级规则 (Gotchas/反模式/验证循环)
└── skills/                               ← Layer 1: 阶段指南
    ├── skill-factory-creator/SKILL.md    ← 创建器（生产+加工）
    ├── skill-factory-publisher/SKILL.md  ← 发布器（发布+销毁）
    └── skill-factory-assembler/SKILL.md  ← 整合器（合并+拆分）
```

**通用技能目录约定**：

```
{skill-name}/
├── SKILL.md                 ← Layer 0: 入口（必需）
├── scripts/                 ← 可执行脚本（可选，不占层级）
├── references/              ← 参考文档（可选，不占层级）
├── assets/                  ← 模板、图片等资源（可选，不占层级）
└── skills/                  ← Layer 1: 子技能（可选）
```

---

## ⚠️ 注意事项

- **三层铁律不可妥协**：任何技能目录深度 ≤3 层，超过时必须拆分或征求用户同意
- **先判定再动手**：不确定技能是 Type 1-4 中哪种时，先用四维分类法判定，选错类型会导致不必要的返工
- **Type 1 走快速路径**：简单技能不要过度设计，跳过加工阶段直接发布
- **规范清单是底线**：每个技能发布前至少过一遍速查清单的 6 项检查
- **版本号同步**：修改根文件时要检查子技能版本号是否也需要更新，避免版本分裂

---

## 版本历史

| 版本 | 日期 | 主要变更 |
|------|------|---------|
| **v0.5.0** | 2026-05-16 | ✍️ **写作规则模块**：新增 writing-rules.md (7项高级规则)，设计模式 7→11 |
| **v0.4.1** | 2026-05-16 | 📚 **质量审计**：修复 13 个问题 (P0-P2)，旧术语清零 |
| **v0.4.0** | 2026-05-16 | 🔧 **工坊重构**：18文件→6文件，6,000行→~800行，工厂→工坊 |
| v0.3.1 | 2026-05-01 | 📦 Type 3 拆分：主文件精简至 225 行 |
| v0.3.0 | 2026-05-01 | ⚖️ 三层架构铁律内化 |
| v0.2.0 | 2026-05-01 | 🏗️ 三层架构重构 |
| v0.1.0 | 2026-04-XX | 🎉 初始版本 |

> 💡 详细记录: [CHANGELOG.md](CHANGELOG.md)