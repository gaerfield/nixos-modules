{ pkgs
, app
, appName
, appDataDir
, appCacheDir
, mkPwaPolicyDir
, writeShellApplication
}:
let
  safeAppTitle = appName app;
in writeShellApplication {
  name = safeAppTitle;

  runtimeInputs = with pkgs; [
    bubblewrap
    chromium
    hyprland
    jq
  ];

  text = ''
    mkdir -p \
      "${appDataDir app}" \
      "${appCacheDir app}"

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
      --bind "${appDataDir app}" "${appDataDir app}" \
      --bind "${appCacheDir app}" "${appCacheDir app}" \
      --ro-bind "${mkPwaPolicyDir app}" /etc/chromium/policies \
      ${pkgs.chromium}/bin/chromium \
        --class=${safeAppTitle} \
        --user-data-dir="${appDataDir app}" \
        --disk-cache-dir="${appCacheDir app}" \
        --app="${app.url}" \
        --app-id=${safeAppTitle} \
        --no-first-run \
        "$@"
  '';
}
