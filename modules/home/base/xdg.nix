{config, pkgs, ...}: {
  xdg = {
    enable = true;
    portal = {
      enable = true;
      xdgOpenUsePortal = true;
      extraPortals = [ pkgs.xdg-desktop-portal ];
      config.common.default = "*";
    };
  };
  home.packages = [ pkgs.xdg-utils ];
  home.sessionVariables = {
    XDG_BIN_HOME = "${config.home.homeDirectory}/.local/bin";
  };
  home.sessionPath = ["$XDG_BIN_HOME"];
}