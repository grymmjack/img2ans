' Simplified dither.bas for dithering test
'$INCLUDE:'dither.bi'

' ---------- Helpers ----------

FUNCTION Clamp8%%(x AS LONG)
    IF x < 0 THEN Clamp8%% = 0 ELSE IF x > 255 THEN Clamp8%% = 255 ELSE Clamp8%% = x
END FUNCTION

FUNCTION NearestColorUL&(r AS INTEGER, g AS INTEGER, b AS INTEGER, useSRGB AS _BYTE)
    DIM idx AS INTEGER: idx = NearestIndex(r, g, b, useSRGB)
    NearestColorUL& = _RGB32(PalR(idx), PalG(idx), PalB(idx))
END FUNCTION

' ---------- Ordered Dither (Bayer) ----------

SUB ApplyOrderedPaletteDither (img AS LONG, useSRGB AS _BYTE, matrixSize AS INTEGER, amount AS SINGLE)
    IF PalCount <= 0 THEN EXIT SUB
    IF amount < 0 THEN amount = 0
    IF amount > 1 THEN amount = 1
    IF matrixSize <> 4 AND matrixSize <> 8 THEN matrixSize = 4

    DIM bx4(0 TO 3, 0 TO 3) AS INTEGER
    DATA 0, 8, 2,10, 12, 4,14, 6, 3,11, 1, 9, 15, 7,13, 5
    DIM i AS INTEGER, j AS INTEGER
    FOR j = 0 TO 3
        FOR i = 0 TO 3
            READ bx4(i, j)
        NEXT
    NEXT

    DIM bx8(0 TO 7, 0 TO 7) AS INTEGER
    DATA 0,48,12,60, 3,51,15,63, 32,16,44,28, 35,19,47,31, 8,56,4,52, 11,59,7,55, 40,24,36,20, 43,27,39,23
    DATA 2,50,14,62, 1,49,13,61, 34,18,46,30, 33,17,45,29, 10,58,6,54, 9,57,5,53, 42,26,38,22, 41,25,37,21

    DIM w AS LONG, h AS LONG, x AS LONG, y AS LONG, c AS _UNSIGNED LONG
    DIM r AS INTEGER, g AS INTEGER, b AS INTEGER
    w = _WIDTH(img): h = _HEIGHT(img)

    DIM oldS AS LONG: oldS = _SOURCE: _SOURCE img
    DIM oldD AS LONG: oldD = _DEST: _DEST img

    DIM t AS SINGLE, bias AS SINGLE
    DIM m AS INTEGER

    FOR y = 0 TO h - 1
        FOR x = 0 TO w - 1
            c = POINT(x, y)
            r = _RED32(c): g = _GREEN32(c): b = _BLUE32(c)
            IF matrixSize = 4 THEN
                m = bx4(x AND 3, y AND 3) ' 0..15
                t = (m + 0.5) / 16! - 0.5
            ELSE
                m = bx8(x AND 7, y AND 7) ' 0..63
                t = (m + 0.5) / 64! - 0.5
            END IF
            bias = amount * 64! * t ' scale ±32 by amount (t in -0.5..0.5)

            r = Clamp8%%(r + CINT(bias))
            g = Clamp8%%(g + CINT(bias))
            b = Clamp8%%(b + CINT(bias))

            PSET (x, y), NearestColorUL&(r, g, b, useSRGB)
        NEXT
    NEXT

    _SOURCE oldS: _DEST oldD
END SUB

' ---------- Floyd–Steinberg Dither (Simplified) ----------

SUB ApplyFloydSteinbergDither (img AS LONG, useSRGB AS _BYTE, serpentine AS _BYTE)
    IF PalCount <= 0 THEN EXIT SUB

    DIM w AS LONG, h AS LONG, x AS LONG, y AS LONG
    w = _WIDTH(img): h = _HEIGHT(img)

    DIM oldS AS LONG: oldS = _SOURCE: _SOURCE img
    DIM oldD AS LONG: oldD = _DEST: _DEST img

    ' Simplified error arrays (one row at a time)
    DIM er(0 TO w) AS DOUBLE
    DIM eg(0 TO w) AS DOUBLE  
    DIM eb(0 TO w) AS DOUBLE
    DIM ner(0 TO w) AS DOUBLE
    DIM neg(0 TO w) AS DOUBLE
    DIM neb(0 TO w) AS DOUBLE

    DIM c AS _UNSIGNED LONG, r AS DOUBLE, g AS DOUBLE, b AS DOUBLE
    DIM idx AS INTEGER, ir AS INTEGER, ig AS INTEGER, ib AS INTEGER
    DIM dir AS INTEGER, xs AS LONG, xe AS LONG, xi AS LONG

    FOR y = 0 TO h - 1
        ' zero next-row error
        FOR x = 0 TO w
            ner(x) = 0: neg(x) = 0: neb(x) = 0
        NEXT

        IF serpentine THEN
            IF (y AND 1) = 0 THEN
                dir = 1: xs = 0: xe = w - 1
            ELSE
                dir = -1: xs = w - 1: xe = 0
            END IF
        ELSE
            dir = 1: xs = 0: xe = w - 1
        END IF

        xi = xs
        DO
            c = POINT(xi, y)
            r = _RED32(c) + er(xi)
            g = _GREEN32(c) + eg(xi)
            b = _BLUE32(c) + eb(xi)
            IF r < 0 THEN r = 0 ELSE IF r > 255 THEN r = 255
            IF g < 0 THEN g = 0 ELSE IF g > 255 THEN g = 255
            IF b < 0 THEN b = 0 ELSE IF b > 255 THEN b = 255

            idx = NearestIndex(CINT(r), CINT(g), CINT(b), useSRGB)
            ir = PalR(idx): ig = PalG(idx): ib = PalB(idx)
            PSET (xi, y), _RGB32(ir, ig, ib)

            ' error
            r = r - ir: g = g - ig: b = b - ib

            DIM xp1 AS LONG, xm1 AS LONG
            xp1 = xi + dir
            xm1 = xi - dir

            IF xp1 >= 0 AND xp1 < w THEN
                er(xp1) = er(xp1) + r * 7 / 16.0
                eg(xp1) = eg(xp1) + g * 7 / 16.0
                eb(xp1) = eb(xp1) + b * 7 / 16.0
            END IF

            IF xm1 >= 0 AND xm1 < w THEN
                ner(xm1) = ner(xm1) + r * 3 / 16.0
                neg(xm1) = neg(xm1) + g * 3 / 16.0
                neb(xm1) = neb(xm1) + b * 3 / 16.0
            END IF

            ner(xi) = ner(xi) + r * 5 / 16.0
            neg(xi) = neg(xi) + g * 5 / 16.0
            neb(xi) = neb(xi) + b * 5 / 16.0

            IF xp1 >= 0 AND xp1 < w THEN
                ner(xp1) = ner(xp1) + r * 1 / 16.0
                neg(xp1) = neg(xp1) + g * 1 / 16.0
                neb(xp1) = neb(xp1) + b * 1 / 16.0
            END IF

            IF xi = xe THEN EXIT DO
            xi = xi + dir
        LOOP

        FOR x = 0 TO w
            er(x) = ner(x): eg(x) = neg(x): eb(x) = neb(x)
        NEXT
    NEXT

    _SOURCE oldS: _DEST oldD
END SUB
