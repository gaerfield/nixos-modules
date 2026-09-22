{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.gnm.hm.gather;

  sanitizeDesktopName = value:
    lib.toLower (
      lib.replaceStrings
      [ " " "/" ":" "\"" "'" "&" "+" "?" "(" ")" "[" "]" "{" "}" ]
      [ "-" "-" "-" "-" "-" "-" "-" "-" "-" "-" "-" "-" "-" "-" ]
      value
    );

  appIcon = app:
    let
      appTitle = app.appTitle;
      safeAppTitle = sanitizeDesktopName appTitle;
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

  gatherApp = app:
    let
      appTitle = app.appTitle;
      safeAppTitle = sanitizeDesktopName appTitle;
      profileDir = "${config.xdg.configHome}/${safeAppTitle}";
      cacheDir = "${config.xdg.cacheHome}/${safeAppTitle}";
      launchScript = ''
        if command -v hyprctl >/dev/null 2>&1; then
          window="$(hyprctl clients -j | ${pkgs.jq}/bin/jq -r --arg app "${safeAppTitle}" '
            map(select((.class // "") | contains($app))) | .[0].address // empty
          ')"
          if [ -n "$window" ]; then
            hyprctl dispatch "hl.dsp.focus({ window = "address:$window" })"
            exit 0
          fi
        fi

        exec ${pkgs.chromium}/bin/chromium \
          --class=${safeAppTitle} \
          --user-data-dir="${profileDir}" \
          --disk-cache-dir="${cacheDir}" \
          --profile-directory="${safeAppTitle}" \
          --app="${app.url}" \
          --no-first-run \
          "$@"
      '';
    in pkgs.writeShellScriptBin safeAppTitle launchScript;

  gatherDesktopEntries = builtins.listToAttrs (
    map (app: let
      appTitle = app.appTitle;
      safeAppTitle = sanitizeDesktopName appTitle;
      iconPath = appIcon app;
      desktopEntry = {
        name = appTitle;
        genericName = appTitle;
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

  persistedDirs = lib.concatMap (
    app: let
      appTitle = app.appTitle;
      dirName = sanitizeDesktopName appTitle;
    in [
      "${config.xdg.configHome}/${dirName}"
      "${config.xdg.cacheHome}/${dirName}"
    ]
  ) cfg.apps;
in {
  options.gnm.hm.gather = {
    enable = mkEnableOption "enable Gather Town Chromium apps";
    apps = mkOption {
      type = types.listOf (types.submodule {
        options = {
          appTitle = mkOption {
            type = types.str;
            description = "The display name for this Gather app. This also becomes the config and cache directory name. Example: \"Gather\".";
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
            description = "The Gather URL to open in Chromium app mode. Example: \"https://app.v2.gather.town/app/73f14dcd-9d94-434f-893e-f35291385057\".";
          };
        };
      });
      default = [];
      description = ''
        The Gather app instances to create.

        Example:

          gnm.hm.gather = {
            enable = true;
            apps = [
              {
                appTitle = "Gather";
                url = "https://app.v2.gather.town/app/big-long-id";
                iconUrl = "https://example.com/icons/gather.png";
                iconHash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
              }
              {
                appTitle = "Gather Ops";
                url = "https://app.v2.gather.town/app/another-room";
                icon = ./icons/gather-ops.png;
              }
            ];
          };
      '';
    };
  };

  config = mkIf cfg.enable {
    home.packages = map gatherApp cfg.apps;
    xdg.desktopEntries = gatherDesktopEntries;
    persistence.directories = persistedDirs;
  };
}
