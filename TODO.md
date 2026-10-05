# TODO

Goal: a NixOS host that does everything `desktop-btw` (CachyOS, set up by
`~/home-sweet-home` + stow from `~/dotfiles`) does today.

The checklist follows the module list in `home-sweet-home/hosts/desktop-btw/main.sh`,
`pacman -Qqe`, and the enabled systemd units on the CachyOS box.

Check your work with:

```sh
nix flake check                       # evaluates every host and home config
nh os build                           # builds the host matching $HOSTNAME
nh os switch                          # builds and activates it
home-manager switch --flake .                # machines without NixOS (standalone.nix)
```

## How the repo is laid out

Every `.nix` file under `modules/` is a flake-parts module, loaded automatically by
`import-tree`. Nothing lists files by hand, so creating a file is enough to register it.

```
modules/
  parts.nix               systems, formatter, flake-parts imports
  system/<name>.nix       machine features: nixosModules.<name> (nix, hyprland)
  users/davidutz/         everything about you; every file adds to one of:
                            nixosModules.davidutz        account, login shell, terminal setup
                            homeModules.davidutz         terminal setup (everywhere)
                            homeModules.davidutzDesktop  Hyprland config, GUI apps, T3 Code
                            homeModules.davidutzAgents   Claude Code, agy
    account.nix           the account and the `hm` alias
    standalone.nix        homeConfigurations for machines without NixOS
    theme.nix             the palette (base profile), GTK and Qt (desktop profile)
    shell/                zsh, starship, zoxide/direnv/atuin, nix-your-shell
    cli/                  git, tmux, neovim, command-line utilities
    desktop/              the session: hyprland/, mochi
                          (the shell, its keys, screenshots, media, power), lock
                          screen, audio, brightness, clipboard, wallpapers/
    apps/<category>/      one file per GUI app: package, settings, launch key
    agents/               one file per coding agent
  hosts/<host>/           hardware + host settings; imports system features and users;
                          sets host-only home options (monitors, GPU env)
```

Hyprland's config is plain Lua in `wayland.windowManager.hyprland.extraConfig`,
rendered to `hyprland.lua`. Each file writes the part it owns, so the Lua for a thing
sits next to the thing:

- `desktop/hyprland/`: env, input, appearance and the window/workspace keys.
- `apps/<category>/<app>.nix`: the app's launch key (`hl.bind`) and window rules
  (`hl.window_rule`).
- `desktop/mochi.nix`: Mochi's keys (launcher, hub, notifications, capture, media).
- `hosts/<host>/configuration.nix`: `hl.monitor` and `hl.workspace_rule`.
- Commands run once at startup go in `hl.on("hyprland.start", function() ... end)`.
  Daemons are systemd user services instead (`services.awww`, `services.wl-clip-persist`).

Check the result with
`Hyprland --verify-config -c ~/.config/hypr/hyprland.lua`.

`davidutz.theme.colors` (`theme.nix`) is the palette. Starship, Hyprland, ghostty,
hyprlock and Mochi's theme read it.

Prefer a home-manager `programs.<app>` / `services.<app>` module when it configures
something; a plain `home.packages` entry otherwise. Keep a file next to its module
only for what is code or style, not settings: CSS, shell
scripts that came from upstream.

Several files can set the same module name (`homeModules.davidutz`), and the module
system merges them. So a user file doesn't import anything. The dendritic README
recommends this: "Consider merging multiple non-distinct lower-level modules under
one distinct name."

To add something:

- Something only you use (a program, dotfile, alias): a new file in the matching
  directory of `modules/users/davidutz/` that sets `flake.homeModules.davidutz`
  (terminal) or `flake.homeModules.davidutzDesktop` (GUI). If it also needs a system
  setting, set `flake.nixosModules.davidutz` in the same file, as `shell/zsh.nix` does.
- Something the machine provides (Steam, Docker, NVIDIA, Bluetooth): a new file in
  `modules/system/` that sets `flake.nixosModules.<name>`, then add `<name>` to the
  `imports` of each host that should have it.
- Then run `nix flake check`.

Each host picks your profiles on top of the terminal setup, for example:
this desktop and a headless AI box `hm.imports = [ davidutzAgents ]` (plus
`davidutzDesktop` on the desktop), a laptop only `davidutzDesktop`.

If a second person ever uses these machines, give them `modules/users/<name>/` with
their own three modules and import `nixosModules.<name>` on the hosts they use.

References: https://github.com/mightyiam/dendritic, https://flake.parts

## Done in this pass

- [x] Split config into `modules/system/` (machine) and `modules/users/davidutz/` (you).
- [x] zsh ported from `~/dotfiles/zsh/.zshrc`: Oh My Zsh (gitfast, alias-finder,
      battery), zsh-autocomplete, zsh-autosuggestions, zsh-syntax-highlighting, starship
      with the transient prompt, zoxide, direnv + nix-direnv, atuin (^R only), eza
      aliases, fastfetch greeting, work rc hook. Load order matches the CachyOS file.
- [x] zsh is the login shell (`users.users.davidutz.shell`) and enabled system-wide.
- [x] Hyprland: NixOS module with UWSM, hyprlock PAM, portals, keyring, fonts.
      Home side in `users/davidutz/desktop/hyprland/` (section 0).
- [x] tmux and ghostty as home-manager options; the `dotfiles` input is gone (section 0).
- [x] `git` options moved to `programs.git.settings` (the old names were deprecated).
- [x] `nh` for rebuilds and store cleanup, `auto-optimise-store`, `allowUnfree`.
- [x] `home-manager` follows the flake's `nixpkgs`, so there is one nixpkgs to download.
- [x] Host output renamed `testVm` to `test-vm` to match its hostname.
- [x] `test-vm` now describes desktop-btw: hardware, kernel, NVIDIA, passthrough
      kernel settings, and the system services from the CachyOS install.
- [x] Disks in disko (`hosts/test-vm/disko.nix`), root wiped on every boot, system
      state kept with preservation (`system/impermanence.nix`). VM test in
      `modules/checks/impermanence.nix` (`nix flake check`, needs KVM).
- [x] Waybar, Walker + Elephant and swaync restored from dotfiles history as the
      desktop shell (`users/davidutz/desktop/`). Odyssey is dropped: its keys call
      Walker, swaync, wpctl, hyprshot and hyprlock directly.
- [x] Agents profile (Claude Code, agy) separate from the desktop; hosts opt in.
- [x] `hm` alias: `hm.<option>` in a NixOS module sets `home-manager.users.davidutz.<option>`.
- [x] The pi config gets the terminal profile only, not Hyprland.
- [x] `.gitignore`, `nix fmt` (nixfmt-tree).

## 0. Retiring `~/dotfiles`

Every machine runs home-manager: NixOS hosts through `nixosModules.davidutz`, everything
else through `users/davidutz/standalone.nix` (`home-manager switch --flake .`). Config
moves out of `~/dotfiles` into `modules/users/davidutz/`, as home-manager options where
they exist and as files next to the module otherwise.

Done:

- [x] Flake input `dotfiles` removed.
- [x] Hyprland: the Lua framework (`core/`, `config/`, `themes/`) is now Nix in
      `desktop/hyprland/`, checked with `Hyprland --verify-config` and against the
      old config's calls. App keys and rules moved to the app files, monitors and the
      NVIDIA env to the host. Changed on the way: SUPER + B runs `zen-beta` and
      SUPER + SHIFT + C `codium` (the old commands didn't exist on NixOS);
      `QT_QPA_PLATFORMTHEME=qt5ct` and the startup `gsettings` calls are gone (they
      fought the GTK/Qt settings in `theme.nix`); the portal and
      dbus/systemctl env imports are gone (NixOS and UWSM do them); awww and
      wl-clip-persist are systemd services.
- [x] Waybar, swaync, Walker + Elephant replaced by Mochi (`desktop/mochi.nix`, the
      `mochi` flake input): bar, launcher, notifications, OSD and power menu, coloured
      from `davidutz.theme`. Dropped with them: the clipboard history
      (SUPER + V), the wallpaper menu (SUPER + Y) and the `mic-status` script.
- [x] ghostty, tmux (+ tmux-sessionizer as a package),
      wallpapers (`desktop/wallpapers/`).
- [x] zsh, starship, zoxide, direnv, atuin (`shell/`), already ported before.
- [x] `pi.nix` became `standalone.nix`: `davidutz` (x86_64, terminal) for any machine,
      `davidutz@<host>` entries in `machines` for the ones that need more.

Still in `~/dotfiles`:

- [ ] `ssh/`: `services.ssh-agent.enable = true;` with the 30-minute key timeout
      (`ssh-agent -t 1800`), and `SSH_ASKPASS` (ksshaskpass is a KDE app; pick one
      packaged in nixpkgs).
- [ ] `zsh/.zshenv`: sources `~/.cargo/env`. Drop it once rustup comes from Nix (section 8).
- [ ] `qt/`: qt5ct/qt6ct with the Catppuccin Mocha Lavender colours. Conflicts with
      `qt.platformTheme.name = "adwaita"` in `theme.nix`; decide together with section 9.
- [ ] `thunar/` (`accels.scm`, `uca.xml`) and `dolphin/` (`dolphinrc`): only if those
      file managers come back; `xdg.configFile` the files.
- [ ] `zen-browser/.zen-chrome/*.css`: `programs.zen-browser.profiles.default.userChrome`
      / `userContent` in `apps/browsers/zen-browser.nix`.
- [ ] wepapered (`wepaperedctl gui` on SUPER + SHIFT + W, and its daemon) and
      nekoland were autostarted by the old Hyprland config. Neither is packaged:
      package them, then give each an `apps/` file with `autostart = true`.
- [ ] `bin/` binaries (`ccd`, `cco`, `ficsit`, `herdr`, `ironfoil`, `nekoland`, `rtk`)
      and the `jcode`/`t3` symlinks: package them (or use nixpkgs) instead of
      committing binaries. `herdr-jcode`, `herdr-jcode-reporter` and
      `remuda-status-check` go with herdr.
- [ ] Idle: hypridle was only enabled for Odyssey and is gone. To lock or turn the
      screens off when idle, add `services.hypridle.settings` (home-manager) next to
      `desktop/lock.nix`.
- [ ] Screen recording (Odyssey's SUPER + SHIFT + R): gpu-screen-recorder, section 6.
- [ ] Standalone desktop on another distro: GUI apps from nixpkgs need OpenGL from
      the host. Add `targets.genericLinux.nixGL` (https://github.com/nix-community/nixGL)
      before giving such a machine `davidutzDesktop`.
- [ ] Set zsh as login shell by hand on standalone machines (`chsh -s ~/.nix-profile/bin/zsh`
      after adding it to `/etc/shells`); home-manager can't do that.
- [ ] Archive the dotfiles repo on GitHub once the list above is empty.

## 1. Installing on desktop-btw

`hosts/test-vm` now describes this machine (desktop-btw). The directory and hostname
stay `test-vm` until the rename. When renaming, change the directory,
`networking.hostName`, the `flake.nixosConfigurations.<name>` key and the two
`testVm*` module names together, because `nh` picks the config by hostname.

- [ ] Follow INSTALL.md. It reorganises the data disk from CachyOS, then installs
      into the existing partitions: the root is wiped on every boot, `@home` and the
      data disk are kept, nothing is reformatted.
- [ ] The password is `/persist/passwords/davidutz` (INSTALL.md B6). Move it to sops
      later (section 10) so it's in the repo, encrypted.
- [ ] Add your SSH public key: `users.users.davidutz.openssh.authorizedKeys.keys`.
      Password login over SSH is off, so without a key you can't reach the headless
      session while the GPU is in the VM.
- [ ] systemd-boot sits next to CachyOS's Limine on the same ESP. Once CachyOS is
      gone, delete `/boot/limine*`, the CachyOS kernels in `/boot`, and `@cachyos`.

## 2. Hardware (Ryzen 5 5600X, GTX 1060 6GB)

Done in `hosts/test-vm/`: filesystems (all 13 mounts from `/etc/fstab`), microcode,
NVIDIA 580 legacy driver with VA-API, zen kernel, Plymouth, Bluetooth, ratbagd (Piper),
Oversteer udev rules.

- [ ] Check the monitor names in `config/monitors.lua` (`DP-3`, `HDMI-A-1`) with
      `hyprctl monitors` after first boot. They can differ between kernels.
- [ ] If you want the exact CachyOS kernel instead of zen:
      https://github.com/xddxdd/nix-cachyos-kernel (check that `legacy_580` builds against it).
- [ ] Solaar (Logitech receiver), only if you still use it:
      `hardware.logitech.wireless = { enable = true; enableGraphical = true; };`

## 3. CachyOS performance tweaks

Done in `system/performance.nix`: ananicy-cpp with CachyOS rules, zram (size = RAM,
zstd), every sysctl from `70-cachyos-settings.conf`, `nowatchdog`, fstrim,
power-profiles-daemon.

- [ ] sched-ext is not enabled on CachyOS today (`scx_loader` not found). If you want it:
      `services.scx = { enable = true; scheduler = "scx_lavd"; };`
- [ ] Snapshots of `/home` and the data disk subvolumes (CachyOS uses snapper). `/`
      is recreated every boot, so only user data needs this:
      `services.snapper.configs.home = { SUBVOLUME = "/home"; TIMELINE_CREATE = true; TIMELINE_CLEANUP = true; };`
      https://wiki.nixos.org/wiki/Snapper

## 4. System services

Done in `system/`: NetworkManager + OpenVPN, resolved, avahi, sshd (keys only),
Tailscale, firewall (`network.nix`); PipeWire (`audio.nix`); Docker, libvirt, virt-manager,
quickemu (`virtualisation.nix`); Steam, gamemode, gamescope, Proton-GE (`gaming.nix`);
gvfs, tumbler, udisks2, Flatpak, Sunshine, nix-ld (`desktop.nix`). Your user joins the
docker, libvirtd and gamemode groups on hosts that enable those services.

- [ ] Single-GPU passthrough. The kernel side is in the host (IOMMU, ACS override,
      `kvm ignore_msrs`). The `~/win-vm` scripts need checking on NixOS:
  - [ ] Shebangs and hardcoded paths (`/usr/bin/quickemu`, `/usr/lib/...`) don't
        exist on NixOS. Use `#!/usr/bin/env bash` and commands from `PATH`.
  - [ ] `gpu-unbind.sh` restarts sddm and rebinds `nvidia`; check the unit and module
        names match (`display-manager.service` on NixOS).
  - [ ] The TPM passthrough in `windows-11.conf` uses `/dev/tpm0`; add yourself to
        `tss` (`security.tpm2.enable = true;` creates it).
- [ ] Firewall ports. CachyOS's ufw rules weren't readable without sudo. Run
      `sudo ufw status numbered` and add anything not covered by an `openFirewall`
      option to `networking.firewall.allowedTCPPorts`.
- [ ] Declarative Flatpaks (Sober, Bottles, SysDVR): https://github.com/gmodena/nix-flatpak
- [ ] User services from CachyOS: `verdaccio.service`. Write it as
      `systemd.user.services.verdaccio` in `users/davidutz/`.
- [ ] Printing: CachyOS has no CUPS, so it's off. `services.printing.enable = true;` if needed.

## 5. Hyprland session gaps

The Lua config comes over unchanged, so anything it runs by name must exist on NixOS.

- [ ] SDDM theme: pick one and set `services.displayManager.sddm.theme`.
- [x] App commands that differ on NixOS: zen (`zen-beta`), Spotify (`spotify`),
      VSCodium (`codium`). wepapered and nekoland: section 0.
- [ ] tmux (`cli/tmux/tmux.nix`) copies with `xclip`, which doesn't work under Wayland. Switch it to `wl-copy`.
- [ ] Neovim config (`~/.config/nvim`) isn't in any repo. Copy it into
      `users/davidutz/nvim/`, then link it with `xdg.configFile."nvim".source`.
- [ ] Faster editing loop (optional): point `~/.config/hypr` files at the working copy
      with `config.lib.file.mkOutOfStoreSymlink "/home/davidutz/personal/dotnix/..."` so edits
      apply without a rebuild. The cost is that the config is no longer pinned.

## 6. Apps not ported yet

`modules/users/davidutz/apps/` has one file per app ported so far. Remaining:

- [ ] Browsers: chromium, zen (see above).
- [ ] Chat: equibop (`pkgs.equibop`) or Vencord/Equicord through https://github.com/KaylorBen/nixcord, legcord.
- [ ] Spotify with Spicetify: https://github.com/Gerg-L/spicetify-nix
- [ ] Remote: rustdesk, winbox, localsend firewall (`programs.localsend = { enable = true; openFirewall = true; };`
      at NixOS level instead of the home package).
- [ ] Sync: megasync.
- [ ] Recording: gpu-screen-recorder (`programs.gpu-screen-recorder.enable = true;`).
- [ ] USB: ventoy.
- [ ] Qt apps from KDE you kept: ark, dolphin (config: see section 0).
- [ ] MIME defaults from `~/.config/mimeapps.list`: `xdg.mimeApps.defaultApplications`.
- [ ] XDG user dirs: `xdg.userDirs = { enable = true; createDirectories = true; };`

## 7. Gaming (`apps/gaming/*`)

https://wiki.nixos.org/wiki/Steam

- [x] Steam, gamemode, gamescope, Proton-GE (`system/gaming.nix`); Lutris, Prism
      Launcher, Wine (`users/davidutz/apps/games/`).
- [ ] steamcmd.
- [ ] Roblox: Sober through Flatpak (section 4), Vinegar (`pkgs.vinegar`) for Studio.
- [ ] truckersmp-cli: not in nixpkgs. Package it or run it through `uv`.
- [ ] Unreal Engine lives on `/opt/unreal-engine` and expects an FHS system. Run it
      with nix-ld or a `buildFHSEnv` wrapper. Rider is `jetbrains.rider`.

## 8. Development tools

- [ ] Prefer per-project dev shells (`flake.nix` + `.envrc` with `use flake`) over
      global toolchains. direnv + nix-direnv are already enabled.
- [ ] Tools used across projects (CachyOS installs them globally): go, dotnet-sdk,
      php + composer, python + uv, nodejs + pnpm + bun, rustup, cmake, opentofu,
      kubectl, ansible, forgejo-cli.
- [x] Claude Code and agy (`users/davidutz/agents/`), T3 Code on desktops.
- [ ] Other AI CLIs if you still use them: `gemini-cli`, `opencode`.
- [ ] Editors: VSCodium extensions through `programs.vscode = { enable = true; package = pkgs.vscodium; profiles.default.extensions = [ ... ]; };`,
      Zed (`zed-editor`), IntelliJ (`jetbrains.idea-oss`).

## 9. Theming (`desktop/theming`, `desktop/qt`, `desktop/fonts`)

- [ ] Catppuccin Mocha for GTK, Qt, cursors and terminal apps in one place:
      https://github.com/catppuccin/nix. It replaces the `gsettings` calls in
      `config/autostart.lua`.
- [ ] Qt: `qt = { enable = true; platformTheme.name = "qtct"; };` plus the Darkly style.
- [ ] Cursor: `home.pointerCursor = { gtk.enable = true; hyprcursor.enable = true; package = ...; name = ...; size = 24; };`
- [ ] Papirus folders in the Catppuccin colour (AUR `papirus-folders-catppuccin-git`).

## 10. Repo hygiene

- [ ] Secrets with sops-nix. You already have `~/.config/sops`.
      https://github.com/Mic92/sops-nix. First users: the password hash, Wi-Fi
      PSKs, Tailscale auth key.
      With the wiped root, point sops at a key that survives: the host key is
      preserved as `/etc/ssh/ssh_host_ed25519_key` (target in /persist), so
      `sops.age.sshKeyPaths = [ "/persist/etc/ssh/ssh_host_ed25519_key" ];`.
- [ ] Run `nix fmt` once and commit it on its own, so later diffs only show real changes.
- [ ] Lint with `statix check` and `deadnix`.
- [ ] CI: GitHub Actions running `nix flake check` (for example with
      `cachix/install-nix-action`).
- [ ] `modules/parts.nix` imports `flake-parts.flakeModules.modules`, but nothing uses
      `flake.modules.*` (`nix flake check` warns "unknown flake output 'modules'").
      Either drop the import, or rename `flake.nixosModules.X` / `flake.homeModules.X`
      to `flake.modules.nixos.X` / `flake.modules.homeManager.X`, the naming most
      dendritic configs use. Both merge the same way.
- [ ] Drop the darwin entries from `systems` unless a Mac is coming.
- [ ] README with the layout section above and the rebuild commands.

## 11. Later

- [ ] If the pi runs NixOS, give it a host under `modules/hosts/pi/` with
      https://github.com/NixOS/nixos-hardware and remove the standalone home config.
- [ ] Install remotely with https://github.com/nix-community/nixos-anywhere.
- [ ] Binary cache for anything you package yourself (wepapered): Cachix or
      a self-hosted attic.
