{
  flake.homeModules.davidutz = {
    programs.git = {
      enable = true;
      settings = {
        user.name = "David Gheghea";
        user.email = "71325082+DavidutzDev@users.noreply.github.com";
        init.defaultBranch = "main";
        pull.rebase = true;
      };
    };

    programs.lazygit.enable = true;
  };
}
