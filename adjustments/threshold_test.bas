' Threshold Test
' Standalone test for threshold algorithm (black and white conversion)
$CONSOLE
_CONSOLE ON
PRINT "Threshold Test Starting..."

' Include our common framework
'$INCLUDE:'../core/adjustment_common.bi'

' Algorithm-specific forward declarations
DECLARE SUB ApplyThreshold (img AS LONG, threshold AS INTEGER, mode AS INTEGER)
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
CALL InitializeGraphics("Threshold Test - +/-: adjust, R: reset, ESC: exit")

PRINT "Graphics screen created successfully!"
PRINT "Starting main loop - switch to graphics window!"
PRINT "Controls:"
PRINT "  +/- = adjust threshold value"
PRINT "  R = reset parameters"
PRINT "  ESC = exit"

' Apply initial adjustments
CALL ApplyAdjustments

DO
    _DEST 0 ' Graphics screen
    CLS
    CALL DrawUI("Threshold", "Binary threshold conversion." + CHR$(10) + "Converts to pure black/white." + CHR$(10) + "Useful for line art and logos." + CHR$(10) + "Range: 28-228 (offset from 128)")
    
    ' Store old parameter value to detect changes
    DIM oldThreshold AS SINGLE
    oldThreshold = parameters(0)
    
    CALL HandleInput
    
    ' Reapply adjustments if parameter changed
    IF parameters(0) <> oldThreshold THEN
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
    ' Setup threshold parameter
    parameterCount = 1
    
    ' Threshold parameter (offset from base 128)
    parameterNames(0) = "Threshold"
    parameterMins(0) = -100  ' 128 - 100 = 28
    parameterMaxs(0) = 100   ' 128 + 100 = 228
    parameterSteps(0) = 5
    parameters(0) = 0        ' Default to 128
    
    parameterIndex = 0
END SUB

SUB ApplyAdjustments
    DIM actualThreshold AS INTEGER
    actualThreshold = 128 + CINT(parameters(0))
    
    _DEST _CONSOLE
    PRINT "Applying threshold: threshold="; actualThreshold
    _DEST 0
    
    IF originalImage = 0 THEN 
        _DEST _CONSOLE
        PRINT "No original image!"
        _DEST 0
        EXIT SUB
    END IF
    
    IF adjustedImage <> 0 THEN _FREEIMAGE adjustedImage
    adjustedImage = _COPYIMAGE(originalImage, 32)
    
    ' Apply threshold
    CALL ApplyThreshold(adjustedImage, actualThreshold, 0)
    
    _DEST _CONSOLE
    PRINT "Threshold complete"
    _DEST 0
END SUB

SUB ApplyThreshold (img AS LONG, threshold AS INTEGER, mode AS INTEGER)
    DIM w AS LONG, h AS LONG, x AS LONG, y AS LONG, c AS _UNSIGNED LONG
    DIM gray AS INTEGER
    
    w = _WIDTH(img): h = _HEIGHT(img)
    DIM old AS LONG: old = _SOURCE: _SOURCE img
    DIM oldW AS LONG: oldW = _DEST: _DEST img
    
    FOR y = 0 TO h - 1
        FOR x = 0 TO w - 1
            c = POINT(x, y)
            gray = (_RED32(c) + _GREEN32(c) + _BLUE32(c)) \ 3
            IF gray > threshold THEN
                PSET (x, y), _RGB32(255, 255, 255)
            ELSE
                PSET (x, y), _RGB32(0, 0, 0)
            END IF
        NEXT
    NEXT
    _SOURCE old: _DEST oldW
END SUB

'$INCLUDE:'../core/adjustment_common.bas'
