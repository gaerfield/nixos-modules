{config, ...}: {
  xdg.enable = true;
  home.sessionVariables = {
    XDG_BIN_HOME = "${config.home.homeDirectory}/.local/bin";
  };
  home.sessionPath = ["$XDG_BIN_HOME"];
}
