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

    persistence.directories = [
      { directory = "${config.xdg.configHome}/chromium"; mode = "0700"; }
      { directory = "${config.xdg.cacheHome}/chromium"; mode = "0700"; }
    ];
  };
}
