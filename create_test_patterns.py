# Sample MacPaint Pattern Creation Script
# Creates test patterns in the patterns directory

import numpy as np
from PIL import Image
import os

# Create patterns directory if it doesn't exist
patterns_dir = "resources/patterns"
os.makedirs(patterns_dir, exist_ok=True)

def create_pattern(name, pattern_func, size=16):
    """Create a pattern and save as BMP"""
    pattern = np.zeros((size, size), dtype=np.uint8)
    
    for y in range(size):
        for x in range(size):
            if pattern_func(x, y, size):
                pattern[y, x] = 255  # White
            else:
                pattern[y, x] = 0    # Black
    
    # Create PIL image and save
    img = Image.fromarray(pattern, mode='L')
    img.save(f"{patterns_dir}/{name}.bmp")
    print(f"Created {name}.bmp ({size}x{size})")

# MacPaint-style patterns
def dots(x, y, size):
    return (x % 4 == 1) and (y % 4 == 1)

def diagonal_lines(x, y, size):
    return (x + y) % 4 < 2

def crosshatch(x, y, size):
    return (x % 4 < 2) or (y % 4 < 2)

def brick(x, y, size):
    if y % 8 < 4:
        return x % 8 < 1
    else:
        return (x + 4) % 8 < 1

def checkerboard(x, y, size):
    return (x // 2 + y // 2) % 2 == 0

def vertical_lines(x, y, size):
    return x % 3 == 0

def horizontal_lines(x, y, size):
    return y % 3 == 0

def mesh(x, y, size):
    return (x % 4 == 0) or (y % 4 == 0)

# Create all patterns
patterns = [
    ("macpaint_dots", dots),
    ("macpaint_diagonal", diagonal_lines),
    ("macpaint_crosshatch", crosshatch),
    ("macpaint_brick", brick),
    ("macpaint_checkerboard", checkerboard),
    ("macpaint_vertical", vertical_lines),
    ("macpaint_horizontal", horizontal_lines),
    ("macpaint_mesh", mesh)
]

print("Creating MacPaint-style test patterns...")
for name, func in patterns:
    create_pattern(name, func, 16)

print(f"\nAll patterns created in {patterns_dir}/")
print("Ready to test bitmap pattern loading in IMG2PAL!")
