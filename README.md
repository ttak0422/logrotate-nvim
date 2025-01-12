# logrotate-nvim

> [!NOTE]
> This plugin does not aim to faithfully reproduce the logrotate command.

## usage

> [!IMPORTANT]
> `logrotate-nvim` is currently only compatible with Neovim 0.10+ or later.

```lua
-- minimal
require("logrotate").setup()

-- default option
require("logrotate").setup({
    -- target file paths .
    -- e.g. `vim.fn.stdpath("state") .. lsp.log`
    targets = {},     
    -- lotate interval. 
    -- e.g. "daily" | "weekly" | "monthly"
    interval = "weekly", 
    -- path to the configuration file
    config_path = vim.fn.stdpath("data") .. "/logrotate.json",
})
```
