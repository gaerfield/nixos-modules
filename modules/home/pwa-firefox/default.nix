# that is in interesting discussion regarding configuration options: https://discourse.nixos.org/t/declare-firefox-extensions-and-settings/36265/26
# https://pwasforfirefox.filips.si/user-guide/browser/#open-out-of-scope-urls-in-the-default-browser
# GTK_USE_PORTAL=1
{ config, lib, pkgs, options, ... }:
let
  cfg = config.gnm.hm.pwaFirefox;
  #firefoxPwaLauncher = pkgs.callPackage ./launcher.nix { };
  instance = import ./instance.nix { inherit lib pkgs; };
  groupedApps = lib.groupBy (app: app.profile) cfg.apps;
  profiles = lib.mapAttrs' (profile: apps: lib.nameValuePair
    (instance.mkStableId "profile" profile)
    {
      name = profile;
      sites = builtins.listToAttrs (map (app: lib.nameValuePair
        (instance.mkStableId "site" app.id) (instance.site app)) apps);
      settings = {
        # Keep out-of-scope pages in-app with the URL bar visible for debugging.
        "firefoxpwa.enableHidingIconBar" = false;
        "firefoxpwa.openOutOfScopeInDefaultBrowser" = false;
        "firefoxpwa.linksTarget" = 1;
        "firefoxpwa.allowedDomains" = "";
        "browser.aboutConfig.showWarning" = false;
      };
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
      default = pkgs.firefox-esr-153-unwrapped;
      defaultText = lib.literalExpression "pkgs.firefox-esr-153-unwrapped";
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
    debugLogEffectiveSettings = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Log FirefoxPWA profile settings from config.json during activation for debugging.";
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
        {
          assertion = builtins.all
            (profile: (profile.settings."firefoxpwa.linksTarget" or null) != null)
            (builtins.attrValues profiles);
          message = "pwaFirefox: expected firefoxpwa.linksTarget in each generated profile settings map.";
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
          #runtime_use_portals = cfg.usePortals;
          # Use the runtime shipped by the Nix package instead of a separately downloaded runtime.
          #use_linked_runtime = true;
          #always_patch = true;
        };
      };
      programs.firefox.nativeMessagingHosts = [ pkgs.firefoxpwa ];
      
      #gnm.hm.browserNativeClient = {
      #  enable = true;
      #  extraFirefoxProfileDirs = map (id: "${config.xdg.dataHome}/firefoxpwa/profiles/${id}") (builtins.attrNames profiles);
      #};

      # xdg.desktopEntries = pwaDesktopEntries;

      home.packages = [ pkgs.firefoxpwa ];
    }
    (lib.mkIf cfg.debugLogEffectiveSettings {
      home.activation.pwaFirefoxDebugEffectiveSettings = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        cfg_path="${config.xdg.dataHome}/firefoxpwa/config.json"
        runtime_version="${pkgs.firefoxpwa-unwrapped.version}"
        runtime_mm="$(echo "$runtime_version" | ${pkgs.gnused}/bin/sed -E 's/^([0-9]+\.[0-9]+).*/\1/')"
        if [[ -f "$cfg_path" ]]; then
          echo "pwaFirefox debug: effective profile settings in $cfg_path"
          ${pkgs.jq}/bin/jq -c '.profiles | to_entries[] | { id: .key, name: .value.name, settings: (.value.settings // {}) }' "$cfg_path" || true

          echo "pwaFirefox debug: extension/runtime version check (runtime=$runtime_version)"
          ${pkgs.jq}/bin/jq -r '.profiles | keys[]' "$cfg_path" | while IFS= read -r profile_id; do
            ext_json="${config.xdg.dataHome}/firefoxpwa/profiles/$profile_id/extensions.json"
            if [[ ! -f "$ext_json" ]]; then
              echo "pwaFirefox debug: profile=$profile_id extensions.json missing"
              continue
            fi

            ext_version="$(${pkgs.jq}/bin/jq -r '.addons[] | select(.id == "firefoxpwa@filips.si") | .version' "$ext_json" | head -n1)"
            if [[ -z "$ext_version" ]]; then
              echo "pwaFirefox debug: profile=$profile_id addon firefoxpwa@filips.si not installed"
              continue
            fi

            ext_mm="$(echo "$ext_version" | ${pkgs.gnused}/bin/sed -E 's/^([0-9]+\.[0-9]+).*/\1/')"
            if [[ "$ext_mm" != "$runtime_mm" ]]; then
              echo "pwaFirefox debug: profile=$profile_id addon=$ext_version runtime=$runtime_version (major.minor mismatch)"
            else
              echo "pwaFirefox debug: profile=$profile_id addon=$ext_version runtime=$runtime_version (major.minor matches)"
            fi
          done
        else
          echo "pwaFirefox debug: missing $cfg_path"
        fi
      '';
    })
    (lib.optionalAttrs hasPersistence {
      persistence.directories = lib.mkIf cfg.persistProfiles profileDirectories;
    })
  ]);
}
