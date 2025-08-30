' Film Grain Test
' Standalone test for film grain effect algorithm
$CONSOLE
_CONSOLE ON
PRINT "Film Grain Test Starting..."

' Include our common framework
'$INCLUDE:'../core/adjustment_common.bi'

' Algorithm-specific forward declarations
DECLARE SUB ApplyFilmGrain (img AS LONG, amount AS INTEGER)
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
CALL InitializeGraphics("Film Grain Test - +/-: adjust, R: reset, ESC: exit")

PRINT "Graphics screen created successfully!"
PRINT "Starting main loop - switch to graphics window!"
PRINT "Controls:"
PRINT "  +/- = adjust grain intensity"
PRINT "  R = reset parameters"
PRINT "  ESC = exit"

' Apply initial adjustments
CALL ApplyAdjustments

DO
    _DEST 0 ' Graphics screen
    CLS
    CALL DrawUI("Film Grain", "Adds realistic film grain texture." + CHR$(10) + "Simulates analog photography." + CHR$(10) + "Creates organic, vintage feel." + CHR$(10) + "Range: 0-100 intensity")
    
    ' Store old parameter value to detect changes
    DIM oldIntensity AS SINGLE
    oldIntensity = parameters(0)
    
    CALL HandleInput
    
    ' Reapply adjustments if parameter changed
    IF parameters(0) <> oldIntensity THEN
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
    ' Setup film grain parameter
    parameterCount = 1
    
    ' Intensity parameter
    parameterNames(0) = "Intensity"
    parameterMins(0) = 0
    parameterMaxs(0) = 100
    parameterSteps(0) = 5
    parameters(0) = 25  ' Default to 25% intensity
    
    parameterIndex = 0
END SUB

SUB ApplyAdjustments
    _DEST _CONSOLE
    PRINT "Applying film grain: intensity="; parameters(0)
    _DEST 0
    
    IF originalImage = 0 THEN 
        _DEST _CONSOLE
        PRINT "No original image!"
        _DEST 0
        EXIT SUB
    END IF
    
    IF adjustedImage <> 0 THEN _FREEIMAGE adjustedImage
    adjustedImage = _COPYIMAGE(originalImage, 32)
    
    ' Apply film grain
    CALL ApplyFilmGrain(adjustedImage, CINT(parameters(0)))
    
    _DEST _CONSOLE
    PRINT "Film grain complete"
    _DEST 0
END SUB

SUB ApplyFilmGrain (img AS LONG, amount AS INTEGER)
    DIM w AS LONG, h AS LONG, x AS LONG, y AS LONG, c AS _UNSIGNED LONG
    DIM r AS INTEGER, g AS INTEGER, b AS INTEGER, noise AS INTEGER
    
    w = _WIDTH(img): h = _HEIGHT(img)
    DIM old AS LONG: old = _SOURCE: _SOURCE img
    DIM oldW AS LONG: oldW = _DEST: _DEST img
    
    RANDOMIZE TIMER
    
    FOR y = 0 TO h - 1
        FOR x = 0 TO w - 1
            c = POINT(x, y)
            noise = (RND * amount * 2) - amount
            r = _RED32(c) + noise
            g = _GREEN32(c) + noise
            b = _BLUE32(c) + noise
            IF r < 0 THEN r = 0 ELSE IF r > 255 THEN r = 255
            IF g < 0 THEN g = 0 ELSE IF g > 255 THEN g = 255
            IF b < 0 THEN b = 0 ELSE IF b > 255 THEN b = 255
            PSET (x, y), _RGB32(r, g, b)
        NEXT
    NEXT
    _SOURCE old: _DEST oldW
END SUB

'$INCLUDE:'../core/adjustment_common.bas'
