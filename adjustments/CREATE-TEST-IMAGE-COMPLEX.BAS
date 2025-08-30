' CREATE-TEST-IMAGE-COMPLEX.BAS
' Creates a complex test pattern image and saves it as TESTIMAGE-COMPLEX.PNG
$CONSOLE
_CONSOLE ON

PRINT "Creating complex test pattern image..."

' Create test image
DIM img AS LONG
img = _NEWIMAGE(300, 300, 32)
CALL CreateComplexTestImage(img)

' Set up temporary screen to save the image
SCREEN _NEWIMAGE(300, 300, 32)
_PUTIMAGE , img
_SAVEIMAGE "TESTIMAGE-COMPLEX.PNG"

' Clean up
_FREEIMAGE img
PRINT "Test image saved as TESTIMAGE-COMPLEX.PNG"
SYSTEM

SUB CreateComplexTestImage (img AS LONG)
    DIM oldDest AS LONG
    oldDest = _DEST
    _DEST img
    
    DIM x AS INTEGER, y AS INTEGER
    DIM r AS INTEGER, g AS INTEGER, b AS INTEGER
    DIM centerX AS INTEGER, centerY AS INTEGER
    DIM dist AS SINGLE, angle AS SINGLE
    
    centerX = 150: centerY = 150
    
    FOR y = 0 TO 299
        FOR x = 0 TO 299
            ' Calculate distance from center and angle
            dist = SQR((x - centerX) * (x - centerX) + (y - centerY) * (y - centerY))
            angle = _ATAN2(y - centerY, x - centerX) * 180 / _PI
            
            ' Create complex test pattern with various features
            IF dist < 50 THEN
                ' Center circle - solid color gradient
                r = 255 - (dist * 5)
                g = 128 + (SIN(angle * _PI / 180) * 64)
                b = 64 + (COS(angle * _PI / 180) * 64)
            ELSEIF dist < 100 THEN
                ' Ring area - color bands
                r = 128 + SIN((angle + dist) * _PI / 180 * 3) * 127
                g = 128 + COS(angle * _PI / 180 * 2) * 127
                b = 64 + SIN(dist * _PI / 180) * 64
            ELSEIF x < 100 THEN
                ' Left section - brightness ramp
                r = (y * 255) \ 300
                g = r \ 2
                b = r \ 4
            ELSEIF x > 200 THEN
                ' Right section - color wheel
                r = 128 + SIN(y * _PI / 180 * 2) * 127
                g = 128 + COS(y * _PI / 180 * 3) * 127
                b = 128 + SIN(y * _PI / 180 * 4) * 127
            ELSE
                ' Middle section - mixed patterns
                r = ((x * 255) \ 300 + (y * 128) \ 300) \ 2
                g = ((y * 255) \ 300 + SIN(x / 25) * 64 + 64)
                b = ((x + y) * 255) \ 600 + COS(y / 20) * 32 + 32
            END IF
            
            ' Add some noise for testing
            r = r + (RND * 20) - 10
            g = g + (RND * 20) - 10
            b = b + (RND * 20) - 10
            
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
END SUB
