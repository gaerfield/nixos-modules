{
  imports = [
    ./audio.nix
    ./bluetooth.nix
  ];

  services.fwupd.enable = true;
}