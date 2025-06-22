{
  pkgs,
  lib,
  config,
  ...
}:
with lib; let
  mainuser = config.gnm.system.mainuser;
in {
  # https://nixos.wiki/wiki/GNOME

  # Enable the GNOME Desktop Environment.
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;

  environment = {
    systemPackages = with pkgs; [
      dconf-editor
      adwaita-icon-theme
      gnomeExtensions.appindicator
      gnome-tweaks
      noto-fonts-color-emoji
      wl-clipboard
      libsecret
      # get metadata info for media files in nautilus
      gst_all_1.gst-plugins-good
      gst_all_1.gst-plugins-bad
      gst_all_1.gst-plugins-ugly
      gst_all_1.gst-libav
    ];

    # get metadata info for media files in nautilus
    sessionVariables.GST_PLUGIN_SYSTEM_PATH_1_0 = lib.makeSearchPathOutput "lib" "lib/gstreamer-1.0" (with pkgs.gst_all_1; [
      gst-plugins-good
      gst-plugins-bad
      gst-plugins-ugly
      gst-libav
    ]);

    gnome.excludePackages = with pkgs; [
      # gnome-photos
      gnome-tour
      cheese # webcam tool
      epiphany # web browser
      geary # email reader
      totem # video player
      gnome-contacts
      gnome-music
      tali # poker game
      iagno # go game
      hitori # sudoku game
      atomix # puzzle game
      gnome-weather # weather in notifications
      gnome-clocks # world clocks in notifications
    ];
  };

  programs.dconf.enable = true;
  services.udev.packages = with pkgs; [gnome-settings-daemon];
  nixpkgs.config.allowAliases = false;

  ### automatic login ###
  # Enable automatic login for the user.
  services.displayManager.autoLogin = mkIf mainuser.autologin {
    enable = true;
    user = mainuser.name;
  };
  # Workaround for GNOME autologin: https://github.com/NixOS/nixpkgs/issues/103746#issuecomment-945091229
  systemd.services = mkIf mainuser.autologin {
    "getty@tty1".enable = false;
    "autovt@tty1".enable = false;
  };

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "de";
    variant = "nodeadkeys";
  };

}