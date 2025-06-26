{pkgs, ...}: {
  programs.fzf = {
    enable = true;

    enableBashIntegration = true;
    enableFishIntegration = true;
    enableZshIntegration = true;

    # colors = {
    #   hl = colors.bright.accent;
    #   "hl+" = colors.normal.accent;
    #   info = colors.normal.green;
    #   prompt = colors.normal.white;
    #   pointer = colors.normal.accent;
    # };

    # historyWidgetOptions = [ "--no-multi" ];
  };

  programs.fish = {
    plugins = with pkgs.fishPlugins; [
      {
        name = "fzf";
        src = fzf.src;
      }
      {
        name = "fzf-fish";
        src = fzf-fish.src;
      } # requires fd and bat
    ];
    shellAbbrs.fzf-help = "fzf_configure_bindings --help";
    interactiveShellInit = ''
      set fzf_directory_opts --bind "ctrl-o:execute($EDITOR {} &> /dev/tty)"
      set fzf_directory_opts --bind "ctrl-x:execute(xdg-open {} &> /dev/tty)"
    '';
  };

  home.packages = [pkgs.fd pkgs.bat];
}
