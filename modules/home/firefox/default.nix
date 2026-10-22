{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.gnm.hm.firefox;
  firefoxPackage = config.programs.firefox.finalPackage or config.programs.firefox.package;
in {
  imports = [
    ./profile.nix
  ];

  options.gnm.hm.firefox.enable = mkEnableOption "enable Firefox browser support";

  config = mkIf cfg.enable {

    home.sessionVariables.BROWSER = "${firefoxPackage}/bin/firefox";
    programs.firefox = {
      enable = true;
      configPath = "${config.xdg.configHome}/mozilla/firefox";
      # package = pkgs.firefox.override {
      #   nativeMessagingHosts = with pkgs; [
      #     gnome-browser-connector
      #     # gsconnect
      #     libpulseaudio
      #   ];
      # };
    };

    home.sessionVariables = {
      MOZ_ENABLE_WAYLAND = "1";
      MOZ_USE_XINPUT2 = "1";
    };

    persistence.directories = with config.xdg; [
      "${configHome}/mozilla/firefox"
      "${cacheHome}/mozilla/firefox"
    ];
  };
}