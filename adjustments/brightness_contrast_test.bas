' Brightness and Contrast Adjustment Test
' Standalone test for brightness and contrast algorithms
$CONSOLE
_CONSOLE ON
PRINT "Brightness/Contrast Adjustment Test Starting..."

' Include our common framework
'$INCLUDE:'../core/adjustment_common.bi'

' Algorithm-specific forward declarations
DECLARE SUB ApplyBrightness (img AS LONG, offset AS INTEGER)
DECLARE SUB ApplyContrast (img AS LONG, pct AS INTEGER)
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
CALL InitializeGraphics("Brightness/Contrast Adjustment Test - +/-: adjust, TAB: parameter, R: reset, ESC: exit")

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
    CALL DrawUI("Brightness/Contrast", "Basic brightness and contrast adjustments." + CHR$(10) + "Brightness adds/subtracts from all channels." + CHR$(10) + "Contrast expands/compresses the tonal range." + CHR$(10) + "Range: Brightness ±255, Contrast ±100")
    
    ' Store old parameter values to detect changes
    DIM oldBrightness AS SINGLE, oldContrast AS SINGLE
    oldBrightness = parameters(0)
    oldContrast = parameters(1)
    
    CALL HandleInput
    
    ' Reapply adjustments if parameters changed
    IF parameters(0) <> oldBrightness OR parameters(1) <> oldContrast THEN
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
    ' Setup brightness and contrast parameters
    parameterCount = 2
    
    ' Brightness parameter
    parameterNames(0) = "Brightness"
    parameterMins(0) = -255
    parameterMaxs(0) = 255
    parameterSteps(0) = 5
    parameters(0) = 0
    
    ' Contrast parameter
    parameterNames(1) = "Contrast"
    parameterMins(1) = -100
    parameterMaxs(1) = 100
    parameterSteps(1) = 5
    parameters(1) = 0
    
    parameterIndex = 0
END SUB

SUB ApplyAdjustments
    _DEST _CONSOLE
    PRINT "Applying brightness/contrast adjustments: brightness="; parameters(0); ", contrast="; parameters(1)
    _DEST 0
    
    IF originalImage = 0 THEN 
        _DEST _CONSOLE
        PRINT "No original image!"
        _DEST 0
        EXIT SUB
    END IF
    
    IF adjustedImage <> 0 THEN _FREEIMAGE adjustedImage
    adjustedImage = _COPYIMAGE(originalImage, 32)
    
    ' Apply brightness adjustment
    IF parameters(0) <> 0 THEN CALL ApplyBrightness(adjustedImage, CINT(parameters(0)))
    
    ' Apply contrast adjustment  
    IF parameters(1) <> 0 THEN CALL ApplyContrast(adjustedImage, CINT(parameters(1)))
    
    _DEST _CONSOLE
    PRINT "Adjustments complete"
    _DEST 0
END SUB

SUB ApplyBrightness (img AS LONG, offset AS INTEGER)
    DIM w AS LONG, h AS LONG, x AS LONG, y AS LONG, c AS _UNSIGNED LONG
    DIM r AS INTEGER, g AS INTEGER, b AS INTEGER
    w = _WIDTH(img): h = _HEIGHT(img)
    DIM old AS LONG: old = _SOURCE: _SOURCE img
    DIM oldW AS LONG: oldW = _DEST: _DEST img
    FOR y = 0 TO h - 1
        FOR x = 0 TO w - 1
            c = POINT(x, y)
            r = _RED32(c) + offset
            g = _GREEN32(c) + offset
            b = _BLUE32(c) + offset
            IF r < 0 THEN r = 0 ELSE IF r > 255 THEN r = 255
            IF g < 0 THEN g = 0 ELSE IF g > 255 THEN g = 255
            IF b < 0 THEN b = 0 ELSE IF b > 255 THEN b = 255
            PSET (x, y), _RGB32(r, g, b)
        NEXT
    NEXT
    _SOURCE old: _DEST oldW
END SUB

SUB ApplyContrast (img AS LONG, pct AS INTEGER)
    IF pct < -100 THEN pct = -100
    IF pct > 100 THEN pct = 100
    DIM f AS DOUBLE
    f = (259.0 * (pct + 255.0)) / (255.0 * (259.0 - pct))

    DIM w AS LONG, h AS LONG, x AS LONG, y AS LONG, c AS _UNSIGNED LONG
    DIM r AS INTEGER, g AS INTEGER, b AS INTEGER
    w = _WIDTH(img): h = _HEIGHT(img)
    DIM old AS LONG: old = _SOURCE: _SOURCE img
    DIM oldW AS LONG: oldW = _DEST: _DEST img
    FOR y = 0 TO h - 1
        FOR x = 0 TO w - 1
            c = POINT(x, y)
            r = CINT(f * (_RED32(c) - 128) + 128)
            g = CINT(f * (_GREEN32(c) - 128) + 128)
            b = CINT(f * (_BLUE32(c) - 128) + 128)
            IF r < 0 THEN r = 0 ELSE IF r > 255 THEN r = 255
            IF g < 0 THEN g = 0 ELSE IF g > 255 THEN g = 255
            IF b < 0 THEN b = 0 ELSE IF b > 255 THEN b = 255
            PSET (x, y), _RGB32(r, g, b)
        NEXT
    NEXT
    _SOURCE old: _DEST oldW
END SUB

'$INCLUDE:'../core/adjustment_common.bas'
