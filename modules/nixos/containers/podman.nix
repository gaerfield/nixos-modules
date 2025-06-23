{
  config,
  pkgs,
  ...
}: let
  mainuser = config.gnm.system.mainuser.name;
in {
  virtualisation = {
    containers.registries.search = ["docker.io"];

    podman = {
      enable = true;

      # Create a `docker` alias for podman, to use it as a drop-in replacement
      dockerCompat = true;
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

  users.users."${mainuser}".extraGroups = ["docker"];

  programs.fish = {
    shellAbbrs.p = "podman";
    shellAbbrs.dco = "podman compose";
  };
}
