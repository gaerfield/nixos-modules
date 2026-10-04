{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.gnm.hm.pwaChromium;

  sanitizeDesktopName = value:
    lib.toLower (
      lib.replaceStrings
      [ " " "/" ":" "\"" "'" "&" "+" "?" "(" ")" "[" "]" "{" "}" ]
      [ "-" "-" "-" "-" "-" "-" "-" "-" "-" "-" "-" "-" "-" "-" ]
      value
    );

  appName = app: sanitizeDesktopName app.title;
  appDataDir = app: "${config.xdg.configHome}/pwa-chromium/${appName app}";
  appCacheDir = app: "${config.xdg.cacheHome}/pwa-chromium/${appName app}";

  appIcon = app:
    let
      safeAppTitle = appName app;
      iconSource = if app.iconUrl != null then app.iconUrl else app.icon;
    in if iconSource == null then null else if builtins.isPath iconSource then iconSource else if lib.hasPrefix "http://" iconSource || lib.hasPrefix "https://" iconSource then
      pkgs.fetchurl {
        url = iconSource;
        hash = app.iconHash;
        name = "${safeAppTitle}-icon";
      }
    else if builtins.isString iconSource && (lib.hasPrefix "./" iconSource || lib.hasPrefix "../" iconSource || lib.hasPrefix "/" iconSource) then
      throw "Gather icon paths must be passed as Nix path literals, e.g. icon = ./gather-logo.png; rather than quoted strings."
    else
      iconSource;

  pwaExtensions = [
    {
      title = "Open in Firefox";
      id = "lmeddoobegbaiopohmpmmobpnpjifpii";
    }
  ];
  
  mkExtensionJson = app: ext: {
    name = "${appDataDir app}/External Extensions/${ext.id}.json";
    value = {
      text = builtins.toJSON {
        external_update_url = ext.updateUrl or "https://clients2.google.com/service/update2/crx";
      };
    };
  };

  pwaExtensionFiles = builtins.listToAttrs (
    concatMap (app: map (ext: mkExtensionJson app ext) pwaExtensions) cfg.apps
  );

  pwaApp = app:
    let
      safeAppTitle = appName app;
      launchScript = ''
        if command -v hyprctl >/dev/null 2>&1; then
          window="$(hyprctl clients -j | ${pkgs.jq}/bin/jq -r --arg app "${safeAppTitle}" '
            map(select((.class // "") | contains($app))) | .[0].address // empty
          ')"
          if [ -n "$window" ]; then
            hyprctl dispatch "hl.dsp.focus({ window = \"address:$window\" })"
            exit 0
          fi
        fi
    
        exec ${pkgs.chromium}/bin/chromium \
          --class=${safeAppTitle} \
          --user-data-dir="${appDataDir app}" \
          --disk-cache-dir="${appCacheDir app}" \
          --app="${app.url}" \
          --app-id=${safeAppTitle} \
          --no-first-run \
          "$@"
      '';
    in pkgs.writeShellScriptBin safeAppTitle launchScript;
  
  pwaDesktopEntries = builtins.listToAttrs (
    map (app: let
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
    in {
      name = safeAppTitle;
      value = if iconPath == null then desktopEntry else desktopEntry // { icon = toString iconPath; };
    }) cfg.apps
  );

  persistedDirs = lib.concatMap (app: [
    (appDataDir app)
    (appCacheDir app)
  ]) cfg.apps;
in {
  options.gnm.hm.pwaChromium = {
    enable = mkEnableOption "enable Chromium PWA apps";
    apps = mkOption {
      type = types.listOf (types.submodule {
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
        };
      });
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
      extraChromiumDataDirs = map appDataDir cfg.apps;
    };

    home.packages = map pwaApp cfg.apps;
    xdg.desktopEntries = pwaDesktopEntries;
    persistence.directories = persistedDirs;

    home.file = pwaExtensionFiles;
  };
}
