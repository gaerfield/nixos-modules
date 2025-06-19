{ lib, ... }: {
  options = {
    mainuser = {
      name = lib.mkOption {
        type = lib.types.str;
        default = "gaerfield";
        description = "Default user for the nixos system.";
      };
      autologin = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Should the default user be logged in automatically upon boot.";
      };
      authorizedKeys = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [];
        description = "SSH public keys for the default user.";
      };
    };
  };
  config.flake = {
    homeModules = import ./home-manager;
    nixosModules = import ./nixos;
  };
}
