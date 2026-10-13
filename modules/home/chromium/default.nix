{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.gnm.hm.chromium;

  profile = import ./profile.nix {
    inherit config lib pkgs;
  };
in {
  options.gnm.hm.chromium = {
    enable = mkEnableOption "enable Chromium browser support";
    profiles = profile.profilesOption;
  };

  config = mkIf cfg.enable {
    programs.chromium = {
      enable = true;
      # https://webextension.org/listing/open-in.html
      # Native Message Host: https://github.com/andy-portmen/native-client
      extensions = [
        # Bitwarden Password Manager
        "nngceckbapebfimnlniiiahkandclblb"
        # LanguageTool
        "oldceeleldhonbafppcapldpdifcinji"
        # Vimium
        "dbepggeogbaibhgnhhndojpepiihcmeb"
        # Open in Firefox Browser
        "lmeddoobegbaiopohmpmmobpnpjifpii"
      ];
    };

    home.packages = profile.profilePackages;
    xdg.desktopEntries = profile.profileDesktopEntries;
    home.activation.chromiumProfileBookmarks = mkIf (cfg.profiles != []) (lib.hm.dag.entryAfter [ "writeBoundary" ] profile.profileBookmarksActivation);

    persistence.directories = with config.xdg; [
      "${config.home.homeDirectory}/.pki" # chromium store for certificates
      "${configHome}/chromium"
      "${cacheHome}/chromium"
    ];
  };
}
