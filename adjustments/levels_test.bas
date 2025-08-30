' Levels Adjustment Test
' Standalone test for levels adjustment algorithm
$CONSOLE
_CONSOLE ON
PRINT "Levels Adjustment Test Starting..."

' Include our common framework
'$INCLUDE:'../core/adjustment_common.bi'

' Algorithm-specific forward declarations
DECLARE SUB ApplyLevels (img AS LONG, inputMin AS INTEGER, inputMax AS INTEGER, outputMin AS INTEGER, outputMax AS INTEGER)
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
CALL InitializeGraphics("Levels Adjustment Test - +/-: adjust, TAB: parameter, R: reset, ESC: exit")

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
    CALL DrawUI("Levels Adjustment", "Input and output level mapping." + CHR$(10) + "Adjusts black/white points." + CHR$(10) + "Professional exposure correction." + CHR$(10) + "Range: ±50 for shadow/highlight inputs")
    
    ' Store old parameter values to detect changes
    DIM oldShadow AS SINGLE, oldHighlight AS SINGLE
    oldShadow = parameters(0)
    oldHighlight = parameters(1)
    
    CALL HandleInput
    
    ' Reapply adjustments if parameters changed
    IF parameters(0) <> oldShadow OR parameters(1) <> oldHighlight THEN
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
    ' Setup levels parameters
    parameterCount = 2
    
    ' Shadow input parameter
    parameterNames(0) = "Shadow Input"
    parameterMins(0) = -50
    parameterMaxs(0) = 50
    parameterSteps(0) = 5
    parameters(0) = 0
    
    ' Highlight input parameter
    parameterNames(1) = "Highlight Input"
    parameterMins(1) = -50
    parameterMaxs(1) = 50
    parameterSteps(1) = 5
    parameters(1) = 0
    
    parameterIndex = 0
END SUB

SUB ApplyAdjustments
    _DEST _CONSOLE
    PRINT "Applying levels: shadow="; parameters(0); ", highlight="; parameters(1)
    _DEST 0
    
    IF originalImage = 0 THEN 
        _DEST _CONSOLE
        PRINT "No original image!"
        _DEST 0
        EXIT SUB
    END IF
    
    IF adjustedImage <> 0 THEN _FREEIMAGE adjustedImage
    adjustedImage = _COPYIMAGE(originalImage, 32)
    
    ' Apply levels adjustment
    CALL ApplyLevels(adjustedImage, 0, 255, CINT(parameters(0)), 255 + CINT(parameters(1)))
    
    _DEST _CONSOLE
    PRINT "Levels adjustment complete"
    _DEST 0
END SUB

SUB ApplyLevels (img AS LONG, inputMin AS INTEGER, inputMax AS INTEGER, outputMin AS INTEGER, outputMax AS INTEGER)
    DIM w AS LONG, h AS LONG, x AS LONG, y AS LONG
    DIM r AS INTEGER, g AS INTEGER, b AS INTEGER
    DIM inputRange AS SINGLE, outputRange AS SINGLE
    
    inputRange = inputMax - inputMin
    outputRange = outputMax - outputMin
    IF inputRange <= 0 THEN inputRange = 1
    
    w = _WIDTH(img): h = _HEIGHT(img)
    
    ' ULTRA-FAST: Pre-calculate levels lookup table (MASSIVE speed boost!)
    DIM levelsLUT(0 TO 255) AS INTEGER
    DIM i AS INTEGER
    FOR i = 0 TO 255
        levelsLUT(i) = CINT(outputMin + ((i - inputMin) / inputRange) * outputRange)
        IF levelsLUT(i) < 0 THEN levelsLUT(i) = 0
        IF levelsLUT(i) > 255 THEN levelsLUT(i) = 255
    NEXT i
    
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
            
            ' Apply levels using pre-calculated lookup table (BLAZING FAST!)
            r = levelsLUT(r)
            g = levelsLUT(g)
            b = levelsLUT(b)
            
            ' Write back to memory
            _MEMPUT imgBlock, imgBlock.OFFSET + memOffset, b AS _UNSIGNED _BYTE
            _MEMPUT imgBlock, imgBlock.OFFSET + memOffset + 1, g AS _UNSIGNED _BYTE
            _MEMPUT imgBlock, imgBlock.OFFSET + memOffset + 2, r AS _UNSIGNED _BYTE
        NEXT x
    NEXT y
    
    _MEMFREE imgBlock
END SUB

'$INCLUDE:'../core/adjustment_common.bas'
