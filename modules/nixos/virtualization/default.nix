{
  pkgs,
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.gnm.virtualization;
in {
  options.gnm.virtualization = {
    enable = mkEnableOption "Enable virtualization support, including libvirt and virt-manager.";
    users = mkOption {
      type = types.listOf types.str;
      default = [];
      example = [ "user1" "user2" ];
      description = "users that become members of the 'libvirtd' group to manage virtual machines"; 
    };
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

    users.users = lists.foldl' (acc: user: acc // {
      "${user}" = { extraGroups = ["libvirtd"]; };
    }) {} cfg.users;

    # allow nested virtualization (https://nixos.wiki/wiki/Libvirt)
    boot.extraModprobeConfig = "options kvm_intel nested=1";
  };
}
