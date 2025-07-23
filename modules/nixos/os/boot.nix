{
  boot.loader = {
    systemd-boot.enable = true;
    timeout = 0; # skip selection menu, unless <space> is pressed during boot
    efi = {
      canTouchEfiVariables = true;
      efiSysMountPoint = "/boot";
    };
  };
}