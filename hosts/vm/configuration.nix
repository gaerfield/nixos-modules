{
  pkgs,
  flake,
  lib,
  ...
}: let
  nm = flake.nixosModules;
  mainuser = "nixos";
in {
  imports = [
    ./hardware-configuration.nix
    nm.os
    nm.networking
    nm.hardware
    nm.gui
  ];

  system.stateVersion = "25.05";
  nixpkgs.hostPlatform = "x86_64-linux";
  
  gnm = {
    os = {
      mainuser = {
        name = mainuser;
        autologin = true;
        authorizedKeys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJiwF/fhZ3Avw2RxpwuikiSraNpbD88ixd7rHJsuJHeG gaerfield@kramhal.de"
        ];
      };
      allowUnfree = true;
      hostname = "nixos";
    };
  };
  users.mutableUsers = true;
  
  boot.loader.grub = {
    # no need to set devices, disko will add all devices that have a EF02 partition to the list already
    # devices = [ ];
    efiSupport = true;
    efiInstallAsRemovable = true;
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  programs = {
    chromium.enable = true;
    fish.enable = true;
  };
}