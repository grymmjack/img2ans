# IMGADJ - Clean Image Adjustment API

A simplified, clean API for image adjustments in QB64PE. No more boilerplate - just simple function calls!

## Quick Start

```bas
'$INCLUDE:'../core/adjustment_common.bi'

DIM myImage AS LONG
myImage = IMGADJ_LoadTestImage&("simple")

' Apply adjustments with clean one-liners
DIM adjusted AS LONG
adjusted = IMGADJ_Brightness&(myImage, "+", 50)     ' Increase brightness by 50
adjusted = IMGADJ_Contrast&(myImage, "-", 25)       ' Decrease contrast by 25%
adjusted = IMGADJ_Gamma&(myImage, "+", 20)          ' Increase gamma to 1.2
adjusted = IMGADJ_Saturation&(myImage, "+", 75)     ' Increase saturation by 75%
adjusted = IMGADJ_Hue&(myImage, "-", 45)            ' Shift hue by -45 degrees

'$INCLUDE:'../core/adjustment_common.bas'
```

## Core Functions

### `IMGADJ_Brightness&(sourceImg&, direction$, amount%)`
**Purpose**: Adjusts image brightness by adding/subtracting from RGB values  
**Parameters**:
- `sourceImg&`: Source image handle
- `direction$`: "+" to increase, "-" to decrease  
- `amount%`: Value to add/subtract (0-255)
**Returns**: New image handle with adjustment applied  
**Example**: `bright = IMGADJ_Brightness&(img, "+", 30)`

### `IMGADJ_Contrast&(sourceImg&, direction$, amount%)`
**Purpose**: Adjusts image contrast using standard contrast formula  
**Parameters**:
- `sourceImg&`: Source image handle
- `direction$`: "+" to increase, "-" to decrease
- `amount%`: Contrast percentage (0-100)
**Returns**: New image handle with adjustment applied  
**Example**: `contrasted = IMGADJ_Contrast&(img, "-", 15)`

### `IMGADJ_Gamma&(sourceImg&, direction$, amount%)`
**Purpose**: Applies gamma correction for midtone adjustment  
**Parameters**:
- `sourceImg&`: Source image handle  
- `direction$`: "+" to lighten midtones, "-" to darken
- `amount%`: Gamma adjustment (amount/100 = gamma multiplier)
**Returns**: New image handle with adjustment applied  
**Example**: `gamma_adj = IMGADJ_Gamma&(img, "+", 30)` ' Gamma = 1.3

### `IMGADJ_Saturation&(sourceImg&, direction$, amount%)`
**Purpose**: Adjusts color saturation using HSV color space  
**Parameters**:
- `sourceImg&`: Source image handle
- `direction$`: "+" to increase saturation, "-" to decrease  
- `amount%`: Saturation percentage change (0-200)
**Returns**: New image handle with adjustment applied  
**Example**: `saturated = IMGADJ_Saturation&(img, "+", 50)` ' +50% saturation

### `IMGADJ_Hue&(sourceImg&, direction$, amount%)`
**Purpose**: Shifts hue around the color wheel using HSV color space  
**Parameters**:
- `sourceImg&`: Source image handle
- `direction$`: "+" for clockwise, "-" for counter-clockwise
- `amount%`: Degrees to shift (0-360)  
**Returns**: New image handle with adjustment applied  
**Example**: `hue_shifted = IMGADJ_Hue&(img, "-", 120)` ' Shift -120 degrees

## Utility Functions

### `IMGADJ_LoadTestImage&(imageType$)`
**Purpose**: Loads predefined test images  
**Parameters**:
- `imageType$`: "simple"/"gradient" for TESTIMAGE.PNG, "complex" for TESTIMAGE-COMPLEX.PNG
**Returns**: Image handle, or exits with error if file not found  
**Example**: `img = IMGADJ_LoadTestImage&("simple")`

### `IMGADJ_ShowComparison(originalImg&, adjustedImg&, title$)`
**Purpose**: Displays before/after comparison with title  
**Parameters**:
- `originalImg&`: Original image handle
- `adjustedImg&`: Adjusted image handle  
- `title$`: Title to display
**Example**: `CALL IMGADJ_ShowComparison(orig, adjusted, "Brightness +50")`

## Advanced Usage Patterns

### Chaining Adjustments
```bas
' Method 1: Chain with temporary variables
DIM temp AS LONG, final AS LONG
temp = IMGADJ_Brightness&(original, "+", 20)
final = IMGADJ_Contrast&(temp, "+", 15)
_FREEIMAGE temp

' Method 2: Nested calls (be careful with memory)
final = IMGADJ_Contrast&(IMGADJ_Brightness&(original, "+", 20), "+", 15)
```

### Interactive Adjustment
```bas
DIM adjustment AS INTEGER: adjustment = 0
DO
    IF adjusted <> 0 THEN _FREEIMAGE adjusted
    adjusted = IMGADJ_Brightness&(original, IIF(adjustment >= 0, "+", "-"), ABS(adjustment))
    CALL IMGADJ_ShowComparison(original, adjusted, "Brightness: " + STR$(adjustment))
    ' Handle input to change adjustment value
LOOP
```

### Batch Processing
```bas
DIM images(10) AS LONG, processed(10) AS LONG
FOR i = 0 TO 10
    processed(i) = IMGADJ_Brightness&(images(i), "+", 25)
    processed(i) = IMGADJ_Contrast&(processed(i), "+", 10)
NEXT
```

## Memory Management

⚠️ **Important**: All IMGADJ functions return NEW image handles. You must free them when done:

```bas
DIM adjusted AS LONG
adjusted = IMGADJ_Brightness&(original, "+", 50)
' ... use the adjusted image ...
_FREEIMAGE adjusted  ' Always free when done!
```

## Error Handling

- Functions will exit with error message if source image is invalid
- `IMGADJ_LoadTestImage&` exits if test image files don't exist
- Parameter values are automatically clamped to safe ranges

## Complete Example

```bas
'$INCLUDE:'../core/adjustment_common.bi'

SCREEN _NEWIMAGE(800, 600, 32)

' Load test image
DIM original AS LONG, result AS LONG
original = IMGADJ_LoadTestImage&("simple")

' Apply multiple adjustments
result = IMGADJ_Brightness&(original, "+", 30)      ' Brighten
DIM temp AS LONG: temp = result
result = IMGADJ_Contrast&(temp, "+", 20)            ' Add contrast  
_FREEIMAGE temp: temp = result
result = IMGADJ_Saturation&(temp, "+", 40)          ' Boost saturation
_FREEIMAGE temp

' Show final result
CALL IMGADJ_ShowComparison(original, result, "Multi-Adjustment Result")
SLEEP

' Cleanup
_FREEIMAGE original
_FREEIMAGE result

'$INCLUDE:'../core/adjustment_common.bas'
```

## Benefits of This API

✅ **Minimal Boilerplate**: Just include files and call functions  
✅ **Consistent Interface**: Same pattern for all adjustments  
✅ **Safe**: Automatic parameter clamping and error handling  
✅ **Flexible**: Support for both positive and negative adjustments  
✅ **Chainable**: Easy to combine multiple adjustments  
✅ **Memory Safe**: Clear ownership of returned image handles
