{
  programs.yazi = {
    # https://yazi-rs.github.io/docs/configuration
    enable = true;
    settings = {
      mgr = {
        show_hidden = false;
        sort_by = "natural";
        sort_dir_first = true;
      };
    };
  };
}