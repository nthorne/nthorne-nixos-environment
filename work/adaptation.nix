{
  config,
  pkgs,
  lib,
  ...
}:
let
  ethernetDevice = "enp0s13f0u4u4";
in
{
  # Don't require ethernet to be connected when booting
  systemd.services = {
    "network-link-${ethernetDevice}".wantedBy = lib.mkForce [ ];
    "network-addresses-${ethernetDevice}".wantedBy = lib.mkForce [ ];
  };

  # Start the driver at boot
  systemd.services.fprintd = {
    wantedBy = [ "multi-user.target" ];
    serviceConfig.Type = "simple";
  };

  # Install the driver
  services.fprintd = {
    enable = true;
  };

  # Enable fscrypt for home directory encryption
  security.pam.enableFscrypt = true;
  # NOTE: I NEED to login with password to descrypt my home directory.
  security.pam.services.greetd.fprintAuth = false;

  # PAM fails to lock protector in memory, causing unlock to fail, so we
  # increase the memlock limit to infinity.
  systemd.settings.Manager = {
    DefaultLimitMEMLOCK = "infinity";
  };

  # This sets memlock limits for all users to "unlimited"
  security.pam.loginLimits = [
    {
      domain = "*";
      item = "memlock";
      type = "-";
      value = "unlimited";
    }
  ];

  # Have the home-manager service restart on failure, since it needs
  # to have my home directory decrypted in order to exit successfully.
  # Setting After etc does not work since we only append to that list.
  # Wait 10s between restarts, and allow 30 restarts within a 5 minute window.
  systemd.services."home-manager-nthorne".serviceConfig = {
    Restart = "on-failure";
    RestartSec = "10s";
    StartLimitIntervalSec = "300";
    StartLimitBurst = 30;
  };

  # SystemD service hardening - Phase 2
  systemd.services.ollama.serviceConfig = {
    PrivateTmp = lib.mkForce true;
    ProtectSystem = lib.mkForce "strict";
    ProtectHome = lib.mkForce true;
    ProtectKernelTunables = lib.mkForce true;
    ProtectKernelModules = lib.mkForce true;
    ProtectKernelLogs = lib.mkForce true;
    ProtectControlGroups = lib.mkForce true;
    NoNewPrivileges = lib.mkForce true;
    RemoveIPC = lib.mkForce true;

    # Generous resource limits for large models
    MemoryHigh = lib.mkForce "16G";
    MemoryMax = lib.mkForce "32G";
    CPUQuota = lib.mkForce "800%"; # 8 cores max

    # Filesystem access
    ReadWritePaths = lib.mkForce [
      "/var/lib/ollama"
      "/tmp"
    ];
    ReadOnlyPaths = lib.mkForce [ "/nix/store" ];
  };

  systemd.services.tailscaled.serviceConfig = {
    PrivateTmp = lib.mkForce true;
    ProtectSystem = lib.mkForce "strict";
    ProtectHome = lib.mkForce true;
    ProtectKernelTunables = lib.mkForce true;
    ProtectKernelLogs = lib.mkForce true;
    ProtectControlGroups = lib.mkForce true;
    NoNewPrivileges = lib.mkForce true;

    ReadWritePaths = lib.mkForce [
      "/var/lib/tailscale"
      "/etc/resolv.conf"
    ];
    ReadOnlyPaths = lib.mkForce [
      "/etc/hosts"
      "/etc/nsswitch.conf"
      "/etc/services"
    ];

    # Conservative resource limits
    MemoryHigh = lib.mkForce "512M";
    MemoryMax = lib.mkForce "1G";
  };

  systemd.services.docker.serviceConfig = {
    PrivateTmp = lib.mkForce true;
    ProtectKernelTunables = lib.mkForce true;
    # Docker needs these capabilities
    ProtectKernelModules = lib.mkForce false;
    ProtectControlGroups = lib.mkForce false;
    NoNewPrivileges = lib.mkForce false;

    # Reasonable resource limits
    MemoryHigh = lib.mkForce "4G";
    MemoryMax = lib.mkForce "8G";
  };

  systemd.services.clamav-daemon.serviceConfig = {
    # Resource limits for scanning - keeping existing protections for now
    MemoryHigh = lib.mkForce "2G";
    MemoryMax = lib.mkForce "4G";
  };

  # Security hardening - kernel sysctls (VM-safe)
  boot.kernel.sysctl = {
    "kernel.ftrace_enabled" = true;
    "kernel.perf_event_paranoid" = 1;
    "kernel.kptr_restrict" = true;

    # Additional VM-safe hardening
    "kernel.dmesg_restrict" = true;
    "kernel.yama.ptrace_scope" = 1;
    "net.core.bpf_jit_harden" = 2;
    "kernel.unprivileged_bpf_disabled" = true;
    "net.ipv4.conf.all.rp_filter" = 1;
    "net.ipv4.conf.default.rp_filter" = 1;
    "net.ipv4.icmp_echo_ignore_broadcasts" = true;
    "net.ipv4.icmp_ignore_bogus_error_responses" = true;
    "net.ipv4.tcp_syncookies" = true;
    "net.ipv4.conf.all.accept_source_route" = false;
    "net.ipv4.conf.default.accept_source_route" = false;
    "net.ipv6.conf.all.accept_source_route" = false;
    "net.ipv6.conf.default.accept_source_route" = false;
    "net.ipv4.conf.all.send_redirects" = false;
    "net.ipv4.conf.default.send_redirects" = false;
    "net.ipv4.conf.all.accept_redirects" = false;
    "net.ipv4.conf.default.accept_redirects" = false;
    "net.ipv6.conf.all.accept_redirects" = false;
    "net.ipv6.conf.default.accept_redirects" = false;
    "net.ipv4.conf.all.secure_redirects" = false;
    "net.ipv4.conf.default.secure_redirects" = false;

    # Additional missing security hardening
    "net.ipv4.conf.all.log_martians" = true;
    "net.ipv4.conf.default.log_martians" = true;
    "kernel.core_uses_pid" = true;
    "fs.suid_dumpable" = false;
    "kernel.randomize_va_space" = 2;
    "vm.mmap_rnd_bits" = 32;
    "vm.mmap_rnd_compat_bits" = 16;
    "kernel.ctrl-alt-del" = false;
  };

  virtualisation = {
    podman = {
      enable = true;
    };
    docker.enable = true;
  };

  virtualisation.libvirtd = {
    enable = true;
    qemu = {
      # This is the default, but it's good to be explicit
      package = pkgs.qemu_kvm;
      # Enable other features as needed, e.g., for shared folders
      vhostUserPackages = with pkgs; [ virtiofsd ];
      swtpm.enable = true;
    };
  };

  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking = {
    hostName = "vimes";

    interfaces = {
      enp0s13f0u4u4.useDHCP = true;
      wlp0s20f3.useDHCP = true;
    };

    nat = {
      enable = true;
      internalInterfaces = [ "ve-*" ];
      # Wired at office.
      externalInterface = "wlp0s20f3";
    };

    networkmanager = {
      enable = true;
      wifi.powersave = false;

      # Tell NetworkManager to ignore br0 (managed by libvirt)
      unmanaged = [ "br0" ];

      # Explicitly enable all plugins that used to be default, to
      # have a functioning VPN
      plugins = with pkgs; [
        networkmanager-fortisslvpn
        networkmanager-iodine
        networkmanager-l2tp
        networkmanager-openconnect
        networkmanager-openvpn
        networkmanager-sstp
        networkmanager-vpnc
      ];
    };

    useDHCP = false;
  };

  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = with pkgs; [
    afuse
    clamav
    fscrypt-experimental
    gnupg
    sshfs-fuse

    virt-manager
    qemu
    virtiofsd
  ];

  services.clamav = {
    daemon.enable = true;
    updater.enable = true;
  };

  boot = {
    kernelModules = [
      "nbd"
      "uvcvideo"
    ];
    tmp.useTmpfs = true;
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.extraUsers.nthorne.extraGroups = [
    "wheel"
    "docker"
    "dialout"
    "disk"
    "audio"
    "libvirtd"
  ];
  users.extraGroups.networkmanager.members = [ "nthorne" ];

  hardware.nvidia = {
    # Keep using the closed source, proprietary driver.
    open = false;
    prime = {
      offload.enable = true;

      # Bus ID of the Intel GPU. VGA controller found with lspci
      intelBusId = "PCI:0:2:0";

      # Bus ID of the NVIDIA GPU. 3D controller found with lspci
      nvidiaBusId = "PCI:1:0:0";
    };
  };

  # ^^

  # Not sure about this one
  hardware.nvidia.modesetting.enable = true;
  services = {
    xserver.videoDrivers = [
      "nvidia"
      "intel"
      "modesetting"
      "displaylink"
    ];
  };

  # https://discourse.nixos.org/t/external-monitors-not-working-dell-xps/1799/7
  # dropped uvcvideo from this list, since I do want a webcam..
  boot.blacklistedKernelModules = [
    "nouveau"
    "rivafb"
    "nvidiafb"
    "rivatv"
    "nv"
  ];
  # ^^

  # Unless this one, (and no nvidia driver), kitty refuses to start.
  hardware.graphics.enable = true;

  # Needed for cargo to be able to pull from private Github repositories
  programs.ssh = {
    forwardX11 = true;
  };

  services.ollama = {
    enable = true;
    acceleration = "cuda";
    host = "127.0.0.1";
    environmentVariables = {
      OLLAMA_ORIGINS = "app://obsidian.md*,http://100.67.86.55:11435,https://100.67.86.55:11435,http://localhost:11434,https://localhost:11434";
      CUDA_VISIBLE_DEVICES = "0,1";
    };
  };

  # Secure Ollama proxy for Tailscale access using nginx
  services.nginx = {
    enable = true;
    virtualHosts."ollama-tailscale" = {
      listen = [
        {
          addr = "100.67.86.55";
          port = 11435;
        }
      ];
      serverName = "_"; # Accept any hostname
      locations."/" = {
        proxyPass = "http://127.0.0.1:11434";
        extraConfig = ''
          proxy_set_header Host localhost:11434;
          proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
          proxy_set_header X-Forwarded-Proto $scheme;
        '';
      };
    };
  };

  services.tailscale.enable = true;

  # Audit logging for security monitoring
  security.auditd.enable = true;
  security.audit = {
    enable = true;
    backlogLimit = 1024;
    rateLimit = 0;
    failureMode = "silent";
    rules = [
      # Monitor file access to sensitive directories
      "-w /etc/passwd -p wa -k identity"
      "-w /etc/group -p wa -k identity"
      "-w /etc/shadow -p wa -k identity"
      "-w /etc/sudoers -p wa -k identity"
      "-w /etc/hosts -p wa -k network"
      "-w /etc/NetworkManager/ -p wa -k network"

      # Monitor privileged commands (use actual NixOS paths)
      "-w /run/wrappers/bin/passwd -p x -k passwd_modification"
      "-w /run/current-system/sw/bin/gpasswd -p x -k group_modification"
      "-w /run/wrappers/bin/newgrp -p x -k group_modification"
      "-w /run/current-system/sw/bin/chgrp -p x -k group_modification"
      "-w /run/wrappers/bin/su -p x -k priv_esc"
      "-w /run/wrappers/bin/sudo -p x -k priv_esc"

      # Monitor network configuration (use actual NixOS paths)
      "-w /run/current-system/sw/bin/iptables -p x -k network"
      "-w /run/current-system/sw/bin/ip6tables -p x -k network"
      "-w /run/current-system/sw/bin/ip -p x -k network"

      # Monitor system calls (reduced for VM environments, removed stime for modern kernels)
      "-a always,exit -F arch=b64 -S adjtimex,settimeofday -k time_change"
      "-a always,exit -F arch=b64 -S clock_settime -k time_change"

      # Monitor file deletions
      "-a always,exit -F arch=b64 -S unlink,unlinkat,rename,renameat -F success=1 -k delete"

      # Monitor permission changes
      "-a always,exit -F arch=b64 -S chmod,fchmod,fchmodat -F success=1 -k perm_mod"
      "-a always,exit -F arch=b64 -S chown,fchown,lchown,fchownat -F success=1 -k perm_mod"
    ];
  };

  # Fix audit service startup timing by ensuring SUID/SGID wrappers are created first
  systemd.services.audit-rules-nixos = {
    after = [ "suid-sgid-wrappers.service" ];
    wants = [ "suid-sgid-wrappers.service" ];
  };

  # Ensure log directories exist
  systemd.tmpfiles.rules = [
    "d /var/log/audit 0750 root adm -"
    "d /var/log/clamav 0750 clamav clamav -"
  ];

  # Enhanced firewall configuration
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ ];
    allowedUDPPorts = [ ];

    # Trust libvirt bridge interfaces for VM networking
    trustedInterfaces = [
      "virbr0"
      "virbr1"
      "docker0"
    ];

    # Custom rules for enhanced security
    extraCommands = ''
      # Allow Ollama on Tailscale interface only
      iptables -A nixos-fw -i tailscale0 -p tcp --dport 11435 -j nixos-fw-accept

      # Allow SSH from Tailscale network only (if needed)
      # iptables -A nixos-fw -i tailscale0 -p tcp --dport 22 -j nixos-fw-accept

      # Log dropped packets (limited to prevent spam)
      iptables -A nixos-fw -m limit --limit 5/min --limit-burst 5 -j LOG --log-prefix "iptables-dropped: "
    '';

    extraStopCommands = ''
      iptables -D nixos-fw -i tailscale0 -p tcp --dport 11435 -j nixos-fw-accept 2>/dev/null || true
    '';
  };

  nix.extraOptions = ''
    keep-outputs = true
    keep-derivations = true
    experimental-features = nix-command flakes
    accept-flake-config = true
  '';

  sops.age.keyFile = "/etc/sops/age/keys.txt";
  sops.secrets = {
    unicorn-passwords = {
      format = "binary";
      sopsFile = ./secrets/unicorn-passwords.sh;

      mode = "0440";
      owner = config.users.users.nthorne.name;
      group = config.users.users.nthorne.group;
    };
  };

  environment.etc = {
    "vpn/netclean-client-ca.pem".source = ./secrets/vpn/netclean-client-ca.pem;
    "vpn/netclean-client-cert.pem".source = ./secrets/vpn/netclean-client-cert.pem;
    "vpn/netclean-client-key.pem".source = ./secrets/vpn/netclean-client-key.pem;
    "vpn/netclean-client-tls-crypt.pem".source = ./secrets/vpn/netclean-client-tls-crypt.pem;

    # Auditd configuration for proper logging
    "audit/auditd.conf".text = ''
      log_file = /var/log/audit/audit.log
      log_format = RAW
      log_group = adm
      priority_boost = 4
      flush = INCREMENTAL_ASYNC
      freq = 50
      max_log_file = 8
      num_logs = 5
      disp_qos = lossy
      dispatcher = /sbin/audispd
      name_format = NONE
      max_log_file_action = ROTATE
      space_left = 75
      space_left_action = SYSLOG
      admin_space_left = 50
      admin_space_left_action = SUSPEND
      disk_full_action = SUSPEND
      disk_error_action = SUSPEND
    '';
  };

  # I handled this one separately from sops, as it is an input to `certificateFiles`
  # and need to be in this repository.
  security.pki.certificateFiles = [ ./secrets/vimes.pem ];

  # TEMP: Disable this one until the CUDA debacle has been resolved 😒
  #nixpkgs.config.cudaSupport = true;

  # Enable systemd-oomd for better OOM handling
  systemd.oomd = {
    enable = true;
    enableRootSlice = true;
    enableSystemSlice = true;
    enableUserSlices = true;
  };
}
