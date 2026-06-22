{ pkgs, ... }: {
  programs.yazi = {
    # https://yazi-rs.github.io/docs/configuration
    enable = true;
    shellWrapperName = "yy";
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
        gallery = [
          { run = "swayimg -g %s"; desc = "swayimg Gallery"; }
        ];
        swayimg = [
          { run = "swayimg %s"; desc = "swayimg"; }
        ];
      };
      open = {
        # These are the defaults from: https://github.com/sxyazi/yazi/blob/main/yazi-config/preset/yazi-default.toml
        # docs: https://yazi-rs.github.io/docs/configuration/yazi/#open
        # uncommented matchers got a custom opener appended (like swayimg_gallery)
        # sadly the user array gets overwritten instead of merged with the default one, so I have to copy all the defaults here and then add my custom ones
        prepend_rules = [
          # Folder
          { url = "*/"; use = [ "edit" "open" "reveal" "gallery" ]; }
          # Text
          #{ mime = "text/*"; use = [ "edit" "reveal" ]; }
          # Image
          { mime = "image/*"; use = [ "open" "reveal" "swayimg" ]; }
          # Media
          #{ mime = "{audio,video}/*"; use = [ "play" "reveal" ]; }
          # Code
          #{ mime = "application/{json,ndjson,javascript,wine-extension-ini}"; use = [ "edit" "reveal" ]; }
          # Archive
          #{ mime = "application/{zip,rar,7z*,tar,gzip,xz,zstd,bzip*,lzma,compress,archive,cpio,arj,xar,ms-cab*}"; use = [ "extract" "reveal" ]; }
          # Empty file
          #{ mime = "inode/empty"; use = [ "edit" "reveal" ]; }
          # Virtual file system
          #{ mime = "vfs/{absent,stale}"; use = "download" }
          # Fallback
          #{ url = "*"; use = [ "open" "reveal" ]; }
        ];
      };       
    };
    plugins = with pkgs.yaziPlugins; {
      full-border = full-border;
      wl-clipboard = wl-clipboard;
    };
  };
  xdg.configFile."yazi/init.lua".source = ./config/init.lua;
  # https://github.com/sxyazi/yazi/tree/shipped/yazi-config/preset
  xdg.configFile."yazi/keymap.toml".source = ./config/keymap.toml;
  
  home.packages = with pkgs; [
    exiftool
    mpv
    mediainfo
  ];
}