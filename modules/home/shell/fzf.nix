{pkgs, ...}: {
  programs.fzf = {
    enable = true;

    enableBashIntegration = true;
    enableFishIntegration = true;
    enableZshIntegration = true;
    defaultOptions = [
      "--info=inline"
      "--preview='bat -n --color=always {}'"
      "--border=rounded"
      "--margin=1"
      "--padding=1"
    ];
    # regarding options: https://github.com/junegunn/fzf?tab=readme-ov-file#key-bindings-for-command-line
    # alt-c options
    changeDirWidgetOptions = [
      "--preview 'eza --group-directories-first --no-quotes --no-permissions --no-user --no-git --tree --level=2 --color=always {}'"
    ];
    # ctrl-t options
    fileWidgetOptions = [
      "--preview='bat -n --color=always {}'"
      "--bind 'ctrl-/:change-preview-window(down|hidden|)'"
    ];
    # ctrl-r options
    historyWidgetOptions = [ "--no-multi" ];
  };

  programs.fish = {
    # is this even still needed?
    plugins = with pkgs.fishPlugins; [
      {
        name = "fzf";
        inherit (fzf) src;
      }
      {
        name = "fzf-fish";
        inherit (fzf-fish) src;
      } # requires fd and bat
    ];
    shellAbbrs.fzf-help = "fzf_configure_bindings --help";
    # ctrl-o = edit file, ctrl-g = xdg-open
    interactiveShellInit = ''
      set fzf_directory_opts --bind "ctrl-o:execute($EDITOR {} &> /dev/tty)"
    '';
  };

  home.packages = [pkgs.fd pkgs.bat];
}
