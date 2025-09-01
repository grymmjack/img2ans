# 🎨 Pattern Dithering - Custom Black & White Patterns!

## What is Pattern Dithering?

Pattern dithering is a technique where a **black and white pattern image** is used as a **threshold map** for dithering! Instead of using mathematical algorithms, the pattern image determines how colors are quantized - dark areas in the pattern create different thresholds than light areas.

## How It Works

1. **Pattern as Threshold**: Each pixel in your pattern image becomes a threshold value
2. **Tiling**: The pattern tiles seamlessly across your entire image  
3. **Threshold Mapping**: Light areas in the pattern = higher thresholds, dark areas = lower thresholds
4. **Custom Effects**: This creates unique, repeatable dithering patterns based on your design!

## Built-in Patterns (Method 23)

I've implemented **5 built-in patterns** you can cycle through:

### **🔲 Crosshatch**
- Classic crosshatch pattern with intersecting lines
- Creates a hand-drawn, sketchy effect
- Great for artistic illustrations

### **⚫ Dots** 
- Regular dot pattern (halftone style)
- Perfect for comic book or printing effects
- Creates clean, professional results

### **📏 Lines**
- Horizontal line pattern
- Creates scan-line or TV screen effects
- Great for retro/vintage looks

### **🌐 Mesh**
- Diagonal mesh pattern
- Creates fabric-like textures
- Unique geometric appearance

### **🎨 Custom**
- Mathematical pattern (sine/cosine waves)
- Organic, flowing appearance
- Can be extended to load external images

## 🎮 How to Use

1. **Select Pattern Dithering**: Use `<`/`>` to cycle to method 23 ("Pattern Dithering")
2. **Cycle Patterns**: Press `K` to cycle through the 5 different patterns
3. **Adjust Intensity**: Use `+`/`-` to control dithering strength (0% to 200%)
4. **Current Pattern**: The pattern name is shown in the status: "Pattern Dithering (Crosshatch)"

## 🔧 Technical Details

- **Pattern Size**: 32x32 pixels (tiles seamlessly)
- **Threshold Range**: 64-192 (adjustable via intensity)
- **Performance**: Optimized with pattern caching
- **Memory**: Patterns generated procedurally in memory

## 🚀 Future Extensions

This system is designed to be extended! You could easily add:
- **Custom Image Loading**: Load your own B&W pattern images from files
- **Pattern Editor**: Draw patterns directly in the program
- **Pattern Library**: Save/load pattern collections
- **Animated Patterns**: Time-based pattern variations

## 💡 Creative Ideas

Try creating patterns for:
- **Crosshatch Drawing**: Use crosshatch pattern for sketch effects
- **Comic Books**: Use dots pattern for halftone printing look
- **Retro Gaming**: Use lines for scan-line CRT effects  
- **Textures**: Use mesh for fabric/material textures
- **Abstract Art**: Experiment with different intensities

## 🎯 Perfect For

- **Artistic Effects**: Creating hand-drawn or printed looks
- **Retro Aesthetics**: Matching specific vintage printing styles
- **Texture Simulation**: Mimicking real-world printing techniques
- **Creative Exploration**: Experimenting with unique dithering patterns

This opens up a whole new world of creative dithering possibilities! 🎨✨
