{ config, lib, pkgs, ... }:

{
  imports = [ 
    # ./hyprland-environment.nix
  ];

  home.packages = with pkgs; [ 
    eww
    swww
  ];
  
  #test later systemd.user.targets.hyprland-session.Unit.Wants = [ "xdg-desktop-autostart.target" ];
  wayland.windowManager.hyprland = {
    enable = true;
    
    settings.env = [
      "EDITOR,kitty nvim"
      "BROWSER,firefox"
      "TERMINAL,kitty"
      # "GBM_BACKEND,nvidia-drm"
      # "__GLX_VENDOR_LIBRARY_NAME,nvidia"
      # "LIBVA_DRIVER_NAME,nvidia"
      "__GL_VRR_ALLOWED,1"
      "WLR_NO_HARDWARE_CURSORS,1"
      "WLR_RENDERER_ALLOW_SOFTWARE,1"
      "CLUTTER_BACKEND,wayland"
      "WLR_RENDERER,vulkan"
      "XDG_CURRENT_DESKTOP,Hyprland"
      "XDG_SESSION_DESKTOP,Hyprland"
      "XDG_SESSION_TYPE,wayland"
      "USE_WAYLAND_GRIM,1"
      "QT_QPA_PLATFORMTHEME,qt5ct"
      "QT_QPA_PLATFORM,wayland"
      "QT_WAYLAND_DISABLE_WINDOWDECORATION,1"
      "MOZ_ENABLE_WAYLAND,1"
    ];
    xwayland.enable = true;
    systemd.enable = true;
    extraConfig = ''
    # Monitors
    monitor=,preferred,auto,1

    # Fix slow startup
    #exec systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP
    #exec dbus-update-activation-environment --systemd DISPLAY WAYLAND_DISPLAY XDG_CURRENT_DESKTOP

    $terminal = kitty
    $fileManager = kitty ranger 
    $menu = rofi -show drun -show-icons

    # Autostart necessary processes (like notifications daemons, status bars, etc.) 
    exec-once = eww daemon
    exec-once = eww open bar
    # Or execute your favorite apps at launch like this:
    exec-once = pipewire
    exec-once = pipewire-pulse
    exec-once = wireplumber
    exec-once = vesktop 
    exec-once = telegram-desktop 
    exec-once = spotify

    exec-once = blueman-applet
    exec-once = blueman-tray

    # Set wallpaper
    exec-once = swww-daemon
    exec-once = swww img ~/wallpapers/3.jpg

    # Start wayland applets and components
    exec-once = nm-applet
    exec-once = dunst

    exec-once = rog-control-center

    # env = XCURSOR_SIZE,24
    # env = HYPRCURSOR_SIZE,24

    # https://wiki.hyprland.org/Configuring/Variables/#general
general { 
    gaps_in = 6
    gaps_out = 12

    border_size = 1

    # https://wiki.hyprland.org/Configuring/Variables/#variable-types for info about colors
    col.active_border = rgba(ff8fd0bb)
    col.inactive_border = rgba(595959aa)

    # Set to true enable resizing windows by clicking and dragging on borders and gaps
    resize_on_border = false 

    # Please see https://wiki.hyprland.org/Configuring/Tearing/ before you turn this on
    allow_tearing = false 

    layout = dwindle
}

# https://wiki.hyprland.org/Configuring/Variables/#decoration
decoration {
    rounding = 4

    # Change transparency of focused and unfocused windows
    active_opacity = 1.0
    inactive_opacity = 0.8

    drop_shadow = true
    shadow_range = 4
    shadow_render_power = 3
    col.shadow = rgba(1a1a1aee)

    # https://wiki.hyprland.org/Configuring/Variables/#blur
    blur {
        enabled = true
	new_optimizations = true;
	noise = 0.05;
	brightness = 1.0;
	popups = true;
        size = 6
        passes = 2
        
        vibrancy = 0.05
    }
}

# https://wiki.hyprland.org/Configuring/Variables/#animations
animations {
    enabled = true

    # Default animations, see https://wiki.hyprland.org/Configuring/Animations/ for more

    bezier = myBezier, 0.05, 0.9, 0.1, 1.05

    animation = windows, 1, 7, myBezier
    animation = windowsOut, 1, 7, default, popin 80%
    animation = border, 1, 10, default
    animation = borderangle, 1, 8, default
    animation = fade, 1, 7, default
    animation = workspaces, 1, 6, default
}

# See https://wiki.hyprland.org/Configuring/Dwindle-Layout/ for more
dwindle {
    pseudotile = true # Master switch for pseudotiling. Enabling is bound to mainMod + P in the keybinds section below
    preserve_split = true # You probably want this
}

# See https://wiki.hyprland.org/Configuring/Master-Layout/ for more
master {
    new_status = master
}

# https://wiki.hyprland.org/Configuring/Variables/#misc
misc { 
    force_default_wallpaper = 0 # Set to 0 or 1 to disable the anime mascot wallpapers
    disable_hyprland_logo = true # If true disables the random hyprland logo / anime girl background. :(
}


#############
### INPUT ###
#############

# https://wiki.hyprland.org/Configuring/Variables/#input
input {
    kb_layout = us
    kb_variant =
    kb_model =
    kb_options =
    kb_rules =

    follow_mouse = 1

    sensitivity = 0 # -1.0 - 1.0, 0 means no modification.

    touchpad {
        natural_scroll = false
    }
}

# https://wiki.hyprland.org/Configuring/Variables/#gestures
gestures {
    workspace_swipe = false
}

# Fix mouse cursor on new hyprland version
cursor {
  no_warps = true
    no_hardware_cursors = true
    allow_dumb_copy = true
  }

# Example per-device config
# See https://wiki.hyprland.org/Configuring/Keywords/#per-device-input-configs for more
device {
    name = hp,-inc-hyperx-pulsefire-haste-wireless
    sensitivity = -0.5
}


####################
### KEYBINDINGSS ###
####################

# See https://wiki.hyprland.org/Configuring/Keywords/
$mainMod = SUPER # Sets "Windows" key as main modifier

bind = $mainMod, F, fullscreen,

# Example binds, see https://wiki.hyprland.org/Configuring/Binds/ for more
bind = $mainMod, RETURN, exec, $terminal
bind = $mainMod SHIFT, C, killactive,
# bind = $mainMod, M, exit,
bind = $mainMod, E, exec, $fileManager
bind = $mainMod, V, togglefloating,
bind = $mainMod, R, exec, pkill rofi || rofi -show drun -show-icons
bind = $mainMod, P, pseudo, # dwindle
bind = $mainMod, J, togglesplit, # dwindle

# Move focus with mainMod + arrow keys
bind = $mainMod, H, movefocus, l
bind = $mainMod, L, movefocus, r
bind = $mainMod, K, movefocus, u
bind = $mainMod, J, movefocus, d

# Switch workspaces with mainMod + [0-9]
bind = $mainMod, 1, workspace, 1
bind = $mainMod, 2, workspace, 2
bind = $mainMod, 3, workspace, 3
bind = $mainMod, 4, workspace, 4
bind = $mainMod, 5, workspace, 5
bind = $mainMod, 6, workspace, 6

# Move active window to a workspace with mainMod + SHIFT + [0-9]
bind = $mainMod SHIFT, 1, movetoworkspace, 1
bind = $mainMod SHIFT, 2, movetoworkspace, 2
bind = $mainMod SHIFT, 3, movetoworkspace, 3
bind = $mainMod SHIFT, 4, movetoworkspace, 4
bind = $mainMod SHIFT, 5, movetoworkspace, 5
bind = $mainMod SHIFT, 6, movetoworkspace, 6

# Screenshots with flameshot
bind = , Print, exec, flameshot gui

# run menu
#rbind = $mainMod, R, exec, rofi -show drun -show-icons 

# Scroll through existing workspaces with mainMod + scroll
bind = $mainMod, mouse_down, workspace, e+1
bind = $mainMod, mouse_up, workspace, e-1

# Move/resize windows with mainMod + LMB/RMB and dragging
bindm = $mainMod, mouse:272, movewindow
bindm = $mainMod, mouse:273, resizewindow

# OS control keys
bindel=, XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 1%+
bindel=, XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 1%-
bindl=, XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
# Requires playerctl
bindl=, XF86AudioPlay, exec, playerctl play-pause
bindl=, XF86AudioPrev, exec, playerctl previous
bindl=, XF86AudioNext, exec, playerctl next
bind=, XF86Sleep, exec, systemctl suspend

# Display
binde = , XF86MonBrightnessDown, exec, brightnessctl set 10-
binde = , XF86MonBrightnessUp, exec, brightnessctl set 10+
# ROG control center
bind = , XF86Launch3, exec, asusctl led-mode -n
bind = , code:156, exec, rog-control-center
bind = , code:237, exec, asusctl -p
bind = , code:238, exec, asusctl -n 
bind = , code:211, exec, asusctl profile -n 

##############################
### WINDOWS AND WORKSPACES ###
##############################

# See https://wiki.hyprland.org/Configuring/Window-Rules/ for more
# See https://wiki.hyprland.org/Configuring/Workspace-Rules/ for workspace rules

# Example windowrule v1
# windowrule = float, ^(kitty)$

# Example windowrule v2
layerrule = ignorealpha 0, bar
layerrule = blur, bar
layerrule = blurpopups, bar
layerrule = xray, bar

windowrulev2 = suppressevent maximize, class:.* # You'll probably like this. 
    '';
  };
}

