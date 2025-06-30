{ config, pkgs, lib, flake, ... }: with lib; let
  cfg = config.gnm.systemWithHm;
  gnmConfig = config.gnm;
in {

  options.gnm.systemWithHm = {
    mainuser = {
      name = mkOption {
        type = types.str;
        default = "nixos";
        description = "Default user for the nixos system.";
      };
      password = mkOption {
        type = types.str;
        default = "nixos";
        description = "Default password for the default user.";
      };
      autologin = mkOption {
        type = types.bool;
        default = false;
        description = "Should the default user be logged in automatically upon boot.";
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
    flake.nixosModules.appimage
    flake.nixosModules.containers
    flake.nixosModules.gui
    flake.nixosModules.hardware
    flake.nixosModules.networking
    flake.nixosModules.nix
    flake.nixosModules.os
    flake.nixosModules.virtualisation
  ];

  config = {
    gnm = { 
      appimage.enable = mkDefault false;
      containers = {
        enable = mkDefault false;
        users = [ cfg.mainuser.name ];
      };
      gui.enable = mkDefault true;
      hardware.enable = mkDefault true;
      networking = {
        enable = mkDefault true;
        users = [ cfg.mainuser.name ];
      };
      os = cfg;
      virtualisation = {
        enable = mkDefault false;
        users = [ cfg.mainuser.name ];
      };
    };

    home-manager.users."${cfg.mainuser.name}" = {
      imports = [
        #flake.homeManagerModules.base
        flake.homeModules.chromium
        flake.homeModules.cloud
        flake.homeModules.java-development
        flake.homeModules.firefox
        flake.homeModules.git
        flake.homeModules.gnome
        flake.homeModules.shell
        flake.homeModules.terminal
        flake.homeModules.track-working-day
        flake.homeModules.virtualisation
        flake.homeModules.vscode
      ];

      gnm.hm = {
        chromium.enable = mkDefault false;
        cloud.enable = mkDefault false;
        javaDevelopment.enable = mkDefault false;
        firefox.enable = mkDefault true;
        git.enable = mkDefault true;
        trackWorkingDay.enable = mkDefault false;
        vscode.enable = mkDefault false;

        virtualisation.enable = gnmConfig.virtualisation.enable;
        gnome.enable = gnmConfig.gui.enable;
        terminal.enable = gnmConfig.gui.enable;
      };
    };
    
  };
}