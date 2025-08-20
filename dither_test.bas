' IMG2ANS Dithering Test v1.0

' Include the core dithering and palette modules
'$INCLUDE:'core/palette.bi'
'$INCLUDE:'core/dither.bi'

' Screen configuration
CONST SCREEN_W = 1200
CONST SCREEN_H = 800

' Image display areas
CONST ORIG_X = 10: CONST ORIG_Y = 60
CONST ORIG_W = 280: CONST ORIG_H = 280
CONST DITH_X = 310: CONST DITH_Y = 60
CONST DITH_W = 280: CONST DITH_H = 280

' UI Controls
CONST BTN_LOAD_X = 10: CONST BTN_LOAD_Y = 10
CONST BTN_APPLY_X = 320: CONST BTN_APPLY_Y = 10
CONST PALETTE_X = 620: CONST PALETTE_Y = 60

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
DIM SHARED paletteImage AS LONG
DIM SHARED imageLoaded AS _BYTE

' Initialize
ditherOpts.method = 1
ditherOpts.amount = 0.6
ditherOpts.useSRGB = -1
ditherOpts.serpentine = -1
imageLoaded = 0

' Load default palette
CALL LoadDefaultPalette

' Main program
SCREEN _NEWIMAGE(SCREEN_W, SCREEN_H, 32)
_TITLE "IMG2ANS Dithering Test - Load an image to begin"
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
IF paletteImage <> 0 THEN _FREEIMAGE paletteImage
SYSTEM

SUB DrawUI
    ' Title
    COLOR _RGB32(255, 255, 255)
    _PRINTSTRING (10, 10), "IMG2ANS Dithering Test v1.0"
    
    ' Load button
    CALL DrawButton(BTN_LOAD_X, BTN_LOAD_Y + 25, 120, 25, "Load Image", _RGB32(100, 150, 255))
    
    ' Apply button (only if image loaded)
    IF imageLoaded THEN
        CALL DrawButton(BTN_APPLY_X, BTN_APPLY_Y + 25, 120, 25, "Apply Dither", _RGB32(100, 255, 100))
    END IF
    
    ' Dithering controls
    _PRINTSTRING (10, 360), "Dithering Method:"
    _PRINTSTRING (10, 380), "1. None     2. Ordered 4x4     3. Ordered 8x8     4. Floyd-Steinberg"
    _PRINTSTRING (10, 400), "Current: " + GetMethodName$(ditherOpts.method)
    
    _PRINTSTRING (10, 430), "Amount (Ordered): " + STR$(ditherOpts.amount) + " (A/Z to adjust)"
    _PRINTSTRING (10, 450), "Use sRGB: " + IIF$(ditherOpts.useSRGB, "Yes", "No") + " (S to toggle)"
    _PRINTSTRING (10, 470), "Serpentine: " + IIF$(ditherOpts.serpentine, "Yes", "No") + " (R to toggle)"
    
    ' Palette info
    IF PalCount > 0 THEN
        _PRINTSTRING (10, 500), "Loaded Palette: " + PalName$ + " (" + _TRIM$(STR$(PalCount)) + " colors)"
        _PRINTSTRING (10, 520), "P - Load different palette"
    ELSE
        _PRINTSTRING (10, 500), "No palette loaded! Press P to load one."
    END IF
    
    ' Image areas
    IF imageLoaded THEN
        ' Original image label
        _PRINTSTRING (ORIG_X, ORIG_Y - 20), "Original Image"
        LINE (ORIG_X - 1, ORIG_Y - 1)-(ORIG_X + ORIG_W, ORIG_Y + ORIG_H), _RGB32(128, 128, 128), B
        
        ' Dithered image label
        _PRINTSTRING (DITH_X, DITH_Y - 20), "Dithered Image"
        LINE (DITH_X - 1, DITH_Y - 1)-(DITH_X + DITH_W, DITH_Y + DITH_H), _RGB32(128, 128, 128), B
        
        ' Display images
        IF originalImage <> 0 THEN
            _PUTIMAGE (ORIG_X, ORIG_Y)-(ORIG_X + ORIG_W - 1, ORIG_Y + ORIG_H - 1), originalImage
        END IF
        
        IF ditheredImage <> 0 THEN
            _PUTIMAGE (DITH_X, DITH_Y)-(DITH_X + DITH_W - 1, DITH_Y + DITH_H - 1), ditheredImage
        END IF
    ELSE
        _PRINTSTRING (ORIG_X, ORIG_Y + ORIG_H / 2), "No image loaded"
        _PRINTSTRING (DITH_X, DITH_Y + DITH_H / 2), "Apply dithering first"
    END IF
    
    ' Palette preview
    IF PalCount > 0 THEN
        CALL DrawPalettePreview(PALETTE_X, PALETTE_Y)
    END IF
    
    ' Instructions
    _PRINTSTRING (10, SCREEN_H - 40), "ESC - Exit    L - Load Image    P - Load Palette    1-4 - Dither Method"
    _PRINTSTRING (10, SCREEN_H - 20), "A/Z - Adjust Amount    S - Toggle sRGB    R - Toggle Serpentine"
END SUB

SUB HandleInput
    DIM k AS STRING
    k = INKEY$
    
    SELECT CASE UCASE$(k)
        CASE "L"
            CALL LoadImage
        CASE "P"
            CALL LoadPalette
        CASE " "
            IF imageLoaded THEN CALL ApplyDithering
        CASE "1"
            ditherOpts.method = 0
        CASE "2"
            ditherOpts.method = 1
        CASE "3"
            ditherOpts.method = 2
        CASE "4"
            ditherOpts.method = 3
        CASE "A"
            ditherOpts.amount = ditherOpts.amount + 0.05
            IF ditherOpts.amount > 1.0 THEN ditherOpts.amount = 1.0
        CASE "Z"
            ditherOpts.amount = ditherOpts.amount - 0.05
            IF ditherOpts.amount < 0.0 THEN ditherOpts.amount = 0.0
        CASE "S"
            ditherOpts.useSRGB = NOT ditherOpts.useSRGB
        CASE "R"
            ditherOpts.serpentine = NOT ditherOpts.serpentine
    END SELECT
    
    ' Check mouse clicks
    WHILE _MOUSEINPUT: WEND
    IF _MOUSEBUTTON(1) THEN
        DIM mx AS INTEGER, my AS INTEGER
        mx = _MOUSEX: my = _MOUSEY
        
        ' Check load button
        IF mx >= BTN_LOAD_X AND mx <= BTN_LOAD_X + 120 AND my >= BTN_LOAD_Y + 25 AND my <= BTN_LOAD_Y + 50 THEN
            CALL LoadImage
        END IF
        
        ' Check apply button
        IF imageLoaded AND mx >= BTN_APPLY_X AND mx <= BTN_APPLY_X + 120 AND my >= BTN_APPLY_Y + 25 AND my <= BTN_APPLY_Y + 50 THEN
            CALL ApplyDithering
        END IF
    END IF
END SUB

SUB LoadImage
    DIM filter$, filename$
    filter$ = "Image Files|*.bmp;*.jpg;*.jpeg;*.png;*.gif;*.tga|All Files|*.*"
    filename$ = _OPENFILEDIALOG$("Load Image", "", filter$, "Load")
    
    IF filename$ <> "" THEN
        IF originalImage <> 0 THEN _FREEIMAGE originalImage
        IF ditheredImage <> 0 THEN _FREEIMAGE ditheredImage: ditheredImage = 0
        
        originalImage = _LOADIMAGE(filename$, 32)
        IF originalImage < -1 THEN
            imageLoaded = -1
            _TITLE "IMG2ANS Dithering Test - " + filename$
        ELSE
            _TITLE "IMG2ANS Dithering Test - Failed to load image"
            originalImage = 0
            imageLoaded = 0
        END IF
    END IF
END SUB

SUB LoadPalette
    DIM filter$, filename$
    filter$ = "GIMP Palettes|*.gpl|All Files|*.*"
    filename$ = _OPENFILEDIALOG$("Load Palette", "resources\palettes", filter$, "Load")
    
    IF filename$ <> "" THEN
        DIM result AS INTEGER
        result = LoadGimpPalette(filename$)
        IF result > 0 THEN
            _TITLE "IMG2ANS Dithering Test - Loaded " + _TRIM$(STR$(result)) + " colors"
        ELSE
            _TITLE "IMG2ANS Dithering Test - Failed to load palette"
        END IF
    END IF
END SUB

SUB LoadDefaultPalette
    ' Try to load a default palette
    DIM defaultPal$
    defaultPal$ = "resources\palettes\DAWNBRINGER-16 (16).GPL"
    IF _FILEEXISTS(defaultPal$) THEN
        CALL LoadGimpPalette(defaultPal$)
    END IF
END SUB

SUB ApplyDithering
    IF NOT imageLoaded OR originalImage = 0 OR PalCount <= 0 THEN EXIT SUB
    
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

SUB DrawButton (x AS INTEGER, y AS INTEGER, w AS INTEGER, h AS INTEGER, text$, col AS _UNSIGNED LONG)
    LINE (x, y)-(x + w, y + h), col, BF
    LINE (x, y)-(x + w, y + h), _RGB32(255, 255, 255), B
    DIM textW AS INTEGER: textW = LEN(text$) * 8
    _PRINTSTRING (x + (w - textW) / 2, y + (h - 16) / 2), text$
END SUB

SUB DrawPalettePreview (x AS INTEGER, y AS INTEGER)
    DIM i AS INTEGER, px AS INTEGER, py AS INTEGER
    DIM cols AS INTEGER: cols = 16
    DIM size AS INTEGER: size = 20
    
    _PRINTSTRING (x, y - 20), "Palette Preview:"
    
    FOR i = 0 TO PalCount - 1
        px = x + (i MOD cols) * size
        py = y + (i \ cols) * size
        LINE (px, py)-(px + size - 2, py + size - 2), _RGB32(PalR(i), PalG(i), PalB(i)), BF
        LINE (px, py)-(px + size - 2, py + size - 2), _RGB32(128, 128, 128), B
    NEXT
END SUB

FUNCTION GetMethodName$ (method AS INTEGER)
    SELECT CASE method
        CASE 0: GetMethodName$ = "None"
        CASE 1: GetMethodName$ = "Ordered 4x4"
        CASE 2: GetMethodName$ = "Ordered 8x8"
        CASE 3: GetMethodName$ = "Floyd-Steinberg"
        CASE ELSE: GetMethodName$ = "Unknown"
    END SELECT
END FUNCTION

FUNCTION IIF$ (condition AS _BYTE, trueVal$, falseVal$)
    IF condition THEN IIF$ = trueVal$ ELSE IIF$ = falseVal$
END FUNCTION

'$INCLUDE:'core/palette.bas'
'$INCLUDE:'core/dither.bas'
