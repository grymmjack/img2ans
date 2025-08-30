import re
import requests
import time
import sys

# 1. Download the Unicode Full Emoji List (v16.0)
url = "https://unicode.org/emoji/charts/full-emoji-list.html"
print("🌐 Downloading emoji data from Unicode.org...")
start_time = time.time()

try:
    resp = requests.get(url, timeout=30)
    download_time = time.time() - start_time
    print(f"✅ Downloaded {len(resp.content):,} bytes in {download_time:.1f} seconds")
except Exception as e:
    print(f"❌ Download failed: {e}")
    sys.exit(1)

resp.encoding = 'utf-8'
lines = resp.text.split('\n')

print(f"📄 Processing {len(lines):,} lines of HTML...")
print("🔍 Looking for emoji data...")

# 2. Process line by line to avoid regex timeouts
seen = set()
current_glyph = None
current_code = None
current_name = None
emojis_found = 0
progress_interval = max(1, len(lines) // 20)  # Show progress 20 times

process_start = time.time()

for i, line in enumerate(lines):
    # Show progress every 5% of lines processed
    if i % progress_interval == 0 and i > 0:
        percent = (i / len(lines)) * 100
        elapsed = time.time() - process_start
        rate = i / elapsed if elapsed > 0 else 0
        eta = (len(lines) - i) / rate if rate > 0 else 0
        print(f"⏳ Progress: {percent:.1f}% ({i:,}/{len(lines):,} lines) | {rate:.0f} lines/sec | ETA: {eta:.0f}s | Found: {emojis_found} emojis", end='\r')
    
    # Look for emoji character
    if "class='rchars'" in line:
        glyph_match = re.search(r"<td class='rchars'>(.*?)</td>", line)
        if glyph_match:
            current_glyph = glyph_match.group(1).strip()
    
    # Look for Unicode code point
    elif "class='code'" in line:
        code_match = re.search(r"U\+([0-9A-F]{4,6})", line)
        if code_match:
            current_code = code_match.group(1)
    
    # Look for emoji name
    elif "class='name'" in line:
        name_match = re.search(r"<td class='name'>(.*?)</td>", line)
        if name_match:
            current_name = name_match.group(1).strip()
            
            # If we have all three pieces, output the constant
            if current_glyph and current_code and current_name:
                # Avoid duplicates
                key = (current_code, current_name)
                if key not in seen:
                    seen.add(key)
                    emojis_found += 1
                    
                    # Create sanitized constant name
                    cname = re.sub(r'[^A-Z0-9]+', '_', current_name.upper())
                    cname = re.sub(r'_+', '_', cname).strip('_')
                    if cname and len(cname) <= 50:
                        print(f"\nCONST EM_{cname} = &H{current_code}  ' {current_glyph}")
                
                # Reset for next emoji
                current_glyph = None
                current_code = None
                current_name = None

total_time = time.time() - start_time
print(f"\n\n✨ Completed! Found {emojis_found} unique emojis in {total_time:.1f} seconds")
