{ pkgs
, app
, appName
, appDataDir
, appCacheDir
, mkPwaPolicyDir
, browserPackage
, enableScreenSharing
, extraChromiumFlags
, singleInstance
, stateHome
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
    single_instance="${if singleInstance then "1" else "0"}"

    launch_chromium() {
      ${pkgs.bubblewrap}/bin/bwrap \
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
    }

    get_all_children() {
        echo "$1"
        for child in $(pgrep -P "$1"); do
            get_all_children "$child"
        done
    }

    if [ "$single_instance" = "0" ]; then
      launch_chromium "$@"
    fi

    state_dir="${stateHome}/pwa-chromium"
    mkdir -p "$state_dir"
    state_file="$state_dir/${safeAppTitle}.window"

    if [ -f "$state_file" ]; then
      tracked_pid="$(tr -d '\r\n' < "$state_file")"
      if [ -n "$tracked_pid" ] && kill -0 "$tracked_pid" 2>/dev/null; then
        sub_pids=$(get_all_children "$tracked_pid" | grep -v "$tracked_pid" | xargs)

        addr="$(hyprctl clients -j | jq --arg pids "$sub_pids" '($pids | split(" ") | map(tonumber)) as $pid_list | .[] | select(.pid | IN($pid_list[]))' | jq .address -r)"
        if [ -n "$addr" ]; then
          hyprctl dispatch "hl.dsp.focus({ window = \"address:$addr\" })"
          exit 0
        fi
      fi
      rm -f "$state_file"
    fi

    launch_chromium "$@" &
    browser_pid=$!
    printf '%s\n' "$browser_pid" > "$state_file"
    wait "$browser_pid"
  '';
}

