{
  pkgs,
  firefoxPackage,
  shimDir,
  writeShellApplication,
}:
let
  shimPathSetup = if shimDir == null then "" else ''export PATH=${pkgs.lib.escapeShellArg shimDir}:"$PATH"'';
  firefoxBin = "${firefoxPackage}/bin/firefox";
in
writeShellApplication {
  name = "firefox-profile-command";
  runtimeInputs = with pkgs; [ coreutils jq ];
  text = ''
    set -euo pipefail
    ${shimPathSetup}

    if [[ $# -lt 1 ]]; then
      echo "usage: firefox-profile-command <profile|--default> [url]" >&2
      exit 1
    fi

    profile="$1"
    shift
    if [[ "$profile" == "--default" ]]; then
      exec ${firefoxBin} "$@"
    fi

    # Window focus is optional when running outside Hyprland.
    if command -v hyprctl >/dev/null 2>&1; then
      if [[ $# -gt 0 ]]; then
        active_profile="$(hyprctl activewindow -j 2>/dev/null | jq -r '(.initialClass // .class // "")' || true)"
        if [[ "$active_profile" == "$profile" ]]; then
          exec ${firefoxBin} --name "$profile" --no-remote -P "$profile" "$@"
        fi
      fi

      addr="$(hyprctl clients -j 2>/dev/null | jq --arg cls "$profile" -r '.[] | select((.initialClass // "") == $cls) | .address' | head -n 1 || true)"
      if [[ -n "$addr" && "$addr" != "null" ]]; then
        hyprctl --quiet dispatch "hl.dsp.focus({ window = \"address:$addr\" })" || true
        if [[ $# -eq 0 ]]; then
          exit 0
        fi
      fi
    fi

    if [[ $# -eq 0 ]]; then
      exec ${firefoxBin} --name "$profile" --no-remote -P "$profile" --new-window
    fi
    exec ${firefoxBin} --name "$profile" --no-remote -P "$profile" "$@"
  '';
}