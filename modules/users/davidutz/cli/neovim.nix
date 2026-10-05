# Neovim with LazyVim. The LazyVim config in ~/.config/nvim isn't managed here yet
# (TODO.md), so this is the plain package, not programs.neovim: that module writes
# ~/.config/nvim/init.lua, which would replace it.
{
  flake.homeModules.davidutz =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        neovim
        # LazyVim compiles treesitter parsers.
        gcc
        gnumake
      ];

      home.sessionVariables = {
        EDITOR = "nvim";
        VISUAL = "nvim";
      };
      programs.zsh.shellAliases = {
        vi = "nvim";
        vim = "nvim";
      };
    };
}
