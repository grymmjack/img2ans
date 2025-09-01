' MacPaint Pattern Generator
' Creates test bitmap patterns for the pattern dithering system

_TITLE "MacPaint Pattern Generator"
SCREEN _NEWIMAGE(640, 480, 32)

PRINT "MacPaint Pattern Generator"
PRINT "========================="
PRINT

' Check if directory exists
IF _DIREXISTS("resources") THEN
    PRINT "resources\ directory exists"
ELSE
    PRINT "Creating resources\ directory..."
    MKDIR "resources"
END IF

IF _DIREXISTS("resources\patterns") THEN
    PRINT "patterns\ directory exists"
ELSE
    PRINT "Creating patterns\ directory..."
    MKDIR "resources\patterns"
END IF

PRINT
PRINT "Creating test patterns..."

' Create patterns
CALL CreateDotsPattern
CALL CreateDiagonalPattern  
CALL CreateBrickPattern
CALL CreateCheckerPattern

PRINT
PRINT "Test patterns created in resources\patterns\"
PRINT "Ready to test bitmap pattern loading!"
PRINT "Press any key to exit..."
SLEEP

SUB CreateDotsPattern
    DIM img AS LONG
    img = _NEWIMAGE(16, 16, 32)
    _DEST img
    
    ' Clear to black
    CLS 0
    
    ' Create dot pattern
    FOR y = 0 TO 15
        FOR x = 0 TO 15
            IF (x MOD 4 = 1) AND (y MOD 4 = 1) THEN
                PSET (x, y), _RGB32(255, 255, 255) ' White dot
            END IF
        NEXT x
    NEXT y
    
    ' Save as BMP
    _SAVEIMAGE "resources\patterns\macpaint_dots.bmp", img
    _FREEIMAGE img
    PRINT "Created macpaint_dots.bmp"
END SUB

SUB CreateDiagonalPattern
    DIM img AS LONG
    img = _NEWIMAGE(16, 16, 32)
    _DEST img
    
    ' Clear to black
    CLS 0
    
    ' Create diagonal line pattern  
    FOR y = 0 TO 15
        FOR x = 0 TO 15
            IF (x + y) MOD 4 < 2 THEN
                PSET (x, y), _RGB32(255, 255, 255) ' White line
            END IF
        NEXT x
    NEXT y
    
    ' Save as BMP
    _SAVEIMAGE "resources\patterns\macpaint_diagonal.bmp", img
    _FREEIMAGE img
    PRINT "Created macpaint_diagonal.bmp"
END SUB

SUB CreateBrickPattern
    DIM img AS LONG
    img = _NEWIMAGE(16, 16, 32)
    _DEST img
    
    ' Clear to black
    CLS 0
    
    ' Create brick pattern
    FOR y = 0 TO 15
        FOR x = 0 TO 15
            IF y MOD 8 < 4 THEN
                IF x MOD 8 < 1 THEN PSET (x, y), _RGB32(255, 255, 255)
            ELSE
                IF (x + 4) MOD 8 < 1 THEN PSET (x, y), _RGB32(255, 255, 255)
            END IF
        NEXT x
    NEXT y
    
    ' Save as BMP
    _SAVEIMAGE "resources\patterns\macpaint_brick.bmp", img
    _FREEIMAGE img
    PRINT "Created macpaint_brick.bmp"
END SUB

SUB CreateCheckerPattern
    DIM img AS LONG
    img = _NEWIMAGE(16, 16, 32)
    _DEST img
    
    ' Clear to black
    CLS 0
    
    ' Create checker pattern
    FOR y = 0 TO 15
        FOR x = 0 TO 15
            IF (x \ 2 + y \ 2) MOD 2 = 0 THEN
                PSET (x, y), _RGB32(255, 255, 255) ' White square
            END IF
        NEXT x
    NEXT y
    
    ' Save as BMP
    _SAVEIMAGE "resources\patterns\macpaint_checker.bmp", img
    _FREEIMAGE img
    PRINT "Created macpaint_checker.bmp"
END SUB
