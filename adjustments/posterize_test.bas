' Posterize Test
' Standalone test for posterize algorithm (color quantization)
$CONSOLE
_CONSOLE ON
PRINT "Posterize Test Starting..."

' Include our common framework
'$INCLUDE:'../core/adjustment_common.bi'

' Algorithm-specific forward declarations
DECLARE SUB ApplyColorQuantization (img AS LONG, sourceImg AS LONG, numColors AS INTEGER)
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
CALL InitializeGraphics("Posterize Test - +/-: adjust, R: reset, ESC: exit")

PRINT "Graphics screen created successfully!"
PRINT "Starting main loop - switch to graphics window!"
PRINT "Controls:"
PRINT "  +/- = adjust total colors"
PRINT "  R = reset parameters"
PRINT "  ESC = exit"

' Apply initial adjustments
CALL ApplyAdjustments

DO
    _DEST 0 ' Graphics screen
    CLS
    CALL DrawUI("Posterize", "Reduces colors to specific levels." + CHR$(10) + "Creates banded, artistic effect." + CHR$(10) + "Popular in pop art and comics." + CHR$(10) + "Range: 2-256 total colors")
    
    ' Store old parameter value to detect changes
    DIM oldColors AS SINGLE
    oldColors = parameters(0)
    
    CALL HandleInput
    
    ' Reapply adjustments if parameter changed
    IF parameters(0) <> oldColors THEN
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
    ' Setup posterize parameter
    parameterCount = 1
    
    ' Total colors parameter
    parameterNames(0) = "Total Colors"
    parameterMins(0) = 2
    parameterMaxs(0) = 256
    parameterSteps(0) = 1
    parameters(0) = 16  ' Default to 16 colors
    
    parameterIndex = 0
END SUB

SUB ApplyAdjustments
    _DEST _CONSOLE
    PRINT "Applying posterize: colors="; parameters(0)
    _DEST 0
    
    IF originalImage = 0 THEN 
        _DEST _CONSOLE
        PRINT "No original image!"
        _DEST 0
        EXIT SUB
    END IF
    
    IF adjustedImage <> 0 THEN _FREEIMAGE adjustedImage
    adjustedImage = _COPYIMAGE(originalImage, 32)
    
    ' Apply posterize
    IF parameters(0) >= 2 THEN
        CALL ApplyColorQuantization(adjustedImage, originalImage, CINT(parameters(0)))
    END IF
    
    _DEST _CONSOLE
    PRINT "Posterize complete"
    _DEST 0
END SUB

' True color quantization - reduces image to specified number of total colors
SUB ApplyColorQuantization (img AS LONG, sourceImg AS LONG, numColors AS INTEGER)
    IF numColors < 2 OR numColors > 256 THEN EXIT SUB
    
    ' Dead simple posterize - just reduce each channel to fewer levels
    DIM w AS LONG, h AS LONG, x AS LONG, y AS LONG
    
    w = _WIDTH(img): h = _HEIGHT(img)
    DIM oldSrc AS LONG: oldSrc = _SOURCE: _SOURCE img
    DIM oldDest AS LONG: oldDest = _DEST: _DEST img
    
    ' Calculate how many levels per channel based on color count
    DIM levels AS INTEGER
    IF numColors <= 8 THEN 
        levels = 2
    ELSEIF numColors <= 27 THEN 
        levels = 3
    ELSEIF numColors <= 64 THEN 
        levels = 4
    ELSEIF numColors <= 125 THEN 
        levels = 5
    ELSE 
        levels = 6
    END IF
    
    ' Process each pixel
    FOR y = 0 TO h - 1
        FOR x = 0 TO w - 1
            DIM pixel AS _UNSIGNED LONG
            pixel = POINT(x, y)
            DIM r AS INTEGER, g AS INTEGER, b AS INTEGER
            r = _RED32(pixel)
            g = _GREEN32(pixel)
            b = _BLUE32(pixel)
            
            ' Simple level reduction
            DIM newR AS INTEGER, newG AS INTEGER, newB AS INTEGER
            newR = (r * (levels - 1)) \ 255
            newG = (g * (levels - 1)) \ 255  
            newB = (b * (levels - 1)) \ 255
            
            ' Scale back to 0-255
            newR = (newR * 255) \ (levels - 1)
            newG = (newG * 255) \ (levels - 1)
            newB = (newB * 255) \ (levels - 1)
            
            PSET (x, y), _RGB32(newR, newG, newB)
        NEXT
    NEXT
    _SOURCE oldSrc: _DEST oldDest
END SUB

'$INCLUDE:'../core/adjustment_common.bas'
