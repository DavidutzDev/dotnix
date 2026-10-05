# Starship prompt, in the palette from theme.nix:
#
#   ~/p/dotnix  main !2 ?1  nix-shell  took 3s
#   ❯
#
# user@host shows only over SSH. Language versions (rust, node, python, ...) show
# in projects that use them. After each command the prompt shrinks to the ❯ alone,
# so scrollback shows commands, not prompts.
{
  flake.homeModules.davidutz =
    { config, lib, ... }:
    {
      programs.starship = {
        enable = true;
        # Nerd Font icons for every module instead of emoji. `settings` wins over it.
        presets = [ "nerd-font-symbols" ];

        settings = {
          palette = "theme";
          palettes.theme = lib.mapAttrs (_: hex: "#${hex}") config.davidutz.theme.colors;

          # The modules listed first come first; $all adds every other module in
          # its default place, which ends with the line break and the ❯.
          format = lib.concatStrings [
            "$username"
            "$hostname"
            "$directory"
            "$git_branch"
            "$git_state"
            "$git_status"
            "$nix_shell"
            "$all"
          ];

          username = {
            style_user = "bold mauve";
            style_root = "bold red";
            format = "[$user]($style)";
          };
          hostname = {
            style = "bold mauve";
            format = "[@$hostname]($style) ";
          };

          directory = {
            style = "bold lavender";
            read_only = " 󰌾";
            truncation_length = 3;
            truncation_symbol = "…/";
            fish_style_pwd_dir_length = 1;
          };

          git_branch = {
            symbol = " ";
            style = "bold mauve";
            format = "[$symbol$branch]($style) ";
          };
          git_status = {
            style = "bold peach";
            format = "([$all_status$ahead_behind]($style) )";
          };
          git_state.style = "bold yellow";

          # Inside `nix develop` (it sets IN_NIX_SHELL), with the shell's name.
          nix_shell = {
            symbol = " ";
            style = "bold blue";
            format = "[$symbol$name]($style) ";
          };

          cmd_duration = {
            min_time = 2000;
            style = "yellow";
            format = "took [$duration]($style) ";
          };

          character = {
            success_symbol = "[❯](bold green)";
            error_symbol = "[❯](bold red)";
            vimcmd_symbol = "[❮](bold green)";
          };

          # The transient prompt below runs `starship prompt --profile transient`.
          profiles.transient = "$character";
        };
      };

      # Starship's own transient prompt is fish only, so zsh gets it here. Starship
      # initialises at the default order (1000); this reads the PROMPT it sets, so
      # it runs later.
      programs.zsh.initContent = lib.mkOrder 1500 ''
        autoload -Uz add-zle-hook-widget
        STARSHIP_TRANSIENT_PROMPT="''${PROMPT// prompt / prompt --profile transient }"
        transient-prompt() {
          PROMPT="$STARSHIP_TRANSIENT_PROMPT" RPROMPT="" zle .reset-prompt
        }
        add-zle-hook-widget zle-line-finish transient-prompt
      '';
    };
}
