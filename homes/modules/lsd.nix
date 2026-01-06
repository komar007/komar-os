{ ... }:
{
  programs.lsd.enable = true;
  programs.lsd.settings = {
    indicators = true;
    blocks = [
      "permission"
      "user"
      "group"
      "size"
      "date"
      "git"
      "name"
    ];
  };
  programs.lsd.colors = {
    user = 247;
    group = 244;
    permission = {
      read = 247;
      write = 199;
      exec = 118;
      exec-sticky = 5;
      no-access = 245;
      octal = 6;
      acl = "dark_cyan";
      context = "cyan";
    };
    date = {
      older = 23;
      day-old = 30;
      hour-old = 43;
    };
    size = {
      none = 245;
      small = 0;
      medium = 216;
      large = 172;
    };
    inode = {
      valid = 13;
      invalid = 245;
    };
    links = {
      valid = 13;
      invalid = 245;
    };
    tree-edge = 245;
    git-status = {
      default = 245;
      unmodified = 245;
      ignored = 245;
      new-in-index = "dark_green";
      new-in-workdir = "dark_green";
      typechange = "dark_yellow";
      deleted = "dark_red";
      renamed = "dark_green";
      modified = "dark_yellow";
      conflicted = "dark_red";
    };
  };
}
