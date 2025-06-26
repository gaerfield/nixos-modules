{
  pkgs,
  inputs,
  ...
}: let
  nm = inputs.self.nixosModules;
  mainuser = "gaerfield";
in {
  imports = [
    ./hardware-configuration.nix
    nm.system
    nm.networking
    nm.hardware
    nm.gui
    nm.home-manager
  ];

  config = {
    system.stateVersion = "25.05";

    networking.hostName = "nixos"; # Define your hostname.
    gnm.system.mainuser = {
      name = mainuser;
      autologin = true;
      authorizedKeys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJiwF/fhZ3Avw2RxpwuikiSraNpbD88ixd7rHJsuJHeG gaerfield@kramhal.de"
      ];
    };
    users.mutableUsers = true;
    users.users.${mainuser}.initialPassword = "nixos";

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

    #   disko.nixosModules.disko
    # ./configuration.nix
    # ./hardware-configuration.nix
    # common.system.base
    # common.system.dns-resolve
    # common.system.gnome-wayland
  };
}
