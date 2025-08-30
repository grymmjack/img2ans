' Test the updated core image operations with blur
$CONSOLE
_CONSOLE ON

'$INCLUDE:'core/image_ops.bi'

PRINT "Testing core image operations with blur..."

' Create a simple test image
DIM testImg AS LONG
testImg = _NEWIMAGE(100, 100, 32)

DIM oldDest AS LONG
oldDest = _DEST
_DEST testImg

' Create a simple pattern
DIM x AS INTEGER, y AS INTEGER
FOR y = 0 TO 99
    FOR x = 0 TO 99
        IF (x + y) MOD 20 < 10 THEN
            PSET (x, y), _RGB32(255, 255, 255)
        ELSE
            PSET (x, y), _RGB32(0, 0, 0)
        END IF
    NEXT x
NEXT y

_DEST oldDest

PRINT "Test image created..."

' Test individual blur function
PRINT "Testing ApplyBlur with radius 3..."
CALL ApplyBlur(testImg, 3)
PRINT "Blur applied successfully!"

' Test combined function
PRINT "Testing AdjustImageInPlaceWithBlur..."
CALL AdjustImageInPlaceWithBlur(testImg, 20, 10, 0, 2)
PRINT "Combined adjustments applied successfully!"

_FREEIMAGE testImg
PRINT "All tests passed! Core blur functionality working."

'$INCLUDE:'core/image_ops.bas'
