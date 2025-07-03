_: {
  programs.ranger = {
    enable = true;
    settings = {
      preview_images = true;
      preview_images_method = "kitty";
      vcs_aware = true;
      mouse_enabled = true;
      update_title = true;
    };
    # rifle = [
    #   {
    #     condition = "mime ^text";
    #     command = ''nvim -nw -- "$@"'';
    #   }
    # ];
  };
}
