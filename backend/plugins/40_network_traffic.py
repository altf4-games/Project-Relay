#!/usr/bin/env python3
import json
import subprocess
import time

def get_default_interface():
    try:
        result = subprocess.run(['ip', 'route'], capture_output=True, text=True)
        for line in result.stdout.split('\n'):
            if 'default' in line:
                parts = line.split()
                if 'dev' in parts:
                    return parts[parts.index('dev') + 1]
    except:
        pass
    return 'eth0'

def get_bytes(interface):
    try:
        with open(f'/sys/class/net/{interface}/statistics/rx_bytes') as f:
            rx = int(f.read().strip())
        with open(f'/sys/class/net/{interface}/statistics/tx_bytes') as f:
            tx = int(f.read().strip())
        return rx, tx
    except:
        return 0, 0

def format_bytes(bytes_val):
    if bytes_val < 1024:
        return f"{bytes_val} B/s"
    elif bytes_val < 1048576:
        return f"{bytes_val // 1024} KB/s"
    else:
        return f"{bytes_val // 1048576} MB/s"

try:
    interface = get_default_interface()
    rx1, tx1 = get_bytes(interface)
    time.sleep(1)
    rx2, tx2 = get_bytes(interface)
    
    rx_rate = rx2 - rx1
    tx_rate = tx2 - tx1
    
    rx_status = "warning" if rx_rate > 104857600 else "success"
    tx_status = "warning" if tx_rate > 104857600 else "success"
    
    result = {
        "title": "Network Traffic",
        "widgets": [
            {
                "type": "metric_card",
                "data": {
                    "label": "Inbound",
                    "value": format_bytes(rx_rate),
                    "status": rx_status
                }
            },
            {
                "type": "metric_card",
                "data": {
                    "label": "Outbound",
                    "value": format_bytes(tx_rate),
                    "status": tx_status
                }
            }
        ]
    }
    
    print(json.dumps(result))
    
except Exception as e:
    error_result = {
        "title": "Network Traffic",
        "error": str(e),
        "widgets": []
    }
    print(json.dumps(error_result))
