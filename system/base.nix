{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.system;
in {

  options.system = {
    username = mkOption {
      type = types.str;
      default = "gaerfield";
      description = "default usernames that gets automatically logged in.";
    };
    autologin = mkOption {
      type = types.bool;
      default = false;
      description = "should the default user be logged in automatically upon boot";
    };
    authorizedKeys = mkOption {
      type = types.listOf types.str;
      default = [];
      description = "ssh public keys for the default user";
    };
  };

  config = {
    users.users."${cfg.username}" = {
      isNormalUser = true;
      description = "${cfg.username}";
      extraGroups = ["networkmanager" "wheel"];
      linger = true;
      openssh.authorizedKeys.keys = cfg.authorizedKeys;
    };

    ### automatic login ###
    # Enable automatic login for the user.
    services.displayManager.autoLogin = mkIf cfg.autologin {
      enable = true;
      user = cfg.username;
    };
    # Workaround for GNOME autologin: https://github.com/NixOS/nixpkgs/issues/103746#issuecomment-945091229
    systemd.services = mkIf cfg.autologin {
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

    # Set your time zone.
    time.timeZone = "Europe/Berlin";

    # Select internationalisation properties.
    i18n.defaultLocale = "de_DE.UTF-8";

    i18n.extraLocaleSettings = {
      LC_ADDRESS = "de_DE.UTF-8";
      LC_IDENTIFICATION = "de_DE.UTF-8";
      LC_MEASUREMENT = "de_DE.UTF-8";
      LC_MONETARY = "de_DE.UTF-8";
      LC_NAME = "de_DE.UTF-8";
      LC_NUMERIC = "de_DE.UTF-8";
      LC_PAPER = "de_DE.UTF-8";
      LC_TELEPHONE = "de_DE.UTF-8";
      LC_TIME = "de_DE.UTF-8";
    };

    # Enable CUPS to print documents.
    services.printing.enable = true;

    fonts = {
      packages = with pkgs; [
        # icon fonts
        material-design-icons

        # normal fonts
        noto-fonts
        noto-fonts-color-emoji
        noto-fonts-cjk-sans

        # nerdfonts
        (nerdfonts.override {fonts = ["FiraCode" "JetBrainsMono" "Meslo"];})
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

    # networking.firewall.allowedTCPPorts = [ ... ];
    # networking.firewall.allowedUDPPorts = [ ... ];
    # Or disable the firewall altogether.
    networking.firewall.enable = false;

    # Enable the OpenSSH daemon.
    services.openssh = {
      enable = true;
      settings = {
        X11Forwarding = true;
        PermitRootLogin = "no"; # disable root login
        PasswordAuthentication = false; # disable password login
      };
      openFirewall = true;
    };

    # Enable flakes
    nix.settings = {
      experimental-features = [ "nix-command" "flakes" ];
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

    # Enable sound with pipewire.
    hardware.pulseaudio.enable = false;
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      # If you want to use JACK applications, uncomment this
      #jack.enable = true;

      # use the example session manager (no others are packaged yet so this is enabled by default,
      # no need to redefine it in your config for now)
      #media-session.enable = true;
    };
  };
}
