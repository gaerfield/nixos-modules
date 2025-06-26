{
  config,
  pkgs,
  lib,
  ...
}:
# Common settings for all type of system/users that home-manager should have.
# In General home-manager required defaults
with lib; let
  username = config.gnm.home-manager.home.username;
in {
  options.gnm.home-manager.home.username = mkOption {
    type = types.str;
    default = config.gnm.system.mainuser.name;
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
