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
    enableScreenSharing = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Enable XDG portal integration for Chromium PWA apps.

        This enables the desktop portal on the user level so web apps can request
        microphone, camera, and screen-sharing access via the Hyprland portal backend.
      '';
    };
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
                title = "Teams";
                instanceName = "Teams-Work";
                url = "https://teams.microsoft.com";
                icon = ./icons/teams.png;
                cookieAllowlist = [
                  "https://*.microsoft.com"
                  "https://login.microsoftonline.com"
                  "https://*.live.com"
                  "https://*.office.com"
                ];
                extraChromiumFlags = [
                  "--allow-insecure-localhost"
                ];
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
      allowedChromiumExtensions = unique (map (_: instance.openInFirefoxExtensionId) cfg.apps);
    };

    xdg.portal = mkIf cfg.enableScreenSharing {
      enable = true;
      extraPortals = with pkgs; [
        xdg-desktop-portal-hyprland
      ];
    };

    home.packages = map instance.mkPwaLauncher cfg.apps;
    xdg.desktopEntries = pwaDesktopEntries;
    persistence.directories = persistedDirs;
  };
}
