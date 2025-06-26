{config, ...}: {
  home.sessionVariables.BROWSER = "${config.programs.firefox.package}/bin/firefox";

  programs.firefox = {
    enable = true;
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
}
