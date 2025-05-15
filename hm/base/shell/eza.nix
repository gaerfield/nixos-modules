{
  programs.eza = {
    enable = true;
    git = true;
    icons = "auto";
    
    extraOptions = [
      "--group-directories-first"
      "--no-quotes"
    ];
  };

  home.shellAliases = {
    l = "eza -l";
    ll = "eza -la";
  };
}