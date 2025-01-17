# github-permalink.nvim

A Neovim plugin that generates GitHub permalinks from your visual selections. Select code in your editor and quickly create shareable GitHub links that highlight specific line ranges.

## Installation

Using [lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
{
  'johnsaigle/github-link.nvim',
}
```

## Usage

1. Select lines in visual mode
2. Run `:GitHubPermalink`
3. A GitHub permalink will be copied to your clipboard in the format:
   `https://github.com/org/repo/blob/commit-hash/path/to/file#L1-L5`

### Configuring a keymap

```lua
require('github-permalink').setup({})
-- Using <C-u> clears the highlight after generating the link.
vim.keymap.set("x", "<leader>gl", ":<C-u>GitHubPermalink<CR>", { desc = "[G]itHub Perma[L]ink"})
```
