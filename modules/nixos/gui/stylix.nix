{ config, lib, pkgs, ... }: with lib; let
  cfg = config.gnm.gui;
in 
{
  config = mkIf cfg.enable {
    stylix = {
      enable = true;
      # autoEnable = true;
      # polarity = "light";
      # image = pkgs.fetchurl {
      #   url = "https://raw.githubusercontent.com/zhichaoh/catppuccin-wallpapers/refs/heads/main/os/nix-black-4k.png";
      #   sha256 = "1d165878a0e67c0e7791bddf671b8d5af47c704f7ab4baea3d9857e3ecf89590";
      # };
      # https://tinted-theming.github.io/tinted-gallery/
      base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-frappe.yaml";

      # opacity = {
      #   terminal = 0.9;
      #   popups = 0.8;
      # };

      # cursor = {
      #   package = pkgs.volantes-cursors;
      #   name = "volantes_cursors";
      #   size = 24;
      # };

      fonts = {
        serif = config.stylix.fonts.monospace;
        sansSerif = config.stylix.fonts.monospace;
        monospace = {
          package = pkgs.nerd-fonts.jetbrains-mono;
          name = "JetBrainsMono Nerd Font";
        };
      };
    };
  };
}
