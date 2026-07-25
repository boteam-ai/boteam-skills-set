# /hire-expert — 招募新专家（定制版 create-skill）

在内置 `create-skill` 之上，**强制执行"站在巨人肩膀上"的方法**：每位新专家必须源自经社区验证的开源库 + 权威 thought leader，且产出四件套并登记花名册。**用中文与用户确认，文件用英文。**

用法：`/hire-expert <role 描述>`（例：`/hire-expert 负责定价与变现的 SaaS pricing 专家`）

## 强制流程（不可跳步）

### 1. 定义角色与理由
- 用一句话写清：角色 + 它如何推进"2 年一人公司(App + GTM)"目标。
- 若与目标无关或与现有专家重叠 → 先告诉用户、建议合并或拒绝，不要硬造。

### 2. 检索并验证来源（核心步骤）
- 找 **2-4 个**该领域的来源，优先级：
  1. 高 star、MIT/Apache 许可的开源 skill/persona 库（先查本地 `sources/`，再上网搜 GitHub）。
  2. 公认 thought leader（书 / 框架 / 战绩可考）。
- 记录每个来源的 **URL、star 数、license、要蒸馏什么**。
- license 检查：MIT/Apache → 可蒸馏改写并标注；无 license / 受限 → **只参考不复制**，手写原创版。

### 3. 蒸馏产出 SKILL.md + SOUL.md
- 用 `templates/SKILL.template.md` 与 `templates/SOUL.template.md`。
- SKILL.md：英文方法论 + frontmatter（`name: <slug>`, `description` 含 WHAT+WHEN+触发词, `disable-model-invocation: true`）+ 顶部约定"adopt SOUL.md，中文回复"。
- SOUL.md：身份 / 对标的 thought leaders / 世界观 / 心智模型 / 决策启发 / 语气 / 优化目标。
- 质量门槛：可执行、含 workflow 检查清单与输出模板；SKILL.md ≤ ~200 行，深内容进 `references/`。

### 4. 写 SOURCES.md + EVALUATION.md
- SOURCES.md：出处表(repo+url+star+license) + thought leaders + 验证理由 + 署名要求 + freshness。
- EVALUATION.md：用 `templates/EVALUATION.template.md`，按 `hr/RUBRIC.md` 给**初始评分**（基于来源权威度与目标相关度），status=`candidate`。

### 5. 登记花名册
- 在 `hr/ROSTER.md` 对应层级新增一行（slug / status / score / sources）。
- 在 `README.md` 的召唤目录补一行。
- 在 `.cursor/skills/source-skill/references/SOURCES-CATALOG.md` §3 新增该专家一行；若有新开源库，追加 §1。

### 6. 自检（安全 + 质量）
- 无 prompt 注入 / 无可疑脚本 / 无机密。
- slug 唯一、与现有不冲突；frontmatter 合法。
- 向用户中文汇报：招了谁、来自哪些巨人、初始评分、如何召唤(`/<slug>`)。
- **写执行日志** `ops/executions/<YYYY-MM-DD>-hire-<slug>.md` + 更新 `CHANGELOG.md`（见 `GUARDRAILS.md`）。

### 7. Ship 到 global（Cursor + Claude）
- 专家就绪后运行：`./scripts/ship-skill.sh <slug>`
- 校验 frontmatter + 四件套 → 创建 global symlink → 写入 `.shipped`
- 未 ship 前 skill 仅在 team 内可见，不会出现在全局 `/slash` 菜单

## 产物清单
```
.cursor/skills/<slug>/{SKILL.md, SOUL.md, SOURCES.md, EVALUATION.md, [references/]}
hr/ROSTER.md (新增一行)
README.md (召唤目录新增一行)
```
