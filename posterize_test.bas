SCREEN _NEWIMAGE(400, 300, 32)

' Create a test image with gradients
FOR y = 0 TO 299
    FOR x = 0 TO 399
        DIM r AS INTEGER, g AS INTEGER, b AS INTEGER
        r = (x * 255) \ 399
        g = (y * 255) \ 299
        b = ((x + y) * 255) \ 698
        PSET (x, y), _RGB32(r, g, b)
    NEXT
NEXT

PRINT "Original test image created. Press any key to start posterize tests..."
SLEEP

FOR targetColors = 2 TO 16
    ' Copy original to test area
    FOR y = 0 TO 299
        FOR x = 0 TO 399
            DIM r AS INTEGER, g AS INTEGER, b AS INTEGER
            r = (x * 255) \ 399
            g = (y * 255) \ 299
            b = ((x + y) * 255) \ 698
            PSET (x, y), _RGB32(r, g, b)
        NEXT
    NEXT
    
    ' Apply posterize
    CALL SimplePosterize(targetColors)
    
    ' Count actual unique colors
    DIM actualColors AS INTEGER
    actualColors = CountUniqueColors()
    
    PRINT "Target:"; targetColors; "colors -> Actual:"; actualColors; "colors"
    SLEEP 1
NEXT

PRINT "Test complete. Press any key to exit."
SLEEP

SUB SimplePosterize (numColors AS INTEGER)
    ' Calculate levels per channel
    DIM levels AS INTEGER
    IF numColors <= 8 THEN 
        levels = 2
    ELSEIF numColors <= 27 THEN 
        levels = 3
    ELSEIF numColors <= 64 THEN 
        levels = 4
    ELSEIF numColors <= 125 THEN 
        levels = 5
    ELSE 
        levels = 6
    END IF
    
    PRINT "Using"; levels; "levels per channel for"; numColors; "target colors"
    
    ' Process each pixel
    FOR y = 0 TO 299
        FOR x = 0 TO 399
            DIM pixel AS _UNSIGNED LONG
            pixel = POINT(x, y)
            DIM r AS INTEGER, g AS INTEGER, b AS INTEGER
            r = _RED32(pixel)
            g = _GREEN32(pixel)
            b = _BLUE32(pixel)
            
            ' Simple level reduction
            DIM newR AS INTEGER, newG AS INTEGER, newB AS INTEGER
            newR = (r * (levels - 1)) \ 255
            newG = (g * (levels - 1)) \ 255  
            newB = (b * (levels - 1)) \ 255
            
            ' Scale back to 0-255
            newR = (newR * 255) \ (levels - 1)
            newG = (newG * 255) \ (levels - 1)
            newB = (newB * 255) \ (levels - 1)
            
            PSET (x, y), _RGB32(newR, newG, newB)
        NEXT
    NEXT
END SUB

FUNCTION CountUniqueColors% ()
    ' Count unique colors in current image
    DIM colorSet(65535) AS INTEGER ' Hash set for colors
    DIM uniqueCount AS INTEGER
    uniqueCount = 0
    
    FOR y = 0 TO 299
        FOR x = 0 TO 399
            DIM pixel AS _UNSIGNED LONG
            pixel = POINT(x, y)
            DIM r AS INTEGER, g AS INTEGER, b AS INTEGER
            r = _RED32(pixel)
            g = _GREEN32(pixel)
            b = _BLUE32(pixel)
            
            ' Create a hash for this color (reduce to 16-bit)
            DIM colorHash AS INTEGER
            colorHash = ((r \ 8) * 32 + (g \ 8)) * 32 + (b \ 8)
            IF colorHash > 65535 THEN colorHash = 65535
            
            IF colorSet(colorHash) = 0 THEN
                colorSet(colorHash) = 1
                uniqueCount = uniqueCount + 1
            END IF
        NEXT
    NEXT
    
    CountUniqueColors% = uniqueCount
END FUNCTION
