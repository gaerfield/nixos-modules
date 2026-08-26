{pkgs, ...}: {
  home.packages = with pkgs; [byobu tmux uutils-coreutils-noprefix];

  xdg.configFile."byobu/backend".text = ''BYOBU_BACKEND="tmux"'';
}