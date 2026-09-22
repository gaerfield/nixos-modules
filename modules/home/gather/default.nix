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

  gatherExternalLinkHost = pkgs.writeShellApplication {
    name = "gather-open-external-host";
    runtimeInputs = [ pkgs.python3 pkgs.xdg-utils ];
    text = ''
      python3 - <<'PY'
      import json
      import os
      import shlex
      import struct
      import sys

      def write_response(payload):
          encoded = json.dumps(payload, separators=(",", ":")).encode("utf-8")
          sys.stdout.buffer.write(struct.pack("<I", len(encoded)))
          sys.stdout.buffer.write(encoded)
          sys.stdout.buffer.flush()

      data = sys.stdin.buffer.read()
      if len(data) < 4:
          sys.exit(0)

      msg_len = struct.unpack("<I", data[:4])[0]
      raw = data[4:4 + msg_len]
      if len(raw) < msg_len:
          sys.exit(0)

      try:
          message = json.loads(raw.decode("utf-8"))
      except Exception:
          write_response({"status": "error"})
          sys.exit(0)

      url = message.get("url") or message.get("URL")
      if url:
          os.system(f"${pkgs.xdg-utils}/bin/xdg-open {shlex.quote(url)} >/dev/null 2>&1")

      write_response({"status": "ok"})
      PY
    '';
  };

  gatherExternalLinkExtension = pkgs.runCommand "gather-open-external-extension" { } ''
    mkdir -p "$out"
    cat > "$out/manifest.json" <<'EOF'
    {
      "manifest_version": 3,
      "name": "Gather External Link Handler",
      "version": "1.0.0",
      "description": "Open external links in the system browser instead of the Gather app.",
      "permissions": ["nativeMessaging"],
      "host_permissions": [
        "https://*/*",
        "http://*/*"
      ],
      "content_scripts": [
        {
          "matches": [
            "https://*.gather.town/*",
            "https://app.v2.gather.town/*",
            "http://localhost/*"
          ],
          "js": ["content.js"],
          "run_at": "document_start",
          "all_frames": true
        }
      ]
    }
    EOF

    cat > "$out/content.js" <<'EOF'
    const isInternalGatherUrl = (value) => {
      if (!value) return false;
      try {
        const url = new URL(value, window.location.href);
        const host = url.hostname.toLowerCase();
        return host === "gather.town" || host === "app.v2.gather.town" || host.endsWith(".gather.town");
      } catch {
        return false;
      }
    };

    const openExternalUrl = (url) => {
      if (!url || isInternalGatherUrl(url)) return false;
      try {
        chrome.runtime.sendNativeMessage("com.gather.open_external", { url });
        return true;
      } catch {
        return false;
      }
    };

    document.addEventListener(
      "click",
      (event) => {
        const anchor = event.target.closest("a[href]");
        if (!anchor) return;

        const href = anchor.href;
        if (!href || isInternalGatherUrl(href)) return;

        if (event.button !== 0 || event.metaKey || event.ctrlKey || event.shiftKey || event.altKey) {
          return;
        }

        event.preventDefault();
        event.stopPropagation();
        openExternalUrl(href);
      },
      true,
    );

    const originalOpen = window.open.bind(window);
    window.open = function (url, target, features) {
      if (url && typeof url === "string" && !isInternalGatherUrl(url)) {
        if (openExternalUrl(url)) {
          return null;
        }
      }
      return originalOpen(url, target, features);
    };
    EOF
  '';

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

        BROWSER="${pkgs.xdg-utils}/bin/xdg-open" exec ${pkgs.chromium}/bin/chromium \
          --class=${safeAppTitle} \
          --disable-extensions-except="${gatherExternalLinkExtension}" \
          --load-extension="${gatherExternalLinkExtension}" \
          --user-data-dir="${profileDir}" \
          --disk-cache-dir="${cacheDir}" \
          --profile-directory="${safeAppTitle}" \
          --no-first-run \
          --new-window "${app.url}" "$@"
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
    xdg.configFile."chromium/NativeMessagingHosts/com.gather.open_external.json".text = builtins.toJSON {
      name = "com.gather.open_external";
      description = "Open Gather external links in the system browser.";
      path = "${gatherExternalLinkHost}/bin/gather-open-external-host";
      type = "stdio";
    };
    xdg.desktopEntries = gatherDesktopEntries;
    persistence.directories = persistedDirs;
  };
}
