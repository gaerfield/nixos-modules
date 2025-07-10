{
  config,
  inputs,
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
      password = mkOption {
        type = types.str;
        default = "nixos";
        description = "Default password for the default user.";
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
    inputs.self.nixosModules.appimage
    inputs.self.nixosModules.containers
    inputs.self.nixosModules.gui
    inputs.self.nixosModules.hardware
    inputs.self.nixosModules.home-manager
    inputs.self.nixosModules.networking
    inputs.self.nixosModules.nix
    inputs.self.nixosModules.os
    inputs.self.nixosModules.virtualisation
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
      home-manager = {
        user = cfg.mainuser.name;
      };
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
    
    hm = {
      imports = [
        inputs.self.homeModules.base
        inputs.self.homeModules.chromium
        inputs.self.homeModules.cloud
        inputs.self.homeModules.firefox
        inputs.self.homeModules.git
        inputs.self.homeModules.gnome
        inputs.self.homeModules.java-development
        inputs.self.homeModules.shell
        inputs.self.homeModules.terminal
        inputs.self.homeModules.track-working-day
        inputs.self.homeModules.virtualisation
        inputs.self.homeModules.vscode
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
