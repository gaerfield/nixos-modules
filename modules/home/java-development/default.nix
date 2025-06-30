{config, pkgs, lib, ...}: with lib; let
  cfg = config.gnm.hm.javaDevelopment;
in {
  options.gnm.hm.javaDevelopment.enable = mkEnableOption "java dvelopment tools";

  config = mkIf cfg.enable {
    home.packages = with pkgs; [temurin-bin jetbrains.idea-ultimate jetbrains.datagrip];
    home.sessionVariables = {
      GRADLE_USER_HOME = "$XDG_DATA_HOME/gradle";
    };
  };
}
