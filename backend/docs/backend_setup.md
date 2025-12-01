# Relay Agent Backend Setup Guide

## Prerequisites

- **Node.js**: Version 18+ (LTS recommended)
- **Python**: Version 3.8+ (for Python plugins)
- **Non-root user**: Never run the agent as root for security reasons
- **SSH Access**: Key-based authentication to your VPS

## Installation Steps

### 1. Create a Dedicated User (CRITICAL)

**Never run the agent as root.** Create a dedicated user:

```bash
sudo adduser relay
sudo usermod -aG docker relay  # If using Docker plugins
```

Switch to the relay user:

```bash
sudo su - relay
```

### 2. Clone or Upload the Agent

```bash
cd ~
git clone <your-repo-url> relay-agent
# OR upload the backend folder via SCP
cd relay-agent
```

### 3. Install Node.js Dependencies

```bash
npm install
```

This installs Express and other required packages.

### 4. Install Python Dependencies

```bash
pip3 install psutil
# OR if you have a requirements.txt
pip3 install -r requirements.txt
```

Required for system monitoring plugins (CPU, RAM, Disk).

### 5. Configure Environment Variables

Create the `.env` file:

```bash
cp sample.env .env
nano .env
```

Set a strong Agent Secret (32+ characters):

```
PORT=3000
AGENT_SECRET=your-secure-random-secret-here
```

**Generate a secure secret:**

```bash
openssl rand -base64 32
```

### 6. Verify Plugins

Check that default plugins are executable:

```bash
chmod +x plugins/*.py plugins/*.sh
ls -la plugins/
```

You should see:

- `00_system_vitals.py`
- `10_disk_usage.py`
- `20_docker_containers.py`
- `30_pm2_processes.js`
- `40_network_traffic.py`

### 7. Test the Agent Manually

Start the server:

```bash
npm start
```

In another terminal, test locally:

```bash
curl -H "x-agent-secret: your-secret" http://127.0.0.1:3000/api/status
```

You should see JSON output with plugin data.

### 8. Set Up as a System Service (Recommended)

Create a systemd service file:

```bash
sudo nano /etc/systemd/system/relay-agent.service
```

Paste this configuration:

```ini
[Unit]
Description=Relay Agent - VPS Operations Backend
After=network.target

[Service]
Type=simple
User=relay
WorkingDirectory=/home/relay/relay-agent
ExecStart=/usr/bin/node server.js
Restart=on-failure
RestartSec=5
Environment=NODE_ENV=production

[Install]
WantedBy=multi-user.target
```

Enable and start the service:

```bash
sudo systemctl daemon-reload
sudo systemctl enable relay-agent
sudo systemctl start relay-agent
sudo systemctl status relay-agent
```

### 9. Configure Firewall (CRITICAL)

See `docs/security_setup.md` for detailed firewall configuration.

Quick setup:

```bash
sudo ufw allow 22/tcp    # SSH
sudo ufw deny 3000/tcp   # Block agent port externally
sudo ufw enable
```

### 10. Verify Installation

Check the service logs:

```bash
sudo journalctl -u relay-agent -f
```

Test via SSH tunnel from your local machine:

```bash
ssh -L 3000:127.0.0.1:3000 relay@your-vps-ip
# Then in another terminal:
curl -H "x-agent-secret: your-secret" http://127.0.0.1:3000/api/status
```

## Troubleshooting

### Agent Won't Start

Check logs:

```bash
sudo journalctl -u relay-agent -n 50
```

Common issues:

- Missing `.env` file
- Port 3000 already in use (change PORT in `.env`)
- Missing Node.js modules (run `npm install`)

### Plugins Return Errors

Test individual plugins:

```bash
cd ~/relay-agent
python3 plugins/00_system_vitals.py
```

Each plugin should output valid JSON.

### Permission Denied Errors

Ensure the relay user has necessary permissions:

```bash
# For Docker access
sudo usermod -aG docker relay

# For PM2 access
npm install -g pm2
```

### Connection Refused from App

Verify:

1. Agent is running: `sudo systemctl status relay-agent`
2. SSH tunnel is active in your Flutter app
3. Agent Secret matches in both `.env` and app

## Updating the Agent

```bash
cd ~/relay-agent
git pull  # Or upload new files
npm install  # Update dependencies
sudo systemctl restart relay-agent
```

## Security Checklist

- [ ] Running as non-root user (relay)
- [ ] Strong Agent Secret (32+ characters)
- [ ] Firewall blocks port 3000 externally
- [ ] Agent binds to localhost only (127.0.0.1)
- [ ] SSH uses key-based authentication
- [ ] `.env` file has restricted permissions (600)

Set correct permissions:

```bash
chmod 600 ~/relay-agent/.env
```

## Optional: PM2 Process Manager

Alternative to systemd for easier management:

```bash
npm install -g pm2
pm2 start server.js --name relay-agent
pm2 save
pm2 startup  # Follow the instructions
```

Manage with PM2:

```bash
pm2 status
pm2 restart relay-agent
pm2 logs relay-agent
```
