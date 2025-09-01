' Simple Pattern Test - Creates a basic BMP for testing
' Creates a 16x16 checkerboard pattern as BMP

_TITLE "Simple Pattern Creator"

DIM img AS LONG
img = _NEWIMAGE(16, 16, 32)
_DEST img

' Clear to black
CLS

' Create simple checkerboard pattern
FOR y = 0 TO 15
    FOR x = 0 TO 15
        IF (x \ 2 + y \ 2) MOD 2 = 0 THEN
            PSET (x, y), _RGB32(255, 255, 255) ' White
        ELSE
            PSET (x, y), _RGB32(0, 0, 0) ' Black
        END IF
    NEXT x
NEXT y

' Save pattern
_SAVEIMAGE "resources\patterns\test_pattern.bmp", img
_FREEIMAGE img

PRINT "Created test_pattern.bmp"
PRINT "You can now test bitmap pattern loading in IMG2PAL!"
PRINT "1. Run IMG2PAL"
PRINT "2. Select Pattern Dithering (method 23)"
PRINT "3. Press M to load test_pattern.bmp"
PRINT "4. Press K to switch to the loaded pattern"
PRINT
PRINT "Press any key to exit..."
SLEEP
