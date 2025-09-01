# 🎨 Bitmap Pattern Dithering - MacPaint Style!

## 🎉 New Feature: Load Real Bitmap Patterns!

You can now load actual black and white bitmap files as dithering patterns! This is perfect for using classic MacPaint patterns, creating custom artistic effects, or loading any 1-bit style pattern.

## How It Works

1. **Load any bitmap file** (BMP, PNG, GIF, TGA) as a dithering pattern
2. **Automatic 1-bit conversion**: Dark pixels become low thresholds, light pixels become high thresholds
3. **Smart scaling**: Patterns are scaled to 32x32 and tile seamlessly
4. **Real-time preview**: See your pattern effect immediately

## 🎮 How to Use

### Loading Bitmap Patterns:
1. **Select Pattern Dithering**: Use `<`/`>` to cycle to method 23 ("Pattern Dithering")
2. **Load Bitmap Pattern**: Press `M` to open file browser and select your bitmap
3. **Cycle Built-in Patterns**: Press `K` to cycle through built-in + loaded patterns
4. **Adjust Intensity**: Use `+`/`-` to control pattern strength (0% to 200%)

### Pattern Types Available:
- **0-4**: Built-in patterns (Crosshatch, Dots, Lines, Mesh, Custom)
- **5**: "From File" - Your loaded bitmap pattern

## 📁 Supported File Formats

- **.BMP** - Windows Bitmap (perfect for 1-bit patterns)
- **.PNG** - Portable Network Graphics
- **.GIF** - Graphics Interchange Format
- **.TGA** - Targa format

## 🎨 Creating MacPaint-Style Patterns

### Pattern Requirements:
- **Size**: Any size (automatically scaled to 32x32)
- **Colors**: Black and white work best (color will be converted to grayscale)
- **Contrast**: High contrast patterns give best results
- **Tiling**: Design patterns that tile seamlessly for best effect

### MacPaint Pattern Recreation:
To recreate classic MacPaint patterns:

1. **Create 8x8 or 16x16 pixel patterns** in any graphics editor
2. **Use only black and white** for authentic 1-bit look
3. **Save as BMP or PNG** for best compatibility
4. **Test tiling** - make sure edges match when repeated

### Example Pattern Ideas:

**📐 Geometric Patterns:**
- Diagonal lines (///, \\\, +++, xxx)
- Dots and circles (small, medium, large)
- Crosshatch (vertical + horizontal)
- Brick patterns
- Zigzag lines

**🌿 Organic Patterns:**
- Wood grain textures
- Fabric weaves
- Stone textures
- Cloud patterns
- Water ripples

**🎭 Artistic Patterns:**
- Pen and ink hatching
- Stipple effects
- Cross-hatching styles
- Engraving patterns
- Comic book effects

## 💾 Sample Pattern Library

You can create a library of patterns like:
```
/resources/patterns/
  macpaint_dots.bmp       (various dot sizes)
  macpaint_lines.bmp      (different line angles)
  macpaint_crosshatch.bmp (cross-hatching)
  macpaint_brick.bmp      (brick texture)
  macpaint_diagonal.bmp   (diagonal lines)
  custom_fabric.png       (fabric weave)
  custom_wood.png         (wood grain)
```

## 🔧 Technical Details

### 1-Bit Conversion Process:
1. **Load bitmap** at any size/format
2. **Scale to 32x32** for consistent tiling
3. **Convert to grayscale**: (R + G + B) / 3
4. **Binary threshold**: < 128 = dark (threshold 64), >= 128 = light (threshold 192)
5. **Apply as dither matrix**: Dark areas = low quantization threshold, light areas = high threshold

### Performance Features:
- **Pattern caching**: Loaded patterns stay in memory
- **Automatic scaling**: Handles any input size efficiently  
- **Real-time switching**: Instant pattern changes with 'K' key
- **Memory management**: Automatic cleanup of temporary images

## 🎯 Perfect for Recreating Classic Effects

### **MacPaint Era (1984)**:
- Load authentic MacPaint pattern sheets
- Recreate classic Mac graphics style
- Perfect for retro computing aesthetics

### **Print Publishing**:
- Newspaper halftone patterns
- Magazine screening effects
- Traditional printing textures

### **Artistic Styles**:
- Pen and ink illustrations
- Engraving and etching effects
- Hand-drawn textures
- Comic book styling

## 🚀 Advanced Usage Tips

1. **Create Pattern Libraries**: Organize patterns by style/era
2. **Test at Different Intensities**: Same pattern, different strengths
3. **Combine with Palettes**: Pattern + EGA = retro perfection
4. **Document Your Patterns**: Note what each pattern recreates
5. **Share Pattern Collections**: Build community pattern libraries

## 📸 Status Display

When a bitmap pattern is loaded, the status shows:
- **Built-in patterns**: "Pattern Dithering (Crosshatch)"
- **Loaded files**: "Pattern Dithering (macpaint_dots.bmp)"

This makes it easy to see exactly which pattern is active!

## 🎨 The Magic of 1-Bit Patterns

This feature brings the magic of classic 1-bit computing to modern image processing. You can now use authentic patterns from the golden age of computer graphics, or create your own patterns that capture that distinctive aesthetic.

**From MacPaint to modern art - your dithering possibilities are now limitless!** 🖥️✨
