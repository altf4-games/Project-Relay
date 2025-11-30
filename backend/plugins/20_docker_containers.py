#!/usr/bin/env python3
import json
import subprocess

try:
    result = subprocess.run(['docker', 'ps', '-a', '--format', '{{json .}}'], 
                          capture_output=True, text=True, timeout=5)
    
    if result.returncode != 0:
        raise Exception("Docker not available or not running")
    
    containers = []
    if result.stdout.strip():
        for line in result.stdout.strip().split('\n'):
            try:
                containers.append(json.loads(line))
            except:
                pass
    
    total_containers = len(containers)
    running_containers = sum(1 for c in containers if c.get('State') == 'running')
    
    status = "success" if running_containers == total_containers else "warning"
    if running_containers == 0 and total_containers > 0:
        status = "error"
    
    output = {
        "title": "Docker Containers",
        "widgets": [
            {
                "type": "metric_card",
                "data": {
                    "label": "Containers Running",
                    "value": f"{running_containers}/{total_containers}",
                    "status": status
                }
            }
        ]
    }
    
    print(json.dumps(output))
    
except Exception as e:
    error_result = {
        "title": "Docker Containers",
        "error": str(e),
        "widgets": []
    }
    print(json.dumps(error_result))
