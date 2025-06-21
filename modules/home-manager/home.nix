{
  config,
  pkgs,
  lib,
  ...
}:
# Common settings for all type of system/users that home-manager should have.
# In General home-manager required defaults
with lib; let
  username = config.nixos-modules.home-manager.home.username;
in {
  options.nixos-modules.home-manager.home.username = mkOption {
    type = types.str;
    default = "nixos";
    description = "Default user for the home-manager system.";
  };

  config = {
    home = {
      username = "${username}";
      homeDirectory = "/home/${username}";
      packages = [pkgs.home-manager];
      stateVersion = "25.05";
    };

    systemd.user.startServices = pkgs.stdenv.isLinux;
  };
}
