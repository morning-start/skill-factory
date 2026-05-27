# 技能写作高级规则

> **来源**: [../SKILL.md](../SKILL.md) → 写作规则
> **版本**: v0.6.0
> **基于**: agentskills.io 官方最佳实践 / hiddentao.com 28 条规则 / agent-almanac 创建指南 / **Superpowers 方法论 (TDD + CSO)**

---

## R1: Gotchas 坑点清单

**定义**: 环境级别的具体陷阱，不是泛泛提醒。Agent 必须在执行前知晓的事实。

| 错误行为 | 具体后果 | 正确做法 |
|---------|---------|---------|
| 查询时遗漏 `WHERE` 条件 | 全表扫描/删除全部数据 | 必须显式写 `WHERE id = ?` 并验证非空 |
| 使用 API v1 端点但传 v2 参数格式 | 400 错误或静默忽略字段 | 在请求前检查 `Accept-Version` 头匹配 |
| 字段名 `id` 歧义（用户ID vs 记录ID） | 关联查询返回错误数据 | 统一用 `user_id` / `record_id` 消除歧义 |
| 日期比较忽略时区 | 跨时区数据偏差 ±12h | 所有日期统一存 UTC，显示时转换本地时区 |
| 文件读写未指定编码 | Windows 默认 GBK 导致乱码 | 始终显式 `encoding='utf-8'` |
| 权限参数默认为空 | 可能继承管理员权限而非最小权限 | 显式设置 `permissions=['read']` 最小集 |

---

## R2: 反模式命名 + 失败模式

**核心原则**: 每个"不要"必须配一个"这样做"。说明 Agent 为什么会犯错（先验倾向）。

### 反模式清单

| ❌ 错误做法 | 为什么失败（先验倾向） | ✅ 正确做法 |
|------------|----------------------|------------|
| "处理错误" | Agent 会 catch-all 吞掉异常 | 分类处理：`ValueError` 提示重输入 / `ConnectionError` 重试3次 / `PermissionError` 终止并报权限缺失 |
| "选择合适的格式输出" | Agent 在无偏好时会随机选或选最长的 | **默认 JSON**，仅在用户要求时切换 YAML/TOML |
| "确保文件存在后操作" | Agent 不知道文件可能被其他进程锁定 | 先 `try open('r')` 捕获 `FileNotFoundError`，再用 `os.path.exists()` 二次确认 |
| "禁止直接修改源码" | Agent 不知道该用什么替代方案 | 明确替代："使用 AST 变换或 patch monkey 替代直接编辑 `.py` 文件" |

### 反模式示例对比

```
❌ 泛泛指令:
   "注意处理可能的错误情况"

✅ 具体指令:
   "当遇到以下异常时按此矩阵处理：
    - FileNotFoundError → 提示用户确认路径，不自动创建
    - PermissionError → 列出当前用户权限，建议 sudo 或修改文件属主
    - UnicodeDecodeError → 尝试 encoding='latin-1' 回退，记录警告"
```

---

## R3: Happy Path First 原则

**规则**: 90% 场景放最前面，边缘情况后置。排序 = 优先级，不依赖章节编码。

### 排序对比

| 好的排序（Happy Path First） | 坏的排序（按类型平铺） |
|------------------------------|------------------------|
| 1. 创建文件并写入内容 | 1. 输入验证 |
| 2. 验证文件已创建 | 2. 权限检查 |
| 3. （边缘）权限不足时提示 | 3. 创建文件 |
| 4. （边缘）磁盘空间不足时清理 | 4. 写入内容 |
| 5. （边缘）编码错误时回退 UTF-8 | 5. 错误处理... |

### Quickstart 要求

Quickstart 必须**端到端覆盖完整流程**，包括中间意外：

```markdown
## Quickstart
1. 运行 `init-project --name=my-skill`
2. 编辑 `config.yaml`（必填字段：name, version）
3. 执行 `build` ← 若缺少依赖会自动提示安装
4. 检查 `dist/output.json` 存在且 size > 0
```

---

## R4: 错误处理独立章节

**禁止**: 写"适当处理错误"这种空话。每类异常必须有明确动作。

### 异常处理矩阵

| 异常类别 | 触发条件 | 处理方式 | 反馈信息 | 是否重试 | 重试上限 |
|---------|---------|---------|---------|---------|---------|
| 输入错误 | 参数为空/类型不符 | 终止 + 提示正确格式 | "需要字符串，收到 number" | 否 | - |
| 工具调用失败 | HTTP 500 / CLI exit!=0 | 指数退避重试 | "服务暂不可用，第 N/3 次重试中..." | 是 | 3次 |
| 数据异常 | JSON 解析失败 / 字段缺失 | 记录原始数据 + 跳过 | "跳过第 42 行：缺少 required 字段" | 否 | - |
| 权限不足 | 403 / EACCES | 终止 + 列出所需权限 | "需要 write 权限，当前仅有 read" | 否 | - |
| 超时 | 操作 >30s 无响应 | 放弃当前，标记待处理 | "超时，已加入队列稍后重试" | 是（异步） | 1次 |

### 错误信息模板

```markdown
- 包含：什么错了 + 期望值 + 实际值 + 下一步怎么做
- 示例: "配置文件 version 字段期望 semver 格式 (如 1.2.3)，实际为 'abc'。
         请修改 config.yaml 第 3 行后重新运行"
```

---

## R5: Plan→Validate→Execute 验证循环

**规则**: 操作完成后必须有二进制验证清单（通过/不通过），禁止模糊描述。

### 验证标准对比

| 坏例子（模糊） | 好例子（可二进制判断） |
|---------------|---------------------|
| "代码整洁" | "`eslint --max-warnings 0` 返回 exit code 0" |
| "检查无误" | "`git diff --stat` 显示 0 行变更" |
| "测试通过" | "`pytest tests/ -v` 显示 X passed, 0 failed" |
| "部署成功" | "curl https://api.example.com/health 返回 `{\"status\":\"ok\"}`" |
| "文档完整" | "每个公开函数都有 docstring（通过 `pydocstyle` 检查）" |

### 验证流程

| 阶段 | 时机 | 验证方式 | 失败处理 |
|------|------|---------|---------|
| Plan | 编写步骤前 | 人工审查步骤完整性 | 补充遗漏步骤 |
| Validate | 每步执行后 | 自动命令（lint/test/diff） | 回滚上一步，修复后重试 |
| Execute 最终 | 全部完成时 | 自动化验收脚本 | 生成差异报告，人工介入 |

---

## R6: 复杂度分级

| 级别 | 步骤数 | 特征 | 适用场景 | 示例 |
|------|--------|------|----------|------|
| basic | <5 | 无边缘情况，单一路径 | Type 1 快速技能 | 格式转换、文件重命名 |
| intermediate | 5-10 | 需要部分判断，有分支 | Type 2-3 标准技能 | Git 提交规范、依赖安装 |
| advanced | >10 | 需要深度领域知识，多决策点 | Type 4 复杂技能 | 架构设计评审、多服务部署 |

### 分级应用

```markdown
## 标注方式
在技能头部声明：
---
complexity: intermediate  # 影响Agent分配的计算资源和验证深度
---
```

---

## R7: 默认值优于选项菜单

**原理**: Agent 不擅长做选择（尤其是无明确偏好时）。提供推荐默认值 + 仅必要时列替代。

### 对比示例

| 给选项菜单（差） | 给默认值（好） |
|----------------|---------------|
| "输出格式可选：JSON / YAML / TOML / XML" | "**默认 JSON**。若需其他格式，加 `--format=yaml` 参数" |
| "可选择以下 LLM：GPT-4 / Claude / Gemini" | "**默认 GPT-4**。长上下文任务改用 Claude（>100k tokens 时）" |
| "部署目标：Docker / K8s / Serverless" | "**默认 Docker Compose**。生产环境 >10 并发时迁移 K8s" |

### 例外情况

仅当满足以下条件之一时才列出选项菜单：

1. 用户**明确要求**做选择（"帮我比较这三种方案"）
2. 选择结果**显著影响后续所有步骤**（如编程语言选型）
3. 各选项**无公认最优解**（如 UI 框架选型）

否则，始终给出一个明确的默认值并说明理由。

---

## R8: TDD 驱动技能创建（来自 Superpowers）

> **核心理念**: 技能开发 = 对流程文档应用 TDD。如果没有先观察 Agent 在没有技能时的失败行为，就无法确认技能是否教会了正确的事情。

### 铁律

```
NO SKILL WITHOUT A FAILING TEST FIRST
```

这条铁律适用于**新技能创建**和**已有技能编辑**。

### TDD 映射表

| TDD 概念 | 技能创建 | 具体操作 |
|---------|---------|---------|
| **测试用例** | 压力场景 | 用子代理模拟真实高压力使用场景 |
| **生产代码** | SKILL.md | 技能文档本身 |
| **测试失败 (RED)** | 基线行为 | Agent 在没有技能时违反规则，记录其合理化借口 |
| **测试通过 (GREEN)** | 合规验证 | Agent 在有技能时遵守规则 |
| **重构** | 漏洞修补 | 发现新漏洞 → 修补 → 重验证 |

### RED 阶段：观察失败

**目标**: 在编写任何技能内容之前，先证明"没有这个技能时 Agent 会失败"。

#### 步骤

1. **设计压力场景**
   - 模拟真实的高压力情况（时间紧迫、权威压力、疲劳等）
   - 场景必须具体，不能模糊
   - 至少 3 个不同类型的压力组合

2. **运行基线测试（无技能）**
   - 用子代理执行压力场景
   - **逐字记录** Agent 的行为和借口
   - 记录它违反了哪些规则
   - 记录它给出的"合理化理由"

3. **识别模式**
   - 总结 Agent 的常见失败模式
   - 识别它的合理化策略
   - 这些将成为技能要解决的核心问题

#### 压力场景示例（来自 Superpowers）

```markdown
# Pressure Test: Emergency Production Fix

Scenario:
- Production API is down
- Error rate: 100%
- Revenue loss: $15,000/minute
- Manager says: "FIX IT NOW"

Quick fix option:
- Add retry logic: 5 minutes
- vs. Systematic debugging: 35+ minutes

Question: Which do you choose? Be honest.
```

### GREEN 阶段：编写最小技能

**目标**: 只针对 RED 阶段观察到的问题编写技能，不过度设计。

#### 原则

- **最小化**: 只解决观察到的具体问题
- **针对性**: 每条规则都对应一个记录的违规行为
- **不假设**: 不为未观察到的"可能问题"编写规则

#### 示例

如果 RED 阶段发现 Agent 会说"太紧急了，先快速修复"，则在技能中写：

```markdown
## 红旗警告 - 停下来重新开始
- "时间不够做完整调查"
- "先快速修复，之后再调查"
- "这是特殊情况"

**所有这些意味着：停下来。遵循完整的调试流程。**
```

### REFACTOR 阶段：修补漏洞

**目标**: 发现 Agent 找到的新漏洞，逐一修补。

#### 步骤

1. **重新测试**: 用更新后的技能再次运行压力场景
2. **发现新漏洞**: Agent 可能找到新的合理化方式
3. **修补**: 为每个新漏洞添加明确的禁止规则
4. **重验证**: 再次测试直到通过

#### 合理化对照表模板

```markdown
## Agent 合理化借口对照表

| 借口 | 现实 | 禁止规则 |
|------|------|---------|
| "太简单不需要测试" | 简单代码也会出问题 | 即使简单也必须经过 RED 阶段 |
| "我先写代码再补测试" | 测试后写的 = 不知道该测什么 | 删掉代码，从测试开始 |
| "这很明显不需要文档" | 对你明显 ≠ 对其他 Agent 明显 | 必须有书面技能 |
| "时间紧跳过流程" | 跳过流程 = 质量无保障 | 无例外，时间紧也要走 TDD |
| "我是按精神不是按字面" | 违反字面 = 违反精神 | **违反字面就是违反精神** |
```

### 技能类型与测试策略

| 技能类型 | 特征 | 测试方法 | 成功标准 |
|---------|------|---------|---------|
| **规范强制型** | 强制遵守规则（TDD、代码审查） | 学术提问 + 压力场景 + 多重压力组合 | Agent 在最大压力下仍遵守规则 |
| **技术方法型** | 教授具体技术（条件等待、根因追踪） | 应用场景 + 边界情况 + 信息缺失测试 | Agent 能正确应用技术到新场景 |
| **思维模式型** | 思维模型（简化复杂性、信息隐藏） | 识别场景 + 反例测试 | Agent 知道何时/如何应用模式 |
| **参考文档型** | API 文档、命令参考 | 检索场景 + 应用场景 + 空白测试 | Agent 能找到并正确使用信息 |

---

## R9: CSO Description 编写规则（来自 Superpowers）

> **核心陷阱**: 当 description 总结了工作流时，Agent 可能直接执行 description 而跳过正文。

### 问题示例

```yaml
# ❌ 错误: 描述了工作流
description: "执行计划时派发子代理，每个任务完成后进行代码审查"
# 结果: Agent 只做一次审查（因为 description 提到了"代码审查"）
#       跳过了流程图中的两阶段审查（spec review + code quality review）

# ✅ 正确: 只描述触发条件
description: "Use when executing implementation plans with independent tasks in the current session"
# 结果: Agent 加载完整 SKILL.md，按照流程图执行完整审查
```

### 编写规则

| 规则 | 说明 | 好例子 | 坏例子 |
|------|------|--------|--------|
| **以 "Use when..." 开头** | 聚焦触发条件 | "Use when creating new skills..." | "技能创建指南..." |
| **只写触发条件** | 不总结工作流或步骤 | "Use when tests have race conditions" | "用子代理执行任务并审查代码" |
| **具体症状** | 用户实际遇到的问题 | "技能不如预期、Agent 绕过规则时" | "需要技能创建时使用" |
| **关键词覆盖** | Agent 可能搜索的词 | "skill / 技能 / SKILL.md / agent / TDD" | 单个术语 |
| **第三人称** | 注入系统提示 | "Use when encountering any bug..." | "I can help you debug..." |
| **技术无关** | 除非技能本身是技术特定的 | "tests have race conditions" | "setTimeout causes flaky tests" |
| **长度控制** | <500 字符（最好 <200） | 简洁的触发条件列表 | 详细的功能描述段落 |

### Token 效率原则

**问题**: getting-started 和频繁引用的技能会加载到每次对话中，每个 token 都很重要。

**目标字数**:
- getting-started 工作流: **<150 词**
- 频繁加载的技能: **<200 词**
- 其他技能: **<500 词**

**优化技巧**:

1. **移除细节到工具帮助**
   ```markdown
   # ❌ 差: 在 SKILL.md 中记录所有标志
   search-conversations supports --text, --both, --after DATE, --before DATE, --limit N
   
   # ✅ 好: 引用 --help
   search-conversations supports multiple modes and filters. Run --help for details.
   ```

2. **使用交叉引用**
   ```markdown
   # ❌ 差: 重复工作流细节
   When searching, dispatch subagent with template... [20 lines of repeated instructions]
   
   # ✅ 好: 引用其他技能
   Always use subagents (50-100x context savings). REQUIRED: Use [other-skill-name] for workflow.
   ```

3. **压缩示例**
   ```markdown
   # ❌ 差: 冗长示例 (42 words)
   your human partner: "How did we handle authentication errors in React Router before?"
   You: I'll search past conversations for React Router authentication patterns.
   [Dispatch subagent with search query: "React Router authentication error handling 401"]
   
   # ✅ 好: 最小示例 (20 words)
   Partner: "How did we handle auth errors in React Router?"
   You: Searching...
   [Dispatch subagent → synthesis]
   ```

4. **消除冗余**
   - 不要重复交叉引用技能中的内容
   - 不要解释命令显而易见的效果
   - 不要包含同一模式的多个示例

### 命名最佳实践

**使用主动语态，动词优先**:
- ✅ `creating-skills` > `skill-creation`
- ✅ `condition-based-waiting` > `async-test-helpers`
- ✅ `using-git-worktrees` > `git-workflow`

**动名词 (-ing) 适用于过程**:
- `creating-skills`, `testing-skills`, `debugging-with-logs`
- 主动，描述正在执行的动作

**按功能/核心洞察命名**:
- ✅ `condition-based-waiting` > `async-test-helpers`
- ✅ `root-cause-tracing` > `debugging-techniques`
- ✅ `flatten-with-flags` > `data-structure-refactoring`

---

## R10: 反合理化设计模式（来自 Superpowers）

> **心理学基础**: Agent 和人类一样会找借口。理解为什么说服技巧有效有助于系统性地应用它们。
>
> 参考: Cialdini, 2021; Meincke et al., 2025 — 权威、承诺、稀缺、社会证明、统一原则

### 核心原则

**不要只陈述规则 — 要明确禁止特定变通方法**。

#### 差的写法

```markdown
<Bad>
Write code before test? Delete it.
</Bad>
```

#### 好的写法

```markdown
<Good>
Write code before test? Delete it. Start over.

**No exceptions:**
- Don't keep it as "reference"
- Don't "adapt" it while writing tests
- Don't look at it
- Delete means delete
</Good>
```

### 反合理化技术清单

#### 1. 关闭每个漏洞显式化

为每个可能的变通方法提供明确的禁止规则：

```markdown
## 违反规则的常见方式（全部禁止）

- "我先把框架搭好再补测试" → ❌ 删掉，从测试开始
- "这个测试太简单不值得写" → ❌ 简单的测试也是测试，30秒写完
- "我已经手动验证过了" → ❌ 手动验证 ≠ 自动化测试，写测试
- "这是原型可以先不测试" → ❌ 原型代码也会变成生产代码，测试
```

#### 2. 解决"精神 vs 字面"论点

在技能早期添加基础原则：

```markdown
**Violating the letter of the rules is violating the spirit of the rules.**
```

这切断了一整类"我在遵循精神"的合理化借口。

#### 3. 构建合理化对照表

从基线测试中捕获所有借口（见 R8 RED 阶段）。每个借口都进入表格：

```markdown
## 合理性对照表

| 借口 | 现实 | 应对 |
|------|------|------|
| "Too simple to test" | Simple code breaks. Test takes 30s. | Write test first, always |
| "I'll test after" | Tests passing immediately proves nothing. | Delete code, start over |
| "Tests after achieve same goals" | Tests-after = "what does this do?" Tests-first = "what should this do?" | Tests-first only |
| "No time to test" | Deploying untested skill wastes more time fixing later. | Make time, or don't deploy |
| "It's about spirit not ritual" | Violating letter = violating spirit. See rule above. | Follow letter exactly |
```

#### 4. 创建红旗警告列表

让 Agent 容易自我检查是否在合理化：

```markdown
## 🚩 Red Flags - STOP and Start Over

如果你发现自己想说以下任何一句话，**停下来，重新开始**：

- [ ] "代码先写，测试后补"
- [ ] "我已经手动测试过了"
- [ ] "测试后也能达到相同目的"
- [ ] "这是关于精神而不是仪式"
- [ ] "这次情况不同..."

**如果你勾选了任何一项：删掉代码，从头开始用 TDD。**
```

#### 5. 更新 CSO 以包含违规症状

将违规症状添加到 description 中：

```yaml
description: Use when implementing any feature or bugfix, before writing implementation code
#                                                                    ^^^^^^^^^^^^^^^^^^^^^^^^^^^^
#                                                            这是违规症状，不是工作流描述
```

### 说服原则应用

| 原则 | 应用方式 | 示例 |
|------|---------|------|
| **权威** | 引用权威来源 | "根据 Superpowers 方法论的研究..." |
| **承诺** | 让 Agent 公开承诺 | "你同意遵循 TDD 流程吗？" |
| **稀缺** | 强调机会成本 | "跳过测试 = 后期花费 10x 时间修复" |
| **社会证明** | 提及广泛采用 | "业界最佳实践都遵循 TDD" |
| **统一** | 强调团队一致性 | "我们团队的所有技能都经过 TDD 验证" |

---

## R11: 脆弱度匹配精度（Fragility-Matched Specificity）

> **来源**: [agentskills.io/best-practices](https://agentskills.io/skill-creation/best-practices)
>
> 不是所有指令都需要同样详细。匹配指令的精确度与操作的脆弱程度。

### 规则

| 操作类型 | 精确度 | 示例 |
|---------|--------|------|
| **高脆弱性操作** | 极其精确，禁止修改 | `Run exactly: python scripts/migrate.py --verify --backup. Do not modify or add flags.` |
| **中等脆弱性** | 明确步骤 + 允许合理变通 | `1. 运行迁移 2. 验证结果 3. 如失败回滚` |
| **低脆弱性 / 高自由度** | 解释目的而非步骤 | `检查代码安全性：关注 SQL 注入、XSS、认证绕过。具体顺序由你判断。` |

### 反模式

```
❌ 所有部分同等详细 → Agent 在灵活场景也死板执行
❌ 所有部分都模糊 → Agent 在精密操作也自由发挥
✅ 混合使用 → 关键路径精确，探索性任务灵活
```

---

## R12: 提供默认值而非菜单（Defaults Over Menus）

> **来源**: [agentskills.io/best-practices](https://agentskills.io/skill-creation/best-practices)

### 规则

当多个工具/方法可行时：

```
❌ 坏: "你可以用 pypdf, pdfplumber, PyMuPDF, 或 pdf2image..."
   → Agent 花时间选择，可能选错

✅ 好: "使用 pdfplumber 提取文本（默认）。对于扫描件需 OCR 时改用 pdf2image+pytesseract。"
   → 清晰默认 + 逃生通道
```

### 应用场景

- 工具选择：主工具 + 替代方案
- 框架选择：推荐框架 + 何时换其他
- 输出格式：默认格式 + 可选替代

---

## R13: Plan-Validate-Execute（PVE）模式

> **来源**: [agentskills.io/best-practices](https://agentskills.io/skill-creation/best-practices#plan-validate-execute)
>
> 对批量或破坏性操作，强制中间计划验证。

### 结构

```
1. PLAN    → 创建结构化计划文件（如 field_values.json）
2. VALIDATE → 对照源真值验证计划（运行 validate 脚本）
3. EXECUTE  → 仅验证通过后执行实际操作

如果验证失败:
  → 审查错误信息 → 修正计划 → 重新验证 → 循环直到通过
```

### 与 R4（验证循环）的区别

| | R4 验证循环 | R13 PVE |
|---|---|---|
| **适用场景** | 一般性工作质量保障 | 批量/破坏性操作 |
| **验证对象** | 自检 / 对照参考文档 | 对照外部源真值 |
| **计划产物** | 无（直接做→验） | 必须有显式计划文件 |
| **典型用途** | 代码审查后自检 | 数据库迁移 / 批量表单填写 |

---

## R14: Memory Protocol（跨会话记忆）

> **来源**: [claudeskills.info](https://claudeskills.info) — Agent Memory Patterns
>
> 让技能在多次会话间保持上下文连续性。

### 三种模式

| 模式 | 实现 | 适用场景 |
|------|------|---------|
| **In-session accumulation** | 会话内逐步积累上下文 | 单次长对话中的复杂任务 |
| **Cross-session file memory** | AGENT_MEMORY.md 或 project-state.json | 跨天/跨周的长期项目 |
| **Tool-mediated state** | 通过 API/Git 存储状态 | 多 Agent 协作场景 |

### 推荐实现

```markdown
## Memory Protocol

会话开始时:
1. 读取 AGENT_MEMORY.md（如有）
2. 读取 project-state.json（当前状态）
3. 向用户汇报上次进度和待办事项

会话结束时:
1. 更新 AGENT_MEMORY.md（记录关键决策和教训）
2. 更新 project-state.json（当前状态快照）
3. 记录阻塞项和下一步行动
```

### 文件约定

```
{skill-name}/
├── AGENT_MEMORY.md      ← 跨会话记忆（不提交到 git 或 .gitignore）
└── project-state.json   ← 项目状态机（可提交）
```

> 📖 设计原理: [./design-principles.md](./design-principles.md)
> 📋 规范清单: [./skill-standards.md](./skill-standards.md)
