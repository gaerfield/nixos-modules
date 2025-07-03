{
  pkgs,
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.gnm.gui;
in {
  config = mkIf cfg.enable {
    # https://wiki.nixos.org/wiki/Fonts
    fonts = {
      packages = with pkgs; [
        # icon fonts
        material-design-icons

        # normal fonts
        noto-fonts
        noto-fonts-color-emoji
        noto-fonts-cjk-sans
        nerd-fonts.fira-code
        nerd-fonts.jetbrains-mono
        nerd-fonts.meslo-lg
      ];

      # use fonts specified by user rather than default ones
      enableDefaultPackages = true;

      # user defined fonts
      # the reason there's Noto Color Emoji everywhere is to override DejaVu's
      # B&W emojis that would sometimes show instead of some Color emojis
      fontconfig.defaultFonts = {
        serif = ["Noto Serif" "Noto Color Emoji"];
        sansSerif = ["Noto Sans" "Noto Color Emoji"];
        monospace = ["MesloLGS Nerd Font Mono" "Noto Color Emoji"];
        emoji = ["Noto Color Emoji"];
      };
    };
  };
}
