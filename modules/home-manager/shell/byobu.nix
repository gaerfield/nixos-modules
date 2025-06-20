{pkgs, ...}: {
  home.packages = with pkgs; [byobu tmux coreutils-prefixed];

  xdg.configFile."byobu/backend".text = ''BYOBU_BACKEND="tmux"'';
}
