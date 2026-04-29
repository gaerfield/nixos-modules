{ config, ...}: {
  programs.tealdeer = {
    enable = true;
    settings = {
      display = {
        compact = true;
        use_pager = true;
      };
      updates = {
        auto_update = true;
      };
    };
  };

  persistence.directories = [
    { directory = "${config.xdg.cacheHome}/tealdeer"; mode = "0700"; }
  ];
}
