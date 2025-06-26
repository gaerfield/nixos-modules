{pkgs, ...}: {
  # zlib is somehow required by java
  home.packages = with pkgs; [temurin-bin jetbrains.idea-ultimate jetbrains.datagrip];
  home.sessionVariables = {
    GRADLE_USER_HOME = "$XDG_DATA_HOME/gradle";
  };
}
