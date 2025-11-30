#!/usr/bin/env python3
import json
import psutil
import time

try:
    cpu_percent = psutil.cpu_percent(interval=1)
    memory = psutil.virtual_memory()
    uptime_seconds = int(psutil.boot_time())
    current_time = int(time.time())
    uptime = current_time - uptime_seconds
    
    days = uptime // 86400
    hours = (uptime % 86400) // 3600
    minutes = (uptime % 3600) // 60
    
    uptime_str = f"{days}d {hours}h {minutes}m"
    
    memory_used_gb = memory.used / (1024 ** 3)
    memory_total_gb = memory.total / (1024 ** 3)
    memory_str = f"{memory_used_gb:.1f}GB / {memory_total_gb:.1f}GB"
    
    cpu_status = "success" if cpu_percent < 70 else "warning" if cpu_percent < 90 else "error"
    memory_status = "success" if memory.percent < 70 else "warning" if memory.percent < 90 else "error"
    
    result = {
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
                "type": "metric_card",
                "data": {
                    "label": "RAM Usage",
                    "value": memory_str,
                    "status": memory_status
                }
            },
            {
                "type": "metric_card",
                "data": {
                    "label": "Uptime",
                    "value": uptime_str,
                    "status": "success"
                }
            },
            {
                "type": "progress_bar",
                "data": {
                    "label": "Memory",
                    "value": memory.percent,
                    "max": 100
                },
                "gridWidth": 2
            }
        ]
    }
    
    print(json.dumps(result))
    
except Exception as e:
    error_result = {
        "title": "System Vitals",
        "error": str(e),
        "widgets": []
    }
    print(json.dumps(error_result))
