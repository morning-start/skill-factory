---
name: skill-factory-phase-destruction
version: v0.2.0
author: skill-factory
parent: skill-factory
phase: coordination
layer: 1  # 阶段协调器层
description: 销毁阶段协调器，负责调度 destroyer 执行技能退役、标记 deprecated、归档清理
tags: [skill-factory, phase-coordinator, destruction, deprecation, archive]
dependency:
  parent: skill-factory
  children:
    - skill-factory-destroyer
  input_from: skill-factory-phase-publishing  # 或手动触发
  output_to: null
---

# Phase Destruction - 销毁阶段协调器

## 职责边界

**负责**: 协调销毁阶段的退役流程
**不负责**: 生产、加工、发布阶段

---

## 在三层架构中的位置

```mermaid
flowchart TB
    L0["Layer 0: skill-factory"] --> L1["Layer 1: phase-destruction<br/>⭐ 本协调器"]
    
    L1 --> D["destroyer<br/>退役销毁"]
    
    Trigger["触发来源:<br/>1. phase-publishing 发现需退役<br/>2. 用户主动请求<br/>3. 替代方案已就绪"] --> L1
    
    L1 --> End["✅ 退役完成<br/>技能标记为 deprecated"]
    
    style L0 fill:#f3e5f5,stroke:#9c27b0,color:#4a148c
    style L1 fill:#fce4ec,stroke:#e91e63,color:#880e4f,stroke-width:2px
    style D fill:#ef9a9a,stroke:#c62828,color:#b71c1c
    style End fill:#ffcdd2,stroke:#d32f2f,color:#b71c1c
```

---

## 核心职责

```mermaid
mindmap
  root((销毁阶段))
    退役原因识别
      被拆分替代
      已过时无用
      有安全问题
      功能合并重构
    退役流程
      标记 deprecated
      编写迁移指引
      设置迁移期 (建议30天)
      归档或删除
    安全保障
      不影响正在使用的技能
      迁移期缓冲
      清理前的备份
```

---

## 销毁流程编排

```mermaid
flowchart TD
    Start([收到退役请求]) --> Reason{退役原因?}
    
    Reason -->|被替代| S1[标记 deprecated<br/>+ 替代方案链接]
    Reason -->|已过时| S2[标记 deprecated<br/>+ 过时说明]
    Reason -->|安全| S3[紧急标记 deprecated<br/>+ 安全警告]
    
    S1 & S2 & S3 --> Guide[编写迁移指引]
    Guide --> Period[设置迁移期<br/>建议 30 天]
    
    Period --> Action{到期处理?}
    
    Action -->|归档| Archive[移动到 archive/]
    Action -->|删除| Delete[永久删除]
    
    Archive --> Done([✅ 退役完成])
    Delete --> Done
    
    style Start fill:#e8eaf6,stroke:#3f51b5,color:#1a237e
    style S1 fill:#ef9a9a,stroke:#c62828,color:#b71c1c
    style S2 fill:#ef9a9a,stroke:#c62828,color:#b71c1c
    style S3 fill:#ef5350,stroke:#c62828,color:#ffffff
    style Guide fill:#fce4ec,stroke:#e91e63,color:#880e4f
    style Period fill:#fff3e0,stroke:#ff9800,color:#e65100
    style Done fill:#ffcdd2,stroke:#d32f2f,color:#b71c1c
```

---

## Deprecated 模板

```yaml
---
name: <原技能名>
version: v0.1.0
description: "[已废弃] 请使用以下替代技能:"
tags: [deprecated]
---

## 退役通知

本技能已于 {日期} 标记为废弃。

### 替代方案
- [<新技能A>](../<new-skill-a>/SKILL.md): <用途>
- [<新技能B>](../<new-skill-b>/SKILL.md): <用途>

### 迁移指南
<简要说明如何从旧技能迁移到新技能>
```

---

## 与其他阶段的关系

销毁阶段通常由以下情况触发：

```mermaid
flowchart LR
    Publishing["③ 发布阶段"] -->|发现需退役| Destruction["④ 销毁阶段"]
    User["用户请求"] -->|主动退役| Destruction
    System["系统检测"] -->|安全/过期| Destruction
    
    subgraph Destruction ["本阶段"]
        D[destroyer<br/>执行退役]
    end
    
    Destruction --> Archive[archive/ 归档]
    Destruction --> Delete[删除]
    
    style Publishing fill:#e3f2fd,stroke:#2196f3,color:#0d47a1
    style Destruction fill:#fce4ec,stroke:#e91e63,color:#880e4f
    style D fill:#ef9a9a,stroke:#c62828,color:#b71c1c
```

---

## 配置参数

```yaml
phase_config:
  name: destruction
  layer: 1
  coordinator_type: single_task  # 单任务协调器
  
  steps:
    - id: 1
      skill: destroyer
      required: true
      estimated_time: "15-30min"
  
  safety_settings:
    migration_period_days: 30       # 默认迁移期
    backup_before_delete: true       # 删除前必须备份
    confirm_before_action: true      # 重要操作需确认
    
  triggers:
    - from_phase: publishing
      condition: "技能被替代或不再维护"
    - manual: true
      condition: "用户主动请求"
```

---

## 参考

- [skill-factory](../SKILL.md) - 工厂根 (Layer 0)
- [skill-factory-phase-publishing](../skill-factory-phase-publishing/SKILL.md) - 可能的上游触发者 (Layer 1)
- [destroyer](../skill-factory-destroyer/SKILL.md) - 唯一子技能 (Layer 2)
