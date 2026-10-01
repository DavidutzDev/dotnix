# Port of ~/dotfiles/zsh/.zshrc. Home-manager replaces the pinned ~/.oh-my-zsh
# checkout: nixpkgs pins Oh My Zsh and every plugin, flake.lock pins nixpkgs.
{
  # System side: zsh has to be enabled system-wide before it can be a login shell,
  # otherwise /etc/shells doesn't list it and completions for system packages are missing.
  flake.nixosModules.davidutz = { pkgs, ... }: {
    programs.zsh.enable = true;
    environment.pathsToLink = [ "/share/zsh" ];
    users.users.davidutz.shell = pkgs.zsh;
  };

  flake.homeModules.davidutz = { lib, pkgs, ... }: {
    programs.zsh = {
      enable = true;

      history = {
        size = 100000;
        save = 100000;
        ignoreAllDups = true;
        extended = true;
      };
      setOptions = [ "HIST_REDUCE_BLANKS" "HIST_VERIFY" ];

      oh-my-zsh = {
        enable = true;
        theme = "";
        plugins = [ "gitfast" "alias-finder" "battery" ];
        extraConfig = ''
          HIST_STAMPS="yyyy-mm-dd"
          zstyle ':omz:update' mode disabled
        '';
      };

      # Home-manager sources autosuggestions (order 700) before Oh My Zsh (800).
      # Listing both plugins here instead moves them to order 900, after Oh My Zsh's
      # key bindings, which is the order the CachyOS .zshrc relies on.
      # Syntax highlighting stays at order 1200, after every widget exists.
      plugins = [
        {
          name = "zsh-autocomplete";
          src = "${pkgs.zsh-autocomplete}/share/zsh-autocomplete";
          file = "zsh-autocomplete.plugin.zsh";
        }
        {
          name = "zsh-autosuggestions";
          src = "${pkgs.zsh-autosuggestions}/share/zsh-autosuggestions";
          file = "zsh-autosuggestions.zsh";
        }
      ];
      syntaxHighlighting.enable = true;

      shellAliases = {
        ls = "eza -al --color=always --group-directories-first --icons";
        la = "eza -a --color=always --group-directories-first --icons";
        ll = "eza -l --color=always --group-directories-first --icons";
        lt = "eza -aT --color=always --group-directories-first --icons";
        "l." = "eza -a | grep -e '^\\.'";

        tarnow = "tar -acf ";
        untar = "tar -zxvf ";
        wget = "wget -c ";
        psmem = "ps auxf | sort -nr -k 4";
        psmem10 = "ps auxf | sort -nr -k 4 | head -10";
        ".." = "cd ..";
        "..." = "cd ../..";
        "...." = "cd ../../..";
        grep = "grep --color=auto";
        jctl = "journalctl -p 3 -xb";

        # Replace the pacman aliases (update, cleanup, fixpacman) from CachyOS.
        update = "nh os switch --update";
        rebuild = "nh os switch";
        cleanup = "nh clean all --keep 5";
      };

      sessionVariables = {
        MANROFFOPT = "-c";
        MANPAGER = "sh -c 'col -bx | bat -l man -p'";
      };

      initContent = lib.mkMerge [
        # zsh-autocomplete's helper functions live in Completions/. Oh My Zsh runs
        # compinit at order 800, so the directory must be on fpath before that.
        (lib.mkOrder 550 ''
          fpath=("${pkgs.zsh-autocomplete}/share/zsh-autocomplete/Completions" $fpath)
        '')

        ''
          # Tab opens the menu, then every Tab steps to the next entry.
          bindkey '^I' menu-select

          backup() {
            cp -- "$1" "$1.bak"
          }

          for _work_rc in "$HOME/work/unxwares/config/shell.zsh" "$HOME/work/unxwares/config/shell.sh"; do
            [[ -f "$_work_rc" ]] && source "$_work_rc" && break
          done
          unset _work_rc
        ''

        # Starship, zoxide and atuin initialise at the default order (1000). The
        # transient prompt reads the PROMPT that starship sets, so it runs later.
        (lib.mkOrder 1500 ''
          autoload -Uz add-zle-hook-widget
          STARSHIP_TRANSIENT_PROMPT="''${PROMPT// prompt / prompt --profile transient }"
          transient-prompt() {
            PROMPT="$STARSHIP_TRANSIENT_PROMPT" RPROMPT="" zle .reset-prompt
          }
          add-zle-hook-widget zle-line-finish transient-prompt

          [[ -o interactive ]] && command -v fastfetch >/dev/null && fastfetch
        '')
      ];
    };

    home.sessionPath = [ "$HOME/.local/bin" "$HOME/.bun/bin" ];

    programs.starship = {
      enable = true;
      # ~/.zshrc rewrites PROMPT into `starship prompt --profile transient`, so this
      # profile must exist or Starship errors after every command.
      settings.profiles.transient = "$character";
    };

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
    # Not programs.eza: its zsh integration defines ls/ll/la/lt aliases that
    # conflict with the ones above.
    home.packages = [ pkgs.eza ];
    programs.bat.enable = true;
    programs.fastfetch.enable = true;
  };
}
