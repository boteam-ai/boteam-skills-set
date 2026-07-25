# /team — 专家团队目录

输出**完整专家团队列表与分工**。

## 默认模式

**用中文回复。**

1. 加载并遵循 `.cursor/skills/team/SKILL.md` 的默认输出格式。
2. 读取 `hr/ROSTER.md` 获取最新状态与评分；必要时读 `README.md` 的团队召唤部分。
3. 按 SKILL 中的五层结构 + 团队召唤 + 运营命令表格输出，不要省略任何在岗专家。

若用户附带具体问题（例如「做 GTM 该叫谁」），在目录后加 **3 行以内的选用建议**。

## Demo 模式 (`/team demo`)

当用户附带 **`demo`** 时：

1. 读取 [`.cursor/references/DEMO-SUFFIX.md`](../references/DEMO-SUFFIX.md)。
2. 遵循 `team/SKILL.md` 的 **§ Demo output** — **仅英文**、按部门分组、**脱敏**（无路径、无评分、无内部 ops 日志）。
3. 输出适合录屏与公开分享。
