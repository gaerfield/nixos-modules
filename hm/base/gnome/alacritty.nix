{ pkgs, config, ... }: {
  home.packages = [ pkgs.alacritty ];

  # add environment variables
  home.sessionVariables = {
    TERMINAL = "alacritty";
  };

  # this comes from: https://github.com/alacritty/alacritty-theme/blob/master/themes/nordic.toml
  xdg.configFile."alacritty/theme.toml".text = ''
    # Colors (Nordic)

    [colors.primary]
    background = '#242933'
    foreground = '#BBBDAF'

    [colors.normal]
    black = '#191C1D'
    red = '#BD6062'
    green = '#A3D6A9'
    yellow = '#F0DFAF'
    blue = '#8FB4D8'
    magenta = '#C7A9D9'
    cyan = '#B6D7A8'
    white = '#BDC5BD'

    [colors.bright]
    black = '#727C7C'
    red = '#D18FAF'
    green = '#B7CEB0'
    yellow = '#BCBCBC'
    blue = '#E0CF9F'
    magenta = '#C7A9D9'
    cyan = '#BBDA97'
    white = '#BDC5BD'

    [colors.selection]
    text = '#000000'
    background = '#F0DFAF'
  '';

  # https://github.com/alacritty/alacritty/issues/6999#issuecomment-1903342590
  xdg.configFile."alacritty/alacritty.toml".text = ''
  [general]
  import = [
    "${config.xdg.configHome}/alacritty/theme.toml"
  ]
  [font]
  normal = { family = "MesloLGS Nerd Font Mono", style = "Regular" }
  bold = { family = "MesloLGS Nerd Font Mono", style = "Bold" }
  italic = { family = "MesloLGS Nerd Font Mono", style = "Italic" }
  [window]
  padding = { x = 2, y = 2 }
  decorations = "Full"
  [bell]
  animation = "EaseOutExpo"
  duration = 0
  color = "#777696"
  command = "None"
  [selection]
  # Characters that are used as separators for "semantic words" in Alacritty
  #semantic_escape_chars = ",│`|:\"' ()[]{}<>\\t"  # Default: ",│`|:\"' ()[]{}<>\\t"
  save_to_clipboard = false
  '';
}