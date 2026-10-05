# Tools that hook into the shell: zoxide (`z`), direnv (per-project environments,
# with nix-direnv for `use flake`), atuin (history search on ^R), eza (ls) and
# nix-your-shell (`nix develop` and `nix shell` open zsh, not bash).
{
  flake.homeModules.davidutz = {
    programs.zoxide.enable = true;

    programs.direnv = {
      enable = true;
      nix-direnv.enable = true;
    };

    # Atuin owns ^R only. Up arrow stays with zsh-autocomplete.
    programs.atuin = {
      enable = true;
      flags = [ "--disable-up-arrow" ];
    };

    # ls, ll, la, lt and lla, all with icons, git status and folders first.
    programs.eza = {
      enable = true;
      icons = "auto";
      git = true;
      extraOptions = [ "--group-directories-first" ];
    };

    programs.nix-your-shell.enable = true;
  };
}
