# Skill Factory 测试框架

> **版本**: v0.2.0 | **创建日期**: 2026-05-01

---

## 项目结构

```
skill-factory/
├── tests/
│   ├── README.md                    # 本文件 - 测试指南
│   ├── researcher/                  # Researcher 测试
│   │   └── test_callback_protection.yaml
│   ├── fast-path/                   # 快速路径测试
│   │   └── test_type1_release.yaml
│   ├── unit/                        # 单元测试
│   │   ├── test_researcher.yaml
│   │   ├── test_analyzer.yaml
│   │   ├── test_planner.yaml
│   │   ├── test_packager.yaml
│   │   └── test_publisher_version.yaml
│   ├── integration/                 # 集成测试
│   │   ├── test_production_flow.yaml
│   │   └── test_processing_flow.yaml
│   └── fixtures/                    # 测试数据
│       ├── sample_skills/
│       └── expected_outputs/
```

---

## 测试覆盖目标

### v0.2.0 覆盖范围

| 模块 | 单元测试 | 集成测试 | 总计 |
|------|---------|---------|------|
| **Researcher** | 8 (callback) | 2 | 10 |
| **Planner** | 5 (type decision) | 1 | 6 |
| **Packager** | 5 (validation) | 2 | 7 |
| **Publisher-Version** | 4 (versioning) | 1 | 5 |
| **Processing Strategies** | 3 (strategy selection) | 2 | 5 |
| **Fast Path** | 0 | 3 | 3 |
| **合计** | **25** | **11** | **36** |

### 覆盖率目标

- 核心流程覆盖: **≥ 60%**
- P0 功能全覆盖: **100%**
- 边缘场景覆盖: **≥ 50%**

---

## 测试分类说明

### 单元测试 (Unit Tests)

测试单个子技能的核心逻辑：

```yaml
# 示例结构
name: Test<Module><Function>
tests:
  - name: <场景描述>
    input: { ... }
    expected: { ... }
```

**文件位置**: `tests/unit/test_<module>.yaml`

### 集成测试 (Integration Tests)

测试多步骤的端到端流程：

```yaml
# 示例结构
scenario: <场景描述>
steps:
  - step: N
    name: <步骤名>
    action: <操作>
    expected: { ... }
expected_results:
  total_time: ...
  output_files: [...]
```

**文件位置**: `tests/integration/test_<flow>.yaml`

---

## 运行测试

### 手动验证

由于本项目是 SKILL.md 文档系统，测试主要用于：

1. ✅ **流程验证**: 按照测试用例走一遍完整流程
2. ✅ **规则校验**: 检查判定规则是否清晰无歧义
3. ✅ **边缘测试**: 验证边界条件处理是否正确
4. ✅ **回归测试**: 版本升级后重新验证核心功能

### 自动化支持（未来）

在 v0.3.0 计划中：
- 引入测试运行器（Python/Node.js）
- 支持 YAML 测试用例自动解析和执行
- 生成测试报告和覆盖率统计

---

## 已有测试文件索引

### v0.2.0 新增

| 文件 | 类型 | 覆盖任务 | 用例数 |
|------|------|---------|--------|
| [test_callback_protection.yaml](./researcher/test_callback_protection.yaml) | Unit | T2.1 | 8 |
| [test_type1_release.yaml](./fast-path/test_type1_release.yaml) | Integration | T2.3 | 1 (10 steps) |

### 待创建

| 文件 | 类型 | 优先级 | 预计用例数 |
|------|------|--------|-----------|
| test_researcher.yaml | Unit | P1 | 5 |
| test_analyzer.yaml | Unit | P1 | 3 |
| test_planner.yaml | Unit | P0 | 5 |
| test_packager.yaml | Unit | P0 | 5 |
| test_publisher_version.yaml | Unit | P1 | 4 |
| test_production_flow.yaml | Integration | P0 | 3 |
| test_processing_flow.yaml | Integration | P1 | 3 |

---

## 测试用例编写规范

### 命名规范

```
test_<模块>_<功能>.yaml
```

示例:
- `test_researcher_callback.yaml` - Researcher 回调机制测试
- `test_planner_type_decision.yaml` - Planner 类型判定测试
- `test_packager_validation.yaml` - Packager 验证逻辑测试

### 用例命名规范

```yaml
- name: "<正常/异常/边界>_<具体场景>"
```

示例:
- `正常回调不超过3次`
- `第4次回调被拒绝`
- `冷却期内重复请求被拒绝`

### 必填字段

每个测试用例必须包含:

```yaml
- name: <名称>
  input: { ... }           # 输入数据
  expected: { ... }        # 预期输出
```

可选字段:
```yaml
  description: <详细描述>
  priority: P0/P1/P2       # 默认 P1
  related_task: T2.X       # 关联的任务编号
  tags: [callback, limit]  # 标签用于筛选
```

---

## 验收标准

### 数量要求

- [x] ≥ 25 个单元测试用例
- [ ] ≥ 5 个集成测试场景
- [ ] 覆盖所有 P0 任务
- [ ] 覆盖主要边缘场景

### 质量要求

- [ ] 所有测试用例可独立执行
- [ ] 预期结果明确无歧义
- [ ] 输入数据合理且真实
- [ ] 覆盖正常/异常/边界情况

---

## 相关文件

- [v0.2.0 计划](../plan/v0.2.0.md) - 任务定义（T2.5）
- [Processing Strategies](../docs/processing-strategies.md) - 加工策略（T2.2）
- [Versioning Rules](../docs/versioning-rules.md) - 版本规则（T2.4）

---

> **维护者**: Skill Factory Core Team  
> **最后更新**: 2026-05-01
