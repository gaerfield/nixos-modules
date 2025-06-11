{ pkgs, lib, ... }:

{
  # https://nixos.wiki/wiki/GNOME
  
  # Enable the GNOME Desktop Environment.
  services.xserver.enable = true;
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;
  
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

    gnome.excludePackages = (with pkgs; [
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
    ]);
  };

  programs.dconf.enable = true;
  services.udev.packages = with pkgs; [ gnome-settings-daemon ];

  # enable tripple buffering - probably to be removed on next stable
  # https://wiki.nixos.org/wiki/GNOME#Dynamic_triple_buffering
  nixpkgs.overlays = [
    (final: prev: {
      gnome = prev.gnome.overrideScope (gnomeFinal: gnomePrev: {
        mutter = gnomePrev.mutter.overrideAttrs ( old: {
          src = pkgs.fetchgit {
            url = "https://gitlab.gnome.org/vanvugt/mutter.git";
            # GNOME 46: triple-buffering-v4-46
            rev = "663f19bc02c1b4e3d1a67b4ad72d644f9b9d6970";
            sha256 = "sha256-I1s4yz5JEWJY65g+dgprchwZuPGP9djgYXrMMxDQGrs=";
          };
        } );
      });
    })
  ];

  nixpkgs.config.allowAliases = false;

}