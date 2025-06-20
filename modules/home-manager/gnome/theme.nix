{pkgs, ...}: {
  gtk = {
    enable = true;

    iconTheme = {
      name = "Papirus-Light";
      package = pkgs.papirus-icon-theme;
    };

    theme = {
      name = "Arc-Darker";
      package = pkgs.arc-theme;
    };

    cursorTheme = {
      name = "Bibata-Modern-Classic";
      package = pkgs.bibata-cursors;
    };

    gtk3.extraConfig = {
      Settings = ''
        gtk-application-prefer-dark-theme=0
      '';
    };

    gtk4.extraConfig = {
      Settings = ''
        gtk-application-prefer-dark-theme=0
      '';
    };
  };
}
