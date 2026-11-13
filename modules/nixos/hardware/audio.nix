{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.gnm.hardware;
in {
  config = mkIf cfg.enable {
    security.rtkit.enable = true;
    services = {
      pulseaudio.enable = false; # use PipeWire instead of PulseAudio
      pipewire = {
        enable = true;
        audio.enable = true;
        pulse.enable = true;

        alsa.enable = true;
        alsa.support32Bit = true;

        # https://wiki.nixos.org/wiki/PipeWire
        # automatically switch audio profiles when 
        # https://pipewire.pages.freedesktop.org/wireplumber/daemon/configuration/bluetooth.html
        wireplumber.extraConfig."11-bluetooth-policy" = {
          "wireplumber.settings" = {
            "bluetooth.autoswitch-to-headset-profile" = true;
          };
        };
      };
    };
  };
}