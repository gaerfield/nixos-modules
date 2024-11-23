{ pkgs, lib, colors, ... }: {
  imports = [
    ./theme.nix
    ./autostart.nix
    ./flameshot.nix
    ./alacritty.nix
    ./notifications.nix
  ];

  fonts.fontconfig.enable = true;

  # TODO remove when `pkgs.cantarell-fonts` is no more broken on darwin
  #home.packages = lib.optionals pkgs.stdenv.isLinux ([
  #  pkgs.cantarell-fonts
  #  (pkgs.nerdfonts.override { fonts = [ "RobotoMono" ]; })
  #
  #  pkgs.papirus-icon-theme
  #  pkgs.yaru-theme
  #] ++ extensions);

  home.packages = with pkgs.gnomeExtensions; [
    # pkgs.gnome-extensions-cli
    dash-to-dock
    gsconnect
    appindicator
    gnome-40-ui-improvements
    # material-shell # tiling manager - vanished, but why
    #pano # clipboard-manager, required libgda and gsound
    clipboard-indicator # replacement until pano works *sigh
    pkgs.gsound
    pkgs.meld
    # gstreamer plugins hopefully displaying some metadata infos
    pkgs.gst_all_1.gst-plugins-good
    #pkgs.copyq
  ];

  dconf = {
    enable = true;

    settings = {
      # subpixel anti-aliasing (best for LCD's)
      "org/gnome/desktop/interface".font-antialiasing = "rgba";
      "org/gnome/desktop/peripherals/mouse".natural-scroll = true;
      "org/gnome/desktop/peripherals/touchpad".tap-to-click = true;
    
      "org/gnome/desktop/interface".enable-hot-corners = false;
      "org/gnome/shell/app-switcher".current-workspace-only = true;
      "org/gnome/mutter" = {
        dynamic-workspaces = true;
        workspaces-only-on-primary = true;
        experimental-features = [
          "scale-monitor-framebuffer" # enable fractional scaling 
        ];
      };
      
      "ca/desrt/dconf-editor/Settings".show-warning = false;
      "org/gnome/desktop/privacy" = {
        old-files-age = 30;
        remove-old-temp-files = true;
        remove-old-trash-files = true;
        report-technical-problems = false;
        send-software-usage-stats = false;
      };
      "org/gnome/desktop/search-providers" = {
        disabled = [ "org.gnome.Contacts.desktop" ];
        sort-order = [ "org.gnome.Documents.desktop" "org.gnome.Nautilus.desktop" ];
      };
      # super + right click allows for resizing windows
      "org/gnome/desktop/wm/preferences".resize-with-right-button = true;
      "org/gnome/desktop/wm/keybindings" = {
        close=["<Super>q"];
        cycle-group=["<Super>Tab"];
        cycle-group-backward=["<Shift><Super>Tab"];
        minimize=["<Super>w"];
        move-to-monitor-left=["<Shift><Super>Left"];
        move-to-monitor-right=["<Shift><Super>Right"];
        move-to-workspace-left=["<Control><Super>Left"];
        move-to-workspace-right=["<Control><Super>Right"];
        switch-applications=["<Alt>Tab"];
        switch-applications-backward=["<Shift><Alt>Tab"];
        switch-to-workspace-left=["<Super>Left"];
        switch-to-workspace-right=["<Super>Right"];
        toggle-maximized=["<Super>m"];
        toggle-message-tray=[];
      };
      "org/gnome/mutter/keybindings" = {
        toggle-tiled-left=["<Alt><Super>Left"];
        toggle-tiled-right=["<Alt><Super>Right"];
      };
      "org/gnome/settings-daemon/plugins/media-keys" = {
        custom-keybindings=[
          "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/"
          "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/"
          "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2/"
        ];
        home=["<Super>e"];
        www=["<Super>b"];
      };

      "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
        name = "terminal";
        command = "alacritty"; # alacritty -e byobu
        binding = "<Super>x";
      };
      "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1" = {
        name = "gnome-system-monitor";
        command = "gnome-system-monitor";
        binding = "<Shift><Control>Escape";
      };
      "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2" = {
        name = "restart gnome";
        command = "killall -3 gnome-shell";
        binding = "<Ctrl><Alt>BackSpace";
      };

      # gnome-shell-extensions
      "org/gnome/shell" = {
        disable-user-extensions = false;
        enabled-extensions = [
          "native-window-placement@gnome-shell-extensions.gcampax.github.com"
          "gsconnect@andyholmes.github.io"
          "dash-to-dock@micxgx.gmail.com"
          "appindicatorsupport@rgcjonas.gmail.com"
        ];
      };

      "org/gnome/shell/extensions/dash-to-dock" = {
        show-trash = false;
        hotkeys-show-dock = false;
        apply-custom-theme = true;
        hot-keys = false;
        disable-overview-on-startup = true;
      };
    };
  };
}