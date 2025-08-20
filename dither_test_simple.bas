' IMG2ANS Dithering Test v1.0 - Simplified Version
'$INCLUDE:'core/palette.bi'
'$INCLUDE:'core/dither.bi'

' Screen configuration
CONST SCREEN_W = 1000
CONST SCREEN_H = 700

' Dithering options
TYPE DitherOptions
    method AS INTEGER      ' 0=None, 1=Ordered4x4, 2=Ordered8x8, 3=Floyd-Steinberg
    amount AS SINGLE       ' 0.0 to 1.0 for ordered dithering
    useSRGB AS _BYTE       ' Color space for distance calculation
    serpentine AS _BYTE    ' For Floyd-Steinberg
END TYPE

DIM SHARED ditherOpts AS DitherOptions
DIM SHARED originalImage AS LONG
DIM SHARED ditheredImage AS LONG
DIM SHARED imageLoaded AS _BYTE

' Initialize
ditherOpts.method = 1
ditherOpts.amount = 0.6
ditherOpts.useSRGB = -1
ditherOpts.serpentine = -1
imageLoaded = 0

' Load default palette
CALL LoadDefaultPalette

' Create test image if no image loaded
CALL CreateTestImage

' Main program
SCREEN _NEWIMAGE(SCREEN_W, SCREEN_H, 32)
_TITLE "IMG2ANS Dithering Test - Press SPACE to cycle dithering methods"
_SCREENMOVE 200, 100

DO
    CLS
    CALL DrawUI
    CALL HandleInput
    _DISPLAY
    _LIMIT 60
LOOP UNTIL _KEYDOWN(27) ' ESC to exit

' Cleanup
IF originalImage <> 0 THEN _FREEIMAGE originalImage
IF ditheredImage <> 0 THEN _FREEIMAGE ditheredImage
SYSTEM

SUB DrawUI
    COLOR _RGB32(255, 255, 255)
    _PRINTSTRING (10, 10), "IMG2ANS Dithering Test v1.0"
    
    ' Controls info
    _PRINTSTRING (10, 40), "Controls:"
    _PRINTSTRING (10, 60), "SPACE - Apply next dithering method"
    _PRINTSTRING (10, 80), "L - Load image (requires file dialog support)"
    _PRINTSTRING (10, 100), "A/Z - Adjust dithering amount (" + STR$(ditherOpts.amount) + ")"
    _PRINTSTRING (10, 120), "S - Toggle sRGB color space (" + IIF_STR$(ditherOpts.useSRGB, "ON", "OFF") + ")"
    _PRINTSTRING (10, 140), "R - Toggle serpentine scan (" + IIF_STR$(ditherOpts.serpentine, "ON", "OFF") + ")"
    _PRINTSTRING (10, 160), "ESC - Exit"
    
    ' Current method
    _PRINTSTRING (10, 190), "Current Method: " + GetMethodName$(ditherOpts.method)
    
    ' Palette info
    IF PalCount > 0 THEN
        _PRINTSTRING (10, 210), "Palette: " + PalName$ + " (" + _TRIM$(STR$(PalCount)) + " colors)"
    ELSE
        _PRINTSTRING (10, 210), "No palette loaded!"
    END IF
    
    ' Display images side by side
    IF originalImage <> 0 THEN
        _PRINTSTRING (50, 250), "Original"
        _PUTIMAGE (50, 270)-(350, 570), originalImage
    END IF
    
    IF ditheredImage <> 0 THEN
        _PRINTSTRING (400, 250), "Dithered"
        _PUTIMAGE (400, 270)-(700, 570), ditheredImage
    END IF
    
    ' Palette preview
    IF PalCount > 0 THEN
        CALL DrawPalettePreview(750, 270)
    END IF
END SUB

SUB HandleInput
    DIM k AS STRING
    k = INKEY$
    
    SELECT CASE UCASE$(k)
        CASE " "
            CALL CycleDitherMethod
            CALL ApplyDithering
        CASE "L"
            CALL LoadImageSimple
        CASE "A"
            ditherOpts.amount = ditherOpts.amount + 0.1
            IF ditherOpts.amount > 1.0 THEN ditherOpts.amount = 1.0
            IF ditherOpts.method = 1 OR ditherOpts.method = 2 THEN CALL ApplyDithering
        CASE "Z"
            ditherOpts.amount = ditherOpts.amount - 0.1
            IF ditherOpts.amount < 0.0 THEN ditherOpts.amount = 0.0
            IF ditherOpts.method = 1 OR ditherOpts.method = 2 THEN CALL ApplyDithering
        CASE "S"
            ditherOpts.useSRGB = NOT ditherOpts.useSRGB
            CALL ApplyDithering
        CASE "R"
            ditherOpts.serpentine = NOT ditherOpts.serpentine
            IF ditherOpts.method = 3 THEN CALL ApplyDithering
    END SELECT
END SUB

SUB CycleDitherMethod
    ditherOpts.method = ditherOpts.method + 1
    IF ditherOpts.method > 3 THEN ditherOpts.method = 0
END SUB

SUB LoadImageSimple
    ' Simple file input - user can type filename
    COLOR _RGB32(255, 255, 255)
    _PRINTSTRING (10, 600), "Enter image filename (or press ENTER for test image):"
    
    DIM filename$
    INPUT "", filename$
    
    IF filename$ = "" THEN
        CALL CreateTestImage
        RETURN
    END IF
    
    IF _FILEEXISTS(filename$) THEN
        IF originalImage <> 0 THEN _FREEIMAGE originalImage
        originalImage = _LOADIMAGE(filename$, 32)
        IF originalImage < -1 THEN
            imageLoaded = -1
            CALL ApplyDithering
        ELSE
            _PRINTSTRING (10, 620), "Failed to load: " + filename$
            CALL CreateTestImage
        END IF
    ELSE
        _PRINTSTRING (10, 620), "File not found: " + filename$
        CALL CreateTestImage
    END IF
END SUB

SUB CreateTestImage
    ' Create a test gradient image
    IF originalImage <> 0 THEN _FREEIMAGE originalImage
    
    originalImage = _NEWIMAGE(300, 300, 32)
    DIM oldDest AS LONG: oldDest = _DEST
    _DEST originalImage
    
    DIM x AS INTEGER, y AS INTEGER
    DIM r AS INTEGER, g AS INTEGER, b AS INTEGER
    
    FOR y = 0 TO 299
        FOR x = 0 TO 299
            r = (x * 255) \ 300
            g = (y * 255) \ 300
            b = ((x + y) * 255) \ 600
            PSET (x, y), _RGB32(r, g, b)
        NEXT
    NEXT
    
    _DEST oldDest
    imageLoaded = -1
    CALL ApplyDithering
END SUB

SUB LoadDefaultPalette
    ' Try to load a default palette
    DIM defaultPal$
    defaultPal$ = "resources\palettes\DAWNBRINGER-16 (16).GPL"
    IF _FILEEXISTS(defaultPal$) THEN
        DIM result AS INTEGER
        result = LoadGimpPalette(defaultPal$)
        IF result <= 0 THEN CALL CreateTestPalette
    ELSE
        ' Create a simple test palette if file not found
        CALL CreateTestPalette
    END IF
END SUB

SUB CreateTestPalette
    ' Create a simple 8-color palette for testing
    PalCount = 8
    REDIM PalR(0 TO 7) AS INTEGER
    REDIM PalG(0 TO 7) AS INTEGER
    REDIM PalB(0 TO 7) AS INTEGER
    PalName$ = "Test 8-Color"
    
    ' Basic 8 colors
    PalR(0) = 0: PalG(0) = 0: PalB(0) = 0         ' Black
    PalR(1) = 255: PalG(1) = 255: PalB(1) = 255   ' White
    PalR(2) = 255: PalG(2) = 0: PalB(2) = 0       ' Red
    PalR(3) = 0: PalG(3) = 255: PalB(3) = 0       ' Green
    PalR(4) = 0: PalG(4) = 0: PalB(4) = 255       ' Blue
    PalR(5) = 255: PalG(5) = 255: PalB(5) = 0     ' Yellow
    PalR(6) = 255: PalG(6) = 0: PalB(6) = 255     ' Magenta
    PalR(7) = 0: PalG(7) = 255: PalB(7) = 255     ' Cyan
END SUB

SUB ApplyDithering
    IF originalImage = 0 OR PalCount <= 0 THEN EXIT SUB
    
    ' Free previous dithered image
    IF ditheredImage <> 0 THEN _FREEIMAGE ditheredImage
    
    ' Create copy of original for dithering
    ditheredImage = _COPYIMAGE(originalImage, 32)
    
    ' Apply selected dithering method
    SELECT CASE ditherOpts.method
        CASE 0 ' None - just quantize to palette
            CALL QuantizeToPalette(ditheredImage)
        CASE 1 ' Ordered 4x4
            CALL ApplyOrderedPaletteDither(ditheredImage, ditherOpts.useSRGB, 4, ditherOpts.amount)
        CASE 2 ' Ordered 8x8
            CALL ApplyOrderedPaletteDither(ditheredImage, ditherOpts.useSRGB, 8, ditherOpts.amount)
        CASE 3 ' Floyd-Steinberg
            CALL ApplyFloydSteinbergDither(ditheredImage, ditherOpts.useSRGB, ditherOpts.serpentine)
    END SELECT
END SUB

SUB QuantizeToPalette (img AS LONG)
    ' Simple palette quantization without dithering
    DIM w AS LONG, h AS LONG, x AS LONG, y AS LONG
    DIM c AS _UNSIGNED LONG, r AS INTEGER, g AS INTEGER, b AS INTEGER, idx AS INTEGER
    
    w = _WIDTH(img): h = _HEIGHT(img)
    DIM oldS AS LONG: oldS = _SOURCE: _SOURCE img
    DIM oldD AS LONG: oldD = _DEST: _DEST img
    
    FOR y = 0 TO h - 1
        FOR x = 0 TO w - 1
            c = POINT(x, y)
            r = _RED32(c): g = _GREEN32(c): b = _BLUE32(c)
            idx = NearestIndex(r, g, b, ditherOpts.useSRGB)
            PSET (x, y), _RGB32(PalR(idx), PalG(idx), PalB(idx))
        NEXT
    NEXT
    
    _SOURCE oldS: _DEST oldD
END SUB

SUB DrawPalettePreview (x AS INTEGER, y AS INTEGER)
    DIM i AS INTEGER, px AS INTEGER, py AS INTEGER
    DIM cols AS INTEGER: cols = 4
    DIM size AS INTEGER: size = 30
    
    _PRINTSTRING (x, y - 20), "Palette:"
    
    FOR i = 0 TO PalCount - 1
        px = x + (i MOD cols) * size
        py = y + (i \ cols) * size
        LINE (px, py)-(px + size - 2, py + size - 2), _RGB32(PalR(i), PalG(i), PalB(i)), BF
        LINE (px, py)-(px + size - 2, py + size - 2), _RGB32(128, 128, 128), B
    NEXT
END SUB

FUNCTION GetMethodName$ (method AS INTEGER)
    SELECT CASE method
        CASE 0: GetMethodName$ = "None (Quantize Only)"
        CASE 1: GetMethodName$ = "Ordered Dither 4x4"
        CASE 2: GetMethodName$ = "Ordered Dither 8x8"
        CASE 3: GetMethodName$ = "Floyd-Steinberg"
        CASE ELSE: GetMethodName$ = "Unknown"
    END SELECT
END FUNCTION

FUNCTION IIF_STR$ (condition AS _BYTE, trueVal$, falseVal$)
    IF condition THEN IIF_STR$ = trueVal$ ELSE IIF_STR$ = falseVal$
END FUNCTION

'$INCLUDE:'core/palette_simple.bas'
'$INCLUDE:'core/dither_simple.bas'
