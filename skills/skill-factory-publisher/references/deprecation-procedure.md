# 技能退役流程详解

> **来源**: [../SKILL.md](../SKILL.md) → 退役流程
> **何时读取**: 需要退役或弃用技能时

---

## 退役判定标准

满足以下任一条件时考虑退役：

- [ ] 技能已被更好的替代方案取代
- [ ] 技能依赖的技术/服务已废弃
- [ ] 技能长期无人使用（6个月+ 无更新）
- [ ] 技能与当前需求严重不符

---

## Phase 1: 标记弃用（Soft Deprecation）

### 1. 更新 description

```yaml
description: >
  Use when ... (DEPRECATED: use {替代技能} instead).
  This skill will be removed in v{未来版本}.
```

### 2. 添加弃用警告

```markdown
> ⚠️ **已弃用 (Deprecated)**
>
> 本技能将于 **{日期}** 移除。
> 请迁移至: [{替代技能}](path/to/new-skill)
>
> 弃用原因: {原因说明}
```

### 3. 发布弃用版本

- 版本: `minor +1` (如 `1.2.0` → `1.3.0`)
- Commit: `chore(deprecate): mark as deprecated`

---

## Phase 2: 硬移除（Hard Removal）

等待至少 **一个 major 版本周期** 后执行：

### 1. 最终版本

- 版本: `major +1` (如 `1.3.0` → `2.0.0`)
- Commit: `chore(remove): remove deprecated skill`

### 2. 清理工作

```bash
# 删除技能目录
rm -rf {skill-path}

# 更新根路由器（移除此技能的路由条目）
# 更新相关文档
```

### 3. 发布公告

- 在 CHANGELOG 记录移除
- 如有用户群，发送通知

---

## 退役模板

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

## 核心原则

1. **不突然删除**: 先 soft deprecate 再 hard remove
2. **给迁移时间**: 至少等待一个 major 版本周期
3. **提供替代方案**: 明确指出用户应该用什么替代
4. **发布公告**: 让所有用户知道即将发生的变化
