{lib, ...}:
with lib; {
  imports = [
    ./gnome.nix
    # ./fonts.nix
    ./stylix.nix
  ];

  options.gnm.gui = {
    enable = mkEnableOption "Enable the GNOME GUI.";
  };
}
