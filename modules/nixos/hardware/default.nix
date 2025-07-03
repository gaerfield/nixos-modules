{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.gnm.hardware;
in {
  imports = [
    ./audio.nix
    ./bluetooth.nix
  ];

  options.gnm.hardware.enable = mkEnableOption "Enable audio, bluetooth and firmware update support.";

  config = mkIf cfg.enable {
    services.fwupd.enable = true;
  };
}
