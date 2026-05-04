{
  lib,
  config,
  ...
}:
with lib; let
  cfg = config.gnm.hardware;
  normalUsers = lib.filterAttrs (_: u: u.isNormalUser) config.users.users;
in {
  config = mkIf cfg.enable {
    # allow users to access serial devices without sudo (https://wiki.nixos.org/wiki/Serial_Console)
    # that covers arduino and similar per usb attached serial devices (they expose themselves as ttyUSBX / ttyACMX)
    users.groups = {
      dialout.members = lib.attrNames normalUsers;
    };

    services.udisks2.enable = true;
    # automounting could be enabled by `services.udiskie.enable = true;`
    # but I'm not sure if it interferes with writing usb-images and stuff, so I leave it out for now.
  };
}
