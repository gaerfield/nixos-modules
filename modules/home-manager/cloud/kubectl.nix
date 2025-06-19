{ pkgs, ... }: {
  home.packages = with pkgs; [ kubectl k9s kubectx ];
  home.sessionVariables = {
    KUBECONFIG = "$XDG_CONFIG_HOME/kube/config";
  };
  programs.fish = {
    # interactiveShellInit = ''
    #   set -a tide_right_prompt_items kubectl
    #   set -gx tide_show_kubectl_on kubectl helm kubens kubectx stern gcloud gcx kcx kns
    # '';
    shellAbbrs.k = "kubectl";
    shellAbbrs.krestart = "kubectl rollout restart deployment ";
    shellAbbrs.kcx = "kubectx";
    shellAbbrs.kns = "kubens";
  };
}