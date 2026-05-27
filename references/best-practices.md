# 📚 Skill Factory 最佳实践大全 v3.0

> **定位**: 全项目知识导航枢纽 — 一站式速查 + 深度文档索引
> **版本**: v4.0.0 | **更新**: 2026-05-27
> **原则**: 速查在此，深读在链接

---

## 🔗 文档地图 (v2.0)

```
skill-factory/
├── SKILL.md                              ← 路由器入口 (~121行, 4-Entry Router)
├── skills/                               ← Layer 1: 4个独立子技能
│   ├── skill-factory-creator/            ← 📦 创建 (自含 refs)
│   │   ├── SKILL.md                      ←    协调器 (~180行)
│   │   └── references/
│   │       ├── tdd-guide.md              ←    TDD 完整指南
│   │       └── type-templates.md         ←    Type 1-4 模板库
│   ├── skill-factory-processor/         ← ⚙️ 加工+审计 (自含 refs+scripts)
│   │   ├── SKILL.md                      ←    双模式协调器 (~160行)
│   │   ├── references/
│   │   │   ├── strategies.md             ←    4种加工策略
│   │   │   └── audit-criteria.md         ←    100分审计细则
│   │   └── scripts/
│   │       └── audit.ps1                 ←    自动化审计脚本
│   ├── skill-factory-publisher/         ← 📤 发布+退役
│   │   └── SKILL.md                      ←    单文件 (~130行, 手动触发)
│   └── skill-factory-assembler/          ← 🔗 合并+拆分
│       └── SKILL.md                      ←    单文件 (~150行)
├── examples/                             ← 示例技能库
│   ├── git-commit-helper/                ←    Type 1 示例
│   └── devops-toolkit/                   ←    Type 2 示例
└── references/                           ← 全局共享参考 (L3 按需加载)
    ├── best-practices.md                 ← 本文件: 导航枢纽 (你在这里)
    ├── design-principles.md              ← 铁律 + 四维分类 + 三级加载系统
    ├── skill-standards.md                ← 100分评分体系 + CSO 规则
    └── writing-rules.md                  ← R1-R14 高级写作规则
```

| 文档 | 核心问题 | 目标读者 | 紧急度 |
|------|---------|---------|--------|
| design-principles | 技能该用什么结构？ | 所有技能作者 | ⭐⭐⭐⭐⭐ |
| skill-standards | 我的技能合格吗？ | 发布前审计 | ⭐⭐⭐⭐⭐ |
| writing-rules | 怎么写出高质量内容？ | 内容编写者 | ⭐⭐⭐⭐ |

---

## ⚡ 30 秒速查卡

### 创建技能最小清单

```
✅ 前言区: name/version/description(Use when...)/tags
✅ CSO: description 只写触发条件，100-150字符
✅ 铁律: 先 RED(压力测试) 再写技能
✅ 层级: 目录深度 ≤3 层
✅ 章节: 任务目标 / 操作步骤 / 示例 / 注意事项
```

### 四维分类快判

| | 轻(单功能) | 重(多模块) |
|---|---|---|
| **薄(<300行)** | Type 1: 单文件 | Type 2: +skills/ |
| **厚(>300行)** | Type 3: +references/ | Type 4: +skills/ + references/ |

### 版本判定

```
修复 → patch+1 (`fix`) | 新增/重构 → minor+1 (`feat`/`refactor`) | 破坏性 → major+1 (`feat!`)
```

### 路由速查

```
创建/优化 → creator | 发布/退役 → publisher | 合并/拆分 → assembler | 审计 → skill-standards
```

---

## 🏗️ 核心原则（来自 design-principles.md）

### 三层铁律

> 所有技能目录深度 ≤3 层。不可妥协。

```
Layer 0: SKILL.md (路由器) → Layer 1: skills/ (子技能) → Layer 2: references/ (参考)
```

超过 3 层? → 拆分为独立技能族 或 征求用户同意后标记 `depth: N` + `layer-warning`

### Router 模式 (v2.0 采用)

根文件 = **轻量路由器**（~121行），详细逻辑在各子技能中，每个子技能完全自含

---

## ✅ 质量门禁（来自 skill-standards.md）

### 100 分评分体系 — Top 8 关键项

| # | 检查项 | 权重 | 通过标准 | 扣分 |
|---|--------|------|---------|------|
| 1 | **CSO description** | **15分** | Use when开头, 只写触发条件 | -5/违规 |
| 2 | **TDD 验证** | **15分** | 有压力测试记录或豁免说明 | -15/缺失 |
| 3 | 前言区完整 | 10分 | name/version/description/tags | -2/项 |
| 4 | 必备章节 | 10分 | 目标/步骤/示例/注意事项 | -2.5/项 |
| 5 | 层级合规 | 10分 | ≤3层 | -10/超标 |
| 6 | description长度 | 10分 | 50-1024字符(官方规格), 含触发短语 | -5/超限 |
| 7 | 命名规范 | 5分 | kebab-case | -5/违规 |
| 8 | 链接有效 | 5分 | 无死链 | -1/个 |

> 📖 完整 100 分清单: [skill-standards.md](./skill-standards.md)

---

## ✍️ 写作 essentials（来自 writing-rules.md）

### Top 5 规则（覆盖 80% 场景）

| 规则 | 一句话 |
|------|--------|
| **R1 Gotchas** | 写具体陷阱，不写泛泛提醒（"WHERE条件不能省" > "注意SQL安全"） |
| **R2 反模式** | 每个"不要"配"这样做"+失败原因（Agent会catch-all吞异常→分类处理） |
| **R3 Happy Path** | 90%场景放最前面，边缘后置 |
| **R4 验证循环** | Plan→Validate→Execute，验证项必须是二进制通过/不通过 |
| **R5 Token 效率** | 删除低信号内容，每行都要有决策价值 |

> 📖 完整 R1-R10: [writing-rules.md](./writing-rules.md)

---

## 🎯 子技能设计（v2.0 架构）

### 4-Entry Router 原则

> **按用户操作类型划分，非技术阶段**: 创建(creator) / 加工(processor) / 发布(publisher) / 整合(assembler)

### 决策速查

```
功能数=1 且 <300行? → Type 1, 不需要子技能
功能数>1 或 >300行? → 需要 skills/ 子技能目录
  └─ 按用户操作类型划分为 2-4 个独立子技能
  └─ 每个子技能完全自含 (SKILL.md + references/ + scripts/)
```

> 📖 详细模板: [../skills/skill-factory-creator/references/type-templates.md](../skills/skill-factory-creator/references/type-templates.md)

---

## 📐 TDD + CSO 双引擎

### TDD 铁律

```
NO SKILL WITHOUT A FAILING TEST FIRST
RED(观察失败) → GREEN(编写最小技能) → REFACTOR(修补漏洞) → ✅
```

### CSO 铁律 (agentskills.io v2025.12 规格)

```
description = 触发条件 ONLY（Use when... 开头）
官方上限: 1024 字符（充分利用空间覆盖触发短语）
格式: [功能描述]. Use when [短语1], [短语2], or [短语3].
禁止: XML角括号 < > （可能注入系统提示）
```

> 📖 TDD详情: [../skills/skill-factory-creator/references/tdd-guide.md](../skills/skill-factory-creator/references/tdd-guide.md)
> 📖 CSO详情: [skill-standards.md](./skill-standards.md)
> 📖 官方规格: [agentskills.io/specification](https://agentskills.io/specification)

---

## 🔄 三级渐进加载系统 (Progressive Disclosure)

> **来源**: agentskills.io 官方规范 + SKILL.md Pattern 实战验证
>
> 这是 Skill 可扩展的核心架构。理解它就能解释"为什么我的技能不触发"和"为什么上下文爆了"。

```
┌─────────────────────────────────────────────────────────────┐
│                    三级加载架构                              │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  L1: Metadata (~100 tokens/skill)                          │
│  ├─ 始终加载 → 系统提示中                                  │
│  ├─ 内容: name + description                               │
│  ├─ 作用: Agent 决定"是否激活此技能"                       │
│  └─ 💡 技能数量无限制，token 开销极小                      │
│                         ↓ 触发匹配                           │
│  L2: Instructions (<5000 tokens)                           │
│  ├─ 按需加载 → 读取完整 SKILL.md                           │
│  ├─ 内容: 核心操作步骤 + 引用路径                          │
│  ├─ 作用: Agent 知道"怎么做"                              │
│  └─ 💡 建议 <500 行, <5k tokens                            │
│                         ↓ 引用 references/               │
│  L3: Referenced Files & Scripts (按需)                   │
│  ├─ 懒加载 → 仅在需要时读取                                │
│  ├─ 内容: 详细参考文档 / 可执行脚本                        │
│  ├─ 作用: 提供深度知识 / 执行自动化操作                     │
│  └─ 💡 数量不限，idle 时零 token 开销                     │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### Token 预算指南

| 层级 | 加载时机 | Token 预算 | 你应该放什么 |
|------|---------|-----------|-------------|
| **L1** | 启动时 | ~100/skill | name + 高质量 description |
| **L2** | 触发时 | <5,000 | 核心流程 + 决策逻辑 + 引用指针 |
| **L3** | 按需 | 不限 | API 文档 / 详细标准 / 模板 / 脚本 |

### 关键设计原则 (来自 agentskills.io best-practices)

| 原则 | 说明 | 反模式 |
|------|------|--------|
| **加 Agent 缺少的，省略 Agent 已知的** | 不需要解释什么是 PDF、HTTP、数据库 | 用 10 行解释通用概念 |
| **设计内聚单元** | 一个技能 = 一个连贯的工作单元 | 一个技能既做查询又做管理 |
| **适度细节** | 过于全面反而有害 — Agent 难以提取相关内容 | 覆盖所有边缘情况 |
| **脆弱度匹配精度** | 操作精密→指令性；操作灵活→自由度 | 所有部分同样详细 |
| **提供默认值而非菜单** | 选一个默认方案，提替代方案 | 列出 5 个平等选项让 Agent 选 |
| **过程优于声明** | 教"怎么思考一类问题"而非"这个任务怎么做" | 写死具体答案 |

---

## 🧠 新增高级模式 (来自业界最佳实践)

### Plan-Validate-Execute (PVE)

对批量或破坏性操作，强制中间计划验证：

```
1. PLAN   → 创建结构化计划文件
2. VALIDATE → 对照源真值验证计划
3. EXECUTE → 仅验证通过后执行
```

### Memory Protocol (跨会话记忆)

```
会话开始时:
  - 读 AGENT_MEMORY.md (如有)
  - 读 project-state.json (当前状态)
  - 向用户汇报上次进度

会话结束/存档时:
  - 更新 AGENT_MEMORY.md (关键决策)
  - 更新 project-state.json (当前状态)
  - 记录阻塞项和待解决问题
```

---

## 📊 项目统计 v2.0.0

| 维度 | 数值 |
|------|------|
| 根 SKILL.md | ~121 行 (4-Entry Router 轻量路由器) |
| 子技能数 | **4** (creator / processor / publisher / assembler) |
| 子技能 references | 4 个 (tdd-guide, type-templates, strategies, audit-criteria) |
| 子技能 scripts | 1 个 (audit.ps1 在 processor 中) |
| 全局参考文档 | **4 个** (design-principles/skill-standards/writing-rules/best-practices) |
| 示例技能 | 3 个 (Type1 git-commit-helper + Type2 devops-toolkit) |
| 总项目行数 | ~4800 行 (清理后) |
| 最大层级深度 | **2 层** ✅ (root → skills/ = Layer 0 → Layer 1) |
| 架构模式 | **4-Entry Router Architecture (Type 4)** |

> 🔄 **v1.0.0 → v2.0.0 变更**: 从统一技能模式(单文件428行)重构为 4-Entry Router 架构(路由器121行 + 4个自含子技能)。按用户操作类型划分(创建/加工/发布/整合)，每个子技能完全自含(references/scripts/assets)。审计归属processor，publisher加手动触发。

---

## 🔄 常见工作流索引（v2.0 更新）

| 你想做什么 | 读什么 | 调用什么 |
|-----------|-------|---------|
| 从零创建技能 | creator(类型判定+TDD+模板) | `/creator` |
| 优化已有技能 | processor(4种策略) | `/processor` |
| 审计技能质量 | processor(100分评分) | `/processor` + audit.ps1 |
| 发布/退役技能 | publisher(semver+git流程) | `/publisher` (手动触发) |
| 合并/拆分技能 | assembler(3模式×3维度) | `/assembler` |
| 发布前自检 | skill-standards(100分清单) | 直接对照或 `/processor` |
| 理解架构设计 | design-principles(三层铁律+四维分类) | 仅阅读 |
| 学习写作规则 | writing-rules(R1-R14) | 仅阅读 |

---

> 💡 **使用建议**: 日常开发用本文件速查即可。需要深入某主题时点击对应链接。
> 🔄 **同步策略**: 当任何参考文档更新时，检查本文件的速查卡是否需要同步更新。
