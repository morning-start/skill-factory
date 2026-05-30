---
name: skill-factory
version: v2.1.0
author: skill-factory
description: Use when creating, editing, optimizing, validating, auditing, publishing, merging, or splitting AI Agent skills and SKILL.md files. Triggers on "create a skill", "write SKILL.md", "optimize this skill", "check if compliant", "skill factory", "audit skill", "TDD for skills", "publish skill", "merge skills", "split skills", "deprecate skill", or "retire skill". A meta-skill for complex skill lifecycle management with agentskills.io standard compliance
tags: [skill-factory, skill-creation, tdd-driven, skill-optimization, skill-publishing, skill-auditing, merging, splitting]
dependency:
  parent: none
  structure: "Type 4 (重+厚): Router + 4 sub-skills + references/"
  pattern: "4-Entry Router Architecture"
meta:
  complexity: advanced
  last_audit_date: "2026-05-27"
  version_history: "v1.0(unified) → v2.0(4-entry-router)"
  tdd: validation-only
  tdd_waiver_reason: "路由器型技能（Router Pattern），仅做请求分发不含具体操作逻辑。详细验证在各子技能中执行"
  tdd_waiver_date: "2026-05-30"
---
# Skill Factory v2.0 — 技能工坊 (Router Edition)

> **定位**: 轻量路由枢纽 — 将用户请求分发到 4 个独立子技能
> **架构**: 4-Entry Router (root → skills/ = Layer 0 → Layer 1)

## 目标

将 skill-factory 的完整能力（创建/加工/发布/整合）通过轻量路由器统一入口分发，让用户无论从哪个角度进入都能快速到达正确的子技能。

**能做什么**:
- 智能路由用户请求到 4 个自含型子技能
- 提供全局速查（铁律/分类/CSO规则）
- 展示项目结构和子技能概览

**不能做什么**:
- 不包含具体操作步骤（各子技能负责）
- 不执行审计或加工（→ `/processor`）

## 🎯 核心原则（速查）

```
┌─────────────────────────────────────────────┐
│           三大铁律                           │
├─────────────────────────────────────────────┤
│ ① 层级 ≤3 层 (references/scripts/assets 不算) │
│ ② NO SKILL WITHOUT FAILING TEST FIRST (TDD)   │
│ ③ description 只写触发条件 (CSO)             │
└─────────────────────────────────────────────┘
```

**四维分类速查**：

| | **轻**(单功能) | **重**(多模块) |
|---|---|---|
| **薄** (<300行) | Type 1: 单文件 | Type 2: +skills/ |
| **厚** (>300行) | Type 3: +references/ | Type 4: +skills/ + references/ |

**CSO 规则**: description 含 "Use when..."，max 1024 字符，禁止 XML 角括号

---

## 🧭 智能路由

```
用户说...                    → 调用
─────────────────          ──────────────────────────
"创建/新建/从零/写一个"    → 📦 /creator      (创建新技能)
"优化/加工/改进/精简/美化" → ⚙️ /processor    (加工已有技能)
"检查/审计/合规/评分"     → ⚙️ /processor    (审计已有技能)
"发布/提交/版本/tag"      → 📤 /publisher    (发布或退役)
"合并/拆分/整合/重组"     → 🔗 /assembler    (多技能操作)
```

### 复合场景

| 用户意图 | 执行顺序 |
|---------|---------|
| 创建并发布 | creator → publisher |
| 优化后发布 | processor → publisher |
| 拆分后逐一发布 | assembler → creator(×N) → publisher(×N) |
| 全量审计所有技能 | processor(逐个审计) |

### 歧义处理

不确定用户意图时，提供选项菜单：
> "您是想：a) 从零创建新技能 b) 优化已有技能 c) 发布 d) 其他？"

---

## 📂 子技能一览

| 子技能 | 职责 | 独立可用 | 关键文件 |
|--------|------|---------|---------|
| **[creator](skills/skill-factory-creator/SKILL.md)** | 创建新技能 | ✅ `/creator` | TDD流程+类型判定+模板 |
| **[processor](skills/skill-factory-processor/SKILL.md)** | 加工+审计已有技能 | ✅ `/processor` | 4种策略+审计脚本+评分 |
| **[publisher](skills/skill-factory-publisher/SKILL.md)** | 发布+退役 | ✅ `/publisher` (手动触发) | 版本判定+git+退役 |
| **[assembler](skills/skill-factory-assembler/SKILL.md)** | 合并+拆分 | ✅ `/assembler` | 序列/并行/嵌套模式 |

> 每个子技能完全自含：独立的 description、references/、scripts/、assets/

---

## 📂 项目结构

```
skill-factory/
├── SKILL.md                              ← 本文件 (路由器 ~150行)
├── examples/                             ← 示例库 (Type1/Type2)
├── references/                           ← 全局共享参考
│   ├── best-practices.md                 ← 知识导航枢纽
│   ├── design-principles.md              ← 铁律+分类+三级加载系统
│   ├── writing-rules.md                  ← R1-R14 写作规则
│   └── routing-engine.md                 ← 路由引擎详细版
└── skills/                               ← Layer 1: 4个独立子技能
    ├── skill-factory-creator/            ← 📦 创建 (自含 refs+scripts)
    ├── skill-factory-processor/         ← ⚙️ 加工+审计 (自含 refs+scripts+audit.ps1)
    ├── skill-factory-publisher/         ← 📤 发布+退役
    └── skill-factory-assembler/          ← 🔗 合并+拆分
```

---

## ⚠️ 注意事项

- **子技能优先**: 根文件仅做路由，详细逻辑在各子技能中
- **每个子技能可独立使用**: 有自己的 description，Agent 可直接触发
- **全局 references/ 仅放跨子技能公共内容**: 写作规则/设计原则等
- **职能归属明确**: 审计在 processor，发布在 publisher，创建在 creator

---

## 版本历史

| 版本 | 日期 | 变更 |
|------|------|------|
| **v2.1.0** | 2026-05-30 | **Test Harness 集成 + 质量提升**: 新增 TDD 豁免说明（路由器型技能）；processor 升级至 v2.3.0 并新增 CI/CD 集成能力；补充 Test Harness & Harness.io 对接指南；修复部分模块的合规性问题 |
| **v2.0.0** | 2026-05-27 | **4-Entry Router 架构**: 基于真实案例(官方文档/博客/GitHub)重新设计；子技能按用户操作类型划分(创建/加工/发布/整合)；每个子技能完全自含(references/scripts/assets)；用references/替代Workers；审计归属processor；publisher加手动触发 |
| v1.0.0 | 2026-05-27 | 统一技能模式(已废弃) |
| v0.9.0 | 2026-05-27 | Hub Edition (已废弃) |
