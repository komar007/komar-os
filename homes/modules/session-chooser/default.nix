{ pkgs, ... }: {
  home.packages = [
    (pkgs.writeShellApplication {
      name = "session-chooser";
      runtimeInputs = with pkgs; [ fzf openssh ];
      text = builtins.readFile ./session-chooser.sh;
    })
  ];
}
