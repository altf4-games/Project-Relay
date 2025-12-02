# Project Relay

**A secure, SSH-tunneled VPS monitoring solution with a Flutter mobile app and extensible plugin system.**

Project Relay enables you to monitor and manage your VPS infrastructure from your mobile device. It establishes an SSH tunnel to securely access a lightweight Node.js agent running on your server, displaying real-time system metrics and executing remote commands.

## Key Features

- **Secure SSH Tunneling**: All communication flows through encrypted SSH connections - no exposed ports
- **Real-Time Monitoring**: CPU, RAM, disk usage, network traffic, and process status with 60-second historical graphs
- **Biometric Authentication**: Fingerprint/face unlock enabled by default for quick access
- **Extensible Plugin System**: Write custom monitoring plugins in Python, JavaScript, or Bash
- **Multiple Server Support**: Manage multiple VPS instances from a single app
- **Zero Trust Architecture**: Agent binds to localhost only, firewall blocks external access, header-based authentication required

## Architecture

### Mobile App (Flutter)

- Cross-platform Android/iOS application
- Establishes SSH tunnel via dart_ssh2
- Server-Driven UI rendered from JSON responses
- Secure credential storage with flutter_secure_storage

### Backend Agent (Node.js)

- Lightweight Express server listening on localhost:3000
- Plugin-based architecture for extensibility
- Real-time metrics collection with 1-second intervals
- Python execution via child_process for system monitoring

### Security Layers

1. UFW firewall blocks agent port from internet
2. Agent binds exclusively to 127.0.0.1
3. SSH tunnel provides encrypted access
4. Agent secret header authentication
5. Biometric authentication on mobile

## Quick Start

### Backend Setup

1. Create a dedicated non-root user on your VPS:

```bash
sudo adduser relay
sudo su - relay
```

2. Clone the repository and install dependencies:

```bash
cd ~
git clone <repository-url> relay-agent
cd relay-agent/backend
npm install
pip3 install psutil
```

3. Configure the agent secret:

```bash
cp sample.env .env
# Edit .env and set a strong AGENT_SECRET (32+ characters)
openssl rand -base64 32  # Generate secure secret
```

4. Configure firewall protection:

```bash
sudo ufw allow 22/tcp
sudo ufw deny 3000/tcp
sudo ufw enable
```

5. Set up systemd service:

```bash
sudo cp relay-agent.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable relay-agent
sudo systemctl start relay-agent
```

Full backend documentation: `backend/docs/backend_setup.md`

### Mobile App Setup

1. Install Flutter dependencies:

```bash
cd app
flutter pub get
```

2. Build and run:

```bash
flutter run                # Development
flutter build apk          # Android release
flutter build ios          # iOS release
```

3. Configure your first connection:

- Add server with SSH credentials
- Enter agent port (default: 3000)
- Set agent secret (matches backend .env)
- Connect and authenticate

## Plugin Development

Create custom monitoring widgets by writing plugins in Python, JavaScript, or Bash. Plugins output JSON defining the UI components.

Example plugin (`plugins/50_custom_monitor.py`):

```python
#!/usr/bin/env python3
import json

plugin = {
    "title": "Custom Monitor",
    "widgets": [
        {
            "title": "Status",
            "type": "metric_card",
            "gridWidth": 1,
            "data": {
                "label": "SERVICE",
                "value": "Running",
                "status": "ok"
            }
        }
    ]
}

print(json.dumps(plugin))
```

Widget types: `metric_card`, `metric_chart`, `progress_bar`, `action_button`

Full plugin documentation: `backend/docs/creating_custom_plugins.md`

## Project Structure

```
Project-Relay/
├── app/                          # Flutter mobile application
│   ├── lib/
│   │   ├── core/                # Core services (SSH, storage, theme)
│   │   ├── features/            # Feature modules (dashboard, connection, settings)
│   │   └── main.dart
│   └── pubspec.yaml
│
├── backend/                      # Node.js agent
│   ├── server.js                # Express server
│   ├── src/
│   │   ├── pluginRunner.js     # Plugin execution engine
│   │   └── services/
│   │       └── metricsCollector.js  # Historical data collection
│   ├── plugins/                 # Monitoring plugins
│   │   ├── 00_system_vitals.py
│   │   ├── 20_docker_containers.py
│   │   ├── 30_pm2_processes.js
│   │   └── 40_network_traffic.py
│   └── docs/                    # Documentation
│
└── README.md
```

## Security Considerations

- **Never run the agent as root** - Use a dedicated low-privilege user
- **Use strong agent secrets** - Minimum 32 characters, random generation recommended
- **Enable SSH key authentication** - Disable password authentication on VPS
- **Keep firewall active** - UFW should deny the agent port explicitly
- **Regular updates** - Keep Node.js, Python, and system packages updated
- **Monitor logs** - Check agent logs for unauthorized access attempts

Full security guide: `backend/docs/security_setup.md`

## Requirements

### Backend

- Node.js 18+ (LTS recommended)
- Python 3.8+ (for system monitoring plugins)
- Linux VPS with SSH access
- UFW or firewalld for firewall management

### Mobile App

- Flutter 3.0+
- Android SDK 21+ or iOS 12+
- Dart SDK 3.0+

## License

This project is provided as-is for personal and commercial use.
