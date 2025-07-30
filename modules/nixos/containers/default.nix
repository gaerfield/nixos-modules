{
  config,
  pkgs,
  lib,
  ...
}:
with lib; let
  cfg = config.gnm.containers;
in {
  options.gnm.containers = {
    enable = mkEnableOption "enable podman containerization support";
    users = mkOption {
      type = types.listOf types.str;
      default = [];
      example = ["user1" "user2"];
      description = "users that become members of the 'docker' group to manage containers";
    };
  };

  config = mkIf cfg.enable {
    virtualisation = {
      containers.registries.search = ["docker.io"];

      podman = {
        enable = true;

        dockerSocket.enable = true;
        # Required for containers under podman-compose to be able to talk to each other.
        defaultNetwork.settings.dns_enabled = true;
      };
    };

    environment = {
      systemPackages = with pkgs; [dive podman-tui podman-compose];
      shellAliases.docker-compose = "${config.virtualisation.podman.package}/bin/podman-compose";
      # odd ... I expected podman.dockerSocket.enable to take care of this
      sessionVariables = {
        DOCKER_HOST = "unix://$XDG_RUNTIME_DIR/podman/podman.sock";
      };
    };

    users.users = lists.foldl' (acc: user:
      acc
      // {
        "${user}" = {extraGroups = ["docker"];};
      }) {}
    cfg.users;
  };
}