{ config, inputs, lib, pkgs, ... }: with lib; let
  cfg = config.gnm.gui;
in 
{
  imports = [ inputs.stylix.nixosModules.stylix ];
  config = mkIf cfg.enable {
    stylix = {
      enable = true;
      polarity = "light";
      image = pkgs.fetchurl {
        url = "https://raw.githubusercontent.com/D3Ext/aesthetic-wallpapers/main/images/acrylic.jpg";
        sha256 = "XfZKZrIxezZ+9J9ZpIqx2laSmg7m7BWzraC4JI/Go38=";
      };
      # https://tinted-theming.github.io/tinted-gallery/
      base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-latte.yaml";
      targets = {
        console.enable = false;
        grub.enable = false;
      };
      # opacity = {
      #   terminal = 0.9;
      #   popups = 0.8;
      # };

      # cursor = {
      #   package = pkgs.volantes-cursors;
      #   name = "volantes_cursors";
      #   size = 24;
      # };

      # fonts = {
      #   serif = config.stylix.fonts.monospace;
      #   sansSerif = config.stylix.fonts.monospace;
      #   monospace = {
      #     package = pkgs.nerd-fonts.jetbrains-mono;
      #     name = "JetBrainsMono Nerd Font";
      #   };
      # };
    };
  };
}
