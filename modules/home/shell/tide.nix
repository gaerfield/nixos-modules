{ lib, pkgs, ... }: let
  tideResetCmd = ''
    tide configure --auto \
    --style=Rainbow \
    --prompt_colors="True color" \
    --show_time=No \
    --rainbow_prompt_separators=Angled \
    --powerline_prompt_heads=Sharp \
    --powerline_prompt_tails=Flat \
    --powerline_prompt_style="Two lines, frame" \
    --prompt_connection=Disconnected \
    --powerline_right_prompt_frame=Yes \
    --prompt_connection_andor_frame_color=Dark \
    --prompt_spacing=Compact \
    --icons="Few icons" \
    --transient=Yes 
  '';
    # For ExecStart: remove line continuations and newlines.
  tideResetCmdExec =
    lib.replaceStrings ["\\\n" "\n"] [" " " "] tideResetCmd;
in {
  # This runs once when the user systemd instance starts (covers GUI and TTY sessions via pam_systemd).
  # If your user manager stays alive for a long time (lingering), it may not run on every new shell login, only when user manager starts.
  # If you need strict per-login behavior regardless of lingering, a fish hook is more reliable.
  systemd.user.services.tide-self-heal = {
    Unit = {
      Description = "Tide prompt self-heal";
      After = [ "default.target" ];
    };
    Service = {
      Type = "oneshot";
      ExecStart =  lib.escapeShellArgs [
        "${pkgs.fish}/bin/fish"
        "-lc"
        tideResetCmdExec
      ];
    };
    Install = {
      WantedBy = [ "default.target" ];
    };
  };

  programs.fish = {
    enable = true;
    # tide does not officially support declarative config
    # this abbr is my replacement for resetting the theme (and avoiding starship)
    shellAbbrs.tideThemeReset = tideResetCmd;
    
    # branchvincent/tide-show-on-cmd
    plugins = with pkgs.fishPlugins; [
      {
        name = "tide";
        inherit (tide) src;
      }
      # {
      #   name = "tide-show-on-cmd";
      #   src = pkgs.fetchFromGitHub {
      #     owner = "branchvincent";
      #     repo = "tide-show-on-cmd";
      #     rev = "fb36b09e1d8d934d82ea90d99384d24d4b67db25";
      #     sha256 = "sha256-p+y4MBe/13JpK/b6HCVT3VRQ05H6RCz5CW4wG9NN2HY=";
      #   };
      # }
    ];
  };
}
