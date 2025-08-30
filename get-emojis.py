import re
import requests
import time
import sys

def try_unicode_org():
    """Try to get emoji data from Unicode.org"""
    print("🌐 Trying Unicode.org (this may be slow)...")
    url = "https://unicode.org/emoji/charts/full-emoji-list.html"
    try:
        resp = requests.get(url, timeout=60, stream=True)
        print(f"✅ Connected! Status: {resp.status_code}")
        
        # Download in chunks to show progress
        content = b""
        chunk_size = 8192
        for i, chunk in enumerate(resp.iter_content(chunk_size=chunk_size)):
            if chunk:
                content += chunk
                if i % 100 == 0:  # Every ~800KB
                    print(f"📥 Downloaded {len(content):,} bytes...", end='\r')
        
        print(f"\n✅ Download complete: {len(content):,} bytes")
        return content.decode('utf-8')
        
    except Exception as e:
        print(f"❌ Unicode.org failed: {e}")
        return None

def try_github_emoji_data():
    """Try to get emoji data from GitHub's emoji API or similar"""
    print("🐙 Trying GitHub emoji API...")
    try:
        url = "https://api.github.com/emojis"
        resp = requests.get(url, timeout=30)
        if resp.status_code == 200:
            print(f"✅ GitHub API success: {len(resp.json())} emojis")
            return resp.json()
    except Exception as e:
        print(f"❌ GitHub API failed: {e}")
    return None

def try_openmoji_data():
    """Try OpenMoji dataset"""
    print("� Trying OpenMoji dataset...")
    try:
        url = "https://raw.githubusercontent.com/hfg-gmuend/openmoji/master/data/openmoji.csv"
        resp = requests.get(url, timeout=30)
        if resp.status_code == 200:
            print(f"✅ OpenMoji success: {len(resp.text)} bytes")
            return resp.text
    except Exception as e:
        print(f"❌ OpenMoji failed: {e}")
    return None

def process_github_emojis(emoji_data):
    """Process GitHub emoji data"""
    print("🔍 Processing GitHub emoji data...")
    seen = set()
    count = 0
    
    for name, url in emoji_data.items():
        # Extract unicode from name if possible
        clean_name = re.sub(r'[^A-Z0-9]+', '_', name.upper())
        clean_name = re.sub(r'_+', '_', clean_name).strip('_')
        
        if clean_name and len(clean_name) <= 50:
            if clean_name not in seen:
                seen.add(clean_name)
                count += 1
                # Use a placeholder hex value - GitHub API doesn't provide Unicode codepoints
                print(f"' GitHub emoji: {name}")
                print(f"CONST EM_{clean_name} = &H1F600  ' {name}")
    
    return count

def process_openmoji_csv(csv_data):
    """Process OpenMoji CSV data"""
    print("🔍 Processing OpenMoji CSV data...")
    lines = csv_data.split('\n')
    headers = lines[0].split(',') if lines else []
    
    # Find relevant columns
    emoji_col = -1
    unicode_col = -1
    annotation_col = -1
    
    for i, header in enumerate(headers):
        if 'emoji' in header.lower():
            emoji_col = i
        elif 'hexcode' in header.lower() or 'unicode' in header.lower():
            unicode_col = i
        elif 'annotation' in header.lower():
            annotation_col = i
    
    print(f"📊 Found columns - Emoji: {emoji_col}, Unicode: {unicode_col}, Name: {annotation_col}")
    
    seen = set()
    count = 0
    
    for i, line in enumerate(lines[1:], 1):  # Skip header
        if i % 100 == 0:
            print(f"⏳ Processed {i} emojis...", end='\r')
            
        parts = line.split(',')
        if len(parts) > max(emoji_col, unicode_col, annotation_col):
            emoji = parts[emoji_col] if emoji_col >= 0 else ''
            unicode_hex = parts[unicode_col] if unicode_col >= 0 else ''
            name = parts[annotation_col] if annotation_col >= 0 else f"emoji_{i}"
            
            if unicode_hex and name:
                # Clean up unicode hex (remove U+ prefix, hyphens, etc.)
                clean_hex = re.sub(r'[^0-9A-F]', '', unicode_hex.upper())
                if clean_hex and len(clean_hex) >= 4:
                    # Take first codepoint if multiple
                    clean_hex = clean_hex[:6]
                    
                    clean_name = re.sub(r'[^A-Z0-9]+', '_', name.upper())
                    clean_name = re.sub(r'_+', '_', clean_name).strip('_')
                    
                    key = (clean_hex, clean_name)
                    if key not in seen and clean_name and len(clean_name) <= 50:
                        seen.add(key)
                        count += 1
                        print(f"\nCONST EM_{clean_name} = &H{clean_hex}  ' {emoji}")
    
    return count

# Main execution
print("🚀 Emoji Constants Generator")
print("=" * 40)

start_time = time.time()

# Try different data sources in order of preference
emoji_count = 0

# Try OpenMoji first (smaller, more reliable)
openmoji_data = try_openmoji_data()
if openmoji_data:
    emoji_count = process_openmoji_csv(openmoji_data)

# If that fails, try GitHub
if emoji_count == 0:
    github_data = try_github_emoji_data()
    if github_data:
        emoji_count = process_github_emojis(github_data)

# Last resort: try Unicode.org (slow/unreliable)
if emoji_count == 0:
    print("⚠️  Fallback to Unicode.org (this will be slow)...")
    unicode_data = try_unicode_org()
    if unicode_data:
        print("🔍 Processing Unicode.org HTML...")
        # ... (original HTML processing code would go here)

total_time = time.time() - start_time
print(f"\n\n✨ Completed! Generated {emoji_count} emoji constants in {total_time:.1f} seconds")
