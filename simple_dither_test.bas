' Very Simple Dithering Test - Self-contained
$CONSOLE:ONLY
PRINT "Simple Dithering Test Starting..."

' Palette variables - local to this program
DIM SHARED PalCount AS INTEGER
DIM SHARED PalR(0 TO 255) AS INTEGER
D            IF r < 0 THEN r = 0: IF r > 255 THEN r = 255
            g = g + threshold: IF g < 0 THEN g = 0: IF g > 255 THEN g = 255
            b = b + threshold: IF b < 0 THEN b = 0: IF b > 255 THEN b = 255
            
            idx = NearestPaletteIndex%(r, g, b)
            PSET (x, y), _RGB32(PalR(idx), PalG(idx), PalB(idx))RED PalG(0 TO 255) AS INTEGER  
DIM SHARED PalB(0 TO 255) AS INTEGER
DIM SHARED PalName AS STRING

' Screen configuration
CONST SCREEN_W = 1000
CONST SCREEN_H = 700

DIM SHARED originalImage AS LONG
DIM SHARED ditheredImage AS LONG
DIM SHARED ditherMethod AS INTEGER

PRINT "Initializing..."
ditherMethod = 0
originalImage = 0
ditheredImage = 0

PRINT "Creating test palette..."
CALL CreateTestPalette

PRINT "Creating test image..."
CALL CreateTestImage

PRINT "Setting up screen..."
SCREEN _NEWIMAGE(SCREEN_W, SCREEN_H, 32)
_TITLE "Simple Dithering Test - Press SPACE to cycle methods, ESC to exit"
_SCREENMOVE 200, 100

PRINT "Starting main loop..."
DO
    CLS
    CALL DrawUI
    CALL HandleInput
    _DISPLAY
    _LIMIT 60
LOOP UNTIL _KEYDOWN(27) ' ESC to exit

PRINT "Cleaning up..."
IF originalImage <> 0 THEN _FREEIMAGE originalImage
IF ditheredImage <> 0 THEN _FREEIMAGE ditheredImage
PRINT "Program ended."
SYSTEM

SUB CreateTestPalette
    PRINT "Creating 8-color test palette..."
    PalCount = 8
    PalName = "Test 8-Color Palette"
    
    ' Basic 8 colors
    PalR(0) = 0: PalG(0) = 0: PalB(0) = 0         ' Black
    PalR(1) = 255: PalG(1) = 255: PalB(1) = 255   ' White  
    PalR(2) = 255: PalG(2) = 0: PalB(2) = 0       ' Red
    PalR(3) = 0: PalG(3) = 255: PalB(3) = 0       ' Green
    PalR(4) = 0: PalG(4) = 0: PalB(4) = 255       ' Blue
    PalR(5) = 255: PalG(5) = 255: PalB(5) = 0     ' Yellow
    PalR(6) = 255: PalG(6) = 0: PalB(6) = 255     ' Magenta
    PalR(7) = 0: PalG(7) = 255: PalB(7) = 255     ' Cyan
    
    PRINT "Palette created successfully."
    FOR i = 0 TO PalCount - 1
        PRINT "Color"; i; ": R="; PalR(i); " G="; PalG(i); " B="; PalB(i)
    NEXT
END SUB

SUB CreateTestImage
    PRINT "Creating 300x300 test gradient image..."
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
    PRINT "Test image created. Applying initial dithering..."
    CALL ApplyDithering
END SUB

SUB DrawUI
    COLOR _RGB32(255, 255, 255)
    _PRINTSTRING (10, 10), "Simple Dithering Test"
    
    _PRINTSTRING (10, 40), "Controls:"
    _PRINTSTRING (10, 60), "SPACE - Next dithering method"
    _PRINTSTRING (10, 80), "ESC - Exit"
    
    _PRINTSTRING (10, 110), "Current Method: " + GetMethodName$(ditherMethod)
    _PRINTSTRING (10, 130), "Palette: " + PalName + " (" + STR$(PalCount) + " colors)"
    
    ' Display images side by side
    IF originalImage <> 0 THEN
        _PRINTSTRING (50, 170), "Original"
        _PUTIMAGE (50, 190)-(350, 490), originalImage
    END IF
    
    IF ditheredImage <> 0 THEN
        _PRINTSTRING (400, 170), "Dithered"
        _PUTIMAGE (400, 190)-(700, 490), ditheredImage
    END IF
    
    ' Palette preview
    CALL DrawPalettePreview(750, 190)
END SUB

SUB HandleInput
    DIM k AS STRING
    k = INKEY$
    
    IF UCASE$(k) = " " THEN
        ditherMethod = ditherMethod + 1
        IF ditherMethod > 2 THEN ditherMethod = 0
        PRINT "Switched to method:", ditherMethod
        CALL ApplyDithering
    END IF
END SUB

SUB ApplyDithering
    PRINT "Applying dithering method:", ditherMethod
    IF originalImage = 0 OR PalCount <= 0 THEN 
        PRINT "No image or palette!"
        EXIT SUB
    END IF
    
    ' Free previous dithered image
    IF ditheredImage <> 0 THEN _FREEIMAGE ditheredImage
    
    ' Create copy of original for dithering
    ditheredImage = _COPYIMAGE(originalImage, 32)
    
    SELECT CASE ditherMethod
        CASE 0 ' None - just quantize
            CALL QuantizeToPalette(ditheredImage)
        CASE 1 ' Simple ordered dither
            CALL ApplyOrderedDither(ditheredImage)
        CASE 2 ' Simple Floyd-Steinberg
            CALL ApplyFloydSteinberg(ditheredImage)
    END SELECT
    PRINT "Dithering complete"
END SUB

FUNCTION NearestPaletteIndex%(r AS INTEGER, g AS INTEGER, b AS INTEGER)
    DIM i AS INTEGER, bestI AS INTEGER
    DIM dr AS INTEGER, dg AS INTEGER, db AS INTEGER
    DIM dist AS LONG, bestDist AS LONG
    
    bestDist = 999999
    bestI = 0
    
    FOR i = 0 TO PalCount - 1
        dr = r - PalR(i)
        dg = g - PalG(i) 
        db = b - PalB(i)
        dist = dr * dr + dg * dg + db * db
        IF dist < bestDist THEN
            bestDist = dist
            bestI = i
        END IF
    NEXT
    
    NearestPaletteIndex% = bestI
END FUNCTION

SUB QuantizeToPalette(img AS LONG)
    PRINT "Simple palette quantization..."
    DIM w AS LONG, h AS LONG, x AS LONG, y AS LONG
    DIM c AS _UNSIGNED LONG, r AS INTEGER, g AS INTEGER, b AS INTEGER, idx AS INTEGER
    
    w = _WIDTH(img): h = _HEIGHT(img)
    DIM oldS AS LONG: oldS = _SOURCE: _SOURCE img
    DIM oldD AS LONG: oldD = _DEST: _DEST img
    
    FOR y = 0 TO h - 1
        FOR x = 0 TO w - 1
            c = POINT(x, y)
            r = _RED32(c): g = _GREEN32(c): b = _BLUE32(c)
            idx = NearestPaletteIndex%(r, g, b)
            PSET (x, y), _RGB32(PalR(idx), PalG(idx), PalB(idx))
        NEXT
    NEXT
    
    _SOURCE oldS: _DEST oldD
END SUB

SUB ApplyOrderedDither(img AS LONG)
    PRINT "Ordered dithering..."
    DIM w AS LONG, h AS LONG, x AS LONG, y AS LONG
    DIM c AS _UNSIGNED LONG, r AS INTEGER, g AS INTEGER, b AS INTEGER, idx AS INTEGER
    DIM threshold AS INTEGER
    
    ' Simple 2x2 Bayer matrix
    DIM bayer(0 TO 1, 0 TO 1) AS INTEGER
    bayer(0, 0) = 0: bayer(0, 1) = 2
    bayer(1, 0) = 3: bayer(1, 1) = 1
    
    w = _WIDTH(img): h = _HEIGHT(img)
    DIM oldS AS LONG: oldS = _SOURCE: _SOURCE img
    DIM oldD AS LONG: oldD = _DEST: _DEST img
    
    FOR y = 0 TO h - 1
        FOR x = 0 TO w - 1
            c = POINT(x, y)
            r = _RED32(c): g = _GREEN32(c): b = _BLUE32(c)
            
            ' Add ordered dither noise
            threshold = bayer(x AND 1, y AND 1) * 16 - 32
            r = r + threshold
            IF r < 0 THEN r = 0
            IF r > 255 THEN r = 255
            g = g + threshold
            IF g < 0 THEN g = 0
            IF g > 255 THEN g = 255
            b = b + threshold
            IF b < 0 THEN b = 0
            IF b > 255 THEN b = 255
            
            idx = NearestPaletteIndex(r, g, b)
            PSET (x, y), _RGB32(PalR(idx), PalG(idx), PalB(idx))
        NEXT
    NEXT
    
    _SOURCE oldS: _DEST oldD
END SUB

SUB ApplyFloydSteinberg(img AS LONG)
    PRINT "Floyd-Steinberg dithering..."
    DIM w AS LONG, h AS LONG, x AS LONG, y AS LONG
    DIM c AS _UNSIGNED LONG, idx AS INTEGER
    DIM r AS SINGLE, g AS SINGLE, b AS SINGLE
    DIM nr AS INTEGER, ng AS INTEGER, nb AS INTEGER
    DIM er AS SINGLE, eg AS SINGLE, eb AS SINGLE
    
    ' Error buffer for current row
    DIM rerr(0 TO 350) AS SINGLE, gerr(0 TO 350) AS SINGLE, berr(0 TO 350) AS SINGLE
    
    w = _WIDTH(img): h = _HEIGHT(img)
    DIM oldS AS LONG: oldS = _SOURCE: _SOURCE img
    DIM oldD AS LONG: oldD = _DEST: _DEST img
    
    FOR y = 0 TO h - 1
        FOR x = 0 TO w - 1
            c = POINT(x, y)
            r = _RED32(c) + rerr(x)
            g = _GREEN32(c) + gerr(x)
            b = _BLUE32(c) + berr(x)
            
            ' Clamp values
            IF r < 0 THEN r = 0
            IF r > 255 THEN r = 255
            IF g < 0 THEN g = 0
            IF g > 255 THEN g = 255
            IF b < 0 THEN b = 0
            IF b > 255 THEN b = 255
            
            idx = NearestPaletteIndex%(CINT(r), CINT(g), CINT(b))
            nr = PalR(idx): ng = PalG(idx): nb = PalB(idx)
            PSET (x, y), _RGB32(nr, ng, nb)
            
            ' Calculate error
            er = r - nr: eg = g - ng: eb = b - nb
            
            ' Distribute error (simplified)
            IF x < w - 1 THEN
                rerr(x + 1) = rerr(x + 1) + er * 0.5
                gerr(x + 1) = gerr(x + 1) + eg * 0.5
                berr(x + 1) = berr(x + 1) + eb * 0.5
            END IF
        NEXT
        
        ' Clear error buffer for next row
        FOR x = 0 TO w
            rerr(x) = 0: gerr(x) = 0: berr(x) = 0
        NEXT
    NEXT
    
    _SOURCE oldS: _DEST oldD
END SUB

SUB DrawPalettePreview(x AS INTEGER, y AS INTEGER)
    DIM i AS INTEGER, px AS INTEGER, py AS INTEGER
    DIM size AS INTEGER: size = 20
    
    _PRINTSTRING (x, y - 20), "Palette:"
    
    FOR i = 0 TO PalCount - 1
        px = x + (i MOD 4) * size
        py = y + (i \ 4) * size
        LINE (px, py)-(px + size - 2, py + size - 2), _RGB32(PalR(i), PalG(i), PalB(i)), BF
        LINE (px, py)-(px + size - 2, py + size - 2), _RGB32(128, 128, 128), B
    NEXT
END SUB

FUNCTION GetMethodName$(method AS INTEGER)
    SELECT CASE method
        CASE 0: GetMethodName$ = "None (Quantize Only)"
        CASE 1: GetMethodName$ = "Ordered Dither 2x2"
        CASE 2: GetMethodName$ = "Floyd-Steinberg"
        CASE ELSE: GetMethodName$ = "Unknown"
    END SELECT
END FUNCTION
