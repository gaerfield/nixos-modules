{
  pkgs,
  flake,
  lib,
  ...
}: let
  nm = flake.nixosModules;
  mainuser = "gaerfield";
in {
  imports = [
    ./hardware-configuration.nix
    nm.os
    nm.networking
    nm.hardware
    nm.gui
    nm.home-manager
  ];

  system.stateVersion = "25.05";
  nixpkgs.hostPlatform = "x86_64-linux";
  nixpkgs.config.allowUnfree = true;
  users.users.${mainuser} = {
    isNormalUser = true;
    initialPassword = "nixos";
  };
  networking.hostName = "nixos"; # Define your hostname.
  #gnm.os.mainuser = {
  #  name = mainuser;
  #  autologin = true;
  #  authorizedKeys = [
  #    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJiwF/fhZ3Avw2RxpwuikiSraNpbD88ixd7rHJsuJHeG gaerfield@kramhal.de"
  #  ];
  #};
  users.mutableUsers = true;
  
  boot.loader.grub = {
    # no need to set devices, disko will add all devices that have a EF02 partition to the list already
    # devices = [ ];
    efiSupport = true;
    efiInstallAsRemovable = true;
  };

  environment.systemPackages = map lib.lowPrio [
    pkgs.curl
    pkgs.gitMinimal
  ];

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