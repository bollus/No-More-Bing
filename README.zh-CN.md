<div align="right"><b><a href="README.md">English Version</a></b></div>

# No More Bing - 彻底锁定 Edge 搜索引擎

你是否厌倦了每次打开 Edge，甚至系统更新后，搜索引擎又被悄悄换回 Bing？

这个脚本就是你的解药。它能通过组策略，将 Edge 的默认搜索引擎牢牢锁定为你想要的任何一个，比如 Google 或 DuckDuckGo。一次设置，永久生效。

### 主要功能

* **强制锁定**: 将默认搜索引擎修改并锁定为 Google, DuckDuckGo, Baidu 等。
* **一键解锁**: 随时可以安全地移除所有策略，恢复如初。
* **交互菜单**: 无需记忆复杂命令，像操作软件一样简单。
* **安全可靠**: 使用微软官方推荐的组策略 (`ManagedSearchEngines`)，而非修改注册表的不稳定方法。

### 如何使用

最简单的方式，只需要一行命令。

1.  **以管理员身份打开 PowerShell**
    * 在开始菜单搜索 `PowerShell`。
    * 右键点击 "Windows PowerShell"，选择 "以管理员身份运行"。

2.  **复制并粘贴以下命令，然后回车：**
    ```powershell
    irm 'https://raw.githubusercontent.com/bollus/No-More-Bing/main/no-more-bing.ps1' | iex
    ```

之后，你就会看到一个清晰的菜单，根据提示操作即可。

### 运行要求

* Windows 10 / 11 专业版、企业版或教育版 (任何支持组策略的版本)。
* 管理员权限。

### 注意事项

本脚本会修改系统组策略。虽然脚本已经过测试，可以安全地锁定和解锁，但请在了解其功能后使用。因使用本脚本造成的任何问题，作者不承担任何责任。
