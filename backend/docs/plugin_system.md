# Relay Plugin System Guide

## Plugin Architecture

Plugins are executable scripts that run on your VPS and output JSON data. The Relay Agent executes these scripts, parses their output, and serves it to your mobile app.

## How Plugins Work

### Execution Flow

1. Agent scans the `plugins/` directory
2. Executes files matching `.py`, `.sh`, or `.js` extensions
3. Captures stdout (standard output)
4. Parses JSON from stdout
5. Aggregates all plugin outputs
6. Serves combined data via API

### Plugin Output Format

Every plugin must output valid JSON to stdout:

```json
{
  "title": "Plugin Name",
  "widgets": [
    {
      "type": "metric_card",
      "data": {
        "label": "Metric Name",
        "value": "Metric Value",
        "status": "success"
      }
    }
  ]
}
```

### Supported Widget Types

**metric_card**: Display a single metric

```json
{
  "type": "metric_card",
  "data": {
    "label": "CPU Load",
    "value": "45%",
    "status": "success|warning|error"
  }
}
```

**progress_bar**: Display a progress indicator

```json
{
  "type": "progress_bar",
  "data": {
    "label": "Memory",
    "value": 65.5,
    "max": 100
  },
  "gridWidth": 2
}
```

**action_button**: Execute a command via SSH

```json
{
  "type": "action_button",
  "data": {
    "label": "Restart Service",
    "command": "systemctl restart nginx"
  }
}
```

## Pre-installed Plugins

The agent comes with 5 verified, safe plugins:

### 00_system_vitals.py

- **Purpose**: CPU load, RAM usage, system uptime
- **Dependencies**: `psutil` (Python package)
- **Security**: Read-only system metrics
- **Verified**: ✅ Safe

### 10_disk_usage.py

- **Purpose**: Disk space usage
- **Dependencies**: `psutil`
- **Security**: Read-only disk metrics
- **Verified**: ✅ Safe

### 20_docker_containers.py

- **Purpose**: Docker container status
- **Dependencies**: Docker CLI, `docker` Python package
- **Security**: Requires Docker group membership
- **Verified**: ✅ Safe (read-only)

### 30_pm2_processes.js

- **Purpose**: Node.js PM2 process status
- **Dependencies**: PM2 installed globally
- **Security**: Read-only PM2 status
- **Verified**: ✅ Safe

### 40_network_traffic.py

- **Purpose**: Network RX/TX statistics
- **Dependencies**: `psutil`
- **Security**: Read-only network metrics
- **Verified**: ✅ Safe

## Plugin Security Rules

### ⚠️ CRITICAL: Never Install Untrusted Plugins

**Why plugins are dangerous:**

- Plugins run with the same permissions as the agent user
- Malicious plugins can steal data, modify files, or compromise your server
- Plugin code is executed directly without sandboxing

### Safe Plugin Practices

1. **Only use verified plugins**: Use the pre-installed plugins or write your own
2. **Review code before adding**: Read every line of a plugin before installing it
3. **Avoid third-party plugins**: Don't download plugins from random GitHub repos
4. **Minimize permissions**: Run agent as non-root user with minimal permissions
5. **Test in isolation**: Test new plugins on a separate test server first

### Warning Signs of Malicious Plugins

❌ Network requests to external servers  
❌ File system modifications outside logging  
❌ Execution of arbitrary commands from remote sources  
❌ Obfuscated or encoded code  
❌ Requests for root/sudo access  
❌ Reading sensitive files (`/etc/shadow`, SSH keys, etc.)

## Creating Custom Plugins

### Example: Simple Python Plugin

```python
#!/usr/bin/env python3
import json
import subprocess

try:
    result = subprocess.run(
        ['df', '-h', '/'],
        capture_output=True,
        text=True,
        timeout=5
    )

    lines = result.stdout.strip().split('\n')
    usage = lines[1].split()[4]  # Get percentage

    output = {
        "title": "Disk Usage",
        "widgets": [{
            "type": "metric_card",
            "data": {
                "label": "Root Disk",
                "value": usage,
                "status": "success"
            }
        }]
    }

    print(json.dumps(output))

except Exception as e:
    error_output = {
        "title": "Disk Usage",
        "error": str(e),
        "widgets": []
    }
    print(json.dumps(error_output))
```

### Example: Shell Script Plugin

```bash
#!/bin/bash

# Get uptime
UPTIME=$(uptime -p)

# Output JSON
cat <<EOF
{
  "title": "System Info",
  "widgets": [
    {
      "type": "metric_card",
      "data": {
        "label": "Uptime",
        "value": "$UPTIME",
        "status": "success"
      }
    }
  ]
}
EOF
```

### Plugin Best Practices

1. **Set timeouts**: Ensure commands timeout (5-10 seconds max)
2. **Handle errors gracefully**: Output error JSON instead of crashing
3. **Use read-only operations**: Avoid write/modify operations
4. **Validate input**: If taking parameters, validate strictly
5. **Keep it simple**: Focused plugins are easier to audit
6. **Test output format**: Verify JSON is valid before deployment

### Naming Convention

Use numeric prefixes to control execution order:

- `00-09`: System metrics (CPU, RAM, Disk)
- `10-19`: Storage and filesystems
- `20-29`: Containers and virtualization
- `30-39`: Process managers
- `40-49`: Network metrics
- `50+`: Custom/optional plugins

### Plugin Permissions

Make plugins executable:

```bash
chmod +x plugins/50_custom_plugin.py
```

Ensure the relay user can execute them:

```bash
ls -la plugins/
# Should show: -rwxr-xr-x relay relay
```

## Disabling Plugins

To disable a plugin without deleting it:

1. Remove execute permission:

   ```bash
   chmod -x plugins/20_docker_containers.py
   ```

2. Or rename with `.disabled` extension:
   ```bash
   mv plugins/30_pm2_processes.js plugins/30_pm2_processes.js.disabled
   ```

## Testing Plugins

Test individual plugins before deployment:

```bash
cd ~/relay-agent
python3 plugins/00_system_vitals.py
# Should output valid JSON
```

Verify JSON format:

```bash
python3 plugins/00_system_vitals.py | jq .
# Should pretty-print JSON without errors
```

## Plugin Troubleshooting

### Plugin Doesn't Appear in App

1. Check if executable: `ls -la plugins/`
2. Test manually: `python3 plugins/your_plugin.py`
3. Check agent logs: `sudo journalctl -u relay-agent -f`
4. Verify JSON output is valid

### Plugin Returns Empty Data

- Check dependencies are installed
- Verify user has necessary permissions
- Look for error messages in JSON output

### Plugin Timeout

Plugins have a 10-second timeout. Optimize slow commands:

- Use caching for expensive operations
- Simplify data collection
- Remove unnecessary processing

## Security Summary

✅ **Safe**: Pre-installed verified plugins  
✅ **Safe**: Custom plugins you write and review  
⚠️ **Risky**: Third-party plugins (review carefully)  
❌ **Dangerous**: Random plugins from the internet

**Remember**: Plugins run with the same permissions as the agent. Never install code you haven't personally reviewed.
