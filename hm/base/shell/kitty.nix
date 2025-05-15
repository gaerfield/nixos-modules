{
  # https://wiki.nixos.org/wiki/Kitty
  programs.kitty = {  
    enable = true;
    # https://nix-community.github.io/home-manager/options.xhtml#opt-programs.kitty.enable
    themeFile = "Nord"; # https://github.com/kovidgoyal/kitty-themes/tree/master/themes
    # https://sw.kovidgoyal.net/kitty/conf/
    settings = {
      confirm_os_window_close = 0;
      dynamic_background_opacity = true;
      enable_audio_bell = false;
      mouse_hide_wait = "-1.0";
      window_padding_width = 10;
      background_opacity = "0.5";
      background_blur = 5;
      cursor_trail = 3;
    };
  };
}