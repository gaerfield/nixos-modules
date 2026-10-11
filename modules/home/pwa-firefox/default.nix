# that is in interesting discussion regarding configuration options: https://discourse.nixos.org/t/declare-firefox-extensions-and-settings/36265/26
# https://pwasforfirefox.filips.si/user-guide/browser/#open-out-of-scope-urls-in-the-default-browser
# GTK_USE_PORTAL=1
{ config, lib, pkgs, ... }:
let
  cfg = config.gnm.hm.pwaFirefox;
  pwaFirefoxDataDir = "${config.xdg.dataHome}/pwa-firefox";
  lockFalse = { Value = false; Status = "locked"; };
  lockTrue = { Value = true; Status = "locked"; };
  defaultPolicies = {
    DisableTelemetry = true;
    DisableFirefoxStudies = true;
    EnableTrackingProtection = {
      Value = true;
      Locked = true;
      Cryptomining = true;
      Fingerprinting = true;
    };
    DisablePocket = true;
    DisableFirefoxAccounts = true;
    DisableAccounts = true;
    DisableFirefoxScreenshots = true;
    OverrideFirstRunPage = "";
    OverridePostUpdatePage = "";
    DontCheckDefaultBrowser = true;
    DisplayBookmarksToolbar = "never"; # alternatives: "always" or "newtab"
    DisplayMenuBar = "default-off"; # alternatives: "always", "never" or "default-on"
    Preferences = {
      #"browser.contentblocking.category" = { Value = "strict"; Status = "locked"; };
      "extensions.pocket.enabled" = lockFalse;
      "extensions.screenshots.disabled" = lockTrue;
      "browser.topsites.contile.enabled" = lockFalse;
      "browser.formfill.enable" = lockFalse;
      "browser.search.suggest.enabled" = lockFalse;
      "browser.search.suggest.enabled.private" = lockFalse;
      "browser.urlbar.suggest.searches" = lockFalse;
      "browser.urlbar.showSearchSuggestionsFirst" = lockFalse;
      "browser.newtabpage.activity-stream.feeds.section.topstories" = lockFalse;
      "browser.newtabpage.activity-stream.feeds.snippets" = lockFalse;
      "browser.newtabpage.activity-stream.section.highlights.includePocket" = lockFalse;
      "browser.newtabpage.activity-stream.section.highlights.includeBookmarks" = lockFalse;
      "browser.newtabpage.activity-stream.section.highlights.includeDownloads" = lockFalse;
      "browser.newtabpage.activity-stream.section.highlights.includeVisited" = lockFalse;
      "browser.newtabpage.activity-stream.showSponsored" = lockFalse;
      "browser.newtabpage.activity-stream.system.showSponsored" = lockFalse;
      "browser.newtabpage.activity-stream.showSponsoredTopSites" = lockFalse;
    };
  };

  # Used only to obtain appModule option schema; must not depend on config.
  instanceBaseDataDir = "/var/empty/pwa-firefox";
  instanceBase = import ./instance.nix {
    inherit config lib pkgs;
    pwaFirefoxDataDir = instanceBaseDataDir;
    apps = [ ];
    cfg = {
      enableWayland = true;
      usePortals = true;
    };
    defaultUserPreferences = { };
    runtimePackage = pkgs.firefox;
    profileId = "base";
  };
  userPreferenceType = lib.types.oneOf [
    lib.types.bool
    lib.types.int
    lib.types.float
    lib.types.str
  ];

in {
  options.gnm.hm.pwaFirefox = {
    enable = lib.mkEnableOption "declarative Firefox web apps";
    runtimePackage = lib.mkOption {
      type = lib.types.package;
      default = pkgs.firefox-esr-153-unwrapped;
      defaultText = lib.literalExpression "pkgs.firefox-esr-153-unwrapped";
      description = "Unwrapped Firefox package used by generated app launchers.";
    };
    enableWayland = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Set MOZ_ENABLE_WAYLAND=1 in app launchers when not already set.";
    };
    usePortals = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Set GTK_USE_PORTAL=1 in app launchers when not already set.";
    };
    persistProfiles = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Register profile directories with the persistence.directories.";
    };
    debugLogEffectiveSettings = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Log generated launcher/profile mapping during activation for debugging.";
    };
    apps = lib.mkOption {
      type = lib.types.listOf (lib.types.submodule instanceBase.appModule);
      default = [ ];
      description = "Web apps, isolated by default; set the same profile key to share browser data.";
    };
    userPreferences = lib.mkOption {
      type = lib.types.attrsOf userPreferenceType;
      default = {
        "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
        "browser.tabs.drawInTitlebar" = false;
      };
      example = {
        "browser.tabs.warnOnClose" = false;
        "widget.gtk.non-native-titlebar-buttons.enabled" = false;
      };
      description = "Default Firefox user preferences written to each generated profile's user.js.";
    };
    policyOverrides = lib.mkOption {
      type = lib.types.attrs;
      default = { };
      example = {
        DisplayBookmarksToolbar = "always";
        EnableTrackingProtection.Fingerprinting = false;
      };
      description = "Per-key overrides merged into the module's built-in Firefox enterprise policy baseline.";
    };
  };

  config = lib.mkIf cfg.enable (
    let
      ids = map (app: app.id) cfg.apps;
      basePolicies = lib.recursiveUpdate defaultPolicies cfg.policyOverrides;
      appsByProfile = lib.groupBy (app: app.profile) cfg.apps;

      mkProfileInstance = profileId: profileApps:
        import ./instance.nix {
          inherit config lib pkgs cfg profileId pwaFirefoxDataDir basePolicies;
          apps = profileApps;
          defaultUserPreferences = cfg.userPreferences;
          runtimePackage = cfg.runtimePackage;
        };

      profileInstances = lib.mapAttrs mkProfileInstance appsByProfile;
      profileInstancesList = builtins.attrValues profileInstances;
      profileFragments = map (instance: instance.profileConfigFragment) profileInstancesList;
      profileDirectories = map (instance: instance.profileDir) profileInstancesList;

      mergedDesktopEntries = builtins.foldl' (acc: fragment:
        acc // fragment.xdg.desktopEntries
      ) { } profileFragments;

      mergedHomePackages = lib.concatMap (fragment: fragment.home.packages) profileFragments;

      mergedXdgDataFiles = builtins.foldl' (acc: fragment:
        acc // (fragment.xdg.dataFile or { })
      ) { } profileFragments;

      profileAssertions = lib.concatMap (fragment: fragment.assertions or [ ]) profileFragments;
    in
    {
      assertions = [
        {
          assertion = builtins.length ids == builtins.length (lib.unique ids);
          message = "pwaFirefox: app ids must be unique.";
        }
        {
          assertion = pkgs.stdenv.hostPlatform.isLinux;
          message = "pwaFirefox: this module targets Linux.";
        }
      ] ++ map (app: {
        assertion = app.icon == null || app.iconUrl == null;
        message = "pwaFirefox: ${app.title} must set at most one of icon and iconUrl.";
      }) cfg.apps ++ profileAssertions;

      gnm.hm.browserNativeClient.enable = true;

      xdg.desktopEntries = mergedDesktopEntries;
      xdg.dataFile = mergedXdgDataFiles;
      home.packages = mergedHomePackages;

      home.activation.pwaFirefoxDebugEffectiveSettings = lib.mkIf cfg.debugLogEffectiveSettings (lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        echo "pwaFirefox debug: wrapped Firefox package source ${cfg.runtimePackage.name}"
        echo "pwaFirefox debug: profile directories"
        ${lib.concatMapStringsSep "\n" (dir: "echo ${lib.escapeShellArg "pwaFirefox debug: ${dir}"}") profileDirectories}
      '');

      persistence.directories = lib.mkIf cfg.persistProfiles [ pwaFirefoxDataDir ];
    }
  );
}
