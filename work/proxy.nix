{ config, lib, pkgs, ... }:

{
  imports = [ ];

  environment.systemPackages = with pkgs; [
    cntlm
  ];

  services.cntlm.domain = <DOMAIN>;
  services.cntlm.enable = true;
  services.cntlm.proxy = [<PROXY URL>];
  services.cntlm.port = [3128];
  services.cntlm.username = <LDAP USER>
  services.cntlm.password = "";
  # To generate new hash: cntlm -u <LDAP USER> -d <DOMAIN> -H <PROXY URL> <PROXY PORT>
  services.cntlm.extraConfig = "
Auth NTLMv2
NoProxy localhost, 127.0.0.*, 10.*, 192.168.*, <LOCAL DOMAIN>
PassNTLMv2      <HASH>
  ";
  networking.proxy.noProxy = "localhost, 127.0.0.*, 192.168.*, <LOCAL DOMAIN>"
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
