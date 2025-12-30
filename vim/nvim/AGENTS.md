# Neovim Configuration

LazyVim-based Neovim setup with custom plugins and LSP configuration.

## Structure

```
nvim/
├── init.lua            # Bootstrap (loads LazyVim)
├── lazyvim.json        # LazyVim extras enabled
├── lua/
│   ├── config/         # Core config (options, keymaps, autocmds)
│   └── plugins/        # Plugin specs (LazyVim format)
└── stylua.toml         # Lua formatter config
```

## Where to Look

| Task | Location |
|------|----------|
| Add plugin | `lua/plugins/<name>.lua` |
| Keybindings | `lua/config/keymaps.lua` |
| Options | `lua/config/options.lua` |
| Autocommands | `lua/config/autocmds.lua` |
| Enable LazyVim extra | `lazyvim.json` |

## Conventions

- **Plugin format**: Return table with `{ "author/plugin", opts = {...} }`
- **Override LazyVim**: Same plugin name overrides defaults
- **Disable plugin**: `{ "plugin/name", enabled = false }`

## Key Plugins

- `opencode.nvim`: AI assistant integration
- `dropbar.nvim`: Breadcrumb navigation
- `snacks.nvim`: UI utilities

## Notes

- Symlinked to `~/.config/nvim` via home-manager
- `lazy-lock.json` pins plugin versions (auto-updated)
