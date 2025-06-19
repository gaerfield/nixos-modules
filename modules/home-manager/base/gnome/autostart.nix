{ pkgs, lib, ... }: {
  xdg.configFile = {
    #"autostart/${pkgs.flameshot.pname}.desktop".text =
    #  let content = lib.readFile "${pkgs.flameshot}/share/applications/org.flameshot.Flameshot.desktop";
    #  in lib.replaceStrings [ "/usr/bin/flameshot" ] [ "flameshot" ] content;
  };
}