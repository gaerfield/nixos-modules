{pkgs, ...}: {
  imports = [
    ./eza.nix
    ./fzf.nix
    ./zoxide.nix
    ./nix-direnv.nix
    ./neovim
    ./byobu.nix
    ./tealdeer.nix
    ./tide.nix
    ./ranger.nix
    ./dust.nix
  ];

  # https://nixos.wiki/wiki/Fish
  # switch to fish if parent is not fish already
  programs.bash = {
    enable = true;
    enableCompletion = true;

    initExtra = ''
      if [[ $(${pkgs.procps}/bin/ps --no-header --pid=$PPID --format=comm) != "fish" && -z ''${BASH_EXECUTION_STRING} ]]
      then
        shopt -q login_shell && LOGIN_OPTION='--login' || LOGIN_OPTION=""
        exec ${pkgs.fish}/bin/fish $LOGIN_OPTION
      fi
    '';
  };

  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      set fish_greeting # Disable greeting
    '';

    plugins = with pkgs.fishPlugins; [
      {
        name = "grc";
        inherit (grc) src;
      }
      # {
      #   name = "sponge";
      #   src = sponge.src;
      # }
      {
        name = "colored-man-pages";
        inherit (colored-man-pages) src;
      }
    ];
    functions = {
      emo-shrug = {
        description = "¯\_(ツ)_/¯";
        body = "echo '¯\_(ツ)_/¯' | wl-copy";
      };
      emo-stroll = {
        description = "ᕕ( ᐛ )ᕗ";
        body = "echo '' | wl-copy";
      };
      emo-flip = {
        description = "(╯°□°）╯︵ ┻━┻";
        body = "echo '(╯°□°）╯︵ ┻━┻' | wl-copy";
      };
      emo-rage = {
        description = "(屮ﾟДﾟ)屮";
        body = "echo '(屮ﾟДﾟ)屮' | wl-copy";
      };
      jwt-decode = {
        description = "cat jwtToken | jwt-decode";
        body = "jq -R 'split(\".\") | select(length > 0) | .[0],.[1] | @base64d | fromjson'";
      };
      git-ignore = {
        # https://docs.gitignore.io/
        description = "git-ignore java,intellij,linux,gradle >> ~/.gitignore_global (git-ignore list to see available options)";
        body = "curl -sL https://www.gitignore.io/api/$argv";
      };
    };

    shellAbbrs = {
      shit = {
        expansion = "sudo $history[1]";
        position = "anywhere";
      };
      "!!" = {
        expansion = "$history[1]";
        position = "anywhere";
      };
      "!!c" = "echo $history[1] | wl-copy";
      opn = "xdg-open";
      df = "df -h";
      ip4 = "curl -sS4 ip.sb";
      ip6 = "curl -sS6 ip.sb";
      top = "btop";
      htop = "btop";
      lsg = "ls | grep ";
      glc = "git log --graph --all --pretty=\"format:ẞ%dẞ%cnẞ%s \" | awk 'BEGIN {FS=\"ẞ\"; OFS=\"ẞ\"} {print substr(\$2, 1, 60), substr(\$1, 1, 10), substr(\$3, 1, 15), substr(\$4, 1, 80)}'  | column -t -s\"ẞ\" | bat -p";
      scan-network = {
        expansion = "nmap -sV -open -oG scan-result.log -p %22 172.20.0.0/24";
        setCursor = true;
      };
      code = "codium";
      c = "wl-copy";
      p = "wl-paste";
      scpr = "rsync -avz --info=progress2 --human-readable";
      netstat = "ss";
      convert-as-gif = {
        # source: https://www.baeldung.com/linux/gif-screen-recording
        # -vf                       # video filters
        #  fps=10                   # framerate to use, usually 10 for GIFs
        #  scale=640:-1             # specifies width and height — -1 being proportional to the width
        #  flags                    # additional parameters for the scale filter:
        #    lanczos                # Lanczos resizing algorithm provides high-quality scaling
        #    split[s0][s1]          # splits the video stream into two for generating and applying the color palette
        #    [s0]palettegen[p]      # generates color palette from s0 and stores it in p
        #    [s1][p]paletteuse      # applies the color palette from p to s1
        # -loop 0: number of counts to loop, 0 loops the GIF indefinitely
        expansion = ", ffmpeg vf \"fps=10,scale=640:-1:flags=lanczos,split[s0][s1];[s0]palettegen[p];[s1][p]paletteuse\" -loop 0 -i %input.mp4 output.gif'";
        setCursor = true;
      };
    };
  };

  home.packages = with pkgs; [
    grc
    lazygit
    lazydocker
    # archives
    zip
    unzip

    # utils
    ripgrep # recursively searches directories for a regex pattern
    jq # A lightweight and flexible command-line JSON processor
    yq-go # yaml processer https://github.com/mikefarah/yq
    fzf # A command-line fuzzy finder
    sshfs # fuse mount directories through ssh

    # networking tools
    mtr # A network diagnostic tool
    iperf3
    dnsutils # `dig` + `nslookup`
    ldns # replacement of `dig`, it provide the command `drill`
    socat # replacement of openbsd-netcat
    nmap # A utility for network discovery and security auditing
    ipcalc # it is a calculator for the IPv4/v6 addresses

    # misc
    file
    which
    tree

    # productivity
    glow # markdown previewer in terminal
    btop # replacement of htop/nmon
    iotop # io monitoring
    iftop # network monitoring

    # system call monitoring
    lsof # list open files

    # system tools
    ethtool
    pciutils # lspci
    usbutils # lsusb
    progress # show progress of various commands even after started
  ];

  # tide configure --auto --style=Rainbow --prompt_colors='True color' --show_time=No --rainbow_prompt_separators=Angled --powerline_prompt_heads=Sharp --powerline_prompt_tails=Flat --powerline_prompt_style='Two lines, frame' --prompt_connection=Disconnected --powerline_right_prompt_frame=Yes --prompt_connection_andor_frame_color=Light --prompt_spacing=Compact --icons='Few icons' --transient=Yes

  # branchvincent/tide-show-on-cmd
  # oh-my-fish/plugin-extract
  # gazorby/fish-abbreviation-tips

  xdg.configFile."fish/conf.d" = {
    source = ./conf.d;
    recursive = true;
  };

  # add environment variables
  home.sessionVariables = {
    PAGER = "bat -p";
    # MANPAGER = "sh -c 'col -bx | bat -l man -p'";
  };

  #   # clean up ~
  #   # LESSHISTFILE = cache + "/less/history";
  #   # LESSKEY = c + "/less/lesskey";
  #   # WINEPREFIX = d + "/wine";
  #
  #   # set default applications
  #   EDITOR = "nvim";
  #   BROWSER = "firefox";
  #
  #   # enable scrolling in git diff
  #   DELTA_PAGER = "less -R";
  #
  #   #MANPAGER = "sh -c 'col -bx | bat -l man -p'";
  # };
  #
  # home.shellAliases = {
  #   # k = "kubectl";
  # };

  programs.pay-respects = {
    enable = true;
    options = ["--alias" "fu"];
  };
}
