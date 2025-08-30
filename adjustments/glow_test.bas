' Glow Effect Test
' Standalone test for glow effect algorithm
$CONSOLE
_CONSOLE ON
PRINT "Glow Effect Test Starting..."

' Include our common framework
'$INCLUDE:'../core/adjustment_common.bi'

' Algorithm-specific forward declarations
DECLARE SUB ApplyGlowEffect (img AS LONG, glowRadius AS INTEGER, intensity AS INTEGER)
DECLARE SUB ApplyBlurToImage (img AS LONG, radius AS INTEGER)
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
CALL InitializeGraphics("Glow Effect Test - +/-: adjust, TAB: parameter, R: reset, ESC: exit")

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
    CALL DrawUI("Glow Effect", "Adds a soft glow around bright areas." + CHR$(10) + "Creates luminous, ethereal effect." + CHR$(10) + "Enhances highlights and bright details." + CHR$(10) + "Radius: 1-10, Intensity: 10-100%")
    
    ' Store old parameter values to detect changes
    DIM oldRadius AS SINGLE, oldIntensity AS SINGLE
    oldRadius = parameters(0)
    oldIntensity = parameters(1)
    
    CALL HandleInput
    
    ' Reapply adjustments if parameters changed
    IF parameters(0) <> oldRadius OR parameters(1) <> oldIntensity THEN
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
    ' Setup glow effect parameters
    parameterCount = 2
    
    ' Glow radius parameter
    parameterNames(0) = "Glow Radius"
    parameterMins(0) = 1
    parameterMaxs(0) = 10
    parameterSteps(0) = 1
    parameters(0) = 3  ' Default to 3 pixel radius
    
    ' Glow intensity parameter
    parameterNames(1) = "Glow Intensity"
    parameterMins(1) = 10
    parameterMaxs(1) = 100
    parameterSteps(1) = 5
    parameters(1) = 50  ' Default to 50% intensity
    
    parameterIndex = 0
END SUB

SUB ApplyAdjustments
    _DEST _CONSOLE
    PRINT "Applying glow: radius="; parameters(0); ", intensity="; parameters(1)
    _DEST 0
    
    IF originalImage = 0 THEN 
        _DEST _CONSOLE
        PRINT "No original image!"
        _DEST 0
        EXIT SUB
    END IF
    
    IF adjustedImage <> 0 THEN _FREEIMAGE adjustedImage
    adjustedImage = _COPYIMAGE(originalImage, 32)
    
    ' Apply glow effect
    CALL ApplyGlowEffect(adjustedImage, CINT(parameters(0)), CINT(parameters(1)))
    
    _DEST _CONSOLE
    PRINT "Glow effect complete"
    _DEST 0
END SUB

' Glow Effect - Adds a soft glow around bright areas
SUB ApplyGlowEffect (img AS LONG, glowRadius AS INTEGER, intensity AS INTEGER)
    DIM tempImg AS LONG, glowImg AS LONG
    DIM x AS INTEGER, y AS INTEGER, dx AS INTEGER, dy AS INTEGER
    DIM r AS INTEGER, g AS INTEGER, b AS INTEGER
    DIM brightness AS SINGLE, glowAmount AS SINGLE
    DIM c AS _UNSIGNED LONG, gc AS _UNSIGNED LONG
    DIM gr AS INTEGER, gg AS INTEGER, gb AS INTEGER
    DIM finalR AS INTEGER, finalG AS INTEGER, finalB AS INTEGER
    DIM oldSource AS LONG, oldDest AS LONG
    
    oldSource = _SOURCE
    oldDest = _DEST
    
    tempImg = _COPYIMAGE(img, 32)
    glowImg = _NEWIMAGE(_WIDTH(img), _HEIGHT(img), 32)
    
    ' First pass: Create glow map from bright areas
    _SOURCE tempImg
    _DEST glowImg
    
    FOR y = 0 TO _HEIGHT(img) - 1
        FOR x = 0 TO _WIDTH(img) - 1
            c = POINT(x, y)
            r = _RED32(c): g = _GREEN32(c): b = _BLUE32(c)
            
            ' Calculate brightness
            brightness = (r + g + b) / (3 * 255.0)
            
            ' Only bright areas contribute to glow
            IF brightness > 0.7 THEN
                glowAmount = (brightness - 0.7) / 0.3 ' Scale from 0.7-1.0 to 0.0-1.0
                gr = CINT(r * glowAmount)
                gg = CINT(g * glowAmount)
                gb = CINT(b * glowAmount)
                PSET (x, y), _RGB32(gr, gg, gb)
            ELSE
                PSET (x, y), _RGB32(0, 0, 0)
            END IF
        NEXT x
    NEXT y
    
    ' Second pass: Blur the glow map
    CALL ApplyBlurToImage(glowImg, glowRadius)
    
    ' Third pass: Combine original with glow
    _SOURCE tempImg
    _DEST img
    
    FOR y = 0 TO _HEIGHT(img) - 1
        FOR x = 0 TO _WIDTH(img) - 1
            ' Get original pixel
            c = POINT(x, y)
            r = _RED32(c): g = _GREEN32(c): b = _BLUE32(c)
            
            ' Get glow pixel
            _SOURCE glowImg
            gc = POINT(x, y)
            _SOURCE tempImg
            gr = _RED32(gc): gg = _GREEN32(gc): gb = _BLUE32(gc)
            
            ' Combine with intensity scaling
            finalR = r + CINT(gr * intensity / 100.0)
            finalG = g + CINT(gg * intensity / 100.0)
            finalB = b + CINT(gb * intensity / 100.0)
            
            ' Clamp values
            IF finalR > 255 THEN finalR = 255
            IF finalG > 255 THEN finalG = 255
            IF finalB > 255 THEN finalB = 255
            
            PSET (x, y), _RGB32(finalR, finalG, finalB)
        NEXT x
    NEXT y
    
    _FREEIMAGE tempImg
    _FREEIMAGE glowImg
    _SOURCE oldSource
    _DEST oldDest
END SUB

' Helper function for glow effect blur
SUB ApplyBlurToImage (img AS LONG, radius AS INTEGER)
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
