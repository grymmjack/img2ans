#!/usr/bin/env python3
"""Extract frames from an animated GIF to analyze the issue"""

from PIL import Image
import sys
import os

def extract_frames(gif_path):
    """Extract all frames from a GIF and save them with frame numbers"""
    img = Image.open(gif_path)
    
    output_dir = os.path.dirname(gif_path)
    base_name = os.path.splitext(os.path.basename(gif_path))[0]
    frames_dir = os.path.join(output_dir, f"{base_name}_frames")
    
    os.makedirs(frames_dir, exist_ok=True)
    
    frame_num = 0
    try:
        while True:
            # Save current frame
            frame_path = os.path.join(frames_dir, f"frame_{frame_num:03d}.png")
            img.save(frame_path)
            print(f"Saved frame {frame_num}")
            
            frame_num += 1
            img.seek(frame_num)
    except EOFError:
        pass
    
    print(f"\nExtracted {frame_num} frames to: {frames_dir}")
    return frame_num

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python3 extract_gif_frames.py <path_to_gif>")
        sys.exit(1)
    
    gif_path = sys.argv[1]
    if not os.path.exists(gif_path):
        print(f"Error: File not found: {gif_path}")
        sys.exit(1)
    
    extract_frames(gif_path)
