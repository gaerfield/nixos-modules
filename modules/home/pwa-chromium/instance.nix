{ config, lib, pkgs, ... }:
with lib;
let
  appId = value:
    lib.toLower (
      lib.replaceStrings
      [ " " "/" ":" "\"" "'" "&" "+" "?" "(" ")" "[" "]" "{" "}" ]
      [ "-" "-" "-" "-" "-" "-" "-" "-" "-" "-" "-" "-" "-" "-" ]
      value
    );

  appName = app: appId app.title;
  appDataDir = app: "${config.xdg.configHome}/pwa-chromium/${appName app}";
  appCacheDir = app: "${config.xdg.cacheHome}/pwa-chromium/${appName app}";

  appIcon = app:
    let
      iconSource = if app.iconUrl != null then app.iconUrl else app.icon;
    in if iconSource == null then null else if builtins.isPath iconSource then iconSource else if lib.hasPrefix "http://" iconSource || lib.hasPrefix "https://" iconSource then
      pkgs.fetchurl {
        url = iconSource;
        hash = app.iconHash;
        name = "${appName app}-icon";
      }
    else if builtins.isString iconSource && (lib.hasPrefix "./" iconSource || lib.hasPrefix "../" iconSource || lib.hasPrefix "/" iconSource) then
      throw "PWA icon paths must be passed as Nix path literals, e.g. icon = ./icon.png; rather than quoted strings."
    else
      iconSource;

  openInFirefoxExtension = {
    id = "lmeddoobegbaiopohmpmmobpnpjifpii";
    updateUrl = "https://clients2.google.com/service/update2/crx";
  };

  browserPackage = pkgs.ungoogled-chromium;

  appOrigin = app:
    let
      match = builtins.match "^([a-zA-Z]+)://([^/]+).*" app.url;
      scheme = builtins.elemAt match 0;
      host = builtins.elemAt match 1;
    in "${scheme}://${host}";

  mkPwaPolicyDir = app:
    let
      cookieAllowlist = lib.unique ([ (appOrigin app) ] ++ app.cookieAllowlist);
      policy = {
        ExtensionInstallForcelist = [
          "${openInFirefoxExtension.id};${openInFirefoxExtension.updateUrl}"
        ];

        "3rdparty" = {
          extensions = {
            "${openInFirefoxExtension.id}" = {
              reverse = true;
              urls = [ "${app.url}*" ];
              faqs = false;
            };
          };
        };
      } // lib.optionalAttrs (cookieAllowlist != []) {
        CookiesAllowedForUrls = cookieAllowlist;
      };
    in pkgs.writeTextDir "managed/pwa.json" (builtins.toJSON policy);

  pwaDesktopEntry = app:
    let
      title = app.title;
      safeAppTitle = appName app;
      iconPath = appIcon app;
      desktopEntry = {
        name = title;
        genericName = title;
        exec = safeAppTitle;
        terminal = false;
        categories = [ "Network" "Chat" ];
        startupNotify = true;
        settings = {
          StartupWMClass = safeAppTitle;
        };
      };
    in if iconPath == null then desktopEntry else desktopEntry // { icon = toString iconPath; };

  mkPwaLauncher = app:
    pkgs.callPackage ./launcher.nix {
      inherit app appName appDataDir appCacheDir mkPwaPolicyDir;
      browserPackage = browserPackage;
      enableScreenSharing = config.gnm.hm.pwaChromium.enableScreenSharing;
      extraChromiumFlags = app.extraChromiumFlags or [];
    };
in {
  inherit appId appName appDataDir appCacheDir appIcon browserPackage mkPwaPolicyDir mkPwaLauncher pwaDesktopEntry;

  appModule = {
    options = {
      title = mkOption {
        type = types.str;
        description = "The display name for this PWA app. This also becomes the config and cache directory name. Example: \"Gather\".";
      };
      iconUrl = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "Optional remote icon URL to download and reuse as the desktop entry icon. Example: \"https://example.com/icons/gather.png\".";
      };
      icon = mkOption {
        type = types.nullOr (types.oneOf [ types.path types.str ]);
        default = null;
        description = "Optional local icon file as a Nix path literal, e.g. ./icons/gather.png. Do not pass a quoted relative string such as \"./gather.png\".";
      };
      iconHash = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "Optional sha256 hash required when iconUrl points to a remote asset. Example: \"sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=\".";
      };
      url = mkOption {
        type = types.str;
        description = "The URL to open in Chromium app mode. Example: \"https://app.v2.gather.town/app/73f14dcd-9d94-434f-893e-f35291385057\".";
      };
      cookieAllowlist = mkOption {
        type = types.listOf types.str;
        default = [];
        description = ''
          Additional URL patterns that should be allowed to set cookies beyond the
          app's own origin derived from the configured URL.

          Example values:
            - "https://*.gather.town"
            - "https://login.microsoftonline.com"
        '';
      };
      extraChromiumFlags = mkOption {
        type = types.listOf types.str;
        default = [];
        description = ''
          Extra command-line flags passed only to this Chromium PWA app.

          This is useful for app-specific flags like Wayland/PipeWire capture or
          other browser workarounds that should not be shared with other apps.
        '';
      };
    };
  };
}
