{
  pkgs,
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.gnm.virtualisation;
  normalUsers = lib.filterAttrs (_: u: u.isNormalUser) config.users.users;
in {
  options.gnm.virtualisation = {
    enable = mkEnableOption "Enable virtualization support, including libvirt and virt-manager.";
  };

  config = mkIf cfg.enable {
    # https://nixos.wiki/wiki/Virt-manager

    # for file sharing add
    # <binary path="/run/current-system/sw/bin/virtiofsd"/>
    environment.systemPackages = with pkgs; [virtiofsd];

    virtualisation.libvirtd = {
      enable = true;
      qemu.swtpm.enable = true;
    };
    programs.virt-manager.enable = true;
    services = {
      qemuGuest.enable = true;
      spice-vdagentd.enable = true;
    };

    # allow nested virtualization (https://nixos.wiki/wiki/Libvirt)
    boot.extraModprobeConfig = "options kvm_intel nested=1";

    persistence.directories = [ "/var/lib/libvirt" "/etc/libvirt" ];

    users.groups = {
      libvirtd.members = lib.attrNames normalUsers;
    };
  };
}
