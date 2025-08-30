' Hue and Saturation Test
' Standalone test for hue and saturation algorithm
$CONSOLE
_CONSOLE ON
PRINT "Hue/Saturation Test Starting..."

' Include our common framework
'$INCLUDE:'../core/adjustment_common.bi'

' Algorithm-specific forward declarations
DECLARE SUB ApplyHueSaturation (img AS LONG, hueShift AS INTEGER, saturation AS SINGLE)
DECLARE SUB ApplyAdjustments ()
DECLARE SUB SetupParameters ()

PRINT "Initializing..."
parameterIndex = 0
originalImage = 0
adjustedImage = 0

PRINT "Setting up algorithm parameters..."
CALL SetupParameters

PRINT "Creating test image..."
CALL CreateComplexTestImage

PRINT "Initializing graphics..."
CALL InitializeGraphics("Hue/Saturation Test - +/-: adjust, TAB: parameter, R: reset, ESC: exit")

PRINT "Graphics screen created successfully!"
PRINT "Starting main loop - switch to graphics window!"
PRINT "Controls:"
PRINT "  +/- = adjust current parameter"
PRINT "  TAB = next parameter"
PRINT "  R = reset parameters"
PRINT "  ESC = exit"

' Apply initial adjustments
CALL ApplyAdjustments

DO
    _DEST 0 ' Graphics screen
    CLS
    CALL DrawUI("Hue/Saturation", "HSV-based hue and saturation control." + CHR$(10) + "Hue shift rotates colors around wheel." + CHR$(10) + "Saturation controls color intensity." + CHR$(10) + "Hue: ±180°, Saturation: 0-200%")
    
    ' Store old parameter values to detect changes
    DIM oldHue AS SINGLE, oldSat AS SINGLE
    oldHue = parameters(0)
    oldSat = parameters(1)
    
    CALL HandleInput
    
    ' Reapply adjustments if parameters changed
    IF parameters(0) <> oldHue OR parameters(1) <> oldSat THEN
        CALL ApplyAdjustments
    END IF
    
    _DISPLAY
    _LIMIT 60
LOOP UNTIL _KEYDOWN(27)

PRINT "Cleaning up..."
IF originalImage <> 0 THEN _FREEIMAGE originalImage
IF adjustedImage <> 0 THEN _FREEIMAGE adjustedImage
PRINT "Program ended."
SYSTEM

SUB SetupParameters
    ' Setup hue and saturation parameters
    parameterCount = 2
    
    ' Hue shift parameter
    parameterNames(0) = "Hue Shift"
    parameterMins(0) = -180
    parameterMaxs(0) = 180
    parameterSteps(0) = 10
    parameterDefaults(0) = 0  ' Default: no hue shift
    parameters(0) = 0
    
    ' Saturation parameter (as percentage)
    parameterNames(1) = "Saturation"
    parameterMins(1) = 0
    parameterMaxs(1) = 255
    parameterSteps(1) = 10
    parameterDefaults(1) = 100  ' Default: normal saturation (100%)
    parameters(1) = 100  ' Default to 100% (no change)
    
    parameterIndex = 0
END SUB

SUB ApplyAdjustments
    DIM actualSaturation AS SINGLE
    actualSaturation = parameters(1) / 100.0
    
    _DEST _CONSOLE
    PRINT "Applying hue/saturation: hue="; parameters(0); "°, saturation="; actualSaturation
    _DEST 0
    
    IF originalImage = 0 THEN 
        _DEST _CONSOLE
        PRINT "No original image!"
        _DEST 0
        EXIT SUB
    END IF
    
    IF adjustedImage <> 0 THEN _FREEIMAGE adjustedImage
    adjustedImage = _COPYIMAGE(originalImage, 32)
    
    ' Apply hue/saturation adjustment
    CALL ApplyHueSaturation(adjustedImage, CINT(parameters(0)), actualSaturation)
    
    _DEST _CONSOLE
    PRINT "Hue/saturation adjustment complete"
    _DEST 0
END SUB

SUB ApplyHueSaturation (img AS LONG, hueShift AS INTEGER, saturation AS SINGLE)
    DIM w AS LONG, imgHeight AS LONG, x AS LONG, y AS LONG
    DIM r AS INTEGER, g AS INTEGER, b AS INTEGER
    DIM hue AS SINGLE, sat AS SINGLE, value AS SINGLE
    
    w = _WIDTH(img): imgHeight = _HEIGHT(img)
    
    ' ULTRA-FAST: Use _MEMIMAGE for direct memory access
    DIM imgBlock AS _MEM
    imgBlock = _MEMIMAGE(img)
    DIM pixelSize AS INTEGER: pixelSize = 4 ' 32-bit RGBA
    DIM memOffset AS _OFFSET
    
    FOR y = 0 TO imgHeight - 1
        FOR x = 0 TO w - 1
            memOffset = y * w * pixelSize + x * pixelSize
            
            ' Read RGB directly from memory (BGR order in memory)
            b = _MEMGET(imgBlock, imgBlock.OFFSET + memOffset, _UNSIGNED _BYTE)
            g = _MEMGET(imgBlock, imgBlock.OFFSET + memOffset + 1, _UNSIGNED _BYTE)
            r = _MEMGET(imgBlock, imgBlock.OFFSET + memOffset + 2, _UNSIGNED _BYTE)
            
            ' Convert RGB to HSV
            CALL RGBtoHSV(r, g, b, hue, sat, value)
            
            ' Adjust hue and saturation (OPTIMIZED!)
            hue = hue + hueShift
            IF hue < 0 THEN hue = hue + 360
            IF hue >= 360 THEN hue = hue - 360
            sat = sat * saturation
            IF sat > 1 THEN sat = 1
            IF sat < 0 THEN sat = 0
            
            ' Convert back to RGB
            CALL HSVtoRGB(hue, sat, value, r, g, b)
            
            ' Write back to memory
            _MEMPUT imgBlock, imgBlock.OFFSET + memOffset, b AS _UNSIGNED _BYTE
            _MEMPUT imgBlock, imgBlock.OFFSET + memOffset + 1, g AS _UNSIGNED _BYTE
            _MEMPUT imgBlock, imgBlock.OFFSET + memOffset + 2, r AS _UNSIGNED _BYTE
        NEXT x
    NEXT y
    
    _MEMFREE imgBlock
END SUB

'$INCLUDE:'../core/adjustment_common.bas'
