{config, pkgs, lib, ...}: {
  xdg = {
    enable = lib.mkDefault true;
    portal = {
      enable = lib.mkDefault true;
      xdgOpenUsePortal = lib.mkDefault true;
      extraPortals = with pkgs; [ 
        xdg-desktop-portal
        xdg-desktop-portal-gtk
      ];
      config.common.default = "*";
    };
    userDirs = {
      enable = lib.mkDefault true;
      createDirectories = lib.mkDefault true;
      setSessionVariables = lib.mkDefault false;
    };
    mimeApps.enable = lib.mkDefault true;
  };

  home.packages = [ pkgs.xdg-utils ];

  persistence.directories = with config.xdg.userDirs; [
    "${config.xdg.binHome}"
    "${config.xdg.dataHome}/applications" # .desktop files for user applications (e.g. AppImages) xdg-desktop-portal thingy?
    "${desktop}"
    "${documents}"
    # "${download}" # keep this explicitly disabled, since it is often used as a temporary directory for downloads
    "${music}"
    "${pictures}"
    "${projects}"
    "${publicShare}"
    "${templates}"
    "${videos}"
  ];
}