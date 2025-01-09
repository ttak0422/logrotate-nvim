# logrotate-nvim

## usage
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
    -- directory path of files used internally, such as timestamps.
    config_path = vim.fn.stdpath("data") .. "/logrotate",
})
```
