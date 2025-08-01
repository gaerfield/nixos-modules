{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.gnm.system;
  gnmConfig = config.gnm;
in {
  options.gnm.system = {
    mainuser = {
      name = mkOption {
        type = types.str;
        default = "nixos";
        description = "Default user for the nixos system.";
      };
      passwordFile = mkOption {
        type = types.str;
        description = "path to the hashed password file for this user.";
      };
      authorizedKeys = mkOption {
        type = types.listOf types.str;
        default = [];
        description = "SSH public keys for the default user.";
      };
    };
    allowUnfree = mkOption {
      type = types.bool;
      default = false;
      description = "Allow unfree packages in the system.";
    };
    hostname = mkOption {
      type = types.str;
      default = "nixos";
      description = "The hostname of the system.";
    };
    timezone = mkOption {
      type = types.str;
      default = "Europe/Berlin";
    };
    locale = mkOption {
      type = types.str;
      default = "de_DE.UTF-8";
    };
  };

  imports = [
    ./../appimage
    ./../containers
    ./../gui
    ./../hardware
    ./../networking
    ./../nix
    ./../os
    ./../virtualisation
  ];

  config = {
    gnm = {
      appimage.enable = mkDefault false;
      containers = {
        enable = mkDefault false;
        users = [cfg.mainuser.name];
      };
      gui.enable = mkDefault true;
      hardware.enable = mkDefault true;
      networking = {
        enable = mkDefault true;
        users = [cfg.mainuser.name];
      };
      os = cfg;
      virtualisation = {
        enable = mkDefault false;
        users = [cfg.mainuser.name];
      };
    };

    home-manager.users."${cfg.mainuser.name}" = {
      imports = [
        #flake.homeManagerModules.base
        ./../../home/base
        ./../../home/chromium
        ./../../home/cloud
        ./../../home/containers
        ./../../home/firefox
        ./../../home/git
        ./../../home/gnome
        ./../../home/java-development
        ./../../home/shell
        ./../../home/terminal
        ./../../home/track-working-day
        ./../../home/virtualisation
        ./../../home/vscode
      ];

      gnm.hm = {
        chromium.enable = mkDefault false;
        cloud.enable = mkDefault false;
        javaDevelopment.enable = mkDefault false;
        firefox.enable = mkDefault true;
        git.enable = mkDefault true;
        trackWorkingDay.enable = mkDefault false;
        vscode.enable = mkDefault false;

        containers.enable = gnmConfig.containers.enable;
        virtualisation.enable = gnmConfig.virtualisation.enable;
        gnome.enable = gnmConfig.gui.enable;
        terminal.enable = gnmConfig.gui.enable;
      };
    };
  };
}
