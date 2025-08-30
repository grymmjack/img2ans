' Color Balance Test
' Standalone test for color balance algorithm
$CONSOLE
_CONSOLE ON
PRINT "Color Balance Test Starting..."

' Include our common framework
'$INCLUDE:'../core/adjustment_common.bi'

' Algorithm-specific forward declarations
DECLARE SUB ApplyColorBalance (img AS LONG, redShift AS INTEGER, greenShift AS INTEGER, blueShift AS INTEGER)
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
CALL InitializeGraphics("Color Balance Test - +/-: adjust, TAB: parameter, R: reset, ESC: exit")

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
    CALL DrawUI("Color Balance", "Independent RGB channel adjustment." + CHR$(10) + "Corrects color casts and white balance." + CHR$(10) + "Useful for temperature correction." + CHR$(10) + "Range: ±100 for each channel")
    
    ' Store old parameter values to detect changes
    DIM oldRed AS SINGLE, oldGreen AS SINGLE, oldBlue AS SINGLE
    oldRed = parameters(0)
    oldGreen = parameters(1)
    oldBlue = parameters(2)
    
    CALL HandleInput
    
    ' Reapply adjustments if parameters changed
    IF parameters(0) <> oldRed OR parameters(1) <> oldGreen OR parameters(2) <> oldBlue THEN
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
    ' Setup color balance parameters
    parameterCount = 3
    
    ' Red-Cyan balance
    parameterNames(0) = "Red-Cyan"
    parameterMins(0) = -100
    parameterMaxs(0) = 100
    parameterSteps(0) = 5
    parameters(0) = 0
    
    ' Green-Magenta balance
    parameterNames(1) = "Green-Magenta"
    parameterMins(1) = -100
    parameterMaxs(1) = 100
    parameterSteps(1) = 5
    parameters(1) = 0
    
    ' Blue-Yellow balance
    parameterNames(2) = "Blue-Yellow"
    parameterMins(2) = -100
    parameterMaxs(2) = 100
    parameterSteps(2) = 5
    parameters(2) = 0
    
    parameterIndex = 0
END SUB

SUB ApplyAdjustments
    _DEST _CONSOLE
    PRINT "Applying color balance: R="; parameters(0); ", G="; parameters(1); ", B="; parameters(2)
    _DEST 0
    
    IF originalImage = 0 THEN 
        _DEST _CONSOLE
        PRINT "No original image!"
        _DEST 0
        EXIT SUB
    END IF
    
    IF adjustedImage <> 0 THEN _FREEIMAGE adjustedImage
    adjustedImage = _COPYIMAGE(originalImage, 32)
    
    ' Apply color balance adjustment
    CALL ApplyColorBalance(adjustedImage, CINT(parameters(0)), CINT(parameters(1)), CINT(parameters(2)))
    
    _DEST _CONSOLE
    PRINT "Color balance complete"
    _DEST 0
END SUB

SUB ApplyColorBalance (img AS LONG, redShift AS INTEGER, greenShift AS INTEGER, blueShift AS INTEGER)
    DIM w AS LONG, h AS LONG, x AS LONG, y AS LONG, c AS _UNSIGNED LONG
    DIM r AS INTEGER, g AS INTEGER, b AS INTEGER
    
    w = _WIDTH(img): h = _HEIGHT(img)
    DIM old AS LONG: old = _SOURCE: _SOURCE img
    DIM oldW AS LONG: oldW = _DEST: _DEST img
    
    FOR y = 0 TO h - 1
        FOR x = 0 TO w - 1
            c = POINT(x, y)
            r = _RED32(c) + redShift
            g = _GREEN32(c) + greenShift
            b = _BLUE32(c) + blueShift
            IF r < 0 THEN r = 0 ELSE IF r > 255 THEN r = 255
            IF g < 0 THEN g = 0 ELSE IF g > 255 THEN g = 255
            IF b < 0 THEN b = 0 ELSE IF b > 255 THEN b = 255
            PSET (x, y), _RGB32(r, g, b)
        NEXT
    NEXT
    _SOURCE old: _DEST oldW
END SUB

'$INCLUDE:'../core/adjustment_common.bas'
