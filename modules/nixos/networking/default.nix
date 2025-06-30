{
  lib,
  config,
  ...
}: let
  mainuser = config.gnm.os.mainuser.name;
in {
  imports = [
    ./ssh.nix
    ./dns-resolve.nix
  ];


  config = {

    # networking.firewall.allowedTCPPorts = [ ... ];
    # networking.firewall.allowedUDPPorts = [ ... ];
    # Or disable the firewall altogether.
    networking = {
      networkmanager.enable = true;
      firewall.enable = false;
    };
    users.users.${mainuser}.extraGroups = ["networkmanager"];
  };
}
