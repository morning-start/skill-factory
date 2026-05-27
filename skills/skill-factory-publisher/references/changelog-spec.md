# Changelog 规范与模板

> **来源**: [../SKILL.md](../SKILL.md) → 第三步+第五步
> **何时读取**: 创建或更新 CHANGELOG.md 时

---

## 格式规范

基于 [Keep a Changelog](https://keepachangelog.com/) 标准。

## CHANGELOG.md 模板

```markdown
# Changelog

All notable changes to this project will be documented in this file.

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

---

## [{old_version}] - {date}
...
```

## 版本历史章节更新模板

如果 SKILL.md 有版本历史章节，追加新条目：

```markdown
## 版本历史

| 版本 | 日期 | 变更 |
|------|------|------|
| **{新版本}** | {日期} | **{变更摘要}** |
| {旧版本} | {日期} | {变更摘要} |
```
