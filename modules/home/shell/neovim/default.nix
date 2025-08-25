{
  config,
  inputs,
  ...
}: {
  imports = [
    # inputs.nvf.nixosModules.default 
    inputs.nvf.homeManagerModules.default
  ];
  
  systemd.user.tmpfiles.rules = [
    "d ${config.xdg.cacheHome}/nvim/undo"
    "d ${config.xdg.cacheHome}/nvim/swap"
    "d ${config.xdg.cacheHome}/nvim/backup"
    "d ${config.xdg.cacheHome}/nvim/view"
  ];

  stylix.targets.nvf.enable = false;
  programs.fish.shellAbbrs = {
    v = "nvim";
  };
  programs.nvf = {
    enable = true;
    enableManpages = true;
    settings.vim = {
      options = {
        undodir="$XDG_CACHE_HOME/nvim/undo";
        directory="$XDG_CACHE_HOME/nvim/swap";
        backupdir="$XDG_CACHE_HOME/nvim/backup";
        viewdir="$XDG_CACHE_HOME/nvim/view";
      };
      viAlias = true;
      vimAlias = true;
      # https://notashelf.github.io/nvf/options.html
      # https://github.com/NotAShelf/nvf/blob/main/configuration.nix
      theme = {
        enable = true;
        name = "nord";
        style = "dark";
      };
      
      spellcheck = {
        enable = true;
        languages = [ "en" "de"];
      };

      lsp = {
        # This must be enabled for the language modules to hook into
        # the LSP API.
        enable = true;
        formatOnSave = false;
        lightbulb.enable = true;
        trouble.enable = true;
      };

      languages = {
        enableFormat = true;
        enableTreesitter = true;
        enableExtraDiagnostics = true;

        bash.enable = true;
        nix.enable = true;
        yaml.enable = true;
        markdown = {
          enable = true;
          extensions.render-markdown-nvim.enable = true;
        };
      };

      visuals = {
        nvim-scrollbar.enable = false;
        nvim-web-devicons.enable = true;
        nvim-cursorline.enable = true;
        cinnamon-nvim.enable = true;
        fidget-nvim.enable = true;
        highlight-undo.enable = true;
        indent-blankline.enable = true;
      };

      statusline.lualine.enable = true;
      autopairs.nvim-autopairs.enable = true;
      autocomplete.nvim-cmp.enable = true;
      filetree.neo-tree.enable = true;
      snippets.luasnip.enable = true;
      telescope.enable = true;
      tabline.nvimBufferline.enable = true;
      treesitter.context.enable = true;
      
      binds = {
        whichKey.enable = true;
        cheatsheet.enable = true;
      };
      
      git = {
        enable = true;
        gitsigns.enable = true;
        gitsigns.codeActions.enable = false; # throws an annoying debug message
      };
      
      notify.nvim-notify.enable = true;

      utility = {
        diffview-nvim.enable = true;
        multicursors.enable = false;
        motion = {
          hop.enable = true;
          leap.enable = true;
        };
      };

      ui = {
        borders.enable = true;
        noice.enable = true;
        colorizer.enable = true;
        illuminate.enable = true;
        smartcolumn = {
          enable = true;
          setupOpts.custom_colorcolumn = {
            # this is a freeform module, it's `buftype = int;` for configuring column position
            nix = "110";
            ruby = "120";
            java = "130";
            go = ["90" "130"];
          };
        };
        fastaction.enable = true;
      };
    };
  };
}