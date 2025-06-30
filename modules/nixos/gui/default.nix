{ lib, ... }: with lib; {
  imports = [
    ./gnome.nix
    ./fonts.nix
  ];

  options.gnm.gui = {
    enable = mkEnableOption "Enable the GNOME GUI.";
    autologin = mkEnableOption "Enable automatic login for the main user.";
    mainuser = mkOption {
      type = types.str;
      default = "nixos";
      description = "The main user for the GNOME GUI.";
    };
  };
}
