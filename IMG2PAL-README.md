# IMG2PAL - Image to Palette Converter

**Version 1.0**  
*A powerful image processing tool for converting images to custom color palettes with advanced adjustment capabilities*

---

## 📖 Overview

IMG2PAL is a specialized image processing application that converts any QB64-supported image format to a fixed color palette. Originally designed to support pixel art conversion for IMG2ANS, it now features a comprehensive suite of image adjustments and dithering algorithms.

### Key Features
- **Real-time Preview** - See original and palette-converted images side by side
- **12 Chained Image Adjustments** - Apply multiple effects in sequence  
- **15 Dithering Algorithms** - From simple quantization to advanced error diffusion
- **GPL Palette Support** - Load custom GIMP palettes (.GPL files)
- **Multiple Scaling Modes** - SXBR, MMPX, HQ2X/HQ3X algorithms
- **Interactive Controls** - Keyboard-driven interface with real-time updates
- **Batch Processing** - Navigate through image collections with arrow keys

---

## 🚀 Quick Start

1. **Launch IMG2PAL** - Run `IMG2PAL.exe`
2. **Load an Image** - Press `L` to browse for an image file
3. **Load a Palette** - Press `P` to browse for a .GPL palette file  
4. **Apply Adjustments** - Use letter keys to modify the image (see controls below)
5. **Explore Variations** - Use `` ` `` (random image), `~` (random palette), or `?` (random everything)
6. **Save Result** - Press `S` to save the palette-converted image

---

## 🎮 Controls Reference

### File Operations
| Key | Action | Description |
|-----|--------|-------------|
| `L` | Load Image | Open file dialog to select an image |
| `P` | Load Palette | Open file dialog to select a .GPL palette |
| `S` | Save Image | Save the current palette-converted result |
| `H` | Help | Display keyboard shortcuts and controls |
| `A` | About | Show version information |
| `ESC` | Exit | Quit the application |

### Navigation
| Key | Action | Description |
|-----|--------|-------------|
| `Page Up` | Previous Image | Navigate to previous image in folder |
| `Page Down` | Next Image | Navigate to next image in folder |
| `Left Arrow` | Previous Palette | Switch to previous palette in folder |
| `Right Arrow` | Next Palette | Switch to next palette in folder |
| `J` | Jump to Image | Enter specific image number |
| `Q` | Jump to Palette | Enter specific palette number |

### Randomization
| Key | Action | Description |
|-----|--------|-------------|
| `` ` `` | Random Image | Randomly select new image (keeps all settings) |
| `~` | Random Palette | Randomly select new palette (keeps all settings) |
| `?` | Random Everything | Randomly select image, palette, and dither settings |

### View Controls
| Key | Action | Description |
|-----|--------|-------------|
| `Up Arrow` | Zoom In | Increase zoom level (+Shift = faster) |
| `Down Arrow` | Zoom Out | Decrease zoom level (+Shift = faster) |
| `0` | Minimum Zoom | Set zoom to minimum (0.1x) |
| `1-4` | Set Zoom | Set zoom to 1x, 2x, 3x, or 4x |
| `9` | Maximum Zoom | Set zoom to maximum (10x) |

### Dithering & Scaling
| Key | Action | Description |
|-----|--------|-------------|
| `D` | Toggle Dithering | Enable/disable dithering |
| `+/=` | Increase Dither | Increase dither amount |
| `-` | Decrease Dither | Decrease dither amount |
| `<` | Previous Dither Method | Cycle through dithering algorithms |
| `>` | Next Dither Method | Cycle through dithering algorithms |
| `,` | Previous Scaler | Change scaling algorithm |
| `.` | Next Scaler | Change scaling algorithm |

---

## 🎲 Randomization Features

IMG2PAL includes powerful randomization tools for creative exploration and discovering unexpected combinations:

### Random Functions
| Key | Function | What Changes | What's Preserved |
|-----|----------|--------------|------------------|
| `` ` `` | **Random Image Only** | Current image file | Palette, dither settings, adjustments, zoom |
| `~` | **Random Palette Only** | Current palette file | Image, dither settings, adjustments, zoom |
| `?` | **Random Everything** | Image, palette, dither method, dither amount | Zoom level (adjustments reset) |

### Randomization Details

#### Random Image Only (`` ` `` - Backtick)
- **Purpose**: Explore how different images look with your current settings
- **Preserves**: All adjustments, palette, dithering configuration, zoom level
- **Changes**: Only the source image file
- **Use Case**: Perfect when you've found great settings and want to see how they work on other images
- **Message**: "RANDOM IMAGE: [filename] (settings preserved)"

#### Random Palette Only (`~` - Tilde)  
- **Purpose**: See how the same image looks with different color schemes
- **Preserves**: Current image, all adjustments, dithering configuration, zoom level
- **Changes**: Only the palette file (.GPL)
- **Use Case**: Ideal for exploring color variations while keeping everything else consistent
- **Message**: "RANDOM PALETTE: [filename] (settings preserved)"

#### Random Everything (`?` - Question Mark)
- **Purpose**: Complete creative chaos for discovering unexpected combinations
- **Changes**: Image file, palette file, dither method, dither amount, dithering on/off (70% chance)
- **Resets**: All image adjustments to defaults
- **Preserves**: Only zoom level
- **Use Case**: Great for inspiration, happy accidents, and breaking creative blocks
- **Message**: Full details of all randomized settings

### Creative Workflows

#### The "Settings Explorer" Workflow
1. Load an image you like (`L`)
2. Apply your favorite adjustments (`B`, `C`, `G`, etc.)
3. Set up dithering preferences (`D`, `+/-`, `<>`)
4. Use **Random Image** (`` ` ``) to see how these settings work on other images
5. Save interesting results (`S`)

#### The "Palette Explorer" Workflow  
1. Find an interesting image (`L`)
2. Apply desired adjustments and effects
3. Use **Random Palette** (`~`) to explore different color schemes
4. Compare how the same processing looks with various palettes
5. Save your favorites (`S`)

#### The "Discovery" Workflow
1. Use **Random Everything** (`?`) for complete surprise combinations
2. If you like what you see, fine-tune with individual adjustments
3. Use specific random functions to explore variations
4. Build a collection of interesting results

### Tips for Effective Randomization

#### Getting the Most from Random Functions
- **Start with intention**: Set up base settings before using `` ` `` or `~`
- **Use in sequence**: Try `?` first, then refine with `` ` `` and `~`
- **Save frequently**: Capture interesting combinations before they're lost
- **Combine with manual**: Use random functions to find starting points, then manually adjust

#### Understanding Random Behavior
- **Image/Palette selection**: Chooses from currently loaded folder contents
- **Dither method**: Cycles through all 15 available algorithms
- **Dither amount**: Biased toward practical ranges (0.2 to 1.5)
- **Dithering toggle**: 70% chance to enable dithering in full random mode

#### Performance Considerations
- **Large image collections**: Random selection works faster with organized folders
- **Complex adjustments**: Random functions preserve expensive adjustment chains
- **Memory management**: Random functions properly handle image loading/unloading

---

## 🎨 Image Adjustments

IMG2PAL features 12 chained image adjustments that are applied sequentially to create stunning effects:

### Basic Adjustments
| Key | Adjustment | Range | Description |
|-----|------------|-------|-------------|
| `B` | **Brightness** | -100 to +100 | Adjust overall image brightness |
| `C` | **Contrast** | -100 to +100 | Increase or decrease contrast |
| `G` | **Gamma** | -100 to +100 | Gamma correction for exposure |

### Color Adjustments  
| Key | Adjustment | Range | Description |
|-----|------------|-------|-------------|
| `U` | **Hue Shift** | -180° to +180° | Shift all colors around the color wheel |
| `Z` | **Colorize** | Hue: 0-360°, Sat: 0-1.0 | Add color tint to the image |
| `N` | **Color Balance** | R/G/B: -100 to +100 | Adjust individual color channels |

### Effect Adjustments
| Key | Adjustment | Range | Description |
|-----|------------|-------|-------------|
| `F` | **Film Grain** | 0 to 100 | Add vintage film grain texture |
| `I` | **Invert** | Toggle | Invert all colors (negative effect) |
| `X` | **Pixelate** | 1 to 20 pixels | Create pixel art effect |

### Advanced Adjustments
| Key | Adjustment | Parameters | Description |
|-----|------------|------------|-------------|
| `T` | **Threshold** | 0 to 255 | Convert to black/white based on threshold |
| `O` | **Posterize** | 2 to 32 levels | Reduce color levels for poster effect |
| `V` | **Levels** | Input Min/Max, Output Min/Max | Advanced tone curve adjustment |

### Reset
| Key | Action | Description |
|-----|--------|-------------|
| `R` | **Reset All** | Reset all adjustments to default values |

---

## 🔄 Adjustment Chain Order

Adjustments are applied in this specific order for optimal results:

1. **Brightness** → 2. **Contrast** → 3. **Hue** → 4. **Colorize** → 5. **Threshold** → 6. **Posterize** → 7. **Gamma** → 8. **Film Grain** → 9. **Invert** → 10. **Levels** → 11. **Color Balance** → 12. **Pixelate**

This order ensures that:
- Basic exposure adjustments are applied first
- Color modifications happen in logical sequence  
- Effects like grain and pixelation are applied last for best quality

---

## 🎯 Dithering Algorithms

IMG2PAL supports 15 professional dithering methods:

### Quantization
- **No Dithering** - Simple color quantization

### Ordered Dithering
- **2x2 Bayer** - Classic small-pattern dithering
- **4x4 Bayer** - Medium-pattern dithering  
- **8x8 Bayer** - Large-pattern dithering
- **Clustered Dot 4x4** - Newspaper-style halftoning
- **Classic Halftone** - Traditional halftone patterns

### Error Diffusion
- **Floyd-Steinberg** - Most popular error diffusion
- **Jarvis-Judice-Ninke** - Higher quality, slower processing
- **Stucki** - Good balance of quality and speed
- **Burkes** - Alternative error diffusion pattern
- **Sierra** - Three-row error diffusion
- **Sierra Lite** - Simplified Sierra algorithm
- **Atkinson** - Classic Mac-style dithering

### Special Methods
- **Random Dithering** - Adds random noise for organic look
- **Blue Noise** - Advanced noise distribution

---

## 🎨 Scaling Algorithms

When dithering is disabled, these scaling algorithms are available:

- **ADAPTIVE** - QB64's built-in adaptive scaling
- **SXBR2** - Super xBR 2x scaling for pixel art
- **MMPX2** - Mixed-resolution scaling algorithm
- **HQ2XA/HQ2XB** - High Quality 2x scaling variants
- **HQ3XA/HQ3XB** - High Quality 3x scaling variants

---

## 📁 Supported Formats

### Input Images
- **JPEG** (.jpg, .jpeg)
- **PNG** (.png)  
- **GIF** (.gif)
- **BMP** (.bmp)
- **TGA** (.tga)
- **PSD** (.psd)
- **PCX** (.pcx)
- **SVG** (.svg)
- **QOI** (.qoi)

### Palettes
- **GPL** (.gpl) - GIMP Palette format
- **Built-in EGA** - Default 16-color palette

### Output
- **PNG** - 8-bit indexed color PNG files

---

## 💡 Tips & Tricks

### Getting Best Results
1. **Start with basic adjustments** - Brightness and contrast first
2. **Use moderate dither amounts** - 50% often works best
3. **Try different dither methods** - Each works better for different image types
4. **Reset and experiment** - Use `R` to quickly start over
5. **Save intermediate results** - Save interesting combinations before trying more

### Workflow Suggestions
1. **Load image** → **Adjust brightness/contrast** → **Apply dithering** → **Save**
2. **For pixel art**: Use pixelate effect + ordered dithering
3. **For photos**: Try Floyd-Steinberg + film grain
4. **For artistic effects**: Combine posterize + colorize + invert

### Performance Notes
- **Large images** may take time to process with complex adjustments
- **Error diffusion** methods are slower but higher quality
- **Reset frequently** to avoid cumulative processing delays

---

## 🛠️ Technical Details

### System Requirements
- **Windows** 10/11 (primary target)
- **QB64-PE** runtime environment
- **2GB RAM** minimum for large images
- **Graphics card** supporting 32-bit color

### Dependencies
- **QB64_GJ_LIB** - Core utility library
- **IMGADJ** - Image adjustment algorithms library

### Image Processing Pipeline
1. **Load** - Image loaded as 32-bit RGBA
2. **Adjust** - Chained adjustments applied sequentially  
3. **Palettize** - Convert to target palette with optional dithering
4. **Display** - Real-time preview of original vs. result
5. **Save** - Export as 8-bit indexed PNG

---

## 📋 Version History

### Version 1.0 (Current)
- ✅ Complete image adjustment suite (12 effects)
- ✅ 15 dithering algorithms implemented
- ✅ Real-time preview system
- ✅ GPL palette support
- ✅ Batch navigation features
- ✅ Interactive keyboard controls
- ✅ **Randomization system** (Random Image, Random Palette, Random Everything)
- ✅ **Creative exploration tools** for discovering unexpected combinations

### Planned Features
- **Additional palette formats** (ACO, PAL, etc.)
- **Batch processing mode**
- **Custom dithering patterns**
- **Adjustment presets**
- **Command-line interface**

---

## 🤝 Contributing

IMG2PAL is part of the **img2ans** project. For bug reports, feature requests, or contributions:

- **Repository**: [grymmjack/img2ans](https://github.com/grymmjack/img2ans)
- **Issues**: Use GitHub Issues for bug reports
- **Pull Requests**: Welcome for enhancements

---

## 📄 License

IMG2PAL is released under the same license as the img2ans project.

### Authors
- **Rick Christy** (@grymmjack) - Original implementation
- **Samuel Gomes** (@a740g) - QB64PE conversion and GPL loader

---

## 🆘 Troubleshooting

### Common Issues

**Q: Image won't load**  
A: Ensure the image format is supported and file isn't corrupted

**Q: Palette conversion looks wrong**  
A: Try different dithering methods or adjust dither amount

**Q: Application runs slowly**  
A: Reduce image size or use simpler adjustments

**Q: Can't save image**  
A: Check file permissions and disk space

### Getting Help
- Press `H` in the application for quick help
- Check the console output for error messages
- Refer to this README for detailed information

---

*Happy image processing! 🎨*
