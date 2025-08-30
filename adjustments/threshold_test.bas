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
    DIM w AS LONG, h AS LONG, x AS LONG, y AS LONG
    DIM gray AS INTEGER
    DIM r AS INTEGER, g AS INTEGER, b AS INTEGER
    DIM result AS INTEGER
    
    w = _WIDTH(img): h = _HEIGHT(img)
    
    ' ULTRA-FAST: Use _MEMIMAGE for direct memory access
    DIM imgBlock AS _MEM
    imgBlock = _MEMIMAGE(img)
    DIM pixelSize AS INTEGER: pixelSize = 4 ' 32-bit RGBA
    DIM memOffset AS _OFFSET
    
    FOR y = 0 TO h - 1
        FOR x = 0 TO w - 1
            memOffset = y * w * pixelSize + x * pixelSize
            
            ' Read RGB directly from memory (BGR order in memory)
            b = _MEMGET(imgBlock, imgBlock.OFFSET + memOffset, _UNSIGNED _BYTE)
            g = _MEMGET(imgBlock, imgBlock.OFFSET + memOffset + 1, _UNSIGNED _BYTE)
            r = _MEMGET(imgBlock, imgBlock.OFFSET + memOffset + 2, _UNSIGNED _BYTE)
            
            ' Calculate grayscale and apply threshold (BLAZING FAST!)
            gray = (r + g + b) \ 3
            IF gray > threshold THEN result = 255 ELSE result = 0
            
            ' Write back to memory
            _MEMPUT imgBlock, imgBlock.OFFSET + memOffset, result AS _UNSIGNED _BYTE
            _MEMPUT imgBlock, imgBlock.OFFSET + memOffset + 1, result AS _UNSIGNED _BYTE
            _MEMPUT imgBlock, imgBlock.OFFSET + memOffset + 2, result AS _UNSIGNED _BYTE
        NEXT x
    NEXT y
    
    _MEMFREE imgBlock
END SUB

'$INCLUDE:'../core/adjustment_common.bas'
