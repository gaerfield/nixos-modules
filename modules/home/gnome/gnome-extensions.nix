{ config, pkgs, ... }: {
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
  ];

  persistence.directories = with config.xdg; [
    "${dataHome}/gnome-shell-extensions"
    "${dataHome}/glib-2.0"
    "${cacheHome}/clipboard-indicator@tudmotu.com"
  ];

  dconf.settings = {
    # gnome-shell-extensions
    "org/gnome/shell" = {
      disable-user-extensions = false;
      enabled-extensions = [
        "native-window-placement@gnome-shell-extensions.gcampax.github.com"
        "gsconnect@andyholmes.github.io"
        "dash-to-dock@micxgx.gmail.com"
        "appindicatorsupport@rgcjonas.gmail.com"
        "clipboard-indicator@tudmotu.com"
        "gnome-ui-tune@itstime.tech"
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
}
