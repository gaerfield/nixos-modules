{pkgs, ...}: {
  # https://nixos.wiki/wiki/Appimage
  programs.appimage = {
    enable = true;
    binfmt = true;
    package = pkgs.appimage-run.override {
      extraPkgs = pkgs: [
        # missing libraries here, e.g.: `pkgs.libepoxy`
        pkgs.xorg.libxshmfence
      ];
    };
  };
}
