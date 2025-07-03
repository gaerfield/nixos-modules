{lib, ...}:
with lib; {
  imports = [
    ./gnome.nix
    ./fonts.nix
  ];

  options.gnm.gui = {
    enable = mkEnableOption "Enable the GNOME GUI.";
  };
}
