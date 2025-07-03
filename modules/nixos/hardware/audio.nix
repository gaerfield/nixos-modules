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
        jack.enable = true;

        alsa.enable = true;
        alsa.support32Bit = true;

        # use the example session manager (no others are packaged yet so this is enabled by default,
        # no need to redefine it in your config for now)
        #media-session.enable = true;
      };
    };
  };
}
