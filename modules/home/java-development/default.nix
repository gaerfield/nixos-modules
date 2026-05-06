{
  config,
  pkgs,
  lib,
  ...
}:
with lib; let
  cfg = config.gnm.hm.javaDevelopment;
in {
  options.gnm.hm.javaDevelopment.enable = mkEnableOption "java development tools";

  config = mkIf cfg.enable {
    home.packages = with pkgs; [temurin-bin jetbrains.idea jetbrains.datagrip];
    home.sessionVariables = {
      GRADLE_USER_HOME = "${config.xdg.dataHome}/gradle";
    };

    persistence.directories = with config.xdg; [
      "${dataHome}/gradle"

      "${config.home.homeDirectory}/.java" # fucked up java cache
      # simply keep all jetbrains products persisted
      "${config.home.homeDirectory}/IdeaProjects"
      "${configHome}/JetBrains"
      "${dataHome}/JetBrains"
      "${cacheHome}/JetBrains"
    ];
  };
}