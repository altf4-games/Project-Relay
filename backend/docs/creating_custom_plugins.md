# Creating Custom Relay Plugins - Complete Guide

## Prerequisites

Before creating a plugin, understand:

1. **JSON Output Format**: Read `json_output_format.md` first
2. **Security**: Plugins run with agent user permissions - never install untrusted code
3. **Execution**: Plugins must output JSON to stdout and complete within 10 seconds

## Plugin Development Workflow

### Step 1: Choose Your Language

Relay supports three plugin types:

- **Python (`.py`)**: Best for system metrics, API calls, complex logic
- **Shell Script (`.sh`)**: Best for simple command outputs, system commands
- **Node.js (`.js`)**: Best for JavaScript-based tools (PM2, npm, etc.)

### Step 2: Plan Your Plugin

Ask yourself:

1. What data do I want to display?
2. What commands/APIs do I need to call?
3. What permissions does the agent user need?
4. How will I handle errors?

### Step 3: Write the Plugin

Follow the templates below for your chosen language.

## Python Plugin Template

### Basic Structure

```python
#!/usr/bin/env python3
import json
import sys

def main():
    try:
        # 1. Gather data
        data = collect_data()

        # 2. Process data
        widgets = process_data(data)

        # 3. Build output
        output = {
            "title": "Plugin Title",
            "widgets": widgets
        }

        # 4. Output JSON
        print(json.dumps(output))

    except Exception as e:
        # 5. Handle errors gracefully
        error_output = {
            "title": "Plugin Title",
            "error": str(e),
            "widgets": []
        }
        print(json.dumps(error_output))
        sys.exit(0)  # Exit cleanly even on error

def collect_data():
    """Gather raw data from system/API"""
    # Your data collection logic here
    pass

def process_data(data):
    """Convert raw data to widget format"""
    widgets = []
    # Your processing logic here
    return widgets

if __name__ == "__main__":
    main()
```

### Example: Custom Service Monitor

```python
#!/usr/bin/env python3
"""
50_service_monitor.py - Monitor systemd services
"""
import json
import subprocess
import sys

def main():
    try:
        # List of services to monitor
        services = ["nginx", "postgresql", "redis"]

        widgets = []

        for service in services:
            status = check_service(service)
            widgets.append({
                "type": "metric_card",
                "data": {
                    "label": service.capitalize(),
                    "value": status["state"],
                    "status": status["health"]
                }
            })

        # Add restart button for stopped services
        stopped = [s for s in services if check_service(s)["state"] == "inactive"]
        if stopped:
            widgets.append({
                "type": "action_button",
                "data": {
                    "label": "Start All",
                    "command": f"sudo systemctl start {' '.join(stopped)}"
                }
            })

        output = {
            "title": "Services",
            "widgets": widgets
        }

        print(json.dumps(output))

    except Exception as e:
        print(json.dumps({
            "title": "Services",
            "error": str(e),
            "widgets": []
        }))

def check_service(name):
    """Check if a systemd service is running"""
    try:
        result = subprocess.run(
            ["systemctl", "is-active", name],
            capture_output=True,
            text=True,
            timeout=3
        )

        state = result.stdout.strip()

        if state == "active":
            return {"state": "Running", "health": "success"}
        elif state == "inactive":
            return {"state": "Stopped", "health": "error"}
        else:
            return {"state": state.capitalize(), "health": "warning"}

    except subprocess.TimeoutExpired:
        return {"state": "Timeout", "health": "error"}
    except Exception:
        return {"state": "Unknown", "health": "warning"}

if __name__ == "__main__":
    main()
```

### Python Best Practices

1. **Use subprocess with timeout**:

```python
result = subprocess.run(
    ["command", "arg"],
    capture_output=True,
    text=True,
    timeout=5  # Always set timeout
)
```

2. **Parse command output safely**:

```python
try:
    lines = result.stdout.strip().split('\n')
    value = lines[1].split()[3]  # May fail if format unexpected
except (IndexError, ValueError):
    value = "N/A"  # Fallback gracefully
```

3. **Use psutil for system metrics**:

```python
import psutil

cpu = psutil.cpu_percent(interval=1)
memory = psutil.virtual_memory()
disk = psutil.disk_usage('/')
```

4. **Format numbers consistently**:

```python
# Format to 1 decimal place
f"{value:.1f}%"

# Convert bytes to GB
f"{bytes_value / (1024**3):.2f} GB"
```

## Shell Script Template

### Basic Structure

```bash
#!/bin/bash

# Exit on error (but catch errors below)
set -o pipefail

# Main function
main() {
    # Check dependencies
    if ! command -v required_command &> /dev/null; then
        echo '{"title":"Plugin Name","error":"required_command not found","widgets":[]}'
        exit 0
    fi

    # Gather data
    DATA=$(gather_data)

    # Build JSON output
    cat <<EOF
{
  "title": "Plugin Title",
  "widgets": [
    {
      "type": "metric_card",
      "data": {
        "label": "Label",
        "value": "$DATA",
        "status": "success"
      }
    }
  ]
}
EOF
}

gather_data() {
    # Your command here
    echo "result"
}

# Run main function
main
```

### Example: Website Uptime Monitor

```bash
#!/bin/bash
"""
55_website_monitor.sh - Check if websites are reachable
"""

# Websites to monitor
SITES=(
    "https://example.com"
    "https://api.example.com"
)

# Initialize widgets array
WIDGETS=""

# Check each site
for SITE in "${SITES[@]}"; do
    # Extract domain name
    DOMAIN=$(echo "$SITE" | sed 's|https://||' | sed 's|/.*||')

    # Check response code
    STATUS_CODE=$(curl -o /dev/null -s -w "%{http_code}" --max-time 5 "$SITE")

    # Determine status
    if [ "$STATUS_CODE" -eq 200 ]; then
        STATUS="success"
        VALUE="Online"
    elif [ -z "$STATUS_CODE" ]; then
        STATUS="error"
        VALUE="Timeout"
    else
        STATUS="warning"
        VALUE="HTTP $STATUS_CODE"
    fi

    # Add widget (properly escape for JSON)
    WIDGET=$(cat <<EOF
    {
      "type": "metric_card",
      "data": {
        "label": "$DOMAIN",
        "value": "$VALUE",
        "status": "$STATUS"
      }
    }
EOF
)

    if [ -z "$WIDGETS" ]; then
        WIDGETS="$WIDGET"
    else
        WIDGETS="$WIDGETS,$WIDGET"
    fi
done

# Output final JSON
cat <<EOF
{
  "title": "Websites",
  "widgets": [
    $WIDGETS
  ]
}
EOF
```

### Shell Script Best Practices

1. **Always check dependencies**:

```bash
if ! command -v docker &> /dev/null; then
    echo '{"title":"Docker","error":"Docker not installed","widgets":[]}'
    exit 0
fi
```

2. **Use timeouts for network commands**:

```bash
curl --max-time 5 "$URL"
timeout 5 ping -c 1 example.com
```

3. **Handle empty output**:

```bash
RESULT=$(some_command)
if [ -z "$RESULT" ]; then
    RESULT="N/A"
fi
```

4. **Escape JSON strings**:

```bash
# For simple strings, quote variables
"value": "$VARIABLE"

# For complex strings with quotes/newlines, use jq
VALUE=$(echo "$RAW_VALUE" | jq -R -s .)
```

## Node.js Plugin Template

### Basic Structure

```javascript
#!/usr/bin/env node
const { execSync } = require("child_process");

function main() {
  try {
    // 1. Gather data
    const data = collectData();

    // 2. Process data
    const widgets = processData(data);

    // 3. Build output
    const output = {
      title: "Plugin Title",
      widgets: widgets,
    };

    // 4. Output JSON
    console.log(JSON.stringify(output));
  } catch (error) {
    // 5. Handle errors
    console.log(
      JSON.stringify({
        title: "Plugin Title",
        error: error.message,
        widgets: [],
      })
    );
  }
}

function collectData() {
  // Your data collection logic
  return {};
}

function processData(data) {
  // Your processing logic
  return [];
}

main();
```

### Example: NPM Package Monitor

```javascript
#!/usr/bin/env node
/**
 * 60_npm_packages.js - Check for outdated npm packages
 */

const { execSync } = require("child_process");
const fs = require("fs");
const path = require("path");

function main() {
  try {
    // Find package.json
    const packagePath = "/path/to/your/project/package.json";

    if (!fs.existsSync(packagePath)) {
      throw new Error("package.json not found");
    }

    // Get outdated packages
    const outdated = getOutdatedPackages(path.dirname(packagePath));

    // Build widgets
    const widgets = [
      {
        type: "metric_card",
        data: {
          label: "Outdated Packages",
          value: `${outdated.length}`,
          status: outdated.length === 0 ? "success" : "warning",
        },
      },
    ];

    // Add update button if outdated packages exist
    if (outdated.length > 0) {
      widgets.push({
        type: "action_button",
        data: {
          label: "Update All",
          command: `cd ${path.dirname(packagePath)} && npm update`,
        },
      });
    }

    console.log(
      JSON.stringify({
        title: "NPM Packages",
        widgets: widgets,
      })
    );
  } catch (error) {
    console.log(
      JSON.stringify({
        title: "NPM Packages",
        error: error.message,
        widgets: [],
      })
    );
  }
}

function getOutdatedPackages(projectPath) {
  try {
    const output = execSync("npm outdated --json", {
      cwd: projectPath,
      encoding: "utf-8",
      timeout: 5000,
    });

    // npm outdated returns JSON
    const outdated = JSON.parse(output || "{}");
    return Object.keys(outdated);
  } catch (error) {
    // npm outdated exits with code 1 if packages are outdated
    // Parse stdout even on error
    if (error.stdout) {
      const outdated = JSON.parse(error.stdout || "{}");
      return Object.keys(outdated);
    }
    return [];
  }
}

main();
```

### Node.js Best Practices

1. **Use execSync with timeout**:

```javascript
execSync("command", {
  encoding: "utf-8",
  timeout: 5000, // 5 second timeout
});
```

2. **Parse JSON output safely**:

```javascript
try {
  const data = JSON.parse(output);
} catch (e) {
  console.log(
    JSON.stringify({
      title: "Plugin",
      error: "Invalid JSON from command",
      widgets: [],
    })
  );
}
```

3. **Handle async operations**:

```javascript
// If you need async, wrap in async function
async function main() {
  try {
    const result = await fetchData();
    console.log(JSON.stringify(result));
  } catch (error) {
    // Handle error
  }
}

main();
```

## Advanced Plugin Patterns

### Pattern 1: Multiple Data Sources

```python
#!/usr/bin/env python3
import json
import psutil
import subprocess

def main():
    try:
        widgets = []

        # Source 1: System metrics
        widgets.extend(get_system_metrics())

        # Source 2: Docker containers
        widgets.extend(get_docker_stats())

        # Source 3: Custom service
        widgets.extend(get_service_status())

        print(json.dumps({
            "title": "Combined Monitor",
            "widgets": widgets
        }))

    except Exception as e:
        print(json.dumps({
            "title": "Combined Monitor",
            "error": str(e),
            "widgets": []
        }))

def get_system_metrics():
    cpu = psutil.cpu_percent(interval=1)
    return [{
        "type": "metric_card",
        "data": {
            "label": "CPU",
            "value": f"{cpu:.1f}%",
            "status": "success" if cpu < 70 else "warning"
        }
    }]

def get_docker_stats():
    # Docker logic here
    return []

def get_service_status():
    # Service check here
    return []

if __name__ == "__main__":
    main()
```

### Pattern 2: Conditional Widgets

```python
#!/usr/bin/env python3
import json
import psutil

def main():
    try:
        widgets = []
        disk = psutil.disk_usage('/')
        used_percent = (disk.used / disk.total) * 100

        # Always show disk usage
        widgets.append({
            "type": "progress_bar",
            "data": {
                "label": "Disk Usage",
                "value": disk.used / (1024**3),
                "max": disk.total / (1024**3)
            },
            "gridWidth": 2
        })

        # Only show warning if > 80%
        if used_percent > 80:
            widgets.append({
                "type": "metric_card",
                "data": {
                    "label": "Disk Warning",
                    "value": f"{used_percent:.1f}% Full",
                    "status": "error" if used_percent > 90 else "warning"
                }
            })

            # Add cleanup button
            widgets.append({
                "type": "action_button",
                "data": {
                    "label": "Clean Logs",
                    "command": "sudo journalctl --vacuum-time=7d"
                }
            })

        print(json.dumps({
            "title": "Disk Monitor",
            "widgets": widgets
        }))

    except Exception as e:
        print(json.dumps({
            "title": "Disk Monitor",
            "error": str(e),
            "widgets": []
        }))

if __name__ == "__main__":
    main()
```

### Pattern 3: Configuration File

```python
#!/usr/bin/env python3
import json
import os

# Configuration at the top of file
CONFIG = {
    "services": ["nginx", "postgresql", "redis"],
    "warning_threshold": 70,
    "critical_threshold": 90
}

def main():
    try:
        widgets = []

        for service in CONFIG["services"]:
            status = check_service(service)
            widgets.append({
                "type": "metric_card",
                "data": {
                    "label": service.capitalize(),
                    "value": status,
                    "status": get_status(status)
                }
            })

        print(json.dumps({
            "title": "Configured Services",
            "widgets": widgets
        }))

    except Exception as e:
        print(json.dumps({
            "title": "Configured Services",
            "error": str(e),
            "widgets": []
        }))

def check_service(name):
    # Check logic here
    return "Running"

def get_status(value):
    return "success"  # Determine from value

if __name__ == "__main__":
    main()
```

## Installing Your Plugin

### 1. Create the Plugin File

```bash
cd ~/relay-agent/plugins
nano 50_my_plugin.py
# Paste your plugin code
```

### 2. Make it Executable

```bash
chmod +x 50_my_plugin.py
```

### 3. Test Manually

```bash
python3 50_my_plugin.py
# Should output valid JSON
```

### 4. Validate JSON

```bash
python3 50_my_plugin.py | jq .
# Should pretty-print without errors
```

### 5. Test with Agent

```bash
# Restart agent
sudo systemctl restart relay-agent

# Check logs
sudo journalctl -u relay-agent -f

# Test API
curl -H "x-agent-secret: your-secret" http://127.0.0.1:3000/api/status
```

### 6. Verify in App

1. Open Relay app
2. Refresh dashboard (pull down)
3. Look for your plugin's title section
4. Verify widgets display correctly

## Debugging Plugins

### Test Plugin Execution

```bash
# Test as agent user
sudo su - relay
cd ~/relay-agent
python3 plugins/50_my_plugin.py
```

### Check for Errors

```bash
# Capture stderr
python3 plugins/50_my_plugin.py 2>&1

# Or redirect to file
python3 plugins/50_my_plugin.py 2> error.log
```

### Validate JSON Structure

```bash
# Check for required fields
python3 plugins/50_my_plugin.py | jq '.title, .widgets[].type'

# Validate widget data
python3 plugins/50_my_plugin.py | jq '.widgets[].data'
```

### Common Issues

**Issue: Plugin doesn't appear in app**

- Check file is executable: `ls -la plugins/`
- Verify JSON is valid: `plugin.py | jq .`
- Check agent logs: `journalctl -u relay-agent -f`

**Issue: "Unknown" widget type**

- Check spelling of `type` field
- Verify widget has `data` object
- See `json_output_format.md` for valid types

**Issue: Plugin times out**

- Reduce command timeout (5 seconds max)
- Remove slow API calls
- Cache expensive operations

**Issue: Permission denied**

- Run as agent user: `sudo su - relay`
- Check file permissions: `ls -la plugins/`
- Verify agent user has access to commands

## Plugin Naming Convention

Use numeric prefixes to control execution order:

- `00-09`: Core system metrics (CPU, RAM, Disk)
- `10-19`: Storage and filesystems
- `20-29`: Containers and virtualization (Docker, LXC)
- `30-39`: Process managers (PM2, systemd services)
- `40-49`: Network metrics and monitoring
- `50-59`: Custom services and applications
- `60-69`: Package managers and updates
- `70-79`: Security and backups
- `80-89`: Logs and monitoring
- `90-99`: Administrative tasks

**Examples:**

- `00_system_vitals.py` - Core system metrics
- `25_kubernetes_pods.py` - Container orchestration
- `55_website_monitor.sh` - Custom service check
- `70_security_updates.py` - Security monitoring

## Security Guidelines

### Safe Operations

✅ Read system metrics (CPU, RAM, disk)  
✅ Check service status  
✅ Query APIs with timeout  
✅ List processes/containers  
✅ Execute safe commands with timeouts

### Unsafe Operations

❌ Write to system files  
❌ Modify configurations  
❌ Network requests without timeout  
❌ Execute arbitrary user input  
❌ Read sensitive files (passwords, keys)  
❌ Run commands as root without sudo

### Command Execution Safety

```python
# ✅ Safe - Specific command with timeout
subprocess.run(
    ["systemctl", "status", "nginx"],
    capture_output=True,
    timeout=5
)

# ❌ Unsafe - Shell injection risk
os.system(f"systemctl status {service_name}")

# ❌ Unsafe - No timeout
subprocess.run(["curl", "http://slow-api.com"])
```

## Testing Checklist

Before deploying your plugin:

- [ ] Plugin outputs valid JSON
- [ ] All widget types are correct
- [ ] Status values are "success", "warning", or "error"
- [ ] Numeric values use correct data types (not strings)
- [ ] Commands have timeouts (5 seconds max)
- [ ] Error handling outputs valid JSON
- [ ] Plugin completes in < 10 seconds
- [ ] File is executable (`chmod +x`)
- [ ] No hardcoded passwords or secrets
- [ ] Agent user has necessary permissions
- [ ] Tested manually: `python3 plugin.py | jq .`
- [ ] Tested with agent: `systemctl status relay-agent`
- [ ] Verified in app: Widgets display correctly

## Example Plugin Gallery

See these examples in the `plugins/` directory:

1. **00_system_vitals.py** - CPU, RAM, uptime with historical sparkline graphs (Python + psutil)
   - Uses `metric_chart` type for CPU and RAM to show trends
   - Backend automatically collects metrics every second
   - Last 60 data points displayed as smooth line graphs
2. **20_docker_containers.py** - Docker status (Python + subprocess)
3. **30_pm2_processes.js** - PM2 process manager (Node.js + execSync)
4. **40_network_traffic.py** - Network I/O stats (Python + psutil)

Each plugin demonstrates best practices for that type of monitoring.

## New Features: Historical Data & Graphs

### Sparkline Charts (metric_chart)

The agent now supports historical data visualization with sparkline charts. This gives users true observability - seeing trends, not just current values.

**How It Works:**

1. **Backend Metrics Collection**: The agent runs `metricsCollector.js` which collects CPU and memory metrics every second using Python/psutil
2. **Rolling Window**: Keeps the last 60 data points in memory
3. **API Response**: Includes `history` object with arrays of historical values
4. **Frontend Rendering**: Uses `fl_chart` package to render smooth line graphs

**Using metric_chart in Your Plugin:**

```python
{
    "type": "metric_chart",
    "data": {
        "label": "CPU Load",
        "value": f"{cpu_percent:.1f}%",
        "status": cpu_status,
        "metricType": "cpu"  # Maps to history.cpu array
    }
}
```

**Supported metricType values:**
- `"cpu"` - CPU percentage history
- `"memory"` - Memory percentage history
- Custom types (requires backend modification)

**When to Use:**
- ✅ Use `metric_chart` for metrics that change over time (CPU, RAM, network)
- ❌ Use `metric_card` for static values (uptime, version, status)

## Dashboard Customization

### Widget Reordering

Users can customize their dashboard layout by dragging and dropping widgets:

**User Experience:**
1. Long-press any widget card
2. Drag to desired position in the 2-column grid
3. Release to drop
4. Order is automatically saved to device storage
5. Persists across app restarts

**Implementation Details:**
- Uses `reorderable_grid_view` package
- Widget IDs: `type + label + index`
- Saved to `SharedPreferences` as string list
- Applied on dashboard load

**Plugin Considerations:**
- Widgets maintain their `gridWidth` during reordering
- Full-width widgets (`gridWidth: 2`) can be moved independently
- Order applies to all widgets across all plugins combined

## Getting Help

If you're stuck:

1. Review `json_output_format.md` for exact JSON structure
2. Check `plugin_system.md` for security guidelines
3. Test your plugin manually before installing
4. Review agent logs for error messages
5. Verify the agent user has necessary permissions

Remember: Start simple, test thoroughly, and never install untrusted plugins.
