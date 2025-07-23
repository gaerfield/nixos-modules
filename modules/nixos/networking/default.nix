{
  lib,
  config,
  ...
}:
with lib; let
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
      example = ["user1" "user2"];
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
      # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
      # (the default) this is the recommended approach. When using systemd-networkd it's
      # still possible to use this option, but it's recommended to use it in conjunction
      # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
      useDHCP = lib.mkDefault true;
      # interfaces.enp0s31f6.useDHCP = lib.mkDefault true;
      # interfaces.wlp0s20f3.useDHCP = lib.mkDefault true;
    };

    users.users = lists.foldl' (acc: user:
      acc
      // {
        "${user}" = {extraGroups = ["networkmanager"];};
      }) {}
    cfg.users;
  };
}
