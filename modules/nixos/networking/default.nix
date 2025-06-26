{
  lib,
  config,
  ...
}:
with lib; let
  mainuser = config.gnm.os.mainuser.name;
  cfg = config.networking;
in {
  imports = [
    ./ssh.nix
    ./dns-resolve.nix
  ];

  options.networking = {
    timezone = mkOption {
      type = types.str;
      default = "Europe/Berlin";
    };
    locale = mkOption {
      type = types.str;
      default = "de_DE.UTF-8";
    };
  };

  config = {
    users.users.${mainuser}.extraGroups = ["networkmanager"];

    # Enable networking
    networking.networkmanager.enable = true;

    # networking.firewall.allowedTCPPorts = [ ... ];
    # networking.firewall.allowedUDPPorts = [ ... ];
    # Or disable the firewall altogether.
    networking.firewall.enable = false;

    # Set your time zone.
    time.timeZone = mkDefault cfg.timezone;

    # Select internationalisation properties.
    i18n.defaultLocale = mkDefault cfg.locale;

    i18n.extraLocaleSettings = {
      LC_ADDRESS = mkDefault cfg.locale;
      LC_IDENTIFICATION = mkDefault cfg.locale;
      LC_MEASUREMENT = mkDefault cfg.locale;
      LC_MONETARY = mkDefault cfg.locale;
      LC_NAME = mkDefault cfg.locale;
      LC_NUMERIC = mkDefault cfg.locale;
      LC_PAPER = mkDefault cfg.locale;
      LC_TELEPHONE = mkDefault cfg.locale;
      LC_TIME = mkDefault cfg.locale;
    };
  };
}
