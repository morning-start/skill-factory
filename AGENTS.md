# Skill Factory — AI Agent 协作配置

> **项目**: Skill Factory v2.2 — 技能工坊 (Router Edition)
> **定位**: AI Agent 技能创建工坊 | 4-Entry Router 架构 | TDD 驱动
> **最后更新**: 2026-05-30

---

## 🎯 这是什么？

Skill Factory 是一个帮助 AI Agent 规范化**创建、加工、发布和管理 Skills** 的轻量级工坊。

**核心能力**:
- 📦 创建新技能（TDD 驱动流程）
- ⚙️ 加工/优化已有技能
- 📤 发布版本 / 退役旧技能
- 🔗 合并 / 拆分技能
- ✅ 审计技能质量（100 分制）

---

## 🚀何时使用此配置？

当你在 **skill-factory 项目中工作时**，此 AGENTS.md 告诉你：

### ✅ 应该使用的场景

| 你想做... | 使用方式 | 示例命令 |
|-----------|---------|---------|
| **创建新技能** | 调用 creator 子技能 | "帮我创建一个代码审查技能" |
| **优化/改进技能** | 调用 processor 子技能 | "优化这个技能的 description" |
| **审计技能质量** | 运行 audit.ps1 或 processor | "检查所有技能是否合规" |
| **发布新版本** | 调用 publisher 子技能 | "发布 v2.3.0 版本" |
| **合并/拆分技能** | 调用 assembler 子技能 | "把这两个技能合并" |
| **理解项目结构** | 查看本文档 + SKILL.md | "项目的架构是什么？" |

### ❌ 不适用的场景

- 非 skill-factory 项目的技能开发
- 纯文档编辑（不涉及 SKILL.md 结构）
- 不需要遵循 agentskills.io 标准的场景

---

## 🏗️ 项目架构速查

```
skill-factory/
├── SKILL.md                              ← 入口路由器 (~150行)
├── references/                           ← 全局参考文档（不占层级）
│   ├── design-principles.md              ← 三大铁律 + 四维分类法
│   ├── best-practices.md                 ← 最佳实践速查
│   ├── writing-rules.md                  ← 写作规则 R1-R14
│   └── skill-standards.md                ← 规范检查清单
├── skills/                               ← Layer 1: 4个独立子技能
│   ├── skill-factory-creator/            ← 📦 创建器
│   ├── skill-factory-processor/          ← ⚙️ 加工器+审计引擎
│   ├── skill-factory-publisher/          ← 📤 发布器
│   └── skill-factory-assembler/           ← 🔗 整合器
└── tests/scenarios/                      ← Test Harness (100个场景)
    ├── skill-factory-root/scenarios.yaml      ← 路由器测试 (20场景)
    ├── skill-factory-creator/scenarios.yaml   ← 创建器测试 (20场景)
    ├── skill-factory-processor/scenarios.yaml ← 加工器测试 (20场景)
    ├── skill-factory-publisher/scenarios.yaml ← 发布器测试 (20场景)
    └── skill-factory-assembler/scenarios.yaml ← 整合器测试 (20场景)
```

### 四维分类法（必读）

在动手前，先判断技能类型：

| | **轻**(单功能) | **重**(多模块) |
|---|---|---|
| **薄** (<300行) | **Type 1**: 单个 SKILL.md | **Type 2**: SKILL.md + skills/ |
| **厚** (>300行) | **Type 3**: SKILL.md + references/ | **Type 4**: SKILL.md + skills/ + references/ |

---

## 📋 工作流程规范

### 🔴 必须遵守的三大铁律

```
┌─────────────────────────────────────────────┐
│           ⚠️ 三大铁律（不可违反）              │
├─────────────────────────────────────────────┤
│ ① 层级 ≤3 层 (references/scripts/assets 不算) │
│ ② NO SKILL WITHOUT FAILING TEST FIRST (TDD)   │
│ ③ description 只写触发条件 (CSO)             │
└─────────────────────────────────────────────┘
```

#### 铁律 ①：三层架构限制

```
Layer 0: skill-name/SKILL.md                  ← 入口
Layer 1: skills/phase-guide/SKILL.md          ← 阶段指南
Layer 2: skills/phase-guide/worker/SKILL.md   ← 执行者（仅大项目需要）

🛑 最大深度 3 层（references/ / scripts/ 不算层级）
```

#### 铁律 ②：TDD 驱动创建

```
NO SKILL WITHOUT A FAILING TEST FIRST

RED → GREEN → REFACTOR 循环:
  🔴 RED:     创建压力场景 → 用子代理运行（无技能）→ 记录违规
  🟢 GREEN:   编写最小技能 → 用子代理验证效果
  🔵 REFACTOR: 发现漏洞 → 修补 → 重新验证
```

#### 铁律 ③：CSO 技能发现优化

**❌ 错误示例**（description 写工作流）:
```
description: "执行计划时派发子代理，每个任务完成后进行代码审查"
→ Agent 只做一次审查（因为 description 说了"代码审查"）
→ 跳过流程图中的两阶段审查流程
```

**✅ 正确示例**（只写触发条件）:
```
description: "Use when executing implementation plans with independent tasks"
→ Agent 加载完整 SKILL.md
→ 按照流程图执行两阶段审查
```

**CSO 规则**:
- ✅ 以 `"Use when..."` 开头
- ✅ 只写触发条件，不总结工作流
- ✅ 包含关键词覆盖（skill / 技能 / SKILL.md / agent）
- ❌ 禁止 XML 角括号 `<>`
- 📏 长度：100-150 字符（max 1024）

---

## 🧭 智能路由表

当用户提出需求时，按以下规则路由：

### 单一意图路由

| 用户说... | → 调用子技能 | 文件路径 |
|-----------|-------------|---------|
| "创建/新建/从零/写一个技能" | 📦 Creator | [skills/skill-factory-creator/SKILL.md](skills/skill-factory-creator/SKILL.md) |
| "优化/加工/改进/精简/美化" | ⚙️ Processor | [skills/skill-factory-processor/SKILL.md](skills/skill-factory-processor/SKILL.md) |
| "检查/审计/合规/评分" | ⚙️ Processor | [skills/skill-factory-processor/SKILL.md](skills/skill-factory-processor/SKILL.md) |
| "发布/提交/版本/tag" | 📤 Publisher | [skills/skill-factory-publisher/SKILL.md](skills/skill-factory-publisher/SKILL.md) |
| "合并/拆分/整合/重组" | 🔗 Assembler | [skills/skill-factory-assembler/SKILL.md](skills/skill-factory-assembler/SKILL.md) |

### 复合场景路由

| 用户意图 | 执行顺序 | 说明 |
|---------|---------|------|
| 创建并发布 | creator → publisher | 先创建再发布 |
| 优化后发布 | processor → publisher | 先优化再发布 |
| 拆分后逐一发布 | assembler → creator(×N) → publisher(×N) | 拆分后再逐个处理 |
| 全量审计 | processor(逐个审计) | 审计所有技能 |

### 歧义处理

不确定用户意图时，**主动询问**：
> "您是想：a) 从零创建新技能 b) 优化已有技能 c) 发布新版本 d) 合并/拆分技能 e) 其他？"

---

## 📝 代码风格与规范

### SKILL.md 标准前言区模板

每个 SKILL.md **必须**包含标准前言区：

```yaml
---
name: {skill-name}           # kebab-case，≤50字符
version: v0.1.0              # 语义化版本
author: {author-name}
description: {100-150字符的描述，Use when... 开头}
tags: [{5-15个标签}]
dependency:
  parent: {父技能 或 none}
  children: [{子技能列表}]
---
```

### Commit 规范

| 类型 | 前缀 | 说明 |
|------|------|------|
| 新功能 | `feat:` | 新增功能或子技能 |
| 修复 | `fix:` | 修复问题 |
| 重构 | `refactor:` | 代码重构 |
| 文档 | `docs:` | 文档更新 |
| 格式 | `style:` | 代码格式调整 |
| 测试 | `test:` | 测试相关 |
| 构建 | `chore:` | 构建/工具相关 |

**示例**:
```bash
git commit -m 'feat: add code-reviewer skill with TDD validation'
git commit -m 'fix: resolve CSO violation in processor description'
git commit -m 'docs: update README with new architecture diagram'
```

### 版本判定规则

| 变更类型 | 版本升级 | Commit 前缀 |
|---------|---------|------------|
| Bug 修复 | patch +1 | `fix:` |
| 新功能 | minor +1 | `feat:` |
| 重构 | minor +1 | `refactor:` |
| 破坏性变更 | major +1 | `feat!:` |

---

## 🛠️ 常用命令速查

### 审计技能质量

```bash
# 审计单个技能（详细输出）
./skills/skill-factory-processor/scripts/audit.ps1 -Path ./skills/skill-factory-creator/SKILL.md -Verbose

# 项目级全量审计（生成 HTML 报告）
./skills/skill-factory-processor/scripts/audit.ps1 -Project -Html -Verbose

# 快速检查（仅输出分数）
./skills/skill-factory-processor/scripts/audit.ps1 -Project
```

### 测试验证

```bash
# 查看测试场景
cat tests/scenarios/skill-factory-creator/scenarios.yaml

# 运行特定技能的压力测试（需配合子代理）
# 参考: skills/skill-factory-creator/references/test-scenario-guide.md
```

### 发布流程

```bash
# 1. 更新版本号（在 SKILL.md 的前言区）
# 2. 更新 CHANGELOG.md
# 3. 提交更改
git commit -m 'release: v2.3.0'
git tag v2.3.0
git push origin main --tags
```

---

## ⚠️ 注意事项与禁忌

### ✅ 应该做的

- [ ] **先判定类型再动手**: 用四维分类法判断 Type 1-4，选错会导致返工
- [ ] **TDD 流程不可跳过**: 每个技能发布前必须经过 RED→GREEN→REFACTOR
- [ ] **CSO 优先**: description 只写触发条件，防止 Agent 走捷径
- [ ] **层级检查**: 每次添加目录时确认深度 ≤3 层
- [ ] **规范清单底线**: 发布前过一遍 8 项检查（见 [references/skill-standards.md](references/skill-standards.md)）
- [ ] **版本号同步**: 修改根文件时检查子技能版本号是否需要更新
- [ ] **子代理压力测试**: 用模拟高压力场景验证技能鲁棒性

### ❌ 绝对禁止的

- 🚫 **发布未经验证的技能**: 没有 TDD 记录的技能不允许进入发布流程
- 🚫 **超过 3 层的目录结构**: 发现立即拆分或征求用户同意
- 🚫 **description 中写工作流**: 违反 CSO 规则，导致 Agent 跳过正文
- 🚫 **跳过压力测试**: 即使是 Type 1 简单技能也必须验证
- 🚫 **随意修改根路由器**: SKILL.md 是路由器，只做请求分发
- 🚫 **忽略版本同步**: 导致版本分裂和维护困难

---

## 📚 关键文档索引

### 核心设计文档

| 文档 | 说明 | 路径 |
|------|------|------|
| **SKILL.md** | 主入口路由器 | [SKILL.md](SKILL.md) |
| **README.md** | 项目说明文档 | [README.md](README.md) |
| **设计原则** | 三大铁律 + 四维分类 + 设计模式 | [references/design-principles.md](references/design-principles.md) |
| **技能标准** | 8 项规范检查清单 | [references/skill-standards.md](references/skill-standards.md) |
| **写作规则** | 高级写作技巧 R1-R14 | [references/writing-rules.md](references/writing-rules.md) |
| **最佳实践** | 28 条最佳实践 | [references/best-practices.md](references/best-practices.md) |

### 子技能文档

| 子技能 | 职责 | 详细文档 |
|--------|------|---------|
| **Creator** | TDD 驱动创建 + 类型判定 | [skills/skill-factory-creator/SKILL.md](skills/skill-factory-creator/SKILL.md) |
| **Processor** | 4 种加工策略 + 审计引擎 | [skills/skill-factory-processor/SKILL.md](skills/skill-factory-processor/SKILL.md) |
| **Publisher** | 版本发布 + 退役流程 | [skills/skill-factory-publisher/SKILL.md](skills/skill-factory-publisher/SKILL.md) |
| **Assembler** | 合并 + 拆分策略 | [skills/skill-factory-assembler/SKILL.md](skills/skill-factory-assembler/SKILL.md) |

### 测试与质量保障

| 资源 | 说明 | 路径 |
|------|------|------|
| **Test Harness** | 100 个压力测试场景 | [tests/scenarios/](tests/scenarios/) |
| **审计脚本** | 100 分制质量审计 | [skills/skill-factory-processor/scripts/audit.ps1](skills/skill-factory-processor/scripts/audit.ps1) |
| **TDD 指南** | 测试驱动开发完整流程 | [skills/skill-factory-creator/references/tdd-guide.md](skills/skill-factory-creator/references/tdd-guide.md) |

---

## 🎯 复杂度分级参考

根据技能的工作步骤数标注难度：

| 级别 | 步骤数 | 适用场景 | 示例 |
|------|--------|---------|------|
| **basic** | <5 步 | 简单工具技能 | 代码格式化、文件重命名 |
| **intermediate** | 5-10 步 | 中等复杂度 | 技能创建、质量审计 |
| **advanced** | >10 步 | 复杂框架 | Skill Factory 本身 |

**当前项目复杂度**: advanced (Router + 4 子技能 + 100 测试场景)

---

## 🔄 典型工作流示例

### 示例 1：从零创建一个新技能

```
用户: "帮我创建一个代码审查技能"

Agent 工作流:
1. 📖 阅读 [creator/SKILL.md](skills/skill-factory-creator/SKILL.md)
2. 🔍 判定类型 → 轻(单功能) + 薄(<300行) → **Type 1**
3. 🔴 RED 阶段:
   - 创建压力场景（参考 test-scenario-guide.md）
   - 用子代理运行场景（无技能状态）
   - 记录违规行为和合理化借口
4. 🟢 GREEN 阶段:
   - 选择 Type 1 模板（参考 type-templates.md）
   - 编写 SKILL.md（遵循 CSO 规则）
   - 用子代理验证效果
5. 🔵 REFACTOR 阶段:
   - 发现新合理化借口
   - 添加明确漏洞修补
   - 重新测试直到通过
6. ✅ 规范检查:
   - 对照 skill-standards.md 8 项清单
   - 运行 audit.ps1 验证
7. 📤 发布（如需要）:
   - 调用 publisher 子技能
```

### 示例 2：审计现有技能质量

```
用户: "检查一下项目中所有技能的质量"

Agent 工作流:
1. 📖 阅读 [processor/SKILL.md](skills/skill-factory-processor/SKILL.md)
2. 🔧 运行审计脚本:
   ```bash
   ./skills/skill-factory-processor/scripts/audit.ps1 -Project -Html -Verbose
   ```
3. 📊 分析报告:
   - 检查各维度得分（目标 ≥85%）
   - 识别 P0/P1/P2 问题
4. 🔧 修复问题（如需要）:
   - 按优先级逐项修复
   - 重新审计验证
5. 📋 输出总结:
   - 项目平均分
   - 各技能评级
   - 改进建议
```

---

## 📈 质量标准体系

### 100 分制审计维度

| 维度 | 权重 | 检查项 |
|------|------|--------|
| **结构完整性** | 15% | 前言区/必备章节/层级合规 |
| **内容质量** | 20% | 任务目标/操作步骤/示例/注意事项 |
| **CSO 合规性** | 15% | description 规则/触发条件 |
| **TDD 验证** | 15% | 测试记录/压力场景/漏洞修补 |
| **链接有效性** | 10% | 内部引用无死链 |
| **格式规范** | 15% | 命名规范/YAML语法/Markdown格式 |
| **最佳实践** | 10% | Token效率/Happy Path/错误处理 |

### 评级标准

| 等级 | 分数范围 | 含义 |
|------|---------|------|
| **A-grade** | 90-100% | 优秀，可发布 |
| **B-grade** | 80-89% | 良好，小幅改进后可发布 |
| **C-grade** | 70-79% | 一般，需要显著改进 |
| **D-grade** | <70% | 不合格，必须重新设计 |

**当前项目平均**: **99% (A-grade)** ✅

---

## 💡 高级技巧与提示

### Token 效率优化

- **Happy Path First**: 90% 场景方案放最前面，边缘情况后置
- **Quickstart 覆盖端到端**: 快速开始示例要完整可运行
- **最小高信号 token 集**: 只保留关键信息，避免冗余

### 反模式防御

- **每个"不要"配"这样做"+失败原因**: 不要只说禁止，要解释为什么
- **显式拒绝 Agent 先验倾向**: 明确指出常见错误假设
- **二进制验证项**: Plan→Validate→Execute，每步都是通过/不通过

### 错误处理矩阵

| 异常类型 | 处理策略 | 反馈方式 | 重试策略 |
|---------|---------|---------|---------|
| **输入异常** | 参数校验 | 明确错误提示 | 引导用户修正 |
| **工具异常** | 降级方案 | 日志记录 | 自动切换备用方案 |
| **数据异常** | 数据清洗 | 跳过+警告 | 重新获取 |
| **权限异常** | 权限检查 | 申请权限提示 | 等待用户授权 |
| **超时异常** | 超时控制 | 进度保存 | 断点续传 |

---

## 🎓 学习路径建议

### 新手入门（首次接触项目）

1. 📖 阅读 [README.md](README.md) — 了解项目概览
2. 📖 阅读本文件（AGENTS.md）— 理解协作规范
3. 📖 阅读 [SKILL.md](SKILL.md) — 理解路由机制
4. 📖 阅读 [references/design-principles.md](references/design-principles.md) — 掌握三大铁律

### 日常开发（已熟悉项目）

1. 🎯 根据需求查阅对应子技能的 SKILL.md
2. 🔧 按照 TDD 流程执行（RED→GREEN→REFACTOR）
3. ✅ 运行 audit.ps1 验证质量
4. 📤 如需发布，调用 publisher 子技能

### 深入进阶（想贡献代码）

1. 📚 研究 Test Harness 的 100 个场景
2. 🔬 分析现有技能的设计模式
3. 💡 阅读 [references/best-practices.md](references/best-practices.md)
4. 🤝 按照 CONTRIBUTING.md 提交 PR

---

## 📞 故障排查

### 常见问题

| 问题 | 可能原因 | 解决方案 |
|------|---------|---------|
| **审计分数低** | 缺少必备章节/CSO违规/TDD缺失 | 对照 skill-standards.md 逐项检查 |
| **Agent 不加载技能** | description 未包含 "Use when" | 修复 CSO 合规性 |
| **层级超过 3 层** | 目录结构过深 | 拆分为独立技能或使用 references/ |
| **路由到错误子技能** | 触发词模糊 | 优化 SKILL.md 的路由表 |
| **测试场景失败** | 技能有漏洞 | 进入 REFACTOR 阶段修补 |

### 调试技巧

```bash
# 1. 查看详细审计日志
./skills/skill-factory-processor/scripts/audit.ps1 -Path ./your-skill/SKILL.md -Verbose

# 2. 检查特定维度
./skills/skill-factory-processor/scripts/audit.ps1 -Path ./your-skill/SKILL.md -Check CSO,TDD

# 3. 生成 HTML 报告（可视化问题）
./skills/skill-factory-processor/scripts/audit.ps1 -Project -Html
```

---

## 📊 项目统计信息

| 指标 | 数值 |
|------|------|
| **当前版本** | v2.2.0 |
| **项目平均分** | 99% (A-grade) |
| **TDD 覆盖率** | 100% (5/5 技能) |
| **测试场景数** | 100 (5 技能 × 20 场景) |
| **子技能数量** | 4 (creator/processor/publisher/assembler) |
| **架构模式** | 4-Entry Router |
| **复杂度级别** | Advanced |
| **最后审计日期** | 2026-05-30 |
| **最后更新日期** | 2026-05-30 |

---

## 🎯 总结：核心理念

> **AGENTS.md 回答的是 "HOW to work"（如何工作），不是 "WHAT is this"（这是什么）。**
>
> 它是你的**操作手册**，不是项目说明书。

**三大原则**:
1. 🔴 **TDD 优先**: 没有测试就没有技能
2. ⚖️ **架构约束**: 三层铁律不可妥协
3. 🎯 **CSO 优化**: 让 Agent 正确发现和使用技能

**工作口诀**:
```
先判定类型 → 再 TDD 验证 → 后规范检查 → 最后发布
```

---

<p align="center">
  <strong>Skill Factory v2.2 — 让 AI Agent 技能创建规范化、标准化、高质量化</strong>
</p>

<p align="center">
  <sub>版本: v2.2.0 | 架构: 4-Entry Router | 质量: 99% (A-grade) | TDD: 100%</sub>
</p>
