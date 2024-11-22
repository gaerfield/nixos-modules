{ outputs, config, ... }: {

  xdg.enable = true;
  home.sessionVariables = {
    XDG_BIN_HOME    = "${config.home.homeDirectory}/.local/bin";
  };
  home.sessionPath = [ "$XDG_BIN_HOME" ];

  nixpkgs = {
    # You can add overlays here
    overlays = [
      outputs.overlays.additions
      outputs.overlays.modifications
      outputs.overlays.stable-packages

      # You can also add overlays exported from other flakes:
      # neovim-nightly-overlay.overlays.default

      # Or define it inline, for example:
      # (final: prev: {
      #   hi = final.hello.overrideAttrs (oldAttrs: {
      #     patches = [ ./change-hello-to-hi.patch ];
      #   });
      # })
    ];

    # Configure your nixpkgs instance
    config = {
      allowUnfree = true;
      # Workaround for https://github.com/nix-community/home-manager/issues/2942
      allowUnfreePredicate = _: true;
    };
  };

  # Let home Manager install and manage itself.
  programs.home-manager.enable = true;

  # set cursor size and dpi for 4k monitor
  xresources.properties = {
    "Xcursor.size" = 16;
    "Xft.dpi" = 172;
  };
  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";
}
