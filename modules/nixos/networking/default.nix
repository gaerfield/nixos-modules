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
    users = mkOption {
      type = types.listOf types.str;
      default = [];
      example = [ "user1" "user2" ];
      description = "users that become members of the 'networkmanager' group to manage network connections";
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
    
    users.users = lists.foldl' (acc: user: acc // {
      "${user}" = { extraGroups = ["networkmanager"]; };
    }) {} cfg.users;
  };
}
