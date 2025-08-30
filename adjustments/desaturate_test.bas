' Desaturate (Grayscale) Test
' Standalone test for grayscale conversion algorithm
$CONSOLE
_CONSOLE ON
PRINT "Desaturate (Grayscale) Test Starting..."

' Include our common framework
'$INCLUDE:'../core/adjustment_common.bi'

' Algorithm-specific forward declarations
DECLARE SUB ApplyDesaturate (img AS LONG, method AS INTEGER)
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
CALL InitializeGraphics("Desaturate (Grayscale) Test - R: reset, ESC: exit")

PRINT "Graphics screen created successfully!"
PRINT "Starting main loop - switch to graphics window!"
PRINT "Controls:"
PRINT "  R = reset (reapply grayscale)"
PRINT "  ESC = exit"

' Apply initial adjustments
CALL ApplyAdjustments

DO
    _DEST 0 ' Graphics screen
    CLS
    CALL DrawUI("Desaturate (Grayscale)", "Grayscale conversion methods." + CHR$(10) + "Removes color information." + CHR$(10) + "Preserves luminance values." + CHR$(10) + "No adjustable parameters.")
    
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
    ' Desaturate has no adjustable parameters
    parameterCount = 0
    parameterIndex = 0
END SUB

SUB ApplyAdjustments
    _DEST _CONSOLE
    PRINT "Applying grayscale conversion"
    _DEST 0
    
    IF originalImage = 0 THEN 
        _DEST _CONSOLE
        PRINT "No original image!"
        _DEST 0
        EXIT SUB
    END IF
    
    IF adjustedImage <> 0 THEN _FREEIMAGE adjustedImage
    adjustedImage = _COPYIMAGE(originalImage, 32)
    
    ' Apply grayscale conversion
    CALL ApplyDesaturate(adjustedImage, 0)
    
    _DEST _CONSOLE
    PRINT "Grayscale conversion complete"
    _DEST 0
END SUB

SUB ApplyDesaturate (img AS LONG, method AS INTEGER)
    DIM w AS LONG, h AS LONG, x AS LONG, y AS LONG, c AS _UNSIGNED LONG
    DIM gray AS INTEGER
    
    w = _WIDTH(img): h = _HEIGHT(img)
    DIM old AS LONG: old = _SOURCE: _SOURCE img
    DIM oldW AS LONG: oldW = _DEST: _DEST img
    
    FOR y = 0 TO h - 1
        FOR x = 0 TO w - 1
            c = POINT(x, y)
            ' Luminance-based grayscale
            gray = CINT(_RED32(c) * 0.299 + _GREEN32(c) * 0.587 + _BLUE32(c) * 0.114)
            PSET (x, y), _RGB32(gray, gray, gray)
        NEXT
    NEXT
    _SOURCE old: _DEST oldW
END SUB

'$INCLUDE:'../core/adjustment_common.bas'
