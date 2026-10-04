{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.gnm.hm.pwaChromium;
  instance = import ./instance.nix { inherit config lib pkgs; };

  pwaDesktopEntries = builtins.listToAttrs (
    map (app: let
      desktopEntry = instance.pwaDesktopEntry app;
    in {
      name = instance.appName app;
      value = desktopEntry;
    }) cfg.apps
  );

  persistedDirs = map instance.appDataDir cfg.apps;
in {
  options.gnm.hm.pwaChromium = {
    enable = mkEnableOption "enable Chromium PWA apps";
    apps = mkOption {
      type = types.listOf (types.submodule instance.appModule);
      default = [];
      description = ''
        The PWA app instances to create.

        Example:

          gnm.hm.pwaChromium = {
            enable = true;
            apps = [
              {
                title = "Gather";
                url = "https://app.v2.gather.town/app/big-long-id";
                iconUrl = "https://example.com/icons/gather.png";
                iconHash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
              }
              {
                title = "Gather Ops";
                url = "https://app.v2.gather.town/app/another-room";
                icon = ./icons/gather-ops.png;
              }
            ];
          };
      '';
    };
  };

  config = mkIf cfg.enable {
    gnm.hm.browserNativeClient = {
      enable = true;
      extraChromiumDataDirs = map instance.appDataDir cfg.apps;
    };

    home.packages = map instance.mkPwaLauncher cfg.apps;
    xdg.desktopEntries = pwaDesktopEntries;
    persistence.directories = persistedDirs;
  };
}
