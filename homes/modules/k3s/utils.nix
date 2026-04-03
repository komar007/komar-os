{ pkgs, ... }:
{
  kubetuiWithNamespace =
    let
      kubetui = pkgs.lib.getExe pkgs.kubetui;
    in
    ns: "KUBECONFIG=/etc/rancher/k3s/k3s.yaml ${kubetui} -n ${ns}";
}
