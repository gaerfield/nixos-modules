{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.gnm.hm.chromium;
in {
  options.gnm.hm.chromium.enable = mkEnableOption "enable Chromium browser support";

  config = mkIf cfg.enable {
    programs.chromium = {
      enable = true;
    };
  };
}
