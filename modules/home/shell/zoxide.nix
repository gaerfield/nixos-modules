{ config, ... }: {
  programs.zoxide = {
    enable = true;

    enableBashIntegration = true;
    enableFishIntegration = true;
  };

  persistence.directories = [
    { directory = "${config.xdg.dataHome}/zoxide"; mode = "0700"; }
  ];
}
