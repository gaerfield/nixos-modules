{ config, ... }: {
  imports = [
    ./xdg.nix
    ./nix.nix
  ];

  persistence.directories = [ "${config.home.homeDirectory}/.ssh" ];
}
