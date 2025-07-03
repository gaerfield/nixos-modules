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
      KUBECONFIG = "$XDG_CONFIG_HOME/kube/config";
    };
    programs.fish = {
      # interactiveShellInit = ''
      #   set -a tide_right_prompt_items kubectl
      #   set -gx tide_show_kubectl_on kubectl helm kubens kubectx stern gcloud gcx kcx kns
      # '';
      shellAbbrs = {
        k = "kubectl";
        krestart = "kubectl rollout restart deployment ";
        kcx = "kubectx";
        kns = "kubens";
      };
    };
  };
}
