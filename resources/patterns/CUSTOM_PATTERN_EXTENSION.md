# Custom Pattern Loading Extension

## How to Extend Pattern Dithering for Custom Images

The current implementation uses procedurally generated patterns, but you can easily extend it to load custom black and white images as dithering patterns!

### Code Modification for Custom Pattern Loading

Add this to the LoadDitherPattern subroutine, CASE 4 section:

```QB64PE
CASE 4 ' Custom (load from file)
    ' Try to load a custom pattern file
    DIM custom_file AS STRING
    custom_file = _STARTDIR$ + SLASH$ + "patterns" + SLASH$ + "custom_pattern.png"
    
    IF _FILEEXISTS(custom_file) THEN
        ' Load the custom pattern image
        DIM temp_img AS LONG
        temp_img = _LOADIMAGE(custom_file, 32)
        
        IF temp_img <> 0 THEN
            ' Resize to 32x32 if needed
            IF _WIDTH(temp_img) <> 32 OR _HEIGHT(temp_img) <> 32 THEN
                DIM resized AS LONG
                resized = _NEWIMAGE(32, 32, 32)
                _PUTIMAGE (0, 0)-(31, 31), temp_img, resized
                _FREEIMAGE temp_img
                temp_img = resized
            END IF
            
            ' Copy to pattern_img
            _PUTIMAGE (0, 0), temp_img, pattern_img
            _FREEIMAGE temp_img
        ELSE
            ' Fallback pattern if file load fails
            FOR y = 0 TO 31
                FOR x = 0 TO 31
                    value = 128 + 64 * SIN(x * 0.2) * COS(y * 0.2)
                    PSET (x, y), _RGB32(value, value, value)
                NEXT
            NEXT
        END IF
    ELSE
        ' Default mathematical pattern if no file found
        FOR y = 0 TO 31
            FOR x = 0 TO 31
                value = 128 + 64 * SIN(x * 0.2) * COS(y * 0.2)
                PSET (x, y), _RGB32(value, value, value)
            NEXT
        NEXT
    END IF
```

### Pattern File Requirements

For best results, your custom pattern files should be:

- **Format**: PNG, BMP, or any QB64-PE supported format
- **Size**: Ideally 32x32 pixels (will be resized if different)
- **Colors**: Grayscale or B&W (color will be converted to grayscale)
- **Content**: High contrast patterns work best
- **Tiling**: Design should tile seamlessly for best results

### Suggested Pattern Ideas

Create 32x32 pixel images with these patterns:
- **Brick texture**: Staggered rectangular pattern
- **Honeycomb**: Hexagonal cell pattern  
- **Circuit board**: Electronic trace patterns
- **Wood grain**: Organic flowing lines
- **Fabric weave**: Textile patterns
- **Mathematical**: Fractals, spirals, waves
- **Typography**: Letter or symbol patterns
- **Organic**: Leaf veins, cell structures

### File Organization

Create a folder structure like:
```
/patterns/
  custom_pattern.png    (loaded by default)
  brick.png
  honeycomb.png
  circuit.png
  woodgrain.png
```

### Advanced Extensions

You could further extend this by:

1. **Pattern Browser**: Add UI to select from multiple pattern files
2. **Pattern Editor**: Built-in pattern drawing tools
3. **Pattern Animation**: Time-based pattern variations
4. **Pattern Blending**: Combine multiple patterns
5. **Auto-Discovery**: Scan pattern folder and list available patterns

### Pattern Creation Tips

When creating custom patterns:
- Use **high contrast** for dramatic effects
- Make patterns **tileable** (edges match)
- Test at **multiple scales** 
- Consider the **dithering intensity** setting
- **Black areas** = low threshold, **white areas** = high threshold

This system gives you unlimited creative control over your dithering patterns! 🎨
