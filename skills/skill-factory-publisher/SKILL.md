---
name: skill-factory-publisher
version: v2.0.0
author: skill-factory
description: Use when publishing, releasing, versioning, tagging, or retiring AI Agent skills. Triggers on "publish skill", "release skill", "version bump", "git tag", "deprecate skill", "retire skill", or "skill lifecycle". Handles semver version judgment, git commit/tag workflow, changelog generation, and deprecation procedures
tags: [skill-publishing, version-management, git-workflow, deprecation, skill-lifecycle, skill-factory]
dependency:
  parent: skill-factory
  structure: "Type 1 (轻+薄): 单文件"
  pattern: "Publisher (Manual Trigger)"
meta:
  complexity: basic
  standalone: true
  can_invoke_directly: true
  disable-model-invocation: true
---
# 📤 Skill Factory Publisher — 技能发布器 v2.0

> **定位**: 技能发布与退役的生命周期管理器
> **架构**: 单文件自含型子技能（可独立通过 `/publisher` 手动触发）
> **特殊属性**: `disable-model-invocation: true` — 仅手动触发，不自动激活

---

## ⚠️ 重要：手动触发 Only

本技能设置了 **`disable-modelInvocation: true`**，意味着：

- ✅ **可以** 通过 `/publisher` 命令手动触发
- ❌ **不会** 被 Agent 自动激活（即使 description 匹配）
- **原因**: 发布是破坏性操作，必须用户明确意图后才执行

### 触发方式

```bash
# 用户显式调用
/publisher

# 或在对话中明确说：
"请发布这个技能"
"帮我打一个版本 tag"
"这个技能需要退役了"
```

---

## 🎯 职责范围

| ✅ 负责 | ❌ 不负责 |
|---------|----------|
| 版本号判定与升级 | 从零创建技能 → `/creator` |
| Git commit 规范 | 优化/审计技能 → `/processor` |
| Git tag 与发布流程 | 合并/拆分技能 → `/assembler` |
| 技能退役与弃用流程 | 代码编写或测试 |

---

## 🔄 发布流程总览

```
┌─────────────────────────────────────────────────────────────┐
│                    技能发布流水线                              │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ① 变更分析 → ② 版本判定 → ③ 更新文件  → ④ Git Commit     │
│    (3min)      (2min)        (5min)        (3min)            │
│                                                             │
│  ⑤ 生成 Changelog → ⑥ Git Tag → ⑦ 推送 → ✅ 完成          │
│       (3min)          (2min)      (2min)                    │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

## 第一步：变更分析（3 min）

### 1.1 收集变更信息

在发布前，必须明确本次变更的内容：

```markdown
## 变更收集清单

### 变更类型判断
本次变更属于哪种类型？

- [ ] **Bug 修复**: 修复了错误或问题
- [ ] **新功能**: 新增了能力或章节
- [ **重构**: 调整了结构或组织方式（功能不变）
- [ ] **破坏性变更**: 删除了功能或改变了接口

### 变更内容清单
1. {变更项1}
2. {变更项2}
3. {变更项3}

### 影响范围
- 影响了哪些用户？{描述}
- 是否需要迁移指南？{是/否}
- 是否向后兼容？{是/否}
```

### 1.2 输出：变更摘要

```yaml
changes:
  - type: {fix/feat/refactor/feat!}
    description: "{变更描述}"
    scope: "{影响范围}"
breaking_change: {true/false}
migration_needed: {true/false}
```

---

## 第二步：版本判定（2 min）

### 2.1 Semver 版本规范

```
版本格式: MAJOR.MINOR.PATCH (如 2.1.3)

MAJOR (主版本): 不兼容的 API 变化
MINOR (次版本): 向后兼容的功能新增
PATCH (修订版): 向后兼容的问题修正
```

### 2.2 版本判定规则

| 变更类型 | 版本变化 | Commit 前缀 | 示例 |
|---------|---------|------------|------|
| Bug 修复、文字修正、小改进 | **patch +1** | `fix` | `1.0.0` → `1.0.1` |
| 新功能、新增章节、非破坏性重构 | **minor +1** | `feat` 或 `refactor` | `1.0.0` → `1.1.0` |
| 破坏性变更、接口删除、类型升级 | **major +1** | `feat!` | `1.0.0` → `2.0.0` |

### 2.3 快速判定流程

```
有破坏性变更？
├── 是 → major +1 (如 1.x → 2.x)
└── 否 → 有新功能？
         ├── 是 → minor +1 (如 1.0 → 1.1)
         └── 否 → patch +1 (如 1.0 → 1.0.1)
```

### 2.4 特殊情况

| 情况 | 处理方式 |
|------|---------|
| 首次发布 | `0.1.0` (初始版本) |
| 预发布/Alpha | `0.x-alpha` (预发布版本) |
| 实验性功能 | `0.x-beta.N` (beta 版本) |
| 多个 patch 积累 | 可直接跳到下一个 minor |
| 大重构但兼容 | `minor +1` + 在 changelog 标注 "refactor" |

---

## 第三步：更新文件（5 min）

### 3.1 更新 SKILL.md Front Matter

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

### 3.2 更新版本历史章节

如果 SKILL.md 有版本历史章节，追加新条目：

```markdown
## 版本历史

| 版本 | 日期 | 变更 |
|------|------|------|
| **{新版本}** | {日期} | **{变更摘要}** |
| {旧版本} | {日期} | {变更摘要} |
| ... | ... | ... |
```

### 3.3 生成/更新 CHANGELOG.md（如有）

```markdown
# Changelog

All notable changes to this project will be documented in this file.

## [{新版本}] - {YYYY-MM-DD}

### Added (新增)
- {新功能1}
- {新功能2}

### Changed (变更)
- {改动1}

### Fixed (修复)
- {bug1}

### Removed (删除)
- {移除的功能} (BREAKING if applicable)

---

## [{旧版本}] - {YYYY-MM-DD}
...
```

---

## 第四步：Git Commit（3 min）

### 4.1 Conventional Commits 规范

```
格式: {type}({scope}): {subject}

type 类型:
  feat:     新功能
  fix:      bug 修复
  docs:     文档变更
  style:    格式调整（不影响代码）
  refactor: 重构（不是新功能也不是修bug）
  perf:     性能优化
  test:     测试相关
  chore:    构建/工具/辅助工具的变动
  feat!:    破坏性变更（注意 !）

scope（可选）: 影响范围
subject: 简短描述（英文，首字母不大写，不加句号）
```

### 4.2 Commit Message 模板

**常规提交**：

```bash
git commit -m "feat(skill): add TDD validation workflow

- Add RED/GREEN/REFACTOR phases
- Include pressure scenario templates
- Add waiver exemption criteria

Closes #123"
```

**破坏性变更**：

```bash
git commit -m "feat!(skill): restructure to router architecture

BREAKING CHANGE: Sub-skills now use new routing format.
Migration guide: see MIGRATION.md"
```

**Patch 提交**：

```bash
git commit -m "fix(docs): correct CSO description length limit

- Update from 150 to 1024 chars per agentskills.io spec
- Fix audit script threshold"
```

### 4.3 提交前检查清单

```markdown
## Pre-commit Checklist

### 内容检查
- [ ] 版本号已更新
- [ ] CHANGELOG 已更新（如有）
- [ ] 版本历史章节已更新
- [ ] 无调试代码或临时文件

### 格式检查
- [ ] 文件编码为 UTF-8
- [ ] 行尾符一致（LF 或 CRLF）
- [ ] 无尾随空格

### 范围检查
- [ ] 只包含必要文件
- [ ] 无敏感信息（密钥、token 等）
- [ ] .gitignore 规则正确
```

---

## 第五步：生成 Changelog（3 min）

如果项目使用 CHANGELOG.md，确保其符合 [Keep a Changelog](https://keepachangelog.com/) 规范。

### 5.1 Changelog 结构

```markdown
# Changelog

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- What's in progress (optional)

## [{version}] - {date}

### Added
- New features

### Changed
- Changes in existing functionality

### Deprecated
- Soon-to-be removed features

### Removed
- Removed features

### Fixed
- Bug fixes

### Security
- Security vulnerability fixes
```

---

## 第六步：Git Tag（2 min）

### 6.1 创建 Tag

```bash
# 创建轻量标签（推荐用于发布）
git tag v{version}

# 创建附注标签（推荐用于重要版本）
git tag -a v{version} -m "Release v{version}: {简短描述}"

# 示例
git tag -a v2.0.0 -m "Release v2.0.0: 4-Entry Router Architecture"
```

### 6.2 Tag 命名规范

```
✅ 正确:
  v1.0.0
  v2.1.3-beta.1
  v0.1.0-alpha

❌ 错误:
  1.0.0          (缺少 v 前缀)
  release-2.0    (非标准格式)
  V2.0.0         (大写 V)
```

---

## 第七步：推送（2 min）

### 7.1 推送 Commit 和 Tag

```bash
# 推送 commits
git push origin {branch}

# 推送 tags
git push origin --tags

# 或者一次性推送
git push origin {branch} --tags
```

### 7.2 推送后验证

```markdown
## Post-push Verification

- [ ] 远程仓库显示最新 commit
- [ ] Tag 已推送到远程
- [ ] CI/CD 流水线正常触发（如有）
- [ ] Release 页面生成正确（如有 GitHub Releases）
```

---

## 🚫 技能退役流程

当技能不再维护时，执行退役流程：

### 退役判定标准

满足以下任一条件时考虑退役：

- [ ] 技能已被更好的替代方案取代
- [ ] 技能依赖的技术/服务已废弃
- [ ] 技能长期无人使用（6个月+ 无更新）
- [ ] 技能与当前需求严重不符

### 退役步骤

#### Phase 1: 标记弃用（Soft Deprecation）

1. **更新 description**:

```yaml
description: >
  Use when ... (DEPRECATED: use {替代技能} instead).
  This skill will be removed in v{未来版本}.
```

2. **添加弃用警告**:

```markdown
> ⚠️ **已弃用 (Deprecated)**
>
> 本技能将于 **{日期}** 移除。
> 请迁移至: [{替代技能}](path/to/new-skill)
>
> 弃用原因: {原因说明}
```

3. **发布弃用版本**:
   - 版本: `minor +1` (如 `1.2.0` → `1.3.0`)
   - Commit: `chore(deprecate): mark as deprecated`

#### Phase 2: 硬移除（Hard Removal）

等待至少 **一个 major 版本周期** 后执行：

1. **最终版本**:
   - 版本: `major +1` (如 `1.3.0` → `2.0.0`)
   - Commit: `chore(remove): remove deprecated skill`

2. **清理工作**:
   ```bash
   # 删除技能目录
   rm -rf {skill-path}
   
   # 更新根路由器（移除此技能的路由条目）
   # 更新相关文档
   ```

3. **发布公告**:
   - 在 CHANGELOG 记录移除
   - 如有用户群，发送通知

### 退役模板

```markdown
## Deprecation Notice

**Status**: Deprecated since v{version}
**Removal Target**: v{future_version}
**Replacement**: [{new_skill_name}]({url})

### Migration Guide

{如何从旧技能迁移到新技能的步骤}

### Timeline
- {date}: Marked as deprecated
- {date}: Hard removal planned
- {date}: Final removal (if no objections)

### Reason
{为什么退役}
```

---

## 📋 发布检查清单

### 发布前（Pre-release）

- [ ] 变更内容已整理完毕
- [ ] 版本号判定正确（遵循 semver）
- [ ] SKILL.md Front Matter 已更新
- [ ] 版本历史章节已更新
- [ ] CHANGELOG.md 已更新（如有）
- [ ] 所有文件已保存
- [ ] Pre-commit checklist 全部通过

### 发布中（Release）

- [ ] Git commit message 符合 conventional commits
- [ ] Tag 格式正确（v{version}）
- [ ] Commit 和 Tag 内容一致
- [ ] 推送到正确的分支

### 发布后（Post-release）

- [ ] 远程仓库验证成功
- [ ] 如有 CI/CD，流水线通过
- [ ] 如有自动化测试，全部通过
- [ ] 通知相关人员（如需要）

---

## ⚠️ 注意事项

1. **版本只能升不能降**: 一旦发布，不要修改已发布的版本号
2. **Tag 不可修改**: 已推送的 tag 不要 force push 修改
3. **破坏性变更要谨慎**: major 版本升级要有充分的理由和迁移指南
4. **保持 changelog 准确**: 每次发布都要更新，不要事后补写
5. **退役要走完整流程**: 不要突然删除，先 soft deprecate 再 hard remove

---

## 🔗 相关资源

| 资源 | 路径 | 用途 |
|------|------|------|
| 设计原则 | [../references/design-principles.md](../references/design-principles.md) | 版本路径选择 |
| 最佳实践 | [../references/best-practices.md](../references/best-practices.md) | 版本速查卡 |
| 全局写作规则 | [../references/writing-rules.md](../references/writing-rules.md) | R1-R14 |

---

## 版本历史

| 版本 | 日期 | 变更 |
|------|------|------|
| **v2.0.0** | 2026-05-27 | **v2.0 架构重构**: 从旧 publisher 重构为单文件自含型；整合完整的 semver 工作流；新增退役流程（soft/hard deprecation）；设置 disable-model-invocation:true；可独立通过 `/publisher` 手动触发 |
| v1.0.0 | 2026-05-27 | 初始版本（已废弃） |
