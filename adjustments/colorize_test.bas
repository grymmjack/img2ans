' Colorize Test
' Standalone test for colorize algorithm
$CONSOLE
_CONSOLE ON
PRINT "Colorize Test Starting..."

' Include our common framework
'$INCLUDE:'../core/adjustment_common.bi'

' Algorithm-specific forward declarations
DECLARE SUB ApplyColorize (img AS LONG, hue AS INTEGER, saturation AS SINGLE)
DECLARE SUB ApplyDesaturate (img AS LONG, method AS INTEGER)
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
CALL InitializeGraphics("Colorize Test - +/-: adjust, TAB: parameter, R: reset, ESC: exit")

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
    CALL DrawUI("Colorize", "Applies single hue to grayscale." + CHR$(10) + "Creates tinted monochrome effect." + CHR$(10) + "Useful for mood and atmosphere." + CHR$(10) + "Hue: 0-360°, Saturation: 0-200%")
    
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
    ' Setup colorize parameters
    parameterCount = 2
    
    ' Hue parameter
    parameterNames(0) = "Hue"
    parameterMins(0) = 0
    parameterMaxs(0) = 360
    parameterSteps(0) = 10
    parameters(0) = 30  ' Default to orange/sepia-like
    
    ' Saturation parameter
    parameterNames(1) = "Saturation"
    parameterMins(1) = 0
    parameterMaxs(1) = 200
    parameterSteps(1) = 10
    parameters(1) = 50  ' Default to moderate saturation
    
    parameterIndex = 0
END SUB

SUB ApplyAdjustments
    DIM actualSaturation AS SINGLE
    actualSaturation = parameters(1) / 100.0
    
    _DEST _CONSOLE
    PRINT "Applying colorize: hue="; parameters(0); "°, saturation="; actualSaturation
    _DEST 0
    
    IF originalImage = 0 THEN 
        _DEST _CONSOLE
        PRINT "No original image!"
        _DEST 0
        EXIT SUB
    END IF
    
    IF adjustedImage <> 0 THEN _FREEIMAGE adjustedImage
    adjustedImage = _COPYIMAGE(originalImage, 32)
    
    ' Apply colorize
    CALL ApplyColorize(adjustedImage, CINT(parameters(0)), actualSaturation)
    
    _DEST _CONSOLE
    PRINT "Colorize complete"
    _DEST 0
END SUB

SUB ApplyColorize (img AS LONG, hue AS INTEGER, saturation AS SINGLE)
    ' First desaturate, then apply color
    CALL ApplyDesaturate(img, 0)
    
    DIM w AS LONG, imgHeight AS LONG, x AS LONG, y AS LONG, c AS _UNSIGNED LONG
    DIM r AS INTEGER, g AS INTEGER, b AS INTEGER, gray AS INTEGER
    DIM hueVal AS SINGLE, satVal AS SINGLE, valueVal AS SINGLE
    
    w = _WIDTH(img): imgHeight = _HEIGHT(img)
    DIM old AS LONG: old = _SOURCE: _SOURCE img
    DIM oldW AS LONG: oldW = _DEST: _DEST img
    
    FOR y = 0 TO imgHeight - 1
        FOR x = 0 TO w - 1
            c = POINT(x, y)
            gray = _RED32(c) ' Already grayscale
            
            ' Convert to HSV and apply color
            hueVal = hue
            satVal = saturation
            valueVal = gray / 255.0
            
            CALL HSVtoRGB(hueVal, satVal, valueVal, r, g, b)
            PSET (x, y), _RGB32(r, g, b)
        NEXT
    NEXT
    _SOURCE old: _DEST oldW
END SUB

SUB ApplyDesaturate (img AS LONG, method AS INTEGER)
    DIM w AS LONG, h AS LONG, x AS LONG, y AS LONG, c AS _UNSIGNED LONG
    DIM gray AS INTEGER
    
    w = _WIDTH(img): h = _HEIGHT(img)
    DIM old AS LONG: old = _SOURCE: _SOURCE img
    DIM oldW AS LONG: oldW = _DEST: _DEST img
    
    FOR y = 0 TO h - 1
        FOR x = 0 TO w - 1
            c = POINT(x, y)
            ' Luminance-based grayscale
            gray = CINT(_RED32(c) * 0.299 + _GREEN32(c) * 0.587 + _BLUE32(c) * 0.114)
            PSET (x, y), _RGB32(gray, gray, gray)
        NEXT
    NEXT
    _SOURCE old: _DEST oldW
END SUB

'$INCLUDE:'../core/adjustment_common.bas'
