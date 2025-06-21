{
  config,
  lib,
  ...
}:
with lib; let
  mainuser = config.nixos-modules.system.mainuser;
in {
  imports = [
    ./gc.nix
    ./packages.nix
    ./nix-ld.nix
  ];

  options.nixos-modules.system.mainuser = {
    name = mkOption {
      type = types.str;
      default = "nixos";
      description = "Default user for the nixos system.";
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

  config = {
    users.users."${mainuser.name}" = {
      isNormalUser = true;
      description = "${mainuser.name}";
      extraGroups = ["wheel"];
      linger = true;
      openssh.authorizedKeys.keys = mainuser.authorizedKeys;
    };

    boot.kernel.sysctl = {
      "kernel.sysrq" = 1; # enable reisub sequence
    };

    # Allow unfree packages
    nixpkgs.config.allowUnfree = true;

    # Enable CUPS to print documents.
    services.printing.enable = true;

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
