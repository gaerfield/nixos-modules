{ config, lib, pkgs, options, ... }:
let
  cfg = config.gnm.hm.pwaFirefox;
  firefoxPwaLauncher = pkgs.callPackage ./launcher.nix { };
  instance = import ./instance.nix { inherit lib pkgs firefoxPwaLauncher; };
  groupedApps = lib.groupBy (app: app.profile) cfg.apps;
  profiles = lib.mapAttrs' (profile: apps: lib.nameValuePair
    (instance.mkStableId "profile" profile)
    {
      name = profile;
      sites = builtins.listToAttrs (map (app: lib.nameValuePair
        (instance.mkStableId "site" app.id) (instance.site app)) apps);
    }) groupedApps;
  ids = map (app: app.id) cfg.apps;

  # Nixpkgs patches this runtime at build time and wraps it with the same
  # graphics/media environment as Firefox. No runtime install/link is needed.
  pwaPackage = pkgs.wrapFirefox
    (pkgs.firefoxpwa-unwrapped.override { firefoxRuntime = cfg.runtimePackage; })
    { };
  
  hasPersistence = lib.hasAttrByPath [ "persistence" "directories" ] options;
  
  profileDirectories = map
    (id: "${config.xdg.dataHome}/firefoxpwa/profiles/${id}")
    (builtins.attrNames profiles);

  pwaDesktopEntries = builtins.listToAttrs (
    map (app: {
      name = app.id;
      value = instance.pwaDesktopEntry app;
    }) cfg.apps
  );

in {
  options.gnm.hm.pwaFirefox = {
    enable = lib.mkEnableOption "declarative Firefox web apps";
    runtimePackage = lib.mkOption {
      type = lib.types.package;
      default = pkgs.firefox-esr-unwrapped;
      defaultText = lib.literalExpression "pkgs.firefox-esr-unwrapped";
      description = "Unwrapped Firefox runtime used by the Nixpkgs immutable-runtime package.";
    };
    enableWayland = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable FirefoxPWA's Wayland setting; existing environment variables take precedence.";
    };
    usePortals = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Use existing XDG desktop portals. Configure the desktop's portal backend separately.";
    };
    persistProfiles = lib.mkOption {
      type = lib.types.bool;
      default = hasPersistence;
      description = "Register profile directories with the persistence.directories.";
    };
    apps = lib.mkOption {
      type = lib.types.listOf (lib.types.submodule instance.appModule);
      default = [ ];
      description = "Web apps, isolated by default; set the same profile key to share browser data.";
    };
  };

  config = lib.mkIf cfg.enable (lib.mkMerge [
    {
      assertions = [
        {
          assertion = builtins.length ids == builtins.length (lib.unique ids);
          message = "pwaFirefox: app ids must be unique.";
        }
        {
          assertion = !cfg.persistProfiles || hasPersistence;
          message = "pwaFirefox: persistProfiles requires a module declaring persistence.directories.";
        }
        {
          assertion = pkgs.stdenv.hostPlatform.isLinux;
          message = "pwaFirefox: this module targets Linux.";
        }
      ] ++ map (app: {
        assertion = app.icon == null || app.iconUrl == null;
        message = "pwaFirefox: ${app.title} must set at most one of icon and iconUrl.";
      }) cfg.apps;

      programs.firefoxpwa = {
        enable = true;
        package = pwaPackage;
        inherit profiles;
        settings.config = {
          runtime_enable_wayland = cfg.enableWayland;
          runtime_use_portals = cfg.usePortals;
          use_linked_runtime = false;
          always_patch = false;
        };
      };

      xdg.desktopEntries = pwaDesktopEntries;

      home.packages = [ firefoxPwaLauncher ];
    }
    (lib.optionalAttrs hasPersistence {
      persistence.directories = lib.mkIf cfg.persistProfiles profileDirectories;
    })
  ]);
}
