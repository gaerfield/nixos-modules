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
    l = "eza -l --no-permissions --no-user --no-git";
    ll = "eza -la";
  };
}
