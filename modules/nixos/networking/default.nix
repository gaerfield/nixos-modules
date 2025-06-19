{
  lib,
  pkgs,
  config,
  opts,
  ...
}:
with lib; let
  mainuser = config.mainuser.name;
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

    # networking.firewall.allowedTCPPorts = [ ... ];
    # networking.firewall.allowedUDPPorts = [ ... ];
    # Or disable the firewall altogether.
    networking.firewall.enable = false;

    # Set your time zone.
    time.timeZone = mkDefault cfg.timezone;

    # Select internationalisation properties.
    i18n.defaultLocale = mkDefault cfg.locale;

    i18n.extraLocaleSettings = {
      LC_ADDRESS = mkconfig cfg.locale;
      LC_IDENTIFICATION = mkconfig cfg.locale;
      LC_MEASUREMENT = mkconfig cfg.locale;
      LC_MONETARY = mkconfig cfg.locale;
      LC_NAME = mkconfig cfg.locale;
      LC_NUMERIC = mkconfig cfg.locale;
      LC_PAPER = mkconfig cfg.locale;
      LC_TELEPHONE = mkconfig cfg.locale;
      LC_TIME = mkconfig cfg.locale;
    };
  };
}
