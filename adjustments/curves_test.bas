' Curves (S-Curve) Test
' Standalone test for S-curve contrast enhancement
$CONSOLE
_CONSOLE ON
PRINT "Curves (S-Curve) Test Starting..."

' Include our common framework
'$INCLUDE:'../core/adjustment_common.bi'

' Algorithm-specific forward declarations
DECLARE SUB ApplyCurves (img AS LONG, curveType AS INTEGER)
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
CALL InitializeGraphics("Curves (S-Curve) Test - R: reset, ESC: exit")

PRINT "Graphics screen created successfully!"
PRINT "Starting main loop - switch to graphics window!"
PRINT "Controls:"
PRINT "  R = reset (reapply curve)"
PRINT "  ESC = exit"

' Apply initial adjustments
CALL ApplyAdjustments

DO
    _DEST 0 ' Graphics screen
    CLS
    CALL DrawUI("Curves (S-Curve)", "S-curve for contrast enhancement." + CHR$(10) + "Increases midtone contrast." + CHR$(10) + "Popular in digital photography." + CHR$(10) + "No adjustable parameters.")
    
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
    ' S-curve has no adjustable parameters
    parameterCount = 0
    parameterIndex = 0
END SUB

SUB ApplyAdjustments
    _DEST _CONSOLE
    PRINT "Applying S-curve"
    _DEST 0
    
    IF originalImage = 0 THEN 
        _DEST _CONSOLE
        PRINT "No original image!"
        _DEST 0
        EXIT SUB
    END IF
    
    IF adjustedImage <> 0 THEN _FREEIMAGE adjustedImage
    adjustedImage = _COPYIMAGE(originalImage, 32)
    
    ' Apply S-curve
    CALL ApplyCurves(adjustedImage, 0)
    
    _DEST _CONSOLE
    PRINT "S-curve complete"
    _DEST 0
END SUB

SUB ApplyCurves (img AS LONG, curveType AS INTEGER)
    ' S-curve for contrast enhancement
    DIM w AS LONG, h AS LONG, x AS LONG, y AS LONG, c AS _UNSIGNED LONG
    DIM r AS INTEGER, g AS INTEGER, b AS INTEGER
    DIM curve AS SINGLE
    
    w = _WIDTH(img): h = _HEIGHT(img)
    DIM old AS LONG: old = _SOURCE: _SOURCE img
    DIM oldW AS LONG: oldW = _DEST: _DEST img
    
    FOR y = 0 TO h - 1
        FOR x = 0 TO w - 1
            c = POINT(x, y)
            ' Apply S-curve using sine function
            curve = (SIN((_RED32(c) / 255.0 - 0.5) * _PI) + 1) / 2
            r = CINT(curve * 255)
            curve = (SIN((_GREEN32(c) / 255.0 - 0.5) * _PI) + 1) / 2
            g = CINT(curve * 255)
            curve = (SIN((_BLUE32(c) / 255.0 - 0.5) * _PI) + 1) / 2
            b = CINT(curve * 255)
            PSET (x, y), _RGB32(r, g, b)
        NEXT
    NEXT
    _SOURCE old: _DEST oldW
END SUB

'$INCLUDE:'../core/adjustment_common.bas'
