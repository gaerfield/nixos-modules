{
  pkgs,
  config,
  lib,
  ...
}: with lib; let
  mainuser = config.mainuser.name;
  virtualisation = config.nixos-modules.virtualisation.enable;
in {
  options.nixos-modules.virtualisation.enable = mkDefault true;

  config = mkIf virtualisation {
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

    users.users."${mainuser}".extraGroups = ["libvirtd"];

    # allow nested virtualization (https://nixos.wiki/wiki/Libvirt)
    boot.extraModprobeConfig = "options kvm_intel nested=1";
  };
}
