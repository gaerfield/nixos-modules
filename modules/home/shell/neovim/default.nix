{
  inputs,
  ...
}: {
  imports = [
    # inputs.nvf.nixosModules.default 
    inputs.nvf.homeManagerModules.default
  ];
  
  #  systemd.user.tmpfiles.rules = [
  #    "d ${config.xdg.cacheHome}/nvim/undo"
  #    "d ${config.xdg.cacheHome}/nvim/swap"
  #    "d ${config.xdg.cacheHome}/nvim/backup"
  #    "d ${config.xdg.cacheHome}/nvim/view"
  #  ];
  stylix.targets.nvf.enable = false;
  programs.fish.shellAbbrs = {
    v = "nvim";
    vim = "nvim";
  };
  programs.nvf = {
    enable = true;
    settings.vim = {
      vimAlias = true;
      # https://notashelf.github.io/nvf/options.html
      theme = {
        enable = true;
        name = "nord";
        style = "dark";
      };
      
      statusline.lualine.enable = true;
      telescope.enable = true;
      autocomplete.nvim-cmp.enable = true;

      languages = {
        enableLSP = true;
        enableTreesitter = true;
        bash.enable = true;
        nix.enable = true;
      };
    };
  };
}
