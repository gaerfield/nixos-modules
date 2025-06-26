{pkgs, ...}: let
  track-working-day = pkgs.callPackage ./script.nix {};
in {
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
}
