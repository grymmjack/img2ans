' Simple Brightness Adjustment Test
$CONSOLE
_CONSOLE ON

PRINT "Simple Brightness Test - Loading image..."

' Setup graphics screen
SCREEN _NEWIMAGE(600, 400, 32)
_TITLE "Simple Brightness Test - Press +/- to adjust, ESC to exit"

' Load test image
DIM originalImage AS LONG, workingImage AS LONG
originalImage = _LOADIMAGE("TESTIMAGE.PNG", 32)
IF originalImage = -1 THEN
    PRINT "Error: Could not load TESTIMAGE.PNG"
    PRINT "Run CREATE-TEST-IMAGE.BAS first to create the test image"
    SYSTEM
END IF
workingImage = _COPYIMAGE(originalImage, 32)

DIM brightness AS INTEGER
brightness = 0

PRINT "Controls:"
PRINT "  + = increase brightness"
PRINT "  - = decrease brightness"
PRINT "  R = reset to original"
PRINT "  ESC = exit"
PRINT "Switch to graphics window!"

DO
    ' Copy original to working image
    _FREEIMAGE workingImage
    workingImage = _COPYIMAGE(originalImage, 32)
    
    ' Apply brightness adjustment
    IF brightness <> 0 THEN CALL AdjustBrightness(workingImage, brightness)
    
    ' Draw on screen
    _DEST 0
    CLS
    
    ' Draw original and adjusted images side by side
    _PUTIMAGE (50, 50), originalImage
    _PUTIMAGE (350, 50), workingImage
    
    ' Draw labels and info
    COLOR _RGB32(255, 255, 255)
    _PRINTSTRING (50, 30), "Original"
    _PRINTSTRING (350, 30), "Brightness: " + STR$(brightness)
    _PRINTSTRING (50, 270), "Controls: +/- adjust, R reset, ESC exit"
    
    _DISPLAY
    
    ' Handle input
    k$ = INKEY$
    IF k$ <> "" THEN
        SELECT CASE k$
            CASE "+"
                brightness = brightness + 10
                IF brightness > 255 THEN brightness = 255
            CASE "-"
                brightness = brightness - 10
                IF brightness < -255 THEN brightness = -255
            CASE "r", "R"
                brightness = 0
            CASE CHR$(27) ' ESC
                EXIT DO
        END SELECT
    END IF
    
    _LIMIT 30
LOOP

' Cleanup
_FREEIMAGE originalImage
_FREEIMAGE workingImage
PRINT "Program ended."
SYSTEM

SUB AdjustBrightness (img AS LONG, offset AS INTEGER)
    DIM w AS LONG, h AS LONG, x AS LONG, y AS LONG, c AS _UNSIGNED LONG
    DIM r AS INTEGER, g AS INTEGER, b AS INTEGER
    
    w = _WIDTH(img): h = _HEIGHT(img)
    _SOURCE img: _DEST img
    
    FOR y = 0 TO h - 1
        FOR x = 0 TO w - 1
            c = POINT(x, y)
            r = _RED32(c) + offset
            g = _GREEN32(c) + offset  
            b = _BLUE32(c) + offset
            
            ' Clamp values to 0-255 range
            IF r < 0 THEN r = 0 ELSE IF r > 255 THEN r = 255
            IF g < 0 THEN g = 0 ELSE IF g > 255 THEN g = 255
            IF b < 0 THEN b = 0 ELSE IF b > 255 THEN b = 255
            
            PSET (x, y), _RGB32(r, g, b)
        NEXT
    NEXT
END SUB
