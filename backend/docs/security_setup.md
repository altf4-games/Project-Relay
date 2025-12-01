# Relay Agent Security Setup Guide

## Overview

The Relay Agent is designed with security in mind, using **localhost-only binding** and requiring an **Agent Secret** for authentication. However, as an additional layer of defense, you should configure your VPS firewall to explicitly block external access to the agent port.

## Required Setup Steps

Run these commands on your VPS to secure the Relay Agent:

### 1. Allow SSH Access (Port 22)

```bash
sudo ufw allow 22/tcp
```

This ensures you can still connect to your server via SSH.

### 2. Block the Agent Port from External Access

```bash
sudo ufw deny 3000/tcp
```

This explicitly blocks port 3000 (or your custom agent port) from external connections. Even if the Node.js binding fails, the OS firewall will protect the port.

### 3. Enable the Firewall

```bash
sudo ufw enable
```

Activates UFW (Uncomplicated Firewall) to enforce the rules.

### 4. Verify Firewall Status

```bash
sudo ufw status
```

You should see output like:

```
Status: active

To                         Action      From
--                         ------      ----
22/tcp                     ALLOW       Anywhere
3000/tcp                   DENY        Anywhere
```

## How It Works

1. **Localhost Binding**: The agent binds to `127.0.0.1:3000`, making it inaccessible from outside the server.
2. **SSH Tunnel**: Your Relay app connects via SSH and creates a secure tunnel to access `localhost:3000`.
3. **Firewall Protection**: UFW provides defense-in-depth by blocking port 3000 even if the binding configuration fails.
4. **Agent Secret**: Even with tunnel access, requests must include the correct `x-agent-secret` header.

## Security Layers Summary

| Layer             | Protection                      |
| ----------------- | ------------------------------- |
| UFW Firewall      | Blocks port 3000 from internet  |
| Localhost Binding | Agent only listens on 127.0.0.1 |
| SSH Tunnel        | Encrypted connection required   |
| Agent Secret      | Header-based authentication     |

## Troubleshooting

### Firewall Not Installed

If UFW is not available:

**Ubuntu/Debian:**

```bash
sudo apt update && sudo apt install ufw
```

**CentOS/RHEL (use firewalld instead):**

```bash
sudo firewall-cmd --permanent --add-service=ssh
sudo firewall-cmd --permanent --remove-port=3000/tcp
sudo firewall-cmd --reload
```

### Changed Agent Port

If you're using a different port (e.g., 4000), update the deny rule:

```bash
sudo ufw deny 4000/tcp
```

### Testing Security

From another machine, try to access the agent directly:

```bash
curl http://your-server-ip:3000/api/status
```

This should **timeout or be refused**. If it returns data, your security setup needs review.

From inside your SSH session, verify it works locally:

```bash
curl -H "x-agent-secret: your-secret" http://127.0.0.1:3000/api/status
```

This should return `{"status":"alive"}`.

## Best Practices

1. **Use Strong Agent Secrets**: Generate a random 32+ character secret.
2. **Rotate Secrets Regularly**: Update the Agent Secret periodically.
3. **Keep SSH Keys Secure**: Use SSH keys instead of passwords for SSH authentication.
4. **Monitor Logs**: Check `/var/log/ufw.log` for suspicious connection attempts.
5. **Use Non-Standard SSH Port**: Consider changing SSH from port 22 to a non-standard port (optional).

## Emergency Access

If you accidentally lock yourself out:

1. Access your VPS via your hosting provider's console/VNC.
2. Disable UFW temporarily: `sudo ufw disable`
3. Fix your configuration.
4. Re-enable: `sudo ufw enable`
