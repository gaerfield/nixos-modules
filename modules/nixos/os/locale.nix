{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.gnm.os;
in {
  networking.hostName = cfg.hostname;
  
  # Set your time zone.
  time.timeZone = mkDefault cfg.timezone;

  # Select internationalisation properties.
  i18n = {
    defaultLocale = mkDefault cfg.locale;
    extraLocaleSettings = {
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
