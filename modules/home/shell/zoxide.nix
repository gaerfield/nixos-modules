{ config, ... }: {
  programs.zoxide = {
    enable = true;

    enableBashIntegration = true;
    enableFishIntegration = true;
  };

  persistence.directories = [
    "${config.xdg.dataHome}/zoxide"
  ];
}
