{
  config,
  pkgs,
  lib,
  ...
}:
with lib; let
  cfg = config.gnm.hm.gnome;
in {
  imports = [
    # ./theme.nix
    ./autostart.nix
    ./flameshot.nix
    ./notifications.nix
    ./gnome-extensions.nix
  ];

  options.gnm.hm.gnome.enable = mkEnableOption "Enable gnome user config";

  config = mkIf cfg.enable {
    fonts.fontconfig.enable = true;

    # TODO remove when `pkgs.cantarell-fonts` is no more broken on darwin
    #home.packages = lib.optionals pkgs.stdenv.isLinux ([
    #  pkgs.cantarell-fonts
    #  (pkgs.nerd-fonts.override { fonts = [ "RobotoMono" ]; })
    #
    #  pkgs.papirus-icon-theme
    #  pkgs.yaru-theme
    #] ++ extensions);

    home.packages = with pkgs; [
      meld
      # gstreamer plugins hopefully displaying some metadata infos in nautilus
      gst_all_1.gst-plugins-good
    ];

    persistence = {
      directories = with config.xdg; [
          "${cacheHome}/glycin"          # image editor - https://gnome.pages.gitlab.gnome.org/glycin/
          "${cacheHome}/gtk-4.0"
          "${cacheHome}/tracker3"        # gnome file indexer
          "${cacheHome}/gstreamer-1.0"   # multimedia cache - enabled in os-level gnome
          "${dataHome}/gedit"
          "${dataHome}/gnome-settings-daemon" # enabled in os-level gnome
          "${dataHome}/gnome-shell"
          "${dataHome}/gvfs-metadata"   # metadata for gvfs (e.g. nautilus)
          "${dataHome}/icc"             # color profiles for display calibration
          "${dataHome}/keyrings"        # gnome keyring
          "${dataHome}/mime"            # mime-type associations
          "${dataHome}/sounds"          # individual notification sounds (login, etc.)
          "${dataHome}/themes"          # user themes (e.g. gtk, icons, cursor)
      ];

      files = with config.xdg; [
        "${dataHome}/recently-used.xbel"    # recently opened files
      ];
    };

    # useful commands:
    # * `dconf watch /`
    # * `dconf dump / | dconf2nix > dconf.nix` (see: https://github.com/nix-community/dconf2nix)
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
          disabled = ["org.gnome.Contacts.desktop"];
          sort-order = ["org.gnome.Documents.desktop" "org.gnome.Nautilus.desktop"];
        };
        # super + right click allows for resizing windows
        "org/gnome/desktop/wm/preferences" = {
          # super + left = move windows, super + right = resize windows
          mouse-button-modifier = "<Super>";
          resize-with-right-button = true;
          button-layout = "appmenu:minimize,close";
        };
        "org/gnome/desktop/wm/keybindings" = {
          close = ["<Super>q"];
          cycle-group = ["<Super>Tab"];
          cycle-group-backward = ["<Shift><Super>Tab"];
          minimize = ["<Super>w"];
          move-to-monitor-left = ["<Shift><Super>Left"];
          move-to-monitor-right = ["<Shift><Super>Right"];
          move-to-workspace-left = ["<Control><Super>Left"];
          move-to-workspace-right = ["<Control><Super>Right"];
          switch-applications = ["<Alt>Tab"];
          switch-applications-backward = ["<Shift><Alt>Tab"];
          switch-to-workspace-left = ["<Super>Left"];
          switch-to-workspace-right = ["<Super>Right"];
          toggle-maximized = ["<Super>m"];
          toggle-message-tray = [];
        };
        "org/gnome/mutter/keybindings" = {
          toggle-tiled-left = ["<Alt><Super>Left"];
          toggle-tiled-right = ["<Alt><Super>Right"];
        };
        "org/gnome/settings-daemon/plugins/media-keys" = {
          custom-keybindings = [
            "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/"
            "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/"
            "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2/"
          ];
          home = ["<Super>e"];
          www = ["<Super>b"];
        };

        "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
          name = "terminal";
          command = "kitty";
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
      };
    };
  };
}
