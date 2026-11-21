# Unattended recovery from the hard hangs this box has been having.
#
# Three outages so far (2026-11-16 17:40, 2026-11-20 19:42, then again the next
# morning) all ended the same way: no clean shutdown, nothing in the journal, an
# unclean ext4 recovery on the next boot, and the only way back was a physical
# press of the power button. The second one was especially telling — the box
# stayed pingable for fourteen hours while writing nothing at all to disk, so
# the failure is a wedge in the kernel/IO path, not a power cut (the house meter
# and Home Assistant kept logging throughout).
#
# Two independent mechanisms now recover without a human:
#
#   * the iTCO hardware watchdog in the PCH — if the kernel stops petting it the
#     chip resets the machine, which is the only thing that works when the SoC
#     is wedged. Needs no userspace beyond PID1.
#   * kernel.panic = 10 — a kernel panic reboots after ten seconds rather than
#     sitting on the panic screen until someone notices.
#
# Both are checkable right after a switch:
#   systemctl show -p RuntimeWatchdogUSec      # expect 1min
#   sysctl kernel.panic                         # expect 10
# and a wedged box should come back on its own within a minute instead of
# waiting days for a button press.
#
# Worth remembering if hangs persist: the N2820 is Bay Trail, whose deep C-state
# erratum is the classic cause of random freezes; `intel_idle.max_cstate=1` is
# the usual workaround. Not enabled here — the evidence above points at the IO
# path rather than idle states, and one variable at a time.
{ ... }:
{
  # Hardware watchdog. PID1 pings it; a wedged kernel stops pinging and the PCH
  # resets the box. 60 s is well above any legitimate stall on this hardware and
  # below the point where a hang costs a human intervention.
  systemd.settings.Manager.RuntimeWatchdogSec = "60s";

  # Reboot ten seconds after a panic instead of hanging forever.
  boot.kernel.sysctl."kernel.panic" = 10;
}
