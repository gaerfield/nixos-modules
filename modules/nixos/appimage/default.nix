{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.gnm.appimage;
in {
  options.gnm.appimage.enable = mkEnableOption "enable AppImage support";

  config = mkIf cfg.enable {
    # https://nixos.wiki/wiki/Appimage
    programs.appimage = {
      enable = true;
      binfmt = true;
      package = pkgs.appimage-run.override {
        extraPkgs = pkgs: [
          # missing libraries here, e.g.: `pkgs.libepoxy`
          pkgs.xorg.libxshmfence
        ];
      };
    };
  };
}
