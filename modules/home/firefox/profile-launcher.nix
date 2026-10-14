{ config, lib, pkgs, ... }:
let
  cfg = config.gnm.hm.firefoxProfiles;
  profileNames = builtins.attrNames cfg.profiles;
  profileNamesShell = lib.concatMapStringsSep " " lib.escapeShellArg profileNames;

  firefoxProfileLauncher = pkgs.writeShellApplication {
    name = "firefox-profile-launcher";
    runtimeInputs = with pkgs; [
      firefox
      coreutils
      gnugrep
      jq
      procps
    ];
    text = ''
      set -euo pipefail

      if [[ $# -lt 1 ]]; then
        echo "usage: firefox-profile-launcher <profile-name|url>" >&2
        exit 1
      fi

      target="$1"
      known_profiles=( ${profileNamesShell} )

      is_profile=false
      for p in "''${known_profiles[@]}"; do
        if [[ "$target" == "$p" ]]; then
          is_profile=true
          break
        fi
      done

      if [[ "$is_profile" == "true" ]]; then
        # Match by class or initialClass against profile id.
        addr="$(hyprctl clients -j | jq --arg cls "$target" -r '.[] | select((.initialClass // "") == $cls) | .address' | head -n 1)"
        if [ -n "$addr" ] && [ "$addr" != "null" ]; then
          hyprctl dispatch "hl.dsp.focus({ window = \"address:$addr\" })"
          return $?
        fi

        exec firefox --name "$target" --no-remote -P "$target" --new-window about:blank
      fi

      exec firefox "$target"
    '';
  };
in {
  config = lib.mkIf cfg.enable {
    home.packages = [ firefoxProfileLauncher ];
  };
}
