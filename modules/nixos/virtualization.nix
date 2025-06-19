{ pkgs, config, ... }: 
let 
  mainuser = config.system.username;
in {
  # https://nixos.wiki/wiki/Virt-manager
  virtualisation.libvirtd = {
    enable = true;
    qemu.swtpm.enable = true;
  };
  programs.virt-manager.enable = true;

  users.users."${mainuser}".extraGroups = [ "libvirtd" ];

  # allow nested virtualization (https://nixos.wiki/wiki/Libvirt)
  boot.extraModprobeConfig = "options kvm_intel nested=1";
}