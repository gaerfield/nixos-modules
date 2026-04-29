{config, pkgs, lib, ...}: {
  xdg = {
    enable = true;
    portal = {
      enable = true;
      xdgOpenUsePortal = true;
      extraPortals = with pkgs; [ 
        xdg-desktop-portal
        xdg-desktop-portal-gtk
      ];
      config.common.default = "*";
    };
    userDirs = {
      enable = true;
      createDirectories = true;
      setSessionVariables = lib.mkDefault false;
      extraConfig.BIN_HOME = "${config.home.homeDirectory}/.local/bin";
    };
    mimeApps.enable = true;
  };

  home.packages = [ pkgs.xdg-utils ];

  persistence.directories = with config.xdg.userDirs; [
    { directory = "${desktop}"; mode = "0700"; }
    { directory = "${documents}"; mode = "0700"; }
    # { directory = "${download}"; mode = "0700"; } # keep this explicitly disabled, since it is often used as a temporary directory for downloads
    { directory = "${music}"; mode = "0700"; }
    { directory = "${pictures}"; mode = "0700"; }
    { directory = "${projects}"; mode = "0700"; }
    { directory = "${publicShare}"; mode = "0700"; }
    { directory = "${templates}"; mode = "0700"; }
    { directory = "${videos}"; mode = "0700"; }
    "${config.xdg.binHome}"
  ];
}