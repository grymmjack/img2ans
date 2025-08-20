' Simplified palette.bas for dithering test
'$INCLUDE:'palette.bi'

FUNCTION LoadGimpPalette%% (path$)
    ' Simple parser for GIMP .GPL files
    DIM h AS LONG, line$
    DIM tmpR(0 TO 255) AS INTEGER, tmpG(0 TO 255) AS INTEGER, tmpB(0 TO 255) AS INTEGER
    DIM n AS INTEGER: n = 0
    DIM r AS INTEGER, g AS INTEGER, b AS INTEGER
    DIM pos1 AS INTEGER, pos2 AS INTEGER
    
    IF _FILEEXISTS(path$) = 0 THEN LoadGimpPalette%% = 0: EXIT FUNCTION

    h = FREEFILE
    OPEN path$ FOR INPUT AS #h
    
    DO WHILE NOT EOF(h) AND n < 256
        LINE INPUT #h, line$
        line$ = _TRIM$(line$)
        IF LEN(line$) = 0 THEN _CONTINUE
        IF LEFT$(line$, 1) = "#" THEN _CONTINUE
        IF UCASE$(LEFT$(line$, 7)) = "GIMP PA" THEN _CONTINUE
        IF UCASE$(LEFT$(line$, 4)) = "NAME" THEN
            PalName$ = _TRIM$(MID$(line$, 6))
            _CONTINUE
        END IF
        
        ' Parse "r g b [name]" using simple string parsing
        pos1 = INSTR(line$, " ")
        IF pos1 = 0 THEN _CONTINUE
        r = VAL(LEFT$(line$, pos1 - 1))
        
        line$ = _TRIM$(MID$(line$, pos1 + 1))
        pos2 = INSTR(line$, " ")
        IF pos2 = 0 THEN _CONTINUE
        g = VAL(LEFT$(line$, pos2 - 1))
        
        line$ = _TRIM$(MID$(line$, pos2 + 1))
        pos1 = INSTR(line$, " ")
        IF pos1 > 0 THEN
            b = VAL(LEFT$(line$, pos1 - 1))
        ELSE
            b = VAL(line$)
        END IF
        
        IF r >= 0 AND r <= 255 AND g >= 0 AND g <= 255 AND b >= 0 AND b <= 255 THEN
            tmpR(n) = r: tmpG(n) = g: tmpB(n) = b
            n = n + 1
        END IF
    LOOP
    CLOSE #h

    IF n <= 0 THEN LoadGimpPalette%% = 0: EXIT FUNCTION

    REDIM PalR(0 TO n - 1) AS INTEGER
    REDIM PalG(0 TO n - 1) AS INTEGER
    REDIM PalB(0 TO n - 1) AS INTEGER
    DIM i AS INTEGER
    FOR i = 0 TO n - 1
        PalR(i) = tmpR(i): PalG(i) = tmpG(i): PalB(i) = tmpB(i)
    NEXT
    PalCount = n
    LoadGimpPalette%% = n
END FUNCTION

FUNCTION NearestIndex%% (r AS INTEGER, g AS INTEGER, b AS INTEGER, useSRGB AS _BYTE)
    ' Returns palette index with minimal squared error.
    IF PalCount <= 0 THEN NearestIndex%% = 0: EXIT FUNCTION
    DIM i AS INTEGER, bestI AS INTEGER, dr AS SINGLE, dg AS SINGLE, db AS SINGLE, e AS SINGLE, bestE AS SINGLE
    bestE = 1E+30: bestI = 0
    DIM rr AS SINGLE, gg AS SINGLE, bb AS SINGLE
    IF useSRGB THEN
        rr = CSNG((r / 255.0) ^ 2.2)
        gg = CSNG((g / 255.0) ^ 2.2)
        bb = CSNG((b / 255.0) ^ 2.2)
        FOR i = 0 TO PalCount - 1
            dr = rr - CSNG((PalR(i) / 255.0) ^ 2.2)
            dg = gg - CSNG((PalG(i) / 255.0) ^ 2.2)
            db = bb - CSNG((PalB(i) / 255.0) ^ 2.2)
            e = dr * dr + dg * dg + db * db
            IF e < bestE THEN bestE = e: bestI = i
        NEXT
    ELSE
        FOR i = 0 TO PalCount - 1
            dr = r - PalR(i): dg = g - PalG(i): db = b - PalB(i)
            e = dr * dr + dg * dg + db * db
            IF e < bestE THEN bestE = e: bestI = i
        NEXT
    END IF
    NearestIndex%% = bestI
END FUNCTION
