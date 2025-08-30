' Pixelate Effect Test
' Standalone test for pixelate effect algorithm
$CONSOLE
_CONSOLE ON
PRINT "Pixelate Effect Test Starting..."

' Include our common framework
'$INCLUDE:'../core/adjustment_common.bi'

' Algorithm-specific forward declarations
DECLARE SUB ApplyPixelateEffect (img AS LONG, pixelSize AS INTEGER)
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
CALL InitializeGraphics("Pixelate Effect Test - +/-: adjust, R: reset, ESC: exit")

PRINT "Graphics screen created successfully!"
PRINT "Starting main loop - switch to graphics window!"
PRINT "Controls:"
PRINT "  +/- = adjust pixel size"
PRINT "  R = reset parameters"
PRINT "  ESC = exit"

' Apply initial adjustments
CALL ApplyAdjustments

DO
    _DEST 0 ' Graphics screen
    CLS
    CALL DrawUI("Pixelate Effect", "Creates pixelated look with specified pixel size." + CHR$(10) + "Reduces image resolution for retro effect." + CHR$(10) + "Popular for 8-bit and retro gaming aesthetic." + CHR$(10) + "Range: 1-100 pixel size")
    
    ' Store old parameter value to detect changes
    DIM oldSize AS SINGLE
    oldSize = parameters(0)
    
    CALL HandleInput
    
    ' Reapply adjustments if parameter changed
    IF parameters(0) <> oldSize THEN
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
    ' Setup pixelate parameter
    parameterCount = 1
    
    ' Pixel size parameter
    parameterNames(0) = "Pixel Size"
    parameterMins(0) = 1
    parameterMaxs(0) = 50  ' Reduced max for practicality
    parameterSteps(0) = 1
    parameters(0) = 8  ' Default to 8x8 pixels
    
    parameterIndex = 0
END SUB

SUB ApplyAdjustments
    _DEST _CONSOLE
    PRINT "Applying pixelate: size="; parameters(0)
    _DEST 0
    
    IF originalImage = 0 THEN 
        _DEST _CONSOLE
        PRINT "No original image!"
        _DEST 0
        EXIT SUB
    END IF
    
    IF adjustedImage <> 0 THEN _FREEIMAGE adjustedImage
    adjustedImage = _COPYIMAGE(originalImage, 32)
    
    ' Apply pixelate effect
    CALL ApplyPixelateEffect(adjustedImage, CINT(parameters(0)))
    
    _DEST _CONSOLE
    PRINT "Pixelate complete"
    _DEST 0
END SUB

' Pixelate Effect - Creates pixelated look with specified pixel size
SUB ApplyPixelateEffect (img AS LONG, pixelSize AS INTEGER)
    DIM x AS INTEGER, y AS INTEGER, px AS INTEGER, py AS INTEGER
    DIM totalR AS LONG, totalG AS LONG, totalB AS LONG, count AS INTEGER
    DIM r AS INTEGER, g AS INTEGER, b AS INTEGER
    DIM c AS _UNSIGNED LONG
    DIM oldSource AS LONG, oldDest AS LONG
    
    oldSource = _SOURCE
    oldDest = _DEST
    _SOURCE img
    _DEST img
    
    FOR y = 0 TO _HEIGHT(img) - 1 STEP pixelSize
        FOR x = 0 TO _WIDTH(img) - 1 STEP pixelSize
            totalR = 0: totalG = 0: totalB = 0: count = 0
            
            ' Sample the pixel block
            FOR py = y TO y + pixelSize - 1
                FOR px = x TO x + pixelSize - 1
                    IF px < _WIDTH(img) AND py < _HEIGHT(img) THEN
                        c = POINT(px, py)
                        r = _RED32(c): g = _GREEN32(c): b = _BLUE32(c)
                        totalR = totalR + r
                        totalG = totalG + g
                        totalB = totalB + b
                        count = count + 1
                    END IF
                NEXT px
            NEXT py
            
            ' Calculate average color
            IF count > 0 THEN
                r = totalR \ count
                g = totalG \ count
                b = totalB \ count
                
                ' Fill the entire pixel block with the average color
                FOR py = y TO y + pixelSize - 1
                    FOR px = x TO x + pixelSize - 1
                        IF px < _WIDTH(img) AND py < _HEIGHT(img) THEN
                            PSET (px, py), _RGB32(r, g, b)
                        END IF
                    NEXT px
                NEXT py
            END IF
        NEXT x
    NEXT y
    
    _SOURCE oldSource
    _DEST oldDest
END SUB

'$INCLUDE:'../core/adjustment_common.bas'
