{
  pkgs,
  config,
  lib,
  ...
}: {
  systemd.user.tmpfiles.rules = [
    "d ${config.xdg.cacheHome}/nvim/undo"
    "d ${config.xdg.cacheHome}/nvim/swap"
    "d ${config.xdg.cacheHome}/nvim/backup"
    "d ${config.xdg.cacheHome}/nvim/view"
  ];

  programs.fish.shellAbbrs = {
    v = "nvim";
    vim = "nvim";
  };

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    withNodeJs = false;

    plugins = with pkgs.vimPlugins; [
      neovim-sensible
      nvim-treesitter.withAllGrammars
      vim-airline
      vim-airline-themes
      nvim-fzf
      nvim-fzf-commands
      zoxide-vim
      vim-fugitive
      vim-gitgutter
      nvim-surround
      nord-vim
      nvim-web-devicons
      nvim-tree-lua
      wilder-nvim
    ];

    extraLuaConfig = ''
      -- enhanced completion menu
      local wilder = require('wilder')
      wilder.setup({modes = {':', '/', '?'}})
      wilder.set_option('pipeline', {
        wilder.branch(
          wilder.cmdline_pipeline(),
          wilder.search_pipeline()
        ),
      })
      wilder.set_option('renderer', wilder.popupmenu_renderer(
        wilder.popupmenu_border_theme({
          highlights = {
            border = 'Normal', -- highlight to use for the border
          },
          -- 'single', 'double', 'rounded' or 'solid'
          -- can also be a list of 8 characters, see :h wilder#popupmenu_border_theme() for more details
          border = 'rounded',
        })
      ))

      -- -- specific nvim-tree config
      -- disable netrw at the very start of your init.lua
      vim.g.loaded_netrw = 1
      vim.g.loaded_netrwPlugin = 1
      -- empty setup using defaults
      require("nvim-tree").setup()
      -- experimental tree
      vim.keymap.set('n', '<leader>b', ':NvimTreeToggle<CR>')
      vim.keymap.set('n', '<leader>bf', ':NvimTreeFocus<CR>')
      vim.keymap.set('n', '<leader>bs', ':NvimTreeFindFile<CR>')
      vim.keymap.set('n', '<leader>bc', ':NvimTreeCollaps<CR>')
    '';

    extraConfig = lib.fileContents ./init.vim;
  };
}
