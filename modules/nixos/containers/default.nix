{
  config,
  pkgs,
  lib,
  ...
}:
with lib; let
  cfg = config.gnm.containers;
  normalUsers = lib.filterAttrs (_: u: u.isNormalUser) config.users.users;
in {
  options.gnm.containers = {
    enable = mkEnableOption "enable podman containerization support";
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
        DOCKER_HOST = "unix://$\{XDG_RUNTIME_DIR\}/podman/podman.sock";
      };
    };
    
    persistence.directories = [ "/var/lib/containers/storage" ];
    
    users.groups = {
      docker.members = lib.attrNames normalUsers;
    };
  };
}