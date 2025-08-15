' core/palette.bas — palette loading & nearest-color lookup (QB64-PE)
'$INCLUDE:'palette.bi'

FUNCTION LoadGimpPalette%% (path$)
    ' Reads a GIMP .GPL file into PalR/PalG/PalB arrays.
    ' Returns number of colors loaded, or 0 on failure.
    DIM h AS LONG, line$, r AS LONG, g AS LONG, b AS LONG, name$
    DIM tmpR(0 TO 1023) AS INTEGER, tmpG(0 TO 1023) AS INTEGER, tmpB(0 TO 1023) AS INTEGER
    DIM n AS INTEGER: n = 0
    IF _FILEEXISTS(path$) = 0 THEN LoadGimpPalette%% = 0: EXIT FUNCTION

    h = FREEFILE
    OPEN path$ FOR INPUT AS #h
    DO WHILE NOT EOF(h)
        LINE INPUT #h, line$
        IF LEN(_TRIM$(line$)) = 0 THEN _CONTINUE
        IF LEFT$(line$, 1) = "#" THEN _CONTINUE
        IF UCASE$(LEFT$(line$, 7)) = "GIMP PA" THEN _CONTINUE
        IF UCASE$(LEFT$(line$, 4)) = "NAME" THEN
            PalName$ = _TRIM$(_MID$(line$, 6))
            _CONTINUE
        END IF
        ' Try to parse "r g b [name]"
        r = 0: g = 0: b = 0
        ON ERROR GOTO ParseFail
        r = VAL(_TRIM$(_WORD$(line$, 1, " ")))
        g = VAL(_TRIM$(_WORD$(line$, 2, " ")))
        b = VAL(_TRIM$(_WORD$(line$, 3, " ")))
        IF r < 0 OR r > 255 OR g < 0 OR g > 255 OR b < 0 OR b > 255 THEN GOTO ParseFail
        tmpR(n) = r: tmpG(n) = g: tmpB(n) = b
        n = n + 1
        IF n > UBOUND(tmpR) THEN EXIT DO
        GOTO NextLine
ParseFail:
        ' ignore non-color lines
        RESUME NextLine
NextLine:
        ' continue
        _CONTINUE
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
    EXIT FUNCTION
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
