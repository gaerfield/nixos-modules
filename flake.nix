{
  description = "gaerfields default configurations for nixos";

  outputs = _: {
    system =
      let
        import = path: path; # let the module system know what we are exporting
      in
      {
        appimage = import ./system/appimage.nix;
        base = import ./system/base.nix;
        bluetooth = import ./system/bluetooth.nix;
        dns-resolve = import ./system/dns-resolve.nix;
        gnome-wayland = import ./system/gnome-wayland.nix;
        nix-ld = import ./system/nix-ld.nix;
        podman = import ./system/podman.nix;
        virtualization = import ./system/virtualization.nix;
      };
    hm =
      let
        import = path: path; # let the module system know what we are exporting
      in
      {
        base = {
          home-manager = import ./hm/base/home-manager.nix;
          gnome = import ./hm/base/gnome;
          shell = import ./hm/base/shell;
          git = import ./hm/base/git.nix;
        };
        cloud = import ./hm/cloud;
        development = {
          java = import ./hm/development/java.nix;
        };
        track-working-day = import ./hm/track-working-day;
        chromium = import ./hm/chromium.nix;
        firefox = import ./hm/firefox.nix;
        obsidian = import ./hm/obsidian.nix;
        rambox = import ./hm/rambox.nix;
        teams = import ./hm/teams-for-linux.nix;
        virtualization = import ./hm/virtualization.nix;
        vlc = import ./hm/vlc.nix;
        vscode = import ./hm/vscode.nix;
      };
  };
}
