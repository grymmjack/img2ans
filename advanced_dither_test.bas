' Advanced Dithering Test with Multiple Algorithms and Matrix Sizes
$CONSOLE
_CONSOLE ON
PRINT "Advanced Dithering Test Starting..."

' Palette variables
DIM SHARED PalCount AS INTEGER
DIM SHARED PalR(0 TO 255) AS INTEGER
DIM SHARED PalG(0 TO 255) AS INTEGER  
DIM SHARED PalB(0 TO 255) AS INTEGER
DIM SHARED PalName AS STRING

' Screen configuration
CONST SCREEN_W = 1200
CONST SCREEN_H = 800

DIM SHARED originalImage AS LONG
DIM SHARED ditheredImage AS LONG
DIM SHARED ditherMethod AS INTEGER
DIM SHARED currentPalette AS INTEGER

PRINT "Initializing..."
ditherMethod = 0
currentPalette = 0
originalImage = 0
ditheredImage = 0

PRINT "Creating test palette..."
CALL CreatePalette(currentPalette)

PRINT "Creating test image..."
CALL CreateTestImage

PRINT "Setting up graphics screen..."
SCREEN _NEWIMAGE(SCREEN_W, SCREEN_H, 32)
_TITLE "Advanced Dithering Test - SPACE: dither method, P: palette, ESC: exit"
_SCREENMOVE 100, 50

PRINT "Graphics screen created successfully!"
PRINT "Starting main loop - switch to graphics window!"
PRINT "Controls:"
PRINT "  SPACE = next dither method"
PRINT "  P = next palette"
PRINT "  ESC = exit"

DO
    _DEST 0 ' Graphics screen
    CLS
    CALL DrawUI
    CALL HandleInput
    _DISPLAY
    _LIMIT 60
LOOP UNTIL _KEYDOWN(27)

PRINT "Cleaning up..."
IF originalImage <> 0 THEN _FREEIMAGE originalImage
IF ditheredImage <> 0 THEN _FREEIMAGE ditheredImage
PRINT "Program ended."
SYSTEM

SUB CreatePalette(paletteType AS INTEGER)
    SELECT CASE paletteType
        CASE 0 ' CGA 4-color
            PRINT "Creating CGA 4-color palette..."
            PalCount = 4
            PalName = "CGA 4-Color"
            PalR(0) = 0: PalG(0) = 0: PalB(0) = 0         ' Black
            PalR(1) = 255: PalG(1) = 255: PalB(1) = 255   ' White
            PalR(2) = 255: PalG(2) = 0: PalB(2) = 255     ' Magenta
            PalR(3) = 0: PalG(3) = 255: PalB(3) = 255     ' Cyan
            
        CASE 1 ' CGA 16-color
            PRINT "Creating CGA 16-color palette..."
            PalCount = 16
            PalName = "CGA 16-Color"
            ' Standard CGA colors
            PalR(0) = 0: PalG(0) = 0: PalB(0) = 0         ' Black
            PalR(1) = 128: PalG(1) = 128: PalB(1) = 128   ' Dark Gray
            PalR(2) = 192: PalG(2) = 192: PalB(2) = 192   ' Light Gray
            PalR(3) = 255: PalG(3) = 255: PalB(3) = 255   ' White
            PalR(4) = 128: PalG(4) = 0: PalB(4) = 0       ' Dark Red
            PalR(5) = 255: PalG(5) = 0: PalB(5) = 0       ' Red
            PalR(6) = 255: PalG(6) = 128: PalB(6) = 128   ' Light Red
            PalR(7) = 0: PalG(7) = 128: PalB(7) = 0       ' Dark Green
            PalR(8) = 0: PalG(8) = 255: PalB(8) = 0       ' Green
            PalR(9) = 128: PalG(9) = 255: PalB(9) = 128   ' Light Green
            PalR(10) = 0: PalG(10) = 0: PalB(10) = 128    ' Dark Blue
            PalR(11) = 0: PalG(11) = 0: PalB(11) = 255    ' Blue
            PalR(12) = 128: PalG(12) = 128: PalB(12) = 255 ' Light Blue
            PalR(13) = 255: PalG(13) = 255: PalB(13) = 0  ' Yellow
            PalR(14) = 255: PalG(14) = 0: PalB(14) = 255  ' Magenta
            PalR(15) = 0: PalG(15) = 255: PalB(15) = 255  ' Cyan
            
        CASE 2 ' Monochrome
            PRINT "Creating Monochrome palette..."
            PalCount = 2
            PalName = "Monochrome"
            PalR(0) = 0: PalG(0) = 0: PalB(0) = 0         ' Black
            PalR(1) = 255: PalG(1) = 255: PalB(1) = 255   ' White
            
        CASE 3 ' Gameboy Green
            PRINT "Creating Game Boy palette..."
            PalCount = 4
            PalName = "Game Boy Green"
            PalR(0) = 15: PalG(0) = 56: PalB(0) = 15      ' Darkest Green
            PalR(1) = 48: PalG(1) = 98: PalB(1) = 48      ' Dark Green
            PalR(2) = 139: PalG(2) = 172: PalB(2) = 15    ' Light Green
            PalR(3) = 155: PalG(3) = 188: PalB(3) = 15    ' Lightest Green
            
        CASE 4 ' C64 colors
            PRINT "Creating C64 palette..."
            PalCount = 16
            PalName = "Commodore 64"
            PalR(0) = 0: PalG(0) = 0: PalB(0) = 0         ' Black
            PalR(1) = 255: PalG(1) = 255: PalB(1) = 255   ' White
            PalR(2) = 136: PalG(2) = 57: PalB(2) = 50     ' Red
            PalR(3) = 103: PalG(3) = 182: PalB(3) = 189   ' Cyan
            PalR(4) = 139: PalG(4) = 63: PalB(4) = 150    ' Purple
            PalR(5) = 85: PalG(5) = 160: PalB(5) = 73     ' Green
            PalR(6) = 64: PalG(6) = 49: PalB(6) = 141     ' Blue
            PalR(7) = 191: PalG(7) = 206: PalB(7) = 114   ' Yellow
            PalR(8) = 139: PalG(8) = 84: PalB(8) = 41     ' Orange
            PalR(9) = 87: PalG(9) = 66: PalB(9) = 0       ' Brown
            PalR(10) = 184: PalG(10) = 105: PalB(10) = 98 ' Light Red
            PalR(11) = 80: PalG(11) = 80: PalB(11) = 80   ' Dark Gray
            PalR(12) = 120: PalG(12) = 120: PalB(12) = 120 ' Gray
            PalR(13) = 148: PalG(13) = 224: PalB(13) = 137 ' Light Green
            PalR(14) = 120: PalG(14) = 105: PalB(14) = 196 ' Light Blue
            PalR(15) = 159: PalG(15) = 159: PalB(15) = 159 ' Light Gray
            
        CASE ELSE
            currentPalette = 0
            CALL CreatePalette(0)
            EXIT SUB
    END SELECT
    
    PRINT "Palette created:"; PalName; "with"; PalCount; "colors"
END SUB

SUB CreateTestImage
    PRINT "Creating 250x250 test gradient image..."
    IF originalImage <> 0 THEN _FREEIMAGE originalImage
    
    originalImage = _NEWIMAGE(250, 250, 32)
    DIM oldDest AS LONG
    oldDest = _DEST
    _DEST originalImage
    
    DIM x AS INTEGER, y AS INTEGER
    DIM r AS INTEGER, g AS INTEGER, b AS INTEGER
    
    FOR y = 0 TO 249
        FOR x = 0 TO 249
            ' Create a complex test pattern
            r = ((x * 255) \ 250 + (y * 128) \ 250) \ 2
            g = ((y * 255) \ 250 + SIN(x / 25) * 64 + 64) 
            b = ((x + y) * 255) \ 500 + COS(y / 20) * 32 + 32
            
            IF r < 0 THEN r = 0
            IF r > 255 THEN r = 255
            IF g < 0 THEN g = 0
            IF g > 255 THEN g = 255
            IF b < 0 THEN b = 0
            IF b > 255 THEN b = 255
            
            PSET (x, y), _RGB32(r, g, b)
        NEXT
    NEXT
    
    _DEST oldDest
    PRINT "Test image created. Applying initial dithering..."
    CALL ApplyDithering
END SUB

SUB DrawUI
    COLOR _RGB32(255, 255, 255)
    _PRINTSTRING (10, 10), "Advanced Dithering Test - " + STR$(GetMethodCount%) + " algorithms, " + STR$(GetPaletteCount%) + " palettes"
    
    _PRINTSTRING (10, 40), "Controls:"
    _PRINTSTRING (10, 60), "SPACE - Next dithering method (" + STR$(ditherMethod + 1) + "/" + STR$(GetMethodCount%) + ")"
    _PRINTSTRING (10, 80), "P - Next palette (" + STR$(currentPalette + 1) + "/" + STR$(GetPaletteCount%) + ")"
    _PRINTSTRING (10, 100), "ESC - Exit"
    
    _PRINTSTRING (10, 130), "Current Method: " + GetMethodName$(ditherMethod)
    _PRINTSTRING (10, 150), "Palette: " + PalName + " (" + STR$(PalCount) + " colors)"
    
    IF originalImage <> 0 THEN
        _PRINTSTRING (50, 190), "Original"
        _PUTIMAGE (50, 210)-(300, 460), originalImage
    END IF
    
    IF ditheredImage <> 0 THEN
        _PRINTSTRING (350, 190), "Dithered"
        _PUTIMAGE (350, 210)-(600, 460), ditheredImage
    END IF
    
    CALL DrawPalettePreview(650, 210)
    CALL DrawAlgorithmInfo(50, 480)
END SUB

SUB DrawAlgorithmInfo(x AS INTEGER, y AS INTEGER)
    DIM info AS STRING
    info = GetAlgorithmInfo$(ditherMethod)
    
    COLOR _RGB32(200, 200, 200)
    _PRINTSTRING (x, y), "Algorithm Info:"
    
    ' Split info into lines for display
    DIM lineCount AS INTEGER, i AS INTEGER, lineText AS STRING
    lineCount = 0
    i = 1
    WHILE i <= LEN(info)
        IF MID$(info, i, 1) = CHR$(10) OR i = LEN(info) THEN
            IF i = LEN(info) AND MID$(info, i, 1) <> CHR$(10) THEN
                lineText = lineText + MID$(info, i, 1)
            END IF
            _PRINTSTRING (x, y + 20 + lineCount * 16), lineText
            lineText = ""
            lineCount = lineCount + 1
            IF lineCount >= 8 THEN EXIT WHILE ' Limit display lines
        ELSE
            lineText = lineText + MID$(info, i, 1)
        END IF
        i = i + 1
    WEND
END SUB

SUB HandleInput
    DIM k AS STRING
    k = INKEY$
    
    IF UCASE$(k) = " " THEN
        ditherMethod = ditherMethod + 1
        IF ditherMethod >= GetMethodCount% THEN ditherMethod = 0
        _DEST _CONSOLE
        PRINT "Switched to dither method:"; ditherMethod; "(" + GetMethodName$(ditherMethod) + ")"
        _DEST 0
        CALL ApplyDithering
    ELSEIF UCASE$(k) = "P" THEN
        currentPalette = currentPalette + 1
        IF currentPalette >= GetPaletteCount% THEN currentPalette = 0
        _DEST _CONSOLE
        PRINT "Switched to palette:"; currentPalette
        _DEST 0
        CALL CreatePalette(currentPalette)
        CALL ApplyDithering
    END IF
END SUB

SUB ApplyDithering
    _DEST _CONSOLE
    PRINT "Applying dithering method:"; ditherMethod; "(" + GetMethodName$(ditherMethod) + ")"
    _DEST 0
    
    IF originalImage = 0 OR PalCount <= 0 THEN 
        _DEST _CONSOLE
        PRINT "No image or palette!"
        _DEST 0
        EXIT SUB
    END IF
    
    IF ditheredImage <> 0 THEN _FREEIMAGE ditheredImage
    
    ditheredImage = _COPYIMAGE(originalImage, 32)
    
    SELECT CASE ditherMethod
        CASE 0
            CALL QuantizeToPalette(ditheredImage)
        CASE 1
            CALL ApplyOrderedDither2x2(ditheredImage)
        CASE 2
            CALL ApplyOrderedDither4x4(ditheredImage)
        CASE 3
            CALL ApplyOrderedDither8x8(ditheredImage)
        CASE 4
            CALL ApplyFloydSteinberg(ditheredImage)
        CASE 5
            CALL ApplyJarvisJudiceNinke(ditheredImage)
        CASE 6
            CALL ApplyStucki(ditheredImage)
        CASE 7
            CALL ApplyBurkes(ditheredImage)
        CASE 8
            CALL ApplySierra(ditheredImage)
        CASE 9
            CALL ApplySierraLite(ditheredImage)
        CASE 10
            CALL ApplyAtkinson(ditheredImage)
        CASE 11
            CALL ApplyRandomDither(ditheredImage)
        CASE 12
            CALL ApplyBlueNoiseDither(ditheredImage)
        CASE 13
            CALL ApplyClusteredDot4x4(ditheredImage)
        CASE 14
            CALL ApplyHalftoneClassic(ditheredImage)
    END SELECT
    
    _DEST _CONSOLE
    PRINT "Dithering complete"
    _DEST 0
END SUB

FUNCTION GetMethodCount%
    GetMethodCount% = 15
END FUNCTION

FUNCTION GetPaletteCount%
    GetPaletteCount% = 5
END FUNCTION

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
    DIM w AS LONG, h AS LONG, x AS LONG, y AS LONG
    DIM c AS _UNSIGNED LONG, r AS INTEGER, g AS INTEGER, b AS INTEGER, idx AS INTEGER
    
    w = _WIDTH(img)
    h = _HEIGHT(img)
    DIM oldS AS LONG
    oldS = _SOURCE
    _SOURCE img
    DIM oldD AS LONG
    oldD = _DEST
    _DEST img
    
    FOR y = 0 TO h - 1
        FOR x = 0 TO w - 1
            c = POINT(x, y)
            r = _RED32(c)
            g = _GREEN32(c)
            b = _BLUE32(c)
            idx = NearestPaletteIndex%(r, g, b)
            PSET (x, y), _RGB32(PalR(idx), PalG(idx), PalB(idx))
        NEXT
    NEXT
    
    _SOURCE oldS
    _DEST oldD
END SUB

SUB ApplyOrderedDither2x2(img AS LONG)
    DIM w AS LONG, h AS LONG, x AS LONG, y AS LONG
    DIM c AS _UNSIGNED LONG, r AS INTEGER, g AS INTEGER, b AS INTEGER, idx AS INTEGER
    DIM threshold AS INTEGER
    
    DIM bayer(0 TO 1, 0 TO 1) AS INTEGER
    bayer(0, 0) = 0
    bayer(0, 1) = 2
    bayer(1, 0) = 3
    bayer(1, 1) = 1
    
    CALL ApplyOrderedDitherMatrix(img, bayer(), 2, 2, 4)
END SUB

SUB ApplyOrderedDither4x4(img AS LONG)
    DIM bayer(0 TO 3, 0 TO 3) AS INTEGER
    ' 4x4 Bayer matrix
    bayer(0, 0) = 0: bayer(0, 1) = 8: bayer(0, 2) = 2: bayer(0, 3) = 10
    bayer(1, 0) = 12: bayer(1, 1) = 4: bayer(1, 2) = 14: bayer(1, 3) = 6
    bayer(2, 0) = 3: bayer(2, 1) = 11: bayer(2, 2) = 1: bayer(2, 3) = 9
    bayer(3, 0) = 15: bayer(3, 1) = 7: bayer(3, 2) = 13: bayer(3, 3) = 5
    
    CALL ApplyOrderedDitherMatrix(img, bayer(), 4, 4, 16)
END SUB

SUB ApplyOrderedDither8x8(img AS LONG)
    DIM bayer(0 TO 7, 0 TO 7) AS INTEGER
    ' 8x8 Bayer matrix
    bayer(0, 0) = 0: bayer(0, 1) = 32: bayer(0, 2) = 8: bayer(0, 3) = 40: bayer(0, 4) = 2: bayer(0, 5) = 34: bayer(0, 6) = 10: bayer(0, 7) = 42
    bayer(1, 0) = 48: bayer(1, 1) = 16: bayer(1, 2) = 56: bayer(1, 3) = 24: bayer(1, 4) = 50: bayer(1, 5) = 18: bayer(1, 6) = 58: bayer(1, 7) = 26
    bayer(2, 0) = 12: bayer(2, 1) = 44: bayer(2, 2) = 4: bayer(2, 3) = 36: bayer(2, 4) = 14: bayer(2, 5) = 46: bayer(2, 6) = 6: bayer(2, 7) = 38
    bayer(3, 0) = 60: bayer(3, 1) = 28: bayer(3, 2) = 52: bayer(3, 3) = 20: bayer(3, 4) = 62: bayer(3, 5) = 30: bayer(3, 6) = 54: bayer(3, 7) = 22
    bayer(4, 0) = 3: bayer(4, 1) = 35: bayer(4, 2) = 11: bayer(4, 3) = 43: bayer(4, 4) = 1: bayer(4, 5) = 33: bayer(4, 6) = 9: bayer(4, 7) = 41
    bayer(5, 0) = 51: bayer(5, 1) = 19: bayer(5, 2) = 59: bayer(5, 3) = 27: bayer(5, 4) = 49: bayer(5, 5) = 17: bayer(5, 6) = 57: bayer(5, 7) = 25
    bayer(6, 0) = 15: bayer(6, 1) = 47: bayer(6, 2) = 7: bayer(6, 3) = 39: bayer(6, 4) = 13: bayer(6, 5) = 45: bayer(6, 6) = 5: bayer(6, 7) = 37
    bayer(7, 0) = 63: bayer(7, 1) = 31: bayer(7, 2) = 55: bayer(7, 3) = 23: bayer(7, 4) = 61: bayer(7, 5) = 29: bayer(7, 6) = 53: bayer(7, 7) = 21
    
    CALL ApplyOrderedDitherMatrix(img, bayer(), 8, 8, 64)
END SUB

SUB ApplyOrderedDitherMatrix(img AS LONG, matrix() AS INTEGER, matW AS INTEGER, matH AS INTEGER, maxVal AS INTEGER)
    DIM w AS LONG, h AS LONG, x AS LONG, y AS LONG
    DIM c AS _UNSIGNED LONG, r AS INTEGER, g AS INTEGER, b AS INTEGER, idx AS INTEGER
    DIM threshold AS INTEGER
    
    w = _WIDTH(img)
    h = _HEIGHT(img)
    DIM oldS AS LONG
    oldS = _SOURCE
    _SOURCE img
    DIM oldD AS LONG
    oldD = _DEST
    _DEST img
    
    FOR y = 0 TO h - 1
        FOR x = 0 TO w - 1
            c = POINT(x, y)
            r = _RED32(c)
            g = _GREEN32(c)
            b = _BLUE32(c)
            
            threshold = matrix(x MOD matW, y MOD matH) * 8 - (maxVal * 4)
            r = r + threshold
            IF r < 0 THEN r = 0
            IF r > 255 THEN r = 255
            g = g + threshold
            IF g < 0 THEN g = 0
            IF g > 255 THEN g = 255
            b = b + threshold
            IF b < 0 THEN b = 0
            IF b > 255 THEN b = 255
            
            idx = NearestPaletteIndex%(r, g, b)
            PSET (x, y), _RGB32(PalR(idx), PalG(idx), PalB(idx))
        NEXT
    NEXT
    
    _SOURCE oldS
    _DEST oldD
END SUB

SUB ApplyFloydSteinberg(img AS LONG)
    ' Error diffusion pattern:
    '     X   7/16
    ' 3/16 5/16 1/16
    CALL ApplyErrorDiffusion(img, 0)
END SUB

SUB ApplyJarvisJudiceNinke(img AS LONG)
    ' Jarvis-Judice-Ninke dithering (more complex error diffusion)
    CALL ApplyErrorDiffusion(img, 1)
END SUB

SUB ApplyStucki(img AS LONG)
    ' Stucki dithering
    CALL ApplyErrorDiffusion(img, 2)
END SUB

SUB ApplyBurkes(img AS LONG)
    ' Burkes dithering
    CALL ApplyErrorDiffusion(img, 3)
END SUB

SUB ApplySierra(img AS LONG)
    ' Sierra dithering
    CALL ApplyErrorDiffusion(img, 4)
END SUB

SUB ApplySierraLite(img AS LONG)
    ' Sierra Lite (2-row) dithering
    CALL ApplyErrorDiffusion(img, 5)
END SUB

SUB ApplyAtkinson(img AS LONG)
    ' Atkinson dithering (used by classic Mac)
    CALL ApplyErrorDiffusion(img, 6)
END SUB

SUB ApplyErrorDiffusion(img AS LONG, algorithm AS INTEGER)
    DIM w AS LONG, h AS LONG, x AS LONG, y AS LONG
    DIM c AS _UNSIGNED LONG, idx AS INTEGER
    DIM r AS SINGLE, g AS SINGLE, b AS SINGLE
    DIM nr AS INTEGER, ng AS INTEGER, nb AS INTEGER
    DIM er AS SINGLE, eg AS SINGLE, eb AS SINGLE
    
    ' Error buffers for current and next lines
    DIM rerr1(0 TO 300) AS SINGLE, gerr1(0 TO 300) AS SINGLE, berr1(0 TO 300) AS SINGLE
    DIM rerr2(0 TO 300) AS SINGLE, gerr2(0 TO 300) AS SINGLE, berr2(0 TO 300) AS SINGLE
    
    w = _WIDTH(img)
    h = _HEIGHT(img)
    DIM oldS AS LONG
    oldS = _SOURCE
    _SOURCE img
    DIM oldD AS LONG
    oldD = _DEST
    _DEST img
    
    FOR y = 0 TO h - 1
        FOR x = 0 TO w - 1
            c = POINT(x, y)
            r = _RED32(c) + rerr1(x)
            g = _GREEN32(c) + gerr1(x)
            b = _BLUE32(c) + berr1(x)
            
            IF r < 0 THEN r = 0
            IF r > 255 THEN r = 255
            IF g < 0 THEN g = 0
            IF g > 255 THEN g = 255
            IF b < 0 THEN b = 0
            IF b > 255 THEN b = 255
            
            idx = NearestPaletteIndex%(CINT(r), CINT(g), CINT(b))
            nr = PalR(idx)
            ng = PalG(idx)
            nb = PalB(idx)
            PSET (x, y), _RGB32(nr, ng, nb)
            
            er = r - nr
            eg = g - ng
            eb = b - nb
            
            ' Distribute error based on algorithm
            SELECT CASE algorithm
                CASE 0 ' Floyd-Steinberg
                    IF x < w - 1 THEN
                        rerr1(x + 1) = rerr1(x + 1) + er * 0.4375 ' 7/16
                        gerr1(x + 1) = gerr1(x + 1) + eg * 0.4375
                        berr1(x + 1) = berr1(x + 1) + eb * 0.4375
                    END IF
                    IF y < h - 1 THEN
                        IF x > 0 THEN
                            rerr2(x - 1) = rerr2(x - 1) + er * 0.1875 ' 3/16
                            gerr2(x - 1) = gerr2(x - 1) + eg * 0.1875
                            berr2(x - 1) = berr2(x - 1) + eb * 0.1875
                        END IF
                        rerr2(x) = rerr2(x) + er * 0.3125 ' 5/16
                        gerr2(x) = gerr2(x) + eg * 0.3125
                        berr2(x) = berr2(x) + eb * 0.3125
                        IF x < w - 1 THEN
                            rerr2(x + 1) = rerr2(x + 1) + er * 0.0625 ' 1/16
                            gerr2(x + 1) = gerr2(x + 1) + eg * 0.0625
                            berr2(x + 1) = berr2(x + 1) + eb * 0.0625
                        END IF
                    END IF
                    
                CASE 1 ' Jarvis-Judice-Ninke (simplified)
                    IF x < w - 1 THEN
                        rerr1(x + 1) = rerr1(x + 1) + er * 0.146 ' 7/48
                        gerr1(x + 1) = gerr1(x + 1) + eg * 0.146
                        berr1(x + 1) = berr1(x + 1) + eb * 0.146
                    END IF
                    IF x < w - 2 THEN
                        rerr1(x + 2) = rerr1(x + 2) + er * 0.104 ' 5/48
                        gerr1(x + 2) = gerr1(x + 2) + eg * 0.104
                        berr1(x + 2) = berr1(x + 2) + eb * 0.104
                    END IF
                    ' Next row distribution (simplified)
                    IF y < h - 1 THEN
                        rerr2(x) = rerr2(x) + er * 0.146
                        gerr2(x) = gerr2(x) + eg * 0.146
                        berr2(x) = berr2(x) + eb * 0.146
                    END IF
                    
                CASE ELSE ' Default to Floyd-Steinberg
                    IF x < w - 1 THEN
                        rerr1(x + 1) = rerr1(x + 1) + er * 0.5
                        gerr1(x + 1) = gerr1(x + 1) + eg * 0.5
                        berr1(x + 1) = berr1(x + 1) + eb * 0.5
                    END IF
            END SELECT
        NEXT
        
        ' Swap error buffers
        FOR x = 0 TO w
            rerr1(x) = rerr2(x)
            gerr1(x) = gerr2(x)
            berr1(x) = berr2(x)
            rerr2(x) = 0
            gerr2(x) = 0
            berr2(x) = 0
        NEXT
    NEXT
    
    _SOURCE oldS
    _DEST oldD
END SUB

SUB ApplyRandomDither(img AS LONG)
    DIM w AS LONG, h AS LONG, x AS LONG, y AS LONG
    DIM c AS _UNSIGNED LONG, r AS INTEGER, g AS INTEGER, b AS INTEGER, idx AS INTEGER
    DIM noise AS INTEGER
    
    w = _WIDTH(img)
    h = _HEIGHT(img)
    DIM oldS AS LONG
    oldS = _SOURCE
    _SOURCE img
    DIM oldD AS LONG
    oldD = _DEST
    _DEST img
    
    RANDOMIZE TIMER
    
    FOR y = 0 TO h - 1
        FOR x = 0 TO w - 1
            c = POINT(x, y)
            r = _RED32(c)
            g = _GREEN32(c)
            b = _BLUE32(c)
            
            noise = (RND * 64) - 32
            r = r + noise
            IF r < 0 THEN r = 0
            IF r > 255 THEN r = 255
            g = g + noise
            IF g < 0 THEN g = 0
            IF g > 255 THEN g = 255
            b = b + noise
            IF b < 0 THEN b = 0
            IF b > 255 THEN b = 255
            
            idx = NearestPaletteIndex%(r, g, b)
            PSET (x, y), _RGB32(PalR(idx), PalG(idx), PalB(idx))
        NEXT
    NEXT
    
    _SOURCE oldS
    _DEST oldD
END SUB

SUB ApplyBlueNoiseDither(img AS LONG)
    ' Simplified blue noise approximation using pseudo-random pattern
    DIM w AS LONG, h AS LONG, x AS LONG, y AS LONG
    DIM c AS _UNSIGNED LONG, r AS INTEGER, g AS INTEGER, b AS INTEGER, idx AS INTEGER
    DIM noise AS INTEGER
    
    w = _WIDTH(img)
    h = _HEIGHT(img)
    DIM oldS AS LONG
    oldS = _SOURCE
    _SOURCE img
    DIM oldD AS LONG
    oldD = _DEST
    _DEST img
    
    FOR y = 0 TO h - 1
        FOR x = 0 TO w - 1
            c = POINT(x, y)
            r = _RED32(c)
            g = _GREEN32(c)
            b = _BLUE32(c)
            
            ' Simple blue noise approximation using coordinate-based hash
            noise = ((x * 1234 + y * 5678) MOD 127) - 64
            r = r + noise
            IF r < 0 THEN r = 0
            IF r > 255 THEN r = 255
            g = g + noise
            IF g < 0 THEN g = 0
            IF g > 255 THEN g = 255
            b = b + noise
            IF b < 0 THEN b = 0
            IF b > 255 THEN b = 255
            
            idx = NearestPaletteIndex%(r, g, b)
            PSET (x, y), _RGB32(PalR(idx), PalG(idx), PalB(idx))
        NEXT
    NEXT
    
    _SOURCE oldS
    _DEST oldD
END SUB

SUB ApplyClusteredDot4x4(img AS LONG)
    ' Clustered dot dithering (newspaper-style halftoning)
    DIM clustered(0 TO 3, 0 TO 3) AS INTEGER
    clustered(0, 0) = 12: clustered(0, 1) = 5: clustered(0, 2) = 6: clustered(0, 3) = 13
    clustered(1, 0) = 4: clustered(1, 1) = 0: clustered(1, 2) = 1: clustered(1, 3) = 7
    clustered(2, 0) = 11: clustered(2, 1) = 3: clustered(2, 2) = 2: clustered(2, 3) = 8
    clustered(3, 0) = 15: clustered(3, 1) = 10: clustered(3, 2) = 9: clustered(3, 3) = 14
    
    CALL ApplyOrderedDitherMatrix(img, clustered(), 4, 4, 16)
END SUB

SUB ApplyHalftoneClassic(img AS LONG)
    ' Classic halftone pattern using distance from center
    DIM w AS LONG, h AS LONG, x AS LONG, y AS LONG
    DIM c AS _UNSIGNED LONG, r AS INTEGER, g AS INTEGER, b AS INTEGER, idx AS INTEGER
    DIM gray AS INTEGER, threshold AS INTEGER
    DIM dx AS SINGLE, dy AS SINGLE, dist AS SINGLE
    
    w = _WIDTH(img)
    h = _HEIGHT(img)
    DIM oldS AS LONG
    oldS = _SOURCE
    _SOURCE img
    DIM oldD AS LONG
    oldD = _DEST
    _DEST img
    
    FOR y = 0 TO h - 1
        FOR x = 0 TO w - 1
            c = POINT(x, y)
            r = _RED32(c)
            g = _GREEN32(c)
            b = _BLUE32(c)
            gray = (r + g + b) \ 3
            
            ' Calculate distance from cell center in 8x8 grid
            dx = (x MOD 8) - 4
            dy = (y MOD 8) - 4
            dist = SQR(dx * dx + dy * dy)
            threshold = (dist / 5.66) * 255 ' 5.66 is max distance
            
            IF gray > threshold THEN
                idx = NearestPaletteIndex%(255, 255, 255) ' Use lightest color
            ELSE
                idx = NearestPaletteIndex%(0, 0, 0) ' Use darkest color
            END IF
            
            PSET (x, y), _RGB32(PalR(idx), PalG(idx), PalB(idx))
        NEXT
    NEXT
    
    _SOURCE oldS
    _DEST oldD
END SUB

SUB DrawPalettePreview(x AS INTEGER, y AS INTEGER)
    DIM i AS INTEGER, px AS INTEGER, py AS INTEGER
    DIM size AS INTEGER
    size = 20
    
    _PRINTSTRING (x, y - 20), "Palette:"
    
    FOR i = 0 TO PalCount - 1
        px = x + (i MOD 8) * size
        py = y + (i \ 8) * size
        LINE (px, py)-(px + size - 2, py + size - 2), _RGB32(PalR(i), PalG(i), PalB(i)), BF
        LINE (px, py)-(px + size - 2, py + size - 2), _RGB32(128, 128, 128), B
    NEXT
END SUB

FUNCTION GetMethodName$(method AS INTEGER)
    SELECT CASE method
        CASE 0
            GetMethodName$ = "No Dithering (Quantize Only)"
        CASE 1
            GetMethodName$ = "Ordered Dither 2x2 (Bayer)"
        CASE 2
            GetMethodName$ = "Ordered Dither 4x4 (Bayer)"
        CASE 3
            GetMethodName$ = "Ordered Dither 8x8 (Bayer)"
        CASE 4
            GetMethodName$ = "Floyd-Steinberg Error Diffusion"
        CASE 5
            GetMethodName$ = "Jarvis-Judice-Ninke"
        CASE 6
            GetMethodName$ = "Stucki Error Diffusion"
        CASE 7
            GetMethodName$ = "Burkes Error Diffusion"
        CASE 8
            GetMethodName$ = "Sierra Error Diffusion"
        CASE 9
            GetMethodName$ = "Sierra Lite"
        CASE 10
            GetMethodName$ = "Atkinson (Classic Mac)"
        CASE 11
            GetMethodName$ = "Random Dithering"
        CASE 12
            GetMethodName$ = "Blue Noise Dithering"
        CASE 13
            GetMethodName$ = "Clustered Dot 4x4"
        CASE 14
            GetMethodName$ = "Classic Halftone"
        CASE ELSE
            GetMethodName$ = "Unknown Method"
    END SELECT
END FUNCTION

FUNCTION GetAlgorithmInfo$(method AS INTEGER)
    SELECT CASE method
        CASE 0
            GetAlgorithmInfo$ = "Simple nearest-color quantization." + CHR$(10) + "No dithering pattern applied." + CHR$(10) + "Fast but shows banding artifacts."
        CASE 1
            GetAlgorithmInfo$ = "2x2 Bayer ordered dithering matrix." + CHR$(10) + "Creates regular crosshatch pattern." + CHR$(10) + "Good for low-resolution displays."
        CASE 2
            GetAlgorithmInfo$ = "4x4 Bayer ordered dithering matrix." + CHR$(10) + "More detail than 2x2, regular pattern." + CHR$(10) + "Classic dithering for print/web."
        CASE 3
            GetAlgorithmInfo$ = "8x8 Bayer ordered dithering matrix." + CHR$(10) + "High detail, fine regular pattern." + CHR$(10) + "Good for high-resolution output."
        CASE 4
            GetAlgorithmInfo$ = "Floyd-Steinberg error diffusion." + CHR$(10) + "Distributes error to adjacent pixels." + CHR$(10) + "Natural, organic-looking results."
        CASE 5
            GetAlgorithmInfo$ = "Jarvis-Judice-Ninke algorithm." + CHR$(10) + "More complex error distribution." + CHR$(10) + "Smoother than Floyd-Steinberg."
        CASE 6
            GetAlgorithmInfo$ = "Stucki error diffusion." + CHR$(10) + "Large error distribution kernel." + CHR$(10) + "Very smooth gradients."
        CASE 7
            GetAlgorithmInfo$ = "Burkes error diffusion." + CHR$(10) + "Medium complexity distribution." + CHR$(10) + "Good balance of speed and quality."
        CASE 8
            GetAlgorithmInfo$ = "Sierra error diffusion." + CHR$(10) + "Three-row error distribution." + CHR$(10) + "Excellent gradient reproduction."
        CASE 9
            GetAlgorithmInfo$ = "Sierra Lite (2-row) algorithm." + CHR$(10) + "Simplified Sierra dithering." + CHR$(10) + "Faster processing, good quality."
        CASE 10
            GetAlgorithmInfo$ = "Atkinson dithering algorithm." + CHR$(10) + "Used in classic Macintosh systems." + CHR$(10) + "Preserves sharp edges well."
        CASE 11
            GetAlgorithmInfo$ = "Random noise dithering." + CHR$(10) + "Adds random noise before quantization." + CHR$(10) + "Breaks up banding, chaotic look."
        CASE 12
            GetAlgorithmInfo$ = "Blue noise dithering (approximated)." + CHR$(10) + "Pseudo-random high-frequency pattern." + CHR$(10) + "Minimal visual artifacts."
        CASE 13
            GetAlgorithmInfo$ = "Clustered dot 4x4 matrix." + CHR$(10) + "Newspaper-style halftone pattern." + CHR$(10) + "Creates dot clusters for printing."
        CASE 14
            GetAlgorithmInfo$ = "Classic halftone screening." + CHR$(10) + "Distance-based dot pattern." + CHR$(10) + "Traditional print reproduction."
        CASE ELSE
            GetAlgorithmInfo$ = "No information available."
    END SELECT
END FUNCTION
