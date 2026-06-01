{pkgs, lib,...}: {
  wayland.windowManager.hyprland = {
    enable = true;
    configType = "lua";
    settings = {};  # Why on earth would I want to write nixified Lua 🤮
    extraConfig = ''
      ----------------
      --- MONITORS ---
      ----------------

      hl.monitor(
      {
          output = "eDP-1",
          mode = "3840x2400@59.99",
          position = "5120x0",
          scale = "auto"
      },
      {
          output = "DP-6",
          mode = "2560x1440@59.95",
          position = "2560x0",
          scale = "auto"
      },
      {
          output = "DP-8",
          mode = "2560x1440@59.95",
          position = "0x0",
          scale = "auto"
      }
      )

      -----------------
      --- AUTOSTART ---
      -----------------

      hl.on("hyprland.start", function() 
        hl.exec_cmd("waybar & swaync & ${lib.getExe pkgs.networkmanagerapplet}")
      end)


      -----------------------------
      --- ENVIRONMENT VARIABLES ---
      -----------------------------

      hl.env("XCURSOR_SIZE","24")
      hl.env("HYPRCURSOR_SIZE","24")


      ---------------------
      --- LOOK AND FEEL ---
      ---------------------

      hl.config({
        general = {
            gaps_in = 1,
            gaps_out = 2,
  
            border_size = 2,
  
            col = {
                active_border = { colors = { "rgba(33ccffee)", "rgba(00ff99ee)"}, angle = 45 },
                inactive_border = "rgba(595959aa)"
            },
  
            resize_on_border = false,
  
            allow_tearing = false,
  
            layout = dwindle,
          },
          decoration = {
              rounding = 0,
  
              active_opacity = 1.0,
              inactive_opacity = 1.0,
  
              shadow = {
                  enabled = true,
                  range = 4,
                  render_power = 3,
                  color = 0xee1a1a1a,
              },
  
              blur = {
                  enabled = true,
                  size = 3,
                  passes = 1,
                  vibrancy = 0.1696,
              },
          },
          animations = {
              enabled = true,
          },
      })

      -- Default curves and animations, see https://wiki.hypr.land/Configuring/Advanced-and-Cool/Animations/
      hl.curve("easeOutQuint",   { type = "bezier", points = { {0.23, 1},    {0.32, 1}    } })
      hl.curve("easeInOutCubic", { type = "bezier", points = { {0.65, 0.05}, {0.36, 1}    } })
      hl.curve("linear",         { type = "bezier", points = { {0, 0},       {1, 1}       } })
      hl.curve("almostLinear",   { type = "bezier", points = { {0.5, 0.5},   {0.75, 1}    } })
      hl.curve("quick",          { type = "bezier", points = { {0.15, 0},    {0.1, 1}     } })

      -- Default springs
      hl.curve("easy",           { type = "spring", mass = 1, stiffness = 71.2633, dampening = 15.8273644 })

      hl.animation({ leaf = "global",        enabled = true,  speed = 10,   bezier = "default" })
      hl.animation({ leaf = "border",        enabled = true,  speed = 5.39, bezier = "easeOutQuint" })
      hl.animation({ leaf = "windows",       enabled = true,  speed = 4.79, spring = "easy" })
      hl.animation({ leaf = "windowsIn",     enabled = true,  speed = 4.1,  spring = "easy",         style = "popin 87%" })
      hl.animation({ leaf = "windowsOut",    enabled = true,  speed = 1.49, bezier = "linear",       style = "popin 87%" })
      hl.animation({ leaf = "fadeIn",        enabled = true,  speed = 1.73, bezier = "almostLinear" })
      hl.animation({ leaf = "fadeOut",       enabled = true,  speed = 1.46, bezier = "almostLinear" })
      hl.animation({ leaf = "fade",          enabled = true,  speed = 3.03, bezier = "quick" })
      hl.animation({ leaf = "layers",        enabled = true,  speed = 3.81, bezier = "easeOutQuint" })
      hl.animation({ leaf = "layersIn",      enabled = true,  speed = 4,    bezier = "easeOutQuint", style = "fade" })
      hl.animation({ leaf = "layersOut",     enabled = true,  speed = 1.5,  bezier = "linear",       style = "fade" })
      hl.animation({ leaf = "fadeLayersIn",  enabled = true,  speed = 1.79, bezier = "almostLinear" })
      hl.animation({ leaf = "fadeLayersOut", enabled = true,  speed = 1.39, bezier = "almostLinear" })
      hl.animation({ leaf = "workspaces",    enabled = true,  speed = 1.94, bezier = "almostLinear", style = "fade" })
      hl.animation({ leaf = "workspacesIn",  enabled = true,  speed = 1.21, bezier = "almostLinear", style = "fade" })
      hl.animation({ leaf = "workspacesOut", enabled = true,  speed = 1.94, bezier = "almostLinear", style = "fade" })
      hl.animation({ leaf = "zoomFactor",    enabled = true,  speed = 7,    bezier = "quick" })

      hl.config({
          dwindle = {
              preserve_split = true, -- You probably want this
          },
      })

      hl.config({
          master = {
              new_status = "master",
          },
      })

      hl.config({
          misc = {
              force_default_wallpaper = 0,
              disable_hyprland_logo   = true,
          },
      })


      -------------
      --- INPUT ---
      -------------

      hl.config({
      input  = {
          kb_layout = "se",
          kb_variant = "",
          kb_model = "",
          kb_options = "",
          kb_rules = "",

          follow_mouse = 1,

          sensitivity = 0,

          touchpad = {
              natural_scroll = false,
          },
        },
      })

      hl.device({
          name = "epic-mouse-v1",
          sensitivity = -0.5
      })

      hl.config({
        ecosystem = {
            no_update_news = true,
            no_donation_nag = true,
        },
      })


      -------------------
      --- KEYBINDINGS ---
      -------------------

      local mainMod = "ALT"

      hl.bind(mainMod .. "+ SHIFT + C", hl.dsp.window.close())

      hl.bind(mainMod .. " + SHIFT + RETURN", hl.dsp.exec_cmd("ghostty -e zsh -c tmux"))
      hl.bind(mainMod .. " + X", hl.dsp.exec_cmd("rofi -show drun -show-icons"))
      hl.bind(mainMod .. " + P", hl.dsp.window.pseudo())
      hl.bind(mainMod .. "+ SHIFT + n", hl.dsp.exec_cmd("swaync-client -t"))

      -- Window management
      hl.bind(mainMod .. " + f", hl.dsp.window.float({action = "toggle"}))
      hl.bind(mainMod .. " + SHIFT + space", hl.dsp.layout("togglesplit"))
      hl.bind(mainMod .. " + space", hl.dsp.window.fullscreen(1))

      -- Lock the screen
      hl.bind(mainMod .. " + Scroll_Lock", hl.dsp.exec_cmd("hyprlock"))

      hl.bind(mainMod .. " + SHIFT + F", hl.dsp.exec_cmd("firefox"))
      hl.bind(mainMod .. " + SHIFT + P", hl.dsp.exec_cmd("${lib.getExe pkgs.openpomodoro-cli} start"))
      hl.bind(mainMod .. " + SHIFT + B", hl.dsp.exec_cmd("${lib.getExe pkgs.openpomodoro-cli} break"))

      -- Manage window focus
      hl.bind(mainMod .. " + h", hl.dsp.focus({ direction = "left" }))
      hl.bind(mainMod .. " + j", hl.dsp.focus({ direction = "down" }))
      hl.bind(mainMod .. " + k", hl.dsp.focus({ direction = "up" }))
      hl.bind(mainMod .. " + l", hl.dsp.focus({ direction = "right" }))
      hl.bind(mainMod .. " + tab", hl.dsp.window.cycle_next())
      hl.bind(mainMod .. " + SHIFT + tab", hl.dsp.window.cycle_next({ next = false} ))

      hl.bind(mainMod .. " + SHIFT + H", hl.dsp.window.move({ direction = "left" }))
      hl.bind(mainMod .. " + SHIFT + J", hl.dsp.window.move({ direction = "down" }))
      hl.bind(mainMod .. " + SHIFT + K", hl.dsp.window.move({ direction = "up" }))
      hl.bind(mainMod .. " + SHIFT + L", hl.dsp.window.move({ direction = "right" }))

      -- Switch workspaces with mainMod + [0-9]
      -- Move active window to a workspace with mainMod + SHIFT + [0-9]
      for i = 1, 10 do
          local key = i % 10 -- 10 maps to key 0
          hl.bind(mainMod .. " + " .. key,             hl.dsp.focus({ workspace = i}))
          hl.bind(mainMod .. " + SHIFT + " .. key,     hl.dsp.window.move({ workspace = i }))
      end

      -- Monitor handling
      hl.bind(mainMod .. " + w", hl.dsp.focus({ monitor = 2 }))
      hl.bind(mainMod .. " + e", hl.dsp.focus({ monitor = 1 }))
      hl.bind(mainMod .. " + r", hl.dsp.focus({ monitor = 0 }))
      hl.bind(mainMod .. " + SHIFT + w", hl.dsp.window.move({ monitor = 2 }))
      hl.bind(mainMod .. " + SHIFT + e", hl.dsp.window.move({ monitor = 1 }))
      hl.bind(mainMod .. " + SHIFT + r", hl.dsp.window.move({ monitor = 0 }))

      -- Move/resize windows with mainMod + LMB/RMB and dragging
      hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
      hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

      -- Laptop multimedia keys for volume and LCD brightness
      hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true })
      hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),      { locked = true, repeating = true })
      hl.bind("XF86AudioMute",        hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),     { locked = true, repeating = true })
      hl.bind("XF86AudioMicMute",     hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),   { locked = true, repeating = true })

      ------------------------------
      --- WINDOWS AND WORKSPACES ---
      ------------------------------

      local suppressMaximizeRule = hl.window_rule({
          -- Ignore maximize requests from all apps. You'll probably like this.
          name  = "suppress-maximize-events",
          match = { class = ".*" },

          suppress_event = "maximize",
      })

      hl.window_rule({
          -- Fix some dragging issues with XWayland
          name  = "fix-xwayland-drags",
          match = {
              class      = "^$",
              title      = "^$",
              xwayland   = true,
              float      = true,
              fullscreen = false,
              pin        = false,
          },

          no_focus = true,
      })
    '';
  };
}
