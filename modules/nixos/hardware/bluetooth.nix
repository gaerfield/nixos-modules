{
  lib,
  config,
  ...
}:
with lib; let
  cfg = config.gnm.hardware;
in {
  config = mkIf cfg.enable {
    # https://nixos.wiki/wiki/Bluetooth
    hardware.bluetooth = {
      enable = true; # enables support for Bluetooth
      powerOnBoot = true; # powers up the default Bluetooth controller on boot
    };

    # not strictly required but offers some command-line utilities
    services.blueman.enable = true;
  };
}
