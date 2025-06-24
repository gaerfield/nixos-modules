{config, lib, ...}: with lib; let
  virtualization = config.gnm.hm.virtualization.enable;
in {
  options.gnm.hm.virtualization.enable = mkOption { 
    type = types.bool;
    default = config.gnm.virtualization.enable;
    description = "Enable virtualization support, including libvirt and virt-manager.";
  };

  config = mkIf virtualization {
    # Enable UEFI firmware support
    # https://nixos.wiki/wiki/Libvirt
    xdg.configFile."libvirt/qemu.conf".text = ''
      nvram = [ "/run/libvirt/nix-ovmf/AAVMF_CODE.fd:/run/libvirt/nix-ovmf/AAVMF_VARS.fd", "/run/libvirt/nix-ovmf/OVMF_CODE.fd:/run/libvirt/nix-ovmf/OVMF_VARS.fd" ]
    '';

    # https://nixos.wiki/wiki/Virt-manager
    # https://github.com/rhoriguchi/nixos-setup/blob/master/modules/home-manager/virt-manager.nix
    dconf = {
      enable = true;
      settings = {
        "org/virt-manager/virt-manager" = {
          system-tray = true;
          xmleditor-enabled = true;
          "new-vm/firmware" = "uefi";
        };
        "org/virt-manager/virt-manager/connections" = {
          autoconnect = ["qemu:///system"];
          uris = ["qemu:///system"];
        };
        # "org/virt-manager/virt-manager/confirm" = {
        #   delete-storage = true;
        #   forcepoweroff = true;
        #   pause = true;
        #   poweroff = true;
        #   removedev = true;
        #   unapplied-dev = true;
        # };
        # "org/virt-manager/virt-manager/details".show-toolbar = true;
        # "org/virt-manager/virt-manager/new-vm" = {
        #   cpu-default = "default";
        #   graphics-type = "vnc";
        #   storage-format = "default";
        # };
        # "org/virt-manager/virt-manager/stats" = {
        #   enable-cpu-poll = true;
        #   enable-disk-poll = true;
        #   enable-memory-poll = true;
        #   enable-net-poll = true;
        #   update-interval = 5;
        # };
        # "org/virt-manager/virt-manager/vmlist-fields" = {
        #   cpu-usage = true;
        #   disk-usage = false;
        #   host-cpu-usage = false;
        #   network-traffic = false;
        # };
      };
    };
  };
}