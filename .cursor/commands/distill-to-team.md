# /distill-to-team — 提炼跨项目方法论

当某做法 **第二次仍被验证**、可跨 App 复用时，写入 `methodology/` 并走组织 loop 收尾。

**用中文与用户确认**，文件英文 slug + 可中英正文。

## 前置（LOOP-CONTEXT）

开始前读：`GUARDRAILS.md` · `CHANGELOG [Unreleased]` · 最近 3 条 executions。

## 流程

1. **门槛**：确认不是产品 PRD/一次性 dump（GUARDRAILS §3）；已是第二次使用或明确会复用。
2. **创建** `methodology/<topic-slug>.md`（模板 `templates/METHODOLOGY.template.md`）：
   - Summary / When to use / Steps / Sources / Linked experts
3. **可选**：把摘要链入相关专家 `.cursor/skills/<slug>/references/`（一行链接即可，不复制全文）。
4. **更新** `source-skill/references/SOURCES-CATALOG.md` 若引入新来源。
5. **写 execution log** `ops/executions/<date>-distill-<slug>.md`
6. **运行** `./scripts/update-execution-index.sh`
7. **更新** `CHANGELOG.md`（Added: methodology/…）
8. 中文汇报：写了什么、链到哪些专家、为何符合 GUARDRAILS ✅

## 与 /log-expert-use 区别

| | log-expert-use | distill-to-team |
|--|----------------|-----------------|
| 层级 | Layer 3 轻量 | Layer 2 execution + CHANGELOG |
| 产出 | index + EVALUATION 一行 | methodology/ 文件 |
| 触发 | 每次咨询可选 | 可复用方法论第二次验证 |
