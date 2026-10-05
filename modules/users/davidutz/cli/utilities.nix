# Everyday command-line tools. Part of the base profile, so every machine gets them.
{
  flake.homeModules.davidutz =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        ripgrep
        fd
        jq
        duf
        ouch # (de)compress any archive format
        unzip
        zip
        trash-cli
        fetch
      ];

      programs.btop.enable = true;
      programs.bat.enable = true; # also the man pager (shell/zsh.nix)

      # programs.fastfetch.enable = true; # greeting in every new shell
    };
}
