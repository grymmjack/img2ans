' CREATE-TEST-IMAGE-GRADIENT.BAS
' Creates a simple RGB gradient test image and saves it as TESTIMAGE-GRADIENT.PNG
$CONSOLE
_CONSOLE ON

PRINT "Creating RGB gradient test image..."

' Create test image
DIM img AS LONG
img = _NEWIMAGE(200, 200, 32)
CALL CreateGradientTestImage(img)

' Set up temporary screen to save the image
SCREEN _NEWIMAGE(200, 200, 32)
_PUTIMAGE , img
_SAVEIMAGE "TESTIMAGE-GRADIENT.PNG"

' Clean up
_FREEIMAGE img
PRINT "Test image saved as TESTIMAGE-GRADIENT.PNG"
SYSTEM

SUB CreateGradientTestImage (img AS LONG)
    DIM x AS LONG, y AS LONG
    _DEST img
    
    ' Create a gradient with some colored squares
    FOR y = 0 TO _HEIGHT(img) - 1
        FOR x = 0 TO _WIDTH(img) - 1
            IF x < _WIDTH(img) / 3 THEN
                PSET (x, y), _RGB32(255 - (y * 255) / _HEIGHT(img), 0, 0) ' Red gradient
            ELSEIF x < 2 * _WIDTH(img) / 3 THEN
                PSET (x, y), _RGB32(0, 255 - (y * 255) / _HEIGHT(img), 0) ' Green gradient
            ELSE
                PSET (x, y), _RGB32(0, 0, 255 - (y * 255) / _HEIGHT(img)) ' Blue gradient
            END IF
        NEXT
    NEXT
END SUB
