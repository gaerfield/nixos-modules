{
  config,
  pkgs,
  inputs,
  ...
}: {
  xdg.enable = true;
  home.sessionVariables = {
    XDG_BIN_HOME = "${config.home.homeDirectory}/.local/bin";
  };
  home.sessionPath = ["$XDG_BIN_HOME"];

  # set cursor size and dpi for 4k monitor
  xresources.properties = {
    "Xcursor.size" = 16;
    "Xft.dpi" = 172;
  };
  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  home.packages = with pkgs; [alejandra nixd];
  nix.nixPath = ["nixpkgs=${inputs.nixpkgs}"];
}
