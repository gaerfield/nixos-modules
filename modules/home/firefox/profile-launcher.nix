{
  pkgs,
  firefoxPackage,
  shimDir,
  profileNames,
  routePatternsTsv,
  writeShellApplication,
}:
let
  profileNamesShell = pkgs.lib.concatMapStringsSep " " pkgs.lib.escapeShellArg profileNames;
  routePatternsTsvShell = pkgs.lib.escapeShellArg routePatternsTsv;
  shimPathSetup = if shimDir == null then "" else ''export PATH=${pkgs.lib.escapeShellArg shimDir}:"$PATH"'';
  firefoxBin = "${firefoxPackage}/bin/firefox";
in
writeShellApplication {
  name = "firefox-profile-launcher";
  runtimeInputs = with pkgs; [
    firefoxPackage
    coreutils
    gnugrep
    jq
    procps
  ];
  text = ''
    set -euo pipefail

    ${shimPathSetup}

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
        hyprctl --quiet dispatch "hl.dsp.focus({ window = \"address:$addr\" })"
        exit $?
      fi

      exec ${firefoxBin} --name "$target" --no-remote -P "$target" --new-window
    fi

    route_profile=""
    route_patterns_tsv=${routePatternsTsvShell}

    if [[ -n "$route_patterns_tsv" && "$target" =~ ^https?:// ]]; then
      while IFS=$'\t' read -r candidate pattern; do
        if [[ -z "$candidate" || -z "$pattern" ]]; then
          continue
        fi
        # shellcheck disable=SC2053
        if [[ "$target" == $pattern ]]; then
          route_profile="$candidate"
          break
        fi
      done <<< "$route_patterns_tsv"
    fi

    if [[ -n "$route_profile" ]]; then
      # If the active window already belongs to the target profile, keep the URL in it.
      active_profile="$(hyprctl activewindow -j 2>/dev/null | jq -r '(.initialClass // .class // "")')"
      if [[ "$active_profile" == "$route_profile" ]]; then
        exec ${firefoxBin} --name "$route_profile" --no-remote -P "$route_profile" "$target"
      fi

      addr="$(hyprctl clients -j | jq --arg cls "$route_profile" -r '.[] | select((.initialClass // "") == $cls) | .address' | head -n 1)"
      if [[ -n "$addr" && "$addr" != "null" ]]; then
        hyprctl --quiet dispatch "hl.dsp.focus({ window = \"address:$addr\" })"
      fi

      exec ${firefoxBin} --name "$route_profile" --no-remote -P "$route_profile" "$target"
    fi

    exec ${firefoxBin} "$target"
  '';
}
