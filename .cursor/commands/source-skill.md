# /source-skill — 权威来源注册表

输出专家团队所有技能的**权威来源**：开源库（URL、star、license）、thought leaders、每位专家的对照关系。**用中文回复。**

## 执行方式

1. 读取 `.cursor/skills/source-skill/references/SOURCES-CATALOG.md`（主数据源）。
2. 若用户指定专家 slug（如 `product-manager`），只输出该专家一行 + 其 `SOURCES.md` 摘要。
3. 按 `source-skill/SKILL.md` 的输出格式呈现；必须包含许可与署名规则。

相关：`/boteam` 看全员分工 · `/hire-expert` 招募时必须登记新来源到此 catalog。
