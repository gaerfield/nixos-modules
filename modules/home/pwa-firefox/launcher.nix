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
    forwarded_url="''${3:-}"
    class_name="FFPWA-$site_id"

    if [ "$single_instance" = "1" ]; then
      addr="$(hyprctl clients -j | jq -r --arg class "$class_name" '.[] | select(.class == $class) | .address' | head -n 1)"
      if [ -n "$addr" ]; then
        hyprctl dispatch "hl.dsp.focus({ window = \"address:$addr\" })"
        exit 0
      fi
    fi

    if [ -n "$forwarded_url" ]; then
      exec firefoxpwa site launch "$site_id" --protocol "$forwarded_url"
    fi

    exec firefoxpwa site launch "$site_id"
  '';
}
