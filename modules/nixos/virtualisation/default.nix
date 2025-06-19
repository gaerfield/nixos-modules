{
  pkgs,
  config,
  ...
}: let
  mainuser = config.mainuser;
in {
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

  users.users."${mainuser.name}".extraGroups = ["libvirtd"];

  # allow nested virtualization (https://nixos.wiki/wiki/Libvirt)
  boot.extraModprobeConfig = "options kvm_intel nested=1";
}
