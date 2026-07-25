# HR Rubric — Expert Evaluation Standard

考核标准。每位专家在 `EVALUATION.md` 中按此打分（每维度 1-5），加权得总分。所有评分用英文记录，给你的总结用中文。

## Scoring dimensions

| Dimension | Weight | 1 (差) | 3 (合格) | 5 (顶尖) |
|-----------|-------:|--------|----------|----------|
| **Source authority** 源头权威度 | 25% | 来源不明/无背书 | 有一个可信开源库或人物 | 多个高 star MIT 库 + 公认 thought leader |
| **Goal relevance** 目标相关度 | 25% | 与一人公司/App/GTM 无关 | 间接相关 | 直接推进 2 年一人公司目标 |
| **Output quality** 产出质量 | 20% | 空泛、不可执行 | 有框架但需补 | 可直接落地、含模板与验证步骤 |
| **Usage frequency** 调用频率 | 10% | 30 天 0 次 | 偶尔调用 | 高频且被主动召唤 |
| **Outcome impact** 实际效果 | 15% | 无可见结果 | 有产出但影响小 | 直接带来发货/收入/用户增长 |
| **Freshness** 时效性 | 5% | 内容过时 | 半年内 | 近 30 天经 radar 校准 |

**加权总分** = Σ(score × weight)。满分 5.0。

## Thresholds (action gates)

- **≥ 4.0** → `active`，保留；考虑提名为团队核心。
- **3.0 – 3.9** → `active`，但标记 `upgrade`：下次 radar 优先补强来源与方法。
- **2.0 – 2.9** → `probation`：给一个考核周期（2 周）改进，否则降级。
- **< 2.0** → `retire`：移出活跃名单（保留目录存档），并触发 `/hire-expert` 寻找替代。
- **Usage frequency = 1 连续 2 个周期** → 即使总分高也标 `review`：可能是定位重叠或入口不清。

## Review cadence
- 每周由 `ops/weekly-automation.md` 的 cron 触发 `/hr-review`。
- 每次 review 产出写入 `hr/reviews/<YYYY-MM-DD>.md`，并回写各专家 `EVALUATION.md` 与 `hr/ROSTER.md`。

## Scoring integrity
- 评分必须有证据：引用 `EVALUATION.md` 的 usage/outcome log 条目。
- 没有证据的维度记为 `3 (assumed)` 并标注，避免凭空给高分。
