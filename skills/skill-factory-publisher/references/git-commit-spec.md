# Git Commit 规范与模板

> **来源**: [../SKILL.md](../SKILL.md) → 第四步：Git Commit
> **何时读取**: 编写 commit message 时

---

## Conventional Commits 规范

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

## Commit Message 模板

### 常规提交

```bash
git commit -m "feat(skill): add TDD validation workflow

- Add RED/GREEN/REFACTOR phases
- Include pressure scenario templates
- Add waiver exemption criteria

Closes #123"
```

### 破坏性变更

```bash
git commit -m "feat!(skill): restructure to router architecture

BREAKING CHANGE: Sub-skills now use new routing format.
Migration guide: see MIGRATION.md"
```

### Patch 提交

```bash
git commit -m "fix(docs): correct CSO description length limit

- Update from 150 to 1024 chars per agentskills.io spec
- Fix audit script threshold"
```

## Pre-commit Checklist

```markdown
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
