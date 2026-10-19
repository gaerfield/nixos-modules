{
  config,
  lib,
  pkgs,
  apps,
  basePolicies ? { },
  cfg,
  defaultUserPreferences,
  profileId,
  pwaFirefoxDataDir,
  runtimePackage,
  ...
}:
let
  openInExternalBrowser = pkgs.callPackage ../firefox/open-in-external-browser-shared.nix { };

  preferenceValueType = lib.types.oneOf [
    lib.types.bool
    lib.types.int
    lib.types.float
    lib.types.str
  ];

  appModule = { config, ... }: with lib; {
    options = {
      title = mkOption {
        type = types.str;
        description = "Display name; may change without changing an explicit id.";
      };
      id = mkOption {
        type = types.strMatching "[a-z0-9][a-z0-9_-]*";
        default = toLower (replaceStrings [ " " ] [ "-" ] config.title);
        description = "Stable app key. Set explicitly before first use; keep unchanged to retain data.";
      };
      profile = mkOption {
        type = types.strMatching "[a-z0-9][a-z0-9_-]*";
        default = config.id;
        description = "Stable profile key. Apps with the same key share cookies, login and browser data.";
      };
      url = mkOption {
        type = types.strMatching "https?://[^[:space:]]+";
        description = "Start URL.";
      };
      extraUrls = mkOption {
        type = types.listOf types.str;
        default = [ ];
        example = [ "https://accounts.google.com/*" ];
        description = "Additional URL patterns included in managed open-in-external-browser extension settings.";
      };
      manifestUrl = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "Optional web manifest URL. Null also supports ordinary websites.";
      };
      icon = mkOption {
        type = types.nullOr (types.either types.path types.str);
        default = null;
        description = "Local Nix path literal, icon-theme name, /nix/store icon path string from a package, or pinned remote URL.";
      };
      iconUrl = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "Remote icon URL; requires iconHash. Mutually exclusive with icon.";
      };
      iconHash = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "Fixed-output hash for a remote icon.";
      };
      categories = mkOption {
        type = types.listOf types.str;
        default = [ "Network" ];
        description = "Desktop entry categories.";
      };
      keywords = mkOption {
        type = types.listOf types.str;
        default = [ ];
        description = "Desktop entry keywords.";
      };
      singleInstance = mkOption {
        type = types.bool;
        default = true;
        description = "Whether to allow only a single instance of the app.";
      };
      userPreferences = mkOption {
        type = types.attrsOf preferenceValueType;
        default = { };
        example = {
          "browser.startup.homepage" = "https://example.com";
          "browser.tabs.warnOnClose" = false;
        };
        description = "Profile-level user.js preference overrides contributed by this app.";
      };
    };
  };

  profileDir = "${pwaFirefoxDataDir}/profiles/${profileId}";
  profileRelativeDir = lib.removePrefix "${config.xdg.dataHome}/" profileDir;

  mkOpenInExternalBrowserPolicy =
    let
      profileUrls = lib.unique (lib.concatMap (app: [ app.url ] ++ app.extraUrls) apps);
    in openInExternalBrowser.mkPolicy {
      urls = profileUrls;
      reverse = true;
    };

  profileFirefoxPackage = pkgs.wrapFirefox runtimePackage {
    extraPolicies = lib.recursiveUpdate basePolicies mkOpenInExternalBrowserPolicy;
  };

  browserShimToXdgOpen = openInExternalBrowser.mkBrowserShimToXdgOpen {
    command = "waterfox";
    shimDir = openInExternalBrowser.mkShimDir {
      baseDir = profileDir;
      shimDirName = openInExternalBrowser.pwaFirefoxShimDirName;
    };
  };
  
  # launcher script generation
  appLaunchers = map (
    app: pkgs.callPackage ./launcher.nix {
      inherit app cfg profileDir;
      shimDir = browserShimToXdgOpen.shimDir;
      firefoxPackage = profileFirefoxPackage;
    }
  ) apps;

  # Desktop entry generation
  pwaDesktopEntries = builtins.listToAttrs ( map (
    app: {
      name = app.id;
      value = pwaDesktopEntry app;
    }
  ) apps );

  pwaDesktopEntry = app:
    let
      launcherName = "pwa-firefox-${app.id}";
      iconPath = appIcon app;
      desktopEntry = {
        name = app.title;
        genericName = app.title;
        exec = "${launcherName} %u";
        terminal = false;
        categories = app.categories;
        startupNotify = true;
        settings = {
          Keywords = lib.concatStringsSep ";" app.keywords;
        };
      };
    in
    if iconPath == null then desktopEntry else desktopEntry // { icon = toString iconPath; };
  
  appIcon = app: with lib;
    let source = if app.iconUrl != null then app.iconUrl else app.icon;
    in if source == null then null
    else if builtins.isPath source then source
    else if hasPrefix "https://" source || hasPrefix "http://" source then
      pkgs.fetchurl {
        url = source;
        hash = if app.iconHash != null then app.iconHash
          else throw "pwaFirefox: remote icon for ${app.title} requires iconHash.";
        name = "pwa-firefox-${app.id}-icon";
      }
    else if hasPrefix "/nix/store/" source then source
    else if hasPrefix "/" source || hasPrefix "./" source || hasPrefix "../" source then
      throw "pwaFirefox: use a Nix path literal for ${app.title}'s icon."
    else source;

  # profile configuration generation
  profileConfigFragment = {
      assertions = [
        {
          assertion = builtins.all (app: app.profile == profileId) apps;
          message = "pwaFirefox: profile fragment ${profileId} received apps from other profiles.";
        }
      ];
      xdg.desktopEntries = pwaDesktopEntries;
      home.packages = appLaunchers ++ [ browserShimToXdgOpen.package ];
      xdg.dataFile."${profileRelativeDir}/user.js" = {
        text = renderUserPreferences effectiveUserPreferences;
      };
      xdg.dataFile."${profileRelativeDir}/chrome/userChrome.css" = {
        text = ''
          /* Generated by gnm.hm.pwaFirefox: app-like chrome in windowed mode */
          #TabsToolbar,
          #PersonalToolbar,
          #sidebar-header,
          #titlebar {
            visibility: collapse !important;
          }

          #nav-bar {
            visibility: collapse !important;
          }

          #navigator-toolbox {
            border: 0 !important;
            max-height: 0 !important;
            opacity: 0 !important;
            overflow: hidden !important;
            visibility: collapse !important;
            pointer-events: none !important;
            transition: none !important;
          }
        '';
      };
      xdg.dataFile."${profileRelativeDir}/${openInExternalBrowser.pwaFirefoxShimDirName}/${browserShimToXdgOpen.command}" = {
        source = "${browserShimToXdgOpen.package}/bin/${browserShimToXdgOpen.command}";
      };
    };
  
  renderUserPreferences = userPreferences:
    lib.concatStringsSep "\n" (
      map (key: "user_pref(${builtins.toJSON key}, ${builtins.toJSON userPreferences.${key}});")
        (lib.attrNames userPreferences)
    );

  profileUserPreferences = builtins.foldl' (acc: app:
    acc // app.userPreferences
  ) { } apps;

  effectiveUserPreferences = defaultUserPreferences // profileUserPreferences;

in {
  inherit appModule profileConfigFragment profileDir;
}
