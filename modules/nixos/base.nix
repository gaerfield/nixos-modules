{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  mainuser = config.mainuser;
in {
    users.users."${mainuser.name}" = {
      isNormalUser = true;
      description = "${mainuser.name}";
      extraGroups = ["wheel"];
      linger = true;
      openssh.authorizedKeys.keys = mainuser.authorizedKeys;
    };

    ### automatic login ###
    # Enable automatic login for the user.
    services.displayManager.autoLogin = mkIf mainuser.autologin {
      enable = true;
      user = mainuser.username;
    };
    # Workaround for GNOME autologin: https://github.com/NixOS/nixpkgs/issues/103746#issuecomment-945091229
    systemd.services = mkIf mainuser.autologin {
      "getty@tty1".enable = false;
      "autovt@tty1".enable = false;
    };

    boot.kernel.sysctl = {
      "kernel.sysrq" = 1; # enable reisub sequence
    };

    # compatibility with non-nixos bash scripts
    # https://github.com/mic92/envfs
    # services.envfs.enable = true;

    # do garbage collection weekly to keep disk usage low
    nix.gc = {
      automatic = mkDefault true;
      dates = mkDefault "weekly";
      options = mkDefault "--delete-older-than 7d";
    };

    # Allow unfree packages
    nixpkgs.config.allowUnfree = true;

    # Enable CUPS to print documents.
    services.printing.enable = true;

    # https://wiki.nixos.org/wiki/Fonts
    fonts = {
      packages = with pkgs; [
        # icon fonts
        material-design-icons

        # normal fonts
        noto-fonts
        noto-fonts-color-emoji
        noto-fonts-cjk-sans
        nerd-fonts.fira-code
        nerd-fonts.jetbrains-mono
        nerd-fonts.meslo-lg
      ];

      # use fonts specified by user rather than default ones
      enableDefaultPackages = true;

      # user defined fonts
      # the reason there's Noto Color Emoji everywhere is to override DejaVu's
      # B&W emojis that would sometimes show instead of some Color emojis
      fontconfig.defaultFonts = {
        serif = ["Noto Serif" "Noto Color Emoji"];
        sansSerif = ["Noto Sans" "Noto Color Emoji"];
        monospace = ["MesloLGS Nerd Font Mono" "Noto Color Emoji"];
        emoji = ["Noto Color Emoji"];
      };
    };

    # Enable flakes
    nix.settings = {
      experimental-features = ["nix-command" "flakes"];
      auto-optimise-store = true;
    };
    # List packages installed in system profile. To search, run:
    # $ nix search wget
    environment.systemPackages = with pkgs; [
      #neovim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
      wget
      curl
      git
      sysstat
      lm_sensors
      home-manager
      killall
      killport
    ];
}
