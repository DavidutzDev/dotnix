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
home-manager switch --flake .#davidutz@pi
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
                            homeModules.davidutz         terminal setup (pi included)
                            homeModules.davidutzDesktop  Hyprland config, GUI apps, T3 Code
                            homeModules.davidutzAgents   Claude Code, agy
  hosts/<host>/           hardware + host settings; imports system features and users
```

Several files can set the same module name (`homeModules.davidutz`), and the module
system merges them. So a user file doesn't import anything. The dendritic README
recommends this: "Consider merging multiple non-distinct lower-level modules under
one distinct name."

To add something:

- Something only you use (a program, dotfile, alias): a new file in
  `modules/users/davidutz/` that sets `flake.homeModules.davidutz` (terminal) or
  `flake.homeModules.davidutzDesktop` (GUI). If it also needs a system setting,
  set `flake.nixosModules.davidutz` in the same file, as `zsh.nix` does.
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
- [x] Hyprland: NixOS module with UWSM, hyprlock PAM, hypridle, portals, keyring,
      fonts. Home side generates `hyprland.lua` and links your Lua modules from the
      pinned `dotfiles` input. Odyssey's runtime files stay writable.
- [x] tmux and ghostty read their config from the `dotfiles` input.
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
      session shell until Odyssey is installed (`users/davidutz/desktop-shell.nix`).
- [x] Agents profile (Claude Code, agy) separate from the desktop; hosts opt in.
- [x] `hm` alias: `hm.<option>` in a NixOS module sets `home-manager.users.davidutz.<option>`.
- [x] The pi config gets the terminal profile only, not Hyprland.
- [x] `.gitignore`, `nix fmt` (nixfmt-tree).

## 1. Installing on desktop-btw

`hosts/test-vm` now describes this machine (desktop-btw). The directory and hostname
stay `test-vm` until the rename. When renaming, change the directory,
`networking.hostName`, the `flake.nixosConfigurations.<name>` key and the two
`testVm*` module names together, because `nh` picks the config by hostname.

- [ ] Push the 5 unpushed commits in `~/dotfiles`, then `nix flake update dotfiles`.
      The flake pins GitHub, which still has the older `config/bindings.lua`.
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
docker, libvirtd, gamemode and seat groups on hosts that enable those services.

- [ ] Single-GPU passthrough. The kernel side is in the host (IOMMU, ACS override,
      `kvm ignore_msrs`, seatd). The `~/win-vm` scripts need checking on NixOS:
  - [ ] Shebangs and hardcoded paths (`/usr/bin/quickemu`, `/usr/lib/...`) don't
        exist on NixOS. Use `#!/usr/bin/env bash` and commands from `PATH`.
  - [ ] `gpu-unbind.sh` restarts sddm and rebinds `nvidia`; check the unit and module
        names match (`display-manager.service` on NixOS).
  - [ ] `hypr-headless.sh` needs `wayvnc` (add it to your home packages).
  - [ ] The TPM passthrough in `windows-11.conf` uses `/dev/tpm0`; add yourself to
        `tss` (`security.tpm2.enable = true;` creates it).
- [ ] Firewall ports. CachyOS's ufw rules weren't readable without sudo. Run
      `sudo ufw status numbered` and add anything not covered by an `openFirewall`
      option to `networking.firewall.allowedTCPPorts`.
- [ ] ssh-agent with the timeout from `dotfiles/ssh/.config/systemd/user/ssh-agent.service.d/timeout.conf`:
      home-manager `services.ssh-agent.enable = true;`, then set the same timeout.
- [ ] Declarative Flatpaks (Sober, Bottles, SysDVR): https://github.com/gmodena/nix-flatpak
- [ ] User services from CachyOS: `verdaccio.service`. Write it as
      `systemd.user.services.verdaccio` in `users/davidutz/`.
- [ ] Printing: CachyOS has no CUPS, so it's off. `services.printing.enable = true;` if needed.

## 5. Hyprland session gaps

The Lua config comes over unchanged, so anything it runs by name must exist on NixOS.

- [ ] Odyssey (Quickshell shell) is not in nixpkgs. Its `install.sh` writes to
      `~/.local/share/odyssey`, `~/.local/bin/odyssey`, and creates `odyssey.service`,
      which `odyssey.lua` starts. Package it as a derivation (source: github:sud0-L/odyssey,
      runtime: `quickshell`, `matugen`, plus whatever its scripts call) and define
      `systemd.user.services.odyssey` in `modules/users/davidutz/hyprland.nix`. Until then,
      running `install.sh` once by hand works, because `pcall(require, "odyssey")` keeps
      Hyprland starting without it.
- [ ] Odyssey's SDDM theme (`odyssey/sddm/odyssey`): package it and set
      `services.displayManager.sddm.theme`.
- [ ] `config/apps.lua` launches commands that differ on NixOS:
  - [ ] `zen-browser`: not in nixpkgs. Add https://github.com/0xc000022070/zen-browser-flake as an input.
  - [ ] `spotify-launcher`: nixpkgs ships the client as `spotify`. Change the command,
        or add a `spotify-launcher` wrapper script on NixOS.
  - [ ] `wepaperedctl` (AUR `wepapered-git`) and `~/.local/bin/nekoland`: not packaged.
        Package them, or skip them on NixOS.
- [ ] Scripts from `dotfiles/bin/.local/bin` (`mic-toggle`, `mic-status`,
      `tmux-sessionizer`, `ccd`, `cco`, ...). Link the shell scripts with
      `home.file.".local/bin/<name>".source = "${inputs.dotfiles}/bin/.local/bin/<name>";`.
      Replace committed binaries (`rtk`, `herdr`, `jcode`) with packages.
- [ ] `tmux.conf` copies with `xclip`, which doesn't work under Wayland. Switch it to `wl-copy`.
- [ ] Neovim config (`~/.config/nvim`) is not in the dotfiles repo. Add it there, then
      link it with `xdg.configFile."nvim".source`.
- [ ] Faster editing loop (optional): point `~/.config/hypr` files at the working copy
      with `config.lib.file.mkOutOfStoreSymlink "/home/davidutz/dotfiles/..."` so edits
      apply without a rebuild. The cost is that the config is no longer pinned.

## 6. Apps not ported yet

`modules/users/davidutz/apps.nix` has the ones that are plain nixpkgs packages. Remaining:

- [ ] Browsers: chromium, zen (see above).
- [ ] Chat: equibop (`pkgs.equibop`) or Vencord/Equicord through https://github.com/KaylorBen/nixcord, legcord.
- [ ] Spotify with Spicetify: https://github.com/Gerg-L/spicetify-nix
- [ ] Remote: rustdesk, winbox, localsend firewall (`programs.localsend = { enable = true; openFirewall = true; };`
      at NixOS level instead of the home package).
- [ ] Sync: megasync.
- [ ] Recording: gpu-screen-recorder (`programs.gpu-screen-recorder.enable = true;`).
- [ ] USB: ventoy.
- [ ] Qt apps from KDE you kept: ark, dolphin (config is in `dotfiles/dolphin`).
- [ ] MIME defaults from `~/.config/mimeapps.list`: `xdg.mimeApps.defaultApplications`.
- [ ] XDG user dirs: `xdg.userDirs = { enable = true; createDirectories = true; };`

## 7. Gaming (`apps/gaming/*`)

https://wiki.nixos.org/wiki/Steam

- [x] Steam, gamemode, gamescope, Proton-GE (`system/gaming.nix`); Lutris, Prism
      Launcher, Wine (`users/davidutz/apps.nix`).
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
- [x] Claude Code and agy (`users/davidutz/agents.nix`), T3 Code on desktops.
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
- [ ] Binary cache for anything you package yourself (Odyssey, wepapered): Cachix or
      a self-hosted attic.
