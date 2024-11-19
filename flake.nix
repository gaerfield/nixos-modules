{
  description = "gaerfields default configurations for nixos";

  outputs = _: {
    system =
      let
        import = path: path; # let the module system know what we are exporting
      in
      {
        appimage = import ./system/appimage.nix;
        base = import ./system/base.nix;
        bluetooth = import ./system/bluetooth.nix;
        dns-resolve = import ./system/dns-resolve.nix;
        gnome-wayland = import ./system/gnome-wayland.nix;
        nix-ld = import ./system/nix-ld.nix;
        podman = import ./system/podman.nix;
        virtualization = import ./system/virtualization.nix;
      };
    #hm =
    #  let
    #    import = path: path; # let the module system know what we are exporting
    #  in
    #  {
    #    # basicTest = import ./basic-test.nix;
    #  };
  };
}
