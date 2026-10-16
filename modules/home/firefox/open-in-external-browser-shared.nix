{
  lib,
  pkgs,
  writeShellApplication,
}:
let
  extensionId = "{5cf4e3be-dd11-4589-befe-1b9e5037792b}";
  xpiUrl = "https://addons.mozilla.org/firefox/downloads/file/3686239/open_in_waterfox-0.1.1.xpi";

  firefoxShimDirName = ".firefox-shims";
  pwaFirefoxShimDirName = ".pwa-firefox-shims";
in {
  inherit extensionId xpiUrl firefoxShimDirName pwaFirefoxShimDirName;

  mkPolicy = {
    urls,
    reverse,
  }: {
    ExtensionSettings = {
      # https://addons.mozilla.org/en-US/firefox/addon/external-application:
      "${extensionId}" = {
        install_url = xpiUrl;
        installation_mode = "force_installed";
      };
    };
    "3rdparty" = {
      Extensions = {
        "${extensionId}" = {
          inherit reverse;
          faqs = false;
          inherit urls;
        };
      };
    };
  };

  mkShimDir = {
    baseDir,
    shimDirName ? firefoxShimDirName,
  }: "${baseDir}/${shimDirName}";

  mkBrowserShimToXdgOpen = {
    command ? "waterfox",
    shimDir ? null,
  }:
    let
      package = writeShellApplication {
        name = command;
        runtimeInputs = [ pkgs.xdg-utils ];
        text = ''
          target=""
          for arg in "$@"; do
            case "$arg" in
              http://*|https://*|ftp://*|file://*|mailto:*) target="$arg" ;;
            esac
          done

          if [[ -z "$target" ]]; then
            target="''${1:-about:blank}"
          fi

          exec ${pkgs.xdg-utils}/bin/xdg-open "$target"
        '';
      };
    in {
      inherit command package;
    } // lib.optionalAttrs (shimDir != null) {
      inherit shimDir;
    };
}
