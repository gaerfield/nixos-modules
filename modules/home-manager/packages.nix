{pkgs, ...}: {
  # move to configurations/nixos
  home.packages = with pkgs; [obsidian rambox teams-for-linux vlc];
}
