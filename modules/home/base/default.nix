{ config, lib, osConfig, ... }: {
  imports = [
    ./xdg.nix
    ./nix.nix
  ];

  persistence.directories = with config.xdg; [ 
    "${config.home.homeDirectory}/.ssh"

    # Currently I have no better place for these
    "${cacheHome}/mesa_shader_cache_db"   # mesa shader cache (Vulkan and OpenGL)
    "${cacheHome}/obexd"                  # bluetooth dbus service stuff
  ]
      # thats here because of audio.nix and I didn't wanted to add another file for this single line
      ++ lib.optionals osConfig.services.pipewire.enable [ "${config.xdg.stateHome}/wireplumber" ]
      ++ lib.optionals osConfig.programs.appimage.enable [ "${config.home.homeDirectory}/Applications" "${config.xdg.cacheHome}/appimage-run" ];
}
