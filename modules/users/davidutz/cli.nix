# Terminal tools. Part of the base profile, so the headless pi gets them too.
{ inputs, ... }: {
  flake.homeModules.davidutz = { pkgs, ... }: {
    home.packages = with pkgs; [
      ripgrep
      fd
      jq
      btop
      duf
      ouch
      unzip
      zip
      trash-cli
      tmux-sessionizer # provides `tms`, used in tmux.conf's status line
      neovim
      gcc # LazyVim compiles treesitter parsers
      gnumake
    ];

    programs.tmux = {
      enable = true;
      # Same file stow links on CachyOS. It sets the prefix, keys and status line itself.
      extraConfig = builtins.readFile "${inputs.dotfiles}/tmux/.config/tmux/tmux.conf";
    };

    # Plain package, not programs.neovim: that module writes ~/.config/nvim/init.lua,
    # which would replace the LazyVim config that lives there.
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
