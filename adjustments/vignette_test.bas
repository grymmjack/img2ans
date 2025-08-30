' Vignette Effect Test
' Standalone test for vignette effect algorithm
$CONSOLE
_CONSOLE ON
PRINT "Vignette Effect Test Starting..."

' Include our common framework
'$INCLUDE:'../core/adjustment_common.bi'

' Algorithm-specific forward declarations
DECLARE SUB ApplyVignette (img AS LONG, strength AS SINGLE)
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
CALL InitializeGraphics("Vignette Effect Test - +/-: adjust, R: reset, ESC: exit")

PRINT "Graphics screen created successfully!"
PRINT "Starting main loop - switch to graphics window!"
PRINT "Controls:"
PRINT "  +/- = adjust vignette strength"
PRINT "  R = reset parameters"
PRINT "  ESC = exit"

' Apply initial adjustments
CALL ApplyAdjustments

DO
    _DEST 0 ' Graphics screen
    CLS
    CALL DrawUI("Vignette Effect", "Darkens image edges gradually." + CHR$(10) + "Creates lens vignetting effect." + CHR$(10) + "Draws focus to image center." + CHR$(10) + "Range: 0-100% strength")
    
    ' Store old parameter value to detect changes
    DIM oldStrength AS SINGLE
    oldStrength = parameters(0)
    
    CALL HandleInput
    
    ' Reapply adjustments if parameter changed
    IF parameters(0) <> oldStrength THEN
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
    ' Setup vignette parameter
    parameterCount = 1
    
    ' Strength parameter
    parameterNames(0) = "Strength"
    parameterMins(0) = 0
    parameterMaxs(0) = 100
    parameterSteps(0) = 5
    parameters(0) = 50  ' Default to 50% strength
    
    parameterIndex = 0
END SUB

SUB ApplyAdjustments
    DIM actualStrength AS SINGLE
    actualStrength = parameters(0) / 100.0
    
    _DEST _CONSOLE
    PRINT "Applying vignette: strength="; actualStrength
    _DEST 0
    
    IF originalImage = 0 THEN 
        _DEST _CONSOLE
        PRINT "No original image!"
        _DEST 0
        EXIT SUB
    END IF
    
    IF adjustedImage <> 0 THEN _FREEIMAGE adjustedImage
    adjustedImage = _COPYIMAGE(originalImage, 32)
    
    ' Apply vignette
    CALL ApplyVignette(adjustedImage, actualStrength)
    
    _DEST _CONSOLE
    PRINT "Vignette complete"
    _DEST 0
END SUB

SUB ApplyVignette (img AS LONG, strength AS SINGLE)
    DIM w AS LONG, h AS LONG, x AS LONG, y AS LONG, c AS _UNSIGNED LONG
    DIM r AS INTEGER, g AS INTEGER, b AS INTEGER
    DIM centerX AS SINGLE, centerY AS SINGLE, maxDist AS SINGLE, dist AS SINGLE, factor AS SINGLE
    
    w = _WIDTH(img): h = _HEIGHT(img)
    centerX = w / 2: centerY = h / 2
    maxDist = SQR(centerX * centerX + centerY * centerY)
    
    DIM old AS LONG: old = _SOURCE: _SOURCE img
    DIM oldW AS LONG: oldW = _DEST: _DEST img
    
    FOR y = 0 TO h - 1
        FOR x = 0 TO w - 1
            c = POINT(x, y)
            dist = SQR((x - centerX) * (x - centerX) + (y - centerY) * (y - centerY))
            factor = 1.0 - (dist / maxDist) * strength
            IF factor < 0 THEN factor = 0
            
            r = CINT(_RED32(c) * factor)
            g = CINT(_GREEN32(c) * factor)
            b = CINT(_BLUE32(c) * factor)
            PSET (x, y), _RGB32(r, g, b)
        NEXT
    NEXT
    _SOURCE old: _DEST oldW
END SUB

'$INCLUDE:'../core/adjustment_common.bas'
