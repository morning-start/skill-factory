---
name: skill-factory-publisher
version: v2.0.1
author: skill-factory
description: Use when publishing, releasing, versioning, tagging, or retiring AI Agent skills. Triggers on "publish skill", "release skill", "version bump", "git tag", "deprecate skill", "retire skill", or "skill lifecycle"
tags: [skill-publishing, version-management, git-workflow, deprecation, skill-lifecycle, skill-factory]
dependency:
  parent: skill-factory
  structure: "Type 3 (轻+厚): SKILL.md + references/"
  pattern: "Publisher (Manual Trigger)"
meta:
  complexity: basic
  standalone: true
  can_invoke_directly: true
  disable-model-invocation: true
  tdd: validation-only
  tdd_waiver_reason: "发布流程是确定性操作（版本判定+git+tag），非创造性任务"
  tdd_waiver_date: "2026-05-27"
---
# 📤 Skill Factory Publisher — 技能发布器 v2.0.1

> **定位**: 技能发布与退役的生命周期管理器
> **架构**: 自含型子技能 + references/ 详细参考
> **特殊属性**: `disable-model-invocation: true` — 仅手动触发

---

## 目标

提供完整的技能发布生命周期管理：从版本判定、Git 提交、打标签到推送，以及技能退役（Soft Deprecation → Hard Removal）的标准化流程。

**能做什么**:
- Semver 版本号自动判定与升级
- Conventional Commits 规范的 Git 提交
- Git Tag 创建与推送
- 技能弃用与退役的全流程管理

**不能做什么**:
- 不创建或修改技能内容 → `/creator` 或 `/processor`
- 不执行代码构建或测试

## 示例

### 发布新版本

```
用户: "帮我发布 skill-factory-creator 的新版本"
你:
1. 分析变更 → 判定 feat 类型 → minor 升级 v2.0.0→v2.1.0
2. 更新 Front Matter version 字段
3. git commit -m "feat(creator): add type-templates.md"
4. git tag -a v2.1.0 -m "Release v2.1.0"
5. git push origin main --tags
```

### 退役旧技能

```
用户: "这个 legacy-formatter 技能不再维护了"
你:
1. 评估 → 确认有替代方案 (skill-factory-processor)
2. Soft Deprecation: 添加 DEPRECATED 标记 + 迁移指引
3. 发布 v1.3.0 (chore: deprecate)
4. (一个 major 版本后) Hard Removal: 删除文件
```

---

## ⚠️ 手动触发 Only

本技能设置了 **`disable-modelInvocation: true`**：

- ✅ 通过 `/publisher` 手动触发
- ❌ 不会被 Agent 自动激活
- **原因**: 发布是破坏性操作，必须用户明确意图

```
/publisher
"请发布这个技能" / "帮我打一个 tag" / "这个技能需要退役了"
```

## 🎯 职责范围

| ✅ 负责 | ❌ 不负责 |
|---------|----------|
| 版本号判定与升级 | 从零创建 → `/creator` |
| Git commit 规范与 tag | 优化/审计 → `/processor` |
| 技能退役与弃用 | 合并/拆分 → `/assembler` |

---

## 🔄 发布流程 7 步总览

```
① 变更分析(3min) → ② 版本判定(2min) → ③ 更新文件(5min) → ④ Git Commit(3min)
                                                              ↓
                        ⑤ Changelog(3min) → ⑥ Git Tag(2min) → ⑦ 推送(2min) → ✅
```

### 各步骤详细指南

| 步骤 | 内容 | 详细参考 |
|------|------|---------|
| **① 变更分析** | 收集变更信息，输出变更摘要 | （本文件内联，见下方） |
| **② 版本判定** | Semver 规则、快速判定树、特殊情况 | 📖 [semver-rules.md](references/semver-rules.md) |
| **③ 更新文件** | Front Matter / 版本历史 / CHANGELOG | 📖 [changelog-spec.md](references/changelog-spec.md) |
| **④ Git Commit** | Conventional Commits 规范 + 模板 | 📖 [git-commit-spec.md](references/git-commit-spec.md) |
| **⑤ 生成 Changelog** | Keep a Changelog 格式 | 📖 [changelog-spec.md](references/changelog-spec.md) |
| **⑥ Git Tag** | 创建标签 + 命名规范 | （本文件内联） |
| **⑦ 推送** | 推送 commit + tag + 验证 | （本文件内联） |

---

## ① 变更分析（内联）

### 变更类型判断

- [ ] **Bug 修复** → `fix` / patch+1
- [ ] **新功能** → `feat` / minor+1
- [ **重构** → `refactor` / minor+1
- [ ] **破坏性变更** → `feat!` / major+1

### 输出：变更摘要

```yaml
changes:
  - type: {fix/feat/refactor/feat!}
    description: "{变更描述}"
    breaking_change: {true/false}
```

---

## ⑥ Git Tag（内联）

### 创建 Tag

```bash
# 轻量标签（日常发布）
git tag v{version}

# 附注标签（重要版本，推荐）
git tag -a v{version} -m "Release v{version}: {简短描述}"
```

### 命名规范

```
✅ v1.0.0 / v2.1.3-beta.1 / v0.1.0-alpha
❌ 1.0.0 (无v前缀) / release-2.0 / V2.0.0 (大写V)
```

---

## ⑦ 推送与验证（内联）

```bash
git push origin {branch} --tags
```

**推送后验证**：
- [ ] 远程仓库显示最新 commit
- [ ] Tag 已推送到远程
- [ ] CI/CD 流水线正常触发（如有）

---

## 🚫 技能退役流程

> 📖 **完整流程（Soft Deprecation → Hard Removal）**: [deprecation-procedure.md](references/deprecation-procedure.md)

### 速查

| 阶段 | 操作 | 版本变化 |
|------|------|---------|
| **Soft** | 标记 DEPRECATED + 迁移指引 | minor +1 |
| **Hard** | 删除文件 + 清理路由 | major +1 |

**核心原则**: 不突然删除 → 给迁移时间 → 提供替代方案 → 发公告

---

## 📋 发布检查清单

### Pre-release
- [ ] 变更内容已整理，版本号正确（遵循 semver）
- [ ] Front Matter / 版本历史 / CHANGELOG 已更新
- [ ] Pre-commit checklist 全部通过 → 见 [git-commit-spec.md](references/git-commit-spec.md)

### Release
- [ ] Commit message 符合 conventional commits
- [ ] Tag 格式: `v{version}`
- [ ] 推送到正确分支

### Post-release
- [ ] 远程验证成功 / CI/CD 通过
- [ ] 通知相关人员（如需要）

---

## ⚠️ 注意事项

1. **版本只升不降**: 不修改已发布的版本号
2. **Tag 不可改**: 已推送的 tag 不要 force push
3. **破坏性变更谨慎**: major 升级要有迁移指南
4. **Changelog 准确**: 每次发布更新，不事后补写
5. **退役走完整流程**: 先 soft deprecate 再 hard remove

---

## 📂 本子技能结构

```
skills/skill-factory-publisher/
├── SKILL.md                      ← 本文件（协调器 ~200行）
└── references/
    ├── semver-rules.md             ← 版本判定规则
    ├── git-commit-spec.md          ← Commit 规范与模板
    ├── changelog-spec.md           ← Changelog 格式
    └── deprecation-procedure.md   ← 退役完整流程
```

## 🔗 相关资源

| 资源 | 路径 |
|------|------|
| 设计原则 | [../references/design-principles.md](../references/design-principles.md) |
| 最佳实践速查 | [../references/best-practices.md](../references/best-practices.md) |
| 写作规则 | [../references/writing-rules.md](../references/writing-rules.md) |

---

## 版本历史

| 版本 | 日期 | 变更 |
|------|------|------|
| **v2.0.1** | 2026-05-27 | **优化**: 拆分 references/(4文件)；CSO 修复；添加 TDD 豁免；行数 537→~200 |
| **v2.0.0** | 2026-05-27 | 初始版本：单文件自含型；semver 工作流 + 退役流程 |
