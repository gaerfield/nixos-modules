{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.gnm.hm.terminal;
in {
  options.gnm.hm.terminal.enable = mkEnableOption "Enable the kitty terminal";

  config = mkIf cfg.enable {
    stylix.targets.kitty.enable = false;
    # https://wiki.nixos.org/wiki/Kitty
    programs.kitty = {
      enable = true;
      # https://nix-community.github.io/home-manager/options.xhtml#opt-programs.kitty.enable
      themeFile = "Catppuccin-Frappe"; # https://github.com/kovidgoyal/kitty-themes/tree/master/themes
      # https://sw.kovidgoyal.net/kitty/conf/
      settings = {
        confirm_os_window_close = 0;
        dynamic_background_opacity = false;
        enable_audio_bell = false;
        mouse_hide_wait = "-1.0";
        window_padding_width = 10;
        cursor_trail = 3;
      };
    };

    home.sessionVariables = {
      TERMINAL = "kitty";
    };
  };
}
