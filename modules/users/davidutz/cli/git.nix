{
  flake.homeModules.davidutz =
    { pkgs, ... }:
    {
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

      # Forgejo CLI (`fj`): issues, pull requests and releases on Forgejo instances
      # such as Codeberg. `fj auth login` once per instance.
      home.packages = [ pkgs.forgejo-cli ];
    };
}
