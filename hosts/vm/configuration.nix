{flake, ...}: let
  mainuser = "nixos";
in {
  imports = [
    ./hardware-configuration.nix
    flake.nixosModules.system
  ];

  system.stateVersion = "25.05";
  nixpkgs.hostPlatform = "x86_64-linux";

  gnm = {
    gui.enable = true;
    system = {
      mainuser = {
        name = mainuser;
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

  ### automatic login ###
  # Enable automatic login for the user.
  services.displayManager.autoLogin = {
    enable = true;
    user = mainuser;
  };
  # Workaround for GNOME autologin: https://github.com/NixOS/nixpkgs/issues/103746#issuecomment-945091229
  systemd.services = {
    "getty@tty1".enable = false;
    "autovt@tty1".enable = false;
  };
}
