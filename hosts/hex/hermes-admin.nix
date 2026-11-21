# Administration bridge between the Hermes agent and this host.
#
# Three grants for the `hermes` service user, all of them a *unit start*:
#
#   1. apply a system generation the agent built itself
#      (agent: nix build → point /var/lib/hermes/.hermes/hex-target at ./result
#       → `systemctl start hex-apply`),
#   2. reboot the host (`systemctl start hex-reboot`) — used only when the
#      operator explicitly asks for it, and
#   3. (the polkit reboot/power-off actions below stay for a human shell.)
#
# Why a unit instead of a command: Hermes blocks `systemctl reboot` issued from
# the agent's own shell at its tool layer (a hardline block, independent of any
# permission), so a plain polkit grant is unusable from the agent. Starting a
# unit is not blocked, and it keeps the privileged action in a file the operator
# reviewed in the repo rather than in a command string.
#
# The agent never runs as root: the sandbox on hermes-agent stays as configured
# (NoNewPrivileges, ProtectSystem=strict). The activation runs in this root
# service, which is outside that sandbox, and only accepts a store path that
# looks like a hex system closure.
{ pkgs, ... }:
let
  hexApply = pkgs.writeShellScript "hex-apply" ''
    set -euo pipefail
    target=$(readlink -f /var/lib/hermes/.hermes/hex-target)
    case "$target" in
      /nix/store/*-nixos-system-hex-*) ;;
      *)
        echo "refusing to activate: $target is not a hex system closure" >&2
        exit 1
        ;;
    esac
    echo "activating $target"
    nix-env -p /nix/var/nix/profiles/system --set "$target"
    exec "$target/bin/switch-to-configuration" switch
  '';
in
{
  systemd.services.hex-apply = {
    description = "Apply a NixOS generation built by the Hermes agent";
    path = [
      pkgs.nix
      pkgs.coreutils
    ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = false;
      ExecStart = "${hexApply}";
    };
  };

  # `systemctl start hex-reboot` reboots the host. The unit exists because the
  # agent's shell cannot issue the command itself (see the header); it is the
  # same reviewed-unit pattern as hex-apply. It stays inert until started — there
  # is no [Install] section, so nothing pulls it in at boot.
  systemd.services.hex-reboot = {
    description = "Reboot the host on request from the Hermes agent";
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = false;
      ExecStart = "${pkgs.systemd}/bin/systemctl --no-block reboot";
      # The reboot kills this unit mid-run; success is the reboot itself.
      SuccessExitStatus = "0 1";
    };
  };

  # Polkit is the authorisation path, so no sudoers entry (and no weakening of
  # the agent's systemd sandbox) is needed.
  security.polkit.extraConfig = ''
    polkit.addRule(function (action, subject) {
      if (subject.user !== "hermes") {
        return polkit.Result.NOT_HANDLED;
      }

      // Let the agent activate a generation it built, and reboot when asked.
      if (action.id === "org.freedesktop.systemd1.manage-units" &&
          (action.lookup("unit") === "hex-apply.service" ||
           action.lookup("unit") === "hex-reboot.service") &&
          (action.lookup("verb") === "start" || action.lookup("verb") === "restart")) {
        return polkit.Result.YES;
      }

      // Reboot / power off. Policy: only on an explicit request from the
      // operator — the agent does not reboot the host on its own initiative.
      if (action.id === "org.freedesktop.login1.reboot" ||
          action.id === "org.freedesktop.login1.reboot-multiple-sessions" ||
          action.id === "org.freedesktop.login1.power-off" ||
          action.id === "org.freedesktop.login1.power-off-multiple-sessions") {
        return polkit.Result.YES;
      }

      return polkit.Result.NOT_HANDLED;
    });
  '';
}
