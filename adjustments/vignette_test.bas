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
    parameterMaxs(0) = 255
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
    DIM w AS LONG, h AS LONG, x AS LONG, y AS LONG
    DIM r AS INTEGER, g AS INTEGER, b AS INTEGER
    DIM centerX AS SINGLE, centerY AS SINGLE, maxDistSq AS SINGLE, distSq AS SINGLE, factor AS SINGLE
    DIM dx AS SINGLE, dy AS SINGLE
    
    w = _WIDTH(img): h = _HEIGHT(img)
    centerX = w / 2: centerY = h / 2
    maxDistSq = centerX * centerX + centerY * centerY  ' Use squared distance to avoid SQR
    
    ' ULTRA-FAST: Use _MEMIMAGE for direct memory access
    DIM imgBlock AS _MEM
    imgBlock = _MEMIMAGE(img)
    DIM pixelSize AS INTEGER: pixelSize = 4 ' 32-bit RGBA
    DIM memOffset AS _OFFSET
    
    FOR y = 0 TO h - 1
        dy = y - centerY
        FOR x = 0 TO w - 1
            dx = x - centerX
            memOffset = y * w * pixelSize + x * pixelSize
            
            ' Read RGB directly from memory (BGR order in memory)
            b = _MEMGET(imgBlock, imgBlock.OFFSET + memOffset, _UNSIGNED _BYTE)
            g = _MEMGET(imgBlock, imgBlock.OFFSET + memOffset + 1, _UNSIGNED _BYTE)
            r = _MEMGET(imgBlock, imgBlock.OFFSET + memOffset + 2, _UNSIGNED _BYTE)
            
            ' OPTIMIZED: Use squared distance to avoid expensive SQR calls
            distSq = dx * dx + dy * dy
            factor = 1.0 - (distSq / maxDistSq) * strength
            IF factor < 0 THEN factor = 0
            
            ' Apply vignette factor (BLAZING FAST!)
            r = CINT(r * factor)
            g = CINT(g * factor)
            b = CINT(b * factor)
            
            ' Write back to memory
            _MEMPUT imgBlock, imgBlock.OFFSET + memOffset, b AS _UNSIGNED _BYTE
            _MEMPUT imgBlock, imgBlock.OFFSET + memOffset + 1, g AS _UNSIGNED _BYTE
            _MEMPUT imgBlock, imgBlock.OFFSET + memOffset + 2, r AS _UNSIGNED _BYTE
        NEXT x
    NEXT y
    
    _MEMFREE imgBlock
END SUB

'$INCLUDE:'../core/adjustment_common.bas'
