---
name: skill-factory-publisher
version: v2.3.0
author: skill-factory
description: "Use when publishing, releasing, versioning, tagging, retiring AI Agent skills, generating changelogs, or managing skill lifecycle. Triggers include: publish skill, release skill, version bump, git tag, deprecate skill, retire skill, automated release, CI/CD pipeline, GitHub Actions workflow, changelog generation, skill deprecation"
tags: [skill-publishing, version-management, git-workflow, deprecation, skill-lifecycle, ci-cd-integration, automation, skill-factory]
dependency:
  parent: skill-factory
  structure: "Type 3 (轻+厚): SKILL.md + references/"
  pattern: "Publisher (Manual Trigger + CI/CD Integration)"
meta:
  complexity: intermediate
  standalone: true
  can_invoke_directly: true
  disable-model-invocation: true
  tdd: validation-only
  tdd_waiver_reason: "发布流程是确定性操作（版本判定+git+tag），非创造性任务。CI/CD集成部分已通过harness-integration-guide.md验证"
  tdd_waiver_date: "2026-05-30"
  ci_cd_ready: true
  harness_integration: "v1.0"
---
# 📤 Skill Factory Publisher — 技能发布器

> **定位**: 技能发布与退役的生命周期管理器
> **特殊**: `disable-model-invocation: true` — 仅手动触发

## 职责

| ✅ 负责 | ❌ 不负责 |
|---------|----------|
| 版本号判定与升级 (Semver) | 从零创建 → `/creator` |
| Git commit 规范 + tag | 优化/审计 → `/processor` |
| 技能退役与弃用 (soft→hard) | 合并/拆分 → `/assembler` |
| ⭐ CI/CD 自动化发布 | 创建测试场景 → `/creator` |
| ⭐ Changelog 生成 | |

## 🔄 发布流程

```
① 变更分析(3min) → ② 版本判定(2min) → ③ 更新文件(5min) → ④ Git Commit(3min)
                                                                    ↓
                              ⑤ Changelog(3min) → ⑥ Git Tag(2min) → ⑦ 推送(2min) → ✅
```

| 步骤 | 核心 | 参考 |
|------|------|------|
| ① 变更分析 | 判断 fix/feat/refactor/breaking | （内联） |
| ② 版本判定 | Semver: major/minor/patch | [references/semver-rules.md](references/semver-rules.md) |
| ③ 更新文件 | Front Matter + version history + CHANGELOG | [references/changelog-spec.md](references/changelog-spec.md) |
| ④ Git Commit | Conventional Commits 规范 | [references/git-commit-spec.md](references/git-commit-spec.md) |
| ⑤ 生成 Changelog | Keep a Changelog 格式 | [references/changelog-spec.md](references/changelog-spec.md) |
| ⑥ Git Tag | `git tag -a v{version} -m "..."` | 命名: `v1.0.0` / `v2.1.3-beta.1` |
| ⑦ 推送 | `git push origin {branch} --tags` | 验证远程+CI/CD 正常触发 |

## 🚀 CI/CD 自动化 (Harness 集成)

> **来源**: [harness-integration-guide.md](../skill-factory-processor/references/harness-integration-guide.md)
> **完整配置**: `.github/workflows/skill-auto-release.yml`

### 发布质量门禁

| 门禁 | 时机 | 标准 | 失败动作 |
|------|------|------|---------|
| Pre-release Audit | tag 推送 | 项目平均 ≥85% | 阻止发布 |
| Format Validation | 每个 PR | Front Matter 完整 | PR 评论警告 |
| TDD Coverage | Nightly | 所有技能有记录/豁免 | 创建 Issue |
| Link Validity | Weekly | 死链数=0 | 告警 |

### GitHub Actions 发布工作流

> 推送 `v*` tag 时自动触发：全量审计 → 质量门禁(≥85%) → 生成 Changelog → 创建 Release → 上传审计报告

```yaml
# 完整配置见: .github/workflows/skill-auto-release.yml
```

### Harness DevOps Agent (可选)

- 自动生成发布流水线（监控 version 变更 → 审计 → 质量门禁 → Changelog → Tag → Release）
- 批量发布多个技能

## 🚫 技能退役流程

| 阶段 | 操作 | 版本变化 |
|------|------|---------|
| **Soft Deprecation** | 标记 DEPRECATED + 迁移指引 | minor +1 |
| **Hard Removal** | 删除文件 + 清理路由 | major +1 |

**核心原则**: 不突然删除 → 给迁移时间 → 提供替代方案 → 发公告

> **完整流程**: [references/deprecation-procedure.md](references/deprecation-procedure.md)

## ⚠️ 约束

1. **手动触发 Only** — 发布是破坏性操作，需用户明确确认 (`/publisher`)
2. **版本只升不降** — 不修改已发布的版本号
3. **Tag 不可改** — 已推送 tag 不要 force push
4. **破坏性变更谨慎** — major 升级要有迁移指南
5. **退役走完整流程** — 先 soft 后 hard

## 📂 结构

```
skill-factory-publisher/
├── SKILL.md                              ← 本文件
└── references/
    ├── semver-rules.md                   ← 版本判定规则
    ├── git-commit-spec.md                ← Commit 规范
    ├── changelog-spec.md                 ← Changelog 格式
    └── deprecation-procedure.md          ← 退役完整流程
```

## 版本历史

| 版本 | 日期 | 变更 |
|------|------|------|
| **v2.3.0** | 2026-05-30 | 新增 TDD 验证记录+scenarios.yaml 引用+质量门禁 |
| **v2.0.0** | 2026-05-27 | 初始版本：semver 工作流 + 退役流程 |