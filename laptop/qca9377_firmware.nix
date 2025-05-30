{
  lib,
  stdenv,
  fetchurl,
}:

# <https://gist.github.com/osmano807/8b8e9b37043007c68c4cbfb69ee3e562>
# Fix for broken ath10k driver.
stdenv.mkDerivation rec {
  name = "qca9377_firmware-${version}";
  version = "5";
  src = ./firmware-5.bin;
  sourceRoot = ".";
  dontBuild = true;
  unpackPhase = ''
    cp "$src" .
  '';

  installPhase = ''
    mkdir -p "$out/lib/firmware/ath10k/QCA9377/hw1.0"
    cp "$src" "$out/lib/firmware/ath10k/QCA9377/hw1.0/firmware-5.bin"
    cp "$src" "$out/lib/firmware/ath10k/QCA9377/hw1.0/firmware-6.bin"
  '';

  # Firmware blobs do not need fixing and should not be modified
  dontFixup = true;

  meta = {
    description = "Binary firmware for QCA9377 chipset";
    homepage = "https://github.com/kvalo/ath10k-firmware";
    license = lib.licenses.unfreeRedistributableFirmware;
    platforms = lib.platforms.linux;
    # priority = 6; # give precedence to kernel firmware
  };

  passthru = {
    inherit version;
  };
}
