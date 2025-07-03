{
  pkgs,
  lib,
  ...
}: {
  environment.systemPackages = with pkgs;
    map lib.lowPrio [
      gitMinimal
      sysstat
      lm_sensors
      killall
      killport
    ];
}
