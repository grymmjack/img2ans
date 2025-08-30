#!/usr/bin/env python3
"""
Align the equals signs and comments in EMOJI-CONSTANTS.BAS
"""

import re

def align_constants(content):
    lines = content.split('\n')
    aligned_lines = []
    
    for line in lines:
        # Skip empty lines or lines that don't start with CONST
        if not line.strip() or not line.strip().startswith('CONST '):
            aligned_lines.append(line)
            continue
            
        # Parse the line: CONST NAME = VALUE ' comment
        match = re.match(r'^(CONST\s+\w+)\s*=\s*([^\']+)\s*\'?\s*(.*?)\"?$', line.strip())
        if match:
            const_name = match.group(1)
            value = match.group(2).strip()
            comment = match.group(3).strip()
            
            # Clean up any trailing quotes from comment
            comment = re.sub(r'^[\'"\s]*', '', comment)
            comment = re.sub(r'[\'"\s]*$', '', comment)
            
            # Format with proper alignment
            # Pad constant name to 49 chars, value to 12 chars
            aligned_line = f"{const_name:<49} = {value:<12} ' {comment}"
            aligned_lines.append(aligned_line)
        else:
            # If line doesn't match pattern, keep as-is
            aligned_lines.append(line)
    
    return '\n'.join(aligned_lines)

# Read the file
with open(r'c:\Users\grymmjack\git\img2ans\EMOJI-CONSTANTS.BAS', 'r', encoding='utf-8') as f:
    content = f.read()

# Align the content
aligned_content = align_constants(content)

# Write back to file
with open(r'c:\Users\grymmjack\git\img2ans\EMOJI-CONSTANTS.BAS', 'w', encoding='utf-8') as f:
    f.write(aligned_content)

print("EMOJI-CONSTANTS.BAS has been aligned!")
