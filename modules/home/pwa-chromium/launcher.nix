{ pkgs
, app
, appName
, appDataDir
, appCacheDir
, mkPwaPolicyDir
, browserPackage
, enableScreenSharing
, extraChromiumFlags
, writeShellApplication
, openInFirefoxChromiumExtension
}:
let
  safeAppTitle = appName app;
  chromiumExtraFlags = builtins.concatStringsSep " " (
    (if enableScreenSharing then [
      "--enable-features=UseOzonePlatform,WebRTCPipeWireCapturer"
      "--ozone-platform=wayland"
    ] else []) ++ extraChromiumFlags
  );
in writeShellApplication {
  name = safeAppTitle;

  runtimeInputs = with pkgs; [
    bubblewrap
    browserPackage
    hyprland
    jq
  ];

  text = ''
    if command -v hyprctl >/dev/null 2>&1; then
      window="$(hyprctl clients -j | ${pkgs.jq}/bin/jq -r --arg app "${safeAppTitle}" '
        map(select((.class // "") | contains($app))) | .[0].address // empty
      ')"
      if [ -n "$window" ]; then
        hyprctl dispatch "hl.dsp.focus({ window = \"address:$window\" })"
        exit 0
      fi
    fi

    exec ${pkgs.bubblewrap}/bin/bwrap \
      --ro-bind / / \
      --dev-bind /dev /dev \
      --proc /proc \
      --bind /run /run \
      --bind /tmp /tmp \
      --bind "$HOME" "$HOME" \
      --ro-bind "${mkPwaPolicyDir app}" /etc/chromium/policies \
      ${browserPackage}/bin/chromium \
        ${chromiumExtraFlags} \
        --class=${safeAppTitle} \
        --user-data-dir="${appDataDir app}" \
        --disk-cache-dir="${appCacheDir app}" \
        --app="${app.url}" \
        --app-id=${safeAppTitle} \
        --load-extension=${openInFirefoxChromiumExtension.extensionPath} \
        --no-first-run \
        "$@"
  '';
}
