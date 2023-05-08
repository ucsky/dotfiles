#!/usr/bin/env python3
with open('docker-checksize.bash', 'r') as f:
    lines = f.readlines()

description = ''
found_description = False
for line in lines:
    if line.startswith('# Description:'):
        description += line.lstrip('# Description:').strip() + ' '
        found_description = True
    elif found_description:
        if line.startswith('# Usage:'):
            break
        description += line.lstrip('#').strip() + ' '

description = description.strip()
print(description)
