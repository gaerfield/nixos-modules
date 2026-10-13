{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.gnm.hm.chromium;

  profileRuntimeName = profile: "chromium-profile-${profile.id}";

  mkProfileLauncher = profile:
    pkgs.writeShellApplication {
      name = profileRuntimeName profile;

      runtimeInputs = [
        config.programs.chromium.package
        pkgs.hyprland
        pkgs.jq
      ];

      text = ''
        focus_existing_window() {
          if ! command -v hyprctl >/dev/null 2>&1; then
            return 1
          fi

          # Match by class or initialClass against profile id.
          addr="$(hyprctl clients -j | jq --arg cls "${profile.id}" -r '.[] | select((.initialClass // "") == $cls) | .address' | head -n 1)"
          if [ -n "$addr" ] && [ "$addr" != "null" ]; then
            hyprctl dispatch "hl.dsp.focus({ window = \"address:$addr\" })"
            return $?
          fi

          return 1
        }

        if [ "$#" -eq 0 ] && focus_existing_window; then
          exit 0
        fi

        exec ${config.programs.chromium.package}/bin/chromium \
          --class="${profile.id}" \
          --profile-directory="${profile.id}" \
          "$@"
      '';
    };

  profileBookmarksActivation = lib.concatMapStringsSep "\n" (profile:
    let
      folderName = profile.displayName or profile.id;
      folderEntryJson = builtins.toJSON {
        type = "folder";
        name = folderName;
        children = map (url: {
          type = "url";
          name = url;
          inherit url;
        }) profile.urls;
      };
      initialBookmarksJson = builtins.toJSON {
        checksum = "";
        roots = {
          bookmark_bar = {
            children = [];
            name = "Bookmarks bar";
            type = "folder";
          };
          other = {
            children = [];
            name = "Other bookmarks";
            type = "folder";
          };
          synced = {
            children = [];
            name = "Mobile bookmarks";
            type = "folder";
          };
        };
        version = 1;
      };
    in lib.optionalString (profile.urls != []) ''
      bookmarks_file=${lib.escapeShellArg "${config.xdg.configHome}/chromium/${profile.id}/Bookmarks"}
      bookmarks_folder_name=${lib.escapeShellArg folderName}
      bookmarks_folder_entry_json=${lib.escapeShellArg folderEntryJson}
      initial_bookmarks_json=${lib.escapeShellArg initialBookmarksJson}

      mkdir -p "$(dirname "$bookmarks_file")"
      if [ ! -f "$bookmarks_file" ]; then
        printf '%s\n' "$initial_bookmarks_json" > "$bookmarks_file"
      fi

      tmp_file="$(mktemp)"
      if ${pkgs.jq}/bin/jq --arg folder "$bookmarks_folder_name" --argjson folderEntry "$bookmarks_folder_entry_json" '
        .roots = (.roots // {})
        | .roots.bookmark_bar = (.roots.bookmark_bar // { type: "folder", name: "Bookmarks bar", children: [] })
        | .roots.bookmark_bar.children = (
            (.roots.bookmark_bar.children // [])
            | map(select(.name != $folder))
            + [ $folderEntry ]
          )
      ' "$bookmarks_file" > "$tmp_file"; then
        mv "$tmp_file" "$bookmarks_file"
      else
        rm -f "$tmp_file"
      fi
    '') cfg.profiles;

  profileDesktopEntries = builtins.listToAttrs (
    map (profile: {
      name = "chromium-profile-${profile.id}";
      value = {
        name = profile.displayName or profile.id;
        genericName = profile.displayName or profile.id;
        exec = profileRuntimeName profile;
        icon = toString profile.icon;
        terminal = false;
        categories = profile.categories;
        startupNotify = true;
        settings = {
          StartupWMClass = profile.id;
          Keywords = lib.concatStringsSep ";" profile.keywords;
        };
      };
    }) (lib.filter (profile: profile.createDesktopEntry) cfg.profiles)
  );

  profilePackages = map mkProfileLauncher cfg.profiles;
in {
  inherit profileDesktopEntries profilePackages profileBookmarksActivation;

  profilesOption = mkOption {
    type = types.listOf (types.submodule ({ ... }: {
      options = {
        id = mkOption {
          type = types.strMatching "^[a-z0-9]+(-[a-z0-9]+)*$";
          description = ''
            Required profile identifier used for launcher names, profile directory,
            and WM_CLASS.

            Must be lowercase alphanumeric words separated by single dashes,
            for example: "my-profile".
          '';
        };
        displayName = mkOption {
          type = types.nullOr types.str;
          default = null;
          description = "Display name for the profile launcher and desktop entry.";
        };
        urls = mkOption {
          type = types.listOf types.str;
          default = [];
          description = "URLs ensured as bookmarks in a profile-specific folder on the bookmarks bar.";
        };
        createDesktopEntry = mkOption {
          type = types.bool;
          default = true;
          description = "Create an XDG desktop entry for launching this profile.";
        };
        icon = mkOption {
          type = types.oneOf [ types.str types.path ];
          default = "chromium-browser";
          description = "Desktop icon name or icon path. Local files should be passed as Nix path literals, for example ./icons/work.png.";
        };
        categories = mkOption {
          type = types.listOf types.str;
          default = [ "Network" "WebBrowser" ];
          description = "Desktop entry categories.";
        };
        keywords = mkOption {
          type = types.listOf types.str;
          default = [ "browser" "chromium" "profile" ];
          description = "Desktop entry keywords.";
        };
      };
    }));
    default = [];
    description = ''
      Extra Chromium launch profiles using Chromium's native profile handling.

      Each profile gets a launcher script and optional desktop entry. On start,
      Chromium launches the selected profile and bookmarks can be synchronized during activation.
    '';
    example = [
      {
        id = "work";
        displayName = "Chromium Profile Work";
        urls = [
          "https://calendar.google.com"
          "https://mail.google.com"
          "https://teams.microsoft.com"
        ];
      }
    ];
  };
}
