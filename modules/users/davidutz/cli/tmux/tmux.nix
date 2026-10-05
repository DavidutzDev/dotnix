# tmux, with C-a as prefix, vim-style pane keys, and tmux-sessionizer on C-f.
{
  flake.homeModules.davidutz =
    { lib, pkgs, ... }:
    let
      # ThePrimeagen's tmux-sessionizer: fzf over ~/personal and ~/work, then a session
      # per project. Upstream script, so its style is left alone.
      sessionizer = pkgs.writeShellApplication {
        name = "tmux-sessionizer";
        runtimeInputs = with pkgs; [
          tmux
          fzf
          findutils
        ];
        bashOptions = [ ];
        excludeShellChecks = [
          "SC1090"
          "SC2004"
          "SC2086"
          "SC2155"
        ];
        text = builtins.readFile ./tmux-sessionizer.sh;
      };
    in
    {
      programs.tmux = {
        enable = true;
        prefix = "C-a";
        baseIndex = 1; # windows and panes
        escapeTime = 0;
        focusEvents = true;
        extraConfig = ''
          set -g status-position top
          set -g status-right " #(tms sessions)"
          set -g renumber-windows on

          # Not keyMode = "vi": that also switches the command prompt (status-keys).
          setw -g mode-keys vi
          bind -T copy-mode-vi v send-keys -X begin-selection
          bind -T copy-mode-vi y send-keys -X copy-pipe-and-cancel 'xclip -in -selection clipboard'
          bind v copy-mode

          # vim-like pane switching
          bind -r ^ last-window
          bind -r k select-pane -U
          bind -r j select-pane -D
          bind -r h select-pane -L
          bind -r l select-pane -R

          bind-key C-h select-window -t 1
          bind-key C-j select-window -t 2
          bind-key C-k select-window -t 3
          bind-key C-l select-window -t 4
          bind-key C-o select-window -t 5

          bind C-x confirm-before -p "Kill current session? (y/n)" "kill-session"
          bind C-z confirm-before -p "Kill all other sessions? (y/n)" "kill-session -a"
          bind-key -r -n C-f run-shell "tmux neww ${lib.getExe sessionizer}"
        '';
      };

      home.packages = [
        sessionizer
        pkgs.tmux-sessionizer # the Rust one, `tms`: the status line lists its sessions
      ];

      xdg.configFile."tmux-sessionizer/tmux-sessionizer.conf".text = ''
        TS_SEARCH_PATHS=("$HOME/personal")
        TS_EXTRA_SEARCH_PATHS=("$HOME/work:2")
        TS_LOG=true
      '';

      # Runs in every new session: opens the nvim, scratch, runner, logs and ai windows,
      # and starts the dev servers in Laravel projects.
      home.file.".tmux-sessionizer".source = ./hydrate.sh;
    };
}
