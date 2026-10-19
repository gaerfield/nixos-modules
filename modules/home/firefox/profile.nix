{ config, lib, pkgs, ... }:
let
  cfg = config.gnm.hm.firefoxProfiles;
  profileNames = builtins.attrNames cfg.profiles;
  routeProfiles = lib.filter (name: (cfg.profiles.${name}.routeUrls or [ ]) != [ ]) profileNames;
  allRouteUrls = lib.unique (lib.concatMap (profile: cfg.profiles.${profile}.routeUrls) routeProfiles);
  hasUrlRouting = allRouteUrls != [ ];
  routePatternsTsv =
    lib.concatMapStringsSep "\n" (profile:
      lib.concatMapStringsSep "\n" (pattern: "${profile}\t${pattern}") cfg.profiles.${profile}.routeUrls
    ) routeProfiles;
  openInExternalBrowser = pkgs.callPackage ./open-in-external-browser-shared.nix { };

  browserShimToXdgOpen = openInExternalBrowser.mkBrowserShimToXdgOpen { command = "waterfox"; };

  firefoxProfileLauncher = pkgs.callPackage ./profile-launcher.nix {
    inherit pkgs profileNames routePatternsTsv;
    firefoxPackage = config.programs.firefox.package;
  };

  profileIcon = profileName: profileCfg:
    if builtins.isPath profileCfg.icon then profileCfg.icon else if lib.hasPrefix "http://" profileCfg.icon || lib.hasPrefix "https://" profileCfg.icon then
      if profileCfg.iconHash == null then
        throw "gnm.hm.firefoxProfiles.profiles.${profileName}.iconHash must be set when icon is a remote URL."
      else
        pkgs.fetchurl {
          url = profileCfg.icon;
          hash = profileCfg.iconHash;
          name = "firefox-profile-${profileName}-icon";
        }
    else if builtins.isString profileCfg.icon && (lib.hasPrefix "./" profileCfg.icon || lib.hasPrefix "../" profileCfg.icon || lib.hasPrefix "/" profileCfg.icon) then
      throw "Firefox profile icon paths must be passed as Nix path literals, e.g. icon = ./icon.png; rather than quoted strings."
    else
      profileCfg.icon;

  profileDesktopEntries = lib.mapAttrs' (profileName: profileCfg: {
    name = "firefox-profile-${profileName}";
    value = {
      name = profileCfg.name;
      genericName = profileCfg.name;
      exec = "${firefoxProfileLauncher}/bin/firefox-profile-launcher ${lib.escapeShellArg profileName}";
      icon = toString (profileIcon profileName profileCfg);
      terminal = false;
      categories = profileCfg.categories;
      startupNotify = true;
      settings = {
        StartupWMClass = profileName;
        Keywords = lib.concatStringsSep ";" profileCfg.keywords;
      };
    };
  }) cfg.profiles;

  defaultSettings = {
    # prevents Firefox from disabling newly added or side-loaded extensions upon startup.
    "extensions.autoDisableScopes" = 0;
  };

  mkProfile = profileName: profileCfg:
    let
      normalizeExtension = extension:
        if lib.isDerivation extension then {
          package = extension;
          id = null;
          force = true;
          settings = { };
        } else extension;

      normalizedExtensions = map normalizeExtension profileCfg.extensions;
      configuredPackages = map (extensionCfg: extensionCfg.package) normalizedExtensions;
      configuredExtensionSettings = builtins.listToAttrs (
        map (extensionCfg: {
          name = extensionCfg.id;
          value = { force = extensionCfg.force; } // extensionCfg.settings;
        }) (lib.filter (extensionCfg: extensionCfg.id != null) normalizedExtensions)
      );
      baseProfile = {
        id = profileCfg.id;
        name = profileCfg.name;
        isDefault = profileCfg.isDefault;
        extensions.force = true;
        extensions.packages = lib.unique configuredPackages;
        extensions.settings = configuredExtensionSettings;
        settings = defaultSettings // (profileCfg.extraSettings.settings or { });
      };
      extraSettingsWithoutSettings = removeAttrs profileCfg.extraSettings [ "settings" ];
    in baseProfile // extraSettingsWithoutSettings;
in {
  options.gnm.hm.firefoxProfiles = {
    enable = lib.mkEnableOption "custom Firefox profiles with declarative addon sets";

    profiles = lib.mkOption {
      type = lib.types.attrsOf (lib.types.submodule ({ name, ... }: {
        options = {
          id = lib.mkOption {
            type = lib.types.int;
            description = "Numeric Firefox profile id.";
          };

          name = lib.mkOption {
            type = lib.types.str;
            default = name;
            description = "Profile display name in Firefox profile manager.";
          };

          isDefault = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = "Whether this profile should be marked as the default profile.";
          };

          extensions = lib.mkOption {
            type = lib.types.listOf (lib.types.oneOf [
              lib.types.package
              (lib.types.submodule ({ ... }: {
                options = {
                  package = lib.mkOption {
                    type = lib.types.package;
                    description = "Firefox extension package to install.";
                  };

                  id = lib.mkOption {
                    type = lib.types.nullOr lib.types.str;
                    default = null;
                    description = "Firefox extension id used as extensions.settings.<id>. Set this when using force/settings.";
                  };

                  force = lib.mkOption {
                    type = lib.types.bool;
                    default = true;
                    description = "Whether to force-enable this extension in extensions.settings.<id>.force.";
                  };

                  settings = lib.mkOption {
                    type = lib.types.attrs;
                    default = { };
                    description = "Additional settings merged into extensions.settings.<id>.";
                  };
                };
              }))
            ]);
            default = [ ];
            description = "Firefox extension entries for this profile. Use package-only entries for simple installs, or attrset entries with package/id/force/settings for per-extension configuration.";
          };

          icon = lib.mkOption {
            type = lib.types.oneOf [ lib.types.path lib.types.str ];
            default = "firefox";
            description = "Desktop icon name, local icon path, or remote icon URL. Local files should be passed as Nix path literals, for example ./icons/work.png.";
          };

          iconHash = lib.mkOption {
            type = lib.types.nullOr lib.types.str;
            default = null;
            description = "sha256 hash required when icon is a remote URL.";
          };

          categories = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            default = [ "Network" "WebBrowser" ];
            description = "Desktop entry categories for this profile launcher.";
          };

          keywords = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            default = [ "browser" "firefox" "profile" ];
            description = "Desktop entry keywords for this profile launcher.";
          };

          routeUrls = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            default = [ ];
            example = [
              "https://console.cloud.google.com/*"
              "https://auth0.com/*"
            ];
            description = ''
              URL glob patterns that should be routed to this profile.

              Important behavior:
              - Route definitions from all profiles are aggregated globally into one
                Open in Waterfox policy list.
              - Therefore, matching links are intercepted from any profile, not only
                from this profile.
              - After interception, firefox-profile-launcher resolves the final target
                profile using the aggregated route map and opens/focuses that profile.
            '';
          };

          extraSettings = lib.mkOption {
            type = lib.types.attrs;
            default = { };
            description = "Additional Home Manager programs.firefox.profiles.<name> attributes.";
          };
        };
      }));
      default = { };
      description = "Declarative Firefox profiles keyed by profile name.";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.firefox.profiles = lib.mapAttrs mkProfile cfg.profiles;
    xdg.desktopEntries = profileDesktopEntries;

    home.packages = [ firefoxProfileLauncher ]
      ++ lib.optionals hasUrlRouting [ browserShimToXdgOpen.package ];

    gnm.hm.browserNativeClient.enable = lib.mkIf hasUrlRouting (lib.mkDefault true);

    programs.firefox = {
      policies = lib.mkIf hasUrlRouting (openInExternalBrowser.mkPolicy {
        urls = allRouteUrls;
        reverse = false;
      });
    };
  };
}
