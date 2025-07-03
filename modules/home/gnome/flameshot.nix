{
  pkgs,
  config,
  ...
}: {
  home.packages = [pkgs.flameshot];

  xdg.configFile."flameshot/flameshot.ini".source = (pkgs.formats.ini {}).generate "flameshot.ini" {
    General = {
      autoCloseIdleDaemon = true;
      contrastOpacity = 188;
      copyPathAfterSave = true;
      jpegQuality = 75;
      showMagnifier = false;
      showSelectionGeometryHideTime = 3000;
      startupLaunch = true;
      disabledTrayIcon = false;
      drawColor = "#ff0000";
      drawFontSize = 32;
      drawThickness = 4;
      filenamePattern = "%Y%m%d_%H%M%S";
      savePath = "${config.home.homeDirectory}/Bilder/Bildschirmfotos";
      savePathFixed = true;
      showHelp = false;
      showStartupLaunchMessage = false;
    };
  };

  # workaround for:
  #  https://github.com/flameshot-org/flameshot/issues/3365
  #  https://github.com/flatpak/xdg-desktop-portal/issues/1070
  home.file.".local/bin/flameshot-workaround" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      env QT_QPA_PLATFORM=wayland flameshot $@
    '';
  };

  dconf.settings = {
    "org/gnome/desktop/wm/keybindings" = {
      screenshot = [];
      show-screenshot-ui = [];
      screenshot-window = [];
    };
    "org/gnome/settings-daemon/plugins/media-keys" = {
      custom-keybindings = [
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom3/"
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom4/"
      ];
    };
    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom3" = {
      name = "screenshot";
      command = "flameshot-workaround gui";
      binding = "Print";
    };
    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom4" = {
      name = "screenshot screen";
      command = "flameshot-workaround full -p /home/gaerfield/Bilder/screenshots";
      binding = "<Alt>Print";
    };
  };
}
