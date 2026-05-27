# 技能类型模板库 — Type 1 to Type 4

> **来源**: [../SKILL.md](../SKILL.md) → 类型判定 → 模板选择
> **版本**: v2.0.0
> **用途**: 根据四维分类结果选择对应模板，快速启动技能创建

---

## 使用方法

```
1. 在 creator 主流程的"第二步：类型判定"中确定类型
2. 选择对应类型的模板
3. 复制模板到新技能目录
4. 根据"填充指南"定制内容
```

---

## Type 1 模板（轻+薄）

> **适用**: 单一功能，<300 行，单文件自包含
> **示例**: git-commit-helper, format-converter, file-renamer

### 目录结构

```
{skill-name}/
└── SKILL.md          ← 唯一文件，<150 行理想
```

### SKILL.md 模板

```yaml
---
name: {skill-name}
version: "0.1.0"
author: {author-name}
description: >
  Use when {触发条件1}, {触发条件2}, or {触发条件3}.
  {可选: 一句话功能描述}. Max 1024 chars.
tags: [{tag1}, {tag2}]
dependency:
  parent: none
  structure: "Type 1 (轻+薄): 单文件"
meta:
  complexity: basic
  tdd: standard  # 或 simplified(快速路径)
---
# {Skill Name} — {一句话定位}

> **定位**: {这个技能解决什么问题}
> **类型**: Type 1 (轻+薄) 单文件技能

## 目标

{用一句话描述技能的核心目标}

**能做什么**:
- {功能1}
- {功能2}
- {功能3}

**不能做什么**（明确边界）:
- {不在范围内的事1}
- {不在范围内的事2}

## 操作步骤

### 默认流程（Happy Path — 90% 场景）

```
1. {步骤1: 具体动作 + 预期结果}
2. {步骤2: 具体动作 + 预期结果}
3. {步骤3: 具体动作 + 预期结果}
```

### 变体流程（如适用）

**场景 A: {条件}**

```
1. {变体步骤1}
2. {变体步骤2}
```

**场景 B: {条件}**

```
1. {变体步骤1}
```

## 示例

### 最小示例（端到端）

```
用户: "{用户输入}"
你: 
1. {你的响应步骤1}
2. {你的响应步骤2}
结果: "{预期最终输出}"
```

### 进阶示例（如有边缘情况）

```
用户: "{复杂输入}"
你:
1. {步骤}
...
结果: "{输出}"
```

## ⚠️ 注意事项 / Gotchas

| 坑点 | 后果 | 正确做法 |
|------|------|---------|
| {具体陷阱1} | {具体后果} | {正确做法} |
| {具体陷阱2} | {具体后果} | {正确做法} |

## 验证清单

完成后逐项检查：

- [ ] {二进制检查项1: 可自动验证}
- [ ] {二进制检查项2: 可自动验证}
- [ ] {二进制检查项3: 可自动验证}

## ❌ 常见错误

| 错误做法 | 为什么失败 | 正确做法 |
|---------|-----------|---------|
| {反模式1} | {Agent 的先验倾向} | {具体替代方案} |
| {反模式2} | {Agent 的先验倾向} | {具体替代方案} |
```

### 填充指南

| 字段 | 填写建议 | 示例 |
|------|---------|------|
| name | kebab-case，动词优先 | `git-commit-helper` |
| description | Use when 开头 + 触发短语 | 见 CSO 规则 |
| 定位句 | 一句话说清价值 | "帮助写出规范的 Git 提交信息" |
| 目标 | 能/不能各 2-3 项 | 能: 生成/检查/修正；不能: 推送/合并 |
| 步骤 | 每步可执行、可验证 | "运行 `xxx` 命令" > "处理 xxx" |
| Gotchas | 具体 > 泛泛 | "忘记 `-m` 导致编辑器弹出" > "注意参数" |
| 验证项 | 二进制判断 | "`test` 返回 exit 0" > "检查无误" |

---

## Type 2 模板（重+薄）

> **适用**: 多模块功能，<300 行主文件 + skills/ 子技能
> **示例**: devops-toolkit, testing-framework, ci-cd-pipeline

### 目录结构

```
{skill-name}/
├── SKILL.md                    ← 协调器 (~200行)
└── skills/
    ├── {skill-name}-{module-a}/SKILL.md   ← 子技能 A
    ├── {skill-name}-{module-b}/SKILL.md   ← 子技能 B
    └── {skill-name}-{module-c}/SKILL.md   ← 子技能 C
```

### SKILL.md 模板（协调器）

```yaml
---
name: {skill-name}
version: "0.1.0"
author: {author-name}
description: >
  Use when {触发条件1}, {触发条件2}, or {触发条件3}.
  {可选: 功能描述}. Max 1024 chars.
tags: [{tag1}, {tag2}]
dependency:
  parent: none
  structure: "Type 2 (重+薄): SKILL.md + skills/"
  pattern: "Coordinator Pattern"
meta:
  complexity: intermediate
  sub_skills: [{module-a}, {module-b}, {module-c}]
---
# {Skill Name} — {一句话定位}

> **定位**: 多模块协调器 — 将请求分发到子技能
> **架构**: Coordinator (root → skills/ = Layer 0 → Layer 1)

## 🎯 核心原则

{如果有全局适用的原则，在此列出 2-3 条}

## 🧭 智能路由

```
用户说...                    → 调用
─────────────────          ──────────────────────────
"{触发词A}"              → 📦 {module-a} ({子技能A职责})
"{触发词B}"              → 🔧 {module-b} ({子技能B职责})
"{触发词C}"              → ⚡ {module-c} ({子技能C职责})
```

### 复合场景

| 用户意图 | 执行顺序 |
|---------|---------|
| {意图1} | {子技能A} → {子技能B} |
| {意图2} | {子技能B} → {子技能C} |

## 📂 子技能一览

| 子技能 | 职责 | 独立可用 | 关键能力 |
|--------|------|---------|---------|
| **[{module-a}](skills/{skill-name}-{module-a}/SKILL.md)** | {职责描述} | ✅ `/{module-a}` | {能力1} |
| **[{module-b}](skills/{skill-name-{module-b}}/SKILL.md)** | {职责描述} | ✅ `/{module-b}` | {能力2} |
| **[{module-c}](skills/{skill-name-{module-c}}/SKILL.md)** | {职责描述} | ✅ `/{module-c}` | {能力3} |

## 📂 项目结构

```
{skill-name}/
├── SKILL.md                              ← 本文件（协调器 ~200行）
└── skills/
    ├── {skill-name}-{module-a}/          ← {模块A描述}
    ├── {skill-name}-{module-b}/          ← {模块B描述}
    └── {skill-name}-{module-c}/          ← {模块C描述}
```

## ⚠️ 注意事项

- **子技能优先**: 根文件仅做路由，详细逻辑在各子技能中
- **每个子技能可独立使用**: 有自己的 description 和完整逻辑
- **路由不确定时**: 提供选项菜单让用户选择

## 版本历史

| 版本 | 日期 | 变更 |
|------|------|------|
| **0.1.0** | {日期} | 初始版本 |
```

### 子技能 SKILL.md 模板

```yaml
---
name: {skill-name}-{module-name}
version: "0.1.0"
description: >
  Use when {子技能触发条件}.
  Max 1024 chars.
dependency:
  parent: {skill-name}
  structure: "Sub-skill of Type 2"
---
# {Module Name} — {定位}

> **父技能**: [{parent}](../SKILL.md)
> **独立可用**: ✅ 可直接通过 `/{module-name}` 触发

## 目标

{本子技能的目标}

## 操作步骤

1. {步骤1}
2. {步骤2}
...

## 示例

{示例}

## 注意事项

{注意事项}
```

### 填充指南

| 维度 | 建议 |
|------|------|
| **子技能数量** | 2-4 个理想，超过 4 个考虑拆分为独立技能族 |
| **每个子技能行数** | 80-200 行健康范围 |
| **路由关键词** | 每个子技能 3-5 个触发词 |
| **协调器行数** | <250 行（纯路由 + 概览） |
| **子技能独立性** | 每个都要有完整的 description，可被 Agent 直接触发 |

---

## Type 3 模板（轻+厚）

> **适用**: 单一功能但需要大量参考文档，300-500 行主文件 + references/
> **示例**: api-client-generator, code-reviewer, documentation-builder

### 目录结构

```
{skill-name}/
├── SKILL.md                    ← 主文件 (~300行)
└── references/
    ├── {topic-a}.md            ← 详细参考 A
    ├── {topic-b}.md            ← 详细参考 B
    └── {topic-c}.md            ← 详细参考 C
```

### SKILL.md 模板

```yaml
---
name: {skill-name}
version: "0.1.0"
author: {author-name}
description: >
  Use when {触发条件1}, {触发条件2}, or {触发条件3}.
  {可选: 功能描述}. Max 1024 chars.
tags: [{tag1}, {tag2}]
dependency:
  parent: none
  structure: "Type 3 (轻+厚): SKILL.md + references/"
meta:
  complexity: intermediate
  references_count: N
---
# {Skill Name} — {一句话定位}

> **定位**: {定位描述}
> **架构**: 厚文档型 — 核心逻辑在 SKILL.md，深度知识在 references/

## 目标与范围

### 核心目标

{目标描述}

### 边界

| ✅ 在范围内 | ❌ 不在范围内 |
|------------|--------------|
| {功能1} | {非功能1} |
| {功能2} | {非功能2} |

## 核心流程

```
{流程图或步骤列表}
```

## 详细步骤

### Phase 1: {阶段名}

**何时使用此阶段**: {触发条件}

```
1. {步骤1}
2. {步骤2}
   - {细节}
   - {细节}
3. {步骤3}
```

> 📖 **深度阅读**: 如果需要了解 {主题A} 的详细信息，读取 `references/{topic-a}.md`

### Phase 2: {阶段名}

**何时使用此阶段**: {触发条件}

```
1. {步骤1}
2. {步骤2}
```

> 📖 **深度阅读**: 如果需要了解 {主题B} 的详细信息，读取 `references/{topic-b}.md`

## 错误处理

| 异常类别 | 触发条件 | 处理方式 | 是否重试 |
|---------|---------|---------|---------|
| {类别1} | {条件} | {处理方式} | {是/否} |
| {类别2} | {条件} | {处理方式} | {是/否} |

## 示例

### 基础示例

{示例}

### 复杂示例（引用 references）

{示例，涉及深度知识时指向 references}

## 验证清单

- [ ] {检查项1}
- [ ] {检查项2}
- [ ] {检查项3}

## 📚 参考文档索引

| 文档 | 内容 | 何时读取 |
|------|------|---------|
| [{topic-a}.md](references/{topic-a}.md) | {描述} | {触发条件} |
| [{topic-b}.md](references/{topic-b}.md) | {描述} | {触发条件} |
| [{topic-c}.md](references/{topic-c}.md) | {描述} | {触发条件} |

> 💡 **加载时机**: 仅在需要时按需读取（L3 懒加载），不要预加载全部

## 注意事项

{注意事项}
```

### references/ 文档模板

```markdown
# {Topic Title}

> **来源**: [../SKILL.md](../SKILL.md) → {关联章节}
> **用途**: {本文档解决什么问题}
> **何时读取**: {明确的触发条件}

---

## 概述

{概述内容}

## 详细内容

{详细内容，可以是：
 - API 参考
 - 配置选项表
 - 决策树
 - 代码示例
 - FAQ
}

## 快速速查

{常用信息的表格化总结}

## 相关资源

- [相关文档1](./other-topic.md)
- [外部链接]
```

### 填充指南

| 维度 | 建议 |
|------|------|
| **SKILL.md 行数** | 250-400 行理想 |
| **references/ 数量** | 2-5 个文件 |
| **每个 reference 行数** | 100-300 行 |
| **引用方式** | 明确的"何时读取"条件，不要只放链接 |
| **内容分配** | SKILL.md 放流程/决策；references 放细节/参考 |

---

## Type 4 模板（重+厚）

> **适用**: 大型复杂项目，多模块 + 大量参考文档
> **示例**: skill-factory 本身, full-stack-toolkit, enterprise-automation

### 目录结构

```
{skill-name}/
├── SKILL.md                            ← 路由枢纽 (~150行)
├── references/                         ← 全局共享参考
│   ├── best-practices.md               ← （可选）最佳实践
│   └── shared-standards.md             ← （可选）共享标准
├── scripts/                            ← （可选）自动化脚本
│   └── {script}.{ext}
└── skills/                             ← Layer 1: 子技能
    ├── {skill-name}-{domain-a}/        ← 领域 A
    │   ├── SKILL.md                    ← 协调器
    │   ├── references/                 ← 领域 A 专属参考
    │   └── scripts/                    ← 领域 A 专属脚本
    ├── {skill-name}-{domain-b}/        ← 领域 B
    │   ├── SKILL.md
    │   └── references/
    └── {skill-name}-{domain-c}/        ← 领域 C
        ├── SKILL.md
        └── references/
```

### Root SKILL.md 模板（路由器）

```yaml
---
name: {skill-name}
version: "0.1.0"
author: {author-name}
description: >
  Use when {触发条件1}, {触发条件2}, or {触发条件3}.
  {功能描述}. Max 1024 chars.
tags: [{tag1}, {tag2}]
dependency:
  parent: none
  structure: "Type 4 (重+厚): Router + sub-skills + references/"
  pattern: "Router Architecture"
meta:
  complexity: advanced
  sub_skills: [{domain-a}, {domain-b}, {domain-c}]
---
# {Skill Name} v0.1.0 — {标题副标题}

> **定位**: 轻量路由枢纽 — 将用户请求分发到 {N} 个独立子技能
> **架构**: {N}-Entry Router (root → skills/ = Layer 0 → Layer 1)

## 🎯 核心原则（速查）

{2-3 条核心原则，表格或代码块形式}

## 🧭 智能路由

```
用户说...                    → 调用
─────────────────          ──────────────────────────
"{触发词A}"              → 📦 /{domain-a}      ({职责A})
"{触发词B}"              → ⚙️ /{domain-b}      ({职责B})
"{触发词C}"              → 📤 /{domain-c}      ({职责C})
```

### 复合场景

| 用户意图 | 执行顺序 |
|---------|---------|
| {意图1} | {子技能A} → {子技能B} |
| {意图2} | {子技能B} → {子技能C} → {子技能A} |

### 歧义处理

不确定用户意图时，提供选项菜单：
> "您是想：a) {选项A} b) {选项B} c) {选项C}？"

## 📂 子技能一览

| 子技能 | 职责 | 独立可用 | 关键文件 |
|--------|------|---------|---------|
| **[{domain-a}]({path})** | {职责} | ✅ `/{domain-a}` | {关键能力} |
| **[{domain-b}]({path})** | {职责} | ✅ `/{domain-b}` | {关键能力} |
| **[{domain-c}]({path})** | {职责} | ✅ `/{domain-c}` | {关键能力} |

> 每个子技能完全自含：独立的 description、references/、scripts/、assets/

## 📂 项目结构

{完整目录树}

## ⚠️ 注意事项

- **子技能优先**: 根文件仅做路由
- **每个子技能可独立使用**
- **全局 references/ 仅放跨子技能公共内容**
- **职能归属明确**: {具体归属说明}

## 版本历史

| 版本 | 日期 | 变更 |
|------|------|------|
| **0.1.0** | {日期} | 初始版本 |
```

### 子技能 SKILL.md 模板（Type 4 子技能）

```yaml
---
name: {skill-name}-{domain-name}
version: "0.1.0"
description: >
  Use when {子技能触发条件}.
  Max 1024 chars.
dependency:
  parent: {skill-name}
  structure: "Type 4 Sub-skill: self-contained"
  pattern: "Coordinator with references"
meta:
  complexity: {basic/intermediate/advanced}
  standalone: true
  can_invoke_directly: true
---
# {Domain Name} — {定位}

> **父技能**: [{parent}](../SKILL.md)
> **独立可用**: ✅ 可通过 `/{domain-name}` 直接触发
> **架构**: 自含型子技能（有自己的 references/scripts）

---

## 🎯 职责范围

| ✅ 负责 | ❌ 不负责 |
|---------|----------|
| {职责1} | {非职责1} → `/{other-domain}` |
| {职责2} | {非职责2} → `/{other-domain}` |

## 核心流程

{流程描述}

## 详细步骤

{步骤，包含引用路径指引}

> 📖 **详细参考**: `references/{topic}.md` — {何时读取}

## 验证清单

- [ ] {检查项}

## 📂 本子技能结构

```
skills/skill-factory-{domain}/
├── SKILL.md              ← 本文件
└── references/
    └── {topic}.md
```

## 🔗 相关资源

| 资源 | 路径 | 用途 |
|------|------|------|
| 全局标准 | [../../references/shared.md](../../references/shared.md) | {用途} |
| 兄弟子技能 | [../{other}/SKILL.md](../{other}/SKILL.md) | {用途} |
| 本地参考 | [references/{topic}.md](references/{topic}.md) | {用途} |

## 版本历史

| 版本 | 日期 | 变更 |
|------|------|------|
| **0.1.0** | {日期} | 初始版本 |
```

### 填充指南

| 维度 | 建议 |
|------|------|
| **根路由器行数** | 120-180 行（纯路由 + 速查） |
| **子技能数量** | 3-5 个理想 |
| **每个子技能行数** | 150-250 行 |
| **全局 references** | 仅放跨子技能公共内容 |
| **子技能 references** | 各子技能的自含参考 |
| **scripts/ 位置** | 根目录放公共脚本，子技能放专属脚本 |

---

## 模板选择决策树

```
开始创建技能
    │
    ▼
功能数量？
├── 单一功能 ──┐
│              ▼
│         预估行数？
│         ├── <300行 → Type 1 ✅ (单文件)
│         └── >300行 → Type 3 ✅ (+references/)
│
└── 多模块 ────┐
               ▼
          预估行数？
          ├── <300行 → Type 2 ✅ (+skills/)
          └── >300行 → Type 4 ✅ (完整工厂)
```

---

## 从模板到实战：检查清单

### 创建前

- [ ] 已完成需求分析（第一步）
- [ ] 已确定技能类型（第二步）
- [ ] 已选择正确的模板（本文件）

### 创建中

- [ ] Front Matter 所有必填字段已填写
- [ ] description 符合 CSO 规则（Use when + 触发短语）
- [ ] 目录结构符合类型约定
- [ ] Happy Path First 排序
- [ ] 有明确的验证清单（二进制判断）

### 创建后

- [ ] 行数在类型预期范围内
- [ ] 所有引用路径有效
- [ ] 可独立使用（如果是子技能）
- [ ] 通过基础审计（可选）

---

> 📖 **TDD 指南**: [tdd-guide.md](tdd-guide.md) — 如何用 TDD 方法论验证模板产出
> 📋 **全局标准**: [../skill-standards.md](../skill-standards.md) — 100 分评分体系
> ✍️ **写作规则**: [../writing-rules.md](../writing-rules.md) — R1-R14 完整规则
