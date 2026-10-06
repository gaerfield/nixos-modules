{ pkgs
, writeShellApplication
}: writeShellApplication {
  name = "firefoxpwa-launch";

  runtimeInputs = with pkgs; [
    hyprland
    jq
    firefoxpwa
  ];

  text = ''
    site_id="''${1}"
    single_instance="''${2:-1}"
    class_name="FFPWA-$site_id"

    if [ "$single_instance" = "1" ]; then
      addr="$(hyprctl clients -j | jq -r --arg class "$class_name" '.[] | select(.class == $class) | .address' | head -n 1)"
      if [ -n "$addr" ]; then
        hyprctl dispatch focuswindow "address:$addr"
        exit 0
      fi
    fi

    exec firefoxpwa site launch "$site_id"
  '';
}
