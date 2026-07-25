# /hr-review — 全员考核

扮演 HR 考核官（见 `.cursor/skills/hr-evaluator/SOUL.md`），对专家团队做一次基于证据的考核。**用中文向用户汇报**，文件记录用英文。

## 输入
- 默认：评估 `hr/ROSTER.md` 中所有 `active` / `probation` 专家。
- 可选：用户只点名某些 slug，则只评估这些。

## 预读（LOOP-CONTEXT — 必须先做）

按 [ops/LOOP-CONTEXT.md](../../ops/LOOP-CONTEXT.md)：`GUARDRAILS.md` · `CHANGELOG.md` · 最近 3 条 `ops/executions/index.json` · `hr/ROSTER.md` · 汇总 `ops/usage/index.json` 与各专家 `EVALUATION.md` usage 作为 evidence。

## 流程
1. 读取 `hr/RUBRIC.md`（评分标准与阈值）。
2. 对每位专家：
   - 读其 `.cursor/skills/<slug>/EVALUATION.md` 的 usage log 与 outcome log。
   - 按 6 个维度打分（1-5），**必须引用证据**；无证据的维度记 `3 (assumed)`。
   - 计算加权总分，按阈值给出 `status` 与 `recommendation`(keep/upgrade/retire)。
3. 回写：更新每位专家 `EVALUATION.md` 的 scorecard 与 review history。
4. 更新 `hr/ROSTER.md` 的 Status / Score / Last review。
5. 生成报告 `hr/reviews/<YYYY-MM-DD>.md`，包含：
   - 总览（多少 active/probation/retire、平均分变化）
   - 每位专家一行结论
   - **缺口分析**：一人公司当前阶段缺哪类专家 → 建议 `/hire-expert <role>`
   - **重叠/低频预警**：标 `review` 的专家
6. 向用户中文汇报关键结论与需要决策的事项（招/汰/升级）。
7. **写执行日志** `ops/executions/<YYYY-MM-DD>-hr-review.md`（模板见 `templates/EXECUTION-LOG.template.md`），运行 `./scripts/update-execution-index.sh`，并更新根目录 `CHANGELOG.md`。遵守 `GUARDRAILS.md`。

## 原则
- 只依据 `EVALUATION.md` 的真实日志打分，不凭空给高分。
- 淘汰 = 改 ROSTER 状态为 `retired` + 移入 Retired pool；**不删除目录**（存档可复活）。
- 任何 retire 都要给出替代建议（触发 `/hire-expert`）。
