# Image Adjustment Algorithms

This directory contains individual test programs for each of the 18 image adjustment algorithms, extracted from the monolithic advanced_image_adjust_test.bas file for easier development and fine-tuning.

## Structure

Each algorithm is now in its own standalone .BAS file with:
- Individual parameter setup and ranges
- Dedicated test harness
- Algorithm-specific documentation
- Independent compilation and testing

## Common Framework

All algorithms share common code in `../core/adjustment_common.bas` and `../core/adjustment_common.bi`:
- Complex test image generation
- Common UI elements and parameter handling
- HSV color conversion utilities
- Standard input handling

## Available Algorithms

### Core Adjustments
- **brightness_contrast_test.bas** - Basic brightness (±255) and contrast (±100) adjustments
- **gamma_test.bas** - Gamma correction (0.1 to 3.0) for display calibration
- **color_balance_test.bas** - Independent RGB channel adjustment (±100 each)
- **levels_test.bas** - Input/output level mapping for exposure correction
- **hue_saturation_test.bas** - HSV-based hue shift (±180°) and saturation (0-200%)

### Tone and Color Effects
- **curves_test.bas** - S-curve contrast enhancement (no parameters)
- **threshold_test.bas** - Binary black/white conversion with adjustable threshold
- **invert_test.bas** - Color inversion/negative effect (no parameters)
- **sepia_test.bas** - Vintage sepia tone effect (no parameters)
- **desaturate_test.bas** - Grayscale conversion (no parameters)
- **colorize_test.bas** - Apply single hue to grayscale (hue 0-360°, saturation 0-200%)

### Special Effects
- **posterize_test.bas** - Color quantization (2-256 colors)
- **vignette_test.bas** - Edge darkening effect (0-100% strength)
- **film_grain_test.bas** - Realistic film grain texture (0-100 intensity)
- **retro_effects_test.bas** - Various vintage effects (4 different types)

### Spatial Effects
- **blur_test.bas** - Box blur effect (1-15 pixel radius)
- **pixelate_test.bas** - Pixelated retro look (1-50 pixel size)
- **glow_test.bas** - Soft glow around bright areas (radius 1-10, intensity 10-100%)

## Controls

All test programs use consistent controls:
- **+/-** - Adjust current parameter value
- **TAB** - Switch to next parameter (multi-parameter algorithms)
- **R** - Reset all parameters to defaults
- **ESC** - Exit program

## Usage

1. Compile any algorithm file:
   ```
   qb64pe -c algorithm_name_test.bas
   ```

2. Run the executable:
   ```
   algorithm_name_test.exe
   ```

3. Switch to the graphics window to see the test interface
4. Use controls to adjust parameters and see real-time results

## Development Notes

- Each algorithm can be fine-tuned independently
- Parameter ranges are optimized for practical use
- Common framework allows easy addition of new algorithms
- All shared code is centralized in the CORE directory

## Adding New Algorithms

1. Create new .BAS file based on existing template
2. Include the common framework files
3. Implement SetupParameters() for your algorithm's parameters
4. Implement ApplyAdjustments() to call your algorithm
5. Implement your algorithm function(s)
6. Update this README with the new algorithm

## Notes

- Brightness range extended to ±255 for full black/white capability
- All algorithms preserve the original test image for comparison
- Real-time parameter adjustment with visual feedback
- Consistent UI across all test programs
