---
name: skill-factory-publisher
version: v0.5.1
author: skill-factory
description: 技能发布器 — 覆盖技能的版本发布与退役销毁全生命周期，包含语义化版本快速判定（fix/feat/refactor/breaking）、元数据批量同步更新、发布清单检查、标准化 git commit 与 tag 流程，以及弃用标记、迁移指引编写和 30 天缓冲期管理
tags: [skill-factory, publisher, publishing, versioning, destruction, git-commit, layer-1]
dependency:
  parent: skill-factory
  layer: 1
  phase: publishing
---
# 技能发布器

> **任务目标**: 帮助用户完成技能的版本发布、git 提交、退役销毁等生命周期末端操作。

覆盖技能全生命周期中的 **发布** 和 **销毁** 两个阶段。

---

## 触发条件

| 用户说 | 场景 |
|--------|------|
| "发布新版本" | 版本发布 |
| "提交这个技能" | git 提交 |
| "退役XX技能" | 技能退役 |
| "删除旧技能" | 技能销毁 |

---

## 操作步骤

### 一、发布流程

```
版本判定 → 元数据更新 → 发布清单 → git commit/tag
```

### Step 1: 版本判定

根据变更内容判定版本号变化。

| 变更类型 | 版本变化 | Commit 前缀 |
|---------|---------|------------|
| Bug 修复、文字修正 | patch +1 | `fix` |
| 新功能、新增章节 | minor +1 | `feat` |
| 大规模重构、结构变更 | minor +1 | `refactor` |
| 类型升级（Type 1→2 等） | minor +1 | `refactor` |
| 破坏性变更、接口删除 | major +1 | `feat!` |

**快速判定法**（按顺序检查）：
1. 是否破坏性？→ major +1
2. 是否类型升级？→ minor +1
3. 是否新增功能？→ minor +1
4. 是否仅修复？→ patch +1

### Step 2: 元数据更新

同步更新所有受影响的文件版本号。

**更新范围**：
- 根 SKILL.md → 新版本号
- 子技能 SKILL.md → 仅修改部分的需要更新
- references/*.md → 附加 `版本: vX.Y.Z` 标注
- CHANGELOG.md → 添加新版本条目

### Step 3: 发布清单

提交前确认：

| # | 检查项 |
|---|--------|
| 1 | 所有版本号已更新一致 |
| 2 | CHANGELOG 已添加条目 |
| 3 | 内部链接全部有效 |
| 4 | 无死链或引用不存在文件 |
| 5 | 所有 SKILL.md 前言区完整 |

### Step 4: Git 提交

```
git add {变更文件}
git commit -m "{prefix}: {简要描述}"
git tag vX.Y.Z
```

**Commit 消息格式**：
```
{type}: {简短描述}

{详细说明（可选）}

- 变更点 1
- 变更点 2
```

### 快速发布（Type 1 专用）

Type 1 技能跳过加工阶段，版本直接 minor +1：

```
Type 1 新建 → 版本 v0.1.0 → 快速发布 → 预计 5min
```

---

## 示例

### 发布一个修复版本

```
git add skills/code-reviewer/SKILL.md
git commit -m "fix: 修正审查报告中中文字段描述错误"
git tag v0.1.1
```

### 废弃一个旧技能

```yaml
---
name: old-deployer
version: v0.1.0
description: "[已废弃] 请迁移至: deploy-dev"
tags: [deprecated]
dependency:
  status: deprecated
  migration_target: deploy-dev
  deprecation_date: "2026-05-16"
---
```

---

## 二、销毁/退役流程

```
标记废弃 → 编写迁移指引 → 缓冲期（30天） → 归档/删除
```

### Step 1: 标记废弃

在 SKILL.md 前言区添加废弃标记：

```yaml
---
name: old-skill
version: v0.1.0
description: "[已废弃] 请迁移至: new-skill"
tags: [deprecated]
dependency:
  parent: skill-factory
  status: deprecated
  migration_target: new-skill
  deprecation_date: "2026-05-01"
---
```

### Step 2: 编写迁移指引

在废弃技能中添加迁移说明章节：

```markdown
## ⚠️ 已废弃

此技能已废弃，请迁移至 **[new-skill](../new-skill/SKILL.md)**。

### 迁移对照

| 旧操作 | 新操作 |
|--------|--------|
| 旧用法 A | 新用法 A |
| 旧用法 B | 新用法 B |
```

### Step 3: 缓冲期管理

- 废弃后保留 **30 天**缓冲期
- 期间保留文件但标记为 deprecated
- 缓冲期后可归档或删除

### Step 4: 清理

- 归档：移至 `archive/` 目录
- 删除：直接移除所有文件，更新 CHANGELOG

---

## 版本号对照速查

| 当前版本 | Fix | Feat/Refactor | Breaking |
|---------|-----|---------------|----------|
| v0.1.0 | v0.1.1 | v0.2.0 | v1.0.0 |
| v0.4.5 | v0.4.6 | v0.5.0 | v1.0.0 |
| v1.2.3 | v1.2.4 | v1.3.0 | v2.0.0 |

---

## ⚠️ 注意事项

- **版本一致性**：修改技能后务必同步更新所有受影响文件的版本号，避免出现根文件 v0.5.1 但子技能 v0.5.0 的版本分裂
- **破坏性变更**：任何删除接口、重命名目录、改动 dependency.parent 的行为都属于破坏性变更，必须升级主版本号
- **退役不可逆**：废弃标记一旦加上不要轻易移除，宁可新建替代技能也不要复用废弃技能名
- **缓冲期作用**：30 天缓冲期是为了给依赖方迁移时间，在此期间保持废弃文件可读但标记 deprecated

---

> 📖 设计原理: [../../references/design-principles.md](../../references/design-principles.md)  
> 📋 规范清单: [../../references/skill-standards.md](../../references/skill-standards.md)  
> ✍️ 写作规则: [../../references/writing-rules.md](../../references/writing-rules.md)