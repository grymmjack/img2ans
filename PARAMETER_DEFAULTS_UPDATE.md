# Parameter Defaults System Update

## What was changed:

1. **Common Framework (adjustment_common.bi)**:
   - Added `parameterDefaults(0 TO 4) AS SINGLE` array to shared variables

2. **Common Framework (adjustment_common.bas)**:
   - Updated `ResetParameters` to use `parameterDefaults(i)` instead of hardcoded 0

3. **Updated Files:**
   - ✅ `hue_saturation_test.bas` - Hue defaults to 0°, Saturation defaults to 100%
   - ✅ `brightness_contrast_test.bas` - Both default to 0 (no change)
   - ✅ `gamma_test.bas` - Defaults to 100 (gamma 1.0, no change)
   - ✅ `glow_test.bas` - Radius defaults to 3, Intensity defaults to 50%

## How to update remaining files:

For each `SetupParameters` function, add a `parameterDefaults(i) = value` line for each parameter:

```qbasic
SUB SetupParameters
    parameterCount = 2
    
    parameterNames(0) = "Parameter Name"
    parameterMins(0) = 0
    parameterMaxs(0) = 100
    parameterSteps(0) = 5
    parameterDefaults(0) = 50  ' ADD THIS LINE - proper default value
    parameters(0) = 50
    
    ' Repeat for each parameter...
END SUB
```

## Files that still need updating:
- blur_test.bas
- colorize_test.bas
- color_balance_test.bas
- curves_test.bas
- desaturate_test.bas
- film_grain_test.bas
- invert_test.bas
- levels_test.bas
- pixelate_test.bas
- posterize_test.bas
- retro_effects_test.bas
- sepia_test.bas
- threshold_test.bas
- vignette_test.bas

## Benefits:
- Pressing 'R' now resets to sensible defaults instead of always 0
- Each algorithm can define its own proper "neutral" state
- More intuitive user experience
