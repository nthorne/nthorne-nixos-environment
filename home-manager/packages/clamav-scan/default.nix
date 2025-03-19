{
  ...
}: {
  home.file."scripts/clamav-scan.sh" = {
    text = ''
      #!/usr/bin/env bash
      # This one is incredibly slow, so I'll skip it for now.
      #clamscan -r -i /nix/store --log=$HOME/.clamav-store-scan.log
      clamscan -r -i /home/nthorne --log=$HOME/.clamav-home-scan.log
    '';
    executable = true;
  };

  systemd.user.services.clamav-scan = {
    Unit.Description = "ClamAV User Scan";
    Service.ExecStart = "/home/nthorne/scripts/clamav-scan.sh";
  };

  systemd.user.timers.clamav-scan = {
    Unit.Description = "Scheduled User ClamAV Scan";
    Install.WantedBy = ["timers.target"];
    Timer.OnCalendar = "weekly";
  };
}
