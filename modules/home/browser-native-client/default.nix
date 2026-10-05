{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.gnm.hm.browserNativeClient;

  nativeClientVersion = "1.1.4";

  # Upstream project: https://github.com/andy-portmen/native-client
  # It is a tiny Node-based native messaging host used by browser extensions like
  # the Open in Firefox / Open in Chrome family of add-ons.
  # https://github.com/andy-portmen/native-client/blob/master/.travis.yml build ourselves?
  nativeClient = pkgs.stdenvNoCC.mkDerivation {
    pname = "native-client";
    version = nativeClientVersion;
    src = fetchTarball {
      url = "https://github.com/andy-portmen/native-client/archive/refs/tags/v${nativeClientVersion}.tar.gz";
      sha256 = "0fbhi777jid504xgad3w753fqq1hwdvzf4mz4kssr6ihlzwb7zx3";
    };

    dontBuild = true;

    installPhase = ''
      runHook preInstall

      mkdir -p "$out/bin" "$out/share/native-client"
      cp -a . "$out/share/native-client"

      cat > "$out/bin/native-client" <<EOF
      #!/usr/bin/env bash
      exec ${pkgs.nodejs}/bin/node "$out/share/native-client/host.js" "\$@"
      EOF

      chmod +x "$out/bin/native-client"
      runHook postInstall
    '';

    meta = {
      description = "Native messaging host for browser extensions";
      homepage = "https://github.com/andy-portmen/native-client";
      license = lib.licenses.mpl20;
      maintainers = [ ];
      platforms = lib.platforms.all;
    };
  };

  chromiumManifestContent = builtins.toJSON {
    name = "com.add0n.node";
    description = "Native client bridge for browser extensions";
    path = "${nativeClient}/bin/native-client";
    type = "stdio";
    allowed_origins = [
      "chrome-extension://lmeddoobegbaiopohmpmmobpnpjifpii/"
    ] ++ map (id: "chrome-extension://${id}/") (unique cfg.allowedChromiumExtensions);
  };

  firefoxManifestContent = builtins.toJSON {
    name = "com.add0n.node";
    description = "Native client bridge for Firefox";
    path = "${nativeClient}/bin/native-client";
    type = "stdio";
    allowed_extensions = [
      "{8db82a75-48fd-452a-81cf-bd40b2e60dac}"
    ];
  };

  chromiumManifest = pkgs.writeTextDir "etc/chromium/native-messaging-hosts/com.add0n.node.json" chromiumManifestContent;
  chromiumManifestFile = pkgs.writeText "com.add0n.node.json" chromiumManifestContent;

  firefoxManifest = pkgs.writeTextDir "etc/firefox/native-messaging-hosts/com.add0n.node.json" firefoxManifestContent;
in {
  options.gnm.hm.browserNativeClient = {
    enable = mkEnableOption "enable native-client native messaging host";
    extraChromiumDataDirs = mkOption {
      type = types.listOf types.str;
      default = [];
      description = "Absolute Chromium profile data directories that should receive the native messaging manifest as a symlinked file. Example: [ \"/home/user/.config/a-chromium-data-dir\" ].";
    };
    allowedChromiumExtensions = mkOption {
      type = types.listOf types.str;
      default = [];
      description = "List of allowed extensions in addition to the standard 'lmeddoobegbaiopohmpmmobpnpjifpii' for the native messaging host. Example: [ \"iiknpheaicifjgejodgmcolphkbddobl\" ].";
    };
  };

  config = mkIf cfg.enable {
    home.packages = [ nativeClient ];
    programs.chromium.nativeMessagingHosts = [ chromiumManifest ];
    programs.firefox.nativeMessagingHosts = [ firefoxManifest ];

    home.file = builtins.listToAttrs (
      map (dataDir: {
        name = "${dataDir}/NativeMessagingHosts/com.add0n.node.json";
        value = { source = chromiumManifestFile; };
      }) cfg.extraChromiumDataDirs
    );
  };
}
