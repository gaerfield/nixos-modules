{pkgs, ...}: {
  # List packages installed in system profile. To search, run:
  environment.systemPackages = with pkgs; [
    wget
    curl
    git
    sysstat
    lm_sensors
    home-manager
    killall
    killport
  ];
}
