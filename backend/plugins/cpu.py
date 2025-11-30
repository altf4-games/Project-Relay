#!/usr/bin/env python3
import psutil
import json

def get_cpu_status():
    cpu_percent = psutil.cpu_percent(interval=1)
    
    if cpu_percent < 50:
        status = 'success'
    elif cpu_percent < 80:
        status = 'warning'
    else:
        status = 'error'
    
    return {
        'title': 'CPU',
        'widgets': [
            {
                'type': 'metric_card',
                'data': {
                    'label': 'Usage',
                    'value': f'{cpu_percent}%',
                    'status': status
                }
            }
        ]
    }

if __name__ == '__main__':
    result = get_cpu_status()
    print(json.dumps(result))
