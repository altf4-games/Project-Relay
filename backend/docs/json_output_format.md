# Relay Plugin JSON Output Format

## Overview

Every Relay plugin must output a single JSON object to stdout. This document details the exact format, available widget types, and how the app parses this data.

## Root JSON Structure

```json
{
  "title": "Section Title",
  "widgets": [
    {
      /* widget object */
    },
    {
      /* widget object */
    }
  ]
}
```

### Root Fields

- **title** (string, required): The section heading displayed in the app. Keep it short (2-4 words).
- **widgets** (array, required): Array of widget objects. Can be empty `[]` if no data.
- **error** (string, optional): Error message if plugin fails. Display instead of widgets.

### Error Output Example

```json
{
  "title": "CPU Usage",
  "error": "psutil module not found",
  "widgets": []
}
```

## Widget Types

### 1. metric_card

Displays a single labeled metric with a status indicator (no historical graph).

**JSON Structure:**

```json
{
  "type": "metric_card",
  "data": {
    "label": "CPU Load",
    "value": "45%",
    "status": "success"
  }
}
```

**Fields:**

- `type`: Must be `"metric_card"`
- `data.label` (string, required): Metric name (e.g., "CPU Load", "Memory")
- `data.value` (string, required): Metric value (e.g., "45%", "8.2 GB", "125ms")
- `data.status` (string, required): Status indicator
  - `"success"` - Green indicator (healthy)
  - `"warning"` - Yellow indicator (needs attention)
  - `"error"` - Red indicator (critical)

**Example Use Cases:**

- Uptime
- Service status (running/stopped)
- Static metrics without trends

**Visual Rendering:**

```
┌──────────────────────┐
│ ● CPU Load           │
│   45%                │
└──────────────────────┘
```

### 2. metric_chart

Displays a labeled metric with a status indicator AND a sparkline graph showing historical trend.

**JSON Structure:**

```json
{
  "type": "metric_chart",
  "data": {
    "label": "CPU Load",
    "value": "45%",
    "status": "success",
    "metricType": "cpu"
  }
}
```

**Fields:**

- `type`: Must be `"metric_chart"`
- `data.label` (string, required): Metric name
- `data.value` (string, required): Current metric value
- `data.status` (string, required): Status indicator (success/warning/error)
- `data.metricType` (string, required): Type identifier for history lookup
  - `"cpu"` - Maps to CPU history from backend
  - `"memory"` - Maps to memory history from backend
  - Other custom types if backend provides them

**Backend Requirements:**

The backend must provide historical data in the API response:

```json
{
  "status": "alive",
  "data": [...],
  "history": {
    "cpu": [12.5, 15.2, 18.1, ..., 45.0],
    "memory": [25.0, 26.5, 28.0, ..., 42.3]
  }
}
```

**Example Use Cases:**

- CPU load percentage with trend
- Memory usage with trend
- Network throughput over time
- Any metric where seeing the trend is valuable

**Visual Rendering:**

```
┌──────────────────────┐
│ ● CPU Load           │
│   45%                │
│   ╱╲  ╱╲             │
│  ╱  ╲╱  ╲╱╲          │
└──────────────────────┘
```

### 3. progress_bar

Displays a progress bar with percentage or value/max.

**JSON Structure:**

```json
{
  "type": "progress_bar",
  "data": {
    "label": "Memory Usage",
    "value": 6.4,
    "max": 16.0
  },
  "gridWidth": 2
}
```

**Fields:**

- `type`: Must be `"progress_bar"`
- `data.label` (string, required): Progress bar label
- `data.value` (number, required): Current value
- `data.max` (number, required): Maximum value
- `gridWidth` (number, optional): Grid columns to span (1 or 2, default: 1)

**Calculation:**

- Percentage = `(value / max) * 100`
- Bar color changes based on percentage:
  - < 70% - Green (primary accent color)
  - 70-89% - Yellow
  - ≥ 90% - Red

**Example Use Cases:**

- Disk usage (GB used / GB total)
- Memory usage (GB used / GB total)
- CPU usage (percent / 100)
- Download progress

**Visual Rendering:**

```
┌────────────────────────────────────┐
│ Memory Usage                  40%  │
│ ████████░░░░░░░░░░░░░░░░░░░░░░░░   │
└────────────────────────────────────┘
```

### 3. progress_bar

Displays a button that executes an SSH command when pressed.

**JSON Structure:**

```json
{
  "type": "action_button",
  "data": {
    "label": "Restart Nginx",
    "command": "sudo systemctl restart nginx"
  }
}
```

**Fields:**

- `type`: Must be `"action_button"`
- `data.label` (string, required): Button text (keep short, 2-4 words)
- `data.command` (string, required): SSH command to execute

**Security Notes:**

- Commands run as the SSH user (not root)
- Use `sudo` only if user has passwordless sudo access
- Commands have a 10-second timeout
- Output is captured and displayed in app

**Example Use Cases:**

- Restart services (`systemctl restart service`)
- Reload configurations (`pm2 reload all`)
- Clear caches (`redis-cli FLUSHALL`)
- Trigger deployments

**Visual Rendering:**

```
┌──────────────────────┐
│  Restart Nginx       │  ← Tappable button
└──────────────────────┘
```

## Widget Reordering (Drag & Drop)

The Relay app supports drag-and-drop reordering of widgets on the dashboard. Users can long-press and drag any widget to rearrange them. The order is persisted to device storage and restored on app restart.

**Implementation:**
- Uses `ReorderableGridView` for 2-column layout
- Widget order saved to `SharedPreferences`
- Each widget identified by `type + label + index`

**User Experience:**
- Long-press any widget to enter drag mode
- Drag to desired position
- Release to drop
- Order automatically saved

## Grid Layout System

**gridWidth: 1** (default)

- Takes up 1 column (half width)
- Two widgets per row

**gridWidth: 2**

- Takes up 2 columns (full width)
- One widget per row

**Example:**

```json
{
  "title": "System",
  "widgets": [
    {
      "type": "metric_card",
      "data": { "label": "CPU", "value": "45%", "status": "success" }
    },
    {
      "type": "metric_card",
      "data": { "label": "RAM", "value": "8GB", "status": "success" }
    },
    {
      "type": "progress_bar",
      "data": { "label": "Disk", "value": 120, "max": 500 },
      "gridWidth": 2
    }
  ]
}
```

**Layout:**

```
┌─────────────┬─────────────┐
│ CPU: 45%    │ RAM: 8GB    │
├─────────────┴─────────────┤
│ Disk: [████░░░░] 24%      │
└───────────────────────────┘
```

## Complete Plugin Examples

### Example 1: Python - System Metrics

```python
#!/usr/bin/env python3
import json
import psutil

try:
    cpu_percent = psutil.cpu_percent(interval=1)
    memory = psutil.virtual_memory()

    # Determine CPU status
    if cpu_percent < 70:
        cpu_status = "success"
    elif cpu_percent < 90:
        cpu_status = "warning"
    else:
        cpu_status = "error"

    output = {
        "title": "System Vitals",
        "widgets": [
            {
                "type": "metric_card",
                "data": {
                    "label": "CPU Load",
                    "value": f"{cpu_percent:.1f}%",
                    "status": cpu_status
                }
            },
            {
                "type": "progress_bar",
                "data": {
                    "label": "Memory",
                    "value": memory.used / (1024**3),  # Convert to GB
                    "max": memory.total / (1024**3)
                },
                "gridWidth": 2
            }
        ]
    }

    print(json.dumps(output))

except Exception as e:
    print(json.dumps({
        "title": "System Vitals",
        "error": str(e),
        "widgets": []
    }))
```

### Example 2: Shell Script - Docker Status

```bash
#!/bin/bash

# Check if Docker is running
if ! command -v docker &> /dev/null; then
    echo '{"title":"Docker","error":"Docker not installed","widgets":[]}'
    exit 0
fi

# Count running containers
RUNNING=$(docker ps -q | wc -l)
TOTAL=$(docker ps -aq | wc -l)

# Determine status
if [ "$RUNNING" -eq 0 ]; then
    STATUS="error"
elif [ "$RUNNING" -eq "$TOTAL" ]; then
    STATUS="success"
else
    STATUS="warning"
fi

# Output JSON
cat <<EOF
{
  "title": "Docker",
  "widgets": [
    {
      "type": "metric_card",
      "data": {
        "label": "Containers",
        "value": "$RUNNING / $TOTAL",
        "status": "$STATUS"
      }
    },
    {
      "type": "action_button",
      "data": {
        "label": "Restart All",
        "command": "docker restart \$(docker ps -q)"
      }
    }
  ]
}
EOF
```

### Example 3: Node.js - PM2 Processes

```javascript
#!/usr/bin/env node

const { execSync } = require("child_process");

try {
  const output = execSync("pm2 jlist", { encoding: "utf-8", timeout: 5000 });
  const processes = JSON.parse(output);

  const running = processes.filter((p) => p.pm2_env.status === "online").length;
  const total = processes.length;

  const status =
    running === total ? "success" : running === 0 ? "error" : "warning";

  const result = {
    title: "PM2 Processes",
    widgets: [
      {
        type: "metric_card",
        data: {
          label: "Online",
          value: `${running} / ${total}`,
          status: status,
        },
      },
      {
        type: "action_button",
        data: {
          label: "Reload All",
          command: "bash -c 'source ~/.bashrc 2>/dev/null; npx pm2 reload all'",
        },
      },
    ],
  };

  console.log(JSON.stringify(result));
} catch (error) {
  console.log(
    JSON.stringify({
      title: "PM2 Processes",
      error: error.message,
      widgets: [],
    })
  );
}
```

## Data Type Guidelines

### String Values

- **Short labels**: 1-3 words (e.g., "CPU", "Memory Used", "Uptime")
- **Values with units**: Include the unit (e.g., "45%", "8.2 GB", "125 ms")
- **Time durations**: Use human-readable format (e.g., "2d 5h", "10 minutes")
- **Status text**: Keep concise (e.g., "Running", "Stopped", "Healthy")

### Numeric Values

- Use **integers** for counts (e.g., `5` containers, `12` processes)
- Use **floats** for measurements (e.g., `6.4` GB, `45.8` percent)
- Always provide both `value` and `max` for progress bars
- Don't include units in numbers - add them in labels instead

### Status Values

Only three valid status strings:

- `"success"` - Everything normal (green indicator)
- `"warning"` - Needs attention (yellow indicator)
- `"error"` - Critical issue (red indicator)

**Status Decision Logic:**

```python
def get_status(value, warning_threshold, critical_threshold):
    if value >= critical_threshold:
        return "error"
    elif value >= warning_threshold:
        return "warning"
    else:
        return "success"

# Example: CPU usage
status = get_status(cpu_percent, warning_threshold=70, critical_threshold=90)
```

## Output Best Practices

### 1. Always Output Valid JSON

```python
# ✅ Good - Valid JSON
print(json.dumps(output))

# ❌ Bad - Invalid JSON
print(output)  # Python dict, not JSON string
```

### 2. Handle Errors Gracefully

```python
try:
    # Plugin logic here
    output = {"title": "My Plugin", "widgets": [...]}
    print(json.dumps(output))
except Exception as e:
    # Always output valid JSON, even on error
    print(json.dumps({
        "title": "My Plugin",
        "error": str(e),
        "widgets": []
    }))
```

### 3. Use Descriptive Labels

```python
# ✅ Good - Clear labels
"label": "CPU Load"
"label": "Memory Used"
"label": "Disk / (root)"

# ❌ Bad - Ambiguous labels
"label": "Load"
"label": "Mem"
"label": "Space"
```

### 4. Format Values Consistently

```python
# ✅ Good - Consistent formatting
"value": f"{cpu_percent:.1f}%"  # "45.8%"
"value": f"{memory_gb:.2f} GB"  # "8.23 GB"

# ❌ Bad - Inconsistent formatting
"value": str(cpu_percent)  # "45.83333333"
"value": f"{memory_gb}GB"  # "8.234567GB" (no space)
```

### 5. Limit Widget Count

```python
# ✅ Good - 3-5 widgets per plugin
widgets = [
    metric_card_1,
    metric_card_2,
    progress_bar,
    action_button
]

# ❌ Bad - Too many widgets
widgets = [widget1, widget2, ..., widget15]  # Cluttered UI
```

## Testing Your JSON Output

### 1. Validate JSON Syntax

```bash
# Test plugin output
python3 my_plugin.py | jq .

# Should pretty-print JSON without errors
```

### 2. Check Required Fields

```bash
# Verify all required fields exist
python3 my_plugin.py | jq '.title, .widgets[].type, .widgets[].data'
```

### 3. Test Error Handling

```bash
# Simulate error conditions
chmod -x /usr/bin/docker  # Remove Docker access
python3 docker_plugin.py | jq .
# Should output error JSON, not crash
```

## Common Mistakes

### 1. Missing Required Fields

```json
// ❌ Bad - Missing status field
{
  "type": "metric_card",
  "data": {
    "label": "CPU",
    "value": "45%"
    // Missing: "status"
  }
}

// ✅ Good - All required fields
{
  "type": "metric_card",
  "data": {
    "label": "CPU",
    "value": "45%",
    "status": "success"
  }
}
```

### 2. Invalid Status Values

```json
// ❌ Bad - Invalid status
"status": "green"  // Not a valid status

// ✅ Good - Valid status
"status": "success"
```

### 3. Wrong Data Types

```json
// ❌ Bad - String instead of number
{
  "type": "progress_bar",
  "data": {
    "value": "6.4",  // Should be number
    "max": "16.0"    // Should be number
  }
}

// ✅ Good - Correct data types
{
  "type": "progress_bar",
  "data": {
    "value": 6.4,
    "max": 16.0
  }
}
```

### 4. Malformed JSON

```bash
# ❌ Bad - Multiple JSON objects
echo '{"title":"One","widgets":[]}'
echo '{"title":"Two","widgets":[]}'

# ✅ Good - Single JSON object
echo '{"title":"Combined","widgets":[...]}'
```

## Parser Behavior

The Relay Agent parser (`server.js`):

1. **Executes plugin** with 10-second timeout
2. **Captures stdout** only (stderr ignored)
3. **Parses JSON** from stdout
4. **Validates structure**:
   - Checks for `title` field
   - Checks for `widgets` array
   - Validates each widget has `type` and `data`
5. **Handles errors**:
   - If JSON invalid: Skip plugin, log error
   - If timeout: Skip plugin, log timeout
   - If widget malformed: Set `type: "unknown"`

**Unknown Widget Fallback:**

```json
// If widget is malformed, parser converts to:
{
  "type": "unknown",
  "data": {}
}
```

The app will skip rendering unknown widgets, so always test your JSON format.

## Quick Reference

### Minimal Valid Output

```json
{
  "title": "Plugin Name",
  "widgets": []
}
```

### Single Metric Card

```json
{
  "title": "CPU",
  "widgets": [
    {
      "type": "metric_card",
      "data": {
        "label": "Load",
        "value": "45%",
        "status": "success"
      }
    }
  ]
}
```

### Progress Bar (Full Width)

```json
{
  "title": "Disk",
  "widgets": [
    {
      "type": "progress_bar",
      "data": {
        "label": "/ (root)",
        "value": 120,
        "max": 500
      },
      "gridWidth": 2
    }
  ]
}
```

### Action Button

```json
{
  "title": "Actions",
  "widgets": [
    {
      "type": "action_button",
      "data": {
        "label": "Restart",
        "command": "sudo systemctl restart nginx"
      }
    }
  ]
}
```

### Error Output

```json
{
  "title": "Failed Plugin",
  "error": "Service unavailable",
  "widgets": []
}
```
