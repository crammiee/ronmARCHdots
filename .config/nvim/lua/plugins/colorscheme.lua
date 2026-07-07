return {
  {
    "szammyboi/dune.nvim",
    priority = 1000,
    config = function()
      vim.cmd("colorscheme dune")

      -- The arrakis theme (dune.nvim's default) maps both `nontext` and
      -- `comment` to the same near-invisible arrakisBg2, so anything that
      -- links to either (Snacks picker path/git-status text, shComment,
      -- DiagnosticUnnecessary, @lsp.type.comment, ...) barely separates
      -- from the arrakisBg0 background. Override with distinct, on-palette
      -- colors and reapply whenever the colorscheme (re)loads.
      local function fix_low_contrast_highlights()
        -- Snacks picker/explorer: distinct hue per category
        -- reuses the theme's own git-add color - untracked == new-to-git
        vim.api.nvim_set_hl(0, "SnacksPickerGitStatusUntracked", { fg = "#76946A" })
        -- neutral warm gray - dotfiles, no git semantics
        vim.api.nvim_set_hl(0, "SnacksPickerPathHidden", { fg = "#a6a69c" })
        -- muted gold - gitignored, distinct hue from both of the above
        vim.api.nvim_set_hl(0, "SnacksPickerPathIgnored", { fg = "#938056" })

        -- Comment (shComment, DiagnosticUnnecessary, etc. all link here):
        -- swap arrakisBg2 for Kanagawa's own dedicated comment gray, which
        -- this theme's palette is otherwise based on. Keep the theme's
        -- default italic comment style, just fix the color.
        vim.api.nvim_set_hl(0, "Comment", { fg = "#727169", italic = true })
      end
      fix_low_contrast_highlights()
      vim.api.nvim_create_autocmd("ColorScheme", {
        pattern = "dune",
        callback = fix_low_contrast_highlights,
      })
    end,
  },

  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "dune",
    },
  },
}
