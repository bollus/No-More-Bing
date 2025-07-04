<div align="right"><b><a href="#">中文说明</a></b></div>

# No More Bing - Permanently Lock Your Edge Search Engine

Tired of Edge or Windows updates silently switching your search engine back to Bing?

This script is the solution. It uses Group Policy to lock your default search engine to your choice—like Google or DuckDuckGo—once and for all.

### Features

* **Force Lock**: Change and lock the default search engine to Google, DuckDuckGo, Baidu, etc.
* **One-Click Unlock**: Safely remove all policies and restore the original settings at any time.
* **Interactive Menu**: No need to memorize complex commands. It's as simple as using a software menu.
* **Safe & Reliable**: Uses the official Microsoft-recommended Group Policy (`ManagedSearchEngines`) instead of unstable registry hacks.

### How to Use

The easiest way is with a single command.

1.  **Run PowerShell as Administrator**
    * Search for `PowerShell` in the Start Menu.
    * Right-click on "Windows PowerShell" and select "Run as administrator".

2.  **Copy and paste the following command, then press Enter:**
    ```powershell
    irm '[https://raw.githubusercontent.com/bollus/No-More-Bing/main/no-more-bing.ps1](https://raw.githubusercontent.com/bollus/No-More-Bing/main/no-more-bing.ps1)' | iex
    ```

A straightforward menu will appear. Just follow the on-screen instructions.

### Requirements

* Windows 10 / 11 Pro, Enterprise, or Education (any edition that supports Group Policy).
* Administrator privileges.

### Disclaimer

This script modifies system Group Policies. While it has been tested to be safe for both locking and unlocking, please use it at your own risk. The author assumes no responsibility for any issues that may arise from its use.
