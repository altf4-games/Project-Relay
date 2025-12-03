#!/usr/bin/env python3
import json
import os

try:
    # Check if running as root (UID 0)
    is_root = os.geteuid() == 0
    
    if is_root:
        result = {
            "title": "System Update",
            "widgets": [
                {
                    "type": "action_button",
                    "data": {
                        "label": "Update & Upgrade System",
                        "command": "DEBIAN_FRONTEND=noninteractive apt-get update && DEBIAN_FRONTEND=noninteractive apt-get upgrade -y"
                    },
                    "gridWidth": 2
                }
            ]
        }
    else:
        # Don't show the plugin if not root
        result = {
            "title": "System Update",
            "widgets": []
        }
    
    print(json.dumps(result))
    
except Exception as e:
    error_result = {
        "title": "System Update",
        "error": str(e),
        "widgets": []
    }
    print(json.dumps(error_result))
