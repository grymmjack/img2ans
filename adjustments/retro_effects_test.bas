' Retro Effects Test
' Standalone test for retro effects algorithm
$CONSOLE
_CONSOLE ON
PRINT "Retro Effects Test Starting..."

' Include our common framework
'$INCLUDE:'../core/adjustment_common.bi'

' Algorithm-specific forward declarations
DECLARE SUB ApplyRetroEffect (img AS LONG, effectType AS INTEGER)
DECLARE SUB ApplyBrightness (img AS LONG, offset AS INTEGER)
DECLARE SUB ApplyContrast (img AS LONG, pct AS INTEGER)
DECLARE SUB ApplyColorBalance (img AS LONG, redShift AS INTEGER, greenShift AS INTEGER, blueShift AS INTEGER)
DECLARE SUB ApplyGamma (img AS LONG, gamma AS SINGLE)
DECLARE SUB ApplyPosterize (img AS LONG, levels AS INTEGER)
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
CALL InitializeGraphics("Retro Effects Test - +/-: adjust, R: reset, ESC: exit")

PRINT "Graphics screen created successfully!"
PRINT "Starting main loop - switch to graphics window!"
PRINT "Controls:"
PRINT "  +/- = change effect type"
PRINT "  R = reset parameters"
PRINT "  ESC = exit"

' Apply initial adjustments
CALL ApplyAdjustments

DO
    _DEST 0 ' Graphics screen
    CLS
    CALL DrawUI("Retro Effects", "Various retro/vintage effects." + CHR$(10) + "Simulates different eras of photography." + CHR$(10) + "Includes fading, color shifts, etc." + CHR$(10) + "Types: 0=Vintage Fade, 1=Warm, 2=Cool, 3=High Contrast")
    
    ' Store old parameter value to detect changes
    DIM oldType AS SINGLE
    oldType = parameters(0)
    
    CALL HandleInput
    
    ' Reapply adjustments if parameter changed
    IF parameters(0) <> oldType THEN
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
    ' Setup retro effect parameter
    parameterCount = 1
    
    ' Effect type parameter
    parameterNames(0) = "Effect Type"
    parameterMins(0) = 0
    parameterMaxs(0) = 3
    parameterSteps(0) = 1
    parameters(0) = 0  ' Default to vintage fade
    
    parameterIndex = 0
END SUB

SUB ApplyAdjustments
    _DEST _CONSOLE
    PRINT "Applying retro effect: type="; parameters(0)
    _DEST 0
    
    IF originalImage = 0 THEN 
        _DEST _CONSOLE
        PRINT "No original image!"
        _DEST 0
        EXIT SUB
    END IF
    
    IF adjustedImage <> 0 THEN _FREEIMAGE adjustedImage
    adjustedImage = _COPYIMAGE(originalImage, 32)
    
    ' Apply retro effect
    CALL ApplyRetroEffect(adjustedImage, CINT(parameters(0)) MOD 4)
    
    _DEST _CONSOLE
    PRINT "Retro effect complete"
    _DEST 0
END SUB

SUB ApplyRetroEffect (img AS LONG, effectType AS INTEGER)
    SELECT CASE effectType
        CASE 0 ' Vintage fade
            CALL ApplyBrightness(img, 20)
            CALL ApplyContrast(img, -20)
            CALL ApplyColorBalance(img, 15, 5, -10)
        CASE 1 ' Warm nostalgic
            CALL ApplyColorBalance(img, 20, 10, -15)
            CALL ApplyGamma(img, 1.2)
        CASE 2 ' Cool retro
            CALL ApplyColorBalance(img, -10, 0, 20)
            CALL ApplyContrast(img, 15)
        CASE 3 ' High contrast vintage
            CALL ApplyContrast(img, 40)
            CALL ApplyPosterize(img, 8)
    END SELECT
END SUB

' Supporting functions for retro effects
SUB ApplyBrightness (img AS LONG, offset AS INTEGER)
    DIM w AS LONG, h AS LONG, x AS LONG, y AS LONG, c AS _UNSIGNED LONG
    DIM r AS INTEGER, g AS INTEGER, b AS INTEGER
    w = _WIDTH(img): h = _HEIGHT(img)
    DIM old AS LONG: old = _SOURCE: _SOURCE img
    DIM oldW AS LONG: oldW = _DEST: _DEST img
    FOR y = 0 TO h - 1
        FOR x = 0 TO w - 1
            c = POINT(x, y)
            r = _RED32(c) + offset
            g = _GREEN32(c) + offset
            b = _BLUE32(c) + offset
            IF r < 0 THEN r = 0 ELSE IF r > 255 THEN r = 255
            IF g < 0 THEN g = 0 ELSE IF g > 255 THEN g = 255
            IF b < 0 THEN b = 0 ELSE IF b > 255 THEN b = 255
            PSET (x, y), _RGB32(r, g, b)
        NEXT
    NEXT
    _SOURCE old: _DEST oldW
END SUB

SUB ApplyContrast (img AS LONG, pct AS INTEGER)
    IF pct < -100 THEN pct = -100
    IF pct > 100 THEN pct = 100
    DIM f AS DOUBLE
    f = (259.0 * (pct + 255.0)) / (255.0 * (259.0 - pct))

    DIM w AS LONG, h AS LONG, x AS LONG, y AS LONG, c AS _UNSIGNED LONG
    DIM r AS INTEGER, g AS INTEGER, b AS INTEGER
    w = _WIDTH(img): h = _HEIGHT(img)
    DIM old AS LONG: old = _SOURCE: _SOURCE img
    DIM oldW AS LONG: oldW = _DEST: _DEST img
    FOR y = 0 TO h - 1
        FOR x = 0 TO w - 1
            c = POINT(x, y)
            r = CINT(f * (_RED32(c) - 128) + 128)
            g = CINT(f * (_GREEN32(c) - 128) + 128)
            b = CINT(f * (_BLUE32(c) - 128) + 128)
            IF r < 0 THEN r = 0 ELSE IF r > 255 THEN r = 255
            IF g < 0 THEN g = 0 ELSE IF g > 255 THEN g = 255
            IF b < 0 THEN b = 0 ELSE IF b > 255 THEN b = 255
            PSET (x, y), _RGB32(r, g, b)
        NEXT
    NEXT
    _SOURCE old: _DEST oldW
END SUB

SUB ApplyColorBalance (img AS LONG, redShift AS INTEGER, greenShift AS INTEGER, blueShift AS INTEGER)
    DIM w AS LONG, h AS LONG, x AS LONG, y AS LONG, c AS _UNSIGNED LONG
    DIM r AS INTEGER, g AS INTEGER, b AS INTEGER
    
    w = _WIDTH(img): h = _HEIGHT(img)
    DIM old AS LONG: old = _SOURCE: _SOURCE img
    DIM oldW AS LONG: oldW = _DEST: _DEST img
    
    FOR y = 0 TO h - 1
        FOR x = 0 TO w - 1
            c = POINT(x, y)
            r = _RED32(c) + redShift
            g = _GREEN32(c) + greenShift
            b = _BLUE32(c) + blueShift
            IF r < 0 THEN r = 0 ELSE IF r > 255 THEN r = 255
            IF g < 0 THEN g = 0 ELSE IF g > 255 THEN g = 255
            IF b < 0 THEN b = 0 ELSE IF b > 255 THEN b = 255
            PSET (x, y), _RGB32(r, g, b)
        NEXT
    NEXT
    _SOURCE old: _DEST oldW
END SUB

SUB ApplyGamma (img AS LONG, gamma AS SINGLE)
    DIM w AS LONG, h AS LONG, x AS LONG, y AS LONG, c AS _UNSIGNED LONG
    DIM r AS INTEGER, g AS INTEGER, b AS INTEGER
    DIM invGamma AS SINGLE
    invGamma = 1.0 / gamma
    
    w = _WIDTH(img): h = _HEIGHT(img)
    DIM old AS LONG: old = _SOURCE: _SOURCE img
    DIM oldW AS LONG: oldW = _DEST: _DEST img
    
    FOR y = 0 TO h - 1
        FOR x = 0 TO w - 1
            c = POINT(x, y)
            r = CINT(255 * ((_RED32(c) / 255.0) ^ invGamma))
            g = CINT(255 * ((_GREEN32(c) / 255.0) ^ invGamma))
            b = CINT(255 * ((_BLUE32(c) / 255.0) ^ invGamma))
            IF r > 255 THEN r = 255
            IF g > 255 THEN g = 255
            IF b > 255 THEN b = 255
            PSET (x, y), _RGB32(r, g, b)
        NEXT
    NEXT
    _SOURCE old: _DEST oldW
END SUB

SUB ApplyPosterize (img AS LONG, levels AS INTEGER)
    IF levels < 2 THEN EXIT SUB
    DIM stepv AS INTEGER
    stepv = 255 \ (levels - 1)
    IF stepv < 1 THEN stepv = 1

    DIM w AS LONG, h AS LONG, x AS LONG, y AS LONG, c AS _UNSIGNED LONG
    DIM r AS INTEGER, g AS INTEGER, b AS INTEGER
    w = _WIDTH(img): h = _HEIGHT(img)
    DIM old AS LONG: old = _SOURCE: _SOURCE img
    DIM oldW AS LONG: oldW = _DEST: _DEST img
    FOR y = 0 TO h - 1
        FOR x = 0 TO w - 1
            c = POINT(x, y)
            r = _RED32(c): g = _GREEN32(c): b = _BLUE32(c)
            r = ((r + stepv \ 2) \ stepv) * stepv
            g = ((g + stepv \ 2) \ stepv) * stepv
            b = ((b + stepv \ 2) \ stepv) * stepv
            IF r > 255 THEN r = 255
            IF g > 255 THEN g = 255
            IF b > 255 THEN b = 255
            PSET (x, y), _RGB32(r, g, b)
        NEXT
    NEXT
    _SOURCE old: _DEST oldW
END SUB

'$INCLUDE:'../core/adjustment_common.bas'
