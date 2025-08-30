' Sepia Tone Test
' Standalone test for sepia tone effect
$CONSOLE
_CONSOLE ON
PRINT "Sepia Tone Test Starting..."

' Include our common framework
'$INCLUDE:'../core/adjustment_common.bi'

' Algorithm-specific forward declarations
DECLARE SUB ApplySepia (img AS LONG)
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
CALL InitializeGraphics("Sepia Tone Test - R: reset, ESC: exit")

PRINT "Graphics screen created successfully!"
PRINT "Starting main loop - switch to graphics window!"
PRINT "Controls:"
PRINT "  R = reset (reapply sepia)"
PRINT "  ESC = exit"

' Apply initial adjustments
CALL ApplyAdjustments

DO
    _DEST 0 ' Graphics screen
    CLS
    CALL DrawUI("Sepia Tone", "Vintage sepia tone effect." + CHR$(10) + "Converts to warm brown monochrome." + CHR$(10) + "Classic photography style." + CHR$(10) + "No adjustable parameters.")
    
    ' Handle reset input
    DIM k AS STRING
    k = INKEY$
    IF UCASE$(k) = "R" THEN
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
    ' Sepia has no adjustable parameters
    parameterCount = 0
    parameterIndex = 0
END SUB

SUB ApplyAdjustments
    _DEST _CONSOLE
    PRINT "Applying sepia tone effect"
    _DEST 0
    
    IF originalImage = 0 THEN 
        _DEST _CONSOLE
        PRINT "No original image!"
        _DEST 0
        EXIT SUB
    END IF
    
    IF adjustedImage <> 0 THEN _FREEIMAGE adjustedImage
    adjustedImage = _COPYIMAGE(originalImage, 32)
    
    ' Apply sepia tone
    CALL ApplySepia(adjustedImage)
    
    _DEST _CONSOLE
    PRINT "Sepia tone complete"
    _DEST 0
END SUB

SUB ApplySepia (img AS LONG)
    DIM w AS LONG, h AS LONG, x AS LONG, y AS LONG, c AS _UNSIGNED LONG
    DIM r AS INTEGER, g AS INTEGER, b AS INTEGER
    
    w = _WIDTH(img): h = _HEIGHT(img)
    DIM old AS LONG: old = _SOURCE: _SOURCE img
    DIM oldW AS LONG: oldW = _DEST: _DEST img
    
    FOR y = 0 TO h - 1
        FOR x = 0 TO w - 1
            c = POINT(x, y)
            ' Standard sepia conversion
            r = CINT(_RED32(c) * 0.393 + _GREEN32(c) * 0.769 + _BLUE32(c) * 0.189)
            g = CINT(_RED32(c) * 0.349 + _GREEN32(c) * 0.686 + _BLUE32(c) * 0.168)
            b = CINT(_RED32(c) * 0.272 + _GREEN32(c) * 0.534 + _BLUE32(c) * 0.131)
            IF r > 255 THEN r = 255
            IF g > 255 THEN g = 255
            IF b > 255 THEN b = 255
            PSET (x, y), _RGB32(r, g, b)
        NEXT
    NEXT
    _SOURCE old: _DEST oldW
END SUB

'$INCLUDE:'../core/adjustment_common.bas'
