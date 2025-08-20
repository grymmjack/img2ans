# Advanced Dithering Test Program

This program demonstrates **15 different dithering algorithms** and **5 different color palettes** for image processing and retro computing applications.

## Features

### Dithering Algorithms

1. **No Dithering (Quantize Only)** - Simple nearest-color quantization
2. **Ordered Dither 2x2 (Bayer)** - Classic 2x2 Bayer matrix
3. **Ordered Dither 4x4 (Bayer)** - Standard 4x4 Bayer matrix  
4. **Ordered Dither 8x8 (Bayer)** - High-resolution 8x8 Bayer matrix
5. **Floyd-Steinberg Error Diffusion** - Most popular error diffusion
6. **Jarvis-Judice-Ninke** - Complex error distribution pattern
7. **Stucki Error Diffusion** - Large kernel error diffusion
8. **Burkes Error Diffusion** - Medium complexity distribution
9. **Sierra Error Diffusion** - Three-row error distribution
10. **Sierra Lite** - Simplified 2-row Sierra algorithm
11. **Atkinson (Classic Mac)** - Used in classic Macintosh systems
12. **Random Dithering** - Noise-based dithering
13. **Blue Noise Dithering** - High-frequency pseudo-random pattern
14. **Clustered Dot 4x4** - Newspaper-style halftone
15. **Classic Halftone** - Distance-based dot pattern

### Color Palettes

1. **CGA 4-Color** - Classic PC graphics (Black, White, Magenta, Cyan)
2. **CGA 16-Color** - Full CGA color palette
3. **Monochrome** - Black and white only
4. **Game Boy Green** - Classic Game Boy 4-shade green palette
5. **Commodore 64** - Authentic C64 16-color palette

## Controls

- **SPACE** - Cycle through dithering methods
- **P** - Cycle through color palettes  
- **ESC** - Exit program

## Technical Details

### Ordered Dithering
Uses mathematical matrices (Bayer patterns) to create regular dithering patterns:
- **2x2 Matrix**: Fast, visible pattern, good for low-res displays
- **4x4 Matrix**: Standard quality, moderate pattern visibility
- **8x8 Matrix**: High quality, fine pattern, good for print

### Error Diffusion
Distributes quantization error to neighboring pixels:
- **Floyd-Steinberg**: Most common, good balance of quality and speed
- **Jarvis-Judice-Ninke**: Higher quality, more complex calculation
- **Stucki**: Very smooth gradients, large error kernel
- **Sierra variants**: Different trade-offs between quality and speed
- **Atkinson**: Preserves sharp edges, used in classic Mac

### Specialized Techniques
- **Random Dithering**: Breaks up banding with noise
- **Blue Noise**: Minimal visual artifacts, high-frequency noise
- **Halftone**: Traditional print reproduction methods

## Compilation

```bash
qb64pe -w -x advanced_dither_test.bas -o advanced_dither_test.exe
```

## Usage Examples

1. **Retro Game Development**: Test different palettes and dithering for pixel art
2. **Print Preparation**: Compare halftone algorithms for different output devices  
3. **Web Graphics**: Optimize images for limited color palettes
4. **Educational**: Learn how different dithering algorithms work visually

## Algorithm Performance

- **Fastest**: No dithering, Ordered 2x2
- **Balanced**: Floyd-Steinberg, Ordered 4x4
- **Highest Quality**: Stucki, Jarvis-Judice-Ninke, Ordered 8x8
- **Special Effects**: Random, Blue Noise, Halftone

## Technical Implementation

The program creates a complex test gradient with the following features:
- Horizontal color ramp (red component)
- Vertical color ramp (green component) 
- Diagonal patterns (blue component)
- Sine/cosine variations for testing algorithm behavior

Each dithering algorithm is implemented as a separate function with optimized processing loops and proper color space handling.

## QB64PE Compatibility

This program demonstrates:
- Advanced graphics programming
- Multiple algorithm implementations
- Real-time image processing
- Console/graphics window integration
- Efficient memory management with image handles

---

*Created for QB64PE - Advanced BASIC programming environment*
