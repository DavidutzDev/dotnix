# Skills and instructions from the dotagents repo, replacing its install.sh.
# Skills are linked one by one so ~/.claude/skills can still hold other entries
# (claude.ai's synced/). Updates come from `nix flake update dotagents`.
{ inputs, ... }: {
  flake.homeModules.davidutzAgents =
    { lib, ... }:
    let
      src = inputs.dotagents;
      skills = lib.filterAttrs (_: type: type == "directory") (builtins.readDir "${src}/skills");
    in
    {
      home.file =
        lib.mapAttrs' (
          name: _: lib.nameValuePair ".claude/skills/${name}" { source = "${src}/skills/${name}"; }
        ) skills
        // {
          ".claude/CLAUDE.md".source = "${src}/claude/CLAUDE.md";
          ".claude/RTK.md".source = "${src}/claude/RTK.md";
          ".claude/unslop.md".source = "${src}/skills/unslop/SKILL.md";
        };
    };
}
