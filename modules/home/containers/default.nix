{
  config,
  pkgs,
  lib,
  ...
}:
with lib; let
  cfg = config.gnm.hm.containers;
in {
  options.gnm.hm.containers.enable = mkEnableOption "Enable containers user config";

  config = mkIf cfg.enable {
    programs.fish = {
      shellAbbrs.po = "podman";
      shellAbbrs.docker = "podman";
      shellAbbrs.dco = "podman compose";
      shellAbbrs.pco = "podman compose";
    };
  };
}