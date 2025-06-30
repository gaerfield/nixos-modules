{config, lib, pkgs, ...}: with lib; let
  cfg = config.gnm.hm.trackWorkingDay;
  track-working-day = pkgs.callPackage ./script.nix {};
in {
  options.gnm.hm.trackWorkingDay.enable = mkEnableOption "Enable the track-working-day service to log working hours.";

  config = mkIf cfg.enable {
    home.packages = [track-working-day];

    systemd.user.services.track-working-day = {
      Unit = {
        Description = "tracks my working day by logging logins, logouts, bootups and shutdowns";
      };
      Install = {
        WantedBy = ["default.target"];
      };
      Service = {
        ExecStart = "${track-working-day}/bin/track-working-day start";
      };
    };
  };
}
