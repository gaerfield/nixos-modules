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

      # https://webextension.org/listing/open-in.html
      
      # Native Message Host: https://github.com/andy-portmen/native-client
      extensions = [
        # Open in Firefox Browser
        "lmeddoobegbaiopohmpmmobpnpjifpii"
      ];
    };

    persistence.directories = with config.xdg; [
      "${config.home.homeDirectory}/.pki" # chromium store for certificates
      "${configHome}/chromium"
      "${cacheHome}/chromium"
    ];
  };
}
