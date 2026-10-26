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
  name = "firefox-profile-launcher";
  runtimeInputs = with pkgs; [ coreutils jq ];
  text = ''
    set -euo pipefail
    ${shimPathSetup}

    if [[ $# -lt 1 ]]; then
      echo "usage: firefox-profile-launcher <profile> [url]" >&2
      exit 1
    fi

    profile="$1"
    shift # remove the profile argument from the list of arguments

    if command -v hyprctl >/dev/null 2>&1; then
      addr="$(hyprctl clients -j 2>/dev/null | jq --arg cls "$profile" -r '.[] | select((.initialClass // .class // "") == $cls) | .address' 2>/dev/null | head -n 1 || true)"
      if [[ -n "$addr" && "$addr" != "null" ]]; then
        if hyprctl --quiet dispatch "hl.dsp.focus({ window = \"address:$addr\" })" && [[ $# -eq 0 ]]; then
          exit 0
        fi
      fi
    fi

    exec ${firefoxBin} --name "$profile" --no-remote -P "$profile" "$@"
  '';
}
