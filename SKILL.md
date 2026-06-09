---
name: skill-factory
version: v2.2.0
author: skill-factory
description: "Use when creating, editing, optimizing, validating, auditing, publishing, merging, or splitting AI Agent skills and SKILL.md files. Triggers on \"create a skill\", \"write SKILL.md\", \"optimize this skill\", \"check if compliant\", \"skill factory\", \"audit skill\", \"TDD for skills\", \"publish skill\", \"merge skills\", \"split skills\", \"deprecate skill\", or \"retire skill\". A meta-skill for complex skill lifecycle management with agentskills.io standard compliance"
tags: [skill-factory, skill-creation, tdd-driven, skill-optimization, skill-publishing, skill-auditing, merging, splitting]
dependency:
  parent: none
  structure: "Type 4 (重+厚): Router + 4 sub-skills + references/"
  pattern: "4-Entry Router Architecture"
meta:
  complexity: advanced
  last_audit_date: "2026-05-30"
  version_history: "v1.0(unified) → v2.0(4-entry-router)"
  tdd: validation-only
  tdd_waiver_reason: "路由器型技能（Router Pattern），仅做请求分发不含具体操作逻辑。详细验证在各子技能中执行"
  tdd_waiver_date: "2026-05-30"
---
# Skill Factory v2.0 — 技能工坊 (Router Edition)

> **定位**: 轻量路由枢纽 — 分发请求到 4 个独立子技能
> **架构**: 4-Entry Router (Layer 0 → Layer 1)

## 职责

| ✅ 负责 | ❌ 不负责 |
|---------|----------|
| 智能路由请求到 4 个子技能 | 具体操作步骤 → 各子技能负责 |
| 提供全局速查（铁律/分类/CSO规则） | 审计/加工 → `/processor` |
| 展示项目结构和子技能概览 | 创建/发布/整合 → 对应子技能 |

## 速查

**三大铁律**: ① 层级 ≤3 层 ② 无技能不 TDD（先测试后技能） ③ description 只写 CSO 触发条件

**四维分类**: | | 轻(单功能) | 重(多模块) |
|---|---|---|
| **薄**(<300行) | Type 1: 单文件 | Type 2: +skills/ |
| **厚**(>300行) | Type 3: +references/ | Type 4: +skills/ + references/ |

**CSO 规则**: `"Use when..."` 开头，max 1024 字符，禁止 XML 角括号

## 🧭 路由

| 用户说... | 调用 | 职责 |
|-----------|------|------|
| 创建/新建/从零写一个 | `/creator` | 从零创建新技能 |
| 优化/加工/改进/重构/审计/合规 | `/processor` | 加工或审计已有技能 |
| 发布/提交/版本/tag/退役 | `/publisher` (手动) | 发布或退役技能 |
| 合并/拆分/整合/重组 | `/assembler` | 多技能操作 |

**复合场景**: 创建→发布 → creator→publisher；优化→发布 → processor→publisher；拆分的子技能 → assembler→creator(×N)→publisher(×N)

**歧义处理**: 提供选项菜单引导用户选择子技能

## 📂 子技能

| 子技能 | 职责 | 触发 | 关键文件 |
|--------|------|------|---------|
| [creator](skills/skill-factory-creator/SKILL.md) | 创建新技能 | `/creator` | TDD+类型判定+模板 |
| [processor](skills/skill-factory-processor/SKILL.md) | 加工+审计 | `/processor` | 4策略+审计脚本 |
| [publisher](skills/skill-factory-publisher/SKILL.md) | 发布+退役 | `/publisher` | Semver+Git+退役 |
| [assembler](skills/skill-factory-assembler/SKILL.md) | 合并+拆分 | `/assembler` | 合并/拆分模式 |

## 📂 项目结构

```
skill-factory/
├── SKILL.md                                   ← 路由器
├── references/                                ← 全局共享参考
│   ├── best-practices.md / design-principles.md / writing-rules.md / routing-engine.md
└── skills/                                    ← 4个自含子技能
    ├── skill-factory-creator/  (SKILL.md + references/)
    ├── skill-factory-processor/ (SKILL.md + references/ + scripts/)
    ├── skill-factory-publisher/ (SKILL.md + references/)
    └── skill-factory-assembler/ (SKILL.md + references/)
```

## ⚠️ 约束

1. **根文件仅做路由** — 详细逻辑在各子技能
2. **子技能自含** — 每个有独立 description，Agent 可独立触发
3. **全局 references/** — 仅放跨子技能公共内容
4. **职能不重叠** — 审计→processor，发布→publisher，创建→creator

## 版本历史

| 版本 | 日期 | 变更 |
|------|------|------|
| **v2.2.0** | 2026-05-30 | 新增 TDD 验证记录（Router Pattern Validation）；100场景级联验证 |
| **v2.0.0** | 2026-05-27 | 4-Entry Router 架构：按创建/加工/发布/整合划分，子技能自含 |