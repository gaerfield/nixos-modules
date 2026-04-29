{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.gnm.hm.cloud;
in {
  config = mkIf cfg.enable {
    home.packages = with pkgs; [kubectl k9s kubectx];
    home.sessionVariables = {
      KUBECONFIG = "${config.xdg.configHome}/kube/config";
    };
    programs.fish = {
      # interactiveShellInit = ''
      #   set -a tide_right_prompt_items kubectl
      #   set -gx tide_show_kubectl_on kubectl helm kubens kubectx stern gcloud gcx kcx kns
      # '';
      shellAbbrs = {
        k = "kubectl";
        krestart = "kubectl rollout restart deployment";
        kcx = "kubectx";
        kns = "kubens";
      };
    };

    persistence.directories = [
      { directory = "${config.xdg.configHome}/kube"; mode = "0700"; }
      { directory = "${config.xdg.configHome}/k9s"; mode = "0700"; }
      { directory = "${config.xdg.dataHome}/k9s"; mode = "0700"; }
      { directory = "${config.xdg.stateHome}/k9s"; mode = "0700"; }
    ];
  };
}