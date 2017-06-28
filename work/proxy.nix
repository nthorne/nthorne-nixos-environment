{ config, lib, pkgs, ... }:

{
  imports = [ ];

  environment.systemPackages = with pkgs; [
    cntlm
  ];

  services.cntlm.enable = true;
  services.cntlm.port = [3128];
  networking.proxy.default = "http://127.0.0.1:3128";

  environment.etc.gitconfig.text = ''
  [url "https://github.com/"]
    insteadOf = git://github.com/
	[url "https://github.com/openembedded/"]
    insteadOf = git://git.openembedded.org/
	[url "https://git.yoctoproject.org/git/"]
    insteadOf = git://git.yoctoproject.org/
	[url "https://git.kernel.org/"]
    insteadOf = git://git.kernel.org/
	[url "http://sourceware.org/git/"]
    insteadOf = git://sourceware.org/git/
	[url "http://code.qt.io/"]
    insteadOf = git://code.qt.io/
	[url "http://git.projects.genivi.org/"]
    insteadOf = git://git.projects.genivi.org/
	[url "http://anongit.freedesktop.org/git/"]
    insteadOf = git://anongit.freedesktop.org/
  '';
}
