# OpenClaw Manual Setup Guide

**Status:** Instructions for post-NixOS rebuild setup on hex host  
**Date:** 2026-03-18

After running `nixos-rebuild switch` on hex, follow these steps to complete OpenClaw setup.

---

## Step 1: Prepare nix-secrets Repository

### 1a. Get hex's age public key

On hex, extract the SSH host ed25519 key and convert it to age format:

```bash
nix-shell -p ssh-to-age --run "cat /etc/ssh/ssh_host_ed25519_key.pub | ssh-to-age"
```

This will output something like: `age1abc...xyz`

### 1b. Update nix-secrets with hex entries

In your `nix-secrets` repository:

1. **Decrypt the sops YAML:**
   ```bash
   cd ~/repos/nix-secrets
   sops secrets.yaml  # Opens in your editor
   ```

2. **Add hex section** (if not present):
   ```yaml
   hex:
     openclaw:
       slack_app_token: xapp-...  # From your Slack app at https://api.slack.com
       slack_bot_token: xoxb-...   # From your Slack app
   ```

3. **Update `.sops.yaml`** to include hex's age key in the appropriate key group:
   ```yaml
   keys:
     - &hex age1abc...xyz  # From step 1a
     - &vimes age1def...uvw
   creation_rules:
     - path_regex: hex\.yaml
       key_groups:
       - age: *hex
   ```

4. **Save and re-encrypt** (sops will auto-encrypt on exit if `.sops.yaml` is configured correctly)

---

## Step 2: Create OpenClaw Configuration

On hex, create the configuration file:

```bash
sudo mkdir -p /var/lib/openclaw
sudo chown openclaw:openclaw /var/lib/openclaw
```

Then create `/var/lib/openclaw/openclaw.json`:

```json
{
  "gateway": {
    "bind": "127.0.0.1",
    "port": 18789
  },
  "models": {
    "primary": "github-copilot/gpt-4-mini",
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
    "obsidian": {
      "path": "/var/lib/openclaw/vault"
    },
    "trello": {
      "require_approval": true
    }
  }
}
```

---

## Step 3: Create Slack Application

1. Go to https://api.slack.com
2. Create a new app or use existing one
3. Enable **Socket Mode** in app settings
4. Generate and copy:
   - **App-level token** (xapp-*) → Add to nix-secrets as `hex/openclaw/slack_app_token`
   - **Bot token** (xoxb-*) → Add to nix-secrets as `hex/openclaw/slack_bot_token`
5. Store these in nix-secrets (see Step 1b)

---

## Step 4: Authenticate GitHub Copilot

On hex, authenticate with your GitHub Copilot subscription:

```bash
sudo -u openclaw /run/current-system/sw/bin/openclaw models auth login-github-copilot
```

Follow the interactive prompts to complete authentication.

---

## Step 5: Create Task Instructions (Optional)

Create `/var/lib/openclaw/HEARTBEAT.md` with task instructions that OpenClaw will read on each heartbeat:

```markdown
# OpenClaw Tasks

## Daily Checks
- Check system health
- Review any pending notifications

## Weekly Tasks
- Audit recent logs
- Test connectivity
```

---

## Step 6: Verify Service Status

```bash
# Check if service is running
systemctl status openclaw

# View service logs
journalctl -u openclaw -f

# Check if secrets were decrypted
ls -la /run/secrets.d/*/openclaw-env

# Test gateway health
curl -s http://127.0.0.1:18789/health
```

---

## Accessing the OpenClaw Dashboard

Since OpenClaw gateway is bound to `127.0.0.1:18789`, it's **not directly accessible over Tailscale**. You must use an SSH tunnel:

### One-time SSH Tunnel

```bash
# From your local machine
ssh -L 18789:127.0.0.1:18789 <hex-tailscale-ip>
# Then browse to: http://localhost:18789
```

### Persistent SSH Tunnel (Background)

```bash
# Open tunnel in background
ssh -L 18789:127.0.0.1:18789 <hex-tailscale-ip> -N &

# To close the tunnel later, find and kill the process:
pkill -f "ssh -L 18789"
```

### SSH Config for Convenience

Add to your `~/.ssh/config`:

```
Host hex-openclaw
    HostName <hex-tailscale-ip>
    LocalForward 18789 127.0.0.1:18789
    User nthorne
```

Then simply:
```bash
ssh hex-openclaw -N &  # Opens tunnel in background
# Browse to http://localhost:18789
pkill -f "hex-openclaw"  # Close tunnel when done
```

### Why this design?

- **Bound to 127.0.0.1**: Only accessible locally on hex, not directly on any network interface
- **SSH tunnel requirement**: Provides additional authentication layer and encrypted transport over Tailscale
- **More secure**: Even if Tailscale or network is misconfigured, the port remains unreachable

---

## Rollback / Cleanup

If you need to remove OpenClaw:

1. Delete `hex/openclaw.nix`
2. Remove openclaw import from `hex/adaptation.nix`
3. Remove sops-nix module from `hex-modules` in `flake.nix`
4. Run `nixos-rebuild switch` on hex
5. (Optional) Clean up `/var/lib/openclaw` manually:
   ```bash
   sudo rm -rf /var/lib/openclaw
   ```

---

## Troubleshooting

### Secrets not found
```bash
# Check sops-nix decryption
systemctl status sops-nix

# Check if secret files exist
ls -la /run/secrets.d/
```

### Service fails to start
```bash
# Check detailed logs
journalctl -u openclaw -n 50

# Verify openclaw binary exists
which openclaw
/run/current-system/sw/bin/openclaw --version
```

### Can't access over SSH tunnel
```bash
# Verify tunnel is open
netstat -tln | grep 18789

# Test local connectivity on hex
ssh hex "curl -s http://127.0.0.1:18789/health"
```

---

## References

- OpenClaw GitHub: https://github.com/openclaw/openclaw
- Slack API: https://api.slack.com
- Tailscale SSH: https://tailscale.com/kb/1193/tailscale-ssh
- SSH Local Port Forwarding: https://www.ssh.com/ssh/tunneling/example#local-forwarding
