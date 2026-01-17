{ pkgs, ... }: {
  programs.yazi = {
    # https://yazi-rs.github.io/docs/configuration
    enable = true;
    settings = {
      mgr = {
        show_hidden = false;
        sort_by = "natural";
        sort_dir_first = true;
        prepend_keymap = [
          {
            # when yank, put files into the clipboard as well
            on  = "y";
            run = [ 
              "shell -- for path in \"$@\"; do echo \"file://$path\"; done | wl-copy -t text/uri-list"
              "yank"
            ];
          }
        ];
      };
      tasks = {
        # maximum 250MB allocation when opening an image
        # no other size restrictions
        image_alloc = 250000000; 
        image_bound = [0 0];
      };
      opener = {
        open = [
    	    { run = "swayimg -g %s"; desc = "swayimg gallery"; }
        ];
      };
    };
    plugins = with pkgs.yaziPlugins; {
      full-border = full-border;
      wl-clipboard = wl-clipboard;
    };
  };
  xdg.configFile."yazi/init.lua".source = ./config/init.lua;
  home.packages = with pkgs; [
    exiftool
    mpv
    mediainfo
  ];
}