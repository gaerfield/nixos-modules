{config, lib, inputs, pkgs, system, ...}: with lib; let
  cfg = config.gnm.hm.cloud;
  pkgs = inputs.nixpkgs.legacyPackages.${system};
  gdk = pkgs.google-cloud-sdk.withExtraComponents (with pkgs.google-cloud-sdk.components; [
    gke-gcloud-auth-plugin
  ]);
in {
  config = mkIf cfg.enable {
    home = {
      packages = with pkgs; [ gdk ];
      sessionVariables = { USE_GKE_GCLOUD_AUTH_PLUGIN = "True"; };
    };
    programs.fish = {
      shellAbbrs.gcx = {
        setCursor = true;
        expansion = "gcloud config configurations activate payfree-%";
      };
      # interactiveShellInit = ''
      #  set -a tide_right_prompt_items gcloud
      #  set -gx tide_show_gcloud_on kubectl helm kubens kubectx stern gcloud gcx k kcx kns
      # '';
      plugins = [
        # Manually pull fish completions for gcloud
        # https://github.com/lgathy/google-cloud-sdk-fish-completion
        {
          name = "google-cloud-sdk-fish-completion";
          src = pkgs.fetchFromGitHub {
            owner = "lgathy";
            repo = "google-cloud-sdk-fish-completion";
            rev = "bc24b0bf7da2addca377d89feece4487ca0b1e9c";
            sha256 = "sha256-BIbzdxAj3mrf340l4hNkXwA13rIIFnC6BxM6YuJ7/w8=";
          };
        }
      ];
    };
  };
}
