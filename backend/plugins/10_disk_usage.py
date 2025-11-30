#!/usr/bin/env python3
import json
import shutil
import subprocess

try:
    disk = shutil.disk_usage('/')
    total_gb = disk.total / (1024 ** 3)
    used_gb = disk.used / (1024 ** 3)
    percent = (disk.used / disk.total) * 100
    
    if percent < 70:
        status = "success"
    elif percent < 90:
        status = "warning"
    else:
        status = "error"
    
    io_status = "success"
    io_label = "Healthy"
    
    try:
        result = subprocess.run(['iostat', '-c', '1', '2'], 
                              capture_output=True, text=True, timeout=3)
        if result.returncode == 0:
            lines = result.stdout.strip().split('\n')
            if len(lines) >= 4:
                io_wait = float(lines[3].split()[3])
                if io_wait > 30:
                    io_status = "error"
                    io_label = "Slow"
                elif io_wait > 10:
                    io_status = "warning"
                    io_label = "Slow"
    except:
        pass
    
    result = {
        "title": "Disk Usage",
        "widgets": [
            {
                "type": "metric_card",
                "data": {
                    "label": "Disk Usage",
                    "value": f"{percent:.0f}%",
                    "status": status
                },
                "gridWidth": 2
            },
            {
                "type": "metric_card",
                "data": {
                    "label": "IO Health",
                    "value": io_label,
                    "status": io_status
                }
            }
        ]
    }
    
    print(json.dumps(result))
    
except Exception as e:
    error_result = {
        "title": "Disk Usage",
        "error": str(e),
        "widgets": []
    }
    print(json.dumps(error_result))
