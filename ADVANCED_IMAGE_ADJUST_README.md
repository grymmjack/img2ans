# Advanced Image Adjustment Test Program

This program demonstrates **15 different image adjustment techniques** commonly used in digital image processing, photo editing, and computer graphics applications.

## Features

### Image Adjustment Techniques

1. **Basic (Brightness/Contrast)** - Fundamental exposure adjustments
2. **Gamma Correction** - Display calibration and midtone adjustment
3. **Color Balance** - Independent RGB channel adjustment for white balance
4. **Hue/Saturation** - HSV-based color manipulation
5. **Levels Adjustment** - Professional black/white point mapping
6. **Curves (S-Curve)** - Advanced contrast enhancement
7. **Threshold** - Binary black/white conversion
8. **Invert Colors** - Film negative effect
9. **Sepia Tone** - Classic vintage photography effect
10. **Desaturate (Grayscale)** - Luminance-preserving color removal
11. **Posterize** - Artistic color reduction
12. **Colorize** - Monochrome tinting with single hue
13. **Vignette Effect** - Lens-style edge darkening
14. **Film Grain** - Analog photography texture simulation
15. **Retro Effects** - Various vintage/nostalgic filters

### Real-time Parameter Control

**Five Interactive Parameters:**
- **Brightness** (-100 to +100) - Overall lightness adjustment
- **Contrast** (-100 to +100) - Tonal range expansion/compression
- **Gamma** (0.1 to 3.0) - Nonlinear brightness curve
- **Saturation** (0 to 200%) - Color intensity control
- **Hue Shift** (-180 to +180°) - Color wheel rotation

## Controls

- **SPACE** - Cycle through adjustment methods
- **+/-** - Increase/decrease current parameter value
- **TAB** - Switch between parameters
- **R** - Reset all parameters to defaults
- **ESC** - Exit program

## Technical Implementation

### Core Algorithms

#### **Color Space Conversions**
- **RGB ↔ HSV**: Full bidirectional conversion for hue/saturation operations
- **Luminance Calculation**: Standard NTSC weights (0.299R + 0.587G + 0.114B)

#### **Professional Techniques**
- **Gamma Correction**: `output = (input/255)^(1/gamma) * 255`
- **Contrast Enhancement**: `output = factor * (input - 128) + 128`
- **S-Curve**: Sine-based midtone contrast boost
- **Sepia Formula**: Standard matrix transformation for warm brown tones

#### **Advanced Effects**
- **Vignette**: Distance-based radial darkening from center
- **Film Grain**: Pseudo-random noise simulation
- **Posterization**: Quantization to specific color levels
- **Threshold**: Adaptive binary conversion

### Test Image Features

The program generates a complex 300×300 test image with:
- **Center Circle**: Radial gradient with angular color variation
- **Ring Area**: Multi-frequency color bands
- **Left Section**: Linear brightness ramp
- **Right Section**: Trigonometric color wheel
- **Middle Section**: Mixed gradient patterns
- **Added Noise**: Random variation for algorithm testing

## Educational Value

### Digital Photography Concepts
- **Exposure Correction**: Brightness, contrast, and gamma
- **Color Grading**: Temperature, tint, and creative color effects
- **Artistic Effects**: Vintage processing and stylistic filters

### Computer Graphics Applications
- **Real-time Processing**: Efficient pixel-level operations
- **Color Theory**: HSV manipulation and color harmony
- **Image Enhancement**: Professional adjustment workflows

### Algorithm Learning
- **Matrix Operations**: Color space transformations
- **Curve Mathematics**: Gamma and S-curve functions
- **Noise Generation**: Procedural texture creation

## Performance Characteristics

- **Fastest**: Brightness, Contrast, Invert, Threshold
- **Medium**: Gamma, Levels, Posterize, Sepia
- **Complex**: Hue/Saturation, Colorize (HSV conversion)
- **Intensive**: Vignette, Film Grain (per-pixel calculations)

## Use Cases

### **Professional Photography**
- Color correction and exposure adjustment
- Creative grading and mood enhancement
- Vintage and artistic effect simulation

### **Game Development**
- Real-time post-processing effects
- Texture enhancement and stylization
- Retro/nostalgic visual themes

### **Educational Projects**
- Understanding image processing algorithms
- Learning color theory and digital imaging
- Experimenting with visual effects

### **Research and Development**
- Algorithm prototyping and testing
- Visual comparison of different techniques
- Parameter optimization studies

## Compilation

```bash
qb64pe -w -x advanced_image_adjust_test.bas -o advanced_image_adjust_test.exe
```

## QB64PE Features Demonstrated

- **Advanced Graphics**: Real-time image manipulation
- **Mathematical Functions**: Trigonometry, logarithms, color space math
- **User Interface**: Interactive parameter control
- **Memory Management**: Efficient image buffer handling
- **Console Integration**: Debug output alongside graphics

## Technical Notes

### **Color Accuracy**
- All operations maintain 8-bit precision (0-255)
- Proper clamping prevents overflow/underflow
- Standard color space formulas ensure compatibility

### **Performance Optimization**
- Direct pixel access using POINT/PSET
- Minimal memory allocation during processing
- Efficient loop structures for real-time interaction

### **Algorithm Fidelity**
- Industry-standard formulas for professional effects
- Authentic vintage processing simulation
- Mathematically correct color space conversions

---

*Created for QB64PE - Demonstrating advanced image processing techniques in BASIC*
