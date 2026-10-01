# Coding agents, for machines that run them (this desktop, a headless AI box).
# Not part of any profile: a host opts in with
#   hm.imports = [ self.homeModules.davidutzAgents ];
# Machines that only drive agents running elsewhere (the laptop) just need T3 Code,
# which is in the desktop profile (apps.nix).
{
  flake.homeModules.davidutzAgents =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        claude-code # `claude`
        antigravity-cli # `agy`
      ];

      # The store is read-only, so Claude Code's self-updater can only fail.
      # Updates come from `nix flake update`.
      home.sessionVariables.DISABLE_AUTOUPDATER = "1";
    };
}
