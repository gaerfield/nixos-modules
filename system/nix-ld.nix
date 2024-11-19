{ pkgs, ... }: {
  programs.nix-ld = {
    enable = true;
    libraries = with pkgs; [
      curl
      expat
      fontconfig
      freetype
      fuse
      fuse3
      glib
      icu
      libclang.lib
      libdbusmenu
      libxcrypt-legacy
      libxml2
      nss
      openssl
      python3
      stdenv.cc.cc
      xorg.libX11
      xorg.libXcursor
      xorg.libXext
      xorg.libXi
      xorg.libXrender
      xorg.libXtst
      xz
      zlib
    ];
  };
}