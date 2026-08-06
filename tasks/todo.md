# Updater 修复计划

- [x] 修复 `github/downloader.sh` 的 GitHub API 提取逻辑，只输出 IPv4/IPv6 CIDR，避免 `commit_signing_keys` 等非地址字段进入数据文件。
- [x] 修复 `utils/merge.py`，在调用 `netaddr.cidr_merge` 前去除空白行，保留对非空非法输入的显式失败。
- [x] 使用最小临时输入复现并验证两个解析边界；用当前仓库数据运行合并和 IPv4 展开流程。
- [x] 记录实际变更、验证命令和未验证边界。

## 验证授权

- 允许运行本地 Python 脚本和 shell 级临时输入验证，不修改生产环境或远端。
- 不新增依赖、不重写已有历史数据；提交和推送需单独授权，本轮已获明确授权。

## 影响文件

- `github/downloader.sh`
- `utils/merge.py`
- `tasks/todo.md`

## 实际结果

- 实时 GitHub API 过滤并用 `ipaddress` 校验：`7669` 条 CIDR（IPv4 `6014`、IPv6 `1655`），未采集 PGP/base64 内容。
- 空行输入合并为 `10.0.0.0/24`；非空 `not-a-cidr` 仍以退出码 `1` 失败。
- 当前数据处理：`13` 个 IPv4 源、`9` 个 IPv6 源合并成功；`all/ipv4.txt` 展开并排序得到 `242071` 行。
- 未运行 GitHub-hosted Actions；远端运行环境差异仍需由下一次 workflow 运行确认。
