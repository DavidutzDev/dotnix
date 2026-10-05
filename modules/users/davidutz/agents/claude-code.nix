# Coding agents are their own profile, for machines that run them (this desktop, a
# headless AI box). A host opts in with
#   hm.imports = [ self.homeModules.davidutzAgents ];
# Machines that only drive agents running elsewhere just need T3 Code (apps/dev).
{
  flake.homeModules.davidutzAgents =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.claude-code ];

      # The store is read-only, so Claude Code's self-updater can only fail.
      # Updates come from `nix flake update`.
      home.sessionVariables.DISABLE_AUTOUPDATER = "1";
    };
}
