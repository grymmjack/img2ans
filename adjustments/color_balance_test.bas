' Color Balance Test
' Standalone test for color balance algorithm
$CONSOLE
_CONSOLE ON
PRINT "Color Balance Test Starting..."

' Include our common framework
'$INCLUDE:'../core/adjustment_common.bi'

' Algorithm-specific forward declarations
DECLARE SUB ApplyColorBalance (img AS LONG, redShift AS INTEGER, greenShift AS INTEGER, blueShift AS INTEGER)
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
CALL InitializeGraphics("Color Balance Test - +/-: adjust, TAB: parameter, R: reset, ESC: exit")

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
    CALL DrawUI("Color Balance", "Independent RGB channel adjustment." + CHR$(10) + "Corrects color casts and white balance." + CHR$(10) + "Useful for temperature correction." + CHR$(10) + "Range: ±100 for each channel")
    
    ' Store old parameter values to detect changes
    DIM oldRed AS SINGLE, oldGreen AS SINGLE, oldBlue AS SINGLE
    oldRed = parameters(0)
    oldGreen = parameters(1)
    oldBlue = parameters(2)
    
    CALL HandleInput
    
    ' Reapply adjustments if parameters changed
    IF parameters(0) <> oldRed OR parameters(1) <> oldGreen OR parameters(2) <> oldBlue THEN
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
    ' Setup color balance parameters
    parameterCount = 3
    
    ' Red-Cyan balance
    parameterNames(0) = "Red-Cyan"
    parameterMins(0) = -255
    parameterMaxs(0) = 255
    parameterSteps(0) = 5
    parameters(0) = 0
    
    ' Green-Magenta balance
    parameterNames(1) = "Green-Magenta"
    parameterMins(1) = -255
    parameterMaxs(1) = 255
    parameterSteps(1) = 5
    parameters(1) = 0
    
    ' Blue-Yellow balance
    parameterNames(2) = "Blue-Yellow"
    parameterMins(2) = -255
    parameterMaxs(2) = 255
    parameterSteps(2) = 5
    parameters(2) = 0
    
    parameterIndex = 0
END SUB

SUB ApplyAdjustments
    _DEST _CONSOLE
    PRINT "Applying color balance: R="; parameters(0); ", G="; parameters(1); ", B="; parameters(2)
    _DEST 0
    
    IF originalImage = 0 THEN 
        _DEST _CONSOLE
        PRINT "No original image!"
        _DEST 0
        EXIT SUB
    END IF
    
    IF adjustedImage <> 0 THEN _FREEIMAGE adjustedImage
    adjustedImage = _COPYIMAGE(originalImage, 32)
    
    ' Apply color balance adjustment
    CALL ApplyColorBalance(adjustedImage, CINT(parameters(0)), CINT(parameters(1)), CINT(parameters(2)))
    
    _DEST _CONSOLE
    PRINT "Color balance complete"
    _DEST 0
END SUB

SUB ApplyColorBalance (img AS LONG, redShift AS INTEGER, greenShift AS INTEGER, blueShift AS INTEGER)
    DIM w AS LONG, h AS LONG, x AS LONG, y AS LONG
    DIM r AS INTEGER, g AS INTEGER, b AS INTEGER
    
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
            
            ' Apply color balance shifts with clamping (BLAZING FAST!)
            r = r + redShift: IF r < 0 THEN r = 0 ELSE IF r > 255 THEN r = 255
            g = g + greenShift: IF g < 0 THEN g = 0 ELSE IF g > 255 THEN g = 255
            b = b + blueShift: IF b < 0 THEN b = 0 ELSE IF b > 255 THEN b = 255
            
            ' Write back to memory
            _MEMPUT imgBlock, imgBlock.OFFSET + memOffset, b AS _UNSIGNED _BYTE
            _MEMPUT imgBlock, imgBlock.OFFSET + memOffset + 1, g AS _UNSIGNED _BYTE
            _MEMPUT imgBlock, imgBlock.OFFSET + memOffset + 2, r AS _UNSIGNED _BYTE
        NEXT x
    NEXT y
    
    _MEMFREE imgBlock
END SUB

'$INCLUDE:'../core/adjustment_common.bas'
