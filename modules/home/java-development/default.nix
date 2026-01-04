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
  };
}