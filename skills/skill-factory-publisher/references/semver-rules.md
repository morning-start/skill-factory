# Semver 版本判定规则

> **来源**: [../SKILL.md](../SKILL.md) → 第二步：版本判定
> **何时读取**: 需要判定版本号升级方式时

---

## 版本格式

```
MAJOR.MINOR.PATCH (如 2.1.3)

MAJOR (主版本): 不兼容的 API 变化
MINOR (次版本): 向后兼容的功能新增
PATCH (修订版): 向后兼容的问题修正
```

## 版本判定规则

| 变更类型 | 版本变化 | Commit 前缀 | 示例 |
|---------|---------|------------|------|
| Bug 修复、文字修正、小改进 | **patch +1** | `fix` | `1.0.0` → `1.0.1` |
| 新功能、新增章节、非破坏性重构 | **minor +1** | `feat` 或 `refactor` | `1.0.0` → `1.1.0` |
| 破坏性变更、接口删除、类型升级 | **major +1** | `feat!` | `1.0.0` → `2.0.0` |

## 快速判定流程

```
有破坏性变更？
├── 是 → major +1 (如 1.x → 2.x)
└── 否 → 有新功能？
         ├── 是 → minor +1 (如 1.0 → 1.1)
         └── 否 → patch +1 (如 1.0 → 1.0.1)
```

## 特殊情况

| 情况 | 处理方式 |
|------|---------|
| 首次发布 | `0.1.0` (初始版本) |
| 预发布/Alpha | `0.x-alpha` (预发布版本) |
| 实验性功能 | `0.x-beta.N` (beta 版本) |
| 多个 patch 积累 | 可直接跳到下一个 minor |
| 大重构但兼容 | `minor +1` + 在 changelog 标注 "refactor" |

## Front Matter 更新模板

```yaml
---
name: {skill-name}              # 不变
version: "{新版本号}"           # ← 更新此项
author: {author}                # 不变
description: {...}              # 通常不变（除非触发条件变了）
tags: [...]                     # 如有新能力可添加
dependency:
  parent: {parent}              # 不变
meta:
  last_audit_date: "{今天日期}" # ← 更新审计日期
  version_history: "..."        # ← 追加新版本记录
---
```
