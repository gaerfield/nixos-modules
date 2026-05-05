{
  config,
  osConfig,
  lib,
  ...
}:
with lib; {
  config = mkIf osConfig.virtualisation.podman.enable {

    # user specific persistence for podman
    persistence.directories = [ "${config.xdg.dataHome}/containers" ];
    
    programs.fish = {
      shellAbbrs.po = "podman";
      shellAbbrs.docker = "podman";
      shellAbbrs.dco = "podman compose";
      shellAbbrs.pco = "podman compose";
    };
  };
}