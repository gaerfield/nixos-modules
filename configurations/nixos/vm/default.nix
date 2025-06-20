{
  pkgs,
  lib,
  self,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    self.nixosModules.system
    self.nixosModules.home-manager
  ];

  config = {
    system.stateVersion = "25.05";

    nixos-modules.system.mainuser = {
      name = "gaerfield";
      autologin = true;
      authorizedKeys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJiwF/fhZ3Avw2RxpwuikiSraNpbD88ixd7rHJsuJHeG gaerfield@kramhal.de"
      ];
    };
    users.mutableUsers = true;
    users.users.gaerfield.initialPassword = "nixos";

  boot.loader.grub = {
      # no need to set devices, disko will add all devices that have a EF02 partition to the list already
      # devices = [ ];
      efiSupport = true;
      efiInstallAsRemovable = true;
    };
    services.openssh.enable = true;

    environment.systemPackages = map lib.lowPrio [
      pkgs.curl
      pkgs.gitMinimal
    ];

    # Bootloader.
    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;

    networking.hostName = "nixos"; # Define your hostname.
    # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

    # Enable networking
    networking.networkmanager.enable = true;

    # Configure keymap in X11
    services.xserver = {
      layout = "de";
      xkbVariant = "nodeadkeys";
    };

    # Configure console keymap
    console.keyMap = "de-latin1-nodeadkeys";

    # Enable touchpad support (enabled default in most desktopManager).
    # services.xserver.libinput.enable = true;

    programs = {
      chromium.enable = true;
      fish.enable = true;
    };

    #   disko.nixosModules.disko
    # ./configuration.nix
    # ./hardware-configuration.nix
    # common.system.base
    # common.system.dns-resolve
    # common.system.gnome-wayland55
  }; 
}
