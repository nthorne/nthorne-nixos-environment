# OpenClaw NixOS Module Implementation Plan

**Status:** TEMPORARY PLANNING DOCUMENT - TO BE DROPPED BEFORE MERGE TO MAIN  
**Branch:** `feature/openclaw-nix-module`  
**Target Host:** `hex` (NUC)  
**Date:** 2026-03-18

---

## Overview

This document describes the implementation of a hardened, declarative NixOS module for OpenClaw (self-hosted AI assistant/agent) on the `hex` host, with secrets managed via sops-nix and Slack integration using Socket Mode.

### Key Design Decisions

1. **Package Source:** Use `pkgs.openclaw` from nixpkgs (v2026.3.12) directly - no separate flake input
2. **Secrets Management:** sops-nix (matching existing pattern in vimes)
3. **Heartbeat:** Built-in OpenClaw heartbeat (configured in `openclaw.json`), not systemd timers
4. **Security Posture:** Zero-trust - Tailscale only, no public ports, systemd hardening, restricted user

---

## Threat Model Addressed

From the Gemini discussion, mitigating:

| Threat | Mitigation |
|--------|-----------|
| Prompt Injection (CVE-2026-25253) | systemd hardening, restricted user, no direct filesystem access except `/var/lib/openclaw` |
| Token Exfiltration | sops-nix secrets decrypted at activation, not stored on disk, EnvironmentFile restricted to `openclaw` user |
| Inbound Compromise | Tailscale only, bound to `127.0.0.1`, no public exposure |
| Lateral Movement | Restricted user with `NoNewPrivileges`, `ProtectSystem=strict` |

---

## Implementation Details

### Files to Create

#### 1. `hex/openclaw.nix`

Main NixOS module containing:

- **User/Group Creation**
  - System user `openclaw` with home `/var/lib/openclaw`
  - Dedicated group `openclaw`

- **Insecure Package Permit**
  ```nix
  nixpkgs.config.permittedInsecurePackages = [ "openclaw-2026.3.12" ];
  ```
  (Justification: openclaw has `knownVulnerabilities` for prompt injection risk; explicit per-host opt-in)

- **Secrets Decryption (sops-nix)**
  - `sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ]`
  - Decryption via hex's SSH host ed25519 key
  - Secrets from nix-secrets repo:
    - `hex.openclaw.slack_app_token` (xapp-*)
    - `hex.openclaw.slack_bot_token` (xoxb-*)

- **EnvironmentFile Template**
  - `sops.templates."openclaw-env"` renders:
    ```
    SLACK_APP_TOKEN=<decrypted>
    SLACK_BOT_TOKEN=<decrypted>
    ```
  - Owner: `openclaw`, mode: `0400`

- **Systemd Service Hardening**
  - User: `openclaw`, Group: `openclaw`
  - After: `network.target`, `tailscaled.service`, `sops-nix.service`
  - ExecStart: `${pkgs.openclaw}/bin/openclaw gateway --port 18789 --bind 127.0.0.1`
  - EnvironmentFile: `${config.sops.templates."openclaw-env".path}`
  - Hardening:
    - `ProtectSystem = "strict"`
    - `ProtectHome = true`
    - `PrivateTmp = true`
    - `NoNewPrivileges = true`
    - `ReadWritePaths = [ "/var/lib/openclaw" ]`
    - `RestrictAddressFamilies = [ "AF_INET" "AF_INET6" "AF_UNIX" ]`
  - Restart policy: `on-failure` with `RestartSec = "10s"`

### Files to Modify

#### 2. `hex/adaptation.nix`

Add to imports:
```nix
./openclaw.nix
```

#### 3. `flake.nix`

- Add `sops-nix` to destructured outputs (currently only in inputs, not outputs)
- Add `sops-nix.nixosModules.sops` to `hex-modules` list (currently only in `vimes-modules`)

---

## Manual Setup (Out of Scope for This PR)

### In `nix-secrets` Repository

1. **Decrypt the sops YAML** containing your per-host secrets
2. **Add hex section** (if not already present):
   ```yaml
   hex:
       openclaw:
           slack_app_token: xapp-...
           slack_bot_token: xoxb-...
   ```
3. **Get hex's age public key:**
   ```bash
   nix-shell -p ssh-to-age --run "ssh-keyscan hex | ssh-to-age"
   # or if hex is local:
   nix-shell -p ssh-to-age --run "cat /etc/ssh/ssh_host_ed25519_key.pub | ssh-to-age"
   ```
4. **Update `.sops.yaml`** to include hex's age key in the appropriate key group
5. **Re-encrypt** with `sops updatekeys secrets/hex.yaml` (or equivalent)

### On `hex` After NixOS Build

1. **Create openclaw vault structure:**
   ```bash
   sudo mkdir -p /var/lib/openclaw
   sudo chown openclaw:openclaw /var/lib/openclaw
   ```

2. **Create `/var/lib/openclaw/openclaw.json`** with configuration:
   ```json
   {
     "gateway": { "bind": "127.0.0.1", "port": 18789 },
     "models": {
       "primary": "github-copilot/gpt-5-mini",
       "reasoning": "github-copilot/claude-3.5-sonnet"
     },
     "channels": {
       "slack": {
         "enabled": true,
         "mode": "socket"
       }
     },
     "agents": {
       "defaults": {
         "heartbeat": {
           "every": "5m"
         }
       }
     },
     "skills": {
       "obsidian": { "path": "/var/lib/openclaw/vault" },
       "trello": { "require_approval": true }
     }
   }
   ```

3. **Create `/var/lib/openclaw/HEARTBEAT.md`** with task instructions (optional but recommended)

4. **Create Slack app** at https://api.slack.com:
   - Enable Socket Mode
   - Generate App-level token (xapp-*)
   - Generate Bot token (xoxb-*)
   - Store these in nix-secrets (step above)

5. **Authenticate GitHub Copilot subscription:**
   ```bash
   sudo -u openclaw /run/current-system/sw/bin/openclaw models auth login-github-copilot
   ```

6. **Pair Slack identity** (optional):
   - DM the bot with a pairing code
   - Bot responds with confirmation

---

## Verification Steps

After `nixos-rebuild switch` on hex:

1. **Service is active:**
   ```bash
   systemctl status openclaw
   ```

2. **Secrets were decrypted:**
   ```bash
   ls -la /run/secrets.d/*/openclaw-env
   ```

3. **Gateway is listening:**
   ```bash
   curl -s http://127.0.0.1:18789/health
   ```

4. **Access via Tailscale:**
   ```bash
   ssh -L 18789:127.0.0.1:18789 <hex-tailscale-ip>
   # Then access http://localhost:18789 from your machine
   ```

---

## Rollback / Cleanup

If needed to revert:

1. Delete `hex/openclaw.nix`
2. Remove openclaw import from `hex/adaptation.nix`
3. Remove sops-nix module from `hex-modules` in `flake.nix`
4. Run `nixos-rebuild switch`
5. (Optional) Clean up `/var/lib/openclaw` manually

---

## Known Limitations / Future Work

| Item | Status |
|------|--------|
| NixOS module for openclaw in nixpkgs | Future: contribute upstream if possible |
| Home-manager integration | Out of scope (system-level only) |
| Multi-agent setup | Out of scope (single agent per host) |
| Skill auto-provisioning via Slack | Supported by openclaw, just requires task config in HEARTBEAT.md |
| Custom prompt template per agent | Supported in `openclaw.json`, not exposed in this module yet |

---

## References

- OpenClaw GitHub: https://github.com/openclaw/openclaw
- sops-nix Documentation: https://github.com/Mic92/sops-nix
- nixpkgs openclaw package: https://github.com/NixOS/nixpkgs/blob/master/pkgs/by-name/op/openclaw/package.nix
- NixOS Hardening: https://nixos.org/manual/nixos/stable/options.html#opt-systemd.services

---

## Commits in This PR

- `TEMP: Add openclaw planning document` (this file - to be dropped before merge)
- `feat: Add hex/openclaw.nix NixOS module`
- `feat: Update flake.nix to include sops-nix in hex-modules`
- `feat: Update hex/adaptation.nix to import openclaw module`

