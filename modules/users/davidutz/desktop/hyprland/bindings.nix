# Window, workspace and monitor keys. Everything else binds its own keys in its own
# file: apps in apps/, the shell in desktop/mochi.nix, volume in desktop/audio.nix.
{
  flake.homeModules.davidutzDesktop = {
    wayland.windowManager.hyprland.extraConfig = ''
      hl.bind("SUPER + R", hl.dsp.exec_cmd("hyprctl reload"))

      -- SUPER + W and SUPER + Q both close. Fullscreen is on F and CTRL + F.
      hl.bind("SUPER + W", hl.dsp.window.close())
      hl.bind("SUPER + Q", hl.dsp.window.close())
      hl.bind("SUPER + F", hl.dsp.window.fullscreen({ "fullscreen", "toggle" }))
      hl.bind("SUPER + CTRL + F", hl.dsp.window.fullscreen())
      hl.bind("SUPER + T", hl.dsp.window.float({ action = "toggle" }))
      hl.bind("SUPER + G", hl.dsp.group.toggle())
      hl.bind("SUPER + P", hl.dsp.window.pseudo())

      -- SUPER + <arrow> focuses, SHIFT moves the window.
      -- SUPER + CTRL + <arrow or HJKL> focuses a monitor, SHIFT moves the window there.
      local vim = { left = "H", down = "J", up = "K", right = "L" }
      for dir, key in pairs(vim) do
        hl.bind("SUPER + " .. dir, hl.dsp.focus({ direction = dir }))
        hl.bind("SUPER + SHIFT + " .. dir, hl.dsp.window.move({ direction = dir }))
        hl.bind("SUPER + CTRL + " .. key, hl.dsp.focus({ monitor = dir }))
        hl.bind("SUPER + SHIFT + CTRL + " .. dir, hl.dsp.window.move({ monitor = dir }))
        hl.bind("SUPER + SHIFT + CTRL + " .. key, hl.dsp.window.move({ monitor = dir }))
      end
      hl.bind("SUPER + CTRL + left", hl.dsp.focus({ monitor = "left" }))
      hl.bind("SUPER + CTRL + right", hl.dsp.focus({ monitor = "right" }))

      -- Next and previous workspace: Page_Down/Page_Up, U/I and the mouse wheel.
      -- SHIFT moves the window along, and so do CTRL + down/up.
      for nextKey, prevKey in pairs({ Page_Down = "Page_Up", U = "I" }) do
        hl.bind("SUPER + " .. nextKey, hl.dsp.focus({ workspace = "e+1" }))
        hl.bind("SUPER + " .. prevKey, hl.dsp.focus({ workspace = "e-1" }))
        hl.bind("SUPER + SHIFT + " .. nextKey, hl.dsp.window.move({ workspace = "e+1" }))
        hl.bind("SUPER + SHIFT + " .. prevKey, hl.dsp.window.move({ workspace = "e-1" }))
      end
      hl.bind("SUPER + CTRL + down", hl.dsp.window.move({ workspace = "e+1" }))
      hl.bind("SUPER + CTRL + up", hl.dsp.window.move({ workspace = "e-1" }))
      hl.bind("SUPER + CTRL + U", hl.dsp.window.move({ workspace = "e+1" }))
      hl.bind("SUPER + CTRL + I", hl.dsp.window.move({ workspace = "e-1" }))

      hl.bind("SUPER + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
      hl.bind("SUPER + mouse_up", hl.dsp.focus({ workspace = "e-1" }))
      hl.bind("SUPER + SHIFT + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
      hl.bind("SUPER + SHIFT + mouse_up", hl.dsp.focus({ workspace = "e-1" }))
      hl.bind("SUPER + CTRL + mouse_down", hl.dsp.window.move({ workspace = "e+1" }))
      hl.bind("SUPER + CTRL + mouse_up", hl.dsp.window.move({ workspace = "e-1" }))

      -- SUPER + <n> goes to workspace n, SHIFT moves the window, ALT moves it quietly.
      -- 0 is workspace 10, where Discord and Spotify open.
      for n = 1, 10 do
        local key = tostring(n % 10)
        hl.bind("SUPER + " .. key, hl.dsp.focus({ workspace = n }))
        hl.bind("SUPER + SHIFT + " .. key, hl.dsp.window.move({ workspace = n }))
        hl.bind("SUPER + ALT + " .. key, hl.dsp.window.move({ workspace = n, silent = true }))
      end

      -- Scratchpads: SUPER + S and F1 toggle "magic", F2 toggles "magic1".
      hl.bind("SUPER + S", hl.dsp.workspace.toggle_special("magic"))
      hl.bind("SUPER + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }))
      for key, name in pairs({ F1 = "magic", F2 = "magic1" }) do
        hl.bind("SUPER + " .. key, hl.dsp.workspace.toggle_special(name))
        hl.bind("SUPER + SHIFT + " .. key, hl.dsp.window.move({ workspace = "special:" .. name }))
        hl.bind("SUPER + ALT + " .. key, hl.dsp.window.move({ workspace = "special:" .. name, silent = true }))
      end

      hl.bind("SUPER + bracketleft", hl.dsp.layout("preselect l"))
      hl.bind("SUPER + bracketright", hl.dsp.layout("preselect r"))
      hl.bind("SUPER + J", hl.dsp.layout("togglesplit"))

      -- Drag and resize with the mouse, or hold Z / X and move it.
      hl.bind("SUPER + mouse:272", hl.dsp.window.drag(), { mouse = true })
      hl.bind("SUPER + mouse:273", hl.dsp.window.resize(), { mouse = true })
      hl.bind("SUPER + Z", hl.dsp.window.drag(), { mouse = true })
      hl.bind("SUPER + X", hl.dsp.window.resize(), { mouse = true })

      hl.bind("SUPER + code:20", hl.dsp.window.resize({ x = -100, y = 0 }), { description = "Expand window left" })
      hl.bind("SUPER + code:21", hl.dsp.window.resize({ x = 100, y = 0 }), { description = "Shrink window left" })
      hl.bind("SUPER + minus", hl.dsp.window.resize({ x = -50, y = 0 }), { repeating = true })
      hl.bind("SUPER + equal", hl.dsp.window.resize({ x = 50, y = 0 }), { repeating = true })
      hl.bind("SUPER + SHIFT + minus", hl.dsp.window.resize({ x = 0, y = -50 }), { repeating = true })
      hl.bind("SUPER + SHIFT + equal", hl.dsp.window.resize({ x = 0, y = 50 }), { repeating = true })
    '';
  };
}
