{ config, pkgs, ... }:
{
  networking.wireless = {
    userControlled.enable = true;
    networks = {
      # Example:
      #
      # SSID = {
      #   pskRaw = "<RAW PSK>";
      # };
      #
      # where <RAW PSK> is given by wpa_passphrase <SSID> <PSK>
      SKYNET = {
         pskRaw = "<SECRET>";
      };
      SaferSociety = {
         pskRaw = "<SECRET>";
      };
    };
  };
}
