' Blur Effect Test
' Standalone test for blur effect algorithm
$CONSOLE
_CONSOLE ON
PRINT "Blur Effect Test Starting..."

' Include our common framework
'$INCLUDE:'../core/adjustment_common.bi'

' Algorithm-specific forward declarations
DECLARE SUB ApplyBlurEffect (img AS LONG, radius AS INTEGER)
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
CALL InitializeGraphics("Blur Effect Test - +/-: adjust, R: reset, ESC: exit")

PRINT "Graphics screen created successfully!"
PRINT "Starting main loop - switch to graphics window!"
PRINT "Controls:"
PRINT "  +/- = adjust blur radius"
PRINT "  R = reset parameters"
PRINT "  ESC = exit"

' Apply initial adjustments
CALL ApplyAdjustments

DO
    _DEST 0 ' Graphics screen
    CLS
    CALL DrawUI("Blur Effect", "Applies a box blur with specified radius." + CHR$(10) + "Softens edges and reduces detail." + CHR$(10) + "Useful for depth of field effects." + CHR$(10) + "Range: 1-15 pixel radius")
    
    ' Store old parameter value to detect changes
    DIM oldRadius AS SINGLE
    oldRadius = parameters(0)
    
    CALL HandleInput
    
    ' Reapply adjustments if parameter changed
    IF parameters(0) <> oldRadius THEN
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
    ' Setup blur parameter
    parameterCount = 1
    
    ' Blur radius parameter
    parameterNames(0) = "Blur Radius"
    parameterMins(0) = 1
    parameterMaxs(0) = 15
    parameterSteps(0) = 1
    parameters(0) = 3  ' Default to 3 pixel radius
    
    parameterIndex = 0
END SUB

SUB ApplyAdjustments
    _DEST _CONSOLE
    PRINT "Applying blur: radius="; parameters(0)
    _DEST 0
    
    IF originalImage = 0 THEN 
        _DEST _CONSOLE
        PRINT "No original image!"
        _DEST 0
        EXIT SUB
    END IF
    
    IF adjustedImage <> 0 THEN _FREEIMAGE adjustedImage
    adjustedImage = _COPYIMAGE(originalImage, 32)
    
    ' Apply blur effect
    CALL ApplyBlurEffect(adjustedImage, CINT(parameters(0)))
    
    _DEST _CONSOLE
    PRINT "Blur complete"
    _DEST 0
END SUB

' Blur Effect - Applies a box blur with specified radius
SUB ApplyBlurEffect (img AS LONG, radius AS INTEGER)
    DIM tempImg AS LONG
    DIM x AS INTEGER, y AS INTEGER, dx AS INTEGER, dy AS INTEGER
    DIM totalR AS LONG, totalG AS LONG, totalB AS LONG, count AS INTEGER
    DIM r AS INTEGER, g AS INTEGER, b AS INTEGER
    DIM c AS _UNSIGNED LONG
    DIM oldSource AS LONG, oldDest AS LONG
    
    oldSource = _SOURCE
    oldDest = _DEST
    
    tempImg = _COPYIMAGE(img, 32)
    _SOURCE tempImg
    _DEST img
    
    FOR y = 0 TO _HEIGHT(img) - 1
        FOR x = 0 TO _WIDTH(img) - 1
            totalR = 0: totalG = 0: totalB = 0: count = 0
            
            ' Sample surrounding pixels
            FOR dy = -radius TO radius
                FOR dx = -radius TO radius
                    IF x + dx >= 0 AND x + dx < _WIDTH(img) AND y + dy >= 0 AND y + dy < _HEIGHT(img) THEN
                        c = POINT(x + dx, y + dy)
                        r = _RED32(c): g = _GREEN32(c): b = _BLUE32(c)
                        totalR = totalR + r
                        totalG = totalG + g
                        totalB = totalB + b
                        count = count + 1
                    END IF
                NEXT dx
            NEXT dy
            
            IF count > 0 THEN
                r = totalR \ count
                g = totalG \ count
                b = totalB \ count
                PSET (x, y), _RGB32(r, g, b)
            END IF
        NEXT x
    NEXT y
    
    _FREEIMAGE tempImg
    _SOURCE oldSource
    _DEST oldDest
END SUB

'$INCLUDE:'../core/adjustment_common.bas'
