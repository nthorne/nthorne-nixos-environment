{
  pkgs,
  lib,
  ...
}:
{
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${lib.getExe pkgs.tuigreet} --time --asterisks --remember --remember-user-session --sessions ${lib.getExe pkgs.hyprland}";
      };
    };
  };
  programs.hyprland = {
    enable = true;
    withUWSM = true;
    xwayland.enable = true;
  };
}
