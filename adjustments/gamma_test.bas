' Gamma Correction Test
' Standalone test for gamma correction algorithm
$CONSOLE
_CONSOLE ON
PRINT "Gamma Correction Test Starting..."

' Include our common framework
'$INCLUDE:'../core/adjustment_common.bi'

' Algorithm-specific forward declarations
DECLARE SUB ApplyGamma (img AS LONG, gamma AS SINGLE)
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
CALL InitializeGraphics("Gamma Correction Test - +/-: adjust, R: reset, ESC: exit")

PRINT "Graphics screen created successfully!"
PRINT "Starting main loop - switch to graphics window!"
PRINT "Controls:"
PRINT "  +/- = adjust gamma value"
PRINT "  R = reset parameters"
PRINT "  ESC = exit"

' Apply initial adjustments
CALL ApplyAdjustments

DO
    _DEST 0 ' Graphics screen
    CLS
    CALL DrawUI("Gamma Correction", "Gamma correction for display calibration." + CHR$(10) + "Values < 1.0 brighten midtones." + CHR$(10) + "Values > 1.0 darken midtones." + CHR$(10) + "Range: 0.1 to 3.0 (displayed as 10-300)")
    
    ' Store old parameter value to detect changes
    DIM oldGamma AS SINGLE
    oldGamma = parameters(0)
    
    CALL HandleInput
    
    ' Reapply adjustments if parameter changed
    IF parameters(0) <> oldGamma THEN
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
    ' Setup gamma parameter
    parameterCount = 1
    
    ' Gamma parameter (stored as 10-300, converted to 0.1-3.0)
    parameterNames(0) = "Gamma"
    parameterMins(0) = 10    ' Represents 0.1
    parameterMaxs(0) = 300   ' Represents 3.0
    parameterSteps(0) = 10   ' Step by 0.1
    parameterDefaults(0) = 100  ' Default: gamma 1.0 (no change)
    parameters(0) = 100      ' Default to 1.0 (100)
    
    parameterIndex = 0
END SUB

SUB ApplyAdjustments
    DIM actualGamma AS SINGLE
    actualGamma = parameters(0) / 100.0
    
    _DEST _CONSOLE
    PRINT "Applying gamma correction: gamma="; actualGamma
    _DEST 0
    
    IF originalImage = 0 THEN 
        _DEST _CONSOLE
        PRINT "No original image!"
        _DEST 0
        EXIT SUB
    END IF
    
    IF adjustedImage <> 0 THEN _FREEIMAGE adjustedImage
    adjustedImage = _COPYIMAGE(originalImage, 32)
    
    ' Apply gamma correction
    CALL ApplyGamma(adjustedImage, actualGamma)
    
    _DEST _CONSOLE
    PRINT "Gamma correction complete"
    _DEST 0
END SUB

SUB ApplyGamma (img AS LONG, gamma AS SINGLE)
    DIM w AS LONG, h AS LONG, x AS LONG, y AS LONG
    DIM r AS INTEGER, g AS INTEGER, b AS INTEGER
    DIM invGamma AS SINGLE
    invGamma = 1.0 / gamma
    
    w = _WIDTH(img): h = _HEIGHT(img)
    
    ' ULTRA-FAST: Pre-calculate gamma lookup table (MASSIVE speed boost!)
    DIM gammaLUT(0 TO 255) AS INTEGER
    DIM i AS INTEGER
    FOR i = 0 TO 255
        gammaLUT(i) = CINT(255 * ((i / 255.0) ^ invGamma))
        IF gammaLUT(i) > 255 THEN gammaLUT(i) = 255
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
            
            ' Apply gamma using pre-calculated lookup table (BLAZING FAST!)
            r = gammaLUT(r)
            g = gammaLUT(g)
            b = gammaLUT(b)
            
            ' Write back to memory
            _MEMPUT imgBlock, imgBlock.OFFSET + memOffset, b AS _UNSIGNED _BYTE
            _MEMPUT imgBlock, imgBlock.OFFSET + memOffset + 1, g AS _UNSIGNED _BYTE
            _MEMPUT imgBlock, imgBlock.OFFSET + memOffset + 2, r AS _UNSIGNED _BYTE
        NEXT x
    NEXT y
    
    _MEMFREE imgBlock
END SUB

'$INCLUDE:'../core/adjustment_common.bas'
