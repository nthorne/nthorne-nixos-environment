# Administration bridge between the Hermes agent and this host.
#
# Two separate grants, both for the `hermes` service user:
#
#   1. apply a system generation the agent built itself
#      (agent: nix build → point /var/lib/hermes/.hermes/hex-target at ./result
#       → `systemctl start hex-apply`), and
#   2. reboot / power off the host — used only when the operator explicitly asks.
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

  # Polkit is the authorisation path, so no sudoers entry (and no weakening of
  # the agent's systemd sandbox) is needed.
  security.polkit.extraConfig = ''
    polkit.addRule(function (action, subject) {
      if (subject.user !== "hermes") {
        return polkit.Result.NOT_HANDLED;
      }

      // Let the agent activate a generation it built.
      if (action.id === "org.freedesktop.systemd1.manage-units" &&
          action.lookup("unit") === "hex-apply.service" &&
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
