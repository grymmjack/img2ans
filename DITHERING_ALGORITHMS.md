# Dithering Algorithms in IMG2PAL

This document describes the dithering algorithms implemented in IMG2PAL.

## Available Algorithms (24 total)

### Quantization
**No Dithering (Method 0)** - Pure quantization to palette colors
- No error diffusion or noise
- Fastest method, but can show banding

### Ordered Dithering Algorithms

**Ordered Dither 2x2 Bayer (Method 1)** - Classic 2x2 Bayer matrix
- Fast and creates regular patterns
- Good for retro/pixel art effects

**Ordered Dither 4x4 Bayer (Method 2)** - Standard 4x4 Bayer matrix  
- Good balance of speed and quality
- Creates characteristic crosshatch patterns

**Ordered Dither 8x8 Bayer (Method 3)** - Large 8x8 Bayer matrix
- Higher quality but more regular patterns
- Good for smooth gradients

**Ordered 16x16 Bayer (Method 20)** - Very large Bayer matrix
- Finest ordered dithering available
- Creates very smooth gradients with subtle patterns

### Error Diffusion Algorithms

**Floyd-Steinberg (Method 4)** - The classic error diffusion algorithm
- Distributes quantization error to neighboring pixels using a 2x2 kernel
- Error distribution: [0, 7/16; 3/16, 5/16, 1/16]
- Fast and produces good quality results

**Jarvis-Judice-Ninke (Method 5)** - Extended error diffusion
- Uses a larger 3x5 kernel for error distribution
- Slower but can produce smoother gradients
- Error distribution over 48 total parts

**Stucki (Method 6)** - High-quality error diffusion
- Uses a 3x5 kernel with different weights than JJN
- Good balance between quality and performance
- Error distribution: [0, 8/42, 4/42; 2/42, 4/42, 8/42, 4/42, 2/42; ...]

**Burkes (Method 7)** - Simplified 3x5 error diffusion
- Similar to Stucki but with simpler fractions
- Error distribution over 32 total parts
- Good compromise between Floyd-Steinberg and larger kernels

**Sierra (Method 8)** - Two-row error diffusion
- Uses a 3x3 kernel (two rows)
- Error distribution: [0, 5/32, 3/32; 2/32, 4/32, 5/32, 4/32, 2/32]
- Good quality with moderate computational cost

**Sierra Lite (Method 9)** - Simplified Sierra
- Minimal 2x2 kernel for speed
- Error distribution: [0, 2/4; 1/4, 1/4]
- Fastest error diffusion method

**Atkinson (Method 10)** - Classic Mac dithering
- Used in classic Mac systems
- Spreads error over 6 pixels in an asymmetric pattern
- Error distribution: each neighbor gets 1/8 of the error
- Creates distinctive texture patterns

**False Floyd-Steinberg (Method 15)** - Simplified Floyd-Steinberg
- Only distributes error right and down
- Faster than full Floyd-Steinberg
- Error distribution: [0, 1/2; 1/2, 0]

**Fan Error Diffusion (Method 16)** - Modern high-quality algorithm
- Enhanced version of Floyd-Steinberg with improved distribution
- Better quality than Floyd-Steinberg for complex images
- Uses extended 5-pixel distribution pattern

**Stevenson-Arce (Method 17)** - Advanced error diffusion
- Complex 5x3 kernel with precise weights
- Very high quality but computationally intensive
- Error distribution over 157 total parts

**Two-Row Sierra (Method 18)** - Extended Sierra algorithm
- Similar to Sierra but with enhanced distribution
- Good balance of quality and performance
- Extended error propagation pattern

**Shiau-Fan (Method 19)** - Modern error diffusion variant
- Optimized for natural images
- Uses power-of-2 fractions for efficiency
- Error distribution: [0, 1/8, 1/16; 1/32, 1/8, 1/4, 1/8, 1/16]

### Noise-Based Algorithms

**Random Dithering (Method 11)** - Pure random noise
- Adds random noise to break up color banding
- Good for organic textures
- No pattern artifacts

**Blue Noise Dithering (Method 12)** - High-frequency noise
- Approximated blue noise characteristics
- More pleasing than white noise
- Good for photographic images

**Interleaved Gradient Noise (Method 21)** - Sophisticated noise
- Uses mathematical gradient function
- Creates smooth, artifact-free dithering
- Excellent for gradients and natural images

### Pattern-Based Algorithms

**Clustered Dot 4x4 (Method 13)** - Newspaper-style halftoning
- Creates clustered dot patterns
- Good for printing and retro effects
- Mimics traditional halftone screens

**Classic Halftone (Method 14)** - Traditional halftone pattern
- Distance-based threshold pattern
- Creates circular dot clusters
- Classic printing industry effect

**Spiral Dithering (Method 22)** - Unique artistic pattern
- Creates spiral-based threshold patterns
- Artistic and decorative effect
- Good for special visual effects

**Pattern Dithering (Method 23)** - Custom black & white patterns
- Uses custom B&W images as threshold maps
- 5 built-in patterns: Crosshatch, Dots, Lines, Mesh, Custom
- Press 'K' to cycle through patterns when active
- Perfect for artistic and retro printing effects

## Usage

- Use the `<` and `>` keys (or `,` and `.`) to cycle through dithering methods
- Use the `+` and `-` keys to adjust dithering intensity from 0% to 200%
- Press `D` to toggle dithering on/off
- Press `K` to cycle through pattern types when using Pattern Dithering (Method 23)
- The current method is displayed in the status line

## Algorithm Categories by Use Case

**For Speed**: No Dithering (0), False Floyd-Steinberg (15), Sierra Lite (9)
**For Quality**: Fan (16), Stevenson-Arce (17), Stucki (6)
**For Retro/Pixel Art**: Ordered 2x2 (1), Ordered 4x4 (2), Clustered Dot (13)
**For Photos**: Floyd-Steinberg (4), Blue Noise (12), IGN (21)
**For Artistic Effects**: Pattern Dithering (23), Spiral (22), Classic Halftone (14), Atkinson (10)
**For Smooth Gradients**: Ordered 16x16 (20), JJN (5), Two-Row Sierra (18)
**For Custom Patterns**: Pattern Dithering (23) with 5 different pattern types

## Implementation Notes

All algorithms have been optimized for performance with:
- Palette caching to avoid repeated color lookups
- Single-precision floating-point for error calculations
- Progress indication for large images
- Proper clamping of color values
- Intensity control from 0% to 200%

The dithering amount parameter controls the intensity of the error diffusion and noise, allowing for subtle effects at low values or strong dithering at high values.
