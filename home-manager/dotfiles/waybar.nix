{ flake-inputs, ... }:
{
  programs.waybar = {
    enable = true;
    settings = {
      mainBar = {
        layer = "bottom";
        position = "top";
        #output = [
        #  "DP-3" "DP-4" "DP-5"
        #  "DP-6" "DP-7" "DP-8"
        #  "DP-1"
        #  "eDP-1"
        #];

        modules-left = ["hyprland/workspaces" "hyprland/mode"];
        modules-center = ["hyprland/window"];
        modules-right = ["cpu" "memory" "temperature" "pulseaudio" "network" "battery" "tray" "clock"];

        "hyprland/workspaces" = {
          format = "{icon}{}{icon}";
          format-icons = {
            default = "";
            active = "|";
          };
        };

        cpu = {
          interval = 15;
          format = "💻 {}%";
          max-length = 10;
        };

        memory = {
          interval = 30;
          format = "🧠 {}%";
          max-length = 10;
        };

        temperature = {
          "critical-threshold" = 80;
          format = "🌡️ {}°C";
        };

        pulseaudio = {
          format = "{icon} {volume}%";
          format-bluetooth = "{volume}% {icon}";
          format-muted = "🔇";
          format-icons = {
            headphone = "🎧";
            hands-free = "🎧";
            headset = "🎧";
            phone = "📞";
            portable = "📱";
            car = "🚗";
            default = ["🔊" "🔉"];
          };
          scroll-step = 1;
          on-click = "pavucontrol";
        };

        network = {
          format = "{ifname}";
          format-wifi = "{essid} ({signalStrength}%)";
          format-ethernet = "{essid} {ifname} {ipaddr}/{cidr} ";
          format-disconnected = "Disconnected"; 
          max-length = 50;
        };

        battery = {
          format = "{icon} {capacity}%";
          "format-icons" =  ["🪫" "🔋"];
        };

        clock = {
          "format-alt" = "{:%a, %d. %b  %H:%M}";
        };
      };
    };
  };
}
