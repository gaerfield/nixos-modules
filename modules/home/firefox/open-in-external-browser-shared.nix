{
  lib,
  pkgs,
  writeShellApplication,
}:
let
  extensionId = "{8db82a75-48fd-452a-81cf-bd40b2e60dac}";
  xpiUrl = "https://addons.mozilla.org/firefox/downloads/file/4593044/open_in_opera_browser-0.3.4.xpi";

  firefoxShimDirName = ".firefox-shims";
  pwaFirefoxShimDirName = ".pwa-firefox-shims";
in {
  inherit extensionId xpiUrl firefoxShimDirName pwaFirefoxShimDirName;

  mkPolicy = {
    urls,
    reverse,
  }: {
    ExtensionSettings = {
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
    command ? "opera",
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
