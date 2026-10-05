# zsh with Oh My Zsh and its plugins, ported from the CachyOS .zshrc. nixpkgs pins
# Oh My Zsh and every plugin, flake.lock pins nixpkgs. The prompt is in starship.nix,
# zoxide, direnv, atuin, eza and nix-your-shell in integrations.nix.
{
  # System side: zsh has to be enabled system-wide before it can be a login shell,
  # otherwise /etc/shells doesn't list it and completions for system packages are missing.
  flake.nixosModules.davidutz = { pkgs, ... }: {
    programs.zsh = {
      enable = true;
      # zsh-autocomplete sets up completion itself (see below). A compinit in
      # /etc/zshrc makes it throw the completion cache away and rebuild it on every
      # new shell, which held the first prompt back by 0.6-1 s. The prompt is
      # starship's, so /etc/zshrc's prompt theme only cost time too.
      enableGlobalCompInit = false;
      promptInit = "";
    };
    environment.pathsToLink = [ "/share/zsh" ];
    users.users.davidutz.shell = pkgs.zsh;

    # Replace the pacman aliases (update, cleanup, fixpacman) from CachyOS. Machines
    # without NixOS get `nh home` versions from standalone.nix.
    hm.programs.zsh.shellAliases = {
      update = "nh os switch --update";
      rebuild = "nh os switch";
      cleanup = "nh clean all --keep 5";
    };
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
      setOptions = [
        "HIST_REDUCE_BLANKS"
        "HIST_VERIFY"
      ];

      oh-my-zsh = {
        enable = true;
        theme = "";
        plugins = [
          "gitfast"
          "alias-finder"
          "battery"
        ];
        extraConfig = ''
          HIST_STAMPS="yyyy-mm-dd"
          zstyle ':omz:update' mode disabled
        '';
      };

      # Home-manager sources autosuggestions (order 700) before Oh My Zsh (800).
      # Listing it here instead moves it to order 900, after Oh My Zsh's key bindings.
      # zsh-autocomplete loads before Oh My Zsh, in initContent below.
      # Syntax highlighting stays at order 1200, after every widget exists.
      plugins = [
        {
          name = "zsh-autosuggestions";
          src = "${pkgs.zsh-autosuggestions}/share/zsh-autosuggestions";
          file = "zsh-autosuggestions.zsh";
        }
      ];
      syntaxHighlighting.enable = true;

      shellAliases = {
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
      };

      sessionVariables = {
        MANROFFOPT = "-c";
        MANPAGER = "sh -c 'col -bx | bat -l man -p'";
      };

      initContent = lib.mkMerge [
        # zsh-autocomplete runs compinit itself, on the first prompt, and rebuilds the
        # completion cache whenever something ran compinit before it. So it loads
        # before Oh My Zsh (800), whose compinit is a no-op here; the compdef calls
        # in Oh My Zsh's plugins wait in zsh-autocomplete's queue until then.
        (lib.mkOrder 790 ''
          source ${pkgs.zsh-autocomplete}/share/zsh-autocomplete/zsh-autocomplete.plugin.zsh
          compinit() { : }
        '')
        # zsh-autocomplete keeps its completion cache in ~/.cache/zsh/compdump instead
        # of Oh My Zsh's file. Oh My Zsh deletes its file whenever fpath changes (every
        # switch), and zsh-autocomplete appended Oh My Zsh's markers to it on each start.
        #
        # Oh My Zsh binds Up and Down to its own history search; give them back to
        # zsh-autocomplete (history menu on Up, completion menu on Down).
        (lib.mkOrder 810 ''
          unfunction compinit
          unset ZSH_COMPDUMP
          bindkey '^[[A' up-line-or-search
          bindkey '^[OA' up-line-or-search
          bindkey '^[[B' down-line-or-select
          bindkey '^[OB' down-line-or-select
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

        # After starship.nix's transient prompt (1500), so the greeting comes last.
        (lib.mkOrder 1510 ''
          [[ -o interactive ]] && command -v fastfetch >/dev/null && fastfetch
        '')
      ];
    };

    home.sessionPath = [
      "$HOME/.local/bin"
      "$HOME/.bun/bin"
    ];
  };
}
