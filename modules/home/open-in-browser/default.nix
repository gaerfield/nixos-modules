{ config, lib, pkgs, ... }:
let
  cfg = config.gnm.hm.openInBrowser;
  package = pkgs.callPackage ../../../packages/open-in-browser { };
  format = pkgs.formats.toml { };
  knownExecutables = builtins.attrNames cfg.executables;
in {
  options.gnm.hm.openInBrowser = {
    enable = lib.mkEnableOption "URL routing through open-in-browser";

    executables = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = { };
      example = { firefox-private = "firefox -P private"; };
      description = "Named browser commands. The URL is appended as a separate argument (shell syntax is not evaluated).";
    };

    urlPatterns = lib.mkOption {
      type = lib.types.listOf (lib.types.submodule {
        options = {
          globPattern = lib.mkOption {
            type = lib.types.str;
            example = "https://*posteo.de*";
            description = "Case-sensitive URL glob pattern; the first matching rule wins.";
          };
          executable = lib.mkOption {
            type = lib.types.str;
            example = "firefox-private";
            description = "Name of an entry in executables.";
          };
        };
      });
      default = [ ];
      description = "Ordered URL rules; lists declared by different modules are concatenated.";
    };

    defaultExecutable = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = "$BROWSER";
      example = "firefox-default";
      description = "Named executable for unmatched URLs, or $BROWSER to use the runtime environment variable (the default).";
    };

    registerAsDefault = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Register open-in-browser as the XDG default handler for HTTP and HTTPS URLs.";
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.defaultExecutable == null || cfg.defaultExecutable == "$BROWSER" || builtins.elem cfg.defaultExecutable knownExecutables;
        message = "gnm.hm.openInBrowser.defaultExecutable must be $BROWSER or refer to a registered executable.";
      }
      {
        assertion = !cfg.registerAsDefault || cfg.defaultExecutable != null;
        message = "gnm.hm.openInBrowser.defaultExecutable is required when registerAsDefault is enabled.";
      }
      {
        assertion = builtins.all (rule: builtins.elem rule.executable knownExecutables) cfg.urlPatterns;
        message = "gnm.hm.openInBrowser.urlPatterns must reference registered executables.";
      }
    ];

    home.packages = [ package ];
    xdg.enable = lib.mkDefault true;
    xdg.configFile."open-in-browser/config.toml".source = format.generate "open-in-browser-config.toml" (
      { inherit (cfg) executables urlPatterns; }
      // lib.optionalAttrs (cfg.defaultExecutable != null) { inherit (cfg) defaultExecutable; }
    );

    xdg.desktopEntries.open-in-browser = {
      name = "Open in Browser";
      genericName = "Web Browser";
      exec = "${package}/bin/open-in-browser %u";
      icon = "web-browser";
      terminal = false;
      categories = [ "Network" "WebBrowser" ];
      mimeType = [ "x-scheme-handler/http" "x-scheme-handler/https" ];
    };

    xdg.mimeApps.enable = lib.mkIf (config.xdg.enable && cfg.registerAsDefault) (lib.mkDefault true);
    xdg.mimeApps.defaultApplications = lib.mkIf (config.xdg.enable && cfg.registerAsDefault) {
      "x-scheme-handler/http" = [ "open-in-browser.desktop" ];
      "x-scheme-handler/https" = [ "open-in-browser.desktop" ];
    };
  };
}