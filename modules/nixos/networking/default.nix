{
  lib,
  config,
  ...
}: with lib; let
  cfg = config.gnm.networking;
in {
  imports = [
    ./ssh.nix
    ./dns-resolve.nix
  ];
  options.gnm.networking = {
    enable = mkEnableOption "Enable NetworkManager for managing network connections.";
    mainuser = mkOption {
      type = types.str;
      default = mainuser;
      description = "The main user for networking configurations.";
    };
  };

  config = mkIf cfg.enable {
    # networking.firewall.allowedTCPPorts = [ ... ];
    # networking.firewall.allowedUDPPorts = [ ... ];
    # Or disable the firewall altogether.
    networking = {
      networkmanager.enable = true;
      firewall.enable = false;
    };
    users.users.${cfg.mainuser}.extraGroups = ["networkmanager"];
  };
}
