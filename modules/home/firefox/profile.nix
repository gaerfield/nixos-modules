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
  openInExternalBrowserExtensionId = "{5cf4e3be-dd11-4589-befe-1b9e5037792b}";
  openInExternalBrowserXpiUrl = "https://addons.mozilla.org/firefox/downloads/file/3686239/open_in_waterfox-0.1.1.xpi";

  browserShimToXdgOpen = pkgs.callPackage ./browser-shim-to-xdg-open.nix {
    inherit pkgs;
    command = "waterfox";
    firefoxConfigDir = "${config.xdg.configHome}/mozilla/firefox";
  };

  firefoxProfileLauncher = pkgs.callPackage ./profile-launcher.nix {
    inherit pkgs profileNames routePatternsTsv;
  };

  mkProfile = profileName: profileCfg: {
    id = profileCfg.id;
    name = profileCfg.name;
    isDefault = profileCfg.isDefault;
    extensions.force = true;
    extensions.packages = lib.unique profileCfg.extensions;
  } // profileCfg.extraSettings;
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
            type = lib.types.listOf lib.types.package;
            default = [ ];
            description = "Firefox extension packages for this profile only.";
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

    home.packages = [ firefoxProfileLauncher ]
      ++ lib.optionals hasUrlRouting [ browserShimToXdgOpen.package ];

    gnm.hm.browserNativeClient.enable = lib.mkIf hasUrlRouting (lib.mkDefault true);

    programs.firefox.policies = lib.mkIf hasUrlRouting {
      ExtensionSettings = {
        "${openInExternalBrowserExtensionId}" = {
          install_url = openInExternalBrowserXpiUrl;
          installation_mode = "force_installed";
        };
      };
      "3rdparty" = {
        Extensions = {
          "${openInExternalBrowserExtensionId}" = {
            reverse = true;
            faqs = false;
              urls = allRouteUrls;
          };
        };
      };
    };
  };
}
