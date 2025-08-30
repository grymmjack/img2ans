# Test Image Creators

This directory contains standalone programs to create different types of test images for image adjustment testing.

## Available Test Image Creators

### CREATE-TEST-IMAGE.BAS
- **Output**: `TESTIMAGE.PNG` (200x200)
- **Description**: Simple RGB gradient with three vertical bands (red, green, blue)
- **Usage**: Used by `brightness_contrast_test-simple.bas`
- **Features**: Basic color gradients from bright to dark in each channel

### CREATE-TEST-IMAGE-GRADIENT.BAS  
- **Output**: `TESTIMAGE-GRADIENT.PNG` (200x200)
- **Description**: Same as CREATE-TEST-IMAGE.BAS (RGB gradient)
- **Usage**: Standalone gradient test image
- **Features**: Clean RGB gradients for testing color adjustments

### CREATE-TEST-IMAGE-COMPLEX.BAS
- **Output**: `TESTIMAGE-COMPLEX.PNG` (300x300)  
- **Description**: Complex test pattern with multiple features
- **Usage**: Advanced image adjustment testing
- **Features**:
  - Center circle with radial color gradient
  - Ring area with color bands and angular patterns
  - Left section with brightness ramp
  - Right section with color wheel patterns  
  - Middle section with mixed mathematical patterns
  - Random noise for realistic testing
  - Multiple color zones for comprehensive testing

## How to Use

1. Compile any creator: `qb64pe.exe -x CREATE-TEST-IMAGE.BAS -o CREATE-TEST-IMAGE.exe`
2. Run the executable: `CREATE-TEST-IMAGE.exe`
3. The PNG file will be created in the same directory
4. Use the generated PNG with your image adjustment programs

## Test Image Characteristics

### Simple Gradient (TESTIMAGE.PNG)
- **Size**: 200x200 pixels
- **Pattern**: Three vertical bands of pure RGB gradients
- **Best for**: Basic brightness, contrast, and color balance testing
- **File size**: ~2KB

### Complex Pattern (TESTIMAGE-COMPLEX.PNG)  
- **Size**: 300x300 pixels
- **Pattern**: Multiple geometric and mathematical patterns
- **Best for**: Advanced adjustment testing (gamma, curves, HSV, etc.)
- **File size**: ~311KB (due to complexity and noise)

The complex pattern includes various challenging elements that help test different aspects of image adjustment algorithms:
- Gradients for brightness/contrast testing
- Color wheels for hue/saturation testing  
- Geometric patterns for distortion detection
- Noise for algorithm robustness testing
- Different brightness regions for level adjustments
