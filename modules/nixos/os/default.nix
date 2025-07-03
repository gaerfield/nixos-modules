{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.gnm.os;
  inherit (cfg) mainuser;
in {
  imports = [
    ./locale.nix
    ./packages.nix
  ];

  options.gnm.os = {
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

  config = {
    users = {
      groups."${mainuser.name}" = {}; # Creates a default group with the username
      users."${mainuser.name}" = {
        isNormalUser = true;
        description = "${mainuser.name}";
        extraGroups = ["wheel" "video" "audio" "${mainuser.name}"];
        linger = true;
        password = "${mainuser.password}";
        openssh.authorizedKeys.keys = mainuser.authorizedKeys;
      };
    };

    networking.hostName = cfg.hostname;

    boot.kernel.sysctl = {
      "kernel.sysrq" = 1; # enable reisub sequence
    };

    # Allow unfree packages
    nixpkgs.config.allowUnfree = cfg.allowUnfree;

    # Configure console keymap
    console.keyMap = "de-latin1-nodeadkeys";

    # Enable flakes
    nix.settings = {
      experimental-features = ["nix-command" "flakes"];
      auto-optimise-store = true;
      use-xdg-base-directories = true;
      trusted-users = [mainuser.name "root"];
    };
  };
}
